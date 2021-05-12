public class MFA_LoginFlowVFController{
    public static string MFA_EMAIL_TEMPLATE = 'MFA_Verification_Code_Template';
    public static string STR_EMAIL = 'Email';
    public static String STR_MOBILE = 'Mobile';
    public static String STR_USERTYPE = 'UserType';
    public static String STR_SESSIONID = 'SessionId';
    public static String STR_SOURCEIP = 'SourceIP';
    public static String STR_NUMBERS = '0123456789';
    public static STring STR_QRCODE_URL = 'qrCodeUrl';
    public static STring STR_SECRET = 'secret';
    public static String STR_EMAILMASK_REGEX = '(^[^@]{3}|(?!^)\\G)[^@]';
    public static String STR_BLANK = '';
    
    public userIdentityWrapper userIdentity{get;set;}
    public MFA_Settings__c mfaSettings{get;set;}
    public string selectedIdentity{get;set;}
    public boolean isEmailSent{get;set;}
    public QRWrapper qrWrap{get;set;}
    public boolean isSelectIdentityScreen{get;set;}
    public boolean isMobileConfirmationScreen{get;set;}
    public boolean isEmailConfirmationScreen{get;set;}
    public String token{get;set;}
    public String regToken{get;set;}
    
    public Boolean isNewCode{get;set;}
    public String emailHeaderMessage{get;set;}
    public String securityCode{get;set;}
    public Boolean emailErrorFlag{get;set;}
    public Boolean mobileErrorFlag{get;set;}
    
    
    public MFA_LoginFlowVFController(){
        userIdentity = getLoggedInUserInfo();
        mfaSettings = getMFASettings(); 
        
        emailHeaderMessage = mfaSettings.Email_Confirmation_Screen_Message__c;
        emailHeaderMessage = emailHeaderMessage.replace('<USER_EMAIL>', maskEmail(userIdentity.userEmail));
        
        isNewCode = false;
        if(isNewCode){
            emailHeaderMessage = emailHeaderMessage.replace('<VERIFICATION CODE>', 'new verification code');
        }
        else{
            emailHeaderMessage = emailHeaderMessage.replace('<VERIFICATION CODE>', 'verification code');    
        }
        
        isEmailSent = false;
        isSelectIdentityScreen = true;
        isMobileConfirmationScreen = false;
        isEmailConfirmationScreen = false;
        emailErrorFlag = false;
        mobileErrorFlag = false;
    } 
    
    public PageReference doInit() {
        User loggedInUser = [Select id,Disable_Two_Factor_Authentication__c from user where id = :userinfo.getuserId()];
        if(loggedInUser.Disable_Two_Factor_Authentication__c){
            return Auth.SessionManagement.finishLoginFlow();
        }   
        return null; 
    }
    
    public PageReference continueClick() {
        isSelectIdentityScreen = false;
        if(selectedIdentity == STR_EMAIL){
            isEmailConfirmationScreen = true;
            isEmailSent = sendEmailWithSecurityCode(false);     
        }
        else if(selectedIdentity == STR_MOBILE){
            isMobileConfirmationScreen = true;
            if(!userIdentity.hasRegisteredToken){
                qrWrap = getQRCode();
            } 
        }  
        
        return null;
    }
    
    public PageReference backButtonClick() {
        isSelectIdentityScreen = true;
        isMobileConfirmationScreen = false;
        isEmailConfirmationScreen = false;
        emailErrorFlag = false;
        mobileErrorFlag = false;
        
        return null;
    }
    
    public PageReference submitButtonClick() {
        Boolean status = false;
        emailErrorFlag = false;
        mobileErrorFlag = false;
        if(isEmailConfirmationScreen){
            status = validateSecurityCode(securityCode);
        }
        else if(isMobileConfirmationScreen){
            status = validateTOTP(regToken,qrWrap != null ? qrWrap.secretKey : null,token);  
        }

        if(status){
            return Auth.SessionManagement.finishLoginFlow();
        }
        else{
            if(isEmailConfirmationScreen){
                emailErrorFlag = true;
            }
            else if(isMobileConfirmationScreen){
                mobileErrorFlag = true;
            }
        }

        return null;
    }
    
    public void newVerificationCodeClick() {
        isNewCode = sendEmailWithSecurityCode(true);
    }
    
    public List<SelectOption> getIdentityOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        string option1Label = 'Send an email to me at '+userIdentity.userEmail;
        string option2Label = 'Use a mobile authenticator app for user '+userIdentity.userName; 
        
        options.add(new SelectOption(STR_EMAIL,option1Label));
        options.add(new SelectOption(STR_MOBILE,option2Label));
        
        return options;
    }

    
   public static userIdentityWrapper getLoggedInUserInfo(){  
        userIdentityWrapper userIdentity = new userIdentityWrapper();
        userIdentity.userId = userInfo.getUserId();
        userIdentity.userName = userInfo.getName();
        userIdentity.userEmail = userInfo.getUserEmail();
        
        List<TwoFactorInfo> twoFactors = [SELECT UserId, Type FROM TwoFactorInfo where userID = :userIdentity.userId];
        userIdentity.hasRegisteredToken = !twoFactors.isEmpty();
        
        Map<String,String> sessionAttributes;
        if(!Test.isRunningTest()){
            sessionAttributes = Auth.SessionManagement.getCurrentSession();
            userIdentity.userType = sessionAttributes.get(STR_USERTYPE);
            userIdentity.authSessionId = sessionAttributes.get(STR_SESSIONID);
            
            String sourceIP = sessionAttributes.get(STR_SOURCEIP);
            if(sourceIP != null){
                userIdentity.isTrustedIPAddress = Auth.SessionManagement.inOrgNetworkRange(sourceIP);
            }
        }
        
        return userIdentity;
    }
    
    public static MFA_Settings__c getMFASettings(){
        return MFA_Settings__c.getOrgDefaults();
    }
    
    public void removeMFAaccess(){
        List<TwoFactorInfo> twoFactors = [SELECT UserId, Type FROM TwoFactorInfo where userID = :userIdentity.userId];
        if(twoFactors != null && !twoFactors.isEmpty()){
            delete twoFactors;
            userIdentity = getLoggedInUserInfo();
            continueClick();
        }
    }
    
    public static Boolean sendEmailWithSecurityCode(Boolean byPassFlag){
        Boolean status = false;
        List<MFA_Custom_Auth__c> mcaList = [Select id,userId__c,Verification_Code__c,Expired_time__c,lastmodifiedDate 
                                                                            From MFA_Custom_Auth__c 
                                                                            Where userId__c = :userinfo.getUserId()];     
        if(mcaList.isEmpty()){
            MFA_Custom_Auth__c mca = upsertMFA_Custom_Auth(null,false);
            if(mca != null){ 
                status = sendEmailNotification(mca.Verification_Code__c,mca.id);
            }
        } 
        else{
            MFA_Custom_Auth__c mca = mcaList[0];

            //Restricting multiple updates within the time on same record.
            if(datetime.now() > mca.Expired_time__c || byPassFlag){
                mca = upsertMFA_Custom_Auth(mcaList[0].id,byPassFlag); 
                if(mca != null){ 
                    status = sendEmailNotification(mca.Verification_Code__c,mca.id);
                }
            }
        } 
        
        return status;
    }

    public static Boolean validateSecurityCode(string securityCode){
        List<MFA_Custom_Auth__c> mcaList = [Select id,userId__c,Verification_Code__c,Expired_time__c,lastmodifiedDate 
                                                                            From MFA_Custom_Auth__c 
                                                                            Where userId__c = :userinfo.getUserId()];
        String verificationCode;
        MFA_Settings__c mfaSettings = MFA_Settings__c.getInstance();                                            
        if(!mcaList.isEmpty()){
            MFA_Custom_Auth__c mca = mcaList[0];
            
            //Restricting multiple updates within the time on same record.
            if(datetime.now() <= mca.Expired_time__c){
                verificationCode = mca.Verification_Code__c;
            }
        }
        
        Boolean status = false;
        if(securityCode != null && securityCode == verificationCode){
            status = true;
        }

        return status;
    }
    
     //upsert the MFA_Cust_Auth record
    public static MFA_Custom_Auth__c upsertMFA_Custom_Auth(string mcaId,boolean resendFlag){    
        MFA_Custom_Auth__c mca = new MFA_Custom_Auth__c();
        try{
            MFA_Settings__c mfaSettings = MFA_Settings__c.getInstance();
            String randomCode  = getRandomCode();

            if(!string.isBlank(mcaId)){
                mca.Id = mcaId;   
                if(resendFlag){
                    mca.BypassFlag__c = true;
                } 
            }
            mca.ownerId = userInfo.getUserId();
            mca.UserId__C = userInfo.getUserId();
            mca.Verification_Code__c = randomCode;
            mca.Expired_time__c = datetime.now().addminutes(Integer.valueOf(mfaSettings.Email_Expired_Time_In_Minutes__c));
            
            
            if(mca != null){
                upsert mca;
            }      
        }
        catch(Exception e){
            mca = null;
            //createErrorLog(e.getStackTraceString(),e.getLineNumber(),'MFA_SendEmail.upsertMFA_Custom_Auth');
        }
        
        return mca;
    }
    
     //To send the email notification with the verification code
    public static boolean sendEmailNotification(string code,string mfaId){
        Boolean emailStatus = false;
        try{
            List<EmailTemplate> etList = [Select id,subject,Markup,name,developername from emailtemplate 
                                                                where developername = :MFA_EMAIL_TEMPLATE];
            
            EmailTemplate template = (etList != null && !etList.isEmpty()) ? etList[0] : null;
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            if(template != null){
                OrgWideEmailAddress[] oweList = [select id from OrgWideEmailAddress where address = '' limit 1];
    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                if(oweList != null && !oweList.isempty()){
                    mail.setOrgWideEmailAddressId(oweList[0].id);
                }
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(userInfo.getUserId()); 
                mail.setWhatId(mfaId); 
                mail.setTemplateId(template.id);
                mail.setToAddresses(new String[]{userInfo.getUserEmail()});
                
                 
                mailList.add(mail);

                // Send the email
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailList);
                if (!results.get(0).isSuccess()) {
                    String errorMessage = results.get(0).getErrors()[0].getMessage();
                    emailStatus = false;
                }
                else{
                    emailStatus = true;
                }  
            } 
        }
        Catch(Exception e){
            //createErrorLog(e.getStackTraceString(),e.getLineNumber(),'MFA_SendEmail.sendEmailNotification');
        }
        
        return emailStatus;
    }
    
      //To Generate random code
    public static string getRandomCode(){
        final string chars = STR_NUMBERS;
        string randStr = '';
        while(randStr.length() < 5){
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()),chars.length());
            randStr += chars.substring(idx,idx+1);
        }
        return randStr;
    }
    
    public static QRWrapper getQRCode(){
        QRWrapper qw = new QRWrapper();
        Map<String,String> QR = Auth.SessionManagement.getQrCode();      
        qw.qr_URL= QR.get(STR_QRCODE_URL);
        qw.secretKey = QR.get(STR_SECRET);
            
        return qw;
    }
      
    public static Boolean validateTOTP(string regToken, string secretKey,string token){
        String userid   = UserInfo.getUserId();   
        Boolean status = false;
        
        if(token != null){
            try {
                status = Auth.SessionManagement.validateTotpTokenForUser(token);
            } 
            catch(Exception e)
            {
                system.debug('The key is invalid or the current user has attempted too many validations');
            } 
        }
        else{
            if(regToken != null){
                try {
                    status = Auth.SessionManagement.validateTotpTokenForKey(secretKey, regToken);
                    
                    if(status){
                       TwoFactorInfo TwoFactor = new TwoFactorInfo(UserId=userid, Type='TOTP', SharedKey=secretKey);
            
                       insert(TwoFactor);
                    }
                } 
                catch(Exception e){
                    system.debug('The key is invalid or the current user has attempted too many validations');
                }  
            }   
        }
        
        return status;
    }
    
    public static string maskEmail(string email){
        String email_masked = string.isNotempty(email) ? email.replaceAll(STR_EMAILMASK_REGEX, '$1*') : STR_BLANK;
        
        return email_masked;
    }    
    
    public Class userIdentityWrapper{
        public string userId{get;set;}
        public string userName{get;set;}
        public string userEmail{get;set;}
        public string userType{get;set;}
        public string authSessionId{get;set;}
        public Boolean isIPChangedSinceLogin{get;set;}
        public Boolean isTrustedIPAddress{get;set;}
        public Boolean hasRegisteredToken{get;set;}
    }
    
    public Class QRWrapper{
        public String qr_URL{get;set;}
        public String secretKey{get;set;}
    }

    public PageReference FinishLoginFlowStartUrl() {
        //finish the login flow and send you to the startUrl (account page in this case)
        return Auth.SessionManagement.finishLoginFlow('/001');
    }

    public PageReference FinishLoginFlow() {
        //finish the login flow and send you the default homepage
        return Auth.SessionManagement.finishLoginFlow();
    } 
}