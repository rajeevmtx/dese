/************************************************
* Created By : Ayush Vijayvergia
* Description : Controller for Document Library Internal page.
* Last Modified By : 
* Last Modified Date: 
* ***********************************************/
public with sharing class EEC_DocumentLibraryInternal {

    /*
        * Method Name: doCreateDocs
        * Created By : Ayush Vijayvergia
        * Description: Method to create new Documents which are for the new inserted Document Types
        * @param:      String accountId
    */
    @AuraEnabled
    public static Boolean doCreateDocs(String accountId){
        String memberId = accountId;
        Boolean isGSA= false;
        Boolean isRp = false;
        String providerRecordType;
        Set<Id> providerMemeberConfigIds = new Set<Id>();
        String programName;
        String umbrellaMember;
        Boolean isGroupSwitched = false;
        Boolean isUnsubmitted = false;
        Boolean isDocumentExpired = false;
        LEAD_Configuration__c leadConfiguration = new LEAD_Configuration__c();
        set<Id> docIds = new Set<Id>();
        Map<String,List<S3_File__c>> mapOfDocumentToListOfS3FIles = new Map<String,List<S3_File__c>>();
        String umbrellaId;
        String leadConfigurationId;

        if(memberId != null){
            for(Account acc : [SELECT Id, Is_GSA__c, Is_R_P__c,
                                Umbrella_Members__c 
                                FROM Account 
                                WHERE Id = :memberId
                                //
                                ]){
                 umbrellaId = acc.Umbrella_Members__c;
                if(acc.Is_GSA__c){
                    isGSA = true;
                }
                if(acc.Is_R_P__c){
                    isRp = true;
                }
            }
            
            for(Account acc:[SELECT id,Name,Umbrella_Members__c,Config_Record__c,
                                RecordType.DeveloperName,RecordType.Name,
                                Are_you_switching_small_to_large_group__c,
                                Are_you_switching_large_to_small_group__c 
                                FROM Account 
                                WHERE Id =:memberId
                                //WITH SECURITY_ENFORCED
                                ]){
                providerRecordType  = acc.RecordType.Name;
                programName = acc.Name;
                providerMemeberConfigIds.add(acc.Config_Record__c);
                umbrellaMember = acc.Umbrella_Members__c;
                    if(acc.Are_you_switching_small_to_large_group__c =='Yes' || acc.Are_you_switching_large_to_small_group__c =='Yes'){
                    isGroupSwitched = true;
                }
            }        
        }

        List<Lead_Configuration__c> listleadConfiguration = [SELECT Id, Library_Introduction__c 
                                                             FROM LEAD_Configuration__c 
                                                             WHERE Name = :providerRecordType
                                                             //WITH SECURITY_ENFORCED
                                                             ];
        
        EEC_Config__c config =  EEC_Config__c.getOrgDefaults();   
        Date todayDate = Date.Today();
        isUnsubmitted = false;
        
        for(Document__c docObj:[SELECT Id, Document_Name__c,CreatedDate, Document_Type__c,Status__c,Uploaded_Date__c,Expiration_Date__c,Not_Applicable__c
                                FROM Document__c 
                                WHERE Provider__c=: accountId 
                                AND Not_Applicable__c = false
                                //WITH SECURITY_ENFORCED
                                ]){
            if(docObj.Expiration_Date__c != null){
                Integer numberOfdays = todayDate.daysBetween(docObj.Expiration_Date__c);
                if(numberOfdays <=config.Document_Expiration_Warning_Days__c && !isDocumentExpired){
                    isDocumentExpired = true;
                    break;
                }
            }
            
            if(!string.isBlank(docObj.Status__c) && docObj.Status__c != 'Submitted' && !isDocumentExpired){
                isDocumentExpired = true;
                break;
            }
       } 
        
        if(listleadConfiguration.size() > 0)                                                    
            leadConfiguration = listleadConfiguration[0];
        
        List<Document_Type__c> listDocumentType = new List<Document_Type__c>();     
        if(leadConfiguration != null && umbrellaMember == null){
            for(Document_Type__c docObj:[SELECT Id, Allow_use_of_Umbrella_Level_Document__c, Description__c, Name,Responsible_Party__c,
                                                       Individual_Document__c,Library_Level__c,Need_to_be_Updated_at_each_new_Transacti__c,
                                                       Optional_for_Transactio_Type__c,Related_Role__c,Required_For_Transaction_Type__c,
                                                       LEAD_Configuration__c
                                                       FROM Document_Type__c 
                                                       WHERE  LEAD_Configuration__c =: leadConfiguration.Id 
                                                      //   AND Responsible_Party__c ='Provider' 
                                                         AND Library_Level__c = true AND Transaction_Library_Documents__c = false
                                                         //WITH SECURITY_ENFORCED
                                                         ]){
                listDocumentType.add(docObj);
                
            
            }
        }else if(leadConfiguration != null){
            for(Document_Type__c docObj:[SELECT Id, Allow_use_of_Umbrella_Level_Document__c, Description__c, Name,Responsible_Party__c,
                                                       Individual_Document__c,Library_Level__c,Need_to_be_Updated_at_each_new_Transacti__c,
                                                       Optional_for_Transactio_Type__c,Related_Role__c,Required_For_Transaction_Type__c,
                                                       LEAD_Configuration__c
                                                       FROM Document_Type__c 
                                                       WHERE  LEAD_Configuration__c =: leadConfiguration.Id 
                                                         AND (Responsible_Party__c ='Provider' OR Responsible_Party__c ='Licensor') 
                                                         AND Library_Level__c = true AND Transaction_Library_Documents__c = false
                                                         //WITH SECURITY_ENFORCED
                                                         ]){
                listDocumentType.add(docObj);       
            }
        }      
        else{
            for(Document_Type__c docObj:[SELECT Id, Allow_use_of_Umbrella_Level_Document__c, Description__c, Name,Responsible_Party__c,
                                                       Individual_Document__c,Library_Level__c,Need_to_be_Updated_at_each_new_Transacti__c,
                                                       Optional_for_Transactio_Type__c,Related_Role__c,Required_For_Transaction_Type__c,
                                                       LEAD_Configuration__c 
                                                       FROM Document_Type__c 
                                                       WHERE Responsible_Party__c ='Umbrella' 
                                                         AND Library_Level__c = true 
                                                         AND Transaction_Library_Documents__c = false
                                                         AND LEAD_Configuration__c IN: providerMemeberConfigIds
                                                         //WITH SECURITY_ENFORCED
                                                         ]){
                listDocumentType.add(docObj);           
            }
        
        }
            List<Document__c> listExistingDocuments = [SELECT Id, Document_Name__c,CreatedDate, Document_Type__c,Document_Type__r.Responsible_Party__c, Document_Type__r.Name,Document_Type__r.Category__c,
                                                       Document_Type__r.Description__c, Attachment_Status__c, Notes__c,Is_Document_Exist__c,
                                                       Valid_From__c,Valid_To__c,Responsible_Party__c,Status__c,Uploaded_Date__c,Expiration_Date__c 
                                                       FROM Document__c 
                                                       WHERE Provider__c=: accountId
                                                       //WITH SECURITY_ENFORCED
                                                       ];
                                                       
            List<Document__c> listUmbrellaExistingDocuments = new List<Document__c>();
            
            if(umbrellaMember != null) {
                listUmbrellaExistingDocuments = [SELECT Id, Document_Name__c,CreatedDate, Document_Type__c,Document_Type__r.Responsible_Party__c, Document_Type__r.Name,Document_Type__r.Category__c,
                                                 Document_Type__r.Description__c, Attachment_Status__c, Notes__c,Is_Document_Exist__c,
                                                 Valid_From__c,Valid_To__c,Responsible_Party__c,Status__c,Uploaded_Date__c,Expiration_Date__c 
                                                 FROM Document__c 
                                                 WHERE Provider__c=: umbrellaMember
                                                 //WITH SECURITY_ENFORCED
                                                 ];
            }       
            Map<Id, List<Document__c>> mapDocumentTypeDocs = new Map<Id, List<Document__c>>();
            Map<Id, List<Document__c>> mapUmbrellaDocumentTypeDocs = new Map<Id, List<Document__c>>();
            for(Document__c document : listExistingDocuments){ 
                List<Document__c> listDocs;
                if(mapDocumentTypeDocs.get(document.Document_Type__c) == null){
                    listDocs = new List<Document__c>();
                }
                else{
                    listDocs = mapDocumentTypeDocs.get(document.Document_Type__c);
                }
                listDocs.add(document);
                mapDocumentTypeDocs.put(document.Document_Type__c, listDocs);
            }
            
            for(Document__c document : listUmbrellaExistingDocuments){ 
                List<Document__c> listDocs;
                if(mapUmbrellaDocumentTypeDocs.get(document.Document_Type__c) == null){
                    listDocs = new List<Document__c>();
                }
                else{
                    listDocs = mapUmbrellaDocumentTypeDocs.get(document.Document_Type__c);
                }
                listDocs.add(document);
                mapUmbrellaDocumentTypeDocs.put(document.Document_Type__c, listDocs);
            }
            
            List<Document__c> listNewDocs = new List<Document__c>();
            String responsibleParty;
            boolean isDocumentExist = false;
            for(Document_Type__c documentType : listDocumentType){
                if(documentType.LEAD_Configuration__c != null){
                    leadConfigurationId = documentType.LEAD_Configuration__c;
                }else{
                    leadConfigurationId = '';
                }
                if(umbrellaMember == null && documentType.Responsible_Party__c != null && leadConfiguration != null && documentType.Responsible_Party__c =='Umbrella'){
                    responsibleParty = 'Provider';
                }else if(documentType.Responsible_Party__c != null){
                    responsibleParty = documentType.Responsible_Party__c;
                }else{
                    responsibleParty = '';
                }
                
                isDocumentExist = false;
                List<Document__c> listDocs = mapDocumentTypeDocs.get(documentType.Id);
                List<Document__c> listUmbrellaDocs = mapUmbrellaDocumentTypeDocs.get(documentType.Id);
                
                if(listDocs != null){
                    for(Document__c document : listDocs){
                        if(document.Is_Document_Exist__c == true){
                            isDocumentExist = true;
                            
                            break;
                        }
                    }
                    if(isDocumentExist == false){
                        Document__c newDocument = createDocument(documentType.Id,accountId,responsibleParty,leadConfigurationId);
                        listNewDocs.add(newDocument);
                        
                    }
                } else if (listUmbrellaDocs != null) {
                    for(Document__c document : listUmbrellaDocs){
                        if(document.Is_Document_Exist__c == true){
                            isDocumentExist = true;      
                            break;
                        }
                    }
                    
                    if(isDocumentExist == false){
                        Document__c newDocument = createDocument(documentType.Id,accountId,responsibleParty,leadConfigurationId);
                        listNewDocs.add(newDocument);
                        
                    }
                } else{
                    Document__c newDocument = createDocument(documentType.Id,accountId,responsibleParty,leadConfigurationId);
                    listNewDocs.add(newDocument);
                }
            }
            
            if(listNewDocs.size() > 0){
                DML.doInsert(listNewDocs);
                //insert listNewDocs;
            } 

            return true;
    }

    private static Document__c createDocument(string documentType, string accountId,string responsibleParty,String leadConfigRecord){     
        Document__c newDocument = new Document__c();
        newDocument.Document_Type__c = documentType;
        newDocument.Provider__c = accountId;
        newDocument.Is_Document_Exist__c = true;
        newDocument.Status__c ='Unsubmitted';
        newDocument.Responsible_Party__c = responsibleParty;
        newDocument.LEAD_Configuration__c = leadConfigRecord;
        //system.assert(false,newDocument);
        return newDocument;     
    }

    /*
        * Method Name: getAllDocumentsForIndividual
        * Created By : Ayush Vijayvergia
        * Description: Method to get all documents for an Account
        * @param:      String accountId
        * @return:     List<CategoryToDocumentWrapper>
    */

    @AuraEnabled
    public static List<CategoryToDocumentWrapper> getAllDocumentsForIndividual(String accountId) {
        List<CategoryToDocumentWrapper> categoryToDocumentWrapperList = new List<CategoryToDocumentWrapper>();
        String accId = accountId;
        String umbrellaId;
        String providerRecordType;
        Map<String, List<Document__c>> categoryToDocsMap = new Map<String, List<Document__c>>();
        List<Document__c> documents = new List<Document__c>();

        Boolean isGSA = is_GSA(accountId);
        Boolean isRP = is_RP(accountId);
        Boolean isUmbrella = is_Umbrella(accountId);
        Boolean isGroupSwitched = false;

        for(Account acc : [SELECT Id, Is_GSA__c, Is_R_P__c,Umbrella_Members__c,
                            Are_you_switching_small_to_large_group__c,
                            Are_you_switching_large_to_small_group__c,
                            RecordType.Name 
                            FROM Account 
                            WHERE Id = :accId]){
                            ////WITH SECURITY_ENFORCED
            umbrellaId = acc.Umbrella_Members__c;
            providerRecordType = acc.RecordType.Name;
            if(acc.Are_you_switching_small_to_large_group__c =='Yes' || acc.Are_you_switching_large_to_small_group__c =='Yes'){
                isGroupSwitched = true;
            }
       }
        if(isRP || isUmbrella || isGSA) {
            for(Document__c doc : [SELECT Id,Provider__r.RecordType.Name,(SELECT id,subject,activitydate,createddate, status,type,priority,Description,createdby.name
                                    FROM tasks
                                    ORDER BY activitydate DESC), Name,LEAD_Configuration__r.Name,CreatedDate, Status__c, Document_Type__c,Uploaded_Date__c,Expiration_Date__c, Document_Type__r.Name, Document_Type__r.Document_Type_Name__c,
                                    Document_Type__r.Help_Text__c, EEC_Note_For_Revision__c,Responsible_Party__c,Library_Level__c,Document_Type__r.Library_Level__c,Notes__c, Category__c, Document_Type__r.Category_Description__c,
                                    Attachment_Status__c,Document_Type__r.Not_Applicable__c,Not_Applicable__c, Document_Type__r.LEAD_Configuration__r.Name, Document_Type__r.Sub_Category__c
                                    FROM Document__c 
                                    WHERE (Provider__c =: accId OR Provider__c =: umbrellaId) 
                                    AND (Document_Type__r.Library_Level__c = true 
                                    OR Library_Level__c = true) 
                                    AND Responsible_Party__c != null 
                                    //WITH SECURITY_ENFORCED
                                    ORDER BY Document_Type__r.Sequence__c ASC]){
                if(isGroupSwitched && (doc.Document_Type__r.LEAD_Configuration__r.Name == 'Large Group' || doc.Document_Type__r.LEAD_Configuration__r.Name == 'Small Group')){
                    documents.add(doc);
                }
                if(!isGroupSwitched && doc.LEAD_Configuration__r.Name == providerRecordType && !isUmbrella){
                    documents.add(doc);
                }
                if(isUmbrella){
                    documents.add(doc);
                }
            }
        } else {
            for(Document__c doc : [SELECT Id,Provider__r.RecordType.Name,(SELECT id,subject,activitydate,createddate, status,type,priority,Description,createdby.name
                                FROM tasks
                                ORDER BY activitydate DESC), Name,LEAD_Configuration__r.Name,CreatedDate, Status__c, Document_Type__c,Uploaded_Date__c,Expiration_Date__c, Document_Type__r.Name, Document_Type__r.Document_Type_Name__c,
                                Document_Type__r.Help_Text__c, EEC_Note_For_Revision__c,Responsible_Party__c,Library_Level__c,Document_Type__r.Library_Level__c,Notes__c, Category__c, Document_Type__r.Category_Description__c,
                                Attachment_Status__c,Document_Type__r.Not_Applicable__c,Not_Applicable__c, Document_Type__r.LEAD_Configuration__r.Name, Document_Type__r.Sub_Category__c
                                FROM Document__c 
                                WHERE (Provider__c =: accId OR Provider__c =: umbrellaId) 
                                AND (Document_Type__r.Library_Level__c = true 
                                OR Library_Level__c = true) 
                                AND Responsible_Party__c != null 
                                //WITH SECURITY_ENFORCED
                                ORDER BY Document_Type__r.Name ASC]){
                if(doc.LEAD_Configuration__r.Name == providerRecordType){
                    documents.add(doc);
                }
            }
        }
        

        for(Document__c doc : documents){
            String category;
            if(String.isNotBlank(doc.Category__c)) {
               category = doc.Category__c;
               if(doc.Category__c == 'Temporary Shelter Home Programs'){
                  category = 'In addition, for temporary shelter home programs: 102 CMR 3.03(1)(b)';
               } else if(doc.Category__c == 'Foster Care Services') {
                  category = 'In addition, placement agencies offering foster care services shall submit the following:';
               } else if(doc.Category__c == 'Adoption Agencies') {
                  category = 'In addition, placement agencies offering adoption services shall submit the following:';
               }
            } else if(String.isNotBlank(doc.Document_Type__c) && String.isNotBlank(doc.Document_Type__r.LEAD_Configuration__c) ) {
               if(String.isNotBlank(doc.Document_Type__r.LEAD_Configuration__r.Name) && (doc.Document_Type__r.LEAD_Configuration__r.Name != null)){                 
                if(doc.Document_Type__r.LEAD_Configuration__r.Name == 'School' || //Public School
                    doc.Document_Type__r.LEAD_Configuration__r.Name == 'Private School' ||
                    doc.Document_Type__r.LEAD_Configuration__r.Name == 'Other Eligible Provider') {
                    category = 'Funded Program Documents';
                }                                         
               }
            }
            //System.assert(false, category);
            if(category != null) {
                if(categoryToDocsMap.containsKey(category)){
                    categoryToDocsMap.get(category).add(doc);
                } else {
                    categoryToDocsMap.put(category, new List<Document__c>());
                    categoryToDocsMap.get(category).add(doc);
                }
            }
        }

        for(String key: categoryToDocsMap.keySet()){
            CategoryToDocumentWrapper docsWrap = new CategoryToDocumentWrapper(key, categoryToDocsMap.get(key),providerRecordType);
            categoryToDocumentWrapperList.add(docsWrap);
        }   
        return categoryToDocumentWrapperList;
    }

    /*
        * Method Name: getAllDocumentFiles
        * Created By : Ayush Vijayvergia
        * Description: Method to get all S3 files for a document
        * @param:      String docId
        * @return:     List<DocFilesWrapper>
    */

    @AuraEnabled
	public static List<DocFilesWrapper> getAllDocumentFiles(String docId){
		List<DocFilesWrapper> documentFilesList = new List<DocFilesWrapper>();
        
        List<S3_File__c> tempFilesList = [SELECT Id, Document__c, Bucket__c, Prefix__c, Filename__c, Document_URL__c, Internal_Upload__c,Status__c,Comments__c,CreatedBy.Name,CreatedDate
                                          FROM S3_File__c
                                          WHERE Document__c =: docId
                                          //WITH SECURITY_ENFORCED
                                          ORDER BY CreatedDate DESC];
    
        if(tempFilesList.size() > 0) {
            for(S3_File__c file : tempFilesList) {
                DocFilesWrapper fileWrapper = new DocFilesWrapper(file);
                documentFilesList.add(fileWrapper);
            }
        }
                     
		return documentFilesList;
     }

     /*
        * Method Name: saveDocuments
        * Created By : Rahul Taneja
        * Description: Method to save changes made for an S3 file
        * @param:      String jsonData
        * @return:     none
    */

     @AuraEnabled
     public static void saveDocuments(String jsonData){
         List<DocFilesWrapper> s3FilesWrapperList = (List<DocFilesWrapper>) JSON.deserialize(jsonData, List<DocFilesWrapper>.class);
         List<S3_File__c> s3List = new List<S3_File__c>();
         for(DocFilesWrapper tw : s3FilesWrapperList){
            S3_File__c s3File = new S3_File__c();
            s3File.Id=tw.fileId;
            s3File.Status__c=tw.status; 
            s3File.Comments__c = tw.internalNotes;      
           
            s3List.add(s3File);
         }       
         if(!s3List.isEmpty()){
            DML.doUpdate(s3List);
            //update s3List;    
         }
                         
     }

     /*
        * Method Name: saveDocumentChanges
        * Created By : Ayush Vijayvergia
        * Description: Method to save changes made for a document
        * @param:      String jsonData
        * @return:     none
    */

     @AuraEnabled
     public static void saveDocumentChanges(String jsonData){
        List<CategoryToDocumentWrapper> categoryToDocWrapper = (List<CategoryToDocumentWrapper>) JSON.deserialize(jsonData, List<CategoryToDocumentWrapper>.class);
        List<Document__c> docList = new List<Document__c>();
        Map<Id, String> docIdToStatusMap = new Map<Id, String>();
        List<innerFieldsWrapper> innerFieldsList = new List<innerFieldsWrapper>();
        Map<Id, S3_File__c> docIdToLastUploadedFile = new Map<Id, S3_File__c>();
        List<S3_File__c> s3FilesList = new List<S3_File__c>();
        
        for(CategoryToDocumentWrapper wrapperObj : categoryToDocWrapper){
           innerFieldsList.addAll(wrapperObj.innerFields);
        }
        
        for(innerFieldsWrapper innerField : innerFieldsList) {
            Document__c doc = new Document__c(Id = innerField.documentId);
            doc.Status__c = innerField.status;
            doc.Not_Applicable__c = innerField.documentNotApplicable;
            doc.Responsible_Party__c = innerField.responsibleParty;
            docList.add(doc);
            docIdToStatusMap.put(innerField.documentId, innerField.status);
        }

        if(docIdToStatusMap.size() > 0) {
           List<S3_File__c> s3FileList = [SELECT Id, Status__c, Document__c, CreatedDate 
                                            FROM S3_File__c 
                                            WHERE Document__c IN : docIdToStatusMap.keySet()
                                            //WITH SECURITY_ENFORCED
                                            ];
           for(S3_File__c file : s3FileList) {
               if(!docIdToLastUploadedFile.containsKey(file.Document__c)){
                  docIdToLastUploadedFile.put(file.Document__c, file);
               } else {
                  if(file.CreatedDate > docIdToLastUploadedFile.get(file.Document__c).CreatedDate) {
                    docIdToLastUploadedFile.put(file.Document__c, file);
                  }    
               }              
           }

           if(docIdToLastUploadedFile.size() > 0){
              for(Id docId : docIdToLastUploadedFile.keySet()) {
                S3_File__c lastUploadedFile = new S3_File__c(Id = docIdToLastUploadedFile.get(docId).Id);
                lastUploadedFile.Status__c = docIdToStatusMap.get(docId);
                s3FilesList.add(lastUploadedFile);
              }
           }
        }

        if(docList.size() > 0){
            DML.doUpdate(docList);
           //update docList;
        }

        if(s3FilesList.size() > 0){
            DML.doUpdate(s3FilesList);
            //update s3FilesList;
        }
     }

     /*
        * Method Name: saveDocumentChangesRP
        * Created By : Ayush Vijayvergia
        * Description: Method to save changes made for a document of Non-GSA account
        * @param:      String jsonData
        * @return:     none
    */

     @AuraEnabled
     public static void saveDocumentChangesRP(String jsonData){
        List<innerFieldsWrapper> innerFieldsList = (List<innerFieldsWrapper>) JSON.deserialize(jsonData, List<innerFieldsWrapper>.class);
        List<Document__c> docList = new List<Document__c>();    
        Map<Id, String> docIdToStatusMap = new Map<Id, String>();
        Map<Id, S3_File__c> docIdToLastUploadedFile = new Map<Id, S3_File__c>();
        List<S3_File__c> s3FilesList = new List<S3_File__c>();

        for(innerFieldsWrapper innerField : innerFieldsList) {
            Document__c doc = new Document__c(Id = innerField.documentId);
            doc.Status__c = innerField.status;
            doc.Not_Applicable__c = innerField.documentNotApplicable;
            doc.Responsible_Party__c = innerField.responsibleParty;
            docList.add(doc);
            docIdToStatusMap.put(innerField.documentId, innerField.status);
        }

        if(docIdToStatusMap.size() > 0) {
            List<S3_File__c> s3FileList = [SELECT Id, Status__c, Document__c, CreatedDate 
                                            FROM S3_File__c 
                                            WHERE Document__c IN : docIdToStatusMap.keySet()
                                            //WITH SECURITY_ENFORCED
                                            ];
            for(S3_File__c file : s3FileList) {
                if(!docIdToLastUploadedFile.containsKey(file.Document__c)){
                   docIdToLastUploadedFile.put(file.Document__c, file);
                } else {
                   if(file.CreatedDate > docIdToLastUploadedFile.get(file.Document__c).CreatedDate) {
                     docIdToLastUploadedFile.put(file.Document__c, file);
                   }    
                }              
            }
 
            if(docIdToLastUploadedFile.size() > 0){
               for(Id docId : docIdToLastUploadedFile.keySet()) {
                 S3_File__c lastUploadedFile = new S3_File__c(Id = docIdToLastUploadedFile.get(docId).Id);
                 lastUploadedFile.Status__c = docIdToStatusMap.get(docId);
                 s3FilesList.add(lastUploadedFile);
               }
            }
         }

        if(docList.size() > 0){
            DML.doUpdate(docList);
           //update docList;
        } 

        if(s3FilesList.size() > 0){
            DML.doUpdate(s3FilesList);
            //update s3FilesList;
        }
     }

     /*
        * Method Name: getCommunications
        * Created By : Ayush Vijayvergia
        * Description: Method to fetch all tasks for a document
        * @param:      String docId
        * @return:     none
    */
     
    @AuraEnabled(cacheable=true)
	public static List<TasksWrapper> getCommunications(String docId){
        List<Task> taskList = new List<Task>();
        List<TasksWrapper> communicationsList = new List<TasksWrapper>();
                  
        Document__c document = [SELECT Id, (SELECT id,subject,activitydate,createddate, status,type,priority,Description,createdby.name 
                                FROM tasks
                                ORDER BY activitydate DESC)
                                FROM Document__c 
                                WHERE (Id =: docId) 
                                //WITH SECURITY_ENFORCED
                                 LIMIT 1];
        
         
        if(document != null) {
           taskList = document.Tasks;
           if(taskList.size() > 0) {
              for(Task task : taskList){
                TasksWrapper communication = new TasksWrapper(task);
                communicationsList.add(communication);
              }
           }
        }
                     
		return communicationsList;
     }

     /*
        * Method Name: getAllPicklistValue
        * Created By : Ayush Vijayvergia
        * Description: Method to fetch all picklist values for an S3 file status
        * @param:      none
        * @return:     Map < String, Object >
    */

     @AuraEnabled
     public static Map < String, Object > getAllPicklistValue() {
         Map < String, Object > response = new Map < String, Object > ();
 
         response.put('status', fetchPicklist('S3_File__c', 'Status__c'));
 
         return response;
     }

     /*
        * Method Name: getAccountAndDocInfo
        * Created By : Gunjan Khandelwal
        * Description: Method to fetch Provider and Document Info
        * @param:      none
        * @return:     Boolean
    */

    @AuraEnabled
    public static Boolean getAccountAndDocInfo(String docId , String accId) {
        Boolean response = false;
        String docResponsibleParty;
        String providerType;

        for(Account acc : [SELECT Id,RecordType.Name FROM Account WHERE Id =: accId]){
            providerType = acc.RecordType.Name;
        }

        for(Document__c doc : [SELECT Id,Responsible_Party__c,Provider__r.RecordType.Name 
                                FROM Document__c 
                                WHERE Id =: docId
                                //WITH SECURITY_ENFORCED
                                ]){
            docResponsibleParty = doc.Responsible_Party__c;
        }
        if(providerType != 'Umbrella' && docResponsibleParty == 'Umbrella'){
            response = true;
        }
        return response;
    }

     /*
        * Method Name: fetchPicklist
        * Created By : Rahul Taneja
        * Description: Method to fetch all picklist values for an Object's Picklist field
        * @param:      String objectName 
        * @param:      String fieldName
        * @return:     List < SelectOptionWrapper >
    */
    
     @AuraEnabled
    public static List < SelectOptionWrapper > fetchPicklist(String objectName, String fieldName) {
        List < SelectOptionWrapper > opts = new List < SelectOptionWrapper > ();

        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map < String, Schema.SObjectField > fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry pickListVal: ple) {
            opts.add(new SelectOptionWrapper(pickListVal.getValue(), pickListVal.getLabel()));
        }

        return opts;
    }

    /*
        * Method Name: sendRejectedDocsToProvider
        * Created By : Ayush Vijayvergia
        * Description: Method to return the suitable Message to User on UI
        * @param:      String accId 
        * @return:     String
    */

    @AuraEnabled
    public static String sendRejectedDocsToProvider(String accId) {
        String notficationToProviderTemplate = 'Notification_to_Provider_after_Documents_Sent_For_Revision';
        String templateBody;
        String response = null;
        List<Task> taskList = new List<Task>();
        Account accRecord = [SELECT Id, Name,RecordType.Name, Provider_Email__c, OwnerId, Electronic_Communication__c FROM Account WHERE id =: accId ]; 
        List<OrgWideEmailAddress> orgList = [SELECT Id 
    										 FROM OrgWideEmailAddress 
    										 WHERE DisplayName = 'EEC LEAD Alert'
                                             //WITH SECURITY_ENFORCED
                                             ];
        EmailTemplate template37 = [SELECT id,Body, Subject ,HtmlValue, Name
        							FROM EmailTemplate 
        							WHERE DeveloperName =: notficationToProviderTemplate
                                    //WITH SECURITY_ENFORCED
                                    ];
        List<Document__c> documentsRecList = new List<Document__c>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
	    Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
	    Messaging.SingleEmailMessage newEmail;
	    string documentName = '';
        for(Document__c documentsRec:[SELECT Id, Name,Status__c,EEC_Note_For_Revision__c,Document_Type__c,Document_Type__r.Name, Document_Type__r.Document_Type_Name__c
                                                                FROM Document__c 
                                                                WHERE Provider__c =: accId
                                                                AND Status__c = 'Returned for Revision'
                                                                AND Document_Type__r.LEAD_Configuration__r.Name =: accRecord.RecordType.Name
                                                                //WITH SECURITY_ENFORCED
                                                                ]){
	        documentsRecList.add(documentsRec);                                        	
        	newEmail = Messaging.renderStoredEmailTemplate(template37.id,accRecord.id,documentsRec.id); // Object Must have 'Allow Activities' ON.
        	templateBody = newEmail.HTMLBody;
        	if(templateBody.contains('#Account_List_of_Document_To_Be_sent')){
        		documentName += '* ' + ((String.isNotBlank(documentsRec.Document_Type__r.Document_Type_Name__c) && (documentsRec.Document_Type__r.Document_Type_Name__c != null )) ? documentsRec.Document_Type__r.Document_Type_Name__c : documentsRec.Document_Type__r.Name) +'<br/>' + '<br/>';
        		templateBody = templateBody.replace('#Account_List_of_Document_To_Be_sent',documentName);
        	}
        }
       if(!accRecord.Electronic_Communication__c) {
            response = 'This Provider does not use Electronic Communication, and this transaction can not be sent back to Provider using this functionality.';
            return response;
        }  
       if(documentsRecList.size() <= 0) {
            response = 'Currently, there are no documents that has been marked as Returned for Revision and ready to be sent to the provider. Review the document and update the ones that must be sent back to the Provider for revision with status "Returned for Revision".';
            return response;
        } 
       	newEmail.HTMLBody = templateBody;
        List<String> toemailIdsToSendEmail = new List<String>();
		if(accRecord.Provider_Email__c != null){
			toemailIdsToSendEmail.add(accRecord.Provider_Email__c);
		}
		if(newEmail != null) {
            mailToBeSent.setOrgWideEmailAddressId(orgList[0].id);
            mailToBeSent.setSubject(newEmail.subject);
            mailToBeSent.setHtmlBody(newEmail.HTMLBody);
            mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
            if(toemailIdsToSendEmail.size() > 0) {
                mailToBeSent.setToAddresses(toemailIdsToSendEmail);
            }
            if(toemailIdsToSendEmail.size() > 0) {
                emailList.add(mailToBeSent);
                //S-00138
                Task tsk = new Task();
                tsk.Status = 'completed';
                tsk.Priority = 'Normal';
                tsk.OwnerId = accRecord.OwnerId;
                tsk.Subject = template37.Name + ' Notification';
                tsk.WhatId = accRecord.Id;
                tsk.Description = 'EmailTemplate-Notification_to_Provider_after_Documents_Sent_For_Revision';
                tsk.ActivityDate = Date.today();
                taskList.add(tsk);
            }
        }
        if(emailList.size()>0){
         	Messaging.sendEmail(emailList); 
            try {
                if(!taskList.isEmpty()) {
                    DML.doInsert(taskList);
                    //insert taskList;
                }
            } catch(Exception ex) {
                response = ex.getMessage();
                return response;
            }
        }
        return response;
    }

    /*
        * Method Name: getAllDocumentsFor_R_P
        * Created By : Ayush Vijayvergia
        * Description: Method to fetch all documents for R&P records
        * @param:      String accId 
        * @return:     List<innerFieldsWrapper>
    */
    
    @AuraEnabled
    public static List<innerFieldsWrapper> getAllDocumentsFor_R_P (String accountId) {
        List<Document__c> documents = new List<Document__c>();
        List<innerFieldsWrapper> innerFieldsList = new List<innerFieldsWrapper>();
        String umbrellaId;
        String providerRecordType;

        for(Account acc : [SELECT Id, Is_GSA__c, Is_R_P__c,Umbrella_Members__c,RecordType.Name 
                            FROM Account 
                            WHERE Id = :accountId
                            //WITH SECURITY_ENFORCED
                            ]){
            umbrellaId = acc.Umbrella_Members__c;
            providerRecordType = acc.RecordType.Name;
       }

        for(Document__c doc : [SELECT Id,Provider__r.RecordType.Name,(SELECT id,subject,activitydate,createddate, status,type,priority,Description,createdby.name
                               FROM tasks
                               ORDER BY activitydate DESC), Name,LEAD_Configuration__r.Name,CreatedDate, Status__c, Document_Type__c,Uploaded_Date__c,Expiration_Date__c, Document_Type__r.Name, Document_Type__r.Document_Type_Name__c,
                               Document_Type__r.Help_Text__c, EEC_Note_For_Revision__c,Responsible_Party__c,Library_Level__c,Document_Type__r.Library_Level__c,Notes__c, Category__c, Document_Type__r.Sub_Category__c,
                               Attachment_Status__c,Document_Type__r.Not_Applicable__c,Not_Applicable__c,Document_Type__r.LEAD_Configuration__r.Name
                               FROM Document__c 
                               WHERE (Provider__c =: accountId OR Provider__c =: umbrellaId) 
                               AND (Document_Type__r.Library_Level__c = true 
                               OR Library_Level__c = true) 
                               AND Responsible_Party__c != null 
                               //WITH SECURITY_ENFORCED
                               ORDER BY Document_Type__r.Name ASC]){
            if(doc.LEAD_Configuration__r.Name == providerRecordType){
                documents.add(doc);
            }
        }

        for(Document__c doc : documents) {
            innerFieldsWrapper innerFields = new innerFieldsWrapper(doc, doc.Category__c, false,providerRecordType);
            innerFieldsList.add(innerFields);
        }

        return innerFieldsList;
    }

    /*
        * Method Name: is_GSA_Or_RP
        * Created By : Ayush Vijayvergia
        * Description: Method to check if an account record is of either GSA/R&P type
        * @param:      String accId 
        * @return:     Boolean
    */

    @AuraEnabled
    public static Boolean is_GSA_Or_RP(String accId) {
       Account acc = [SELECT Is_GSA__c, Is_R_P__c, RecordTypeId
                      FROM Account
                      WHERE id =: accId
                      //WITH SECURITY_ENFORCED 
                      LIMIT 1];

       Boolean is_GSA = acc.Is_GSA__c;
       Boolean is_RP = acc.Is_R_P__c;

       String recordTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(acc.RecordTypeId).getName();
       Boolean isUmbrella = recordTypeName == 'Umbrella' ? true : false;

       if(is_GSA || is_RP || isUmbrella) {
          return true;
       } else {
           return false;
       }
    }

    /*
        * Method Name: is_GSA
        * Created By : Ayush Vijayvergia
        * Description: Method to check if an account record is GSA
        * @param:      String accId 
        * @return:     Boolean
    */

    @AuraEnabled(cacheable=true)
    public static Boolean is_GSA(String accId) {
       Account acc = [SELECT Is_GSA__c, Is_R_P__c
                      FROM Account
                      WHERE id =: accId 
                      //WITH SECURITY_ENFORCED
                      LIMIT 1];

       Boolean is_GSA = acc.Is_GSA__c;

       if(is_GSA) {
          return true;
       } else {
           return false;
       }
    }

    /*
        * Method Name: is_RP
        * Created By : Ayush Vijayvergia
        * Description: Method to check if an account record is R&P type
        * @param:      String accId 
        * @return:     Boolean
    */

    @AuraEnabled(cacheable=true)
    public static Boolean is_RP(String accId) {
       Account acc = [SELECT Is_GSA__c, Is_R_P__c
                      FROM Account
                      WHERE id =: accId 
                      //WITH SECURITY_ENFORCED
                      LIMIT 1];

       Boolean is_RP = acc.Is_R_P__c;

       if(is_RP) {
          return true;
       } else {
           return false;
       }
    }

    /*
        * Method Name: is_Umbrella
        * Created By : Ayush Vijayvergia
        * Description: Method to check if an account record is Umbrella type
        * @param:      String accId 
        * @return:     Boolean
    */

    @AuraEnabled(cacheable=true)
    public static Boolean is_Umbrella(String accId) {
       Account acc = [SELECT RecordTypeId
                      FROM Account
                      WHERE id =: accId 
                      //WITH SECURITY_ENFORCED
                      LIMIT 1];

        String recordTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(acc.RecordTypeId).getName();
        Boolean isUmbrella = recordTypeName == 'Umbrella' ? true : false;
               
       if(isUmbrella) {
          return true;
       } else {
           return false;
       }
    }

    /*
        * Method Name: getProviderId
        * Created By : Rahul Taneja
        * Description: Method to get the Provider Id for a transaction
        * @param:      String transactionId
        * @return:     String
    */

    @AuraEnabled(cacheable=true)
    public static String getProviderId(String transactionId) {
        Licensing_Transaction__c transactionObj = [SELECT Provider__c
                                                   FROM Licensing_Transaction__c
                                                   WHERE id =: transactionId 
                                                   //WITH SECURITY_ENFORCED
                                                   LIMIT 1];

       String providerId = transactionObj.Provider__c;
       return providerId;
    }

    /*
        * Method Name: getAllDocumentsForSubCategory
        * Created By : Ayush Vijayvergia
        * Description: Method to get all documents with a particular sub category
        * @param:      String accId 
        * @param:      String subCategory
        * @return:     List<innerFieldsWrapper>
    */

    @AuraEnabled
    public static List<innerFieldsWrapper> getAllDocumentsForSubCategory(String accId, String subCategory) {
        List<Document__c> documents = new List<Document__c>();
        List<innerFieldsWrapper> innerFieldsList = new List<innerFieldsWrapper>();
        String providerRecordType;
        String umbrella;
        for(Account acc : [SELECT Id,RecordType.Name,Umbrella_Members__c 
                            FROM Account 
                            WHERE Id =: accId
                            //WITH SECURITY_ENFORCED
                            ]){
            providerRecordType = acc.RecordType.Name;
            umbrella = acc.Umbrella_Members__c;
        }
        Boolean isUmbrella = is_Umbrella(accId);

        for(Document__c doc : [SELECT Id,Provider__r.RecordType.Name,(SELECT id,subject,activitydate,createddate, status,type,priority,Description,createdby.name
                                FROM tasks
                                ORDER BY activitydate DESC), Name,LEAD_Configuration__r.Name,CreatedDate, Status__c, Document_Type__c,Uploaded_Date__c,Expiration_Date__c, Document_Type__r.Name, Document_Type__r.Document_Type_Name__c,
                                Document_Type__r.Help_Text__c, EEC_Note_For_Revision__c,Responsible_Party__c,Library_Level__c,Document_Type__r.Library_Level__c,Notes__c, Category__c, Document_Type__r.Category_Description__c,
                                Attachment_Status__c,Document_Type__r.Not_Applicable__c,Not_Applicable__c,Document_Type__r.LEAD_Configuration__r.Name, Document_Type__r.Sub_Category__c
                                FROM Document__c 
                                WHERE (Provider__c =: accId OR Provider__c =: umbrella) 
                                AND (Document_Type__r.Library_Level__c = true 
                                OR Library_Level__c = true) 
                                AND Responsible_Party__c != null
                                AND Document_Type__r.Sub_Category__c =: subCategory
                                //WITH SECURITY_ENFORCED
                                ORDER BY Document_Type__r.Sequence__c ASC]){
            if(doc.LEAD_Configuration__r.Name == providerRecordType && !isUmbrella){
                documents.add(doc);
            }
            if(isUmbrella){
                documents.add(doc);
            }
        }

        for(Document__c doc : documents) {
            innerFieldsWrapper innerFields = new innerFieldsWrapper(doc, doc.Category__c, false,providerRecordType);
            innerFieldsList.add(innerFields);
        }

        return innerFieldsList;        
    }

    @AuraEnabled
    public static List<AWS_Config__c> getAWSCustomSetting(){
        return [SELECT id, Name, S3_Bucket_Name__c, 
                S3_Key__c, S3_New_Bucket_Name__c, S3_Secret__c 
                FROM AWS_Config__c
                //WITH SECURITY_ENFORCED
                ];
    }

    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;

        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }

    public class CategoryToDocumentWrapper{
        @AuraEnabled public List<innerFieldsWrapper> innerFields = new List<innerFieldsWrapper>();
        @AuraEnabled public String categoryName                     {get; set;}
        @AuraEnabled public String categoryDescription              {get; set;}
        @AuraEnabled public Boolean isAllDocsReviewed               {get; set;}

        public CategoryToDocumentWrapper(String category, List<Document__c> documents,String providerRecordType){
            this.categoryName = category;
            this.isAllDocsReviewed = true;
            Boolean categoryDescriptionFlag = false;
            String subCategoryOfDocumentType;
            Boolean isFirstDocumentOfSubCategory = false;
            for(Document__c doc : documents){
                if(String.isNotBlank(doc.Document_Type__c) &&  String.isNotBlank(doc.Document_Type__r.Sub_Category__c)){
                   if(String.isBlank(subCategoryOfDocumentType)) {
                      subCategoryOfDocumentType = doc.Document_Type__r.Sub_Category__c;
                      isFirstDocumentOfSubCategory = true;
                   } else {
                       if(subCategoryOfDocumentType == doc.Document_Type__r.Sub_Category__c) {
                        isFirstDocumentOfSubCategory = false;
                       } else {
                        isFirstDocumentOfSubCategory = true;
                       }
                   }
                }

                innerFieldsWrapper documentFields = new innerFieldsWrapper(doc, category, isFirstDocumentOfSubCategory,providerRecordType);
                this.innerFields.add(documentFields);

                if(doc.Status__c != 'Legacy Reviewed') {
                    this.isAllDocsReviewed = false;
                }

                if(!categoryDescriptionFlag) {
                    if(String.isNotBlank(doc.Document_Type__r.Category_Description__c)) {
                        this.categoryDescription = doc.Document_Type__r.Category_Description__c;
                        categoryDescriptionFlag = true;
                    }
                }
            }
        }
    }

    public class innerFieldsWrapper{
        @AuraEnabled public String documentTypeName                            {get; set;}
        @AuraEnabled public String providerType                                {get; set;}
        @AuraEnabled public String programType                                 {get; set;}
        @AuraEnabled public String documentName                                {get; set;}
        @AuraEnabled public String responsibleParty                            {get; set;}
        @AuraEnabled public Date expirationDate                                {get; set;}
        @AuraEnabled public Date uploadedDate                                  {get; set;}
        @AuraEnabled public String status                                      {get; set;}
        @AuraEnabled public String documentId                                  {get; set;}
        @AuraEnabled public Boolean documentNotApplicable                      {get; set;}
        @AuraEnabled public Boolean documentTypeNotApplicable                  {get; set;}
        @AuraEnabled public Boolean isUmbrella                                 {get; set;}
        @AuraEnabled public String category                                    {get; set;}
        @AuraEnabled public String subCategory                                 {get; set;}
        @AuraEnabled public String helpText                                    {get; set;}
        @AuraEnabled public Boolean isUnsubmitted                              {get; set;}
        @AuraEnabled public Boolean isLegacyReviewed                           {get; set;}
        @AuraEnabled public Boolean isReturnedForRevision                      {get; set;}
        @AuraEnabled public Boolean isOtherStatus                              {get; set;}
        @AuraEnabled public Boolean isFirstDocTypeUnderSubCategory             {get; set;}
        @AuraEnabled public Boolean isLegacyDocumentType                       {get; set;}

        public innerFieldsWrapper(Document__c document, String category, Boolean isFirstDocTypeUnderSubCategory,String providerRecordType){
            if(String.isNotBlank(document.Document_Type__c)){
                this.isLegacyDocumentType = false;
               this.providerType = providerRecordType;
               this.documentTypeName = document.Document_Type__r.Document_Type_Name__c;
               this.documentName = document.Document_Type__r.Name;
               this.programType = document.Document_Type__r.LEAD_Configuration__r.Name;
               this.responsibleParty = document.Responsible_Party__c;
               this.documentTypeNotApplicable = document.Document_Type__r.Not_Applicable__c;
               this.helpText = document.Document_Type__r.Help_Text__c != null ? document.Document_Type__r.Help_Text__c.stripHtmlTags() : '';

               if(this.responsibleParty == 'Umbrella' && this.providerType != 'Umbrella'){
                    this.isUmbrella = true;
                    this.isLegacyDocumentType = true;
                }else{
                    this.isUmbrella = false;
                }

               if(this.documentTypeName != null){
                    if(this.documentTypeName.contains('Legacy Document Type')){
                        this.isLegacyDocumentType = true;
                    }
               }
               if(String.isNotBlank(document.Document_Type__r.Sub_Category__c)){
                  this.subCategory = document.Document_Type__r.Sub_Category__c;
                  this.isFirstDocTypeUnderSubCategory = isFirstDocTypeUnderSubCategory;
               }
            }
            
            this.expirationDate = document.Expiration_Date__c;
            this.uploadedDate = document.Uploaded_Date__c;
            
            this.status = document.Status__c;    
            this.documentId = document.Id;
            this.documentNotApplicable = document.Not_Applicable__c;
            this.category = category;
            if(document.Status__c == 'Unsubmitted' || 
                (this.responsibleParty == 'Umbrella' && this.providerType != 'Umbrella')){
                this.isUnsubmitted = true;
            }else{
                this.isUnsubmitted = false;
            }
            this.isLegacyReviewed = document.Status__c == 'Legacy Reviewed' ? true : false;
            this.isReturnedForRevision = document.Status__c == 'Returned for Revision' ? true : false;

            if(String.isNotBlank(document.Status__c)){
                if((document.Status__c != 'Legacy Reviewed') && (document.Status__c != 'Returned for Revision')) {
                    this.isOtherStatus = true;
                } else {
                    this.isOtherStatus = false;
                }
            }
        }
    }

    public class DocFilesWrapper{
        @AuraEnabled public String fileId       ;
        @AuraEnabled public String fileName     ;
        @AuraEnabled public String status       ;
        @AuraEnabled public String uploadedBy   ;
        @AuraEnabled public String uploadedDate ;
        @AuraEnabled public String internalNotes;
        @AuraEnabled public String prefix       ;
        @AuraEnabled public String documentUrl  ;

        public DocFilesWrapper(S3_File__c file){
          this.fileId = file.Id!=null?file.Id:'';
          this.fileName = file.Filename__c!=null?file.Filename__c:'';
          this.status = file.Status__c!=null?file.Status__c:'';
          this.uploadedBy = file.CreatedBy.Name!=null?file.CreatedBy.Name:'';
          this.uploadedDate = file.CreatedDate!=null?file.CreatedDate.format('MM/dd/yyyy HH:mm:ss'):'';
          this.internalNotes = file.Comments__c!=null?file.Comments__c:'';
          this.prefix = file.Prefix__c!=null?file.Prefix__c:'';
          this.documentUrl = file.Document_URL__c!=null?file.Document_URL__c:'';
        }
    }

    public class TasksWrapper{
        @AuraEnabled public String subject               {get; set;}
        @AuraEnabled public String id               {get; set;}
        @AuraEnabled public String message               {get; set;}
        @AuraEnabled public String activityDate          {get; set;}
        @AuraEnabled public String createdBy             {get; set;}

        public TasksWrapper(Task task){
          this.subject = task.subject;
          this.id = task.id;
          this.message = task.Description;
          this.activityDate = task.activitydate.format();
          this.createdBy = task.createdby.name;
        }
    }
}