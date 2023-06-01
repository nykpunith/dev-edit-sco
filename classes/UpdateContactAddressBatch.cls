global class UpdateContactAddressBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Account.Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Account.BillingStreet,
                                         Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Account.No_of_Contacts__c
                                         FROM Contact WHERE AccountId != null AND Account.ParentId = null 
                                         AND Account.No_of_Contacts__c < 3]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        for(Contact con : scope) {
            con.MailingStreet = con.Account.BillingStreet;
            con.MailingCity = con.Account.BillingCity;
            con.MailingState = con.Account.BillingState;
            con.MailingPostalCode = con.Account.BillingPostalCode;
            con.MailingCountry = con.Account.BillingCountry;
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
       
    }
}

/*global Database.QueryLocator start(Database.BatchableContext BC) {
// Query for accounts that meet the criteria
String query = 'SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ';
query += '(SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contacts) ';
query += 'FROM Account ';
query += 'WHERE ParentId = null AND Id IN (SELECT AccountId FROM Contact GROUP BY AccountId HAVING COUNT(Id) < 3)';
return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<Account> scope) {
// Loop through each account in the batch
for (Account acct : scope) {
// Update the address of each associated contact
for (Contact con : acct.Contacts) {
con.MailingStreet = acct.BillingStreet;
con.MailingCity = acct.BillingCity;
con.MailingState = acct.BillingState;
con.MailingPostalCode = acct.BillingPostalCode;
con.MailingCountry = acct.BillingCountry;
}
}

// Update the contacts in the database
update scope;
}

global void finish(Database.BatchableContext BC) {

}
}*/