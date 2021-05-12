public class FormPageWithAttachmentController{
    //Variable declarations
    public List<String> brandList{get;set;}
    public List<String> consumerGroupList{get;set;}
    public List<String> promotionTypeList{get;set;}
    public List<String> campCadenceList{get;set;}
    public List<String> commChannelList{get;set;}
  
    public FormPageWithAttachmentController(){
        //Fetching dropdown values from campaign object
        brandList = getBrandPicklistValues();   
        consumerGroupList = getConsumerGroupPicklistValues();
        promotionTypeList = getPromotionTypeList();
        campCadenceList = getCampCadenceList();
        commChannelList = getCommChannelList();
    } 
    
    //Get recordtype id based on recordType name
    public static string getRecordTypeId(string recTypeName){
         List<String> pickListValuesList= new List<String>();
        Map<string,string> consumerGroupMap = new Map<string,string>();
        for(RecordType pickListVal : [select Id,Name from RecordType where sObjectType='MRM_Campaign__c']){
            pickListValuesList.add(pickListVal.Name);
            consumerGroupMap.put(pickListVal.Name,pickListVal.Id);
        } 
        if(consumerGroupMap.containsKey(recTypeName)){
            return consumerGroupMap.get(recTypeName);
        }
        return null;
    }
    
    //Remote action method to create intakeforom from javascript(VF page)
    @RemoteAction
    public static string saveCampaing(String campObjJson){
        system.debug('###'+campObjJson);
        
        Account objCamp = new Account();
        
            Map<String, Object> objData = (Map<String, Object>) JSON.deserializeUntyped(campObjJson);
          /*  
            //Mapping json data to campaing record
            objCamp.MRM_Brand_Entity__c = objData.containsKey('brand') ?(string)objData.get('brand') : null;
            objCamp.RecordTypeId = objData.containsKey('conGroup') ? getRecordTypeId((string)objData.get('conGroup')) : null;
            objCamp.MRM_Promotion_Type__c = objData.containsKey('promoType') ? (String)objData.get('promoType') : null;
            objCamp.Name = objData.containsKey('campName') ? objData.get('campName')+' '+Date.Today().year() : null;
            objCamp.Campaign_Cadence__c = objData.containsKey('campCadence') ? (string)objData.get('campCadence') : null;
            String mDate = objData.containsKey('tldDate') ?(string)objData.get('tldDate') : null;
            if(string.isNotBlank(mDate)){
               objCamp.MRM_Target_Launch_Deployment_Date__c = date.valueOf(mDate);
            }
            if(objData.containsKey('campOPManager')){
               string manName = (string)objData.get('campOPManager');
               List<User> userList = [select id,name from user where name = :manName limit 1];
               objCamp.MRM_Campaign_Ops_Manager__c = userList != null && !userList.isEmpty() ? userList[0].id : userInfo.getUSerId();
            }
            
            objCamp.MRM_Target_Launch_Date__c = objData.containsKey('tdDateText') ? (string)objData.get('tdDateText') : null;
            //objCamp.MRM_Brand_Lead__c = objData.containsKey('bManager') ? objData.get('bManager') : null;
            
            if(objData.containskey('channel') && objData.get('channel') != null){
                List<Object> channelList = (List<Object>)objData.get('channel');
                String strChannel='';
                for(integer i=0;i<channelList.size();i++){
                    strChannel = strChannel+(string)channelList[i];
                    if(i < channelList.size() - 1){
                        strChannel = strChannel + '; ';
                    }    
                }
                objCamp.MRM_Communication_Channel__c = strChannel;
            }
            
            //Mandatory fields
            objCamp.MRM_Offer_Code__c = 'WebForm';
            
            String s = datetime.now().format(); //Datetime to creat randon number to populat campaign code
            
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(s));
            String uniqueString = EncodingUtil.convertToHex(hash);
            objCamp.MRM_Campaign_Code__c = uniqueString;
            
            //system.debug('###'+attchList);
            if(objCamp != null){
                insert objCamp;
            }*/

        return objCamp.id;
    }

    public class objWrapper{
        public string brand,conGroup,promoType,campName,campCadence,channel,tldDate,campOPManager;
        public string bManager,mAttend,comm,tdDateText;
    }
    
    //Get Brand Picklist values from MRM_Brand_Entity__c field
    public List<String> getBrandPicklistValues(){
        List<String> pickListValuesList= new List<String>();
        /*Schema.DescribeFieldResult fieldResult = Acount.Active__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     */
        return pickListValuesList;
    }
    
    //Get campaign recordType values from recordtype field
    public List<String> getConsumerGroupPicklistValues(){
        List<String> pickListValuesList= new List<String>();
        for(RecordType pickListVal : [select Id,Name from RecordType where sObjectType='Account']){
            pickListValuesList.add(pickListVal.Name);
        }     
        return pickListValuesList;
    }
    
    //Get Promotion type Picklist values from MRM_Promotion_Type__c field
    public List<String> getPromotionTypeList(){
        List<String> pickListValuesList= new List<String>();
        /*Schema.DescribeFieldResult fieldResult = Acount.Active__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        } */    
        return pickListValuesList;
    }
    
    //Get Campaign Cadence Picklist values from Campaign_Cadence__c field
    public List<String> getCampCadenceList(){
        List<String> pickListValuesList= new List<String>();
        /*Schema.DescribeFieldResult fieldResult = Acount.Active__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }    */ 
        return pickListValuesList;
    }
    
    //Get Channel Picklist values from MRM_Communication_Channel__c field
    public List<String> getCommChannelList(){
        List<String> pickListValuesList= new List<String>();
        /*Schema.DescribeFieldResult fieldResult = Acount.Active__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }    */ 
        return pickListValuesList;
    }
}