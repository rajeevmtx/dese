public with sharing class EEC_ReviewLicensingDocumentExtensionLWC{
    @AuraEnabled(cacheable=true)
    public static Map<String, String> sendRejectDocumentsToProvider(String recordId) {
        
        Map<String, String> resultMap = new Map<String, String>();
        Licensing_Transaction__c licensingTransaction = [SELECT Id, Status__c,Source__c,Provider__r.Electronic_Communication__c, (SELECT Id, Name FROM Transaction_Documents__r WHERE Status__c =:EEC_Constants.TRANSACTION_DOCUMENT_STATUS_RETURNED_FOR_REVISION) 
                                                    FROM Licensing_Transaction__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
    
        if(licensingTransaction.Status__c == EEC_Constants.LT_UNSUBMITTED || licensingTransaction.Status__c == EEC_Constants.LT_CLOSED || licensingTransaction.Status__c == EEC_Constants.LT_CANCELLED) {
            
            resultMap.put('errormsg','This transaction is not Submitted or is Closed or Cancelled, and can not be sent back to Provider.');
        }
        else if(licensingTransaction.Source__c != 'Provider Portal') {
           
            resultMap.put('errormsg','This transaction was not submitted from the Portal, and can not be sent back to Provider using this functionality.');
        }
        else if(!licensingTransaction.Provider__r.Electronic_Communication__c) {
           
            resultMap.put('errormsg','This Provider does not use Electronic Communication, and this transaction can not be sent back to Provider using this functionality.');
        }
        else if(licensingTransaction.Transaction_Documents__r.size() <= 0) {
           
            resultMap.put('errormsg','Currently, there is no document that has been marked as Returned for Revision and ready to be sent to the provider. Review the document and update the ones that must be sent back to the Provider for revision with status "Returned for Revision".');
        }else{
            resultMap.put('errormsg','');
        }
        
        return resultMap;
    }

    @AuraEnabled
    public static List<TransactionDocumentWrapper> getAllDocuments(String applicationId) {
        
        
        List<TransactionDocumentWrapper> transactionDocumentWrapperList = new List<TransactionDocumentWrapper>();
      
           for(Transaction_Document__c doc : [SELECT Id, 
                                                        Name, 
                                                        Document__c, 
                                                        Document__r.Notes__c, 
                                                        Document__r.Status__c, 
                                                        Document__r.Document_Type__r.Name, 
                                                        Status__c, 
                                                        Document_Type__c, 
                                                        Document_Type__r.Name, 
                                                        Licensing_Transaction__c,
                                                        Note_For_Revision__c, 
                                                        Mode__c, 
                                                        Transaction_Document_Name__c,
                                                        Document_Attachment_Status__c,
                                                        Document__r.Not_Applicable__c
                                                    FROM Transaction_Document__c 
                                                    WHERE Licensing_Transaction__c =: applicationId
                                                    AND Document__c != null WITH SECURITY_ENFORCED
                                                    ORDER BY Is_Required__c DESC, Mode__c]){
    
         
         EEC_ReviewLicensingDocumentExtensionLWC.TransactionDocumentWrapper transactionWrapper=new EEC_ReviewLicensingDocumentExtensionLWC.TransactionDocumentWrapper ();
         TransactionDocumentWrapper  transactionResponse = new  TransactionDocumentWrapper();
         transactionResponse=transactionWrapper.getTransactionInfo(doc);
         
         transactionDocumentWrapperList.add(transactionResponse);
        }
         return transactionDocumentWrapperList;
    }
    
    @AuraEnabled
    public static List<FileWrapper> returnDocumentList(String applicationId){
        List<FileWrapper> fileWrapperList = new List<FileWrapper>();
        List<String> transactionList = new List<String>();
            for(Transaction_Document__c doc : [SELECT   Id, 
                                                        Name, 
                                                        Document__c, 
                                                        Document__r.Notes__c, 
                                                        Document__r.Status__c, 
                                                        Document__r.Document_Type__r.Name, 
                                                        Status__c, 
                                                        Document_Type__c, 
                                                        Document_Type__r.Name, 
                                                        Licensing_Transaction__c,
                                                        Note_For_Revision__c, 
                                                        Mode__c, 
                                                        Transaction_Document_Name__c,
                                                        Document_Attachment_Status__c,
                                                        Document__r.Not_Applicable__c
                                                    FROM Transaction_Document__c 
                                                    WHERE Licensing_Transaction__c =: applicationId
                                                    AND Document__c != null WITH SECURITY_ENFORCED
                                               ORDER BY Is_Required__c DESC, Mode__c]){
                                                transactionList.add(doc.Document__c);   
                                               }
       
         for(S3_File__c file :[SELECT Id,Name,
                                            Document__c, 
                                            Filename__c,
                                            Prefix__c,
                                            Document_URL__c,
                                            Internal_Upload__c,
                                            Status__c,
                                            CreatedDate,
                                            CreatedBy.Name,
                                            Comments__c,
                                            Description__c
                                        FROM S3_File__c 
                                        WHERE Document__c IN : transactionList 
                                        WITH SECURITY_ENFORCED
                                       ORDER BY CreatedDate DESC]){
                                           
                                       
         EEC_ReviewLicensingDocumentExtensionLWC.FileWrapper fileWrapper=new EEC_ReviewLicensingDocumentExtensionLWC.FileWrapper ();
         FileWrapper  fileResponse = new  FileWrapper();
         fileResponse=fileWrapper.getFileInfo(file);         
         fileWrapperList.add(fileResponse);
        }
         return fileWrapperList;        
                                     
    }
    public static void istaxDocumentSentForRevision(Licensing_Transaction__c licensingTransaction){
        try{
              licensingTransaction.Is_Tax_Certification_Resend__c = true;
              licensingTransaction.Tax_Certification_Status__c = 'Sent';
              licensingTransaction.Status__c = 'Submitted';
              licensingTransaction.Status_Reason__c = 'Pending Provider Response';
              DML.doUpdate(licensingTransaction);
              //update licensingTransaction;
        }catch(Exception e){
        }
      }
    @AuraEnabled
    public static void sendRejectedDocuments(String recordId){
        try{
            String notficationToProviderTemplate = 'Notification_to_Provider_after_Documents_Sent_For_Revision';
            String templateBody;
            Licensing_Transaction__c licensingTransaction = [SELECT Id,Provider__r.Provider_Email__c,Provider__c,Provider__r.Name 
                                                            FROM Licensing_Transaction__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
            List<OrgWideEmailAddress> orgList = [SELECT Id
                                                 FROM OrgWideEmailAddress 
                                                 WHERE DisplayName = :EEC_Constants.ORGWIDE_EMAIL_ADDRESS_DISPLAY_NAME
                                                 WITH SECURITY_ENFORCED];
            EmailTemplate template37 = [SELECT id,Body, Subject ,HtmlValue
                                        FROM EmailTemplate 
                                        WHERE DeveloperName =: notficationToProviderTemplate
                                        WITH SECURITY_ENFORCED];
            List<Transaction_Document__c> documentsRecList = new List<Transaction_Document__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
            Messaging.SingleEmailMessage newEmail;
            string documentName = '';
            Boolean istaxDocumentSentForRevision = false;
            for(Transaction_Document__c documentsRec:[SELECT Id, Name,Document_Type__c,Document_Type__r.Name ,Transaction_Document_Name__c
                                                      FROM Transaction_Document__c 
                                                      WHERE Licensing_Transaction__c =: recordId
                                                       AND Status__c = :EEC_Constants.TRANSACTION_DOCUMENT_STATUS_RETURNED_FOR_REVISION
                                                       WITH SECURITY_ENFORCED]){
                if(istaxDocumentSentForRevision = false && documentsRec.Transaction_Document_Name__c == EEC_Constants.TRANSACTION_DOCUMENT_NAME_TAX_CERTI_STATEMENT){
                    istaxDocumentSentForRevision = true;
                } 
                documentsRecList.add(documentsRec);
                newEmail = Messaging.renderStoredEmailTemplate(template37.id,licensingTransaction.Provider__c,documentsRec.id); // Object Must have 'Allow Activities' ON.
                templateBody = newEmail.HTMLBody;
                if(templateBody.contains('#Account_List_of_Document_To_Be_sent' ) && documentsRec.Document_Type__r.Name !=null){
                    documentName += documentsRec.Document_Type__r.Name +'<br/>';
                    templateBody = templateBody.replace('#Account_List_of_Document_To_Be_sent',documentName);
                }else{
                    if(documentsRec.Transaction_Document_Name__c != null){
                        documentName += documentsRec.Transaction_Document_Name__c +'<br/>';
                        templateBody = templateBody.replace('#Account_List_of_Document_To_Be_sent',documentName);
                    }else{
                        documentName += documentsRec.Name +'<br/>';
                        templateBody = templateBody.replace('#Account_List_of_Document_To_Be_sent',documentName);
                    }
                }
            }
      
        if(istaxDocumentSentForRevision){
            istaxDocumentSentForRevision(licensingTransaction);
        }
            newEmail.HTMLBody = templateBody;
            List<String> toemailIdsToSendEmail = new List<String>();
            if(licensingTransaction.Provider__r.Provider_Email__c != null){
                toemailIdsToSendEmail.add(licensingTransaction.Provider__r.Provider_Email__c);
            }
            if(newEmail != null) {
                      mailToBeSent.setOrgWideEmailAddressId(orgList[0].id);
                      mailToBeSent.setSubject(newEmail.subject);
                      mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                      mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                      if(toemailIdsToSendEmail.size() > 0) {
                        mailToBeSent.setToAddresses(toemailIdsToSendEmail);
                      }
                      // Secure the email sending
                      if(toemailIdsToSendEmail.size() > 0) {
                        emailList.add(mailToBeSent);
                     }
                  }
             if(emailList.size()>0){
                Messaging.sendEmail(emailList);  
             } 
            //isSendDocumentsToProviderApplicable = true;
           
        }
        catch(Exception ex){
            
        }
      }

    @AuraEnabled
    public static Map < String, Object > getAllPicklistValue() {
        Map < String, Object > response = new Map < String, Object > ();

        response.put('status', fetchPicklist('Document__c', 'Status__c'));

        return response;
    }

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

    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;

        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }

    @AuraEnabled
    public static Map<String,Object> saveDocuments(String jsonData){
        Map<String,Object> result = new Map<String,Object>();
        List<TransactionDocumentWrapper> transactionWrapperList = (List<TransactionDocumentWrapper>) JSON.deserialize(jsonData, List<TransactionDocumentWrapper>.class);
        List<Transaction_Document__c> transDocList = new List<Transaction_Document__c>();
        List<Document__c> docList = new List<Document__c>();

        Map<Id, String> docIdToStatusMap = new Map<Id, String>();
        Map<Id, S3_File__c> docIdToLastUploadedFile = new Map<Id, S3_File__c>();
        List<S3_File__c> s3FilesList = new List<S3_File__c>();

        try{
            for(TransactionDocumentWrapper tw : transactionWrapperList){
                Transaction_Document__c transactionDocument = new Transaction_Document__c();
                transactionDocument.Id=tw.Id;
                transactionDocument.Status__c=tw.status;
                Document__c doc = new Document__c(Id = tw.document,Not_Applicable__c=tw.documentNotApplicable);
                docList.add(doc);           
                transDocList.add(transactionDocument);
                docIdToStatusMap.put(tw.document, tw.status);
           }
           
           if(docIdToStatusMap.size() > 0) {
               List<S3_File__c> s3FileList = [SELECT Id, Status__c, Document__c, CreatedDate FROM S3_File__c WHERE Document__c IN : docIdToStatusMap.keySet() WITH SECURITY_ENFORCED];
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
   
           if(!docList.isEmpty()){
                DML.doUpdate(docList);
            }

               //update docList;
           if(!transDocList.isEmpty()){
            DML.doUpdate(transDocList);
           }
               //update transDocList;
           
   
           if(s3FilesList.size() > 0){
                DML.doUpdate(s3FilesList);
               //update s3FilesList;
           }
           result.put('success','Success!');
        }catch(DMLException e){
            result.put('error',e.getDmlMessage(0));
        }catch(Exception ex){
            result.put('error',ex.getMessage());
        }
        return result;
    }



         Public class TransactionDocumentWrapper{
            @AuraEnabled public String Id;
            @AuraEnabled public String name;
            @AuraEnabled public String document;
            @AuraEnabled public String documentNotes;
            @AuraEnabled public String documentStatus;
            @AuraEnabled public Boolean isUnsubmitted;
            @AuraEnabled public String documentdocumentTypeName;
            @AuraEnabled public String status;
            @AuraEnabled public String documentType;
            @AuraEnabled public String documentTypeName;
            @AuraEnabled public String licensingTransaction;
            @AuraEnabled public String noteForRevision;
            @AuraEnabled public String mode;
            @AuraEnabled public String transactionDocumentName;
            @AuraEnabled public String documentAttachmentStatus;
            @AuraEnabled public Boolean documentNotApplicable;
            @AuraEnabled public Boolean showDocRequiredError;

            public TransactionDocumentWrapper getTransactionInfo(Transaction_Document__c doc){
                TransactionDocumentWrapper transactionWrapper = new TransactionDocumentWrapper();
                transactionWrapper.Id=doc.Id != null ? doc.Id : '';
                transactionWrapper.name=doc.Name != null ? doc.Name : '';
                transactionWrapper.document=doc.Document__c != null ? doc.Document__c : '';
                transactionWrapper.documentNotes=doc.Document__r.Notes__c !=null ?doc.Document__r.Notes__c : '';              
                transactionWrapper.status=doc.Status__c != null ? doc.Status__c : ''; 
                transactionWrapper.isUnsubmitted = doc.Status__c == 'Unsubmitted' ? true : false;           
                transactionWrapper.mode=doc.Mode__c != null ? doc.Mode__c : '';
                transactionWrapper.transactionDocumentName=doc.Transaction_Document_Name__c != null ? doc.Transaction_Document_Name__c : '';               
                transactionWrapper.documentNotApplicable=doc.Document__r.Not_Applicable__c;
                if(doc.Document_Attachment_Status__c == 'No Attachment' && !doc.Document__r.Not_Applicable__c){
                    transactionWrapper.showDocRequiredError = true;
                }else{
                    transactionWrapper.showDocRequiredError = false;
                }
                return transactionWrapper;
            }
         }
    
    public class FileWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String document;
        @AuraEnabled public String fileName;
        @AuraEnabled public String prefix;
        @AuraEnabled public String documentURL;
        @AuraEnabled public String internalUpload;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String createdByName;
        @AuraEnabled public String comments;
        @AuraEnabled public String description;
        public FileWrapper getFileInfo(S3_File__c file){
            FileWrapper fileWrapper = new FileWrapper();            
            fileWrapper.fileName=file.Filename__c;           
            fileWrapper.status=file.Status__c;
            fileWrapper.createdDate=file.CreatedDate;
            fileWrapper.createdByName=file.CreatedBy.Name;
            return fileWrapper;            
        }        
    }     
}