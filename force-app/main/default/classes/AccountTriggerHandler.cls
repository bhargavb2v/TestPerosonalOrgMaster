public class AccountTriggerHandler{
    public AccountTriggerHandler(){
    
    }
    
    public void onAfterInsert(List<Account> newAccList){
    
    
    }
    
    @InvocableMethod
    public static void sendEmail(){
    
    }
    
    
    public void onAfterUpdate(List<Account> newAccList,Map<id,Account> oldAccMap){
        List<Account> accList = [Select id,owner.Name,(select id,name,email from contacts limit 1) from account 
                                                                                                    where Id in :newAccList];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Account acc : accList){
            Contact con = acc.contacts != null && !acc.contacts.isEmpty() ? acc.contacts[0] : null;
            if(con != null && con.email != null && con.email != ''){               
                /*PageReference pdf = Page.attachments1;
                pdf.getParameters().put('id',acc.id);
                pdf.setRedirect(true);
                Blob b = pdf.getContent();*/
                
                string pdfContent = '<H2>Account Information in PDF</H2>';
                Blob bb = Blob.toPDF(pdfContent);
                
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('attachment.pdf');
                efa.setBody(bb);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Check VF From PB' +String.valueOf(DateTime.now()));
                List<string> toAddressList = new String[] {con.email};
                email.setToAddresses(toAddressList);
                
                String emailBody = 'Hi '+con.Name+',<br/><br/>'+'Please find the attached PDF.<br/><br/><br/>Regards,<br/>Salesforce Support';
                email.setHtmlBody(emailBody);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                
                emailList.add(email); 
            }
        } 
        
        if(emailList != null && !emailList.isEmpty()){
            // Send it
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);
        } 
    }
}