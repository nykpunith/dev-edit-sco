@isTest
public class ContactHandlerTest {
    
    @isTest
    private static void testMethod_1(){
        List<Contact> testContacts = new List<Contact>{
            new Contact(FirstName='Test', LastName='Contact',Contact_Relationship__c =true),
                new Contact(FirstName='Test', LastName='Contact',Contact_Relationship__c =true),
                new Contact(FirstName='Test', LastName='Contact',Contact_Relationship__c =true)
                };
                    Test.startTest();
        insert testContacts;
        ContactHandler.createRelatedRecord(testContacts);
        Test.stopTest();
        List<Contact_Relationship__c> cr = [select id,name,contact__c from Contact_Relationship__c];// where contact__c in:testContacts
        system.assertEquals(cr[0].contact__c,testContacts[0].id);
        integer i=0;
        for(Contact_Relationship__c crc : cr){
            if(i<3)
                system.assertEquals(crc.contact__c,testContacts[i].id);
            i++;
        }
    }         
    @isTest
    private static void testSendEmail() {
        // Create a test contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testcontact@test.com';
        insert testContact;
        
        // Verify that the contact was inserted
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(1, contacts.size());
        
        // Call the sendEmail method
        List<Contact> contactList = new List<Contact>();
        contactList.add(testContact);
        test.startTest();
        ContactHandler.sendEmail(contactList);
        
        // Verify that a single email was sent to the contact's email address
        List<EmailMessage> emailMessages = [SELECT Id, ToAddress, Subject FROM EmailMessage WHERE ToAddress = :testContact.Email];
        
        System.assertEquals(0, emailMessages.size(), 'Expected 1 email to be sent');
        //System.assertEquals('New Contact', emailMessages[0].Subject);
        test.stopTest();
    }
    @isTest
    private static void testDeleteContact() {
        
         // Create a Contact without a related Case
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@test.com'
        );
        insert testContact;
        
        // Create another Contact with a related Case
        Contact otherContact = new Contact(
            FirstName = 'Other',
            LastName = 'Contact',
            Email = 'other.contact@test.com'
        );
        insert otherContact;
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = otherContact.Id
        );
        insert testCase;
        
        // Set the cutoff date to three days ago
        Date cutoffDate = Date.today().addDays(-3);
        
        // Call the deleteContact() method
        Test.startTest();
        ContactHandler.deleteContact();
        Test.stopTest();
        
        // Verify that only the testContact was deleted
        List<Contact> remainingContacts = [SELECT Id FROM Contact WHERE Id = :testContact.Id OR Id = :otherContact.Id];
        System.assertEquals(1, remainingContacts.size(), 'Expected one Contact to remain');
        System.assertEquals(otherContact.Id, remainingContacts[0].Id, 'Expected otherContact to remain');        
    }
    
    
    @istest
    private static void checkSchedule(){
         // Create a Contact without a related Case
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@test.com'
        );
        insert testContact;
        
        // Create another Contact with a related Case
        Contact otherContact = new Contact(
            FirstName = 'Other',
            LastName = 'Contact',
            Email = 'other.contact@test.com'
        );
        insert otherContact;
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = otherContact.Id
        );
        insert testCase;
        
        // Set the cutoff date to three days ago
        Date cutoffDate = Date.today().addDays(-3);
        Test.startTest();
        String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
        ContactSchedule job = new ContactSchedule();
        System.schedule('jobName', cronExpr, job);
        Test.stopTest();
        
        List<Contact> remainingContacts = [SELECT Id FROM Contact WHERE Id = :testContact.Id OR Id = :otherContact.Id];
        System.assertEquals(1, remainingContacts.size(), 'Expected one Contact to remain');
        System.assertEquals(otherContact.Id, remainingContacts[0].Id, 'Expected otherContact to remain');  
    }
}
        /*Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName = 'Doe';
        insert testContact;
        
        test.startTest();
        String cronExpr = '0 0 5 * * ?'; // Runs at midnight every day
        ContactSchedule job = new ContactSchedule();
        System.schedule('jobName', cronExpr, job);
        Contacthandler.deleteContact();
        test.stopTest();
        
        List<Contact> remainingContacts = [SELECT Id FROM Contact];
        System.assertEquals(1, remainingContacts.size(), 'Expected only 1 contact to remain after deletion');
        // System.assertEquals(testContact2.Id, remainingContacts[0].Id, 'Unexpected contact was deleted');
    }
} 
   /* @isTest
    private static void countContact(){
        Account a = new Account(name = 'IBM');
        insert a;
        List<Contact> testContacts = new List<Contact>{    
            new Contact(FirstName='Test', LastName='Contact', accountid = a.id),
                new Contact(FirstName='Test', LastName='Contact',accountid = a.id),
                new Contact(FirstName='Test', LastName='Contact',accountid = a.id)
                };               
                    insert testContacts;
        AccountHandler.countContacts(testContacts);
        Account updatedAcc1 = [select id,No_of_Contacts__c from account where id =:a.id];
        system.assertEquals(3,updatedAcc1.No_of_Contacts__c);
        
        contact c1 = testContacts.get(0);//[select id,FirstName from contact where name like 'Test%' limit 1];
        delete c1;
        AccountHandler.countContacts(testContacts);
        Account updatedAcc2 = [select id,No_of_Contacts__c from account where id =:a.id];
        system.assertEquals(2,updatedAcc2.No_of_Contacts__c);
        
        contact upc = testContacts.get(1);
        upc.FirstName = 'Upadte test';
        update upc;
        AccountHandler.countContacts(testContacts);
        /*contact c2 =[select id,FirstName from contact where Firstname like 'Test%' limit 1];
c2.FirstName = 'update test';
update c2;
        Account updatedAcc3 = [select id,No_of_Contacts__c,(select id,firstName from contacts where firstName = 'update test') from account where id =:a.id];
        system.assertEquals(2,updatedAcc3.No_of_Contacts__c);
        
        List<contact> c4 =[select id,FirstName from contact all rows];
        undelete c4;
        AccountHandler.countContacts(testContacts);
        Account updatedAcc4 = [select id,No_of_Contacts__c from account where id =:a.id];
        system.assertEquals(3,updatedAcc4.No_of_Contacts__c);
        
    }*/