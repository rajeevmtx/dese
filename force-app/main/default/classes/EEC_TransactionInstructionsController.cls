public with sharing class EEC_TransactionInstructionsController { 
    public PageReference nextInstruction() {
        return null;
    }


    public PageReference CancelTransaction() {
        return null;
    }

         
    public Boolean isSubmitted                                          { get; set; }
    public String licenseRecordTypeName                                 { get; set; }
    public Licensing_Transaction__c licenseTransation                   { get; set; } 
    public Transaction_Contact__c transactionContact                    { get; set; }
    public String licenseInstructionMessage                             { get; set; } 
    public List<selectOption> listLicenseRequested                      { get; set; }
    public String navigationSavePreviousWrapper                         { get; set; }
    public String errorMessage                                          { get; set; }
    public List<Transaction_Document__c> transDocList = new List<Transaction_Document__c>();
    public EEC_TransactionInstructionsController(){
        isSubmitted = false;
        licenseRecordTypeName = '';
        licenseInstructionMessage = '';
        errorMessage = '';
        listLicenseRequested = new List<selectOption>();
        getLicenseTransaction();
        getTransactionContactData();
    }
    public void getTransactionContactData() {
        List<Transaction_Contact__c> transContList = new List<Transaction_Contact__c>();
        if (String.isNotBlank(licenseTransation.Id)) {
            for (Transaction_Contact__c transaContact : [SELECT Id,First_Name__c,Last_Name__c,Role__c,Date_of_Birth__c
                                                        FROM Transaction_Contact__c
                                                        WHERE Licensing_Transaction__c = :licenseTransation.Id 
                                                        AND (Role__c = :EEC_Constants.TC_ROLE_LICENSEE 
                                                        OR Role__c = :EEC_Constants.TC_ROLE_ASSISTANT)]) {
                transContList.add(transaContact);
            }
            if (!transContList.isEmpty()) {
                transactionContact = transContList[0];
            }
        }
    }
    public void getLicenseTransaction() {
        String licenseTransactionId = ApexPages.currentPage().getParameters().get('ltId');
        if (String.isNotBlank(licenseTransactionId)) {
            List<Licensing_Transaction__c> ltList = [SELECT Reason_for_Request__c,Date_Activity_Ends__c, transactionRecordTypeDeveloperName__c,
                                                            Date_Care_Resumes__c,New_Name__c,Date_Name_Change_is_Effective__c,
                                                            License_Requested__c,Transaction_Special_Requests_Comments__c,
                                                            IsAssistantUpgradeToCertified__c,Highest_Reached_Step__c, Status__c,
                                                            Transaction_Configuration__r.EEC_Licensing_Transaction_Instructions__c,
                                                            provider__r.Name, provider__r.Provider_Address_1__c, provider__r.Provider_Address_2__c,
                                                            provider__r.Provider_City__c, provider__r.Provider_City__r.Name, provider__r.State__c,
                                                            provider__r.Provider_Zip_Code__c, provider__r.Provider_Status__c, provider__r.Capacity__c, 
                                                            Transaction_Configuration__r.FCC_Licensing_Transaction_Instructions__c,
                                                            Transaction_Configuration__r.GSA_Licensing_Transaction_Instructions__c, provider__r.Is_GSA__c,
                                                            Transaction_Configuration__r.R_P_Licensing_Transaction_Instructions__c, provider__r.Is_FCC__c,
                                                            provider__r.Is_R_P__c, providerRecordTypeDeveloperName__c,provider__r.RecordType.Name,
                                                            Are_you_switching_large_to_small_group__c,Are_you_switching_small_to_large_group__c,
                                                            Lead_Paint_Constructed_before_1978__c,
                                                            Transportation__c,Transportation_provided1__c,Lead_Paint_Compliance__c,
                                                            Added_A_Coal_Pellet_Wood_Burning_Stove__c,Drinking_Water_Source__c, Provider__c,
                                                            First_Aid_Certified__c,CPR_Certified__c,Took_Upgrading_Capacity_Training__c,
                                                            Took_FCC_Orientation_Module_1__c,Taken_Intro_to_EEC_in_Mass_Orientation__c,
                                                            Took_SIDS_Training__c,
                                                            Took_Transportation_Training__c,Took_Medication_Administration_Training__c,
                                                            Took_FCC_Orientation__c 
                                                    FROM Licensing_Transaction__c
                                                    WHERE Id = :licenseTransactionId];
            if (!ltList.isEmpty()) {
                licenseTransation = ltList.get(0); 
                licenseRecordTypeName = licenseTransation.transactionRecordTypeDeveloperName__c;
                if ((licenseTransation.provider__r.Is_FCC__c || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) 
                        && String.isNotBlank(licenseTransation.Transaction_Configuration__r.FCC_Licensing_Transaction_Instructions__c)) {
                    licenseInstructionMessage = licenseTransation.Transaction_Configuration__r.FCC_Licensing_Transaction_Instructions__c;
                } else if (licenseTransation.provider__r.Is_GSA__c && String.isNotBlank(licenseTransation.Transaction_Configuration__r.GSA_Licensing_Transaction_Instructions__c)) {
                    licenseInstructionMessage = licenseTransation.Transaction_Configuration__r.GSA_Licensing_Transaction_Instructions__c;
                } else if (licenseTransation.provider__r.Is_R_P__c && String.isNotBlank(licenseTransation.Transaction_Configuration__r.R_P_Licensing_Transaction_Instructions__c)) {
                    licenseInstructionMessage = licenseTransation.Transaction_Configuration__r.R_P_Licensing_Transaction_Instructions__c;
                } else {
                    licenseInstructionMessage = licenseTransation.Transaction_Configuration__r.EEC_Licensing_Transaction_Instructions__c;
                }
                listLicenseRequested.add(new SelectOption('', '--Select--'));
                if (String.isNotBlank(licenseTransation.Provider__r.Capacity__c) && licenseTransation.Provider__r.Capacity__c.contains('10')) {
                    listLicenseRequested.add(new SelectOption('8', '8'));
                    listLicenseRequested.add(new SelectOption('6', '6'));
                } else if (String.isNotBlank(licenseTransation.Provider__r.Capacity__c) && licenseTransation.Provider__r.Capacity__c.contains('8')) {
                    listLicenseRequested.add(new SelectOption('6', '6'));
                } else {
                    listLicenseRequested.add(new SelectOption('6', '6'));
                }
                if (licenseTransation.Status__c == EEC_Constants.LT_SUBMITTED || licenseTransation.Status__c == EEC_Constants.LT_CLOSED 
                        || licenseTransation.Status__c == EEC_Constants.LT_UNDER_REVIEW) {
                    isSubmitted = true;
                }
            }
        } else { 
            licenseTransation = new Licensing_Transaction__c();
        }
    }
    
    public void deleteDocumentRecord(string documentName) {
        Set<id> docIds = new Set<Id>();
        List<Transaction_Document__c> transDocToBeDeleted = new List<Transaction_Document__c>();
        List<Document__c> docTobeDeleted = new List<Document__c>();
        for (Transaction_Document__c delTransDoc : [SELECT id,Transaction_Document_Name__c,Document__c
                                                    FROM Transaction_Document__c
                                                    WHERE Transaction_Document_Name__c = :documentName
                                                    AND Licensing_Transaction__c = :licenseTransation.id]) {
            transDocToBeDeleted.add(delTransDoc);
            docIds.add(delTransDoc.Document__c);
        }
        for (Document__c doc : [SELECT id,Name FROM Document__c WHERE id IN :docIds]) {
            docTobeDeleted.add(doc);
        }
        if (!docTobeDeleted.isEmpty()) {
            delete docTobeDeleted;
        }
        if (!transDocToBeDeleted.isEmpty()) {
            delete transDocToBeDeleted;
        }
    }
    public void createDocumentRecordWithDocumentType(string documentName) {
        List<Document__c> documentTobeInserted = new List<Document__c>();
        for (Document_Type__c docType : [SELECT Id, Name, LEAD_Configuration__c, Responsible_Party__c
                                        FROM Document_Type__c
                                        WHERE Name Like :documentName
                                        AND LEAD_Configuration__r.Name = : licenseTransation.provider__r.RecordType.Name
                                        LIMIT 1]) {
            Document__c docObj = new Document__c();
            docObj.Document_Type__c = docType.Id;
            docObj.Document_Name__c = documentName;
            docObj.LEAD_Configuration__c = docType.LEAD_Configuration__c;
            docObj.Responsible_Party__c = docType.Responsible_Party__c;
            docObj.Status__c = EEC_Constants.DOCUMENT_RESPONSIBLE_PARTY_UNSUBMITTED;
            docObj.Provider__c = licenseTransation.Provider__c;
            docObj.Valid_From__c = DateTime.now();
            docObj.Attachment_Status__c = EEC_Constants.DOCUMENT_NO_ATTACHMENT;
            documentTobeInserted.add(docObj);
        }
        if (!documentTobeInserted.isEmpty()) {
            insert documentTobeInserted;
        }
    }
    public void createDocumentRecord(string documentName, boolean isRequired) {
        Date moduLe2NotApplicableDate = date.newinstance(2010, 8, 1);
        Document__c docObj = new Document__c();
        docObj.Document_Name__c = documentName;
        if (documentName == 'FCC Orientation, Module II' && licenseTransation.Provider__r.First_Issue_Date__c <= moduLe2NotApplicableDate) {
            docObj.Not_Applicable__c = true;
        }
        docObj.Provider__c = licenseTransation.Provider__c;
        docObj.Valid_From__c = DateTime.now();
        docObj.Attachment_Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_ATTACHMENT_NO_ATTACHMENT;
        insert docObj;
        Transaction_Document__c transDocObj = new Transaction_Document__c();
        if (isRequired) {
            transDocObj.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_REQUIRED;
            transDocObj.Submit_Transaction_Only_If_Uploaded__c = true;
        } else {
            transDocObj.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_OPTIONAL;
        }
        transDocObj.Transaction_Document_Name__c = documentName;
        transDocObj.Licensing_Transaction__c = licenseTransation.id;
        transDocObj.Last_Status_Date__c = Date.Today();
        transDocObj.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
        transDocObj.Document__c = docObj.id;
        transDocList.add(transDocObj);
    }
    public void createTrainingTransactionDocuments() {
        Set<String> existingDocuments = new Set<String>();
        Set<String> existingLibraryDocuments = new Set<String>();
        for (Transaction_Document__c transactionDocument : [SELECT Id, Transaction_Document_Name__c
                                                            FROM Transaction_Document__c
                                                            WHERE Licensing_Transaction__c = :licenseTransation.id]) {
            existingDocuments.add(transactionDocument.Transaction_Document_Name__c);
        }
        for (Document__c document : [SELECT Id, Document_Name__c
                                    FROM Document__c
                                    WHERE Provider__c = :licenseTransation.Provider__c]) {
            existingLibraryDocuments.add(document.Document_Name__c);
        }
        if (licenseTransation.Took_FCC_Orientation__c == 'Yes' && !existingDocuments.contains('FCC Orientation, Module II')) {
            createDocumentRecord('FCC Orientation, Module II', true);
        } else if (licenseTransation.Took_FCC_Orientation__c == 'No' && !existingDocuments.contains('FCC Orientation, Module II')) {
            createDocumentRecord('FCC Orientation, Module II', false);
        }
        if (licenseTransation.Took_Medication_Administration_Training__c == 'Yes' && !existingDocuments.contains('Medication Administration Online Training')) {
            createDocumentRecord('Medication Administration Online Training', true);
        } else if (licenseTransation.Took_Medication_Administration_Training__c == 'No' && !existingDocuments.contains('Medication Administration Online Training')) {
            createDocumentRecord('Medication Administration Online Training', false);
        }
        if (licenseTransation.Took_Transportation_Training__c == 'Yes' && !existingDocuments.contains('Transportation Safety Training: Look Before You Lock')) {
            createDocumentRecord('Transportation Safety Training: Look Before You Lock', true);
        } else if (licenseTransation.Took_Transportation_Training__c == 'No' && !existingDocuments.contains('Transportation Safety Training: Look Before You Lock')) {
            createDocumentRecord('Transportation Safety Training: Look Before You Lock', false);
        }
        if (licenseTransation.Took_SIDS_Training__c == 'Yes' && !existingDocuments.contains('Reducing the Risk of SIDS in Child Care')) {
            createDocumentRecord('Reducing the Risk of SIDS in Child Care', true);
        } else if (licenseTransation.Took_SIDS_Training__c == 'No' && !existingDocuments.contains('Reducing the Risk of SIDS in Child Care')) {
            createDocumentRecord('Reducing the Risk of SIDS in Child Care', false);
        }
       
       
        if (licenseTransation.Taken_Intro_to_EEC_in_Mass_Orientation__c == 'Yes' && !existingDocuments.contains('Family Child Care Regular Assistant training')) {
            createDocumentRecord('Family Child Care Regular Assistant training', true);
        } else if (licenseTransation.Taken_Intro_to_EEC_in_Mass_Orientation__c == 'No' && !existingDocuments.contains('Family Child Care Regular Assistant training')) {
            createDocumentRecord('Family Child Care Regular Assistant training', false);
        }
        if (licenseTransation.Took_FCC_Orientation_Module_1__c == 'Yes' && !existingDocuments.contains('FCC Orientation, Module 1')) {
            createDocumentRecord('FCC Orientation, Module 1', true);
        } else if (licenseTransation.Took_FCC_Orientation_Module_1__c == 'No' && !existingDocuments.contains('FCC Orientation, Module 1')) {
            createDocumentRecord('FCC Orientation, Module 1', false);
        }
        if (licenseTransation.Took_Upgrading_Capacity_Training__c == 'Yes' && !existingDocuments.contains('Upgrade Capacity Training and Quiz')) {
            createDocumentRecord('Upgrade Capacity Training and Quiz', true);
        } else if (licenseTransation.Took_Upgrading_Capacity_Training__c == 'No' && !existingDocuments.contains('Upgrade Capacity Training and Quiz')) {
            createDocumentRecord('Upgrade Capacity Training and Quiz', false);
        }
        if (licenseTransation.CPR_Certified__c == 'Yes' && !existingDocuments.contains('CPR')) {
            createDocumentRecord('CPR', true);
        } else if (licenseTransation.CPR_Certified__c == 'No' && !existingDocuments.contains('CPR')) {
            createDocumentRecord('CPR', false);
        }
        if (licenseTransation.First_Aid_Certified__c == 'Yes' && !existingDocuments.contains('First Aid')) {
            createDocumentRecord('First Aid', true);
        } else if (licenseTransation.First_Aid_Certified__c == 'No' && !existingDocuments.contains('First Aid')) {
            createDocumentRecord('First Aid', false);
        }
        if (licenseTransation.Drinking_Water_Source__c == 'Private Water Supply' && !existingDocuments.contains('Private Water Supply Evidence') && (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL)) {
            createDocumentRecord('Private Water Supply Evidence', true);
        } else if (licenseTransation.Drinking_Water_Source__c != 'Private Water Supply' && !existingDocuments.contains('Private Water Supply Evidence')) {
            deleteDocumentRecord('Private Water Supply Evidence');
        }
        if (licenseTransation.Added_A_Coal_Pellet_Wood_Burning_Stove__c == 'Yes' && !existingDocuments.contains('Evidence of stove equipment used child care')) {
            createDocumentRecord('Evidence of stove equipment used child care', true);
        } else if (licenseTransation.Drinking_Water_Source__c == 'No' && !existingDocuments.contains('Evidence of stove equipment used child care')) {
            createDocumentRecord('Evidence of stove equipment used child care', false);
        }
        if ((LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL) && !existingDocuments.contains('Medical Letter')) {
            createDocumentRecord('Medical Letter', false);
        }
        if (licenseTransation.Lead_Paint_Compliance__c == 'Yes' && !existingLibraryDocuments.contains('Occupancy Permit')) {
            createDocumentRecordWithDocumentType('Occupancy Permit');
        }
        if (licenseTransation.Transportation_provided1__c == 'Yes' && !existingLibraryDocuments.contains('Transportation Document')) {
            createDocumentRecordWithDocumentType('Transportation Document');
        }
        if (licenseTransation.Transportation__c == 'Program Owned' && !existingLibraryDocuments.contains('Transportation Supplement Form')) {
            createDocumentRecordWithDocumentType('Transportation Supplement Form');
        }
        if (licenseTransation.Transportation__c == 'Program Owned' && !existingLibraryDocuments.contains('Evidence of Insurance')) {
            createDocumentRecordWithDocumentType('Evidence of Insurance');
        }
        if (licenseTransation.Transportation__c == 'Subcontract' && !existingLibraryDocuments.contains('Transportation Contract Agreement')) {
            createDocumentRecordWithDocumentType('Transportation Contract Agreement');
        }
        if (licenseTransation.Lead_Paint_Constructed_before_1978__c == 'Yes' && !existingLibraryDocuments.contains('Detailed lead paint inspection')) {
            createDocumentRecordWithDocumentType('Detailed lead paint inspection');
        }
       
        if (licenseTransation.Are_you_switching_small_to_large_group__c == 'Yes' && !existingLibraryDocuments.contains('Healthcare Policy')) {
            createDocumentRecordWithDocumentType('Healthcare Policy');
        } 
        if (licenseTransation.Are_you_switching_small_to_large_group__c == 'Yes' && !existingLibraryDocuments.contains('Healthcare consultant agreement')) {
            createDocumentRecordWithDocumentType('Healthcare consultant agreement');
        } 
        if (licenseTransation.Are_you_switching_small_to_large_group__c == 'Yes' && !existingLibraryDocuments.contains('Plan for Transitioning Children')) {
            createDocumentRecordWithDocumentType('Plan for Transitioning Children');
        }
        if (licenseTransation.Are_you_switching_large_to_small_group__c == 'No' && !existingLibraryDocuments.contains('Plan for Transitioning Children')) {
            createDocumentRecordWithDocumentType('Plan for Transitioning Children');
        }
        if (licenseTransation.Are_you_switching_large_to_small_group__c == 'No' && !existingLibraryDocuments.contains('Healthcare consultant agreement')) {
            createDocumentRecordWithDocumentType('Healthcare consultant agreement');
        }
        if (licenseTransation.Are_you_switching_large_to_small_group__c == 'No' && !existingLibraryDocuments.contains('Healthcare Policy')) {
            createDocumentRecordWithDocumentType('Healthcare Policy');
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME && !existingDocuments.contains('Proof of name change (Ex: Marriage license, Government issued Id')) {
            createDocumentRecord('Proof of name change (Ex: Marriage license, Government issued Id', true);
        }
        if (!transDocList.isEmpty()) {
            insert transDocList;
        }
    }
   /* public Pagereference nextInstruction() {
        try {
            errorMessage = '';
            EEC_NavigationController.NavigateSavePreviousWrapper navigateWrapper = (EEC_NavigationController.NavigateSavePreviousWrapper)JSON.deserialize(navigationSavePreviousWrapper, EEC_NavigationController.NavigateSavePreviousWrapper.class);
            if (!isSubmitted) {
                if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME 
                        && (transactionContact.Role__c == EEC_Constants.TC_ROLE_LICENSEE 
                        || transactionContact.Role__c == EEC_Constants.TC_ROLE_ASSISTANT)) {
                    update transactionContact;
                }
                licenseTransation.Highest_Reached_Step__c = navigateWrapper.updateHighestStepFlag ? navigateWrapper.highestReachedStepValue : licenseTransation.Highest_Reached_Step__c; 
                licenseTransation.Last_Reached_Step__c = navigateWrapper.updateHighestStepFlag ? navigateWrapper.highestReachedStepValue : licenseTransation.Highest_Reached_Step__c; 
                upsert licenseTransation;
                createTrainingTransactionDocuments();
            }
            PageReference navigateToPage = new PageReference('/apex/'+navigateWrapper.nextPage);
            navigateToPage.getParameters().put('ltId', licenseTransation.Id);
            EEC_NavigationController.addMemberIDPageParameter(navigateToPage);
            navigateToPage.setRedirect(true);
            return navigateToPage;
        } catch(Exception ex) {
            errorMessage = 'Unexpected error occurred ! Please contact your System Administrator - ' + ex.getMessage();
        }
        return null;
    }*/
   /* public Pagereference CancelTransaction() {
        Licensing_Transaction__c licenseTransaction = new Licensing_Transaction__c(id = licenseTransation.id);
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            licenseTransaction.Status__c = EEC_Constants.LT_CANCELLED;
            licenseTransaction.Status_Reason__c = 'Applicant withdrew';
            licenseTransaction.Reason_Closed_Cancelled__c = 'Cancelled by portal user';
            if (!isSubmitted) {
                update licenseTransaction;
            }
            PageReference pPage = page.EEC_PortalLandingPage;
            EEC_NavigationController.addMemberIDPageParameter(pPage);
            return pPage;
        } else {
            licenseTransaction.Status__c = EEC_Constants.LT_CANCELLED;
            licenseTransaction.Status_Reason__c = 'Lack of Response';
            licenseTransaction.Reason_Closed_Cancelled__c = 'Cancelled by EEC user';
            if (!isSubmitted) {
                update licenseTransaction;
            }
            return new PageReference('/' + licenseTransaction.id);
        }
    }*/
}