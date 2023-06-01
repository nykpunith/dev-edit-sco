public class OpportunityHandler {
    //if opportunity is closed won with ammout>=500000 notify salesvp via email -> After save
    public static void notifyVp(List<opportunity> opportunityList){   
        //get vpsales user email
        user vpSalesUser = [select id,name,email,UserRoleId from user where UserRoleId = '00E5i000000u5PFEAY'];
        List<string> toAddress = new List<string>();
        toAddress.add(vpSalesUser.email);
        for(Opportunity opp : opportunityList){
            
            if(opp.StageName == 'Closed Won' && opp.Amount >=500000){
                // Send Email to vp sale to notify
                Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
                mymail.setToAddresses(toAddress);
                mymail.setSenderDisplayName('Salesforce Support');
                mymail.setSubject('Closed Won Opportunity');
                mymail.setPlainTextBody('The Opportunity '+opp.Name +' is '+opp.StageName+' with this much of amount '+opp.Amount+'.');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
            }  
            
        }
    }
    //if stage is closed lost with amount>=500000 change record type to "closed lost" --> Before save
    public static void changeRecordType(List<Opportunity> OpportunityList){
        for(Opportunity opp : OpportunityList){
            if(opp.StageName == 'Closed Lost' && opp.Amount >=500000){
                opp.RecordTypeId = '0125i0000002cE9AAI';//closed Lost Record Type
            }
        }
    }
    //create task for opportunity if stage in proposal/price quote --> after save
    public static void createTaskforPPQ(List<Opportunity> OpportunityList){
        List<Task> newTask = new List<task>();
        for(Opportunity opp : OpportunityList){
            if(opp.StageName == 'Proposal/Price Quote'){
                Task t= new Task();
                t.subject = 'Opportunity stage is proposal/price quote';
                t.Status = 'Not Started';
                t.Priority = 'Normal';
                t.WhatId = opp.AccountId;
                t.WhatId = opp.Id;
                t.Description = 'The opportunity still in Proposal/Price Quote take an quick action on this opportunity';
                newTask.add(t);
            }
        }
        insert newTask;
    }
    //upadate account multipic list value
    public static void updateAccField(List<Opportunity> OpportunityList,map<id,Opportunity> oldOpportunity){
        Set<Id> accountIds = new Set<Id>();
        
        for (Opportunity opp1 : OpportunityList) {
            if (opp1.Alphabet__c != oldOpportunity.get(opp1.id).Alphabet__c) {
                accountIds.add(opp1.AccountId);
            }
        }
        List<Account> accountsToUpdate = [SELECT Id,Alphabet__c FROM Account WHERE Id IN :accountIds];
        for (Account acc : accountsToUpdate) {
            for (Opportunity opp2 : OpportunityList) {
                if (opp2.AccountId == acc.Id) {
                    acc.Alphabet__c = opp2.Alphabet__c;
                }
            }
        }
        update accountsToUpdate;
    }
        
    //Create a high priority follow-up task for the associated account’s owner, which is scheduled 
   // to execute six days after the opportunity’s Close Date. THIS class is schedule on daily to check the opportunity
    public static void createTask(){
        List<Opportunity> OpportunityList = [select id,closeDate,Account.id,stageName,Amount,Account.ownerid from Opportunity Where Amount >= 500000 AND stageName ='Closed Won'];
        Date today = Date.today();
        List<Task> newTask = new List<task>();
        for(Opportunity opp : OpportunityList){
            Date closedDate = opp.CloseDate;
            if(closedDate.daysBetween(today)==6){
                Task t= new Task();
                t.subject = 'Closed Won Opportunity';
                t.Status = 'Not Started';
                t.Priority = 'High';
                t.OwnerId = opp.Account.OwnerId;
                t.WhatId = opp.AccountId;
                t.WhatId = opp.Id;
                newTask.add(t);
            }
        }
        insert newTask;
    }
}