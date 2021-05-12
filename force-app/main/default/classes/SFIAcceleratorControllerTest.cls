@isTest
Public class SFIAcceleratorControllerTest{
    static testMethod void getObjectInformationTest1() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();

            SFIAcceleratorController.getObjectInformation('Both');
            Test.stopTest();
        }
    }
    static testMethod void getObjectInformationTest2() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();

            SFIAcceleratorController.getObjectInformation('Standard Object');
            Test.stopTest();
        }
    }
    
    static testMethod void getObjectInformationTest3() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();

            SFIAcceleratorController.getObjectInformation('Custom Object');
            Test.stopTest();
        }
    }
    
    static testMethod void getFieldInformationTest1(){
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.getFieldInformation('Both','All');
            Test.stopTest();
        }
    }
    
    static testMethod void getFieldInformationTest2(){
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.getFieldInformation('Standard Object','All');

            Test.stopTest();
        }
    }
    
    static testMethod void getFieldInformationTest3(){
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.getFieldInformation('Custom Object','All');

            Test.stopTest();
        }
    }
    
    static testMethod void getFieldInformationTest4(){
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.getFieldInformation('Both','Account');

            Test.stopTest();
        }
    }
    
    static testMethod void runAcceleratorTest1() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.accInputWrapper aI = new SFIAcceleratorController.accInputWrapper();
            aI.selectedDataType = 'Email';
            aI.other = 'Date,Name';
            aI.objType = 'Both';
            aI.sObj = 'All';
            SFIAcceleratorController.runAccelerator(aI);
            
            Test.stopTest();
        }
    }
    
    static testMethod void runAcceleratorTest2() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.accInputWrapper aI = new SFIAcceleratorController.accInputWrapper();
            aI.selectedDataType = 'Email';
            aI.other = 'Date,Name';
            aI.objType = 'Standard Object';
            aI.sObj = 'All';
            SFIAcceleratorController.runAccelerator(aI);
            
            Test.stopTest();
        }
    }
    
    static testMethod void runAcceleratorTest3() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.accInputWrapper aI = new SFIAcceleratorController.accInputWrapper();
            aI.selectedDataType = 'Email';
            aI.other = 'Date,Name';
            aI.objType = 'Custom Object';
            aI.sObj = 'All';
            SFIAcceleratorController.runAccelerator(aI);
            
            Test.stopTest();
        }
    }

    static testMethod void runAcceleratorTest4() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.accInputWrapper aI = new SFIAcceleratorController.accInputWrapper();
            aI.selectedDataType = 'Email';
            aI.other = 'Date,Name';
            aI.objType = 'Both';
            aI.sObj = 'Account';
            SFIAcceleratorController.runAccelerator(aI);
            
            Test.stopTest();
        }
    }
    
    static testMethod void saveDataTest() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.dataWrapper dw = new SFIAcceleratorController.dataWrapper();
            dw.fName = 'testFieldName';
            dw.objName = 'testObjectName';
            dw.isSensitive = 'true';
            dw.comments = 'test';
    
            SFIAcceleratorController.saveData(new List<SFIAcceleratorController.dataWrapper>{dw});
            SFIAcceleratorController.saveAndSendEmailData(new List<SFIAcceleratorController.dataWrapper>{dw},'abcTest@gmail.com','test Name');
            Test.stopTest();
        }
    }
    
    static testMethod void exportToXLTest1() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.exportToXL('Both','All');
            
            Test.stopTest();
        }
    }
    
    
    static testMethod void exportToXLTest2() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.exportToXL('Standard Object','All');
            
            Test.stopTest();
        }
    }
    
    static testMethod void exportToXLTest3() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.exportToXL('Custom Object','All');
            
            Test.stopTest();
        }
    }
    
    static testMethod void exportToXLTest4() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.exportToXL('Both','Account');
            
            Test.stopTest();
        }
    }
    
    static testMethod void exportToXLClientTest1() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.exportToXLClient('Both','All');
            
            Test.stopTest();
        }
    }
    
    
    static testMethod void exportToXLClientTest2() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            sftList[0].is_sensitive__c = false;
            insert sftList;
            
            SFIAcceleratorController sac = new SFIAcceleratorController();
            SFIAcceleratorController.exportToXLClient('Standard Object','All');
            
            Test.stopTest();
        }
    }
    
    static testMethod void exportToXLClientTest3() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.exportToXLClient('Custom Object','All');
            
            Test.stopTest();
        }
    }
    
    static testMethod void exportToXLClientTest4() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();
            List<Sensitive_Field_Tracker__c> sftList = createSFTData();
            insert sftList;

            SFIAcceleratorController.exportToXLClient('Both','Account');
            
            Test.stopTest();
        }
    }
    
    static testMethod void RefListTest() {
        Profile p=[select id from profile where name='System Administrator' limit 1];
        User u = createUser(p.id);
        system.runAs(u){
            Test.startTest();

            SFIAcceleratorController.getRefList('Class');
            SFIAcceleratorController.getRefList('Page');
            SFIAcceleratorController.getRefList('Trigger');
            SFIAcceleratorController.getRefList('Component');
            
            Test.stopTest();
        }
    }

     // Creates a Test User with a given Profile
    public static User createUser(Id profileId) {
        return new User(
            FirstName = 'Test eCRF User',
            LastName = 'Lastname',
            Email = 'testECRF@ECRF.com',
            Username = 'testECRF@ECRF.com',
            ProfileId = profileId,
            Alias = 'weki',
            CommunityNickname = 'wikk',
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US'
        );
    }
    
    public static List<Sensitive_Field_Tracker__c> createSFTData(){
        List<Sensitive_Field_Tracker__c> sftList = new List<Sensitive_Field_Tracker__c>();
                                                                                        
        Sensitive_Field_Tracker__c sft1 = new Sensitive_Field_Tracker__c();
        sft1.field_name__c = 'Name';
        sft1.object_name__c = 'Account';
        sft1.is_sensitive__c = true;
        sft1.Field_Object__c = sft1.field_name__c+''+sft1.object_name__c;
        
        Sensitive_Field_Tracker__c sft2 = new Sensitive_Field_Tracker__c();
        sft2.field_name__c = 'Name';
        sft2.object_name__c = 'Sensitive_Field_Tracker__c';
        sft2.is_sensitive__c = false;
        sft2.Field_Object__c = sft2.field_name__c+''+sft2.object_name__c;
        
        sftList.add(sft1);
        sftList.add(sft2);
        
        return sftList;                                                    
    }
}