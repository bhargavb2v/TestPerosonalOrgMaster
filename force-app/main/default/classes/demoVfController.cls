public class demoVfController{

    public void buttonclick(){
        List<TwoFactorInfo> twoList = [SELECT UserId,SharedKey,Type FROM TwoFactorInfo];
        system.debug('#######'+twoList); 
    }

}