public with sharing class FileUploadRateRequestController {

    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
        ContentDocumentLink cd = createFile(oAttachment);
        system.debug('@@@'+cd.id);
        return oAttachment.Id;
    }
     @testVisible
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [
            SELECT Id, Body,Name,parentid  
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
        ContentDocumentLink cd = createFile(a);
    }

    public static ContentDocumentLink createFile(Attachment att){
        /*Id parentId, String fileName, Blob body, String contentType) {*/

        // insert a version of the file - if no ContentDocumentId, then it creates a new ContentDocument
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; // S = within Salesforce, E = External
        cv.VersionData = att.body;
        cv.Title = att.Name;
        cv.PathOnClient = att.name;
        insert cv;


        // insert a ContentDocumentLink with the fiel version
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = att.parentId;
        cdl.ShareType = 'V';
        insert cdl;

        return cdl;
    }
}