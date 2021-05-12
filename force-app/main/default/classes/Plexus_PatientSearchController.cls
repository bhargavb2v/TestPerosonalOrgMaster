public class Plexus_PatientSearchController {
   /*public String studySFId{get;set;}
    public String siteSFId{get;set;}
    public user u;
    
    public String isPatient{get;set;}
    public String isAdmin{get;set;}
    public String isStaff{get;set;}
    public String isViewEncryptedDataUser{get;set;}

    
    public Plexus_PatientSearchController(){
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
            PageReference p = page.Plexus_Exception;
            return p;
        }
        return null;
    }
    
    @RemoteAction
    public static List<patientWrapper> getPatientSearchResult(String searchkey,string siteId) {
        
        List<Plexus_patient__c> patientList = new List<Plexus_patient__c>();
        

        for(Plexus_patient__c pl: [Select id,name,patient_id__c,first_name__c,last_name__c,
                                                                            phone__c,email__c,date_of_birth__c 
                                                                    From Plexus_Patient__c]){
            if(pl.patient_id__c != null && pl.patient_id__c != ''){
                string s1 = pl.patient_id__c.tolowercase();
                string s2 = searchkey.tolowercase();
                if(s1.indexOf(s2) > -1){
                    patientList.add(pl);  
                }  
            }
        }  
        
        List<Plexus_Study_site_patient__c> psspList = [select id,study__c,site__c,patient__c 
                                                                            From Plexus_Study_site_patient__c 
                                                                            where patient__c in :patientList And 
                                                                                  site__c = :siteId];
                                                                                 
        Map<string,set<string>> patientStudyMap = new Map<string,set<string>>();                                                                   
        for(Plexus_Study_site_patient__c pssp : psspList){
            if(patientStudyMap.containsKey(pssp.patient__C)){
                Set<string> tempSet = new set<String>();
                tempSet = patientStudyMap.get(pssp.patient__c);
                tempSet.add(pssp.study__c);
                patientStudyMap.put(pssp.patient__c,tempSet);
            }
            else{
                patientStudyMap.put(pssp.patient__c,new set<string>{pssp.study__c});
            }
        }
        
        List<patientWrapper> pwList = new List<patientWrapper>();
        for(Plexus_patient__c pp : patientList){
            if(patientStudyMap.containsKey(pp.Id)){
                patientWrapper pw = new patientWrapper();
                pw.Id = pp.Id;
                pw.name = pp.first_Name__c+' '+pp.last_Name__c;
                pw.firstName = pp.first_name__c;
                pw.lastName = pp.last_name__c;
                pw.mrn = pp.patient_id__c;
                pw.phone = pp.phone__c;
                pw.email = pp.email__c;
                pw.dob = setDateToStringformat(pp.date_of_birth__c);
                pw.regStudySet = patientStudyMap.containsKey(pp.Id) ? patientStudyMap.get(pp.Id) : null;
                pwList.add(pw);
            }
        }
        
        return pwList;
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
    
    //Wrapper class
    public class patientWrapper{
        public string Id;
        public string name;
        public string firstName;
        public string lastName;
        public string mrn;
        public string phone;
        public string email;
        public string dob;
        public set<string> regStudySet;
    }*/
}