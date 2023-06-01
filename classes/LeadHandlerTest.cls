@isTest
public class LeadHandlerTest {
    
    @isTest
    static void testUpdateDescription() {
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'will', Status = 'Open - Not Contacted', Phone = '555-555-5555', Email = 'nykpunithns6553@gmail.com',company='4ce');
        Lead lead2 = new Lead(FirstName = 'Jane', LastName = 'Doe', Status = 'Open - Not Contacted', Phone = '555-555-5555',company='4ce');
        List<Lead> leadList = new List<Lead>{lead1, lead2};
            test.startTest();
        insert leadList;
        LeadHandler.updateDescription(leadList);
        test.stopTest();
        System.assertEquals('Ready to be contacted', lead1.Description);
        System.assertEquals('Not Ready to be contacted', lead2.Description);
        
        lead L1 = [select id,LastName,phone,status from Lead where LastName = 'will' limit 1];
        l1.Status = 'Working - Contacted';
        update L1;
        
        LeadHandler.updateDescription(leadList);
        
        System.assertEquals('Ready to be contacted', lead1.Description);
        
        
        lead L2 = [select id,LastName,phone,email from Lead where LastName = 'Doe' limit 1];
        l2.Email = 'puni@gmail.com';
        L2.Phone=null;
        update L2;
        
        LeadHandler.updateDescription(leadList);
        
        System.assertEquals('Not Ready to be contacted', lead2.Description);
        
        lead L3 = [select id,LastName,phone,email,status from Lead where LastName = 'Doe' limit 1];
        L2.Phone='580242141';
        L3.Email =null;
        update L3;
        
        LeadHandler.updateDescription(leadList);
        
        System.assertEquals('Not Ready to be contacted', lead2.Description);
        
        lead L4 = [select id,LastName,phone,email,status from Lead where LastName = 'Doe' limit 1];
        L4.Phone=null;
        
        update L4;
        
        LeadHandler.updateDescription(leadList);
        
        System.assertEquals('Not Ready to be contacted', lead2.Description);
    }
    
    @isTest
    static void testUpdateRating() {
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'will', LeadSource = 'Web',Status = 'Open - Not Contacted',company='4ce');
        Lead lead2 = new Lead(FirstName = 'Jane', LastName = 'Doe', LeadSource = 'Phone Inquiry',Status = 'Open - Not Contacted',company='4ce');
        List<Lead> leadList = new List<Lead>{lead1, lead2};
            test.startTest();
        insert leadList;
        
        LeadHandler.updateRating(leadList);
        test.stopTest();
        System.assertEquals('Cold', lead1.Rating);
        System.assertEquals('Hot', lead2.Rating);
        
    }
    
    @isTest
    static void testSendAttachment() {
        Lead lead1 = new Lead(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        List<Lead> leadList = new List<Lead>{lead1};
            Test.startTest();
        LeadHandler.sendAttachment(leadList);
        Test.stopTest();
        // List<Messaging.SentEmail> sentEmails = [SELECT Id, Subject, ToAddress, HtmlBody, TextBody, ActivityId FROM SentEmail];
        List<Messaging.SingleEmailMessage> emails = new  List<Messaging.SingleEmailMessage>();
        System.assertEquals(1, emails.size());
        Messaging.SingleEmailMessage email = emails[0];
        System.assertEquals(lead1.Email, email.getToAddresses()[0]);
        System.assertEquals('Salesforce support', email.getSenderDisplayName());
        System.assertEquals('Welcome', email.getSubject());
        System.assertEquals('<p>Please click <a href="https://forcecloudlabs4-dev-ed.develop.my.salesforce.com/sfc/p/5i00000BXWc2/a/5i000000gg0q/4JHo3KWEIRknEBkGgnLhUjJJhRwuZ2pK9NqPw7BZX7A">here</a> to view the document.</p>', email.getHtmlBody());
        System.assertEquals('Please find the attached PDF and link', email.getPlainTextBody());
        List<Messaging.EmailFileAttachment> attachments = email.getFileAttachments();
        System.assertEquals(1, attachments.size());
        Messaging.EmailFileAttachment attachment = attachments[0];
        System.assertEquals('application/pdf', attachment.getContentType());
        System.assertEquals('Welcome.pdf', attachment.getFileName());
    }
}   
    
    
    
    /*
@isTest
static void testSendAttachment1() {
Lead l1 = new Lead(Email='test1@example.com');
Lead l2 = new Lead(Email='test2@example.com');

insert new List<Lead>{l1, l2};

List<Lead> leadList = new List<Lead>{l1, l2};
LeadHandler.sendAttachment(leadList);

//System.assertEquals(2, Messaging.sendEmail(new Messaging.SingleEmailMessage[]{}));
}*/