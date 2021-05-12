global class PatientListViewController{
    /*global String studySFId{get;set;}
    global String siteSFId{get;set;}
    public user u;
    
    public String isPatient{get;set;}
    public String isAdmin{get;set;}
    public String isStaff{get;set;}
    public String isViewEncryptedDataUser{get;set;}
    
    public Plexus_PatientListViewController(){
        studySFId = Apexpages.currentpage().getparameters().get('sId'); 
        u = [Select id,name,profile.Name,contactId,contact.Plexus_Site__c,contact.plexus_patient__c 
                                                                    From User where id = :userinfo.getUserId()];
        siteSFId = u.contact.plexus_site__c;
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
        }
        else if(u.profile.Name == setting.Patient_Profile_Name__c){
            isPatient = 'Yes';
            PageReference p = page.Plexus_Exception;
            return p;
        }
        else{
            isAdmin = 'Yes';
        }
        return null;
    }
    
    @RemoteAction
    public static List<patientWrapper> getInitInformation(String studyId,String siteId){
        system.debug('##### Study '+studyId);                                                           
        List<patientWrapper> rwList = new List<patientWrapper>();                               
        List<Plexus_Patient__c> patientList = [Select Id,Name, First_Name__c,Last_Name__c,Email__c From Plexus_Patient__c]; 
        Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id From Contact Where Plexus_Patient__c in :patientList]);
        
        Map<id,User> portalUserMap = new Map<Id,User>();
        for(user u:[Select LastLoginDate,isActive,contactId,contact.plexus_patient__c FROM User WHERE contactId in :contactMap.keySet()]){
            portalUserMap.put(u.contact.plexus_patient__c,u);
        }
        
        string query;
        List<Plexus_Study_Site_Patient__c> psspList;
        query = 'select id,(select id,Document_type__c,file_name__c from Patient_Attachments__r),'
                +'study__c,study__r.Name,study__r.study_Id__c,site__c,site__r.Site_Name__c,site__r.Site_Id__c,'
                +'patient__c,patient__r.Name,patient__r.patient_Id__c,patient__r.first_name__c,patient__r.last_Name__c,patient__r.email__c,'
                +'patient__r.date_of_birth__c,patient__r.phone__c,consent_Status__c,date_of_consent__c,patient__r.createddate '
                +'From Plexus_Study_Site_patient__c';
        if(studyId != null && studyId != ''){
            query = query+ ' Where study__c = :studyId';
                                                                 
            if(siteId != null && siteId !=''){
                query = query+ ' And site__c = :siteId';    
            }
        }
        system.debug('##### query = '+query); 
        
        query = query+' Order by createdDate desc';

        psspList =  database.query(query);  
                                                      
        for(Plexus_Study_Site_Patient__c pssp : psspList){
             Plexus_Patient__c patient = new Plexus_Patient__c(Id = pssp.patient__c,
                                                                 patient_Id__c = pssp.patient__r.patient_Id__c,
                                                                 First_Name__c = pssp.patient__r.first_Name__c,
                                                                 last_Name__c = pssp.patient__r.last_Name__c,
                                                                 phone__c = pssp.patient__r.phone__c,
                                                                 date_of_birth__c =pssp.patient__r.date_of_birth__c, 
                                                                 email__c = pssp.patient__r.email__c);
                                                                 
             Plexus_Study__c study = new Plexus_study__c(Id=pssp.study__c,Name=pssp.study__r.Name,
                                                                            study_Id__c = pssp.study__r.Study_Id__c);
                                                                            
             Plexus_Site__c site = new Plexus_Site__c(Id=pssp.site__c,Site_Name__c=pssp.site__r.Site_Name__c,
                                                                         site_Id__c = pssp.site__r.site_Id__c);
             patientWrapper rw = new patientWrapper();
             rw.patientSFId = patient.Id;
             rw.pId = pssp.patient__r.Name;
             rw.patientId = patient.patient_Id__c;
             rw.firstName = patient.first_Name__c;
             rw.lastName = patient.last_Name__c;
             rw.fullName = patient.first_Name__c + ' '+patient.last_Name__c;
             rw.email = patient.email__c;
             rw.dob =  patient.Date_of_Birth__c != null ? patient.Date_of_Birth__c : null;
             rw.createddate = pssp.patient__r.createddate;
             
             
             rw.siteSFId = site.Id;
             rw.siteId = site.Site_Id__c;
             rw.siteName = site.Site_Name__c;
             rw.studySFId = study.Id;
             rw.studyId = study.Study_Id__c;
             rw.studyName = study.Name;
             rw.psspSFId = pssp.Id;
             rw.consentStatus = pssp.consent_status__c;
             rw.docList = pssp.Patient_Attachments__r;
             rw.noOfDocs = pssp.Patient_Attachments__r.size();
             if(portalUserMap.containsKey(patient.Id)){
                 rw.contactSFId = portalUserMap.get(patient.Id).contactId;
                if(portalUserMap.get(patient.Id).isActive == false){
                    rw.regStatus = 'De-Registered'; 
                } 
                else if(portalUserMap.get(patient.Id).LastLoginDate != null){
                    rw.regStatus = 'Registered';   
                }
                else{
                    rw.regStatus = 'Invited';
                }
            }
            else{
                rw.regStatus = 'New';
            }            
         
             rwList.add(rw);
         } 
         
         return rwList;                                                             
    }  
    
    @RemoteAction
    public static void sendInvitationToPatient(List<String> patList) {
        //system.debug('patList :'+patList);
        List<Plexus_Patient__c> ppList = [Select id,first_Name__c,last_Name__c,email__c,phone__c,Plexus_site__c  
                                                        from plexus_Patient__c where id in : patList];
        //system.debug('ppList :'+ppList);
        Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id From Contact Where Plexus_Patient__c in :ppList]);
        //system.debug('contactMap :'+contactMap);
        Map<id,User> portalUserMap = new Map<Id,User>();
        for(user u:[Select LastLoginDate,isActive,contactId,contact.plexus_patient__c FROM User WHERE contactId in :contactMap.keySet()]){
            portalUserMap.put(u.contact.plexus_patient__c,u);
        }
        //system.debug('portalUserMap :'+portalUserMap);
        List<Contact> conList = new List<Contact>();
        List<User> existUserList = new List<User>();    
        Plexus_Settings__c ps = Plexus_Settings__c.getOrgDefaults();  
                                                    
        for(Plexus_Patient__c pat : ppList){
            if(portalUserMap.containsKey(pat.Id)){
                existUserList.add(portalUserMap.get(pat.Id));
            }
            else{
                contact con = new contact();
                con.firstName = pat.first_Name__c;
                con.lastName = pat.last_Name__c;
                con.phone = pat.phone__c;
                con.email = pat.email__c;
                //con.Plexus_email__c = pat.email__c;
                con.Plexus_Site__c = pat.plexus_Site__c;
                con.plexus_patient__c = pat.Id;
                
                   
                Account acc = [select id,name from Account where name = :ps.Community_Account_Name__c limit 1];
                //system.debug('ACC: '+acc);
                con.accountId = acc.Id;
            
                conList.add(con);
            }
        }
        
        if(conList.size() > 0){
            upsert conList;
            List<User> userList = new List<User>();
            string profileId = [Select Id,name From Profile where name = :ps.Patient_Profile_Name__c].Id;                                                
            for(Contact con:conList){
                user u = new user();
                u.ProfileId = profileId;
                u.FirstName = con.FirstName;
                u.LastName = con.lastName;
                u.Phone= con.phone;
                u.Username = con.email;
                u.CommunityNickname = con.Id;
                u.Email = con.email;
                u.LanguageLocaleKey = 'en_US'; 
                u.LocaleSidKey = u.LanguageLocaleKey;
                u.EmailEncodingKey = 'UTF-8';
                u.TimeZoneSidKey = 'America/New_York';
                u.Alias = u.username.length() > 8 ? u.username.substring(0, 8) : u.username;
                u.contactId = con.Id;
                u.IsActive = true;
                
                userList.add(u);  
            }
            
            if(userList.size() > 0){
                insert userList;
            }
        }
        
        
        if(existUserList.size() > 0){
            List<User> userUpdateList = new List<User>();
            for(User eu : existUserList){
                if(eu.IsActive == false){
                    //eu.IsActive = true;
                    eu.isActiveTemp__c = 'Active';
                    userUpdateList.add(eu);
                }
            }
            if(userUpdateList.size() > 0){
                update userUpdateList;
            }
        }
        
        
        
        
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
        public List<resultWrapper> rwList;
        public Map<string,String> sMap;
        public List<String> sList;
    }
    
    //Wrapper class
    public class patientWrapper{
        public String psspSFId;
        public string patientSFId;
        public String patientId;
        public String pId;
        public String firstName;
        public String lastName;
        public String fullName;
        public string email;
        public Date dob;
        public string consentStatus;
        public string contactSFId;
        public datetime createddate;
        
        public String siteId;
        public String siteName;
        public String siteSFId;
        public String studyId;
        public String studyName;
        public String studySFId;
        public Integer noOfDocs;
        
        public String regStatus;
        public List<Patient_Attachments__c> docList; 
    }  
    
    public class docsWrapper{
        public String fileName;
        public String docType;
    }*/
}