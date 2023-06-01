@isTest
public class AccountOpportunityBatchTest {
    @IsTest
    static void testBatch() {
        // Create test accounts
        Account testAccount1 = new Account(Name = 'Test Account 1');
        insert testAccount1;
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert testAccount2;
        
        // Create test opportunities for testAccount1
        Opportunity testOpportunity1 = new Opportunity(Name = 'Test Opportunity 1', CloseDate = Date.today(), StageName = 'Prospecting', AccountId = testAccount1.Id);
        insert testOpportunity1;
        Opportunity testOpportunity2 = new Opportunity(Name = 'Test Opportunity 2', CloseDate = Date.today(), StageName = 'Closed Won', AccountId = testAccount1.Id);
        insert testOpportunity2;
        
        // Create test opportunities for testAccount2
        Opportunity testOpportunity3 = new Opportunity(Name = 'Test Opportunity 3', CloseDate = Date.today().addDays(-31), StageName = 'Prospecting', AccountId = testAccount2.Id);
        insert testOpportunity3;
        Opportunity testOpportunity4 = new Opportunity(Name = 'Test Opportunity 4', CloseDate = Date.today().addDays(-31), StageName = 'Closed Won', AccountId = testAccount2.Id);
        insert testOpportunity4;
        
        // Run the batch job
        Test.startTest();
        AccountOpportunityBatch batch = new AccountOpportunityBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that the opportunities were updated
        Opportunity updatedOpportunity1 = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpportunity1.Id];
        System.assertEquals('Closed Lost', updatedOpportunity1.StageName);
        
        Opportunity updatedOpportunity3 = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpportunity3.Id];
        System.assertEquals('Closed Lost', updatedOpportunity3.StageName);
        
        // Verify that the email was sent
        List<EmailMessage> sentEmails = [SELECT Id, ToAddress FROM EmailMessage];
        System.assertEquals(3, sentEmails.size());
        //System.assertEquals(testAccount1.Owner.Email, sentEmails[0].ToAddress);
        
        String jobName = 'send email to opp Acc owner';
		String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
		Account_opp_Batch_Schedule job = new Account_opp_Batch_Schedule();
		System.schedule(jobName, cronExpr, job);
    }
}