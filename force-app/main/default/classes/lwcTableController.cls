public with sharing class lwcTableController {
   @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getContacts() {
        List<Contact> conList =  [SELECT Id, firstName,lastName,Name ,Email, Phone ,Createddate from Contact];
        List<ContactWrapper> lstconWrap = new List<ContactWrapper>();
        for(contact con:conList){
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.Id = con.Id;
            conWrap.name = con.Name;
            conWrap.firstName = con.FirstName;
            conWrap.lastName = con.LastName;
            conWrap.createdDate = string.valueof(con.CreatedDate);
            conWrap.phone = con.Phone;
            conWrap.email = con.email;
            lstConWrap.add(conWrap);
        }

        return lstConWrap;
    }

    public class ContactWrapper{
        @AuraEnabled
        public string Id,firstName,lastName,name,email,phone,createdDate;
    }
}