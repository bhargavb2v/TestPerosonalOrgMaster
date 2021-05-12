/**********************************************************************************************************
Author                              Date                  Version                Reason
Bhargavaramu Pentakota         12th May 2016               1.0                   Created 


Description: 
1.It is a controller class of Medication Accuracy form to capture patient medication information
2. This class has been implemented to handle ADD, Edit, View and Delete operations 
***********************************************************************************************************/
global class MedicationAccuracyCtrlPhase2{
 /*   
    //Variable Declaration
    global String patientId{get;set;}
    global String recordId{get;set;}
    global String formMode{get;set;}
    global String isNew{get;set;}
    global String psspId{get;set;}
    
    global String studySFId{get;set;}
    global String siteSFId{get;set;}
    
    public String isPatient{get;set;}
    public String isAdmin{get;set;}
    public String isStaff{get;set;}
    
    public User u;
    
    //Constructor
    public Plexus_MedicationAccuracyCtrlPhase2() {
        //Pulling parameters from URL
        recordId = Apexpages.currentpage().getparameters().get('Id');
        patientId = Apexpages.currentpage().getparameters().get('pId');
        formMode = apexpages.currentpage().getparameters().get('formView');   
        isNew = apexpages.currentpage().getparameters().get('IsNew');
        psspId = apexpages.currentpage().getparameters().get('pssId');  
        
         studySFId = Apexpages.currentpage().getparameters().get('sId'); 
        u = [Select id,name,profile.Name,contactId,contact.Plexus_Site__c,contact.plexus_patient__c 
                                                                    From User where id = :userinfo.getUserId()];
        siteSFId = u.contact.plexus_site__c; 
    }
    
     //Implemented the logic to check the accessibility on this page?
    public pageReference Init(){
        //Fetching org default values from custom settings
        Plexus_Settings__c setting = Plexus_Settings__c.getOrgDefaults();

        if(u.profile.Name == setting.Site_Staff_Profile_Name__c){// checking access for Site staff profile users
            
            isStaff = 'Yes';
             List<Plexus_Study_Site_CSC__c> siteStaffList = [select id From Plexus_Study_Site_CSC__c 
                                                                    Where csc__c = :u.contactId And
                                                                          site__c = :u.contact.plexus_Site__c And 
                                                                          study__c = :studySFId limit 1];
              //If there is no sitestaff associated with site and study, it will redirect to error page.                                                        
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
        else if(u.profile.Name == setting.Patient_Profile_Name__c){ // checking access for Patient profile users
            isPatient = 'Yes';
            List<Plexus_Study_Site_Patient__c> patientList = [select id From Plexus_Study_Site_patient__c 
                                                                    Where patient__c = :u.contact.plexus_patient__c And
                                                                          site__c = :u.contact.plexus_Site__c And 
                                                                          study__c = :studySFId And 
                                                                           Consent_Status__c = 'Consented' limit 1];
                                                                    
             if(patientList.size() == 0 || u.contact.plexus_patient__c != patientId){
                 PageReference p = page.Plexus_Exception;
                 return p;
             }
             psspId  = patientList[0].Id;
        }
        else{  // checking access for other users
            isAdmin = 'Yes';
            psspId = [select id,study__c,site__c,patient__c from plexus_study_site_patient__c where Id=:psspId].Id;
        }
        
        
        return null;
    }
    
    //It is javascipt remoting method and calling from Visualforce page on pageloading to get the required data to the page
   @RemoteAction
    public static resultWrapper getInitInformation(String patientId,String recordId,string isNew,String pssId){
        //Declaring local varibles
        resultWrapper rw = new resultWrapper();
        Plexus_Patient__c pp;
        Plexus_Medication__c pma;
        List<questWrapper> qwList;
        Map<String,questWrapper> qwMap;
        List<Plexus_Questionnaire__c> pMediQuestList;
        
        List<Plexus_Medication__c> pMaInfoTreatmentList = new List<Plexus_Medication__c>();
        List<Plexus_Medication__c> pMaInfoAntiBioticList = new List<Plexus_Medication__c>();
        List<Plexus_Medication__c> pMaInfoProbioticList = new List<Plexus_Medication__c>();
        
        Plexus_study_site_patient__c pssp = [select Id,study__c,study__r.study_Id__c,site__c,site__r.site_Id__c,
                                                            patient__C,study_version__c From Plexus_study_site_patient__c
                                                                                             Where id = :pssId];
        //It will execute when page is in edit mode or view mode
        if(recordId != null && recordId != '' && isNew != 'Yes'){
              //It loads the data on view and edit page loading
            List<Plexus_Medication__c> pmaList = [select id,Patient_ID__c,Form_Submitted_date__c,Form_Status__c,
                                                                 Medication_Name__c,Medication_Other__c,Dosage__c,Frequency__c,
                                                                 Start_Date__c,End_Date__c,Is_dose_Unknown__c,
                                                                 Treatment_Category__c,Parent_Id__c,Route_of_Admin__c,
                                                                 Frequency_in_days__c,Unit__c,Dose_Status__c,
                                                                 Frequency_Status__c,Current_Medication__c,
                                                                 Start_Date_Status__c,Reason_Stopped__c,
                                                                 Reason_Stopped_comments__c,Start_Date_Estimated__c,
                                                                 Stop_Date_Estimated__c,lastmodifiedBy.User_first_name__c,
                                                                 lastmodifiedBy.User_last_name__c,lastmodifiedBy.Name            
                                                             From Plexus_Medication__c
                                                             Where id = :recordId OR parent_Id__c = :recordId];
            
            //Preparing data to send back to page                                               
            For(Plexus_Medication__c p:pmaList){
                if(p.id == recordId){
                    pma = p;    
                }
                if(p.Treatment_Category__c == 'Medication'){
                    pMaInfoTreatmentList.add(p);
                }
                else if(p.Treatment_Category__c == 'Antibiotic'){
                    pMaInfoAntiBioticList.add(p);
                }
                else if(p.Treatment_Category__c == 'Probiotic'){
                    pMaInfoProbioticList.add(p);
                }
            }
            
            //Fetching all question and responses from questionnaire object
            pMediQuestList = [select id,name,question__c,Response__c from Plexus_Questionnaire__c 
                                                                            where Medication_Accuracy_Id__c =:recordId];
                                                                            
            qwMap = new Map<String,questWrapper>();
            for(Plexus_Questionnaire__c pMedi:pMediQuestList){ 
                questWrapper qW = new questWrapper();
                qw.question = pMedi.Question__c;
                qw.resp = pMedi.Response__c;
                qw.Id = pMedi.Id;
                qwMap.put(pMedi.Question__c,qW);
            }
            
            //Fetching patient information
            pp = [select id,First_Name__c,Last_Name__c,Gender__c, name,Date_of_Birth__c,Email__c,Patient_ID__c,Prefix__c,
                                                    createdby.User_first_name__c,createdby.User_last_name__c,createdbyId,
                                                    createdby.Name  
                                                    From Plexus_Patient__c 
                                                    Where id = : pma.Patient_Id__c];  
                                        
            rw.pma = pma;
            rw.quesWrapperMap = qwMap;
            rw.treatmentList = getconvertedMedicationWrapper(pMaInfoTreatmentList,null);
            rw.antibioticList = getconvertedMedicationWrapper(pMaInfoAntiBioticList,null);
            rw.probioticList = getconvertedProbioticWrapper(pMaInfoProbioticList,null);
        }
        else{ 
            //Fetching last submitted record
            List<Plexus_Medication__c> dmList = [Select id,Patient_ID__c,Form_Submitted_date__c,Form_Status__c 
                                                           From Plexus_Medication__c
                                                           Where Patient_Id__c = :patientId And 
                                                                 study_Site_Patient__c = :pssId And
                                                                 Form_Status__c = 'Submitted' And 
                                                                 Recordtype.Name = 'Parent' 
                                                           Order by lastmodifieddate desc limit 1];
            
            //Fetching last submitted record to display ongoing medication on the page                                               
            if(dmList.size() > 0){
                List<Plexus_Medication__c> pmaList = [select id,Patient_ID__c,Form_Submitted_date__c,
                                                                     Form_Status__c,Medication_Other__c,
                                                                     Medication_Name__c,Dosage__c,Frequency__c,
                                                                     Start_Date__c,End_Date__c,Is_dose_Unknown__c,
                                                                     Treatment_Category__c,Parent_Id__c,Route_of_Admin__c,
                                                                     Frequency_in_days__c,Unit__c,Dose_Status__c,
                                                                     Frequency_Status__c,Current_Medication__c,
                                                                     Start_Date_Status__c,Reason_Stopped__c,
                                                                     Reason_Stopped_comments__c,Start_Date_Estimated__c,
                                                                     Stop_Date_Estimated__c,lastmodifiedBy.User_first_name__c,
                                                                     lastmodifiedBy.User_last_name__c,
                                                                     lastmodifiedBy.Name            
                                                                 From Plexus_Medication__c
                                                                 Where Parent_Id__c = :dmList[0].id And 
                                                                       Current_Medication__c != 'No'];
                          
                for(Plexus_Medication__c p : pmaList){
                    if(p.Treatment_Category__c == 'Medication'){
                        pMaInfoTreatmentList.add(p);
                    }
                    else if(p.Treatment_Category__c == 'Antibiotic'){
                        pMaInfoAntiBioticList.add(p);
                    }
                    else if(p.Treatment_Category__c == 'Probiotic'){
                        pMaInfoProBioticList.add(p);
                    }
                }
                
                //Lat submitted questionnaires
                pMediQuestList = [select id,name,question__c,Response__c from Plexus_Questionnaire__c 
                                                                        where Medication_Accuracy_Id__c =:dmList[0].id];
                                                                        
                qwMap = new Map<String,questWrapper>();
                for(Plexus_Questionnaire__c pMedi:pMediQuestList){ 
                    questWrapper qW = new questWrapper();
                    qw.question = pMedi.Question__c;
                    qw.resp = pMedi.Response__c;

                    qwMap.put(pMedi.Question__c,qW);
                }
                
                rw.pma = dmList[0];
                rw.quesWrapperMap = qwMap;
                rw.treatmentList = getconvertedMedicationWrapper(pMaInfoTreatmentList,dmList[0].id);
                rw.antibioticList = getconvertedMedicationWrapper(pMaInfoAntiBioticList,dmList[0].id);
                rw.probioticList = getconvertedProbioticWrapper(pMaInfoProBioticList,dmList[0].id);
            }
            pp = [select id,First_Name__c,Last_Name__c,Date_of_Birth__c,Gender__c, name,
                    Email__c,Patient_ID__c,Prefix__c,createdby.User_first_name__c,createdby.User_last_name__c,
                                                    createdbyId,createdby.Name   
                                                    From Plexus_Patient__c 
                                                    Where id = :patientId];                                  
        }
        
        List<String> questList = new List<String>();
        List<ECRF_Maintainance__c> ecrfList = [select id,type__c,value__c
                                                    from ECRF_Maintainance__c
                                                    where form_type__c = 'Medication Accuracy' 
                                                    and type__c = 'Question' order by priority__C];
                                                    
        for(ECRF_Maintainance__c ecrf:ecrfList){
            questList.add(ecrf.value__c);
        }
        
        rw.questList = questList;
        rw.pp = pp; 
        rw.mediList = getMedications().get('Medication');
        rw.antiList = getMedications().get('Antibiotic');
        rw.proList = getMedications().get('Probiotic');
        rw.routeAdminValList = getRouteAdminValues();
        rw.RreasonStoppedValues = getRreasonStoppedValues();
        rw.studyId = pssp.study__r.study_ID__c;
        rw.siteId = pssp.site__r.site_Id__c;
        
        return rw;
    }
    
    //It is javascipt remoting method and calling from Visualforce page to insert/update the data into the database
    @RemoteAction
    Public static resultWrapper insertForm(userFormWrapper pmaForm,String patientId,
                                                    list<medicationWrapper> treatmentList,list<medicationWrapper> antibioticList,
                                                    List<medicationWrapper> probioticList,List<questWrapper> objList,String pssId,
                                                    List<String> delTrtList,List<String> delAntiList, List<String> delProList){
                                                        
          // DML operation from vf javascript method 
        String recordTypeId = Schema.Sobjecttype.Plexus_Medication__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        List<Plexus_Medication__c> pMedList = [select id from Plexus_Medication__c where recordTypeId = :recordTypeId 
                                                                                      And Form_Status__c = 'Saved' 
                                                                                      And patient_Id__c = :patientId 
                                                                                      And Study_Site_Patient__c = :pssId 
                                                                                      And Id != :pmaForm.Id];
        //Only one saved should be there at instance. if someone tries to submit another saved form, system will throw error
        if(pMedList.size() > 0){
            throw new applicationException('Please edit the saved or existing form to submit.');
        }
        else{
            Plexus_study_site_patient__c pssp = [select Id,study__c,site__c,patient__C,study_version__c from Plexus_study_site_patient__c
                                                                                   Where id = :pssId];
                                                                                   
            //Assigned page data to the sobject to insert/update
            Plexus_Medication__c pma = new Plexus_Medication__c();
            pma.Patient_Id__c = patientId;
            pma.study_Id__c = pssp.study__c;
            pma.site_Id__c = pssp.site__c;
            pma.study_version__c = pssp.study_version__c;
            pma.Study_Site_Patient__c = pssp.Id;
            pma.Form_Status__c = pmaForm.formStatus;
            pma.RecordtypeID = recordTypeId;
            
            if(pmaForm.Id != null && pmaForm.Id != ''){
                pma.Id = pmaForm.Id;
            }
            if(pmaForm.formStatus == 'Submitted'){
                pma.Form_Submitted_date__c = date.today();
            }
            
            upsert pma;
            
            //loading treatment medications
            List<Plexus_Medication__c> pmaiTreatmentList = assignTreatment(pma.Id,patientId,treatmentList);
            if(pmaiTreatmentList.size() > 0){
                upsert pmaiTreatmentList;
            }
            
            //Loading antibiotic medication
            List<Plexus_Medication__c> pmaiAntibioticList = assignAntibiotic(pma.Id,patientId,antibioticList); 
            if(pmaiAntibioticList.size() > 0){
                upsert pmaiAntibioticList;
            }
            
            //Loading probiotic medications
            List<Plexus_Medication__c> pmaiProbioticList = assignProbiotic(pma.Id,patientId,probioticList);
            if(pmaiProbioticList.size() > 0){
                upsert pmaiProbioticList ;
            }
            
            //Loading Questionnaire
            List<Plexus_Questionnaire__c> sMediQuestList = new List<Plexus_Questionnaire__c>();
            for(questWrapper obj:objList){
                if(obj.resp != null){
                    Plexus_Questionnaire__c mediQuest = new Plexus_Questionnaire__c();
                    mediQuest.Question__c = obj.question;
                    mediQuest.Response__c = obj.resp;
                    mediQuest.Medication_Accuracy_Id__c = pma.Id;
                    mediQuest.Question_Category__c = 'Medication Accuracy';
                    if(obj.Id != null && obj.Id != ''){
                        mediQuest.Id = obj.Id;
                    }
                    
                    sMediQuestList.add(mediQuest);
                }
            }
            
            Map<String,questWrapper> qwMap;
            if(sMediQuestList.size() > 0){
                upsert sMediQuestList ;
                qwMap = new Map<String,questWrapper>();
                for(Plexus_Questionnaire__c pInfo:sMediQuestList){ 
                    questWrapper qW = new questWrapper();
                    qw.question = pInfo.Question__c;
                    qw.resp = pInfo.Response__c;
                    qw.Id = pInfo.Id;
                    qwMap.put(PInfo.Question__c,qW);
                }
            }
            
            List<Plexus_Medication__c> pDelList = new List<Plexus_Medication__c>();
            
            //added null pointer exception check
            if(delTrtList!=null)
            for(String delId : delTrtList){
                if(delId != null && delId != ''){
                    Plexus_Medication__c pd = new Plexus_Medication__c(id=delId);
                    pDelList.add(pd);
                }
            }
            
            //added null pointer exception check
            if(delAntiList!=null)
            for(String delId : delAntiList){
                if(delId != null && delId != ''){
                    Plexus_Medication__c pd = new Plexus_Medication__c(id=delId);
                    pDelList.add(pd);
                }
            }
            
            //added null pointer exception check
            if(delProList!=null)
            for(String delId : delProList){
                if(delId != null && delId != ''){
                    Plexus_Medication__c pd = new Plexus_Medication__c(id=delId);
                    pDelList.add(pd);
                }
            }
            
            if(pDelList.size() > 0){
                delete pDelList;
            }
       
            resultWrapper rw = new resultWrapper();
            rw.pma = pma;
            rw.quesWrapperMap = qwMap;
            rw.treatmentList = getconvertedMedicationWrapper(pmaiTreatmentList,null);
            rw.antibioticList = getconvertedMedicationWrapper(pmaiAntibioticList,null);
            rw.probioticList = getconvertedProbioticWrapper(pmaiProbioticList,null);
            
            return rw;
        }
    }
    
    //Coverting Treatments from wrapper class info to sObject to load the data
    public static List<Plexus_Medication__c> assignTreatment(String parentId,String patientId,list<medicationWrapper> treatmentList){
        List<Plexus_Medication__c> pmaiTreatmentList = new List<Plexus_Medication__c>();
        for(medicationWrapper treatmnt : treatmentList){
            Plexus_Medication__c pmai = new Plexus_Medication__c();
            
            pmai.RecordtypeID = Schema.Sobjecttype.Plexus_Medication__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
            pmai.Medication_Name__c = treatmnt.Medication;
            pmai.Medication_Other__c = treatmnt.MedicationOther;
            pmai.Dosage__c = treatmnt.NewDose != null && treatmnt.NewDose != '' ? decimal.valueof(treatmnt.NewDose) : null;
            pmai.Unit__c = treatmnt.NewUnit;
            pmai.Dose_Status__c = treatmnt.DoseStatus;
            pmai.Frequency_Status__c = treatmnt.FrequencyStatus;
            pmai.Start_date_status__c = treatmnt.MedicationDateStatus;
            pmai.Frequency__c = treatmnt.NewFrequency;
            pmai.Frequency_in_days__c = treatmnt.NewFrequent != null ? integer.valueof(treatmnt.NewFrequent) : null;
            pmai.Start_Date__c = treatmnt.NewStartDate != null ? setStringToDateFormat(treatmnt.NewStartDate) : null;
            pmai.End_Date__c = treatmnt.StopDate != null && treatmnt.StopDate != '' ? setStringToDateFormat(treatmnt.StopDate) : null;
            pmai.Current_Medication__c = treatmnt.ongoing ? 'Yes' : 'No';
            pmai.Treatment_Category__c = 'Medication';
            pmai.Stop_Date_Estimated__c = treatmnt.StopDateEstimated ? 'Yes' : 'No';
            pmai.Start_Date_Estimated__c = treatmnt.StartDateEstimated ? 'Yes' : 'No';
            pmai.Reason_Stopped__c = treatmnt.reasonStopped != 'Select' ? treatmnt.reasonStopped : null;
            pmai.Reason_Stopped_Comments__c = treatmnt.rsComments;
    
            pmai.Parent_Id__c = parentId;
            pmai.Patient_Id__c = patientId;
            
            if(treatmnt.Id != null && treatmnt.Id != ''){
                pmai.Id = treatmnt.Id;
            }
            pmaiTreatmentList.add(pmai);
        }
        
        return pmaiTreatmentList;
    }
    
    //Coverting Antibiotic from wrapper class info to sObject to load the data
    public static List<Plexus_Medication__c> assignAntibiotic(String parentId,String patientId,list<medicationWrapper> antibioticList){
        List<Plexus_Medication__c> pmaiAntibioticList = new List<Plexus_Medication__c>();
        for(medicationWrapper antibiotic : antibioticList){
            Plexus_Medication__c pmai = new Plexus_Medication__c();
            
            pmai.RecordtypeID = Schema.Sobjecttype.Plexus_Medication__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
            pmai.Medication_Name__c = antibiotic.Medication;
            pmai.Medication_Other__c = antibiotic.MedicationOther;
            pmai.Dosage__c = antibiotic.NewDose != null && antibiotic.NewDose != '' ? decimal.valueof(antibiotic.NewDose):null;
            pmai.Unit__c = antibiotic.NewUnit;
            pmai.Is_dose_Unknown__c = antibiotic.doseUnknown?'Yes':'No';
            pmai.Frequency__c = antibiotic.NewFrequency;
            pmai.Frequency_in_days__c = antibiotic.NewFrequent != null ? integer.valueof(antibiotic.NewFrequent) : null;
            pmai.Start_Date__c = antibiotic.NewStartDate != null ? setStringToDateFormat(antibiotic.NewStartDate) : null;
            pmai.End_Date__c = antibiotic.StopDate != null && antibiotic.StopDate != '' ? setStringToDateFormat(antibiotic.StopDate) : null;
            pmai.Treatment_Category__c = 'Antibiotic';
            pmai.Route_of_Admin__c = antibiotic.routeOfAdmin;
            pmai.Current_Medication__c = antibiotic.ongoing ? 'Yes' : 'No';
            pmai.Parent_Id__c = parentId;
            pmai.Stop_Date_Estimated__c = antibiotic.StopDateEstimated ? 'Yes' : 'No';
            pmai.Start_Date_Estimated__c = antibiotic.StartDateEstimated ? 'Yes' : 'No';
            pmai.Reason_Stopped__c = antibiotic.reasonStopped != 'Select' ? antibiotic.reasonStopped : null;
            pmai.Reason_Stopped_Comments__c = antibiotic.rsComments;

    
            pmai.Patient_Id__c = patientId;       
            pmai.Current_Medication__c = antibiotic.ongoing ?'Yes':'No'; 
            
            if(antibiotic.Id != null && antibiotic.Id != ''){
                pmai.Id = antibiotic.Id;
            }
            
            pmaiAntibioticList.add(pmai);
        }
        
        return pmaiAntibioticList;
    }
    
    //Coverting Probiotics from wrapper class info to sObject to load the data
    public static List<Plexus_Medication__c> assignProbiotic(String parentId,String patientId,list<medicationWrapper> probioticList){
        List<Plexus_Medication__c> pmaiProbioticList = new List<Plexus_Medication__c>();
        for(medicationWrapper pro : probioticList){
            Plexus_Medication__c pmai = new Plexus_Medication__c();
            pmai.RecordtypeID = Schema.Sobjecttype.Plexus_Medication__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
            pmai.Parent_Id__c = parentId;
            pmai.Patient_Id__c = patientId; 
            pmai.Treatment_Category__c = 'Probiotic';
            pmai.Medication_Name__c = pro.Medication;
            pmai.Medication_Other__c = pro.MedicationOther;
            pmai.Current_Medication__c = pro.ongoing ?'Yes':'No'; 
            
            if(pro.Id != null && pro.Id != ''){
                pmai.Id = pro.Id;
            }
            
            pmaiProbioticList.add(pmai);
        }
        return pmaiProbioticList;
    }
    
   //Function to convert date of String data type to Date data type format
    public static Date setStringToDateFormat(String myDate) {
       String[] myDateOnly = myDate.split(' ');
       String[] strDate = myDateOnly[0].split('/');
       Integer myIntDate = integer.valueOf(strDate[1]);
       Integer myIntMonth = integer.valueOf(strDate[0]);
       Integer myIntYear = integer.valueOf(strDate[2]);
       Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
       return d;
    }
    
    //Function to convert date to String format
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
    
    //Coverting Probiotics from sObject to wrapper class to display on page
    public static List<medicationWrapper> getconvertedProbioticWrapper(List<Plexus_Medication__c> pmaInfoList,String lastSubRecId){
        List<medicationWrapper> mwList = new List<medicationWrapper>();

        for(Plexus_Medication__c pmaInfo:pmaInfoList){
            medicationWrapper mw = new medicationWrapper();
            mw.Medication = pmaInfo.Medication_Name__c;
            mw.MedicationOther = pmaInfo.Medication_Other__c;
            mw.ongoing = pmaInfo.Current_Medication__c == 'Yes' ? true : false;
            
            if(lastSubRecId == null){
                mw.Id = pmaInfo.Id;
            }
            mwList.add(mw);
        }
        
        return mwList;
    }
    
    //Coverting Treatments and antibiotics from sObject to wrapper class to display on page
    public static List<medicationWrapper> getconvertedMedicationWrapper(List<Plexus_Medication__c> pmaInfoList,String lastSubRecId){
        List<medicationWrapper> mwList = new List<medicationWrapper>();

        for(Plexus_Medication__c pmaInfo:pmaInfoList){
            medicationWrapper mw = new medicationWrapper();
            mw.Medication = pmaInfo.Medication_Name__c;
            mw.MedicationOther = pmaInfo.Medication_Other__c;
            mw.NewDose = pmaInfo.Dosage__c != null? getDosageFormat(pmaInfo.Dosage__c) : null;
            mw.NewUnit = pmaInfo.unit__c;
            mw.NewFrequency = pmaInfo.Frequency__c;
            mw.NewFrequent = pmaInfo.Frequency_in_days__c != null ? string.valueof(pmaInfo.Frequency_in_days__c) : null;
            mw.NewStartDate =  pmaInfo.Start_Date__c != null ? setDateToStringformat(pmaInfo.Start_Date__c) : null;
            mw.StopDate = pmaInfo.End_Date__c != null ? setDateToStringformat(pmaInfo.End_Date__c) : null;
            mw.routeOfAdmin = pmaInfo.Route_of_Admin__c; 
            mw.doseUnknown = pmaInfo.Is_dose_Unknown__c == 'Yes' ? true : false;
            mw.DoseStatus = pmaInfo.Dose_Status__c;
            mw.FrequencyStatus = pmaInfo.frequency_Status__c;
            mw.MedicationDateStatus = pmaInfo.Start_Date_Status__c;
            mw.ongoing = pmaInfo.Current_Medication__c == 'Yes' ? true : false;
            mw.StopDateEstimated = pmaInfo.Stop_Date_Estimated__c == 'Yes' ? true : false;
            mw.StartDateEstimated = pmaInfo.Start_Date_Estimated__c == 'Yes' ? true : false;
            mw.reasonStopped = pmaInfo.Reason_Stopped__c;
            mw.rsComments = pmaInfo.Reason_Stopped_Comments__c;

            if(lastSubRecId == null){
                mw.Id = pmaInfo.Id;
            }
            mwList.add(mw);
        }
        
        return mwList;
    }
    
    //Function to delete the record
    @RemoteAction
    Public static void deleteRecord(String recordId){
        Plexus_Medication__c pp = [select id from Plexus_Medication__c where id = :recordId];
        
        pp.Form_Status__c = 'Deleted';
        
        update pp;
    }
    
    //Fetching all medications(Treatments,Antibiotics and probiotics from eCRF maintanence object)
    public static Map<String,List<String>> getMedications(){
        List<ECRF_Maintainance__c> ecrfMntList = [select id,type__c,value__c,category__c from ECRF_Maintainance__c
                                                        where type__c in ('Medication','Antibiotic','Probiotic')];
        
        Map<String,List<String>> medMap = new Map<String,List<String>>();
        for(ECRF_Maintainance__c ecrf:ecrfMntList){
            if(medMap.containsKey(ecrf.type__c)){
                List<String> tempList = medMap.get(ecrf.type__c);
                tempList.add(ecrf.Value__c);
                medMap.put(ecrf.type__c,tempList);
            }
            else{
                List<String> valList = new List<String>();
                if(ecrf.type__c == 'Probiotic'){
                    valList.add('Select');
                }
                valList.add(ecrf.value__c);
                medMap.put(ecrf.type__c, valList);
            }
        }  
        
        return medMap;    
    }
    //Fetching values from custom setting
    public static List<String> getRouteAdminValues() {
        List<String> routeAdminValList = new List<String>();
            
        Schema.DescribeFieldResult fieldResult = Plexus_Medication__c.Route_of_Admin__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple){
          routeAdminValList.add(f.getValue());
        }  
        routeAdminValList.sort();
        
        List<String> finalRouteValList = new list<string>();
        finalRouteValList.add('Select');
        finalRouteValList.addAll(routeAdminValList);
             
        return finalRouteValList;
    }
    
    //Fetching values from custom setting
    public static List<String> getRreasonStoppedValues() {
        List<String> routeAdminValList = new List<String>();
            
        Schema.DescribeFieldResult fieldResult = Plexus_Medication__c.Reason_Stopped__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple){
          routeAdminValList.add(f.getValue());
        }  
        routeAdminValList.sort();
        
        List<String> finalRouteValList = new list<string>();
        finalRouteValList.add('Select');
        finalRouteValList.addAll(routeAdminValList);
             
        return finalRouteValList;
    }
    
    //Coverting Dosage value to string
    public static string getDosageFormat(decimal v){
        integer modVal = math.mod((v*100).intvalue(),100);
        String actualVal;
        if(modVal == 0){
            actualVal = string.valueof(v.intvalue());
        }
        else{
            actualVal = string.valueof(v);
        }

        return actualVal ;
    }
    
     //Wrapper class
    public class resultWrapper{
        public Plexus_Patient__c pp;
        public Plexus_Medication__c pma;
        public List<string> mediList;
        public List<string> antiList;
        Public List<String> proList;
        public List<string> routeAdminValList;
        public List<String> RreasonStoppedValues;
        public List<medicationWrapper> treatmentList;
        public List<medicationWrapper> antibioticList; 
        public List<medicationWrapper> probioticList; 
        public List<questWrapper> quesWrapper;
        public List<string> questList;  
        public Map<String,questWrapper> quesWrapperMap; 
        public String siteId;
        public String studyId;
    }
    
    //MEdication wrapper class
     public class medicationWrapper{
        @TestVisible
        String Id,Medication,MedicationOther,NewDose,NewUnit,NewFrequency,NewFrequent,NewStartDate,StopDate;
        @TestVisible
        String DoseStatus,FrequencyStatus,MedicationDateStatus;
        @TestVisible
        String routeOfAdmin;
        @TestVisible
        boolean doseUnknown;
        @TestVisible
        boolean ongoing;
        @TestVisible
        boolean StopDateEstimated,StartDateEstimated;
        @TestVisible
        String reasonStopped,rsComments;
    }
    
    //Question wrapper class
     public class questWrapper{
         public String question;
         public String resp;
         public String Id;
     }
    
    //Form wrapper class
     public class userFormWrapper{  
        @TestVisible
        String Id,pFirstname,physicianId,pLastname,siteId,studyId,patientId,condition,formStatus,physician,pDOB,pid,gender,PreferredName;
        @TestVisible
        String dateFormSubmt,antiBioticsLast6Months,antiBForIBD,antiBForOther;
        @TestVisible
        String submittedBy;

    }
    public class applicationException extends Exception {}*/
}