public class SFIAcceleratorController {
    
    public SFIAcceleratorController(){
        
    }
    
    //To fetch availble objects in organisation based on selection(Custom/Standard/All) on the page
   @RemoteAction
    public static result getObjectInformation(string objType) {
        //Fetching objects info
        List<Schema.SObjectType> gdList = Schema.getGlobalDescribe().Values();
        Map<String,String> sObjMap = new Map<String,String>();
        set<string> nonSobjectSet = getNonSObjects();
        
        for(Schema.SObjectType gd : gdList){
            //Filtering the objects which are not originally objects
            if(gd.getDescribe().isUpdateable() && gd.getDescribe().isQueryable() 
                                                   && !gd.getDescribe().isCustomSetting() 
                                                   && !nonSobjectSet.contains(gd.getDescribe().getName())){
                if(objType == 'Both'){  // When user selects the both                             
                    if(!gd.getDescribe().isCustom() && gd.getDescribe().isMruEnabled()){                               
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                    }
                    else if(gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                    }
                }
                else if(objType == 'Standard Object' ){ // When user selects the standard object
                    if(gd.getDescribe().isMruEnabled() && !gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                    }
                }
                else if(objType == 'Custom Object'){ // When user selects the custom object
                    if(gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel() +' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                    }
                }
            }
        }
        
        //Creating wrapper class to send the object list to page
        result res = new result();
        res.sObjMap = sObjMap;
        
        List<String> sList = new List<String>();
        sList.add('Select');
        if(sObjMap.keyset().size() > 1){
            sList.add('All');
        }
        List<String> sObjTemp = new List<String>();
        sObjTemp.addAll(sObjMap.keyset());
        sObjTemp.sort();
        sList.addAll(sObjTemp);
        res.sObjList = sList;
        res.dataTypeList = getDataTypes();
        
        return res;
    }
    
    //To fetch the fields based on the object selection(All,pariticular object) from the page
    @RemoteAction
    public static List<fieldWrapper> getFieldInformation(string objType,string sObj) {
        //Fetching saved sensitive information from the custom object
        List<Sensitive_Field_Tracker__c> sftList = [select id,field_name__c,object_name__c,is_sensitive__c,comments__c,LastModifiedBy.Name 
                                                                                        from Sensitive_Field_Tracker__c];
        Map<string,Sensitive_Field_Tracker__c> sftMap = new Map<string,Sensitive_Field_Tracker__c>();
        //Preparing map to get the sensitive field info
        for(Sensitive_Field_Tracker__c sft:sftList){
            string key = sft.field_name__c+''+sft.object_name__c;
            sftMap.put(key,sft);
        }
        
        //Fetching apex class, components, vf pages and triggers to identify field reference
        componentWrapper cw = new componentWrapper();
        cw.lstClasses = [select Name, Body from ApexClass];
        cw.lstPage = [select Name, Markup from ApexPage];
        cw.lstComponent = [select Name, Markup from ApexComponent];
        cw.lstTrigger = [select Name, Body from ApexTrigger];
        
        //Fetching objects
        Map<String,Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Map<String,String> sObjMap = new Map<String,String>();
        List<fieldWrapper> lfList = new List<FieldWrapper>();
        set<string> nonSobjectSet = getNonSObjects();
        
        if(sObj == 'All'){
            for(Schema.SObjectType gd : gdMap.Values()){
                //Filetering objects
                if(gd.getDescribe().isUpdateable() && gd.getDescribe().isQueryable() 
                                                   && !gd.getDescribe().isCustomSetting() 
                                                   && !nonSobjectSet.contains(gd.getDescribe().getName())){                                  
                    if(objType == 'Both'){
                        if(!gd.getDescribe().isCustom() && gd.getDescribe().isMruEnabled()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                        }
                        else if(gd.getDescribe().isCustom()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                        }
                    } 
                    else if(objType == 'Standard Object' && gd.getDescribe().isMruEnabled() 
                                                            && !gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                    }
                    else if(objType == 'Custom Object' && gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                    }
                }
            }
        }
        else{
            //Calling method : assignFieldsToWrapper
            lfList = assignFieldsToWrapper(gdMap,null,sObj,null,sftMap,cw);
        }
        return lfList;
    }
    
    //To identify sensitive fields based on data type and custom label
    @RemoteAction
    public static List<fieldWrapper> runAccelerator(accInputWrapper accWrapper) {
        //Fetching sensitive field info from custom object
        List<Sensitive_Field_Tracker__c> sftList = [select id,field_name__c,object_name__c,is_sensitive__c,comments__c,LastModifiedBy.Name
                                                                            from Sensitive_Field_Tracker__c];
        Map<string,Sensitive_Field_Tracker__c> sftMap = new Map<string,Sensitive_Field_Tracker__c>();
        for(Sensitive_Field_Tracker__c sft:sftList){
            string key = sft.field_name__c+''+sft.object_name__c;
            sftMap.put(key,sft);
        }
        
        //Fetching apex class, components, vf pages and triggers to identify field reference
        componentWrapper cw = new componentWrapper();
        cw.lstClasses = [select Name, Body from ApexClass];
        cw.lstPage = [select Name, Markup from ApexPage];
        cw.lstComponent = [select Name, Markup from ApexComponent];
        cw.lstTrigger = [select Name, Body from ApexTrigger];
        
        Map<String,Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Map<String,String> sObjMap = new Map<String,String>();
        List<fieldWrapper> lfList = new List<FieldWrapper>();
        set<string> nonSobjectSet = getNonSObjects();
        
        if(accWrapper.sObj == 'All'){
            for(Schema.SObjectType gd : gdMap.Values()){
                //Filtering the objects which are not originally objects
                if(gd.getDescribe().isUpdateable() && gd.getDescribe().isQueryable() 
                                                   && !gd.getDescribe().isCustomSetting() 
                                                   && !nonSobjectSet.contains(gd.getDescribe().getName())){                                  
                    if(accWrapper.objType == 'Both'){
                        if(!gd.getDescribe().isCustom() && gd.getDescribe().isMruEnabled()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,accWrapper,sftMap,cw));
                        }
                        else if(gd.getDescribe().isCustom()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,accWrapper,sftMap,cw));
                        }
                    } 
                    else if(accWrapper.objType == 'Standard Object' 
                                            && gd.getDescribe().isMruEnabled() 
                                            && !gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,accWrapper,sftMap,cw));
                    }
                    else if(accWrapper.objType == 'Custom Object' && gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,accWrapper,sftMap,cw));
                    }
                }
            }
        }
        else{
            //Calling method : assignFieldsToWrapper
            lfList = assignFieldsToWrapper(gdMap,null,accWrapper.sObj,accWrapper,sftMap,cw);
        }
        return lfList;
    }
    
    
    
    public static List<fieldWrapper> assignFieldsToWrapper(Map<String,Schema.SObjectType> gdMap,Schema.SObjectType gd,
                                                                    string obj,accInputWrapper accWrapper,
                                                                    Map<string,Sensitive_Field_Tracker__c> sftMap,
                                                                    componentWrapper cw){
        List<fieldWrapper> lfList = new List<FieldWrapper>();
        Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();
        String objLabel;
        String objApi;
        //Fetching field atributes from the describeresult
        if(obj != null){
            fieldMap = gdMap.get(obj).getDescribe().fields.getMap();
            
            objLabel = gdMap.get(obj).getDescribe().getLabel();
            objApi = gdMap.get(obj).getDescribe().getName();
        }
        else{
            fieldMap = gd.getDescribe().fields.getMap();
            
            objLabel = gd.getDescribe().getLabel();
            objApi = gd.getDescribe().getName();
        }
        
        //Assigning field attributes to the wrapper class
        for (String fieldName: fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()){
                fWrapper f = new fWrapper();
                f.objLabel = objLabel;
                f.objApi = objApi;
                f.fLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                f.fApi = fieldMap.get(fieldName).getDescribe().getName();
                string dType = string.valueof(fieldMap.get(fieldName).getDescribe().getType());
                //If it is string data type, changing to text
                if(dType.equalsIgnoreCase('STRING')){
                    f.fDataType = 'Text'+ '('+string.valueof(fieldMap.get(fieldName).getDescribe().getLength())+')';    
                }
                else if(dType.equalsIgnoreCase('TEXTAREA')){
                    f.fDataType = dType + '('+string.valueof(fieldMap.get(fieldName).getDescribe().getLength())+')';    
                }
                else{
                    f.fDataType = string.valueof(fieldMap.get(fieldName).getDescribe().getType());
                }
                f.isEncrypted = boolean.valueof(fieldMap.get(fieldName).getDescribe().isEncrypted());
                string key = f.fApi+''+f.objApi;
                f.isSensitive = f.isEncrypted;
                //Checking with custom object to fetch the last update
                if(sftMap != null && sftMap.containsKey(key)){
                    if(f.isSensitive || sftMap.get(key).is_sensitive__c){
                        f.isSensitive = true;
                    }
                    else{
                        f.isSensitive = accWrapper != null ? isSensitive(f.fLabel,f.fDataType,accWrapper): false;
                    }

                    f.comments = sftMap.get(key).comments__c;
                    f.LastModifiedBy = sftMap.get(key).LastModifiedBy.Name;
                }
                else if(!f.isSensitive){
                    f.isSensitive = accWrapper != null ? isSensitive(f.fLabel,f.fDataType,accWrapper): false;
                }
                
                fieldWrapper fieldW = new fieldWrapper();
                fieldW.fw = f;
                fieldW.isUsed = hasReferences(f.fApi,cw);
                
                lfList.add(fieldW);
            }
        }
        return lfList;
    }
    
    //To identify sensitve field
     public static boolean isSensitive(string fLabel,string fDataType,accInputWrapper accWrapper){
        List<String> dList = accWrapper.selectedDataType != null ? accWrapper.selectedDataType.split(',') : null;
        List<String> otherList = accWrapper.other != null ? accWrapper.other.split(',') : null;
        Boolean isS = false;
        Set<String> dSet = new Set<String>();
        if(dList != null && dList.size() > 0){
            dSet.addAll(dList);
            if(dSet.contains(fDataType)){
                isS = true;
                return isS;
            }
        }
        
        if(otherList != null && otherList.size() > 0){
            for(String o:otherList){
                if(fLabel.containsIgnoreCase(o.trim())){
                    isS = true;
                    break;
                }
            }
        }

        return isS;
    }
    
    //To identify field reference
    public static boolean hasReferences(string fieldName,componentWrapper cw){
        Boolean bRet = false;
        for(ApexClass cls:cw.lstClasses){
            if(cls.body.containsIgnoreCase(fieldName)){
                bRet = true;
                break;
            }
        }

        if(!bRet){
            for(ApexPage pg:cw.lstPage ){
                if(pg.Markup.containsIgnoreCase(fieldName)){
                    bRet = true;
                   break;
                }
            }
        }

        if(!bRet){
            for(ApexTrigger trg:cw.lstTrigger){
                if(trg.Body.containsIgnoreCase(fieldName)){
                    bRet = true;
                   break;
                }
            }
        }

        if(!bRet){
            for(ApexComponent com:cw.lstComponent ){
                if(com.Markup.containsIgnoreCase(fieldName)){
                    bRet = true;
                    break;
                }
            }
        }

        return bRet;
    }
    
    //To fetch referenced classes, pages, components and trigger
     @RemoteAction
    public static List<refWrapper> getRefList(string fieldName) {
        List<ApexClass> lstClasses = [select Name, Body from ApexClass];
        List<ApexPage> lstPage = [select Name, Markup from ApexPage];
        List<ApexComponent> lstComponent = [select Name, Markup from ApexComponent];
        List<ApexTrigger> lstTrigger = [select Name, Body from ApexTrigger];
        
        List<refWrapper> refList = new List<refWrapper>();
        //Apex classes
        for(ApexClass cls:lstClasses){
            if(cls.body.containsIgnoreCase(fieldName)){
                refWrapper rw = new refWrapper();
                rw.name = cls.Name;
                rw.type = 'Apex Class';
                
                refList.add(rw);
            }
        }

        //VF pages
        for(ApexPage pg:lstPage ){
            if(pg.Markup.containsIgnoreCase(fieldName)){
                refWrapper rw = new refWrapper();
                rw.name = pg.Name;
                rw.type = 'Visualforce Page';
                
                refList.add(rw);
            }
        }
        
        //Trigger
        for(ApexTrigger trg:lstTrigger){
            if(trg.Body.containsIgnoreCase(fieldName)){
                refWrapper rw = new refWrapper();
                rw.name = trg.Name;
                rw.type = 'Apex Trigger';
                
                refList.add(rw);
            }
        }
        
        //Components
        for(ApexComponent com:lstComponent ){
            if(com.Markup.containsIgnoreCase(fieldName)){
                refWrapper rw = new refWrapper();
                rw.name = com.Name;
                rw.type = 'Visualforce Component';
                
                refList.add(rw);
            }
        }
        
        return refList;
    }
    
    //Data types to idenentiy sensitve fields
    public static List<string> getDataTypes(){
        List<String> strVals = new List<String>();
        strVals.add('DATE');
        strVals.add('DATETIME');
        strVals.add('EMAIL');
        strVals.add('PHONE');
        strVals.add('Other');
        
        return strVals;
    }
    
    //To save the sensitive data to maintain the history
    @RemoteAction
    public static void saveData(List<dataWrapper> dwList) {
        List<Sensitive_Field_Tracker__c> sftList = new List<Sensitive_Field_Tracker__c>();
        for(dataWrapper dw:dwList){
            Sensitive_Field_Tracker__c sft = new Sensitive_Field_Tracker__c();
            sft.Field_Name__c = dw.fName;
            sft.Object_Name__c = dw.objName;
            sft.Is_Sensitive__c = boolean.valueof(dw.isSensitive);
            sft.Field_Object__c = sft.Field_Name__c+''+sft.Object_Name__c;
            sft.comments__c = dw.comments;
            
            sftList.add(sft);
        }
        
        if(sftList.size() > 0){
            upsert sftList Field_Object__c;
        }
    }
    
    //To save the data and send email to particular user which was provided on the page
    @RemoteAction
    public static void saveAndSendEmailData(List<dataWrapper> dwList,string email,string name) {
        List<Sensitive_Field_Tracker__c> sftList = new List<Sensitive_Field_Tracker__c>();
        for(dataWrapper dw:dwList){
            Sensitive_Field_Tracker__c sft = new Sensitive_Field_Tracker__c();
            sft.Field_Name__c = dw.fName;
            sft.Object_Name__c = dw.objName;
            sft.Is_Sensitive__c = boolean.valueof(dw.isSensitive);
            sft.Field_Object__c = sft.Field_Name__c+''+sft.Object_Name__c;
            sft.comments__c = dw.comments;
            
            sftList.add(sft);
        }
        
        if(sftList.size() > 0){
            upsert sftList Field_Object__c;  
        }
        sendEmailNotification(email,name); 
    }
    
    //Email notification method
    public static boolean sendEmailNotification(string email,string name){
        //Email template
        EmailTemplate et=[Select id, htmlValue, Body, subject from EmailTemplate where DeveloperName = 'EmailNotification' limit 1];
        String htmlBody = et.HtmlValue;

        htmlBody = htmlBody.replace('<Full Name>', name);
        string ahref = '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/sfdcschemaTracker">'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/sfdcschemaTracker</a>';
        htmlBody = htmlBody.replace('<URL>', ahref);
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        //Single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new List<string>{email});  
        mail.setSubject(et.subject);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
    
        boolean isSuccess = false;
        if(mails.size() > 0 ) {
            //Sending email
            Messaging.SendEmailResult[] r = Messaging.sendEmail(mails);
            isSuccess = r[0].IsSuccess();
        }
        
        return isSuccess;
    }
    
    //To generate a report for the  identifier page
    @RemoteAction
    public static string exportToXL(string objType,string sObj) {
        List<Sensitive_Field_Tracker__c> sftList = [select id,field_name__c,object_name__c,is_sensitive__c,comments__c,LastModifiedBy.Name
                                                                                        from Sensitive_Field_Tracker__c];
        Map<string,Sensitive_Field_Tracker__c> sftMap = new Map<string,Sensitive_Field_Tracker__c>();
        for(Sensitive_Field_Tracker__c sft:sftList){
            string key = sft.field_name__c+''+sft.object_name__c;
            sftMap.put(key,sft);
        }
        
        //Fetching apex class, components, vf pages and triggers to identify field reference
        componentWrapper cw = new componentWrapper();
        cw.lstClasses = [select Name, Body from ApexClass];
        cw.lstPage = [select Name, Markup from ApexPage];
        cw.lstComponent = [select Name, Markup from ApexComponent];
        cw.lstTrigger = [select Name, Body from ApexTrigger];
        
        Map<String,Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Map<String,String> sObjMap = new Map<String,String>();
        List<fieldWrapper> lfList = new List<fieldWrapper>();
        set<string> nonSobjectSet = getNonSObjects();
        
        if(sObj == 'All'){
            for(Schema.SObjectType gd : gdMap.Values()){
                //Filtering the objects which are not originally objects
                if(gd.getDescribe().isUpdateable() && gd.getDescribe().isQueryable() 
                                                   && !gd.getDescribe().isCustomSetting()  
                                                   && !nonSobjectSet.contains(gd.getDescribe().getName())){                                  
                    if(objType == 'Both'){
                        if(!gd.getDescribe().isCustom() && gd.getDescribe().isMruEnabled()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                        }
                        else if(gd.getDescribe().isCustom()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                        }
                    } 
                    else if(objType == 'Standard Object' && gd.getDescribe().isMruEnabled() 
                                                         && !gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                    }
                    else if(objType == 'Custom Object' && gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName()); 
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                    }
                }
            }
        }
        else{
            lfList = assignFieldsToWrapper(gdMap,null,sObj,null,sftMap,cw);
        }
        
        String finalReport = generateXLReport(lfList);
        
       
        return finalReport;
    }
    
   
       //To generate a report to excel format
       public static string generateXLReport(List<fieldWrapper> lfList){
       
        string header = 'Object Name \t Field Name \t Field API \t Data Type \t Is Encrypted?\t Is Referenced? \t Is Sensitive Field? \t Comments \t LastModifiedBy\n';
        string finalstr = header;
        
        for(fieldWrapper rslt: lfList){
            string recordString = '';
                
            recordString += (rslt.fw.objLabel != null && rslt.fw.objLabel != '') ? rslt.fw.objLabel+'\t' : '\t';
            recordString += (rslt.fw.fLabel != null && rslt.fw.fLabel != '') ? rslt.fw.fLabel+'\t' : '\t';
            recordString += (rslt.fw.fApi != null && rslt.fw.fApi != '') ? rslt.fw.fApi +'\t' : '\t';
            recordString += (rslt.fw.fDataType != null && rslt.fw.fDataType != '') ? rslt.fw.fDataType +'\t' : '\t';
            recordString += (rslt.fw.isEncrypted ? 'Yes' : 'No') +'\t';   
            recordString += (rslt.isUsed ? 'Yes':'No') +'\t';
            recordString += (rslt.fw.isSensitive ? 'Yes':'No') +'\t'; 
            recordString += (rslt.fw.comments != null && rslt.fw.comments != '') ? rslt.fw.comments +'\t' : '\t';
            recordString += (rslt.fw.LastModifiedBy != null && rslt.fw.LastModifiedBy != '') ? rslt.fw.LastModifiedBy+'\t' : '\t';

            recordString+='\n';
            
            finalstr = finalstr +recordString;
        }

        return finalstr;
    } 
    
      //To generate a report for the validator page
     @RemoteAction
    public static string exportToXLClient(string objType,string sObj) {
        List<Sensitive_Field_Tracker__c> sftList = [select id,field_name__c,object_name__c,is_sensitive__c,comments__c,LastModifiedBy.Name 
                                                                                        from Sensitive_Field_Tracker__c];
        Map<string,Sensitive_Field_Tracker__c> sftMap = new Map<string,Sensitive_Field_Tracker__c>();
        for(Sensitive_Field_Tracker__c sft:sftList){
            string key = sft.field_name__c+''+sft.object_name__c;
            sftMap.put(key,sft);
        }
        
        //Fetching apex class, components, vf pages and triggers to identify field reference
        componentWrapper cw = new componentWrapper();
        cw.lstClasses = [select Name, Body from ApexClass];
        cw.lstPage = [select Name, Markup from ApexPage];
        cw.lstComponent = [select Name, Markup from ApexComponent];
        cw.lstTrigger = [select Name, Body from ApexTrigger];
        
        Map<String,Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Map<String,String> sObjMap = new Map<String,String>();
        List<fieldWrapper> lfList = new List<fieldWrapper>();
        set<string> nonSobjectSet = getNonSObjects();
        
        if(sObj == 'All'){
            for(Schema.SObjectType gd : gdMap.Values()){
                //Filtering the objects which are not originally objects
                if(gd.getDescribe().isUpdateable() && gd.getDescribe().isQueryable() 
                                                   && !gd.getDescribe().isCustomSetting() 
                                                   && !nonSobjectSet.contains(gd.getDescribe().getName())){                                  
                    if(objType == 'Both'){
                        if(!gd.getDescribe().isCustom() && gd.getDescribe().isMruEnabled()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                        }
                        else if(gd.getDescribe().isCustom()){
                            sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                            //Calling method : assignFieldsToWrapper
                            lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                        }
                    } 
                    else if(objType == 'Standard Object' && gd.getDescribe().isMruEnabled() 
                                                         && !gd.getDescribe().isCustom()){
                        sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                    }
                    else if(objType == 'Custom Object' && gd.getDescribe().isCustom()){
                         sObjMap.put(gd.getDescribe().getLabel()+' ('+gd.getDescribe().getName()+')',gd.getDescribe().getName());
                        //Calling method : assignFieldsToWrapper
                        lfList.addAll(assignFieldsToWrapper(gdMap,gd,null,null,sftMap,cw));
                    }
                }
            }
        }
        else{
            //Calling method : assignFieldsToWrapper
            lfList = assignFieldsToWrapper(gdMap,null,sObj,null,sftMap,cw);
        }
        String finalReport = generateXLReportClient(lfList);
        
        return finalReport;
    }
    
       //To generate a report in excel format
       public static string generateXLReportClient(List<fieldWrapper> lfList){
       
        string header = 'Object Name\t Field Name \t Is Encrypted? \t Is Sensitive Field? \t Comments \t LastModifiedBy\n';
        string finalstr = header;
        
        for(fieldWrapper rslt: lfList){
            string recordString = '';
                
            recordString += (rslt.fw.objLabel != null && rslt.fw.objLabel != '') ? rslt.fw.objLabel+'\t' : '\t';
            recordString += (rslt.fw.fLabel != null && rslt.fw.fLabel != '') ? rslt.fw.fLabel+'\t' : '\t';
            recordString += (rslt.fw.isEncrypted ? 'Yes' : 'No') +'\t';
            recordString += (rslt.fw.isSensitive ? 'Yes':'No') +'\t';
            recordString += (rslt.fw.comments != null && rslt.fw.comments != '') ? recordString += rslt.fw.comments+'\t' : '\t';   
            recordString += (rslt.fw.LastModifiedBy != null && rslt.fw.LastModifiedBy != '') ? rslt.fw.LastModifiedBy+'\t' : '';

            recordString+='\n';
            finalstr = finalstr +recordString;
        }

        return finalstr;
    } 
    
    //Hardcoded the object to filter from the list
    public static set<string> getNonSObjects(){
        set<string> nonSobjSet = new set<String>{'ContentDocument','DuplicateRecordSet','EmailTemplate','CollaborationGroup','PermissionSet','StreamingChannel','Sensitive_Field_Tracker__c'};
        return nonSobjSet;
    }
    
    
    //Wrapper class
    public class result{
        public Map<string,string> sObjMap;
        public List<String> sObjList;
        public List<String> dataTypeList;
    }
    
    //Wrapper class for field info
     public class fWrapper{  
        @TestVisible
        String objLabel,objApi,fLabel,fApi,fDataType,comments,LastModifiedBy;  
        @TestVisible
        Boolean isSensitive,isEncrypted; 
    }
    
    //Wrapper class result
     public class fieldWrapper{  
        public fWrapper fw;
        public Boolean isUsed;
        public integer noOfCls;
        public List<String> clsList;
        public Map<String,String> clsMap;
    }
    
    //Wrapper class accelerator inputs
     public class accInputWrapper{  
        public string selectedDataType;
        public string other;
        public string objType;
        public string sObj;
    }
    
    //Wrapper class accelerator inputs
     public class dataWrapper{  
        @TestVisible
        STring fName,objName,comments;
        @TestVisible
        String isSensitive;
    }
    
    //Wrapper
    public class componentWrapper{
        public List<ApexClass> lstClasses;
        public List<ApexComponent> lstComponent;
        public List<ApexPage> lstPage;
        public List<ApexTrigger> lstTrigger;
    }
    
    //Wrapper
    public class refWrapper{
        public string name;
        public string type;
    }
}