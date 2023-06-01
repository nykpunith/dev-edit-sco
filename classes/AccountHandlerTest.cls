@isTest
public class AccountHandlerTest {
    
    @isTest
    public static void testMethod_1(){
        Account acc1 = new Account();
        acc1.name = 'Jhon';
        insert acc1;
        //before update the name
        acc1 = [SELECT Id,name, Name_Change_date__c,LastModifiedDate FROM Account WHERE Id = :acc1.Id];
        system.assertEquals('Jhon',acc1.name);
        system.assertEquals(null, acc1.Name_Change_date__c);
        // update name
        acc1.Name = 'New Test Account Name';
        update acc1;
        //after update name
        Account acc2 = [SELECT Id,name, Name_Change_date__c,LastModifiedDate FROM Account WHERE Id = :acc1.Id];
        System.assertEquals(acc2.LastModifiedDate, acc2.Name_Change_date__c);
        System.assertEquals('New Test Account Name',acc2.name);
        system.assertNotEquals('Jhon',acc2.name);
        //after update other field
        acc1.rating = 'Hot';
        update acc1;
        Account acc3 = [SELECT Id,name, Name_Change_date__c,LastModifiedDate,rating FROM Account WHERE Id = :acc1.Id];
        system.assertEquals(acc2.Name_Change_date__c, acc3.Name_Change_date__c);
    }
    
    @isTest
    private static void testMethod_2(){
        Account acc1 = new Account(name='Jhon');
        insert acc1;
        List<contact> conList = new List<contact>();
        contact c1 = new contact(FirstName = 'Whitter',LastName = 'Walt', accountId = acc1.id);
        contact c2 = new contact(FirstName = 'jhon',LastName = 'Wick', accountId = acc1.id);
        conList.add(c1);
        conList.add(c2);
        insert conList;
        AccountHandler.countContacts(conList);
        //insert check
        Account acc2 = [select id,name,No_of_Contacts__c from account where id =:acc1.id];
        system.assertEquals(3,acc2.No_of_Contacts__c);
        system.assertNotEquals(0,acc2.No_of_Contacts__c);
        
        //delete check
        delete c2;
        Account acc3 = [select id,name,No_of_Contacts__c from account where id =:acc1.id];
        system.assertEquals(2,acc3.No_of_Contacts__c);
        system.assertNotEquals(0,acc3.No_of_Contacts__c);
        
        //undelete check
        List<contact> con = [select id,Account.id from contact all rows];//where Account.id =:acc1.id
        undelete c2;
        Account acc5 = [select id,name,No_of_Contacts__c from account where id =:acc1.id];
        system.assertEquals(3,acc5.No_of_Contacts__c);
        system.assertNotEquals(0,acc5.No_of_Contacts__c);
        //update check
        c2.Phone = '4894894';
        update c2;
        Account acc6 = [select id,name,No_of_Contacts__c from account where id =:acc1.id ];
        system.assertEquals(3,acc6.No_of_Contacts__c);
        system.assertEquals('4894894',c2.Phone);
        system.assertNotEquals(0,acc6.No_of_Contacts__c);
    }
    
    @isTest
    private static void testMethod_3(){
        List<Account> acc1 = new List<Account>{new account(name='jhon'),new account(name='walt')};
            insert acc1;
        AccountHandler.addOwnerNameToField(acc1);
        Set<Id> ownerIds = new Set<Id>();
        for(Account acc2 : acc1) {
            if(acc2.OwnerId != null) {
                ownerIds.add(acc2.OwnerId);
            }
        }
        Map<Id, User> owners = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :ownerIds]);
        for(Account a : acc1) {
            if(a.OwnerId != null && owners.containsKey(a.OwnerId)) {
                //acc2.Sales_Representative__c = owners.get(acc2.OwnerId).Name;
                system.assertEquals(owners.get(a.OwnerId).Name, a.Sales_Representative__c);
            }
        }   
    }
    
    @isTest
    public static void testMethod_4(){
        List<Account> acc1 = new List<Account>{new account(name='jhon'),new account(name='walt')};
            insert acc1;
        List<Account> acc2 = [select id,name,Sales_Representative__c,ownerid from account where name = 'jhon'];
        List<account> accupd = new List<Account>();
        for(Account acc3 : acc2){
            acc3.OwnerId = '0055i000006uTmp';//Anju sing
            accupd.add(acc3);
        }
        
        test.startTest();
        update accupd;
        AccountHandler.addOwnerNameToField(accupd);
        test.stopTest();
        Set<Id> ownerIds = new Set<Id>();
        for(Account acc4 : accupd) {
            if(acc4.OwnerId != null) {
                ownerIds.add(acc4.OwnerId);
            }
        }
        Map<Id, User> owners = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :ownerIds]);
        for(Account a : acc1) {
            if(a.OwnerId != null && owners.containsKey(a.OwnerId)) {
                //acc2.Sales_Representative__c = owners.get(acc2.OwnerId).Name;
                system.assertEquals(owners.get(a.OwnerId).Name, a.Sales_Representative__c);
                system.assertEquals('Anju Sing', a.Sales_Representative__c);
            }
        }    
    }
    @isTest
    private static void testMethod_5(){
        List<Account> acc1 = new List<Account>{new account(name='jhon'),new account(name='walt')};
            Test.startTest();
        insert acc1;
        AccountHandler.insertPrimaryContact(acc1);
        test.stopTest();
        
        List<Account> acc2 = [select id,name,Primary_Contact__r.name,(select id,LastName from contacts) from Account where id in:acc1];
        for(Account acc3 : acc2){
            for (Contact con : acc3.contacts) {
                System.debug('Contact Last Name: ' + con.LastName);
                system.assertEquals('Primary '+con.LastName, acc3.Primary_Contact__r.name);
            }  
        }
    }
    
    @isTest
    private static void testMethod_6(){
        
        Account acc = new Account(Name='Test Account', Type='Customer - Direct');
        insert acc;
        
        // Call the method that sends email for accounts with null phone number and type 'Customer - Direct'
        AccountHandler.sendEmailRegPhoneNoUpdate();  
        // Verify that the email was sent
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(2, invocations, 'Email has not been sent');
       /* List<Messaging.SingleEmailMessage> sentEmails = new List<Messaging.SingleEmailMessage>();
        System.assertEquals(1, sentEmails.size());
        Messaging.SingleEmailMessage sentEmail = sentEmails[0];
        System.assertEquals('Update Phone Number', sentEmail.getSubject());
        System.assertEquals('salesforce suppourt', sentEmail.getSenderDisplayName());
        System.assertEquals('Hello '+ ',\n\n"Test Account" :This Account dont have phone number please update the phone number.', sentEmail.getPlainTextBody());*/
    }
    
    //schedule
    @isTest
    private static void checkSchedule(){
        //schedule
        Account acc = new Account(Name='Test Account', Type='Customer - Direct');
        insert acc;
        String jobName = 'Send Email';
        String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
        Account_SendEmail_Owner_Schedule job = new Account_SendEmail_Owner_Schedule();
        System.schedule(jobName, cronExpr, job);    
    }
}
/*List<Account> accountList = TestDataFactory.createAccounts(2);
Account a1 = accountList[0];
Account a2 = accountList[1];
a1.Type = 'Customer - Direct';
a1.Phone = null;
insert a1;
a2.Type = 'Customer - Channel';
a2.Phone = null;
insert a2;

Test.startTest();
AccountHandler.sendEmailRegPhoneNoUpdate();
Test.stopTest();

// Verify email is sent to correct users
List<Messaging.SingleEmailMessage> sentEmails = Messaging.sendEmail(new List<Messaging.Email>{});
System.assertEquals(1, sentEmails.size(), 'Wrong number of emails sent.');
System.assertEquals(a1.Owner.Email, sentEmails[0].getToAddresses()[0], 'Wrong email recipient.');

/*List<Account> testAccount = new List<Account>{new account(name='jhon',Type = 'Customer – Direct'),new account(name='walt',Type = 'Customer – Direct')};
insert testAccount;
Test.startTest();
AccountHandler.sendEmailRegPhoneNoUpdate();
/*String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
ContactSchedule job = new ContactSchedule();
System.schedule('jobName', cronExpr, job);
test.stopTest();

/*Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
List<User> testUser = new List<User>();
for (Integer i = 0; i < 3; i++) {
testUser.add(new User(
Username = 'vin' + i + '@test.com',
Email = 'user' + i + '@test.com',
Alias = 'test' + i,
LastName = 'Test User ' + i,
TimeZoneSidKey = 'America/Los_Angeles',
LocaleSidKey = 'en_US',
EmailEncodingKey = 'UTF-8',
LanguageLocaleKey = 'en_US',
ProfileId = profile.Id,
IsActive = true
));
}
insert testUser;

// Set the test user as the owner of the test account
testAccount[0].OwnerId = testUser[0].Id;
update testAccount;

// Call the sendEmailRegPhoneNoUpdate method
List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
AccountHAndler.sendEmailRegPhoneNoUpdate();

// Verify that the expected email message was created
System.assertEquals(1, emails.size(), 'Unexpected number of emails created');
Messaging.SingleEmailMessage email = emails[0];
System.assertEquals('testuser@test.com', email.getToAddresses()[0], 'Incorrect email recipient');
System.assertEquals('Update Phone Number', email.getSubject(), 'Incorrect email subject');
System.assertEquals('Salesforce Support', email.getSenderDisplayName(), 'Incorrect email sender display name');
System.assertEquals('Hello Test User,\n\nThis Account does not have a phone number. Please update the phone number for Test Account.', email.getPlainTextBody(), 'Incorrect email body');*/