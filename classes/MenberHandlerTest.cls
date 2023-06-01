@isTest
public class MenberHandlerTest {
    
    @isTest
    private static void createContact(){
        Account a = new Account(name = '4ce');
        insert a;
        
        User newUser = new User();
        newUser.FirstName = 'John';
        newUser.LastName = 'Doe';
        newUser.Email = 'john.doe@example.com';
        newUser.Username = 'check@contact.com';
        newUser.Alias = 'johndoe';
        newUser.CommunityNickname = 'johndoe';
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.ProfileId = '00e5i000000aCMD'; //standerd user
        newUser.IsActive = true;
        
        insert newUser;
        
        List<Members__c> newMember = new List<members__c>();
        for(integer i=1;i<=3;i++){
            Members__c nm = new Members__c();
            nm.name = 'Ryzen '+i;
            nm.Account__c = a.id;
            nm.Manager__c = newuser.id;
            newMember.add(nm);   
        }
        insert newMember;
        Test.startTest();
        MemberHandler.CreateContact(newMember);
        Test.stopTest();
        List<contact> memberCon = [select id,LastName,Account.id from contact where id = : a.id];
        
        //system.assertEquals(6, membercon.size());
        for(contact c : memberCon){
            system.assertEquals(newUser.name, c.lastName);
            system.assertEquals(a.id, c.AccountId);
        }
    }
}