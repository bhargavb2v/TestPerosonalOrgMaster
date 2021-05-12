public with sharing class QuickActionController {
    @AuraEnabled
    public static List<Qucik_Action_Buttons__mdt> getButtons() {
        List<Qucik_Action_Buttons__mdt> lstButtons = [SELECT Id,Button_Label__c,Navigation_Component__c 
                                                        FROM Qucik_Action_Buttons__mdt];

        return lstButtons;
    }
}