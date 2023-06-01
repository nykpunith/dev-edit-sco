trigger ContactTrigger on Contact (After update, After insert, After delete, After Undelete) {

    if(trigger.isAfter){
        if(trigger.isUpdate){
            AccountHandler.countContacts(trigger.new);
        }
        if(trigger.isInsert){
            AccountHandler.countContacts(trigger.new);
            ContactHandler.createRelatedRecord(trigger.new);
            ContactHandler.sendEmail(trigger.new);
        }
        if(trigger.isDelete){
             AccountHandler.countContacts(trigger.old);
        }
        if(trigger.isUnDelete){
             AccountHandler.countContacts(trigger.new);
        }
    }
    
}