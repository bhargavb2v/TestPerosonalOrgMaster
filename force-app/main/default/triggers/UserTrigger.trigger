Trigger UserTrigger on User(after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            if(trigger.new[0].flag__c == true){
                System.resetPassword(trigger.new[0].id,true);
            }
        }
    }
}