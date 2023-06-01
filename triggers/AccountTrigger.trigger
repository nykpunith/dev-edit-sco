trigger AccountTrigger on Account (after insert,before insert,before update,After update) {
    //BEFORE
    if(trigger.isBefore){
        if(trigger.isUpdate){
            AccountHandler.NameChangedate(trigger.new,trigger.oldMap);
            AccountHandler.addOwnerNameToField(trigger.new);
        }
        if(trigger.isInsert){
            AccountHandler.addOwnerNameToField(trigger.new);
        }
    }
    //After
    if(trigger.isAfter){
        if(trigger.isInsert){
            AccountHandler.insertPrimaryContact(trigger.new);
        }
        if(trigger.isUpdate){
            AccountHandler.NameChangedateTask(trigger.new,trigger.oldMap);
        }
    }
}