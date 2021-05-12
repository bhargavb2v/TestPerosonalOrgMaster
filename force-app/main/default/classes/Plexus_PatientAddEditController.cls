global class Plexus_PatientAddEditController {
    /*global String recordId{get;set;}
    global String pageMode{get;set;}
    global String studySFId{get;set;}
    global String siteSFId{get;set;}
    global String mrn{get;set;}
    global Boolean isUser{get;set;}
    
    
    public String isPatient{get;set;}
    public String isAdmin{get;set;}
    public String isStaff{get;set;}
    public String isViewEncryptedDataUser{get;set;}

    
    public user u;
    
    public Plexus_PatientAddEditController () {
        
        recordId = Apexpages.currentpage().getparameters().get('pId'); 
        pageMode = Apexpages.currentpage().getparameters().get('mode'); 
        mrn = Apexpages.currentpage().getparameters().get('mrn'); 

        studySFId = Apexpages.currentpage().getparameters().get('sId'); 
        u = [Select id,name,isActive,profile.Name,contactId,contact.Plexus_Site__c,contact.plexus_patient__c 
                                                                    From User where id = :userinfo.getUserId()];
        
         siteSFId = u.contact.plexus_site__c;
        
      
        List<User> uList = [Select id,name,isActive,contactId,contact.Plexus_Site__c,contact.plexus_patient__c 
                                         From User where contact.plexus_patient__c = :recordId and isActive = true];
       
        if(ulist.size() > 0){
          isUser = True;
          //  system.debug
        }else{
            isUser = False;
        }
       // u = [Select id , name  from User where contact.plexus_patient__c =: ispatientId];
        isViewEncryptedDataUser = Plexus_Utility.isViewEncryptedDataAccess();
    } 
    
    public pageReference init(){
        Plexus_Settings__c setting = Plexus_Settings__c.getOrgDefaults();

        if(u.profile.Name == setting.Site_Staff_Profile_Name__c){
            isStaff = 'Yes';
            List<Plexus_Study_Site_CSC__c> siteStaffList = [select id From Plexus_Study_Site_CSC__c 
                                                                    Where csc__c = :u.contactId And
                                                                          site__c = :u.contact.plexus_Site__c And 
                                                                          study__c = :studySFId limit 1];
                                                                    
             if(siteStaffList.size() == 0){
                 PageReference p = page.Plexus_Exception;
                 return p;
             }
             
             if(recordId != null && recordId != '' && pageMode != 'New'){
                 List<Plexus_Study_Site_Patient__c> patientList = [select id From Plexus_Study_Site_Patient__c 
                                                                        Where patient__c = :recordId And
                                                                              site__c = :u.contact.plexus_Site__c And 
                                                                              study__c = :studySFId limit 1];
                                                                              
                 if(patientList.size() == 0){
                     PageReference p = page.Plexus_Exception;
                     return p;
                 }
             }
        }
        else if(u.profile.Name == setting.Patient_Profile_Name__c){
            isPatient = 'Yes';
            PageReference p = page.Plexus_Exception;
            return p;
        }
        else{
            isAdmin = 'Yes';
            //PageReference p = page.Plexus_Exception;
            //return p;
        }
        return null;
    }
    
    @RemoteAction
    public static resultWrapper getInitInformation(String studyId,String siteId,String recordId,string pageMode) {
        resultWrapper rw = new resultWrapper();
        patientFormWrapper patW = new patientFormWrapper();
        List<conActWrapper> conActivityList = new List<conActWrapper>();
        List<docsWrapper> docsList = new List<docsWrapper>();
        List<diagnosisWrapper> diagnosisList = new List<diagnosisWrapper>();
        List<String> regStudList = new List<String>();
        if(recordId != null && recordId != '' && pageMode != 'New'){
            Plexus_Patient__c pat = [select id,name,patient_Id__c,last_Name__c,first_Name__c,phone__c,email__c,
                                                           Date_of_Birth__c,alternate_Email__c,address__c,city__c,
                                                           state__c,country__c,zip_code__c, Gender__c,
                                                           alternate_Phone__c,prefix__c  
                                                           From Plexus_Patient__c Where Id = :recordId];
                                                                
            
            List<Plexus_Study_Site_Patient__c> psscList = [select id,patient__c,site__c,site__r.site_Id__c,site__r.Site_Name__c, 
                                                                                study__c,study__r.Name,study__r.study_ID__c,
                                                                                Study_Version__c,
                                                                                Consent_Status__c,Date_of_Consent__c,Reason_to_Withdraw__c,Other_Reason__c    
                                                                           From Plexus_Study_Site_Patient__c 
                                                                           Where patient__c = :recordId];   
            
            for(Plexus_Study_Site_Patient__c pssc:psscList){
                if(pssc.study__c == studyId){
                    //regStudList.add(pssc.study__r.Name);
                    patW.Id = pat.Id; 
                    patW.patientId = pat.patient_Id__c;
                    patW.prefix = pat.prefix__c;
                   // patW.prefName = pat.Preferred_Name__c;
                    patW.firstName = pat.first_Name__c;
                    patW.lastName = pat.last_Name__c;
                    patW.phone = pat.phone__c;
                    //patW.sitemrn = pat.Site_MRN__c
                    patW.altPhone = pat.alternate_Phone__c;
                    patW.email = pat.email__c;
                    patW.altEmail = pat.alternate_Email__c;
                    patW.address = pat.address__c;
                    patW.city = pat.City__c;
                    patW.state = pat.state__c;
                    patW.country = pat.country__c;
                    patW.zipCode = pat.zip_code__c;
                    //added for enhancements.
                    patW.name = pat.name;
                    patW.gender= pat.Gender__c;
                    
                    
                    patW.dob =  pat.Date_of_Birth__c != null ? setDateToStringformat(pat.Date_of_Birth__c) : null;
                    
                    patW.pssSFId = pssc.Id;
                    patW.consentStatus = pssc.Consent_Status__c;
                    patW.dateConsent =  pssc.Date_of_Consent__c != null ? setDateToStringformat(pssc.Date_of_Consent__c) : null; 
                    patW.reasonConWithdraw = pssc.Reason_to_Withdraw__c;
                    patW.otherReasonWithdraw = pssc.Other_Reason__c;
                    patW.studySFId = pssc.study__c;
                    patW.studyName = pssc.study__r.Name;
                    patW.studyId = pssc.study__r.study_Id__c;
                    patW.siteSFId = pssc.site__c;
                    patW.siteId = pssc.site__r.site_Id__c;
                    patW.siteName = pssc.site__r.Site_Name__c;
                    patW.studyVersionSFId = pssc.Study_Version__c;
                    
                    
                    List<Plexus_Consent_Activity__c> pcActList = [Select id,Plexus_Stdy_Site_Pat__c,Plexus_Patient_Name__c,Plexus_Consent_Site__c,
                                                             Plexus_Consent_Study__c,Consent_Status__c, Consent_Time__c,LastModifiedDate,Withdrawal_Reason__c,Other_Withdrawal_Reason__c
                                                             from Plexus_Consent_Activity__c
                                                             where Plexus_Stdy_Site_Pat__c = :pssc.Id
                                                             order by createddate desc];
                    
                    for(Plexus_Consent_Activity__c pcAct : pcActList){
                        if(pcActList.size() > 0) {
                            conActWrapper con = new conActWrapper();
                            con.conActStatus = pcAct.Consent_Status__c;
                            con.conActDate = pcAct.Consent_Time__c != null ? setDateToStringformat(pcAct.Consent_Time__c) : null;
                            con.conActStudy = pcAct.Plexus_Consent_Study__c;
                            con.conActSite = pcAct.Plexus_Consent_Site__c;
                            con.conActPatient = pcAct.Plexus_Patient_Name__c;
                            con.conActpssp = pcAct.Plexus_Stdy_Site_Pat__c;
                            con.conLastModDate = string.valueOfGmt(pcAct.LastModifiedDate);
                            con.conReasonGrid = pcAct.Withdrawal_Reason__c;
                            con.Id = pcAct.Id;
                       //     con.conReasonGrid = pcAct.Plexus_Stdy_Site_Pat__r.Reason_to_Withdraw__c;
                            
                            
                            conActivityList.add(con);
                        }
                    }
                    
                    List<Patient_Attachments__c> pAttList = [Select id,Document_Type__c,File_Name__c,Date_of_Consent__c,createddate,lastmodifieddate,  
                                                                            (select id,Name from attachments) 
                                                                            from Patient_Attachments__c where Study_Site_Patient__c = :pssc.Id 
                                                                            order by createddate desc];
                                                                          
                    for(Patient_Attachments__c pAtt : pAttList){
                        if(pAtt.attachments.size() > 0){
                            docsWrapper doc = new docsWrapper();
                            doc.fileName = pAtt.attachments[0].Name;
                            doc.docType = pAtt.document_Type__c;
                            doc.dateConsent = pAtt.Date_of_Consent__c != null ? setDateToStringformat(pAtt.Date_of_Consent__c) : null;
                            doc.Id = pAtt.Id;
                            doc.attId = pAtt.attachments[0].Id;
                            doc.createddate = setDateToStringformat(pAtt.Createddate.date());
                            doc.lastmodifieddate = setDateToStringformat(pAtt.lastmodifieddate.date());
                            
                            docsList.add(doc);
                        }
                    }
                }
                else{
                    regStudList.add(pssc.study__r.Name);
                }
            }
            
            List<Plexus_Diagnosis__c> pdList = [Select id,Diagnosis__c,Diagnosis_Date__c 
                                                                    from Plexus_Diagnosis__c 
                                                                    Where patient__c = :recordId order by createddate desc];
            for(Plexus_Diagnosis__c pd : pdList){
                diagnosisWrapper dW = new diagnosisWrapper();
                dw.diagnosis = pd.Diagnosis__c;
                dw.diagnosisDate = setDateToStringformat(pd.Diagnosis_Date__c);
                dw.Id = pd.Id;
                
                diagnosisList.add(dw);
            }
        }
        else{
            if(recordId != null && recordId != '' && pageMode == 'New'){
                Plexus_Patient__c pat = [select id,name,patient_Id__c,last_Name__c,first_Name__c,phone__c,email__c,
                                                           Date_of_Birth__c,alternate_Email__c,address__c,city__c,
                                                           state__c,country__c,zip_code__c, Gender__c,
                                                           alternate_Phone__c,prefix__c //,Preferred_Name__c  
                                                           From Plexus_Patient__c Where Id = :recordId];
                patW.Id = pat.Id; 
                patW.patientId = pat.patient_Id__c;
                patW.prefix = pat.prefix__c;
              //  patW.prefName = pat.Preferred_Name__c;
                patW.firstName = pat.first_Name__c;
                //patW.sitemrn = pat.Site_MRN__c;
                patW.lastName = pat.last_Name__c;
                patW.phone = pat.phone__c;
                patW.altPhone = pat.alternate_Phone__c;
                patW.email = pat.email__c;
                patW.altEmail = pat.alternate_Email__c;
                patW.address = pat.address__c;
                patW.city = pat.City__c;
                patW.state = pat.state__c;
                patW.country = pat.country__c;
                patW.zipCode = pat.zip_code__c;
                //added for enhancements.
                patW.name = pat.name;
                patW.gender= pat.Gender__c;
                patW.dob =  pat.Date_of_Birth__c != null ? setDateToStringformat(pat.Date_of_Birth__c) : null; 
                
                List<Plexus_Study_Site_Patient__c> psscList = [select id,patient__c,site__c,site__r.site_Id__c,site__r.Site_Name__c, 
                                                                                study__c,study__r.Name,study__r.study_ID__c,
                                                                                Study_Version__c,
                                                                                Consent_Status__c,Date_of_Consent__c    
                                                                           From Plexus_Study_Site_Patient__c 
                                                                           Where patient__c = :recordId];
                                                                           
                for(Plexus_Study_Site_Patient__c pssc:psscList){
                    regStudList.add(pssc.study__r.Name);                                       
                }
                
                List<Plexus_Diagnosis__c> pdList = [Select id,Diagnosis__c,Diagnosis_Date__c 
                                                                    from Plexus_Diagnosis__c 
                                                                    Where patient__c = :recordId order by createddate desc];
                for(Plexus_Diagnosis__c pd : pdList){
                    diagnosisWrapper dW = new diagnosisWrapper();
                    dw.diagnosis = pd.Diagnosis__c;
                    dw.diagnosisDate = setDateToStringformat(pd.Diagnosis_Date__c);
                    dw.Id = pd.Id;
                    
                    diagnosisList.add(dw);
                }                                                      
            }
            
            Plexus_Study__c ps = [select id,Name,study_Id__c from Plexus_Study__c where id = :studyId];
            patW.studySFId = ps.Id;
            patW.studyName = ps.Name;
            patW.studyId = ps.study_Id__c;
            Plexus_Site__c pSite = [select id,Site_Name__c,site_Id__c from Plexus_Site__c where id = :siteId];
            patW.siteSFId = pSite.Id;
            patW.siteName = pSite.Site_Name__c;
            patW.siteId = pSite.site_Id__c;  
        }
        
        List<Plexus_Study_Site__c> pssList = [select id,site__c,study__c,study__r.Name,study__r.study_ID__c,
                                                         Site__r.Site_Name__c,site__r.site_Id__c, 
                                                         Study_Version__c,Study_Version__r.Version_Name__c,
                                                         Study_Version__r.Version_Date__c   
                                                    From Plexus_Study_Site__c 
                                                    Where study__c = :studyId And 
                                                          Current_Registered_Version__c = true]; 
        
        Map<String,string> siteStudyVersionMap = new Map<String,string>();  
        for(Plexus_Study_Site__c pss : pssList){
            Plexus_site__c site = new Plexus_site__c(Id=pss.site__c,Site_Name__c=pss.site__r.Site_Name__c,
                                                                    site_Id__c = pss.site__r.site_Id__c);
                                                                    
            siteStudyVersionMap.put(site.Id,pss.study_Version__c); 
        }
        rw.patientForm = patW;
        rw.siteStudyVersionMap = siteStudyVersionMap;
        rw.conStatList = getConsentStatusValues();
        rw.withReasonList = getWithdrawalReasonValues();
        rw.prefixList = getPrefixValues();
        rw.genderList = getGenderValues();
        rw.docTypeList = getDocTypeValues();
        rw.docsList = docsList;
        rw.diagnosisList = diagnosisList;
        rw.conActivityList = conActivityList;
        rw.diagnosisValues = getDiagnosisValues();
        
        if(regStudList.size() > 0){
            rw.regStudies = regStudList; //string.join(regStudList,',');
        }
        else{
            rw.regStudies = null;
        }
        
        return rw;
    }
    
    @RemoteAction
    public static resetPasswordWrapper resetPassword(Id recordId){
        Boolean isSuccess = false;
       List<User> userList = [Select id,profileId,profile.Name,name,username,email,user_username__c,user_email__c,user_first_name__c,user_last_Name__c,
                                user_phone__c from user where contact.Plexus_patient__c =:recordId Limit 1];
        system.debug('recordId'+recordId);
        resetPasswordWrapper rw = new resetPasswordWrapper();
         if(userList.size() > 0){
            // system.debug('##userList')
                System.resetPasswordResult res = System.resetPassword(userList[0].Id, false);
                if (res != null && !String.isBlank(res.getPassword())){
                     isSuccess = Plexus_Utility.sendResetPasswordemail(userList[0],res.getPassword());
                    rw.email = userList[0].user_email__c;
                   // errorMsg = 'A new password for the user has been sent via email ('+userList[0].user_email__C+').';
                }
         }
        
        rw.isSuccess = isSuccess;
       // rw.email = userList[0].user_email__c;
        
       return rw;
    }
    
    @RemoteAction
    public static resultWrapper insertForm(String recordId,patientFormWrapper uForm,List<docsWrapper> attList,
                                                           List<diagnosisWrapper> diagList,List<String> delAttList,
                                                           List<String> delDiagList) {  
        List<List<sobject>> ssList;  
        List<List<sobject>> patientList;
        List<String> resultCon = new List<String>();
        List<String> resultPatient = new List<String>();
        Set<String> sitemrnPatient = new Set<String>();
        
        if(uForm.Id != null && uForm.Id != ''){  
           // ssList = [Select id,name from contact where email = :uForm.email and plexus_patient__c != :uForm.Id limit 1]; 
            ssList = [Find :uForm.email IN EMAIL Fields returning contact(id,name,email where plexus_patient__c != :uForm.Id),Plexus_patient__c(id,name,email__c where id != :uForm.Id)]; 
                
        }
        else {
            // ssList = [Select id,name from contact where email = :uForm.email limit 1]; 
            ssList = [Find :uForm.email IN EMAIL Fields returning contact(id,name,email),Plexus_patient__c(id,name,email__c)]; 
        }
        
        for(Contact con : (List<Contact>)ssList[0]){
            if(con.email == uForm.email){
                resultCon.add(con.Email);
            }
        }
        
        for(Plexus_Patient__C pp : (List<Plexus_Patient__c>)ssList[1]){
            if(pp.email__c == uForm.email){
                resultPatient.add(pp.Email__c);
            }
        }
        
        if(resultCon.size() > 0 || resultPatient.size() > 0){
            throw new applicationException('Email already exists. Please enter a new email to continue.');
        }
        
        String sitemrn = uForm.patientId+''+uform.siteSFId;
        patientList = [Find :sitemrn in All fields returning Plexus_Patient__c(id,Site_MRN__c where id != :uForm.Id)];
         for(Plexus_Patient__C pp : (List<Plexus_Patient__c>)patientList[0]){
            if(pp.Site_MRN__c == sitemrn){
                sitemrnPatient.add(pp.Site_MRN__c);
                break;
            }
        }
        if(sitemrnPatient.size() > 0 || sitemrnPatient.size() > 0){
            throw new applicationException('MRN already exists. Please enter a new MRN to continue.');
        }
        
        
        Plexus_Patient__c pat = new Plexus_Patient__c();
        pat.patient_Id__c = uForm.patientId;
        pat.Site_MRN__c = sitemrn;
        pat.prefix__c = uForm.prefix;
        pat.first_Name__c = uForm.firstName;
        pat.last_Name__c = uForm.lastName;
        pat.phone__c = uForm.phone;
        pat.alternate_phone__c = uForm.altPhone;
        pat.email__c = uForm.email;
        pat.alternate_email__c = uForm.altEmail;
        pat.address__c = uForm.address;
        pat.City__c = uForm.city;
        pat.state__c = uForm.state;
        pat.country__c = uForm.country;
        pat.zip_code__c = uForm.zipCode;
        //added for enhancements.
        //pat.name = uForm.name;
        pat.Gender__c= uForm.gender;
        
        pat.Date_of_Birth__c = uform.dob != null && uform.dob != '' ? setStringToDateFormat(uform.dob) : null;
                
        pat.Plexus_Site__c = uForm.siteSFId;
        
        if(uForm.Id != null && uForm.Id != ''){
            pat.Id = uForm.Id;
        }
        
        upsert pat;
        
        Plexus_Study_Site_Patient__c psst = new Plexus_Study_Site_Patient__c();
        psst.patient__c = pat.Id;
        psst.Study__c = uForm.studySFId;
        psst.Site__c = uForm.siteSFId;
        psst.study_Version__c = uForm.studyVersionSFId;
        psst.Consent_Status__c = uForm.consentStatus;
        psst.Date_of_Consent__c = uform.dateConsent != null && uform.dateConsent != '' ? setStringToDateFormat(uform.dateConsent) : null;
        psst.Reason_to_Withdraw__c = uform.reasonConWithdraw != 'Select' ? uform.reasonConWithdraw : null;
        psst.Other_Reason__c = uform.otherReasonWithdraw;
        
        if(uForm.pssSFId != null && uForm.pssSFId != ''){
            psst.Id = uForm.pssSFId;
        }
        
        upsert psst;
        
        List<Patient_Attachments__c> pAttList = new List<Patient_Attachments__c>();
        List<Attachment> attachList = new List<Attachment>();
        for(docsWrapper att: attList){
            if(att.Id == null || att.Id == ''){
                String extId = String.valueOf(datetime.now());
                Patient_Attachments__c pAtt = new Patient_Attachments__c();
                pAtt.Document_Type__c = att.docType;
                pAtt.Date_of_Consent__c = uform.dateConsent != null && uform.dateConsent != '' ? setStringToDateFormat(uform.dateConsent) : null;
                pAtt.File_Name__c = att.fileName;
                pAtt.study__c = psst.study__c;
                pAtt.site__c = psst.site__c;
                pAtt.patient__c = psst.patient__C;
                pAtt.Study_Site_Patient__c = psst.Id;
                pAtt.ExternalId__c = extId; 
                if(att.Id != null && att.Id != ''){
                    pAtt.Id = att.Id;
                }
                pAttList.add(pAtt);
                
                Attachment attach = new Attachment();
                attach.Name = att.fileName;
                attach.ContentType = att.fileType;
               
                attach.Body = EncodingUtil.Base64Decode(att.fileBody);
                
                attachList.add(attach);
            }
         }
        
        if(attachList.size() > 0){
            upsert pAttList;
            for(integer i=0;i<attachList.size();i++){
               attachList[i].parentId = pAttList[i].Id;
            }
            
            upsert attachList;
         }
        
        List<Plexus_Diagnosis__c> pdList = new List<Plexus_Diagnosis__c>();
        for(diagnosisWrapper diag : diagList){
            if(diag.Id == null || diag.Id == ''){
                Plexus_Diagnosis__c pd = new Plexus_Diagnosis__c();
    
                pd.Diagnosis__c = diag.diagnosis;
                pd.Diagnosis_Date__c = diag.diagnosisDate != null && diag.diagnosisDate != '' ? setStringToDateFormat(diag.diagnosisDate) : null;
                pd.study__c = psst.study__c;
                pd.site__c = psst.site__c;
                pd.patient__c = psst.patient__C;
                pd.Study_Site_Patient__c = psst.Id;
                
                if(diag.Id != null && diag.Id != ''){
                    pd.Id = diag.Id;
                }
    
                pdList.add(pd);
            }
        }
        
        if(pdList.size() > 0){
            upsert pdList;
        }
        
        List<Patient_Attachments__c> paDelList = new List<Patient_Attachments__c>();
        for(String delId : delAttList){
            if(delId != null && delId != ''){
                Patient_Attachments__c pa = new Patient_Attachments__c(Id=delId);
                paDelList.add(pa);
            }
        }
        
        if(paDelList.size() > 0){
            delete paDelList;
        }
        
        List<Plexus_Diagnosis__c> pdDelList = new List<Plexus_Diagnosis__c>();
        for(String delId : delDiagList){
            if(delId != null && delId != ''){
                Plexus_Diagnosis__c pd = new Plexus_Diagnosis__c(id=delId);
                pdDelList.add(pd);
            }
        }
        
        if(pdDelList.size() > 0){
            delete pdDelList;
        }
        
        uForm.Id = pat.Id;
        uForm.pssSFId = psst.Id;
        
        resultWrapper rw = new resultWrapper();
        rw.patientForm = uform;
        
        return rw;
    }

    public static List<String> getConsentStatusValues(){
        List<String> conList = new List<string>();
        
        Schema.DescribeFieldResult fieldResult = Plexus_Study_Site_Patient__c.Consent_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            conList.add(f.getValue());
        }       
        return conList;
    }
    
    public static List<String> getWithdrawalReasonValues(){
        List<String> pList = new List<string>();
        pList.add('Select');
        List<String> pListTemp = new List<string>();
        Map<String,Plexus_Reason_Withdraw__c> allValues = Plexus_Reason_Withdraw__c.getAll();
        for(Plexus_Reason_Withdraw__c prw:allValues.Values()){
        pListTemp.add(prw.Value__c);
        }
        pListTemp.sort();
        pList.addAll(pListTemp);
        return pList;
    }
    
    public static List<String> getPrefixValues(){
        List<String> pList = new List<string>();
        
        Schema.DescribeFieldResult fieldResult = Plexus_Patient__c.Prefix__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        pList.add('Select');
        for(Schema.PicklistEntry f : ple){
            pList.add(f.getValue());
        }       
        return pList;
    }
    
    public static List<String> getGenderValues(){
        List<String> pList = new List<string>();
        pList.add('Select');
        List<String> pListTemp = new List<String>();
        Map<String,Plexus_Gender__c> allValues = Plexus_Gender__c.getAll();
        for(Plexus_Gender__c gen :allValues.Values()){
        pListTemp.add(gen.Value__c);
        }
        pList.addAll(pListTemp);
        return pList;
    }
    
    public static List<String> getDocTypeValues(){
        List<String> dList = new List<string>();
        
        Schema.DescribeFieldResult fieldResult = Patient_Attachments__c.Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        dList.add('Select');
        for(Schema.PicklistEntry f : ple){
            dList.add(f.getValue());
        }      
        return dList;
    }
    
    public static List<String> getDiagnosisValues(){
        List<String> dList = new List<string>();
        
        Schema.DescribeFieldResult fieldResult = Plexus_Diagnosis__c.Diagnosis__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        dList.add('Select');
        for(Schema.PicklistEntry f : ple){
            dList.add(f.getValue());
        }       
        return dList;
    }
    
     public static Date setStringToDateFormat(String myDate) {
       String[] myDateOnly = myDate.split(' ');
       String[] strDate = myDateOnly[0].split('/');
       Integer myIntDate = integer.valueOf(strDate[1]);
       Integer myIntMonth = integer.valueOf(strDate[0]);
       Integer myIntYear = integer.valueOf(strDate[2]);
       Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
       return d;
    }
    public static string setDateToStringformat(Date myDate) {
       //String s = myDate.month() +'/'+myDate.day()+'/'+myDate.year();
       //return s;
       
       String year = string.valueOf(myDate.year());
       String month = string.valueOf(myDate.month());

       month = month.length() > 1 ? month : '0' + month;

       String day = string.valueof(myDate.day());
       day = day.length() > 1 ? day : '0' + day;

      return month+'/'+day+'/'+year;
    }
    
    public class resultWrapper{
        public patientFormWrapper patientForm;
        public Map<String,String> siteStudyVersionMap;
        public List<String> conStatList;
        public List<String> withReasonList;
        public List<string> prefixList;
        public list<string> genderList;
        public List<string> docTypeList;
        public List<conActWrapper> conActivityList;
        public List<docsWrapper> docsList;
        public List<String> diagnosisValues;
        public List<diagnosisWrapper> diagnosisList;
        public List<String> regStudies;
    }
    
    //Wrapper class
    public class conActWrapper{
        @TestVisible
        String Id,conActStatus,conActDate,conActStudy,conActSite,conActPatient,conActpssp,conLastModDate,conReasonGrid;
    }
    
    //Wrapper class
    public class docsWrapper{
        @TestVisible
        String Id,fileName,fileType,parentId,docType,attId,dateConsent;
        @TestVisible
        String fileBody;
        @TestVisible
        String CreatedDate,lastModifiedDate;
    }
    
    //Wrapper class
    public class diagnosisWrapper{
        @TestVisible
        String Id,diagnosisDate,diagnosis;
    }
    
    //Wrapper class
    public class patientFormWrapper{
        @TestVisible
        String Id,name,gender,patientId,prefix,firstName,lastName,prefName,phone,altPhone,email,altEmail,dob,consentStatus,dateConsent,reasonConWithdraw,otherReasonWithdraw;
        @TestVisible
        String address,city,state,country,zipCode;
        @TestVisible
        String pssSFId,siteKey,siteSFId,siteId,siteName,studySFId,studyId,studyName,studyVersionSFId;
    }
    
    public class resetPasswordWrapper{
        
        Boolean isSuccess;
        String email;
        
    }
    
    public class applicationException extends Exception {}*/
}