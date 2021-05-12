public class LoginController{
/**
    public String username {get; set;}
    public String password {get; set;}
    public String errorMsg{get;set;}
    
    public Plexus_LoginController(){
        username = '';
        password = '';
    }
    
    public PageReference login() {
        errorMsg ='';
        
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        
        
        // If start url is not present then redirect to dashboard page after login
        if(startUrl == null || startUrl == ''){
           startUrl = '/plexus_Home';       
        }
        
        String originalUserName;
        User u = Plexus_Utility.getUserDetails(username);
        if(u != null){
            originalUserName = u.userName;
        }
        else{
            originalUserName = username;
        } 
        
        // Login to community
        PageReference ref = Site.login(originalUserName, password, startUrl);
        // if login fails then show error message
        // if login fails then show error message
        if(ApexPages.getMessages().size() > 0){
            //errorMsg = Label.SIS_Incorrect_Username_Password;//
            errorMsg = ApexPages.getMessages()[0].getSummary();
        }
        
        return ref;
    }
    
    public pagereference forgotpassword() {
        string url;
        if(username != null && username != ''){
            url = '/ibdplexus/Plexus_ForgotPassword?user=' + username;
        }
        else{
            url = '/ibdplexus/Plexus_ForgotPassword';
        }
        PageReference ref = new PageReference(url);
        ref.setRedirect(true);
        return ref;
    }*/
}