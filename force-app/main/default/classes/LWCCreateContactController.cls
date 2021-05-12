public with sharing class LWCCreateContactController {
    @AuraEnabled
    public static Contact saveContact(Contact objContact){
        Contact obj;
        if(objContact != null){
           obj = objContact;
            update obj;
        }

        return obj;
    }
    
     @AuraEnabled
    public static String saveContactData(String firstName,String lastName){
        Contact objCon = new Contact(id='0036F000022ViRMQA0');
        objCon.firstName = firstName;
        objCon.lastName = lastName;
        
        update objCon;

        return objCon.Id;
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact getContact(String conId){
        Contact objCon;
        if(conId != null){
            objCon = [SELECT Id,Name,Firstname,Lastname,Email,Phone FROM Contact 
                                    WHERE Id = :conId];
        }

        return objCon;
    }
}