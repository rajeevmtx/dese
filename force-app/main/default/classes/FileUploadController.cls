public with sharing class FileUploadController {
    public FileUploadController() {

    }
    @AuraEnabled
    public static List<ContentVersion> fetchFiles(String projectId){
        try {
            List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>([
                SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: projectId
            ]);
            List<Id> contentDocumentIds = new List<Id>();
            for(ContentDocumentLink cdl : contentDocumentLinkList){
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            List<ContentVersion> contentVersionList = new List<contentVersion>([
                SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds AND IsLatest =: true LIMIT 100
            ]);
            return contentVersionList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteFile(String contentDocumentId){
        try {
            List<ContentDocument> deleteDocs = [
                SELECT Id FROM ContentDocument WHERE Id =: contentDocumentId
            ];
            delete deleteDocs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}