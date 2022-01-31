/*
* Class Name: RTEM_CONAPP_References_Service
* Description: Service class for RTEM contractor application
*/
public with sharing class RTEM_CONAPP_References_Service {
    
    public static String APPLICATION_CONTENT_RECORD_TYPE_DEVELPOER_NAME = 'Document';
    
  /*
    * Method Name: getApplicationContentList
    * Description: Return the application content list
    * @param: idString a String                                                         
    * @return: List<Application_Content__c>
  */
    public static List<Application_Content__c> getApplicationContentList(String applicationId) {
        List<Application_Content__c> applicationContentList = [select Id, Name, Document_Title__c, Project_Description__c, Mandatory_by_default__c,
                                                                (select Id, Status__c from Project_Documents__r Order by Version__c DESC) 
                                                                from Application_Content__c 
                                                                Where Contractor_Application__c =: applicationId AND RecordType.DeveloperName = :APPLICATION_CONTENT_RECORD_TYPE_DEVELPOER_NAME
                                                                order By Sequence__c ASC];

        return applicationContentList;
    }
    
    /*
    * Method Name: getAttachmentList
    * Description: Return the attachment map
    * @param: List<Application_Content__c>                                                         
    * @return: Map<String, Attachment>
  */
    public static Map<String, Attachment> getAttachmentList(List<Application_Content__c> applicationContentList) {
        List<Project_Document__c> documentList = [ select Id, Name, Application_Content__r.Document_Title__c, (select Id, Name from attachments) 
                                                        from Project_Document__c 
                                                        Where Application_Content__c IN: applicationContentList 
                                               Order by Version__c DESC nulls last];
                                        
        List<Attachment> attachmentList = new List<Attachment>();
        Map<String, Attachment> appContentNameToAttachmentRecMap = new Map<String, Attachment>();
        
        for(Project_Document__c doc : documentList) {
            if(!appContentNameToAttachmentRecMap.containsKey(doc.Application_Content__r.Document_Title__c)) {
                Attachment att = (doc.attachments.size() > 0) ? doc.attachments[0] : new Attachment();
                appContentNameToAttachmentRecMap.put(doc.Application_Content__r.Document_Title__c, att);
            }
        }
        
        for(Application_Content__c appContent : applicationContentList) {
            if(!appContentNameToAttachmentRecMap.containsKey(appContent.Document_Title__c)) {
                appContentNameToAttachmentRecMap.put(appContent.Document_Title__c, new Attachment());
            }
        }
        
        return appContentNameToAttachmentRecMap;
    }
    
    /*
    * Method Name: saveDocuments
    * Description: method to save the documents
    * @param: Map<String, Attachment>, List<Application_Content__c>, String
    * @return: void
  */
    public static void saveDocuments(Map<String, Attachment> appContentNameToNewAttachMap,
                                        List<Application_Content__c> applicationContentList, String applicationId) {
        
        List<Application_Content__c> appContentList = [select Id, Document_Title__c, Type__c,
                                                        Sub_Type__c, (select Version__c, Project__c, Application_Content__c, Name from Project_Documents__r)
                                                            from Application_Content__c where Id IN: applicationContentList];
        
        List<Project_Document__c> documentListToInsert = new List<Project_Document__c>();
        List<Attachment> attachmentListToInsert = new List<Attachment>();
        
        boolean isSignedDocument = false;
        
        for(Application_Content__c appContentRec : appContentList) {
            if(appContentNameToNewAttachMap.containsKey(appContentRec.Document_Title__c)) {
                if(appContentNameToNewAttachMap.get(appContentRec.Document_Title__c).body != null) {
                    
                    if(appContentRec.Type__c == CORE_Helper.TYPE_CON_APP && 
                       appContentRec.Sub_Type__c == 'Signed Application'){
                    
                        isSignedDocument =  true;
                    }
                     
                    Integer totalDocuments = appContentRec.Project_Documents__r.size();
                    Project_Document__c doc = new Project_Document__c();
                    doc.Version__c = totalDocuments + 1;
                    doc.Contractor_Application__c = applicationId;
                    doc.Application_Content__c = appContentRec.Id;
                    doc.Name = appContentRec.Document_Title__c;
                    documentListToInsert.add(doc);
                    
                    Attachment attach = new Attachment();
                    attach.Body = appContentNameToNewAttachMap.get(appContentRec.Document_Title__c).body;
                    attach.Name = appContentNameToNewAttachMap.get(appContentRec.Document_Title__c).Name;
                    attachmentListToInsert.add(attach);
                }
            }
        }
        
        if(documentListToInsert.size() > 0) {
            insert documentListToInsert;
        }
        
        if(attachmentListToInsert.size() > 0) {
            for(Integer i = 0; i < documentListToInsert.size(); i++) {
                attachmentListToInsert[i].ParentId = documentListToInsert[i].Id;
            }
            insert attachmentListToInsert;
        }   
        
        if(isSignedDocument){
            
            Contractor_Application__c tempApp = new Contractor_Application__c(Id=applicationId, Authorized_Signature_Date__c = Date.Today());
            
            update tempApp;
        }
    }
    
    /*
    * Method Name: getAttachmentHistory
    * Description: method to return attachment history
    * @param: String
    * @return: List<Project_Document__c>
  */
    public static List<Project_Document__c> getAttachmentHistory(String applicationContentId) {
        List<Project_Document__c> attachmentHistory = new List<Project_Document__c>(); 
        for(Project_Document__c doc : [select Id, Version__c, CreatedDate, CreatedBy.Name, 
                                              (select Name from Attachments) 
                                         from Project_Document__c 
                                        where Application_Content__c =: applicationContentId 
                                     Order by Version__c DESC]) {
            if(doc.Attachments.size() > 0 ) {
                attachmentHistory.add(doc);
            }
        }
        return attachmentHistory;
    }
}