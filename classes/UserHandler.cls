public class UserHandler {
    @future
    public static void updateContacts(Set<Id> deactivatedUserIds, Id backupUserId) {
        List<Contact> contactsToUpdate = [SELECT Id, OwnerId FROM Contact WHERE OwnerId IN :deactivatedUserIds];
        for (Contact c : contactsToUpdate) {
            c.OwnerId = backupUserId;
        }
        update contactsToUpdate;
    }
}
//15]|DEBUG|Update failed. First exception on row 0 with 
//id 0035i00000RZEvVAAX; first error: MIXED_DML_OPERATION,
// DML operation on setup object is not permitted after you 
// have updated a non-setup object (or vice versa): Contact, original object: User: []