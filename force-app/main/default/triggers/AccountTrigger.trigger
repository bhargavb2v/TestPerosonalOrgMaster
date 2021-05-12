trigger AccountTrigger on Account (after insert,after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    if(Trigger.isBefore){
    
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.onAfterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate){
            handler.onAfterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}