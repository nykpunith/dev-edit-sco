trigger Usertrigger on User (after update) {
    
    if(trigger.isAfter){
        Set<Id> deactivatedUserIds = new Set<Id>();
        for (User u : Trigger.new) {
            if (u.IsActive == false && Trigger.oldMap.get(u.Id).IsActive == true) {
                deactivatedUserIds.add(u.Id);
            }
        }
        if (!deactivatedUserIds.isEmpty()) {
            //User backupUser = [SELECT Id FROM User WHERE Username = 'user@backup.com' LIMIT 1];
            User_ID__mdt mc = User_ID__mdt.getInstance('Backup_user');//metadata type
            UserHandler.updateContacts(deactivatedUserIds, mc.Backup_user_id__c);
        }
    }
}