public without sharing class EEC_LicensingAttachmentController { 
    public LEAD_Configuration__c leadConfiguration                      { get; set; }
    public Licensing_Transaction__c licenseTransaction                  { get; set; }
    public String accessKey                                             { get; set; }
    public string informationText                                       { get; set; }
    public List<TransactionDocumenWrapper> listRequiredDocument         { get; set; }
    public List<TransactionDocumenWrapper> listOptionalDocument         { get; set; }
    public List<TransactionDocumenWrapper> listIndividualDocument       { get; set; }
    public List<TransactionDocumenWrapper> listAdditionalDocument       { get; set; }
    public Map<Id, List<TransactionDocumenWrapper>> mapVarianceDocument { get; set; }
    public Map<string, string> mapVarianceIds                           { get; set; }
    public string formattedLicenseRecordTypeLabel                       { get; set; }
    public User loggedUser                                              { get; set; }
    public boolean isSaveOnly                                           { get; set; }
    public string providerRecordType                                    { get; set; }
    public boolean isInternalUser                                       { get; set; }
    private string accountId                                            { get; set; }
    private string ltId                                                 { get; set; }
    private AWS_Config__c aws                                           { get; set; }
    private AWSKeys credentials                                         { get; set; }
    private string bucket                                               { get; set; }
    public string previousPageName                                      { get; set; }
    public String highestStepReached                                    { get; set; }
    private String AWSCredentialName = 'eec';
    public boolean isDocumentExpired                                    { get; set; }
    public string urlvalue                                              { get; set; }
    public string providerId                                            { get; set; }
    public string accountName                                           { get; set; }
    public Boolean isTransactionClosedOrSubmitted;
    public class TransactionDocumenWrapper {
        public Transaction_Document__c transctionDocument               { get; set; }
        public Task[] taskList                                          { get; set; }
        public string mandatory                                         { get; set; }
        public string s3FileId                                          { get; set; }
        public string s3FileName                                        { get; set; }
        public boolean displayUmbrella                                  { get; set; }
        public boolean displayProvider                                  { get; set; }
        public List<String> listOfS3Files                               { get; set; }
        public TransactionDocumenWrapper() {
            taskList = new Task[]{
            };
        }
    }
    public EEC_LicensingAttachmentController() {
        isInternalUser = false;
        loggedUser = [select Id, Name, contactId, UserType from User where Id = :UserInfo.getUserId()];
        if (loggedUser.contactId == null) {
            isInternalUser = true;
        }
        isDocumentExpired = false;
        isSaveOnly = false;
        isTransactionClosedOrSubmitted = false;
        urlvalue = Apexpages.currentPage().getUrl();
        ltId = ApexPages.currentPage().getParameters().get('ltId');
        string memberId = ApexPages.currentPage().getParameters().get('member');
        List<Licensing_Transaction__c> ltList = new List<Licensing_Transaction__c>();
        for (Licensing_Transaction__c licens : [Select Id,Status__c,Provider__c,Provider__r.Name, (SELECT id,subject,activitydate,createddate, status,type,priority,Description,createdby.name
                                                                                                   FROM tasks
                                                                                                   ORDER BY activitydate DESC)
                                                FROM Licensing_Transaction__c
                                                where id = :ltId
        ]) {
            accountName = licens.Provider__r.Name;
            providerId = licens.Provider__r.Id;
            if (licens.Status__c == EEC_Constants.LT_CLOSED || licens.Status__c == EEC_Constants.LT_SUBMITTED || licens.Status__c == EEC_Constants.LT_UNDER_REVIEW) {
                isTransactionClosedOrSubmitted = true;
            }
            ltList.add(licens);
        }
       if (String.isNotBlank(ApexPages.currentPage().getParameters().get('previouspagename'))) {
            previousPageName = ApexPages.currentPage().getParameters().get('previouspagename');
       }
        if (String.isNotBlank(memberId)) {
            accountId = memberId;
        } else {
            List<Account> tempAccount = [Select Id From Account Where ID in (Select Accountid From User Where id = :Userinfo.getUserId()) Limit 1];
            if (tempAccount != null && tempAccount.size() == 1) {
                accountId = tempAccount.get(0).Id;
            }
        }
        EEC_Config__c config = EEC_Config__c.getOrgDefaults();
        Date todayDate = Date.Today();
        for (Document__c docObj : [SELECT Id, Document_Name__c, Document_Type__c,Status__c,Uploaded_Date__c,Expiration_Date__c
                                   FROM Document__c
                                   WHERE Provider__c = :accountId AND Not_Applicable__c = false
        ]) {
            if (docObj.Expiration_Date__c != null) {
                Integer numberOfdays = todayDate.daysBetween(docObj.Expiration_Date__c);
                if (numberOfdays <= config.Document_Expiration_Warning_Days__c) {
                    isDocumentExpired = true;
                    break;
                }
            }
            if (!string.isBlank(docObj.Status__c) && docObj.Status__c != EEC_Constants.DOCUMENT_STATUS_SUBMITTED && !isDocumentExpired) {
                isDocumentExpired = true;
                break;
            }
        }
        aws = AWS_Config__c.getInstance();
        bucket = aws.S3_Bucket_Name__c;
        string signedUrl = aws.S3_Endpoint_Url__c;
        credentials = new AWSKeys(AWSCredentialName);
        accessKey = credentials.key;
    }
    public void doViewDocuments() {
        List<Licensing_Transaction__c> ltList = [Select Id, Provider__c, RecordType.Name, RecordType.DeveloperName,RecordTypeId,Name,
                                                 Provider__r.RecordType.Name,Provider__r.Is_R_P__c,Provider__r.Is_GSA__c,
                                                 Provider__r.Is_FCC__c,Provider__r.RecordType.DeveloperName, Provider__r.Config_Record__c,
                                                 Transaction_Configuration__c, Highest_Reached_Step__c,Provider__r.Umbrella_Members__c,Status__c,
                                                 (Select Id, Associated_Regulation__c,Associated_Regulation__r.Name,
                                                  Associated_Regulation__r.Regulation_Number__c,Associated_Regulation__r.Article__c,
                                                  Provider_Alternative_Method_to_Comply__c,Provider_Understanding_of_Regulation__c
                                                  From Variance_on_Regulations__r)
                                                  From Licensing_Transaction__c l
                                                  where Id = :ltId
                                                  LIMIT 1
        ];
        if (ltList.size() > 0) {
            licenseTransaction = ltList[0];
            if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
                formattedLicenseRecordTypeLabel = EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY;
            } else {
                formattedLicenseRecordTypeLabel = licenseTransaction.RecordType.DeveloperName.replaceAll('_', ' ');
            }
        }
        highestStepReached = licenseTransaction.Highest_Reached_Step__c;
        System.debug(licenseTransaction.RecordType.Name+'<<<>>>');
        leadConfiguration = [Select Id, Attachment_Page_Intro__c
                from LEAD_Configuration__c
                where
                        Name = :licenseTransaction.RecordType.Name
        ];
        informationText = leadConfiguration.Attachment_Page_Intro__c;
        string query = 'select Id, Allow_use_of_Umbrella_Level_Document__c, Description__c,Name,Individual_Document__c,Library_Level__c,Need_to_be_Updated_at_each_new_Transacti__c,Optional_for_Transactio_Type__c,Related_Role__c,Required_For_Transaction_Type__c from Document_Type__c WHERE LEAD_Configuration__c = \''
                + licenseTransaction.Provider__r.Config_Record__c + '\' AND (Required_For_Transaction_Type__c INCLUDES (\'' + licenseTransaction.RecordType.Name + '\') OR Optional_for_Transactio_Type__c INCLUDES(\'' + licenseTransaction.RecordType.Name + '\'))';
        List<Document_Type__c> listDocumentType = database.query(query);
        List<Transaction_Document__c> listTransactionDocument = [SELECT Comments__c,Document__c,Document_Type__c,
                                                                Document_Type__r.Individual_Document__c,
                                                                Document__r.Contact_Role__c,
                                                                Document__r.Contact_Role__r.Role__c,
                                                                Last_Status_Date__c,Licensing_Transaction__c,Mode__c,Note_For_Revision__c,Status__c,Transaction_Notes__c,
                                                                Variance_on_Regulation__c
                                                                FROM Transaction_Document__c
                                                                WHERE Licensing_Transaction__c = :licenseTransaction.Id
                  ];
        List<Contact_Role__c> listContactRole = [select id, Name,Current_Formula__c,Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingPostalCode,Contact__r.MailingState,Contact__r.Phone,Contact__r.Email,Contact__r.Holds_FCC_License__c,End_Date__c,End_Role_Licensing_Transaction__c,Portal_Access__c,Provider__c,Role__c,Schedule_Administrative_Hours__c,Schedule_Teaching_Hours__c,Start_Date__c,Start_Role_Licensing_Transaction__c,Contact__r.Title,Contact__r.Role__c
                FROM Contact_Role__c
                WHERE Provider__c = :licenseTransaction.Provider__c and Start_Role_Licensing_Transaction__c = :licenseTransaction.Id
                order by Start_Date__c ASC NULLS FIRST
        ];
        Map<string, List<Contact_Role__c>> mapContactRole = new Map<string, List<Contact_Role__c>>();
        for (Contact_Role__c contactRole : listContactRole) {
            List<Contact_Role__c> listRoles;
            if (mapContactRole.get(contactRole.Role__c) == null) {
                listRoles = new List<Contact_Role__c>();
            } else {
                listRoles = mapContactRole.get(contactRole.Role__c);
            }
            listRoles.add(contactRole);
            mapContactRole.put(contactRole.Role__c, listRoles);
        }
        Map<Id, List<Transaction_Document__c>> mapTransactionDocs = new Map<Id, List<Transaction_Document__c>>();
        Map<Id, List<Transaction_Document__c>> mapIndividualTransactionDocs = new Map<Id, List<Transaction_Document__c>>();
        for (Transaction_Document__c transactionDocument : listTransactionDocument) {
            if (transactionDocument.Document_Type__r.Individual_Document__c == true) {
                List<Transaction_Document__c> listTranDoc;
                if (mapIndividualTransactionDocs.get(transactionDocument.Document_Type__c) == null) {
                    listTranDoc = new List<Transaction_Document__c>();
                } else {
                    listTranDoc = mapIndividualTransactionDocs.get(transactionDocument.Document_Type__c);
                }
                listTranDoc.add(transactionDocument);
                mapIndividualTransactionDocs.put(transactionDocument.Document_Type__c, listTranDoc);
            } else {
                List<Transaction_Document__c> listTranDoc;
                if (mapTransactionDocs.get(transactionDocument.Document_Type__c) == null) {
                    listTranDoc = new List<Transaction_Document__c>();
                } else {
                    listTranDoc = mapTransactionDocs.get(transactionDocument.Document_Type__c);
                }
                listTranDoc.add(transactionDocument);
                mapTransactionDocs.put(transactionDocument.Document_Type__c, listTranDoc);
            }
        }
        List<Document__c> listDocuments;
        if (licenseTransaction.Provider__r.Umbrella_Members__c != null) {
            listDocuments = [select Id, Document_Name__c, Approved_for_Future_Usage__c, Document_Type__c, Document_Type__r.Name,
                            Document_Type__r.Description__c, Attachment_Status__c, Notes__c,Valid_From__c,Valid_To__c,Provider__c,
                            Contact_Role__c, (select Id,Filename__c from S3_Files__r)
                            from Document__c
                            where
                            (Provider__c = :licenseTransaction.Provider__c or Provider__c = :licenseTransaction.Provider__r.Umbrella_Members__c)
                            and Current__c = true
            ];
        } else {
            listDocuments = [SELECT Id, Document_Name__c, Approved_for_Future_Usage__c, Document_Type__c, Document_Type__r.Name,
                            Document_Type__r.Description__c, Attachment_Status__c, Notes__c,Valid_From__c,Valid_To__c,Provider__c,
                            Contact_Role__c, (select Id,Filename__c from S3_Files__r)
                    from Document__c
                    where Provider__c = :licenseTransaction.Provider__c
                    and Current__c = true];
        }
        Map<Id, List<Document__c>> mapProviderDocuments = new Map<Id, List<Document__c>>();
        Map<Id, List<Document__c>> mapUmbrellaDocuments = new Map<Id, List<Document__c>>();
        Map<Id, List<Document__c>> mapIndividualDocuments = new Map<Id, List<Document__c>>();
        Map<Id, List<S3_File__c>> mapofDocIdAndS3Files = new Map<Id, List<S3_File__c>>();
        for (Document__c document : listDocuments) {
            mapofDocIdAndS3Files.put(document.Id, document.S3_Files__r);
            if (document.Provider__c == licenseTransaction.Provider__c && document.Contact_Role__c == null) {
                List<Document__c> listDoc;
                if (mapProviderDocuments.get(document.Document_Type__c) == null) {
                    listDoc = new List<Document__c>();
                } else {
                    listDoc = mapProviderDocuments.get(document.Document_Type__c);
                }
                listDoc.add(document);
                mapProviderDocuments.put(document.Document_Type__c, listDoc);
            } else if (document.Provider__c == licenseTransaction.Provider__r.Umbrella_Members__c && document.Contact_Role__c == null) {
                List<Document__c> listDoc;
                if (mapUmbrellaDocuments.get(document.Document_Type__c) == null) {
                    listDoc = new List<Document__c>();
                } else {
                    listDoc = mapUmbrellaDocuments.get(document.Document_Type__c);
                }
                listDoc.add(document);
                mapUmbrellaDocuments.put(document.Document_Type__c, listDoc);
            }
            if (document.Contact_Role__c != null) {
                List<Document__c> listDoc;
                if (mapIndividualDocuments.get(document.Document_Type__c) == null) {
                    listDoc = new List<Document__c>();
                } else {
                    listDoc = mapIndividualDocuments.get(document.Document_Type__c);
                }
                listDoc.add(document);
                mapIndividualDocuments.put(document.Document_Type__c, listDoc);
            }
        }
        listRequiredDocument = new List<TransactionDocumenWrapper>();
        listOptionalDocument = new List<TransactionDocumenWrapper>();
        listIndividualDocument = new List<TransactionDocumenWrapper>();
        listAdditionalDocument = new List<TransactionDocumenWrapper>();
        mapVarianceDocument = new Map<Id, List<TransactionDocumenWrapper>>();
        mapVarianceIds = new Map<string, string>();
        listTransactionDocument = [SELECT Id, Name, Comments__c,Document__c,Document_Type__c,
                        Document_Type__r.Individual_Document__c,
                        Document_Type__r.Name,
                        Document_Type__r.Description__c,
                        Document__r.Contact_Role__c,Document_Level__c,
                        Document__r.Valid_From__c,
                        Document__r.Contact_Role__r.Contact__r.FirstName,Document__r.Contact_Role__r.Contact__r.LastName,
                        Document__r.Contact_Role__r.Contact__r.Role__c,
                        Document__r.Contact_Role__r.Role__c,
                        Document__r.Document_Name__c,
                        Document__r.Provider__r.Umbrella_Members__c,
                        Document_Type__r.Required_For_Transaction_Type__c,
                        Document_Type__r.Optional_for_Transactio_Type__c,
                        Document_Type__r.Allow_Send_by_Mail_for_Transaction_Types__c,
                        Last_Status_Date__c,Licensing_Transaction__c,Mode__c,Note_For_Revision__c,Status__c,Transaction_Notes__c,
                        Variance_on_Regulation__r.Associated_Regulation__r.Regulation_Number__c,
                        Variance_on_Regulation__c, Sent_by_mail__c, Send_by_Mail_Allowed__c
                from Transaction_Document__c
                where Licensing_Transaction__c = :licenseTransaction.Id
        ];
        List<Variance_on_Regulation__c> listVariance = licenseTransaction.Variance_on_Regulations__r;
        for (Variance_on_Regulation__c variance : listVariance) {
            mapVarianceIds.put(variance.Id, variance.Associated_Regulation__r.Name);
            mapVarianceDocument.put(variance.Id, new List<TransactionDocumenWrapper>());
        }
        for (Transaction_Document__c transactionDocument : listTransactionDocument) {
            TransactionDocumenWrapper TransactionDocumenWrapper = new TransactionDocumenWrapper();
            if (transactionDocument.Document_Type__r.Allow_Send_by_Mail_for_Transaction_Types__c) {
                transactionDocument.Send_by_Mail_Allowed__c = true;
            } else {
                transactionDocument.Send_by_Mail_Allowed__c = false;
            }
            if (mapofDocIdAndS3Files.containsKey(transactionDocument.Document__c)) {
                TransactionDocumenWrapper.listOfS3Files = new List<String>();
                for (S3_File__c s3F : mapofDocIdAndS3Files.get(transactionDocument.Document__c)) {
                    TransactionDocumenWrapper.listOfS3Files.add(s3F.Filename__c);
                }
            }
            TransactionDocumenWrapper.transctionDocument = transactionDocument;
            if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_REQUIRED && transactionDocument.Document_Type__r.Individual_Document__c == false) {
                List<Document__c> listDoc = mapUmbrellaDocuments.get(transactionDocument.Document_Type__c);
                if (listDoc != null && listDoc.size() > 0) {
                    TransactionDocumenWrapper.displayUmbrella = true;
                } else {
                    TransactionDocumenWrapper.displayUmbrella = false;
                }
                listDoc = mapProviderDocuments.get(transactionDocument.Document_Type__c);
                if (listDoc != null && listDoc.size() > 0) {
                    TransactionDocumenWrapper.displayProvider = true;
                } else {
                    TransactionDocumenWrapper.displayProvider = false;
                }
                listRequiredDocument.add(TransactionDocumenWrapper);
            } else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_OPTIONAL && transactionDocument.Document_Type__r.Individual_Document__c == false) {
                listOptionalDocument.add(TransactionDocumenWrapper);
            } else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_INDIVIDUAL && transactionDocument.Document_Type__r.Individual_Document__c == true) {
                if (transactionDocument.Document_Type__r.Required_For_Transaction_Type__c.contains(licenseTransaction.RecordType.Name)) {
                    TransactionDocumenWrapper.mandatory = EEC_Constants.TRANSACTION_DOCUMENT_MANDATORY;
                } else {
                    TransactionDocumenWrapper.mandatory = EEC_Constants.TRANSACTION_DOCUMENT_MODE_OPTIONAL;
                }
                listIndividualDocument.add(TransactionDocumenWrapper);
            } else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_ADDITIONAL) {
                for (Document__c document : listDocuments) {
                    if (document.Id == transactionDocument.Document__c) {
                        List<S3_File__c> listFiles = document.S3_Files__r;
                        for (S3_File__c s3File : listFiles) {
                            TransactionDocumenWrapper = new TransactionDocumenWrapper();
                            TransactionDocumenWrapper.transctionDocument = transactionDocument;
                            TransactionDocumenWrapper.s3FileName = s3File.Filename__c;
                            TransactionDocumenWrapper.s3FileId = s3File.Id;
                            listAdditionalDocument.add(TransactionDocumenWrapper);
                        }
                        break;
                    }
                }
            }
            else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_VARIANCE) {
                List<TransactionDocumenWrapper> listVarianceDocs;
                if (mapVarianceDocument.get(transactionDocument.Variance_on_Regulation__c) == null) {
                    listVarianceDocs = new List<TransactionDocumenWrapper>();
                } else {
                    listVarianceDocs = mapVarianceDocument.get(transactionDocument.Variance_on_Regulation__c);
                }
                for (Document__c document : listDocuments) {
                    if (document.Id == transactionDocument.Document__c) {
                        List<S3_File__c> listFiles = document.S3_Files__r;
                        for (S3_File__c s3File : listFiles) {
                            TransactionDocumenWrapper = new TransactionDocumenWrapper();
                            TransactionDocumenWrapper.transctionDocument = transactionDocument;
                            TransactionDocumenWrapper.s3FileName = s3File.Filename__c;
                            TransactionDocumenWrapper.s3FileId = s3File.Id;
                            listVarianceDocs.add(TransactionDocumenWrapper);
                        }
                        mapVarianceDocument.put(transactionDocument.Variance_on_Regulation__c, listVarianceDocs);
                        break;
                    }
                }
            }
        }
    }
    public void doGetDocuments() {
        List<Licensing_Transaction__c> ltList = [Select Id, Provider__c,
                        RecordType.Name, RecordType.DeveloperName,Name,
                        RecordTypeId, Highest_Reached_Step__c,
                        Provider__r.Is_R_P__c,
                        Provider__r.Is_GSA__c,
                        Provider__r.Is_FCC__c,
                        Provider__r.RecordType.Name,
                        Provider__r.RecordType.DeveloperName,
                        Provider__r.Config_Record__c,
                        Transaction_Configuration__c,
                        Provider__r.Umbrella_Members__c,Status__c, (
                        Select Id,
                                Associated_Regulation__c,Associated_Regulation__r.Name,
                                Associated_Regulation__r.Regulation_Number__c,Associated_Regulation__r.Article__c,
                                Provider_Alternative_Method_to_Comply__c,Provider_Understanding_of_Regulation__c
                        From Variance_on_Regulations__r
                )
                From Licensing_Transaction__c l
                where Id = :ltId
        ];
        for (Licensing_Transaction__c lt : ltList) {
            providerRecordType = lt.Provider__r.RecordType.DeveloperName;
        }
        if (ltList.size() > 0) {
            licenseTransaction = ltList[0];
            highestStepReached = licenseTransaction.Highest_Reached_Step__c;
            if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
                formattedLicenseRecordTypeLabel = EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY;
            } else {
                formattedLicenseRecordTypeLabel = licenseTransaction.RecordType.DeveloperName.replaceAll('_', ' ');
            }
        }
        if (licenseTransaction != null && licenseTransaction.RecordType != null)
            leadConfiguration = [
                    Select Id, Attachment_Page_Intro__c
                    from LEAD_Configuration__c
                    where
                            Name = :licenseTransaction.RecordType.Name
            ];
        informationText = leadConfiguration.Attachment_Page_Intro__c;
        string query = 'select Id, Allow_use_of_Umbrella_Level_Document__c, Description__c,Name,Individual_Document__c,Library_Level__c,Need_to_be_Updated_at_each_new_Transacti__c,Optional_for_Transactio_Type__c,Related_Role__c,Required_For_Transaction_Type__c from Document_Type__c WHERE LEAD_Configuration__c = \''
                + licenseTransaction.Provider__r.Config_Record__c + '\' AND (Required_For_Transaction_Type__c INCLUDES (\'' + licenseTransaction.RecordType.Name + '\') OR Optional_for_Transactio_Type__c INCLUDES(\'' + licenseTransaction.RecordType.Name + '\'))';
        List<Document_Type__c> listDocumentType = database.query(query);
        List<Transaction_Document__c> listTransactionDocument = [select Comments__c,Document__c,Document_Type__c,
                        Document_Type__r.Description__c,
                        Document_Type__r.Individual_Document__c,
                        Document__r.Contact_Role__c,
                        Document__r.Contact_Role__r.Role__c,Is_Consent_Document__c,Is_Tax_Statement_Document__c,
                        Last_Status_Date__c,Licensing_Transaction__c,Licensing_Transaction__r.Status__c,Mode__c,Note_For_Revision__c,Status__c,Transaction_Notes__c,
                        Variance_on_Regulation__c
                from Transaction_Document__c
                where Licensing_Transaction__c = :licenseTransaction.Id
        ];
        List<Contact_Role__c> listContactRole = [select id, Name,Current_Formula__c,Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingPostalCode,Contact__r.MailingState,Contact__r.Phone,Contact__r.Email,Contact__r.Holds_FCC_License__c,End_Date__c,End_Role_Licensing_Transaction__c,Portal_Access__c,Provider__c,Role__c,Schedule_Administrative_Hours__c,Schedule_Teaching_Hours__c,Start_Date__c,Start_Role_Licensing_Transaction__c,Contact__r.Title,Contact__r.Role__c
                FROM Contact_Role__c
                WHERE Provider__c = :licenseTransaction.Provider__c and Start_Role_Licensing_Transaction__c = :licenseTransaction.Id
                order by Start_Date__c ASC NULLS FIRST
        ];
        Map<string, List<Contact_Role__c>> mapContactRole = new Map<string, List<Contact_Role__c>>();
        for (Contact_Role__c contactRole : listContactRole) {
            List<Contact_Role__c> listRoles;
            if (mapContactRole.get(contactRole.Role__c) == null) {
                listRoles = new List<Contact_Role__c>();
            } else {
                listRoles = mapContactRole.get(contactRole.Role__c);
            }
            listRoles.add(contactRole);
            mapContactRole.put(contactRole.Role__c, listRoles);
            System.debug('mapContactRole---->'+mapContactRole);
        }
        Map<Id, List<Transaction_Document__c>> mapTransactionDocs = new Map<Id, List<Transaction_Document__c>>();
        Map<Id, List<Transaction_Document__c>> mapIndividualTransactionDocs = new Map<Id, List<Transaction_Document__c>>();
        for (Transaction_Document__c transactionDocument : listTransactionDocument) {
            if (transactionDocument.Document_Type__r.Individual_Document__c == true) {
                List<Transaction_Document__c> listTranDoc;
                if (mapIndividualTransactionDocs.get(transactionDocument.Document_Type__c) == null) {
                    listTranDoc = new List<Transaction_Document__c>();
                } else {
                    listTranDoc = mapIndividualTransactionDocs.get(transactionDocument.Document_Type__c);
                }
                listTranDoc.add(transactionDocument);
                mapIndividualTransactionDocs.put(transactionDocument.Document_Type__c, listTranDoc);
            } else {
                List<Transaction_Document__c> listTranDoc;
                if (mapTransactionDocs.get(transactionDocument.Document_Type__c) == null) {
                    listTranDoc = new List<Transaction_Document__c>();
                } else {
                    listTranDoc = mapTransactionDocs.get(transactionDocument.Document_Type__c);
                }
                listTranDoc.add(transactionDocument);
                mapTransactionDocs.put(transactionDocument.Document_Type__c, listTranDoc);
            }
        }
        List<Document__c> listDocuments;
        if (licenseTransaction.Provider__r.Umbrella_Members__c != null) {
            listDocuments = [select Id, Document_Name__c, Approved_for_Future_Usage__c, Document_Type__c, Document_Type__r.Name,
                            Document_Type__r.Description__c, Attachment_Status__c, Notes__c,Valid_From__c,Valid_To__c,Provider__c,
                            Contact_Role__c, (select Id,Filename__c from S3_Files__r)
                    from
                            Document__c
                    where
                    (Provider__c = :licenseTransaction.Provider__c or Provider__c = :licenseTransaction.Provider__r.Umbrella_Members__c)
                    and Current__c = true
            ];
        } else {
            listDocuments = [select Id, Document_Name__c, Approved_for_Future_Usage__c, Document_Type__c, Document_Type__r.Name,
                            Document_Type__r.Description__c, Attachment_Status__c, Notes__c,Valid_From__c,Valid_To__c,Provider__c,
                            Contact_Role__c, (select Id,Filename__c from S3_Files__r)
                    from Document__c
                    where Provider__c = :licenseTransaction.Provider__c
                    and Current__c = true
            ];
        }
        Map<Id, List<Document__c>> mapProviderDocuments = new Map<Id, List<Document__c>>();
        Map<Id, List<Document__c>> mapUmbrellaDocuments = new Map<Id, List<Document__c>>();
        Map<Id, List<Document__c>> mapIndividualDocuments = new Map<Id, List<Document__c>>();
        for (Document__c document : listDocuments) {
            if (document.Provider__c == licenseTransaction.Provider__c && document.Contact_Role__c == null) {
                List<Document__c> listDoc;
                if (mapProviderDocuments.get(document.Document_Type__c) == null) {
                    listDoc = new List<Document__c>();
                } else {
                    listDoc = mapProviderDocuments.get(document.Document_Type__c);
                }
                listDoc.add(document);
                mapProviderDocuments.put(document.Document_Type__c, listDoc);
            } else if (document.Provider__c == licenseTransaction.Provider__r.Umbrella_Members__c && document.Contact_Role__c == null) {
                List<Document__c> listDoc;
                if (mapUmbrellaDocuments.get(document.Document_Type__c) == null) {
                    listDoc = new List<Document__c>();
                } else {
                    listDoc = mapUmbrellaDocuments.get(document.Document_Type__c);
                }
                listDoc.add(document);
                mapUmbrellaDocuments.put(document.Document_Type__c, listDoc);
            }
            if (document.Contact_Role__c != null) {
                List<Document__c> listDoc;
                if (mapIndividualDocuments.get(document.Document_Type__c) == null) {
                    listDoc = new List<Document__c>();
                } else {
                    listDoc = mapIndividualDocuments.get(document.Document_Type__c);
                }
                listDoc.add(document);
                mapIndividualDocuments.put(document.Document_Type__c, listDoc);
            }
        }
        List<Document__c> listNewDocument = new List<Document__c>();
        List<Transaction_Document__c> listNewTransactionDocument = new List<Transaction_Document__c>();
        for (Document_Type__c documentType : listDocumentType) {
            system.debug('@@@@@@222222'+documentType.Related_Role__c);
            if (documentType.Individual_Document__c == false) {
                if (mapTransactionDocs.get(documentType.Id) == null || mapTransactionDocs.get(documentType.Id).size() == 0) {
                    if (documentType.Need_to_be_Updated_at_each_new_Transacti__c == true) {
                        Document__c newDocument = createDocument(documentType.Id, licenseTransaction.Provider__c);
                        listNewDocument.add(newDocument);
                    } else {
                        if (licenseTransaction.Provider__r.Umbrella_Members__c != null) {
                            if (mapUmbrellaDocuments.get(documentType.Id) != null && mapUmbrellaDocuments.get(documentType.Id).size() > 0) {
                                Document__c newDocument = createDocument(documentType.Id, licenseTransaction.Provider__c);
                                listNewDocument.add(newDocument);
                            } else {
                                if (mapProviderDocuments.get(documentType.Id) == null || mapProviderDocuments.get(documentType.Id).size() == 0) {
                                    Document__c newDocument = createDocument(documentType.Id, licenseTransaction.Provider__c);
                                    listNewDocument.add(newDocument);
                                }
                            }
                        } else {
                            if (mapProviderDocuments.get(documentType.Id) == null || mapProviderDocuments.get(documentType.Id).size() == 0) {
                                Document__c newDocument = createDocument(documentType.Id, licenseTransaction.Provider__c);
                                listNewDocument.add(newDocument);
                            }
                        }
                    }
                }
            } else {
                system.debug('444444444444444'+documentType.Related_Role__c);
                List<Contact_Role__c> listRoles = mapContactRole.get(documentType.Related_Role__c);
                system.debug('444444444444444mapContactRole-->'+mapContactRole);
                system.debug('########'+listRoles);
                if (listRoles != null && listRoles.size() > 0) {
                    List<Transaction_Document__c> listTraDocs = mapIndividualTransactionDocs.get(documentType.Id);
                    boolean isDocExist = false;
                    if (listTraDocs != null && listTraDocs.size() > 0) {
                        for (Contact_Role__c contactRole : listRoles) {
                            for (Transaction_Document__c transactionDoc : listTraDocs) {
                                if (transactionDoc.Document__r.Contact_Role__c == contactRole.Id) {
                                    isDocExist = true;
                                    break;
                                }
                            }
                            if (isDocExist == false) {
                                Document__c newDocument = createDocument(documentType.Id, licenseTransaction.Provider__c);
                                newDocument.Contact_Role__c = contactRole.Id;
                                listNewDocument.add(newDocument);
                            }
                        }
                    } else {
                        for (Contact_Role__c contactRole : listRoles) {
                            Document__c newDocument = createDocument(documentType.Id, licenseTransaction.Provider__c);
                            newDocument.Contact_Role__c = contactRole.Id;
                            listNewDocument.add(newDocument);
                        }
                    }
                }
            }
        }
        if (listNewDocument.size() > 0 && !isTransactionClosedOrSubmitted) {
            insert listNewDocument;
        }
        Map<Id, List<Document__c>> mapNewDocuments = new Map<Id, List<Document__c>>();
        for (Document__c document : listNewDocument) {
            List<Document__c> listDocs;
            if (mapNewDocuments.get(document.Document_Type__c) == null) {
                listDocs = new List<Document__c>();
            } else {
                listDocs = mapNewDocuments.get(document.Document_Type__c);
            }
            listDocs.add(document);
            mapNewDocuments.put(document.Document_Type__c, listDocs);
        }
        for (Document_Type__c documentType : listDocumentType) {
            List<Document__c> listDocs = mapNewDocuments.get(documentType.Id);
            if (documentType.Individual_Document__c == false) {
                if (mapTransactionDocs.get(documentType.Id) == null || mapTransactionDocs.get(documentType.Id).size() == 0) {
                    Transaction_Document__c newTransactionDocument = new Transaction_Document__c();
                    newTransactionDocument.Document_Type__c = documentType.Id;
                    newTransactionDocument.Licensing_Transaction__c = licenseTransaction.Id;
                    if (string.isNotBlank(documentType.Required_For_Transaction_Type__c) && documentType.Required_For_Transaction_Type__c.contains(licenseTransaction.RecordType.Name)) {
                        newTransactionDocument.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_REQUIRED;
                    } else if (string.isNotBlank(documentType.Optional_for_Transactio_Type__c) && documentType.Optional_for_Transactio_Type__c.contains(licenseTransaction.RecordType.Name)) {
                        newTransactionDocument.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_OPTIONAL;
                    }
                    if (documentType.Need_to_be_Updated_at_each_new_Transacti__c == true) {
                        for (Document__c document : listDocs) {
                            if (document.Contact_Role__c == null) {
                                newTransactionDocument.Document__c = document.Id;
                                break;
                            }
                        }
                        newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                        listNewTransactionDocument.add(newTransactionDocument);
                    } else {
                        if (licenseTransaction.Provider__r.Umbrella_Members__c != null) {
                            if (mapUmbrellaDocuments.get(documentType.Id) != null && mapUmbrellaDocuments.get(documentType.Id).size() > 0) {
                                Document__c document = mapUmbrellaDocuments.get(documentType.Id)[0];

                                newTransactionDocument.Document__c = document.Id;
                                if (document.Approved_for_Future_Usage__c) {
                                    newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_REVIEWED;
                                } else {
                                    if (document.S3_Files__r != null && document.S3_Files__r.size() > 0) {
                                        newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_SUBMITTED;
                                    } else {
                                        newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                                    }
                                }
                                listNewTransactionDocument.add(newTransactionDocument);
                            } else {
                                if (mapProviderDocuments.get(documentType.Id) != null && mapProviderDocuments.get(documentType.Id).size() > 0) {
                                    Document__c document = mapProviderDocuments.get(documentType.Id)[0];
                                    newTransactionDocument.Document__c = document.Id;
                                    if (document.Approved_for_Future_Usage__c) {
                                        newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_REVIEWED;
                                    } else {
                                        if (document.S3_Files__r != null && document.S3_Files__r.size() > 0) {
                                            newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_SUBMITTED;
                                        } else {
                                            newTransactionDocument.Status__c =  EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                                        }
                                    }
                                    listNewTransactionDocument.add(newTransactionDocument);
                                } else {
                                    for (Document__c document : listDocs) {
                                        if (document.Contact_Role__c == null) {
                                            newTransactionDocument.Document__c = document.Id;
                                            break;
                                        }
                                    }
                                    newTransactionDocument.Status__c =  EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                                    listNewTransactionDocument.add(newTransactionDocument);
                                }
                            }
                        } else {
                            if (mapProviderDocuments.get(documentType.Id) != null && mapProviderDocuments.get(documentType.Id).size() > 0) {
                                Document__c document = mapProviderDocuments.get(documentType.Id)[0];

                                newTransactionDocument.Document__c = document.Id;
                                if (document.Approved_for_Future_Usage__c)
                                    newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_REVIEWED; else {
                                    if (document.S3_Files__r != null && document.S3_Files__r.size() > 0) {
                                        newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_SUBMITTED;
                                    } else {
                                        newTransactionDocument.Status__c =  EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                                    }
                                }
                                listNewTransactionDocument.add(newTransactionDocument);
                            } else {
                                for (Document__c document : listDocs) {
                                    if (document.Contact_Role__c == null) {
                                        newTransactionDocument.Document__c = document.Id;
                                        break;
                                    }
                                }
                                newTransactionDocument.Status__c =  EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                                listNewTransactionDocument.add(newTransactionDocument);
                            }
                        }
                    }
                }
            } else {
                List<Contact_Role__c> listRoles = mapContactRole.get(documentType.Related_Role__c);
                system.debug('!!!!!!!!!!!!!!!'+listRoles);
                if (listRoles != null && listRoles.size() > 0) {
                    List<Transaction_Document__c> listTraDocs = mapIndividualTransactionDocs.get(documentType.Id);
                    boolean isDocExist = false;
                    if (listTraDocs != null && listTraDocs.size() > 0) {
                        for (Contact_Role__c contactRole : listRoles) {
                            for (Transaction_Document__c transactionDoc : listTraDocs) {
                                if (transactionDoc.Document__r.Contact_Role__c == contactRole.Id) {
                                    isDocExist = true;
                                    break;
                                }
                            }
                            if (isDocExist == false) {
                                Transaction_Document__c newTransactionDocument = new Transaction_Document__c();
                                newTransactionDocument.Licensing_Transaction__c = licenseTransaction.Id;
                                newTransactionDocument.Document_Type__c = documentType.Id;
                                newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                                newTransactionDocument.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_INDIVIDUAL;
                                for (Document__c document : listDocs) {
                                    if (document.Contact_Role__c == contactRole.Id) {
                                        newTransactionDocument.Document__c = document.Id;
                                        break;
                                    }
                                }
                                listNewTransactionDocument.add(newTransactionDocument);
                            }
                        }
                    } else {
                        for (Contact_Role__c contactRole : listRoles) {
                            Transaction_Document__c newTransactionDocument = new Transaction_Document__c();
                            newTransactionDocument.Licensing_Transaction__c = licenseTransaction.Id;
                            newTransactionDocument.Document_Type__c = documentType.Id;
                            newTransactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
                            newTransactionDocument.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_INDIVIDUAL;
                            for (Document__c document : listDocs) {
                                if (document.Contact_Role__c == contactRole.Id) {
                                    newTransactionDocument.Document__c = document.Id;
                                    break;
                                }
                            }
                            listNewTransactionDocument.add(newTransactionDocument);
                        }
                    }
                }
            }
        }

        if (listNewTransactionDocument.size() > 0 && !isTransactionClosedOrSubmitted) {
            insert listNewTransactionDocument;
        }
        listRequiredDocument = new List<TransactionDocumenWrapper>();
        listOptionalDocument = new List<TransactionDocumenWrapper>();
        listIndividualDocument = new List<TransactionDocumenWrapper>();
        listAdditionalDocument = new List<TransactionDocumenWrapper>();
        mapVarianceDocument = new Map<Id, List<TransactionDocumenWrapper>>();
        mapVarianceIds = new Map<string, string>();
        listTransactionDocument = [
                select Id, Name, Comments__c,Document__c,Document_Type__c,
                        Document_Type__r.Individual_Document__c,Transaction_Document_Name__c,
                        Document_Type__r.Name,
                        Document_Type__r.Description__c,
                        Document__r.Contact_Role__c,Document_Level__c,
                        Document__r.Valid_From__c,
                        Document__r.Contact_Role__r.Contact__r.FirstName,Document__r.Contact_Role__r.Contact__r.LastName,
                        Document__r.Contact_Role__r.Contact__r.Role__c,
                        Document__r.Contact_Role__r.Role__c,
                        Document__r.Document_Name__c,
                        Document__r.Provider__r.Umbrella_Members__c,
                        Document_Type__r.Required_For_Transaction_Type__c,
                        Document_Type__r.Optional_for_Transactio_Type__c,
                        Document_Type__r.Allow_Send_by_Mail_for_Transaction_Types__c,
                        Last_Status_Date__c,Is_Consent_Document__c,Is_Tax_Statement_Document__c,
                        Licensing_Transaction__c,Licensing_Transaction__r.Status__c,
                        Mode__c,Note_For_Revision__c,Status__c,Transaction_Notes__c,
                        Variance_on_Regulation__r.Associated_Regulation__r.Regulation_Number__c,
                        Variance_on_Regulation__c, Sent_by_mail__c, Send_by_Mail_Allowed__c
                from Transaction_Document__c
                where Licensing_Transaction__c = :licenseTransaction.Id
        ];
        Set<id> documentIds = new Set<id>();
        for (Transaction_Document__c transDoc : listTransactionDocument) {
            documentIds.add(transDoc.Document__c);
        }
        Map<Id, List<Task>> documentToTask = new Map<Id, List<Task>>();
        for (Document__c doc : [
                SELECT Id, (
                        SELECT id,subject,activitydate,createddate, status,type,priority,Description,createdby.name
                        FROM tasks
                        ORDER BY activitydate DESC
                )
                FROM Document__c
                WHERE Id = :documentIds
        ]) {
            for (Task task : doc.tasks) {
                if (!documentToTask.containsKey(doc.Id)) {
                    documentToTask.put(doc.Id, new List<Task>{
                            task
                    });
                } else {
                    documentToTask.get(doc.Id).add(task);
                }
            }
        }
        List<Variance_on_Regulation__c> listVariance = licenseTransaction.Variance_on_Regulations__r;
        for (Variance_on_Regulation__c variance : listVariance) {
            mapVarianceIds.put(variance.Id, variance.Associated_Regulation__r.Name);
            mapVarianceDocument.put(variance.Id, new List<TransactionDocumenWrapper>());
        }
        for (Transaction_Document__c transactionDocument : listTransactionDocument) {
            if ((transactionDocument.Is_Tax_Statement_Document__c && transactionDocument.Licensing_Transaction__r.Status__c != EEC_Constants.LT_SUBMITTED) || (transactionDocument.Is_Consent_Document__c && transactionDocument.Licensing_Transaction__r.Status__c != EEC_Constants.LT_SUBMITTED)) {
                continue;
            }
            TransactionDocumenWrapper TransactionDocumenWrapper = new TransactionDocumenWrapper();
            if (documentToTask.containsKey(transactionDocument.Document__c)) {
                TransactionDocumenWrapper.taskList.addAll(documentToTask.get(transactionDocument.Document__c));
            }
            if (transactionDocument.Document_Type__r.Allow_Send_by_Mail_for_Transaction_Types__c) {
                transactionDocument.Send_by_Mail_Allowed__c = true;
            } else {
                transactionDocument.Send_by_Mail_Allowed__c = false;
            }
            //if(transactionDocument.Licensing_Transaction__r.Status__c !=EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED' && (transactionDocument.Is_Consent_Document__c == true || transactionDocument.Is_Tax_Statement_Document__c == true)){
            TransactionDocumenWrapper.transctionDocument = transactionDocument;
            //}
            if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_REQUIRED && transactionDocument.Document_Type__r.Individual_Document__c == false) {
                List<Document__c> listDoc = mapUmbrellaDocuments.get(transactionDocument.Document_Type__c);
                if (listDoc != null && listDoc.size() > 0) {
                    TransactionDocumenWrapper.displayUmbrella = true;
                } else {
                    TransactionDocumenWrapper.displayUmbrella = false;
                }
                listDoc = mapProviderDocuments.get(transactionDocument.Document_Type__c);
                if (listDoc != null && listDoc.size() > 0) {
                    TransactionDocumenWrapper.displayProvider = true;
                } else {
                    TransactionDocumenWrapper.displayProvider = false;
                }
                listRequiredDocument.add(TransactionDocumenWrapper);
            } else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_OPTIONAL && transactionDocument.Document_Type__r.Individual_Document__c == false) {
                listOptionalDocument.add(TransactionDocumenWrapper);
            } else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_INDIVIDUAL && transactionDocument.Document_Type__r.Individual_Document__c == true) {
                if (transactionDocument.Document_Type__r.Required_For_Transaction_Type__c.contains(licenseTransaction.RecordType.Name)) {
                    TransactionDocumenWrapper.mandatory = EEC_Constants.TRANSACTION_DOCUMENT_MANDATORY;
                } else {
                    TransactionDocumenWrapper.mandatory = EEC_Constants.TRANSACTION_DOCUMENT_MODE_OPTIONAL;
                }
                listIndividualDocument.add(TransactionDocumenWrapper);
            } else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_ADDITIONAL) {
                for (Document__c document : listDocuments) {
                    if (document.Id == transactionDocument.Document__c) {
                        List<S3_File__c> listFiles = document.S3_Files__r;
                        for (S3_File__c s3File : listFiles) {
                            TransactionDocumenWrapper = new TransactionDocumenWrapper();
                            TransactionDocumenWrapper.transctionDocument = transactionDocument;
                            TransactionDocumenWrapper.s3FileName = s3File.Filename__c;
                            TransactionDocumenWrapper.s3FileId = s3File.Id;
                            listAdditionalDocument.add(TransactionDocumenWrapper);
                        }
                        break;
                    }
                }
            }
            else if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_VARIANCE) {
                List<TransactionDocumenWrapper> listVarianceDocs;
                if (mapVarianceDocument.get(transactionDocument.Variance_on_Regulation__c) == null) {
                    listVarianceDocs = new List<TransactionDocumenWrapper>();
                } else {
                    listVarianceDocs = mapVarianceDocument.get(transactionDocument.Variance_on_Regulation__c);
                }
                for (Document__c document : listDocuments) {
                    if (document.Id == transactionDocument.Document__c) {
                        List<S3_File__c> listFiles = document.S3_Files__r;

                        for (S3_File__c s3File : listFiles) {
                            TransactionDocumenWrapper = new TransactionDocumenWrapper();
                            TransactionDocumenWrapper.transctionDocument = transactionDocument;
                            TransactionDocumenWrapper.s3FileName = s3File.Filename__c;
                            TransactionDocumenWrapper.s3FileId = s3File.Id;
                            listVarianceDocs.add(TransactionDocumenWrapper);
                        }
                        mapVarianceDocument.put(transactionDocument.Variance_on_Regulation__c, listVarianceDocs);
                        break;
                    }
                }
            }
        }
        getLeadConfigurationData();
    }
    public string applicationDisplayName { get; set; }
    public void getLeadConfigurationData() {
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        string LicenseRecordTypeLabel = licenseTransaction.RecordType.Name;
        if (String.isNotBlank(ltId) && String.isNotBlank(LicenseRecordTypeLabel)) {
            leadConfiguration = [
                    Select Visit_Narrative_Summary_Default__c,Application_Display_Name__c,SystemModstamp, Portal_Transaction_Introduction__c,
                            Number_of_days_for_Investigation_Visit__c, No_of_Days_Prior_Corr_Action_Deadline__c, No_of_Days_For_Investigation_Due_Date__c, Name,
                            Large_Group_Instruction__c, Investigation__c, Investig_Non_comp_Default_if_Any__c, Follow_up_Visit_Estimated_Deadline__c
                            , Transaction_Submission_Disclaimer__c,Training_Instructions__c,Transaction_Attachments_New__c, Transaction_Attachments_Renewal__c, Transaction_Attachments_Upgrade__c
                    from LEAD_Configuration__c
                    where Name = :LicenseRecordTypeLabel
            ];
            applicationDisplayName = leadConfiguration.Application_Display_Name__c;
        }
    }
    private Document__c createDocument(string documentType, string accountId) {
        Document__c newDocument = new Document__c();
        newDocument.Document_Type__c = documentType;
        newDocument.Provider__c = accountId;
        return newDocument;
    }
    public void doUpdateSentByMail() {
        String trandocId = ApexPages.currentPage().getParameters().get('trandocId');
        Boolean trandocSentByMail = Boolean.valueOf(ApexPages.currentPage().getParameters().get('trandocSentByMail'));
        Transaction_Document__c transactionDocument = [select Id, Sent_by_mail__c from Transaction_Document__c where Id = :trandocId];
        transactionDocument.Sent_by_mail__c = trandocSentByMail;
        update transactionDocument;
    }
    public void doUpdateComments() {
        String trandocId = ApexPages.currentPage().getParameters().get('trandocId');
        String trandocComments = ApexPages.currentPage().getParameters().get('trandocComments');
        Transaction_Document__c transactionDocument = [select Id, Comments__c from Transaction_Document__c where Id = :trandocId];
        transactionDocument.Comments__c = trandocComments;
        update transactionDocument;
    }

    public Pagereference CancelAttachment() {
        if (string.IsNotBlank(previousPageName)) {
            if (previousPageName == 'Provider') {
                PageReference pPage = page.EEC_PortalProviderPage;
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                return pPage;
            }
             else {
                return null;
            }
        } else {
            return null;
        }

    }
    public Pagereference CancelTransaction() {
        if (UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_POWER_PARTNER || UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_POWER_CUSTOMER_SUCCESS ||
                UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_CSP_LITE_PORTAL || UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_CUSTOMER_SUCCESS) {
            licenseTransaction.Status__c = EEC_Constants.LT_CANCELLED;
            licenseTransaction.Status_Reason__c = EEC_Constants.LT_STATUS_REASON_APPLICATION_WITHDREW;
            licenseTransaction.Reason_Closed_Cancelled__c = EEC_Constants.LT_REASON_CLOSED_CANCELLED_PORTAL;
            update licenseTransaction;
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            licenseTransaction.Status__c = EEC_Constants.LT_CANCELLED;
            licenseTransaction.Status_Reason__c = EEC_Constants.LT_STATUS_REASON_LACK_OF_RESPONSE;
            licenseTransaction.Reason_Closed_Cancelled__c = EEC_Constants.LT_REASON_CLOSED_CANCELLED_EEC_USER;
            update licenseTransaction;
            return new PageReference('javascript:window.close()');
        }
    }

    public PageReference SaveAndBackAttachment() {
        try {
            licenseTransaction = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransaction);
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (previousPageName == 'Provider') {
                    pPage = page.EEC_PortalProviderPage;
                    pPage.getParameters().put('ltId', licenseTransaction.Id);
                    return pPage;
                }
                 else {
                    return null;
                }
            } else {
                pPage = null;
            }
            //pPage.getParameters().put('ltId', licenseTransaction.Id);
            addMemberIDPageParameter(pPage, false);
            //pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }

    public PageReference SaveAndPreviousAttachment() {
        try {
            licenseTransaction.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            if (!isTransactionClosedOrSubmitted) {
                licenseTransaction = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransaction);
            }
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_FCC || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                    system.debug('previousPageName: ' + previousPageName);
                } else if (licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP 
                                                || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP 
                                                || licenseTransaction.Provider__r.RecordType.DeveloperName == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransaction.Provider__r.RecordType.DeveloperName == 'R&P Umbrella' 
                                                || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER 
                                                || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_GROUP_CARE
                                                || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY 
                                                || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }else if(licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_PUBLIC_SCHOOL || licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_PRIVATE_SCHOOL){
                    pPage = EEC_Util.lastCBCStepMap.get(previousPageName);
                }else if(licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_SUMMER_CAMP){
                   // pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
                }else if(licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_INFORMAL_CHILD_CARE){
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_NEW_LICENSE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_RENEWAL ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_LICENSE_CHANGE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_MOVE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION
                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION) {
                pPage = Page.eec_indoorspacegsapage;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
                pPage = Page.eec_designationofadministrative;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE) {
                pPage = Page.EEC_ResidentialProgramDetail;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_RESIDENTIAL_MOVE) {
                pPage = Page.EEC_TransactionProvider;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
                pPage = Page.EEC_OwnershipAdministratorInfo;
            } else if (licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                    || licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_PLACEMENT_RENEWAL
                    || licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE
                    || licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_PLACEMENT_MOVE
                    ) {
                pPage = Page.eec_placementagency;
            } else if (licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE
                    || licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT
                    || licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_FCC_ASSISTANT_RENEWAL
                    || licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE
                    ) {
                pPage = Page.eec_traininginformation;
            } else {
                if ((licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_FCC_NEW_LICENSE
                     || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_NEW_LICENSE
                     || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_RENEWAL ) 
                     && string.IsBlank(previousPageName)) {
                    pPage = Page.eec_indoorspacepage;
                } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                    pPage = Page.eec_traininginformation;
                }else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_FCC_CHANGE_OF_NAME) {
                    pPage = Page.EEC_TransactionInstructions;
                } else {
                    pPage = Page.EEC_TechnicalAssistance;
                }
            }
            pPage.getParameters().put('ltId', licenseTransaction.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public PageReference SaveAndReturnAttachment() {
        try {
            licenseTransaction.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            if (!isTransactionClosedOrSubmitted) {
                licenseTransaction = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransaction);
            }
            if (UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_POWER_PARTNER || UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_POWER_CUSTOMER_SUCCESS ||
                    UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_CSP_LITE_PORTAL || UserInfo.getUserType() == EEC_Constants.GRT_USER_TYPE_CUSTOMER_SUCCESS) {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }

    private boolean checkMandatoryDocuments() {
        List<Transaction_Document__c> listTransactionDocument = [
                SELECT ID, Document__c, Document__r.Document_Name__c
                FROM Transaction_Document__c
                WHERE
                Licensing_Transaction__c = :licenseTransaction.id
                AND (Document_Type__r.Submit_Transaction_Only_If_Uploaded__c = true OR Submit_Transaction_Only_If_Uploaded__c = true)
                AND Document__r.Attachment_Status__c = :EEC_Constants.DOCUMENT_NO_ATTACHMENT
        ];
        if (listTransactionDocument.size() > 0) {
            String errMsg = '';
            for (Transaction_Document__c transactionDocument : listTransactionDocument) {
                errMsg = errMsg + ', ' + transactionDocument.Document__r.Document_Name__c;
            }
            if (errMsg.length() > 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'The following mandatory document(s) have not been uploaded:' + errMsg.removeStart(', ') + '. Please, go back to the Attachment section and upload these document.'));
                return false;
            }
        }
        return true;
    }
    public PageReference SaveAndSubmitAttachment() {
        try {
            if (checkMandatoryDocuments()) {
                licenseTransaction.Send_Email_141__c = true;
                if (!isTransactionClosedOrSubmitted) {
                    licenseTransaction = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransaction);
                }
                List<Transaction_Document__c> listTransactionDocument = [
                        SELECT Id,Status__c
                        FROM Transaction_Document__c
                        WHERE Document_Attachment_Status__c = :EEC_Constants.TRANSACTION_DOCUMENT_ATTACHMENT_STATUS
                        //AND Status__c='Submitted'
                        AND Licensing_Transaction__c = :licenseTransaction.Id
                ];
                for (Transaction_Document__c transactionDocument : listTransactionDocument) {
                    if (transactionDocument.Status__c == EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED) {
                        transactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_SUBMITTED;
                    }
                }
                EEC_ContactRoleUtil.upsertTransactionDocument(listTransactionDocument);
                PageReference pPage;
                if (string.IsNotBlank(previousPageName)) {
                    if (previousPageName == 'Provider' || previousPageName == 'GSALicense' || previousPageName == 'RPLicense') {
                        pPage = page.EEC_PortalProviderPage;
                        pPage.getParameters().put('ltId', licenseTransaction.Id);
                        return pPage;
                    } else {
                        return null;
                    }
                } else {
                    pPage = null;
                }
                //pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;

            } else {
                return null;
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public PageReference SaveAndNextAttachment() {
           // system.assert(false, licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION);
        try {
            //licenseTransaction.Last_Reached_Step__c = 'Review Summary and Submission';
            licenseTransaction.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
            if (!isTransactionClosedOrSubmitted) {
                licenseTransaction = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransaction);
            }
            if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE ||
                    licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PLACEMENT_RENEWAL ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PLACEMENT_MOVE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_RESIDENTIAL_MOVE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY ||
                    (licenseTransaction.Provider__r.Is_R_P__c && licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST)) {
                PageReference pPage = Page.EEC_RP_ReviewSummary;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                    //licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_NEW_LICENSE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_RENEWAL ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_LICENSE_CHANGE  ||
                    licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_GSA_MOVE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_TEMPORARY_MOVE ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY ||
                    (licenseTransaction.Provider__r.Is_GSA__c && licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST)) {
                PageReference pPage = Page.EEC_GSAReviewSummary;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                    //licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE ||
                    licenseTransaction.RecordType.DeveloperName ==  EEC_Constants.LT_FCC_ASSISTANT_RENEWAL ||
                    licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE
                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT 
                    || (licenseTransaction.Provider__r.RecordType.DeveloperName =='FCC_Assistant' 
                    && licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST)) {
                PageReference pPage = Page.EEC_ReviewSummarySubmissionAssistant;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                    //licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_FCC_CHANGE_OF_NAME && licenseTransaction.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
                PageReference pPage = Page.EEC_ReviewSummarySubmissionAssistant;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                    //licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION 
                                                                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION 
                                                                    || licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION) {
                PageReference pPage = Page.EEC_CBCReviewSummary;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                    //licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
                
              
            } /* else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION) {
                PageReference pPage = Page.EEC_SMReviewSummary;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                    //licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;


            } */else if (licenseTransaction.RecordType.DeveloperName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                PageReference pPage = Page.EEC_ICCReviewSummary;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                   // licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            }  
            else {
                PageReference pPage = Page.EEC_ReviewSummarySubmission;
                if (isSaveOnly) {
                    pPage = Page.eec_licensingattachment;
                    //licenseTransaction.Last_Reached_Step__c = 'Attachments';
                }
                pPage.getParameters().put('ltId', licenseTransaction.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage() + e.getStackTraceString());
            ApexPages.addMessage(errMsg);
            
        }
        return null;
    }
    public void addMemberIDPageParameter(PageReference pPage, Boolean encrypt) {
        if (String.isNotBlank(accountId)) {
            pPage.getParameters().put('member', accountId);
        }
    }
    public void UpdateDocument() {
        string docId = apexpages.currentpage().getparameters().get('docId');
        string commandType = apexpages.currentpage().getparameters().get('commandType');
        Transaction_Document__c transactionDoc = [
                select Id, Document_Type__c,
                        Document__c, Document__r.Provider__r.Umbrella_Members__c, Document__r.Provider__c
                from Transaction_Document__c
                where Id = :docId
        ];
        List<Document__c> listDocument;
        if (commandType == 'Umbrella') {
            listDocument = [
                    select Id
                    from Document__c
                    where Document_Type__c = :transactionDoc.Document_Type__c
                    and Provider__c = :licenseTransaction.Provider__r.Umbrella_Members__c and Current__c = true
            ];
        } else if (commandType == 'Provider') {
            listDocument = [
                    select Id
                    from Document__c
                    where Document_Type__c = :transactionDoc.Document_Type__c
                    and Provider__c = :licenseTransaction.Provider__c and Current__c = true
            ];
        }
        if (listDocument.size() > 0) {
            transactionDoc.Document__c = listDocument[0].Id;
            update transactionDoc;
        }
        doGetDocuments();
    }
    public Pagereference closeAndreturnToHome() {
        if (!isInternalUser) {
            PageReference pPage;
            pPage = Page.EEC_PortalLandingPage;
            //pPage.getParameters().put('ltId', licenseTransation.Id);
            pPage.setRedirect(true);
            return pPage;
        } else {
            PageReference pPage = new PageReference('/' + licenseTransaction.Id);
            return pPage;
        }
    }
    public void delAttachment() {
        string docId = apexpages.currentpage().getparameters().get('index');
        string tranDocId = apexpages.currentpage().getparameters().get('tranDocId');
        S3_File__c s3File = [select Id from S3_File__c where Id = :docId];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        delete s3File;
        Transaction_Document__c transactionDocument = [
                select Id,
                        Document__c, Document__r.Id, Status__c
                from Transaction_Document__c
                where Id = :tranDocId
        ];
        List<S3_File__c> listS3File = [select Id from S3_File__c where Document__c = :transactionDocument.Document__r.Id];
        if (listS3File.size() == 0) {
            transactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
        } else {
            transactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_SUBMITTED; 
        }
        update transactionDocument;
        doGetDocuments();
    }
    
}