global class Plexus_ColonoscopySigmoControllerPhase2{
   /* global String patientId{get;set;}
    global String recordId{get;set;}
    global String formMode{get;set;}
    global String psspId{get;set;}
    
    global String studySFId{get;set;}
    global String siteSFId{get;set;}
    
    public String isPatient{get;set;}
    public String isAdmin{get;set;}
    public String isStaff{get;set;}
    
    public String isViewEncryptedDataUser{get;set;}
    
    public User u;
    public Plexus_ColonoscopySigmoControllerPhase2() {
        recordId = Apexpages.currentpage().getparameters().get('Id');
        patientId = Apexpages.currentpage().getparameters().get('pId');
        formMode = apexpages.currentpage().getparameters().get('formView');     
        psspId = apexpages.currentpage().getparameters().get('pssId'); 
        
        studySFId = Apexpages.currentpage().getparameters().get('sId'); 
        u = [Select id,name,profile.Name,contactId,contact.Plexus_Site__c,contact.plexus_patient__c 
                                                                    From User where id = :userinfo.getUserId()];
        siteSFId = u.contact.plexus_site__c;
        
        isViewEncryptedDataUser = Plexus_Utility.isViewEncryptedDataAccess(); 
    }
     public pageReference Init(){
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
             
             if(patientId != null && patientId != ''){
                 List<Plexus_Study_Site_Patient__c> patientList = [select id From Plexus_Study_Site_Patient__c 
                                                                        Where patient__c = :patientId And
                                                                              site__c = :u.contact.plexus_Site__c And 
                                                                              study__c = :studySFId limit 1];
                                                                              
                 if(patientList.size() == 0){
                     PageReference p = page.Plexus_Exception;
                     return p;
                 }
                 
                 psspId  = patientList[0].Id;
             }
             else{
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
            psspId = [select id,study__c,site__c,patient__c from plexus_study_site_patient__c where Id=:psspId].Id;
        }
        
        
        return null;
    }
    
    @RemoteAction
    public static resultWrapper getInitInformation(String patientId,String recordId,String pssId) {  
        resultWrapper rw = new resultWrapper();
        Plexus_Patient__c pp;
        Plexus_Procedure__c pcs;
        List<Plexus_Scoring_System__c> pCSUCIBDMEList = new List<Plexus_Scoring_System__c>();
        List<Plexus_Scoring_System__c> pCSCDCESList = new List<Plexus_Scoring_System__c>();
        List<String> meScoreValues;
        List<String> sesScoreValues;
        
        Map<String,Plexus_Scoring_System__c> meMap = new Map<String,Plexus_Scoring_System__c>();
        Map<String,Plexus_Scoring_System__c> sesMap = new Map<String,Plexus_Scoring_System__c>();
        
        Plexus_study_site_patient__c pssp = [select Id,study__c,study__r.study_Id__c,site__c,site__r.site_Id__c,
                                                            patient__C,study_version__c From Plexus_study_site_patient__c
                                                                                             Where id = :pssId];
                                                                                             
        Plexus_diagnosis__c pd = [select id,diagnosis__c from Plexus_diagnosis__c where patient__c = :patientId order by lastmodifieddate desc limit 1];
        
        if(recordId != null && recordId != ''){
            pcs = [select id,Form_Status__c,Patient_ID__c,Form_Submitted_date__c,Date_of_Event__c,
                                Indication__c,Event_Type__c,Max_extent_of_exam__c,Diagnosis__c,
                                Max_extent_of_active_disease__c,Total_Visualized__c,Total_Overall_score__c,
                                Modified_Mayo_Endoscopy_Score__c,lastmodifiedBy.User_first_name__c,
                                lastmodifiedBy.User_last_name__c, lastmodifiedBy.Name        
                                from Plexus_Procedure__c where id = :recordId];
            
            List<Plexus_Scoring_System__c> pssList = [select id,name,Erythema__c,Friability__c,Location__c,
                                                             Mucosal_breaks__c,Overall_score__c,Vascular_pattern__c,
                                                             Visualized__c,Affected_surface__c,Size_of_ulcers__c,
                                                             Total__c,Ulcerated_surface__c,Presence_of_narrowings__c,
                                                             Diagnosis__c 
                                                             From Plexus_Scoring_System__c 
                                                             Where Form_ID__c = :recordId];
            
            for(Plexus_Scoring_System__c pss:pssList){                                                 
                if(pss.Diagnosis__c == 'Ulcerative Colitis' || pss.Diagnosis__c  == 'IBD Unspecified'){
                    pCSUCIBDMEList.add(pss);  
                    meMap.put(pss.location__c,pss);
                }
                else if(pss.Diagnosis__c == 'Crohn\'s Disease'){
                    pCSCDCESList.add(pss);
                    sesMap.put(pss.location__c,pss);
                } 
            }                                                 
                                                              
            pp = [select id,First_Name__c,Last_Name__c,Date_of_Birth__c,Email__c,Patient_ID__c,Prefix__c,Gender__c, name,
                                                 createdbyId,createdby.User_first_name__c,createdby.User_last_name__c,
                                                 createdby.Name From Plexus_Patient__c  
                                                where id = : pcs.Patient_ID__c];                               
        }
        else{
            pp = [select id,First_Name__c,Last_Name__c,Date_of_Birth__c,Email__c,Patient_ID__c,Prefix__c, Gender__c, name,
                                                        createdbyId,createdby.User_first_name__c,createdby.User_last_name__c,
                                                        createdby.Name  From Plexus_Patient__c 
                                                        where id = :patientId];
        }
        
        rw.pcs = pcs;
        rw.pp = pp;
        
        
        
         List<meWrapper> meWrapList = new List<meWrapper>();
         List<sesWrapper> sesWrapList = new List<sesWrapper>(); 
        
        if(System.label.Plexus_Mayo_Endoscopic_Location != null){
            meScoreValues = System.label.Plexus_Mayo_Endoscopic_Location.split(',');
            
            for(String str : meScoreValues){
                meWrapper me = new meWrapper();
                if(meMap.containsKey(str)){
                    me.Location = meMap.get(str).Location__c;
                    me.Erythema = meMap.get(str).Erythema__c != null ? meMap.get(str).Erythema__c : 'Select';
                    me.Vascular_pattern = meMap.get(str).Vascular_pattern__c != null ? meMap.get(str).Vascular_pattern__c : 'Select';
                    me.Friability = meMap.get(str).Friability__c != null ? meMap.get(str).Friability__c : 'Select';
                    me.Mucosal_breaks = meMap.get(str).Mucosal_breaks__c != null ? meMap.get(str).Mucosal_breaks__c : 'Select';
                    me.Visualized = meMap.get(str).Visualized__c != null ? meMap.get(str).Visualized__c : 'Select';
                    me.Overall_score = meMap.get(str).Overall_score__c != null ? meMap.get(str).Overall_score__c : 'Select';
                    me.Id = meMap.get(str).Id;
                    me.readonly = false;
                }
                else{
                    me.Location = str;
                    me.Erythema = 'Select';
                    me.Vascular_pattern = 'Select';
                    me.Friability = 'Select';
                    me.Mucosal_breaks = 'Select';
                    me.Visualized = 'Select';
                    me.Overall_score = 'Select';
                }
                meWrapList.add(me);
            }
        }
        
        if(System.label.Plexus_SES_CD_Feature != null){
            sesScoreValues = System.label.Plexus_SES_CD_Feature.split(',');
            
            for(String str : sesScoreValues){
                sesWrapper ses = new sesWrapper();
                if(sesMap.containsKey(str)){
                    ses.location = sesMap.get(str).location__c;
                    ses.sizeOfUlcer = sesMap.get(str).Size_of_ulcers__c != null ? sesMap.get(str).Size_of_ulcers__c : 'Select';
                    ses.ulcerSurface = sesMap.get(str).Ulcerated_surface__c != null ? sesMap.get(str).Ulcerated_surface__c : 'Select';
                    ses.affectSurface = sesMap.get(str).Affected_surface__c != null ? sesMap.get(str).Affected_surface__c: 'Select';
                    ses.presNarrow = sesMap.get(str).Presence_of_narrowings__c != null ? sesMap.get(str).Presence_of_narrowings__c : 'Select';
                    ses.total = sesMap.get(str).Total__c;
                    ses.Id = sesMap.get(str).Id;
                    ses.sesreadonly = false;
                }
                else{
                    ses.location = str;
                    ses.sizeOfUlcer = 'Select';
                    ses.ulcerSurface = 'Select';
                    ses.affectSurface = 'Select';
                    ses.presNarrow = 'Select';
                }
                sesWrapList.add(ses);
            }  
        }
        
        rw.pCSUCIBDMEList = meWrapList;
        rw.pCSCDCESList = sesWrapList;

        rw.diagnosisValues = getDiagnosis();
        rw.evntTypeValues = getEventTypes();
        rw.indicationValues = getIndications();
        rw.meScoreValues = meScoreValues;
        rw.sesScoreValues = sesScoreValues;
        rw.sesScoringValues = getSESScoringValues();
        rw.meScoringValues = getMEScoringValues();
        rw.studyId = pssp.study__r.study_ID__c;
        rw.siteId = pssp.site__r.site_Id__c;
        rw.diagnosis = pd.diagnosis__c;
        
        return rw;
    }
    
   
    @RemoteAction
    Public static resultWrapper insertForm(userFormWrapper pcsForm,List<meWrapper> meList,List<sesWrapper> sesList,string patientRecId,String recordId,String pssId){
        
        
        Plexus_Patient__c pp = [select id,First_Name__c,Last_Name__c,Date_of_Birth__c,Email__c,Patient_ID__c,Prefix__c 
                                                                From Plexus_Patient__c where id = :patientRecId];
        
        Plexus_study_site_patient__c pssp = [select Id,study__c,site__c,patient__C,study_version__c from Plexus_study_site_patient__c
                                                                                   Where id = :pssId];
        
        Plexus_Procedure__c pcs = new Plexus_Procedure__c();
        pcs.Patient_ID__c = patientRecId;
        pcs.study_Id__c = pssp.study__c;
        pcs.site_Id__c = pssp.site__c;
        pcs.study_version__c = pssp.study_version__c;
        pcs.Study_Site_Patient__c = pssp.Id;
        pcs.Form_Status__c = pcsForm.formStatus;
        pcs.Diagnosis__c = pcsForm.condition;
        pcs.Event_Type__c = pcsForm.evntType;
        pcs.Indication__c = pcsForm.indication != 'Select' ? pcsForm.indication : null;
        pcs.Category__c = 'Colonoscopy-Sigmoidoscopy';
        pcs.Modified_Mayo_Endoscopy_Score__c = pcsForm.mmeScore;
        if(pcsForm.evntDate != null && pcsForm.evntDate != ''){
            pcs.Date_of_Event__c =  setStringToDateFormat(pcsForm.evntDate);
        }
        else{
            pcs.Date_of_Event__c = null;
        }
          
        if(pcsForm.maxExOfExam != null){  
            pcs.Max_extent_of_exam__c = pcsForm.maxExOfExam != null && pcsForm.maxExOfExam!= '' ? integer.valueof(pcsForm.maxExOfExam) : null;
        }
        else{
            pcs.Max_extent_of_exam__c = null;
        }
        if(pcsForm.maxExOfActDis != null){
            pcs.Max_extent_of_active_disease__c = pcsForm.maxExOfActDis != null && pcsForm.maxExOfActDis != '' ? integer.valueof(pcsForm.maxExOfActDis) : null;
        }
        else{
            pcs.Max_extent_of_active_disease__c = null;
        }

        pcs.Total_Visualized__c  = pcsForm.TotalVisualized;
        pcs.Total_Overall_score__c = pcsForm.TotalOverallScore;
        
        if(pcsForm.id != null && pcsForm.id != ''){
            pcs.Id = pcsForm.id;
        }
        if(pcsForm.formStatus == 'Submitted'){
            pcs.Form_Submitted_date__c = date.today();
        }
        
        upsert pcs;
        
        
        List<Plexus_Scoring_System__c> pCSUCIBDMEList = new List<Plexus_Scoring_System__c>();
        if(pcs.Diagnosis__c == 'Ulcerative Colitis' || pcs.Diagnosis__c  == 'IBD Unspecified'){
            Map<String,string> meScoringMap= new Map<String,string>();
            for(Plexus_ME_Scoring_system__c me:Plexus_ME_Scoring_system__c.getAll().values()){
                meScoringMap.put(me.name,me.value__c);
            }
        
            for(meWrapper me:meList){
                if(pcs.Diagnosis__c == 'Ulcerative Colitis' || pcs.Diagnosis__c == 'IBD Unspecified'){
                    Plexus_Scoring_System__c pcsME = new Plexus_Scoring_System__c();
                    pcsME.Location__c = me.Location;
                    pcsME.Erythema__c = me.Erythema != 'Select' ? me.Erythema : null;
                    pcsME.Vascular_pattern__c = me.Vascular_pattern != 'Select' ? me.Vascular_pattern : null;
                    pcsME.Friability__c = me.Friability != 'Select' ? me.Friability : null;
                    pcsME.Mucosal_breaks__c = me.Mucosal_breaks != 'Select' ? me.Mucosal_breaks : null;
                    pcsME.Visualized__c = me.Visualized != 'Select' ? me.Visualized : null;
                    pcsME.Overall_score__c = me.Overall_score != 'Select' ? me.Overall_score : null;
                    pcsME.Diagnosis__c = pcs.Diagnosis__c;
                    pcsME.Form_id__c = pcs.id;
                    pcsME.Form_Status__c = pcs.Form_Status__c;
                
                    if(meScoringMap.containsKey(me.Overall_score)){
                       pcsME.Code_Description_for_OS__c = meScoringMap.get(me.Overall_score);
                    }
                   
                    if(me.id != null && me.id != ''){
                       pcsME.Id = me.id;
                    }
                    
                    pCSUCIBDMEList.add(pcsME); 
                }   
            }
            
            if(pCSUCIBDMEList.size() > 0){
                upsert pCSUCIBDMEList;
            }
        }

        List<Plexus_Scoring_System__c> pCSCDCESList = new List<Plexus_Scoring_System__c>();
        if(pcs.Diagnosis__c == 'Crohn\'s Disease'){
            for(sesWrapper ses:sesList){
                Plexus_Scoring_System__c pcsSES = new Plexus_Scoring_System__c();
                pcsSES.location__c = ses.location;
                pcsSES.Size_of_ulcers__c = ses.sizeOfUlcer != 'Select' ? ses.sizeOfUlcer : null;
                pcsSES.Ulcerated_surface__c = ses.ulcerSurface != 'Select' ? ses.ulcerSurface : null; 
                pcsSES.Affected_surface__c = ses.affectSurface != 'Select' ? ses.affectSurface : null;
                pcsSES.Presence_of_narrowings__c = ses.presNarrow != 'Select' ? ses.presNarrow : null;
                pcsSES.Total__c = ses.total;
                pcsSES.Diagnosis__c = pcs.Diagnosis__c;
                pcsSES.Form_ID__c = pcs.id;
                pcsSES.Form_Status__c = pcs.form_status__c; 
                
                if(ses.id != null && ses.id != ''){
                    pcsSES.Id = ses.id;
                }
                
                pCSCDCESList.add(pcsSES);
            }
            
            if(pCSCDCESList.size() > 0){
                upsert pCSCDCESList;
            }
        }

        resultWrapper rw = new resultWrapper();
        rw.pcs = pcs;
        rw.pp = pp;
        
        return rw;
    }
    
    @RemoteAction
    Public static void deleteRecord(String recordId){
        Plexus_Procedure__c pp = [select id from Plexus_Procedure__c where id = :recordId];
        
        pp.Form_Status__c = 'Deleted';
        
        update pp;
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
    

    public static List<String> getDiagnosis(){
        List<String> diagList = new List<string>();
        Schema.DescribeFieldResult fieldResult = Plexus_Procedure__c.Diagnosis__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            diagList.add(f.getValue());
        }       
        return diagList ;
    }
    
    public static List<String> getEventTypes(){
        List<String> diagList = new List<string>();
        
        Schema.DescribeFieldResult fieldResult = Plexus_Procedure__c.Event_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        diagList.add('Select');
        for(Schema.PicklistEntry f : ple){
            diagList.add(f.getValue());
        }       
        return diagList ;
    }
    
    public static List<String> getIndications(){
        List<String> diagList = new List<string>();
        
        Schema.DescribeFieldResult fieldResult = Plexus_Procedure__c.Indication__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        diagList.add('Select');
        for(Schema.PicklistEntry f : ple){
            diagList.add(f.getValue());
        }       
        return diagList ;
    }
    
    public static List<Plexus_ME_Scoring_system__c> getMEScoringValues(){
        List<Plexus_ME_Scoring_system__c> meScoringList = new List<Plexus_ME_Scoring_system__c>();
        for(Plexus_ME_Scoring_system__c me:Plexus_ME_Scoring_system__c.getAll().values()){
            meScoringList.add(me);
        }
        meScoringList.sort();
        return meScoringList;
    }
    
    public static List<Plexus_SES_CD_Scoring_System__c> getSESScoringValues(){
        List<Plexus_SES_CD_Scoring_System__c> sesScoringList = new List<Plexus_SES_CD_Scoring_System__c>();
        for(Plexus_SES_CD_Scoring_System__c ses:Plexus_SES_CD_Scoring_System__c.getAll().values()){
            sesScoringList.add(ses);
        }
        sesScoringList.sort();
        return sesScoringList;
    }

     //Wrapper class
    public class resultWrapper{
        public Plexus_Patient__c pp;
        public Plexus_Procedure__c pcs;
        public List<meWrapper> pCSUCIBDMEList;
        public List<sesWrapper> pCSCDCESList;
        public List<String> diagnosisValues;
        public List<String> meScoreValues;
        public List<String> sesScoreValues; 
        public List<String> evntTypeValues;
        public List<String> indicationValues;
        public List<Plexus_SES_CD_Scoring_System__c> sesScoringValues;
        public List<Plexus_ME_Scoring_system__c> meScoringValues;
        public String siteId;
        public String studyId;
        public String diagnosis;
    }
    
    public class meWrapper{
        @TestVisible
        String id,Location,Erythema,Vascular_pattern,Friability,Mucosal_breaks,Overall_score,Visualized;
        boolean readonly;
    }
    
    public class sesWrapper{
        @TEstVisible
        //String id,Feature,Ileum,Right_colon,TV_colon,Left_colon,Rectum;
        String Id,location,sizeOfUlcer,ulcerSurface,affectSurface,presNarrow,total;
        boolean sesreadonly;
    }
    
     public class userFormWrapper{  
        @TestVisible
        String id,pFirstname,physicianId,pLastname,siteId,studyId,patientId,condition,formStatus,physician,pDOB,pid,name,gender;
        @TestVisible
        String dateFormSubmt,evntDate,evntType,indication,maxExOfExam,maxExOfActDis;
        @TestVisible
        String TotalVisualized,TotalOverallScore,mmeScore;
        @TestVisible
        STring TotCDCol1,TotCDCol2,TotCDCol3,TotCDCol4,TotCDCol5;
        @TestVisible
        String submittedBy;
    }*/
}