trigger MemberTrigger on Members__c (before insert,after insert) {

    if(trigger.isAfter){
        if(trigger.isInsert){
            MemberHandler.CreateContact(trigger.new);
        }
    }
}