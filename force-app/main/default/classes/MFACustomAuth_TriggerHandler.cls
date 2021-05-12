/********************************************************************************************
* Class Name: MFACustomAuth_TriggerHelper
* Author: Bhargavaramu
* Date: [05/16/2018]
* Requirement Description: MFA authentication
* Date Modified                Modified By                  Description of the update
* 
***********************************************************************************************/
public class MFACustomAuth_TriggerHandler{
    public void onBeforeUpdate(List<MFA_Custom_Auth__c> newMFAList, Map<id, MFA_Custom_Auth__c> oldMFAMap){
        for(MFA_Custom_Auth__c mfa : newMFAList){
            //Bypassing the below logic for resend verification code scenario. 
            if(!mfa.BypassFlag__c){
                //Restricting multiple updates within the time on same record.
                if(datetime.now() <= oldMFAMap.get(mfa.id).Expired_time__c){
                    mfa.addError('You cannot update this record before '+oldMFAMap.get(mfa.id).Expired_time__c);
                } 
            }
            //Resetting this flag to false in all scenarios. 
            mfa.BypassFlag__c = false;
        }
    }
}