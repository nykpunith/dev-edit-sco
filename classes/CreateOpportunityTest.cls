@IsTest
public class CreateOpportunityTest {
    @IsTest
    public static void testCreateOpportunity() {
        // Create test account with hot rating, agriculture industry, billing and shipping address same
        Account testAccount = new Account(Name = 'Test Account', Rating = 'Hot', Industry = 'Agriculture',
                                          BillingStreet = '123 Main St', BillingCity = 'Anytown',
                                          BillingState = 'CA', BillingPostalCode = '12345',
                                          ShippingStreet = '123 Main St', ShippingCity = 'Anytown',
                                          ShippingState = 'CA', ShippingPostalCode = '12345');
        insert testAccount;
        
        // Create test contacts for the account
        Contact testContact1 = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'johndoe@test.com',
                                            AccountId = testAccount.Id);
        Contact testContact2 = new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'janedoe@test.com',
                                            AccountId = testAccount.Id);
        insert new List<Contact>{testContact1, testContact2};
        
        // Create test account with hot rating, agriculture industry, but different billing and shipping address
        Account testAccount2 = new Account(Name = 'Test Account 2', Rating = 'Hot', Industry = 'Agriculture',
                                           BillingStreet = '123 Main St', BillingCity = 'Anytown',
                                           BillingState = 'CA', BillingPostalCode = '12345',
                                           ShippingStreet = '456 First St', ShippingCity = 'Othertown',
                                           ShippingState = 'CA', ShippingPostalCode = '54321');
        
                                         //insert testAccount2;
        
        // Create test contacts for the account
        
        CreateOpportunityQueueable queueable = new CreateOpportunityQueueable();
        System.enqueueJob(queueable);
        
       
    }
}