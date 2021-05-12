public class SendVF_Email_InvocableMethod {

    public  Account account { get; set; }

    public SendVF_Email_InvocableMethod() {
           account = [SELECT Name,Owner.name,(SELECT Contact.Name, Contact.Email FROM Account.Contacts) FROM Account
                                                               WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
    

/////*************************Used this method for Process builder************//////////////

    @InvocableMethod(label='Get Account Names')
    public static void sendEmail(List<Id> lstId){
    
     String addresses;
    PageReference ref = Page.attachments1;
       
       //ref.getParameters().put('id',(String)account.id);
       //ref.setRedirect(true);

        Blob b = ref.getContent();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();

        efa1.setFileName('attachment_WORK.pdf');

        efa1.setBody(b);
        
        
        
       /* if (account.Contacts[0].Email != null) {

            addresses = account.Contacts[0].Email;

            // Loop through the whole list of contacts and their emails

            for (Integer i = 1; i < account.Contacts.size(); i++) {

                if (account.Contacts[i].Email != null) {

                    addresses += ':' + account.Contacts[i].Email;

                }

            }

        }*/
        
    List<String> EmailIds = 'tanujapawan@gmail.com'.split(',');     
        
        
        //String[] toAddresses = addresses.split(':', 0);

        email.setSubject( 'Check VF From PB' +String.valueOf(DateTime.now()));

        email.setToAddresses( EmailIds   );

        email.setPlainTextBody('Hey there, I am an email Body');

        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

    }
    
    
 }