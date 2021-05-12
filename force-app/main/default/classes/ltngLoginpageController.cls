/************************************************************
 
 Name: CreateCandidateRecord
 Type: Apex Class  
 Purpose: Apex Class  for  lightning component 
          CreateCandidateRecordController.cmp
 ***********************************************************/
public with sharing class ltngLoginpageController{

    /**
   * Create a new candidate Record
   *
   * @param Candidate__c candidate  candidate record to be inserted
   * 
   */
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            // If start url is not present then redirect to dashboard page after login
            if(startUrl == null || startUrl == ''){
               startUrl = '/SensitiveFieldIdentifier';       
            }
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
}