/*
*   Class Name: NYSUN_CONAPP_PaperWorkRecord_Service
*   Description:  Controller Class for CORE_CONAPP_Application_Controller
*
*                                                         
*/
public with sharing class NYSUN_CONAPP_PaperWorkRecord_Service {

    private static String NYSUN_DOCUMENT_SUBMITTED_STATUS = 'Submitted';
    private static final String TYPE_CONTRACTOR_APP = 'Contractor Application';
   
   /*
  * Method Name: getApplicationContentList
  * Description: Fetch Records of Application Content in list
  * @param: String applicationId
  * @return: List<Application_Content__c>                                                       
  */
    public static List<Application_Content__c> getApplicationContentList(String applicationId) {
        List<Application_Content__c> appContentList = [SELECT Id, Name, Document_Title__c, Mandatory_by_default__c, Conditionally_Required__c, Validation_Logic__c,
                                                       (SELECT Id, Status__c FROM Project_Documents__r Order BY Version__c DESC)
                                                       FROM Application_Content__c
                                                       WHERE Contractor_Application__c =: CORE_Helper.doEscapeSingleQuotes(applicationId) AND RecordType.DeveloperName = :CORE_Helper.DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME
                                                       AND (Mandatory_by_default__c = true OR Conditionally_Required__c = true)
                                                       ORDER BY Mandatory_by_default__c DESC, Conditionally_Required__c DESC, Document_Title__c ASC];


        return appContentList;

    }
    
    /*
  * Method Name: getSignedApplicationContentList
  * Description: get document for payee type application  [ #T-01229 ]
  * @param: String applicationId
  * @return: List<Application_Content__c>                                                       
  */
    public static List<Application_Content__c> getSignedApplicationContentList(String applicationId) {
        List<Application_Content__c> appContentList = [SELECT Id, Name, Document_Title__c, Mandatory_by_default__c, Conditionally_Required__c, Validation_Logic__c,
                                                       (SELECT Id, Status__c FROM Project_Documents__r Order BY Version__c DESC)
                                                       FROM Application_Content__c
                                                       WHERE Contractor_Application__c =: CORE_Helper.doEscapeSingleQuotes(applicationId) AND RecordType.DeveloperName = :CORE_Helper.DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME
                                                       AND (Mandatory_by_default__c = true OR Conditionally_Required__c = true) AND Document_Title__c = 'Signed Application'
                                                       ORDER BY Mandatory_by_default__c DESC, Conditionally_Required__c DESC, Document_Title__c ASC];
        
        
        return appContentList;
        
    }
     
    /*
  * Method Name: getOtherApplicationContentList
  * Description: get other Application content List of records
  * @param: String applicationId
  * @return: List<Application_Content__c>                                                       
  */
    public static List<Application_Content__c> getOtherApplicationContentList(String applicationId) {
       return [SELECT Id, Name, Document_Title__c, Configured_From_Solicitation__c, 
                (SELECT Id, Status__c FROM Project_Documents__r Order BY Version__c DESC) 
                FROM Application_Content__c 
                WHERE Contractor_Application__c =: CORE_Helper.doEscapeSingleQuotes(applicationId) AND RecordType.DeveloperName = :CORE_Helper.DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME
                AND (Mandatory_by_default__c = false AND Conditionally_Required__c = false) Order BY CreatedDate ASC];

    }
  
  /*
  * Method Name: getAttachmentList
  * Description: add project document and application content into appContentNameToAttachmentRecMap
  * @param: List<Application_Content__c> appContentList
  * @return: Map<String, Attachment>                                                     
  */
    public static Map<String, Attachment> getAttachmentList(List<Application_Content__c> appContentList) {
        List<Project_Document__c> documentList = [SELECT Id, Name, Application_Content__c, (SELECT Id, Name FROM attachments) 
                                                  FROM Project_Document__c 
                                                  WHERE Application_Content__c IN: appContentList Order BY Version__c DESC nulls last];
                                        
        List<Attachment> attachmentList = new List<Attachment>();
        Map<String, Attachment> appContentNameToAttachmentRecMap = new Map<String, Attachment>();
        
        for(Project_Document__c doc : documentList) {
            if(!appContentNameToAttachmentRecMap.containsKey(doc.Application_Content__c)) {
                Attachment att = (doc.attachments.size() > 0) ? doc.attachments[0] : new Attachment();
                appContentNameToAttachmentRecMap.put(doc.Application_Content__c, att);
            }
        }
        
        for(Application_Content__c appContent : appContentList) {
            if(!appContentNameToAttachmentRecMap.containsKey(appContent.Id)) {
                appContentNameToAttachmentRecMap.put(appContent.Id, new Attachment());
            }
        }
        
        return appContentNameToAttachmentRecMap;
    }
    
    /*
  * Method Name: saveOtherDocuments
  * Description: Save documents
  * @param: List<CORE_CONAPP_Application_Controller.OtherDocument> otherDocumentsList
  * @param: String appId
  * @return: void                                                   
  */ 
    public static void saveOtherDocuments(List<CORE_CONAPP_Application_Controller.OtherDocument> otherDocumentsList, String appId) {
        List<Application_Content__c> appContentList = new List<Application_Content__c>();
        String documentRecTypeId = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'Document').Id;
        
        List<CORE_CONAPP_Application_Controller.OtherDocument> validOtherDocumentsList = new List<CORE_CONAPP_Application_Controller.OtherDocument>();
        
        for(CORE_CONAPP_Application_Controller.OtherDocument otherDoc : otherDocumentsList) {
            if((!String.isBlank(otherDoc.documentName)) && ((otherDoc.documentId != null) 
                                                            || (otherDoc.attach.body != null))) {
                Application_Content__c appContent = new Application_Content__c();
                appContent.Id = otherDoc.documentId;
                appContent.Document_Title__c = otherDoc.documentName;
                appContent.RecordTypeId = documentRecTypeId;
                if(String.isBlank(otherDoc.documentId)) {
                    appContent.Contractor_Application__c = appId;
                }
                appContentList.add(appContent);
                
                validOtherDocumentsList.add(otherDoc);
            }
        }
        
        if(appContentList.size() > 0) {
            upsert appContentList;
        }
        
        Map<Id, Integer> appContentSizeMap = new Map<Id, Integer>();
                                                           
        for(Application_Content__c content : [SELECT Id, (SELECT Version__c, Contractor_Application__c, 
                                              Application_Content__c, Name FROM Project_Documents__r)
                                              FROM Application_Content__c WHERE Id IN: appContentList]){
            if(content.Project_Documents__r != null && content.Project_Documents__r.size() > 0){
                appContentSizeMap.put(content.Id, content.Project_Documents__r.size());
            }else{
                appContentSizeMap.put(content.Id, 0);
            }
        }
        
        List<Attachment> attachmentListToInsert = new List<Attachment>();
        List<Project_Document__c> documentListToInsert = new List<Project_Document__c>();
                                                                    
        for(Integer i = 0; i < validOtherDocumentsList.size(); i++) {
            if(validOtherDocumentsList[i].attach.body != null) {
                Integer totalDocuments = appContentSizeMap.containsKey(appContentList[i].Id) ? appContentSizeMap.get(appContentList[i].Id) : 0;
                Project_Document__c doc = new Project_Document__c();
                doc.Version__c = totalDocuments + 1;
                doc.Contractor_Application__c = appId;
                doc.Application_Content__c = appContentList[i].Id;
                doc.Name = appContentList[i].Document_Title__c;
                doc.Status__c = NYSUN_DOCUMENT_SUBMITTED_STATUS;
                documentListToInsert.add(doc);
                
                Attachment attach = new Attachment();
                attach.Body = validOtherDocumentsList[i].attach.body;
                attach.Name = validOtherDocumentsList[i].attach.Name;
                attachmentListToInsert.add(attach);
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
    }
  
  /*
  * Method Name: getDocApprovalStatus
  * Description: Put document and documents status in Map
  * @param: List<Application_Content__c> applicationContentList
  * @return: Map<String, String>                                                   
  */
    public static Map<String, String> getDocApprovalStatus(List<Application_Content__c> applicationContentList) {
        List<Project_Document__c> documentList = [SELECT Id, Status__c, Application_Content__c
                                                  FROM Project_Document__c 
                                                  WHERE Application_Content__c IN: applicationContentList Order BY Version__c DESC nulls last];
        
        Map<String, String>appContentIdToDocStatusMap = new Map<String, String>();
                                                
        for(Project_Document__c doc : documentList) {
            if(!appContentIdToDocStatusMap.containsKey(doc.Application_Content__c) && doc.Status__c != null) {
                appContentIdToDocStatusMap.put(doc.Application_Content__c, doc.Status__c);
            } else if(!appContentIdToDocStatusMap.containsKey(doc.Application_Content__c) && doc.Status__c == null) {
                appContentIdToDocStatusMap.put(doc.Application_Content__c, '');
            } 
        } 
        
        for(Application_Content__c appContent : applicationContentList) {
            if(!appContentIdToDocStatusMap.containsKey(appContent.Id)) {
                appContentIdToDocStatusMap.put(appContent.Id, '');
            }
        }
        
        return appContentIdToDocStatusMap;
    }
    
    /*
  * Method Name: saveDocuments
  * Description: Put document and documents status in Map
  * @param: Map<String, Attachment> appContentNameToNewAttachMap
  * @param: List<Application_Content__c> appContentList
  * @param: String appId
  * @return: void                                                   
  */
    public static void saveDocuments(Map<String, Attachment> appContentNameToNewAttachMap,
                                     List<Application_Content__c> appContentList, String appId) {
        
        List<Application_Content__c> appList = [SELECT Id, Document_Title__c, Type__c, Sub_Type__c,
                                                 (SELECT Version__c, Contractor_Application__c, Application_Content__c, Name FROM Project_Documents__r)
                                                 FROM Application_Content__c WHERE Id IN: appContentList];
        
        List<Project_Document__c> documentListToInsert = new List<Project_Document__c>();
        List<Attachment> attachmentListToInsert = new List<Attachment>();
        
        boolean isSignedDocument = false;
        
        for(Application_Content__c appContentRec : appList) {
            if(appContentNameToNewAttachMap.containsKey(appContentRec.Id)) {
                if(appContentNameToNewAttachMap.get(appContentRec.Id).body != null) {
                    Integer totalDocuments = appContentRec.Project_Documents__r.size();
                    Project_Document__c doc = new Project_Document__c();
                    doc.Version__c = totalDocuments + 1;
                    doc.Contractor_Application__c = appId;
                    doc.Application_Content__c = appContentRec.Id;
                    doc.Name = appContentRec.Id;
                    doc.Status__c = NYSUN_DOCUMENT_SUBMITTED_STATUS;
                    documentListToInsert.add(doc);
                    
                    Attachment attach = new Attachment();
                    attach.Body = appContentNameToNewAttachMap.get(appContentRec.Id).body;
                    attach.Name = appContentNameToNewAttachMap.get(appContentRec.Id).Name;
                    attachmentListToInsert.add(attach);
                    
                    if(appContentRec.Type__c == TYPE_CONTRACTOR_APP 
                       && appContentRec.Sub_Type__c == NYSUN_Helper.SUB_TYPE_CON_APP){
                    
                        isSignedDocument =  true;
                    }
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
                
            Contractor_Application__c tempApp = new Contractor_Application__c(Id = appId, Authorized_Signature_Date__c = Date.Today());
            update tempApp;
        }
    }
  
  /*
  * Method Name: getAttachmentHistory
  * Description: get project document history
  * @param: String appContentId
  * @return: List<Project_Document__c>                                                   
  */
    public static List<Project_Document__c> getAttachmentHistory(String appContentId) {
        List<Project_Document__c> attachmentHistory = new List<Project_Document__c>();
        List<Project_Document__c> documentList = [SELECT Id, Version__c, CreatedDate, CreatedBy.Name, 
                                                 (SELECT Name FROM Attachments) FROM Project_Document__c 
                                                 WHERE Application_Content__c =: appContentId Order by Version__c DESC];
        for(Project_Document__c doc : documentList) {
            if(doc.Attachments.size() > 0 ) {
                attachmentHistory.add(doc);
            }
        }
        return attachmentHistory;
    }

  /*
  * Method Name: checkForConditionallyRequired
  * Description: Check Application contentId and put into appContentIdToRequiredMap
  * @param: List<Application_Content__c> appContentList
  * @return: Map<String, Boolean>                                                   
  */
    public static Map<String, Boolean> checkForConditionallyRequired(List<Application_Content__c> appContentList) {
        Set<String> fieldsToQuery = getFieldsToQuery(appContentList);
        List<Application_Content__c> appContentsWithAllFields = getAppContentsWithAllFields(fieldsToQuery, appContentList);
        
        Map<String, Boolean> appContentIdToRequiredMap = new Map<String, Boolean>();
        for(Application_Content__c appContentRec : appContentsWithAllFields) {
            appContentIdToRequiredMap.put(appContentRec.Id, FormulaInterpretUtility.checkForRequried(appContentRec));
        }
        return appContentIdToRequiredMap;
    }
   
  /*
  * Method Name: getAppContentsWithAllFields
  * Description: get Application Content with all fields
  * @param: Set<String> fieldsToQuery
  * @param: List<Application_Content__c> appContentList
  * @return: List<Application_Content__c>                                                
  */
    private static List<Application_Content__c> getAppContentsWithAllFields(Set<String> fieldsToQuery, List<Application_Content__c> appContentList) {
        String query = ' SELECT Validation_Logic__c, Conditionally_Required__c, Document_Title__c, ';
        for(String fieldsName : fieldsToQuery) {
            query += fieldsName + ', ';
        }
       // query += 'Contractor_Application__r.Loopfield_Type__c,';
        query = query.substring(0, query.length() - 2);
        query += ' FROM Application_Content__c Where Id IN : appContentList' ;
        system.debug(query);
        system.debug('----250'+appContentList);
        List<Application_Content__c> appContentsWithAllFields = Database.query(query);
        return appContentsWithAllFields;
    }
  
  /*
  * Method Name: getFieldsToQuery
  * Description: Add all Application content fields in fieldsToQuery
  * @param: List<Application_Content__c> appContentList
  * @return: Set<String>                                             
  */
    private static Set<String> getFieldsToQuery(List<Application_Content__c> appContentList) {
        Set<String> fieldsToQuery = new Set<String>();
        for(Application_Content__c appContentRec : appContentList) {
            if(appContentRec.Conditionally_Required__c) {
                system.debug('----258'+appContentRec);
                if(String.isNotBlank(appContentRec.Validation_Logic__c)) {
                    List<String> validationLogicList = appContentRec.Validation_Logic__c.split(' AND ');
                    for(String subStr : validationLogicList) {
                        Map<String, String> stringLiteralToFormulaValueMap = FormulaInterpretUtility.parseFormula(subStr);
                        if(stringLiteralToFormulaValueMap.containsKey('FieldName')) {
                            fieldsToQuery.add(stringLiteralToFormulaValueMap.get('FieldName'));
                            system.debug('-------'+fieldsToQuery);
                        }
                    }
                }
            }
        }
        return fieldsToQuery;
    }
    
    
  /*
  * Method Name: getAllDocuments
  * Description: Return all documents where application content exist in appId
  * @param: String appId
  * @return: List<Application_Content__c>                                            
  */
    public static List<Application_Content__c> getAllDocuments(String appId) {
        List<Application_Content__c> allDocuments = [SELECT (SELECT Id FROM Project_Documents__r)
                                                     FROM Application_Content__c
                                                     WHERE RecordType.Name = :CORE_Helper.DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME
                                                     AND Contractor_Application__c =: appId];
        return allDocuments;
    }
}