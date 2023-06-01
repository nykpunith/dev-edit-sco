public class ContactHandler {
    
    //create contact relatiship record if the box is checked
    public static void createRelatedRecord(List<contact> contactList){
        List<Contact_Relationship__c> newCR = new List<Contact_Relationship__c>();
        for(contact con : contactList){
            if(con.Contact_Relationship__c == true){
                Contact_Relationship__c cr = new Contact_Relationship__c();
                cr.name = con.Name;
                cr.contact__c = con.Id;
                newCR.add(cr);
            }
        }
        insert newCR;
    }
    // send email to contact email when contact is inserted
    public static void sendEmail(List<contact> contactList){
        List<String> contactEmail = new List<String>();
        List<Id> conIds=new List<Id>();
        List<Id> whatIds=new List<Id>();
        EmailTemplate et = [SELECT Id,Subject,developerName, Body FROM EmailTemplate WHERE TemplateType = 'text'and DeveloperName ='New_Contact'];
        for(contact newContact : contactList){
            contactEmail.add(newContact.email);
            conIds.add(newContact.Id);
            whatIds.add(et.Id);
        }
        system.debug(conIds);
        Messaging.MassEmailMessage email = new Messaging.MassEmailMessage(); 
        email.setTargetObjectIds(conIds);
        email.setTemplateId(et.id);
        email.setSenderDisplayName('Salesforce support');
        Messaging.SendEmail(New Messaging.MassEmailMessage[] {email});
    }
    //delete contact -> this method is called in contactscheduled.apxc on daily basis
    public static void deleteContact(){
        List<Contact> contactsWithoutCases = [SELECT Id, Name FROM Contact WHERE Id NOT IN (SELECT ContactId FROM Case)];
        system.debug(contactsWithoutCases);
        
        Date currentDate = Date.today();
        Date cutoffDate = currentDate.addDays(-3);
        List<contact> ContactsToBeDelete = [select id,CreatedDate from contact 
                                            where CreatedDate < : cutoffDate and Id IN:contactsWithoutCases];
        system.debug(ContactsToBeDelete);
        delete ContactsToBeDelete;
        Database.emptyRecycleBin(ContactsToBeDelete);
    }
}
/*    List<Contact> contactsWithoutCases = [SELECT Id, Name FROM Contact WHERE Id NOT IN (SELECT ContactId FROM Case)];
system.debug(contactsWithoutCases);

Date currentDate = Date.today();
Date cutoffDate = currentDate.addDays(-3);
List<contact> ContactsToBeDelete = [select id,CreatedDate from contact 
where CreatedDate < : cutoffDate and Id IN:contactsWithoutCases];
system.debug(ContactsToBeDelete);
delete ContactsToBeDelete;
Database.emptyRecycleBin(ContactsToBeDelete);*/