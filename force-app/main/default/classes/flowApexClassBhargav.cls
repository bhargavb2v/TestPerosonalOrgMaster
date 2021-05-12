global class flowApexClassBhargav{
   
   @InvocableMethod
   public static void updateUserRecord() {
       User u = [select id,profileId from user where id = :userinfo.getUserId()];
       Integer rndnum = Math.round(Math.random()*1000000);
       String otp = string.valueOf(rndnum);
        
        u.token__c = otp;
       
       update u;
   }
}