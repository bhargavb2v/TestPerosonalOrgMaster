public class MFA_LoginFlowController{
    public string resultJson{get;set;}
    public static string MFA_EMAIL_TEMPLATE = 'MFA_Verification_Code_Template';
    
    public MFA_LoginFlowController(){
        resulWrapper result = new resulWrapper();
        result.userIdentity = getLoggedInUserInfo();
        result.mfaSettings = getMFASettings(); 
        
        resultJson = JSON.serialize(result);
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
            userIdentity.userType = sessionAttributes.get('UserType');
            userIdentity.authSessionId = sessionAttributes.get('SessionId');
            
            String sourceIP = sessionAttributes.get('SourceIP');
            if(sourceIP != null){
                userIdentity.isTrustedIPAddress = Auth.SessionManagement.inOrgNetworkRange(sourceIP);
            }
        }
        
        return userIdentity;
    }
    
    public static MFA_Settings__c getMFASettings(){
        return MFA_Settings__c.getOrgDefaults();
    }
    
    @AuraEnabled
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
            system.debug('##'+datetime.now());
            system.debug('###'+mca.expired_time__c);
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

    @AuraEnabled
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
                
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>(); 
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
        final string chars = '0123456789';
        string randStr = '';
        while(randStr.length() < 5){
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()),chars.length());
            randStr += chars.substring(idx,idx+1);
        }
        return randStr;
    }
    
     @AuraEnabled
    public static QRWrapper getQRCode(){
        QRWrapper qw = new QRWrapper();
        Map<String,String> QR = Auth.SessionManagement.getQrCode();      
        qw.qr_URL= QR.get('qrCodeUrl');
        qw.secretKey = QR.get('secret');
            
        return qw;
    }
      
    @AuraEnabled
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
                } 
                catch(Exception e){
                    system.debug('The key is invalid or the current user has attempted too many validations');
                }  
            }   
        }
        
        if(status == true){
           TwoFactorInfo TwoFactor = new TwoFactorInfo(UserId=userid, Type='TOTP', SharedKey=secretKey);

           insert(TwoFactor);
        }
        
        return status;
    }    
    
    public Class resulWrapper{
        @AuraEnabled
        public userIdentityWrapper userIdentity;
         @AuraEnabled
        public MFA_Settings__c mfaSettings;
    }
    
    public Class userIdentityWrapper{
        @AuraEnabled
        public string userId,userName,userEmail,userType,authSessionId;
        @AuraEnabled
        public Boolean isIPChangedSinceLogin,isTrustedIPAddress,hasRegisteredToken;
    }
    
    public Class QRWrapper{
        @AuraEnabled
        public string qr_URL,secretKey;
    }

    public PageReference FinishLoginFlowStartUrl() {
        //do stuff
        
        //finish the login flow and send you to the startUrl (account page in this case)
        return Auth.SessionManagement.finishLoginFlow('/001');
    }

    public PageReference FinishLoginFlow() {
        //do stuff
        
        //finish the login flow and send you the default homepage
        return Auth.SessionManagement.finishLoginFlow();
    } 
}