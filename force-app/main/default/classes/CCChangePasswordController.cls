public class CCChangePasswordController{
   /* 
    public String studySFId{get;set;}
    public String siteSFId{get;set;}
    public String userName{get;set;}
    public user u;
    
    public Plexus_ChangePasswordController(){
        studySFId = Apexpages.currentpage().getparameters().get('sId'); 
        u = [Select id,name,profile.Name,user_username__c,username,contactId,contact.Plexus_Site__c,contact.plexus_patient__c 
                                                                    From User where id = :userinfo.getUserId()];
        siteSFId = u.contact.plexus_site__c;
        if(u.user_username__c != null && u.user_username__c != ''){
            userName = u.user_username__c;
        }
        else{
            userName = u.username;
        }
    }
    
    @RemoteAction
    public static String changePasswordClick(String oldPassword,String newPassword,String confirmNewPassword) {
        String errorMsg;
        PageReference pageRef = Site.changePassword(newPassword, confirmNewPassword,oldPassword);
        //If Change password fails then show the error
        if(ApexPages.getMessages().size() > 0)
            errorMsg = ApexPages.getMessages()[0].getSummary();
        else
            errorMsg = 'Password changed successfully.';
        
        
        return errorMsg;
    }*/
}