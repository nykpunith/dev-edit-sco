public class AccountHandler {
    
    //capture a date when account name got modified -> before save
    public static void NameChangedate(List<Account> accountList, map<id,Account> oldAccount){
        for(Account acc : accountList){
            if(acc.name != oldAccount.get(acc.id).name){
                acc.Name_Change_date__c = system.now();
            }
        }
    }
    //create task
    public static void NameChangedateTask(List<Account> accountList, map<id,Account> oldAccount){
        List<Task> newTask = new List<task>();
        for(Account acc : accountList){
            if(acc.name != oldAccount.get(acc.id).name){
                Task t= new Task();
                t.subject = 'Account name got modified';
                t.Status = 'Not Started';
                t.Priority = 'Normal';
                t.WhatId = acc.Id;
                newTask.add(t);
            }
        }
        insert newTask;
    }
    //count of contacts
    public static void countContacts(List<Contact> contactList){
        List<Account> updateAccount = new List<Account>();
        for(Contact con : contactList){
            try{
                List<Account> AccList = [Select id,name,No_of_Contacts__c,(Select id, name from contacts) from Account];
                for(Account a :AccList){
                    a.No_of_Contacts__c = a.contacts.size();
                    updateAccount.add(a);
                }
                if(!AccList.isEmpty()){
                    update updateAccount;
                }
            }
            catch(exception e){
                system.debug(e.getMessage());
            }
        }
    }
    //update Sales_Representative__c field with account owner name when updated and inserted
    public static void addOwnerNameToField(List<Account> accountList){
        Set<Id> ownerIds = new Set<Id>();
        for(Account acc1 : accountList) {
            if(acc1.OwnerId != null) {
                ownerIds.add(acc1.OwnerId);
            }
        }
        Map<Id, User> owners = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :ownerIds]);
        for(Account acc2 : accountList) {
            if(acc2.OwnerId != null && owners.containsKey(acc2.OwnerId)) {
                acc2.Sales_Representative__c = owners.get(acc2.OwnerId).Name;
            }
        }
    }
    /*we first create a set of owner ids to query for (ownerIds). We then iterate over the new account records 
* in Trigger.new to populate the set of owner ids. After that, we query the User object to get all the owner records 
* in one go using the IN operator ([SELECT Id, Name FROM User WHERE Id IN :ownerIds]). We store these owner records 
* in a map (owners), using the owner id as the key and the User record as the value.
Finally, we iterate over the new account records in Trigger.new again and check if an owner 
is assigned to each account (acc.OwnerId != null). If an owner is assigned, we check if the owners 
map contains the owner record for that account (owners.containsKey(acc.OwnerId)). If the map contains the 
record, we set the owner name on the account record using owners.get(acc.OwnerId).Name.*/
    
    // when account is created insert a contact record with account name and add that contact into the corresponding account as a primary contact
    public static void insertPrimaryContact(List<Account> accountList){
        set<id> accId = new set<id>();
        List<Contact> contactsToInsert = new List<Contact>();
        for(Account newAcc : accountList){
            contact newContact = new contact();
            newContact.FirstNAme = 'Primary';
            newContact.LastName = newAcc.name;
            newContact.accountId = newAcc.id;
            contactsToInsert.add(newContact);
        }
        insert contactsToInsert;
        Map<String, Id> accountNameIdMap = new Map<String, Id>();
        for (Account acc : accountList) {
            accountNameIdMap.put(acc.Name, acc.Id);
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (Contact con : contactsToInsert) {
            Account acc = new Account(
                Id = accountNameIdMap.get(con.LastName),
                Primary_Contact__c = con.Id
            );
            accountsToUpdate.add(acc);
        }
        update accountsToUpdate;
    }/*It sets the Id of the new Account record to the Id of the corresponding Account record that was previously stored in the accountNameIdMap*/

// send email at midnight (scheduled apex) this method is called in contactscheduled.apex    
    public static void sendEmailRegPhoneNoUpdate(){
        List<Account> accountList = [select id,name,type,ownerId,phone,Owner.Name,Owner.email from account];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Account a : accountList){
            if(a.phone == null && a.Type == 'Customer - Direct'){
                List<String> toaddress = new List<string>();
                toaddress.add(a.Owner.Email);
                system.debug(toaddress);
	                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toaddress);  //new List<String>{a.Owner.Email}
                email.setSubject('Update Phone Number');
                email.setSenderDisplayName('salesforce suppourt');
                email.setPlainTextBody('Hello ' + a.owner.name+ ',\n\n' +'"'+ a.Name +'" :'+
                                       'This Account dont have phone number please update the phone number ' +  '.');
                emails.add(email);
            }
        }
        Messaging.SendEmail(emails);
    }
}