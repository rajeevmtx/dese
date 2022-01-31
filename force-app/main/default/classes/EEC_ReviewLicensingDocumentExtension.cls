public with sharing class EEC_ReviewLicensingDocumentExtension {
    public Licensing_Transaction__c licensingTransaction                    {get; set;}
    public Boolean isEditMode                                               {get; set;}
    public Boolean isS3EditMode                                             {get; set;}
    public Boolean isSendDocumentsToProviderApplicable                      {get; set;}
    public boolean reloadPage                                               {get; set;}
    public List<TransactionDocumentWrapper> transactionDocumentWrapperList  {get; set;}
    private Map<String, List<S3_File__c>> documentAttachmentMap;
    private Map<String,Transaction_Document__c> transactionDocumentIdMap;
    public EEC_ReviewLicensingDocumentExtension(ApexPages.StandardController stdCtrl){
        licensingTransaction = (Licensing_Transaction__c)stdCtrl.getRecord();
        licensingTransaction = [SELECT Id, Status__c, Source__c, Provider__r.Electronic_Communication__c
                                    FROM Licensing_Transaction__c
                                    WHERE Id =:licensingTransaction.Id ];
        isSendDocumentsToProviderApplicable = false;
        isEditMode = false;
        isS3EditMode = false;
        reloadPage = true;
        transactionDocumentWrapperList = new List<TransactionDocumentWrapper>();
    }
    public void setEditMode() {
        isEditMode = true;
    }
    public void cancelChanges() {
        isEditMode = false;
    }
    public List<TransactionDocumentWrapper> getAllDocuments() {
        transactionDocumentWrapperList = new List<TransactionDocumentWrapper>();
        Map<String,List<Task>> documentToTask = new Map<String,List<Task>>();
        documentAttachmentMap = new Map<String, List<S3_File__c>>();
        transactionDocumentIdMap = new Map<String,Transaction_Document__c>();
        try {
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
                                                    WHERE Licensing_Transaction__c =: licensingTransaction.Id
                                                    AND Document__c != null
                                                    ORDER BY Is_Required__c DESC, Mode__c]){
                transactionDocumentIdMap.put(doc.Document__c,doc);
                if(!documentToTask.containsKey(doc.Document__c)) {
                    documentToTask.put(doc.Document__c, new List<Task>());
                }
                if(!documentAttachmentMap.containsKey(doc.Document__c)){
                    documentAttachmentMap.put(doc.Document__c, new List<S3_File__c>());
                }
            }
            for(Document__c doc :[SELECT Id,
                                        Not_Applicable__c,
                                        Notes__c,
                                        (SELECT Id, 
                                            Subject,
                                            Activitydate,
                                            Createddate, 
                                            Status,
                                            Type, 
                                            Priority,
                                            Description,
                                            Createdby.name
                                        FROM tasks
                                        ORDER BY activitydate DESC) 
                                    FROM Document__c 
                                    WHERE Id=: transactionDocumentIdMap.keyset()]){
                for(Task task : doc.tasks) {
                    documentToTask.get(doc.Id).add(task);   
                }
            }
            for(S3_File__c file : [SELECT Id,
                                            Name,
                                            Document__c, 
                                            Filename__c,
                                            Document_URL__c,
                                            Internal_Upload__c,
                                            Status__c,
                                            CreatedDate,
                                            CreatedBy.Name,
                                            Comments__c
                                        FROM S3_File__c 
                                        WHERE Document__c IN : transactionDocumentIdMap.keyset() 
                                        ORDER BY CreatedDate DESC]){
                documentAttachmentMap.get(file.Document__c).add(file);
            }
            for(String documentId : transactionDocumentIdMap.keyset()) {
                Transaction_Document__c transactionDocument = transactionDocumentIdMap.get(documentId);
                transactionDocumentWrapperList.add(new TransactionDocumentWrapper(transactionDocument, documentAttachmentMap.get(documentId), documentToTask.get(documentId)));
            }
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
        }
        return transactionDocumentWrapperList;
    }
    public String generateS3Link() {
        String attachmentId = ApexPages.CurrentPage().getParameters().get('attachmentId');
        if(String.isNotBlank(attachmentId)) {
            return generateS3Link(attachmentId);
        } 
        return '';
    }
    public String generateS3Link(String fileId) {
        String filename = '';
        S3_File__c file = [SELECT Id, 
                                Name, 
                                Filename__c, 
                                Prefix__c, 
                                Bucket__c, 
                                Document_URL__c, 
                                Status__c, 
                                CreatedDate, 
                                CreatedBy.Name, 
                                Comments__c 
                            FROM S3_File__c 
                            WHERE Id = :fileId];
        if(file.Document_URL__c != null){
            return file.Document_URL__c;
        } else {
            AWSKeys creds = new AWSKeys('eec');
            if (!String.isBlank(file.Prefix__c)) {
                filename += file.Prefix__c + '/';
            }
            filename += file.Filename__c;
            if(!test.isRunningTest()){
                return EEC_S3ComponentCtrl.generateTempS3Url(file.Bucket__c, EncodingUtil.urlEncode(filename, 'UTF-8'), creds);
            } else {
                return 'testAWSKeys';
            }
        }
    }
    /* public void updateS3File(){
        try {
            S3_File__c tempFile;
            String documentId = ApexPages.CurrentPage().getParameters().get('documentId');
            String fileId = ApexPages.CurrentPage().getParameters().get('fileId');
            reloadPage = true;
            if(String.isNotBlank(documentId) && documentAttachmentMap.containsKey(documentId)) {
                for(S3_File__c s3FileObj : documentAttachmentMap.get(documentId)) {
                    if(String.isNotBlank(fileId) && s3FileObj.Id == fileId) {
                        tempFile = new S3_File__c(Id = s3FileObj.Id, Status__c = s3FileObj.Status__c, Comments__c = s3FileObj.Comments__c);
                        break;
                    }
                }
                if(tempFile != null){
                    update tempFile;
                }
            }
        } catch(Exception ex) {
            reloadPage = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
        }
    } */
    public Pagereference saveProjectDocuments() {
        try{
            List<Transaction_Document__c> transactionDocumentList = new List<Transaction_Document__c>(); 
            List<Document__c> documentList = new List<Document__c>(); 
            reloadPage = true;
            List<S3_File__c> attachmentList = new List<S3_File__c>();
            for(TransactionDocumentWrapper temp : transactionDocumentWrapperList){
                if(temp.document.Status__c == EEC_Constants.TRANSACTION_DOCUMENT_STATUS_REVIEWED && (temp.document.Document_Attachment_Status__c == EEC_Constants.TRANSACTION_DOCUMENT_STATUS_ATTACHMENT_NO_ATTACHMENT)){
                    reloadPage = false;
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A document can only be approved if it has a attached file.');
                    ApexPages.addMessage(errMsg);
                    return null;
                }
                transactionDocumentList.add(temp.document);
                documentList.add(new Document__c(Id= temp.document.Document__c, Not_Applicable__c = temp.document.Document__r.Not_Applicable__c));
            }
            for(String documentId : documentAttachmentMap.keyset()) {
                for(S3_File__c file : documentAttachmentMap.get(documentId)) {
                    if(transactionDocumentIdMap.containsKey(documentId) && file.Status__c == EEC_Constants.S3_FILE_STATUS_SUBMITTED) {
                        file.Status__c = transactionDocumentIdMap.get(documentId).Status__c;
                        attachmentList.add(file);
                    }
                }
            }
            if(!transactionDocumentList.isEmpty()){
                update transactionDocumentList;
            }
            if(!attachmentList.isEmpty()){
                update attachmentList;
            }
            if(!documentList.isEmpty()) {
                update documentList;
            }
            isEditMode = false; 
        } catch(DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
        }
        return null;
    }
    public PageReference sendRejectDocumentsToProvider() {
        isSendDocumentsToProviderApplicable = false;
        List<Transaction_Document__c> transactionDocuments = [SELECT Id, Name 
                                                                FROM Transaction_Document__c 
                                                                WHERE Licensing_Transaction__c =: licensingTransaction.Id
                                                                AND Status__c =:EEC_Constants.TRANSACTION_DOCUMENT_STATUS_RETURNED_FOR_REVISION];
        if(licensingTransaction.Status__c == EEC_Constants.LT_UNSUBMITTED || licensingTransaction.Status__c == EEC_Constants.LT_CLOSED || licensingTransaction.Status__c == EEC_Constants.LT_CANCELLED) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'This transaction is not Submitted or is Closed or Cancelled, and can not be sent back to Provider.'));
            return null;
        }
        if(licensingTransaction.Source__c != 'Provider Portal') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'This transaction was not submitted from the Portal, and can not be sent back to Provider using this functionality.'));
            return null;
        }
        if(!licensingTransaction.Provider__r.Electronic_Communication__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'This Provider does not use Electronic Communication, and this transaction can not be sent back to Provider using this functionality.'));
            return null;
        }
        if(transactionDocuments.size() <= 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Currently, there is no document that has been marked as Returned for Revision and ready to be sent to the provider. Review the document and update the ones that must be sent back to the Provider for revision with status "Returned for Revision".'));
            return null;
        }
        isSendDocumentsToProviderApplicable = true;
        return null;
    }
    public void updateDocuments() {
        try {
            String documentId = ApexPages.CurrentPage().getParameters().get('documentId');
            List<S3_File__c> s3FileList = new List<S3_File__c>();
            if(String.isNotBlank(documentId)) {
                for(TransactionDocumentWrapper transactionDocumentWrap : transactionDocumentWrapperList) {
                    if(transactionDocumentWrap.document.Document__c == documentId) {
                        s3FileList.addAll(transactionDocumentWrap.fileAttachments);
                        break;
                    }
                }
            }
            if(!s3FileList.isEmpty()) {
                update s3FileList;
            }
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
        }
    }
    public class TransactionDocumentWrapper {
        public Transaction_Document__c document     {get; set;}
        public List<S3_File__c> fileAttachments     {get; set;}
        public List<Task> taskList                  {get; set;}
        public TransactionDocumentWrapper(Transaction_Document__c document, List<S3_File__c> fileAttachments, List<Task> taskList) {
            this.document = document;
            this.fileAttachments = fileAttachments;
            this.taskList = taskList;
        }
    }
}