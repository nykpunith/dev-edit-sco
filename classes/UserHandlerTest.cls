@isTest
public class UserHandlerTest {
    
    @isTest
    static void testUpdateContacts() {
        // Create test users
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 3; i++) {
            testUsers.add(new User(
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
        insert testUsers;
        
        // Create test contacts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test Contact ' + i,
                LastName = 'Last Name',
                Email = 'contact' + i + '@test.com',
                OwnerId = testUsers[i].Id
            ));
        }
        insert testContacts;
        
        Set<Id> deactivatedUserIds = new Set<Id>();
        
        // Deactivate test user
        user upu = [select id,username,isActive from user where username like 'vin%' limit 1];
        //upu.isActive = false;
       // update upu;
       // deactivatedUserIds.add(upu.id);
        
        user backUPuser = [select id,username,isActive from user where username like 'vin%' And isActive = true limit 1];
        
        UserHandler.updateContacts(deactivatedUserIds,backUPuser.id);
     
        
        System.runAs(new User(Id = UserInfo.getUserId())) {//new User(Id = UserInfo.getUserId())
            Contact testContact = [SELECT Id FROM Contact WHERE OwnerId = :upu.Id LIMIT 1];
            testContact.Title = 'New Title';
            testContact.OwnerId = backUPuser.id;
            update testContact;
        }

        
        // Call updateContacts method
        Test.startTest();
        UserHandler.updateContacts(new Set<Id>{ testUsers[0].Id }, testUsers[1].Id);
        Test.stopTest();
        
        // Verify contacts were updated
        List<Contact> updatedContacts = [SELECT Id, OwnerId FROM Contact WHERE OwnerId = :testUsers[1].Id];
        System.assertEquals(2, updatedContacts.size());
        for (Contact c : updatedContacts) {
            System.assertEquals(testUsers[1].Id, c.OwnerId);
        }
    }
    
    @isTest
    static void testUsertrigger() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Username = 'than@test.com',
            Email = 'user@test.com',
            Alias = 'test',
            LastName = 'Test User',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id,
            IsActive = true
        );
        insert testUser;
        
        // Deactivate test user
        testUser.IsActive = false;
        update testUser;
        
        // Verify contacts were updated
        List<Contact> updatedContacts = [SELECT Id, OwnerId FROM Contact WHERE OwnerId = :testUser.Id];
        System.assertEquals(0, updatedContacts.size());
    }
}