public without sharing class psr_DocumentReviewManager {

    @AuraEnabled
    public static List<ApplicationDocumentWrapper> getApplicationDocumnets(String applicationId){
        return retrieveApplicationDocuments(applicationId);
    }

    @AuraEnabled
    public static List<ApplicationDocumentWrapper> updateReviewedDocuments(String docValues) {
        return modifyReviewedDocuments(docValues);
    }

    @AuraEnabled
    public static List<ApplicationDocumentWrapper> retrieveApplicationDocuments(String applicationId){
        
        System.debug('applicationId-->'+ applicationId);
        List<Id> contentDocumentId = new List<Id>();
        Map<String,Boolean> contentVersionMap = new Map<String,Boolean>();
        
        List<ApplicationDocumentWrapper> appDocWrapperLst = new List<ApplicationDocumentWrapper>();
        Map<String,Application_Document__c> documentMap = new Map<String,Application_Document__c>();
        Map<String,List<ContentDocumentLink>> contentMap = new Map<String,List<ContentDocumentLink>>();

        List<String> DocIDs = new List<String>();

        List<Application_Document__c> genericDocumentsList =  [SELECT Id, Application__c, Document_Name__c, Status__c, Notes__c 
                                                                FROM Application_Document__c 
                                                                WHERE Application__c = :applicationId];
        for(Application_Document__c genericDocument : genericDocumentsList){
            DocIDs.add(genericDocument.Id);
            documentMap.put(genericDocument.Id,genericDocument);
        }

        List<ContentDocumentLink> contentDocumentLinkslist = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: DocIDs];
        System.debug('contentDocumentLinkslist-->'+ contentDocumentLinkslist);
        for(ContentDocumentLink contentDoc : contentDocumentLinkslist){
            contentDocumentId.add(contentDoc.ContentDocumentId);
            if(!contentMap.containsKey(contentDoc.LinkedEntityId)){
                    contentMap.put(contentDoc.LinkedEntityId,new List<ContentDocumentLink>());
                }
                contentMap.get(contentDoc.LinkedEntityId).add(contentDoc);
            //contentMap.put(content.LinkedEntityId,content);
        }
		
        for( ContentVersion contentVersion : [SELECT ID,ContentDocumentId,Archived__c from ContentVersion Where ContentDocumentId IN: contentDocumentId AND Archived__c = false]){
            contentVersionMap.put(contentVersion.ContentDocumentId , contentVersion.Archived__c);
		}
        
        List<ContentDocumentLink> afterRevisioncontentDoc ;
        
        for(String key : documentMap.keySet()){
            System.debug('documentMap.get(key);-->'+ documentMap.get(key));
            ApplicationDocumentWrapper appDocWrapper;
            afterRevisioncontentDoc = new List<ContentDocumentLink>();
            
            if(documentMap.get(key) != null){
            
                    if(contentMap.get(key) != null){
                        for(ContentDocumentLink contentlink : contentMap.get(key)){
                       
                            if(contentVersionMap.get(contentlink.ContentDocumentId) == false){
                                    afterRevisioncontentDoc.add(contentlink);
                                }
         
                            }
                        
                        appDocWrapper = new ApplicationDocumentWrapper(documentMap.get(key),afterRevisioncontentDoc);
                    
                    }else{
                        appDocWrapper = new ApplicationDocumentWrapper(documentMap.get(key),new List<ContentDocumentLink>());
                    }
               } 
            
            appDocWrapperLst.add(appDocWrapper);
        }
        System.debug('appDocWrapperLst-->'+ appDocWrapperLst);
        return appDocWrapperLst;
    }

    @AuraEnabled
    public static List<ApplicationDocumentWrapper> modifyReviewedDocuments(String docValues) {
        System.debug('docValues--->'+docValues);
        Set<Id> contentDocumentSet = new Set<Id>();
        List<Application_Document__c> appDocumentList = new List<Application_Document__c>();
        List<ApplicationDocumentWrapper> appDocWrapperList = (List<ApplicationDocumentWrapper>) JSON.deserialize(docValues, List<ApplicationDocumentWrapper>.class);
        for(ApplicationDocumentWrapper wrapper : appDocWrapperList){
            
			List<ContentDocumentLink> uploadedDocumentList = wrapper.uploadedDocumentList;
            if(wrapper.status == 'Returned for Revision'){

                for(ContentDocumentLink contentlink : uploadedDocumentList){
                    contentDocumentSet.add(contentlink.ContentDocumentId);
                }                   
 			}    
            Application_Document__c appDoc = new Application_Document__c(Id=wrapper.id,Status__c = wrapper.status,Notes__c = wrapper.notes);
            appDocumentList.add(appDoc);
        }
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        
        for( ContentVersion contentVersion : [SELECT ID,ContentDocumentId,Archived__c from ContentVersion Where ContentDocumentId IN: contentDocumentSet]){
            contentVersion.Archived__c = true;       
            contentVersionList.add(contentVersion);
		}
        if(contentVersionList.size() > 0){
            UPDATE contentVersionList;
        }
        System.debug('appDocumentList-->'+ appDocumentList);
        update appDocumentList;
        return appDocWrapperList;
    }

    // --------------------------------------------- Wrapper Class -----------------------------------------------------

    public class ApplicationDocumentWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String applicationId;
        @AuraEnabled public String documentName;
        @AuraEnabled public String status;
        @AuraEnabled public String notes;
        @AuraEnabled public String uploadedDocumentId;
        @AuraEnabled public String uploadedDocumentName;
        @AuraEnabled public String selectedValue;
        @AuraEnabled public String applicationStatus;
        @AuraEnabled public List<ContentDocumentLink> uploadedDocumentList;
        
        public ApplicationDocumentWrapper(){}

        public ApplicationDocumentWrapper(Application_Document__c appDoc,List<ContentDocumentLink> conObj){
            if(appDoc!=null){
                this.id = appDoc.Id;
                this.applicationId = appDoc.Application__c;
                this.status = appDoc.Status__c;
                this.notes = appDoc.Notes__c == null ? '':appDoc.Notes__c;
                this.documentName = appDoc.Document_Name__c;
                this.applicationStatus = appDoc.Status__c;
                this.selectedValue = '';

            }else{
                this.id = '';
                this.applicationId = '';
                this.status = '';
                this.notes = '';
                this.documentName = '';
                this.applicationStatus = '';
                this.selectedValue = '';	
            }
            this.uploadedDocumentList = conObj;      
        }

    }
}