public class CreateOpportunityQueueable implements Queueable {
    
    public void execute(QueueableContext context) {
        List<Account> accounts = [SELECT Id, Name, Owner.Email, Rating, Industry, BillingStreet, 
                                  BillingCity, BillingState, BillingPostalCode, ShippingStreet, 
                                  ShippingCity, ShippingState, ShippingPostalCode,
                                  (SELECT Id FROM Contacts) 
                                  FROM Account 
                                  WHERE Rating = 'Hot' AND Industry = 'Agriculture'];
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for(Account acc : accounts) {
            if(acc.Contacts.size() >= 2 && 
               acc.BillingStreet == acc.ShippingStreet &&
               acc.BillingCity == acc.ShippingCity &&
               acc.BillingState == acc.ShippingState &&
               acc.BillingPostalCode == acc.ShippingPostalCode) {
                   opportunities.add(new Opportunity(Name = acc.Name + ' Opportunity',
                                                     AccountId = acc.Id,
                                                     CloseDate = Date.today().addDays(30),
                                                     StageName = 'Prospecting'));
                   
                   Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                   email.setToAddresses(new List<String>{acc.Owner.Email});
                   email.setSubject('Opportunity created for account ' + acc.Name);
                   email.setPlainTextBody('Hello ' + ',\n\n' +
                                          'An opportunity has been created for the account ' + 
                                          acc.Name + '.');
                   email.setSenderDisplayName('Salesforce Suppourt');
                   emails.add(email);
               }
        }
        if(!opportunities.isEmpty()) {
            insert opportunities;
        }
        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
//CreateOpportunityQueueable queueable = new CreateOpportunityQueueable();
//System.enqueueJob(queueable);