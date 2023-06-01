@isTest
public class OpportunityHandlerTest {
    
    @isTest
    private static void notifyVP(){
        List<Opportunity> oppList = new List<opportunity>();
        for(integer i = 1; i<=3;i++){
            opportunity opp = new opportunity();
            opp.name = 'Laptop '+i;
            opp.StageName = 'Closed Won';
            opp.Amount = 500000;
            opp.CloseDate = date.today().adddays(5);
            oppList.add(opp);
        }
        insert oppList;
        
        Test.startTest();
        OpportunityHandler.notifyVp(oppList);
         Integer invocations = Limits.getEmailInvocations();
        test.stopTest();
       
        System.assertEquals(3, invocations, 'Email has not been sent');
        
    }
    @isTest
    private static void changeRT(){
        List<Opportunity> oppList = new List<opportunity>();
        for(integer i = 1; i<=3;i++){
            opportunity opp = new opportunity();
            opp.name = 'Laptop '+i;
            opp.StageName = 'Closed Won';
            opp.Amount = 500000;
            opp.CloseDate = date.today().adddays(5);
            oppList.add(opp);
        }
        insert oppList;
        Test.startTest();
        OpportunityHandler.changeRecordType(oppList);
        Test.stopTest();
        
        List<opportunity> updateOpp = [select id,recordTypeid,Amount from opportunity where id=:opplist];
        for(opportunity o : updateOpp){
            system.assertNotEquals('0125i0000002cE9AAI',o.recordtypeid);
        }
        List<Opportunity> oppListUpdate = new List<opportunity>();
        List<opportunity> updateStage = [select id,recordTypeid,Amount from opportunity where id=:opplist];
        for(opportunity ops : updateStage){
            ops.stageName = 'Closed Lost';
            oppListUpdate.add(ops);
        }
        update oppListUpdate;
        
        OpportunityHandler.changeRecordType(oppListUpdate);
       
        List<opportunity> updateOppstage = [select id,recordTypeid,Amount from opportunity where id=:oppListUpdate];
        for(opportunity st : updateOppstage){
            system.assertEquals('0125i0000002cE9AAI',st.recordtypeid);
        } 
    }
    @isTest
    private static void createTask(){
        Account a = new Account(name = 'IBM');
        insert a;
        List<Opportunity> oppList = new List<opportunity>();
        for(integer i = 1; i<=3;i++){
            opportunity opp = new opportunity();
            opp.name = 'Laptop '+i;
            opp.StageName = 'Closed Won';
            opp.Amount = 500000;
            opp.CloseDate = date.today().adddays(5);
            opp.AccountId = a.id;
            oppList.add(opp);
        }
        insert oppList;
        Test.startTest();
        OpportunityHandler.createTaskforPPQ(oppList);
        Test.stopTest();
        
        List<Opportunity> oppListUpdate = new List<opportunity>();
        List<opportunity> updateStage = [select id,recordTypeid,stageName,Account.id from opportunity where id=:opplist];
        for(opportunity ops : updateStage){
            ops.stageName = 'Proposal/Price Quote';
            oppListUpdate.add(ops);
        }
        update oppListUpdate;
        
        OpportunityHandler.createTaskforPPQ(oppListUpdate);
       
    }
    @isTest
    Private static void multiPickUp(){
        Account a = new Account(name = 'IBM');
        insert a;
        List<Opportunity> oppList = new List<opportunity>();
        for(integer i = 1; i<=3;i++){
            opportunity opp = new opportunity();
            opp.name = 'Laptop '+i;
            opp.StageName = 'Closed Won';
            opp.Amount = 500000;
            opp.CloseDate = date.today().adddays(5);
            opp.AccountId =a.id;
            oppList.add(opp);
        }
        insert oppList;
       
        map<id,opportunity> insertedOpp = new Map<Id,opportunity>();
        for(opportunity addTomAp : oppList){
        insertedopp.put(addTomAp.id, addTomAp);
        }
        
        List<Opportunity> oppListUpdate = new List<opportunity>();
        List<opportunity> updateOppAlpha = [select id,recordTypeid,stageName,Alphabet__c,Account.Alphabet__c from opportunity where id=:opplist];
        for(opportunity opAL : updateOppAlpha){
           opAL.Alphabet__c = 'A;B';
            oppListUpdate.add(opAL);
        }
        update oppListUpdate;
        
        OpportunityHandler.updateAccField(oppListUpdate,insertedOpp);
        
        List<opportunity> updOpp = [select id,recordTypeid,stageName,Alphabet__c,Account.Alphabet__c,Account.id from opportunity where id=:opplist];
        for(opportunity op : updOpp){
            system.assertEquals('A;B', op.Alphabet__c);
        }
    }
    @isTest
    private static void oppTask(){
        // Create test Account and Opportunity
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        List<Opportunity> oppList = new List<opportunity>();
        Opportunity testOpportunity = new Opportunity(
            Name='Test Opportunity',
            StageName='Closed Won',
            CloseDate=Date.today().addDays(-6),
            Amount=1000000,
            AccountId=testAccount.Id
        );
        oppList.add(testOpportunity);
        
        
        Opportunity testOpportunity_1 = new Opportunity(
            Name='Test Opportunity',
            StageName='Closed Won',
            CloseDate=Date.today().addDays(-2),
            Amount=1000000,
            AccountId=testAccount.Id
        );
        oppList.add(testOpportunity_1);
        
        Opportunity testOpportunity_2 = new Opportunity(
            Name='Test Opportunity',
            StageName='Closed Lost',
            CloseDate=Date.today().addDays(-6),
            Amount=1000000,
            AccountId=testAccount.Id
        );
        oppList.add(testOpportunity_2);

         Opportunity testOpportunity_3 = new Opportunity(
            Name='Test Opportunity',
            StageName='Closed Won',
            CloseDate=Date.today().addDays(-6),
            Amount=1000,
            AccountId=testAccount.Id
        );
        oppList.add(testOpportunity_3);
        
        insert oppList;
        // Call the createTask() method
        Test.startTest();
        OpportunityHandler.createTask();
        Test.stopTest();
        
        // Verify that a task was created for the Opportunity owner
        Task[] tasks = [SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId = :testOpportunity.Id];
        System.assertEquals(1, tasks.size(), 'Expected one task to be created');
        System.assertEquals(testOpportunity.Id, tasks[0].WhatId, 'Expected task WhatId to be the Opportunity Id');
        
        //schedule class
        String jobName = 'Create Task';
		String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
		OpportunityTaskSchedule job = new OpportunityTaskSchedule();
		System.schedule(jobName, cronExpr, job);
        Task[] tasks_1 = [SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId = :testOpportunity.Id];
        System.assertEquals(1, tasks_1.size(), 'Expected one task to be created');
    }
}