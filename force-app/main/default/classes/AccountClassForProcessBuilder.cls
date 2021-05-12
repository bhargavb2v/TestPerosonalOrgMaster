public class AccountClassForProcessBuilder{
    @InvocableMethod(label='SendEmail')
    public static void sendEmail(List<ID> ids) {
        List<Account> accList = [SELECT Name,(select id,email from contacts limit 1) FROM Account WHERE Id in :ids];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Account acc: accList) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

            Blob attbody;
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
            
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            PageReference pdf = Page.ContactReport;
            // add parent id to the parameters for standardcontroller
            pdf.getParameters().put('id',acc.id);
            pdf.setredirect(true);
            
            if(!Test.IsRunningTest()){
                attbody = pdf.getContent();
                efa1.setFileName('test Vf Page Name.pdf');
                efa1.setBody(attbody);
                fileAttachments.add(efa1);
            }
            string htmlbody = '';
            String subject = 'Her you can set the subject of the mail';
            htmlbody = 'hi here you can set the body content which you want to sent in mail';
            email.setSubject(subject);
            email.setToAddresses(new List<string>{'pbram143@gmail.com'});
            email.setHtmlBody(htmlbody);
            email.setFileAttachments(fileAttachments);
            mails.add(email);  

        }
        
        Messaging.sendEmail(mails);
    }
}