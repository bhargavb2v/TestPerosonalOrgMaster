public class Plexus_HeaderController{
    /*public user u;
    public string isPatientTab{get;set;}
    public string isMyeCRFTab{get;set;}
    public string isMyProfile{get;set;}
    
    public String studySFId{get;set;}
    public String patientSFId{get;set;}
    
    public string patientTabURL{get;set;}
    public String myeCRFTabURL{get;set;}
    public String loggedInUserName{get;set;}
    public string eManifestTabUrl{get;set;}
    
    public Plexus_HeaderController(){
        studySFId = Apexpages.currentpage().getparameters().get('sId'); 
        isMyProfile = Apexpages.currentpage().getparameters().get('myprofile'); 
        u = [Select id,name,profile.Name,contactId,contact.Plexus_Site__c,contact.plexus_patient__c,
                                    user_first_name__c,user_last_name__c  
                                    From User where id = :userinfo.getUserId()];
        loggedInUserName = u.user_first_name__c != null && u.user_first_name__c != '' ? u.user_first_name__c+' '+ u.user_last_name__c : u.Name;                                                            
        Plexus_Settings__c setting = Plexus_Settings__c.getOrgDefaults();

        if(u.profile.Name == setting.Site_Staff_Profile_Name__c){
            isPatientTab = 'Yes';
            isMyeCRFTab = 'No';
        }
        else{
            isPatientTab = 'No';
            isMyeCRFTab = 'Yes';
            patientSFId = u.contact.plexus_patient__c;
        }
        
        Plexus_settings__c ps = Plexus_settings__c.getInstance();
        if(studySFId != null && studySFId != ''){
            patientTabURL  = ps.Community_URL__c  + '/Plexus_PatientListView?sId='+studySFId; 
            myeCRFTabURL = ps.Community_URL__c  + '/Plexus_PatientPage?id='+patientSFId+'&sId='+studySFId;
            eManifestTabUrl = ps.Community_URL__c  + '/plexus_emanifest_page?sId='+studySFId; 
        }
        else{
            patientTabURL  = ps.Community_URL__c  + '/plexus_home'; 
            myeCRFTabURL = ps.Community_URL__c  + '/plexus_home'; 
            eManifestTabUrl = ps.Community_URL__c  + '/plexus_home'; 
            
        }
    }*/
}