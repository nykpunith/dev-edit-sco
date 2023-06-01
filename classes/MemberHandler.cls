public class MemberHandler {
    // add manager as a contact to the assoated account
    public static void CreateContact(List<Members__c> membersList){
        List<Members__c> getManager = [select id,name,Manager__r.id,Account__r.id,Manager__r.name from Members__c where id IN:membersList];
        List<Contact> newContact = new List<Contact>();
        //for(Members__c m : membersList){
         // List<Members__c> getManager = [select id,name,Manager__r.id,Account__r.id,Manager__r.name from Members__c];
            
            for(Members__c manager : getManager){
                Contact c = new contact();
                c.LastName = manager.Manager__r.name;
                c.AccountId = manager.Account__r.id;
                newContact.add(c);
            }
        
        if(!newContact.isEmpty()){
            insert newContact;
        }
    }
}