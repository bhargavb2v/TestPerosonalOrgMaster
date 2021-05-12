public class CCForgotPasswordController{
/**
    public String username {get; set;}
    
    public Plexus_ForgotPasswordController(){
        username = Apexpages.currentpage().getparameters().get('user');
    }
    
    @RemoteAction
    public static string resetPassword(string username) {
        String errorMsg;
        String originalUserName;
        User u = Plexus_Utility.getUserDetails(username);
        if(u != null){
            originalUserName = u.userName;
        }
        else{
            originalUserName = username;
        } 
        if(originalUserName != null && originalUserName != ''){
            List<User> userList = [Select id,profileId,profile.Name,name,username,email,user_username__c,user_email__c,user_first_name__c,user_last_Name__c,user_phone__c from user where Username = :originalUserName Limit 1];
            if(userList.size() > 0){
                System.resetPasswordResult res = System.resetPassword(userList[0].Id, false);
                if (res != null && !String.isBlank(res.getPassword())){
                    Boolean isSuccess = Plexus_Utility.sendResetPasswordemail(userList[0],res.getPassword());
                    errorMsg = 'Success';
                }
            }
            else{
                errorMsg = 'Please enter a valid Username to continue.';
            }  
        }
        else {
            errorMsg = 'Please enter a Username to continue.';
        }
        
        return errorMsg;
    }*/
}