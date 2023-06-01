global class AccountOpportunityBatch implements Database.Batchable<sObject>,Database.Stateful {
    //this batch class is called from Account_opp_Batch_Schedule.apxc at midnight
    global List<Opportunity> opportunitiesToUpdate;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Account WHERE LastModifiedDate = TODAY]);
    }
    
    global void execute(Database.BatchableContext context, List<Account> scope) {
        opportunitiesToUpdate = new List<Opportunity>();
        try{
            List<opportunity> oppList = [select id,stageName, createdDate,AccountId from opportunity where stageName != 'Closed Won' AND stageName != 'Closed Lost' AND AccountId IN: scope];
            //createdDate < Last_N_Days:30 AND
            for(Opportunity opp : oppList) {
                opp.StageName = 'Closed Lost';
                opportunitiesToUpdate.add(opp);
            }
            
            if(!opportunitiesToUpdate.isEmpty()) {
                update opportunitiesToUpdate;
            }
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        
    }
    global void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
        List<Opportunity> updatedOpp = [SELECT Id, Account.Owner.Email,Account.Owner.name,Account.name, name FROM Opportunity WHERE Id IN :opportunitiesToUpdate AND StageName = 'Closed Lost'];
        for(Opportunity up : updatedOpp) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ up.Account.Owner.Email });
            email.setSubject('Opportunity Update Notification');
            email.setPlainTextBody('Dear ' + up.Account.Owner.Name + ',\n\n' + 'This email is to notify you that the opportunity ' + up.Name + ' associated with your account ' + up.Account.Name + ' has been updated to Closed Lost.\n\n' + 'Best regards,\n' + 'Your Salesforce System');
            emails.add(email);
        }
        try{   
        if(emails.size() > 0) {
            Messaging.sendEmail(emails);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
    }
}
/* List<Opportunity> updatedOpp = [SELECT Id, Account.Owner.Email FROM Opportunity WHERE Id IN :opportunitiesToUpdate AND StageName = 'Closed Lost'];
AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
for(Opportunity up : updatedOpp) {
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
email.setToAddresses(new List<String>{ up.Account.Owner.Email });
email.setSubject('Opportunity Update Notification');
email.setPlainTextBody('Dear ' + up.Account.Owner.Name + ',\n\n' + 'This email is to notify you that the opportunity ' + up.Name + ' associated with your account ' + up.Account.Name + ' has been updated to Closed Lost.\n\n' + 'Best regards,\n' + 'Your Salesforce System');
emails.add(email);
}
if(emails.size() > 0) {
Messaging.sendEmail(emails);
}
}
}// this batch class is called from contactscheduled.apxc at midnight*/