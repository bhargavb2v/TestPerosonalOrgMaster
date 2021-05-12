/********************************************************************************************
* Class Name: MFACustomAuth_Trigger
* Author: Bhargavaramu
* Date: [05/16/2018]
* Requirement Description: MFA authentication
* Date Modified                Modified By                  Description of the update
* 
***********************************************************************************************/
trigger MFACustomAuth_Trigger on MFA_Custom_Auth__c (before update) {
    MFACustomAuth_TriggerHandler handler = new MFACustomAuth_TriggerHandler();
    //Before update event
    if(trigger.isBefore){
        if(trigger.isUpdate){
            handler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}