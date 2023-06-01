@isTest
private class UpdateContactAddressBatchAndScheduleTest {
    
   @IsTest
    static void testBatch() {
        // Create an account with no parent account
        Account testAccount = new Account(Name='Test Account', BillingStreet='123 Test St', BillingCity='Test City', BillingState='Test State', BillingPostalCode='12345');
        insert testAccount;
        
        
        Contact testContact1 = new Contact(FirstName='John', LastName='Doe', Email='johndoe@test.com', AccountId=testAccount.Id);
        Contact testContact2 = new Contact(FirstName='Jane', LastName='Doe', Email='janedoe@test.com', AccountId=testAccount.Id);
        //Contact testContact3 = new Contact(FirstName='Bob', LastName='Smith', Email='bobsmith@test.com', AccountId=testAccount.Id);
        insert new List<Contact>{testContact1, testContact2};
        
        
        Account testParentAccount = new Account(Name='Test Parent Account', BillingStreet='123 Test St', BillingCity='Test City', BillingState='Test State', BillingPostalCode='12345');
        insert testParentAccount;
        Account testChildAccount = new Account(Name='Test Child Account', BillingStreet='123 Test St', BillingCity='Test City', BillingState='Test State', BillingPostalCode='12345', ParentId=testParentAccount.Id);
        insert testChildAccount;
        Contact testContact4 = new Contact(FirstName='Sarah', LastName='Johnson', Email='sarahjohnson@test.com', AccountId=testChildAccount.Id);
        insert testContact4;
        
        Test.startTest();
        UpdateContactAddressBatch batch = new UpdateContactAddressBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that the addresses were updated for the three contacts associated with the test account
        List<Contact> updatedContacts = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode,Account.ID FROM Contact WHERE Account.Id = :testAccount.Id];
        System.assertEquals(3, updatedContacts.size());
        for(Contact cont : updatedContacts) {
            System.assertEquals(testAccount.BillingStreet, cont.MailingStreet);
            System.assertEquals(testAccount.BillingCity, cont.MailingCity);
            System.assertEquals(testAccount.BillingState, cont.MailingState);
            System.assertEquals(testAccount.BillingPostalCode, cont.MailingPostalCode);
        }
        
       
        Contact updatedContact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :testContact4.Id];
        System.assertNotEquals(testAccount.BillingStreet, updatedContact.MailingStreet);
        System.assertNotEquals(testAccount.BillingCity, updatedContact.MailingCity);
        System.assertNotEquals(testAccount.BillingState, updatedContact.MailingState);
        System.assertNotEquals(testAccount.BillingPostalCode, updatedContact.MailingPostalCode);
    }


//private class TestScheduleUpdateContactAddress {
    @isTest
    static void test2() {
        // Schedule the job to run immediately
        ScheduleUpdateContactAddress scheduler = new ScheduleUpdateContactAddress();
        String jobId = System.schedule('Update Contact Address Job Test', '0 0 * * * ?', scheduler);

            }
}