public with sharing class EEC_LicensingTransactionWidgetController {
    public String LicenserecordID { get; set; }
    public String transactType { get; set; }
    public String proRecordTypeDeveloperName { get; set; }
    public String transCurrentStatus { get; set; }
    public string taxCertStatus { get; set; } 
    public string navigateLicenseRecordId { get; set; }
    //public string feePaymentChecklistStatus{get;set;}
    public List<SelectedTransactionContactWrapper> licenseTransactionWrapperList { get; set; }
    public Boolean isSelected { get; set; }
    public String feePaymentCheckList = 'Submit_application_fee_payment';
    public string transDiscardType { get; set; }
    public list<EEC_LicenseTransactionWrapperClass> liscnTransSubmtdList;
    public list<TransRecWrapperClass> transWrapperList { get; set; }
    public Licensing_Transaction__c licentranObj;
    public Set<String> addContactsEligibleApplicationSet {get; set;}
    public list<EEC_LicenseTransactionWrapperClass> getliscnTransSubmtdList() {
        return liscnTransSubmtdList;
    }
    public void setliscnTransSubmtdList(list<EEC_LicenseTransactionWrapperClass> valueList) {
        liscnTransSubmtdList = valueList;
        initialize();
    }
    public void initialize() {
        if (liscnTransSubmtdList != null && liscnTransSubmtdList.size() > 0) {
            transWrapperList = new list<TransRecWrapperClass>();
            string taxCertification = 'Submit_Tax_Certification_form';
            string brcConsent = 'Enter_background_check_information_in_the_BRC_App';
            string feePayment = 'Submit_Application_Fee_Payment';
            for (EEC_LicenseTransactionWrapperClass transRecord : liscnTransSubmtdList) {
                transWrapperList.add(new TransRecWrapperClass(transRecord.transRec, transRecord.showAddContactsButton));
            }
            for (TransRecWrapperClass transWrapperRec : transWrapperList) {
                for (Transaction_Due_Diligence__c transDueDiligence : transWrapperRec.transRec.Transaction_Due_Diligence__r) {
                    if (String.isNotBlank(transDueDiligence.Unique_API_Name__c) && transDueDiligence.Unique_API_Name__c == taxCertification && transWrapperRec.transRec.Tax_Certification_Status__c != 'Completed') {
                        transWrapperRec.isTaxCertfShow = true;
                    } else if (String.isNotBlank(transDueDiligence.Unique_API_Name__c) && (transDueDiligence.Unique_API_Name__c == brcConsent || transDueDiligence.Unique_API_Name__c == 'Submit_background_record_check_consent_form' || transDueDiligence.Unique_API_Name__c == 'Submit_BRC')) {
                        transWrapperRec.isbrcConsentShow = true;
                        if (transWrapperRec.transRec.Provider__r.Is_FCC__c) {
                            transWrapperRec.isfccContactShow = true;
                        }
                        if (transWrapperRec.transRec.Provider__r.Is_GSA__c || transWrapperRec.transRec.Provider__r.Is_R_P__c) {
                            transWrapperRec.isGSAAndRPContactShow = true;
                        }
                    } else if (String.isNotBlank(transDueDiligence.Unique_API_Name__c) && transDueDiligence.Unique_API_Name__c == feePayment && transDueDiligence.Status__c == 'Pending') {
                        transWrapperRec.isfeePaymentShow = true;
                    }
                }
            }
        }
    }
    public string feePaymentChecklistStatus {
        get {
            string status;
            list<Transaction_Due_Diligence__c> licTransDueDiligenceList = new list<Transaction_Due_Diligence__c>();
            for (Transaction_Due_Diligence__c transDueDil : [
                    SELECT id,Status__c
                    FROM Transaction_Due_Diligence__c
                    WHERE Unique_API_Name__c = :feePaymentCheckList
                    AND Licensing_Transaction__c = :LicenserecordID
            ]) {
                licTransDueDiligenceList.add(transDueDil);
            }
            if (licTransDueDiligenceList != null && licTransDueDiligenceList.size() > 0) {
                status = licTransDueDiligenceList[0].Status__c;
                return status;
            } else {
                return null;
            }
        }
        set;
    }
    public EEC_LicensingTransactionWidgetController() {
        licenseTransactionWrapperList = new List<SelectedTransactionContactWrapper>();
    }
    public Pagereference reRouteTransactionToLastStep() {
        system.debug('transaction Id == '+navigateLicenseRecordId);
        PageReference pPage;
        Licensing_Transaction__c licenseTransation;
        for (Licensing_Transaction__c ltRec : [
                SElECT Id,Last_Reached_Step__c,Provider__c,RecordType.DeveloperName
                FROM Licensing_Transaction__c
                WHERE
                        Id = :navigateLicenseRecordId
        ]) {
            licenseTransation = ltRec;
        } 
        if (licenseTransation != null && licenseTransation.Last_Reached_Step__c != null) {
            if (proRecordTypeDeveloperName == 'FCC') {
                pPage = EEC_Util.lastFCCStepMap.get(licenseTransation.Last_Reached_Step__c);
            } else if (proRecordTypeDeveloperName == 'FCC_Assistant') {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(licenseTransation.Last_Reached_Step__c);
            } else if (proRecordTypeDeveloperName == 'Large_Group' || proRecordTypeDeveloperName == 'Small_Group') {
                pPage = EEC_Util.lastGSAStepMap.get(licenseTransation.Last_Reached_Step__c);
            } else if (proRecordTypeDeveloperName == 'Umbrella' || proRecordTypeDeveloperName == 'Temporary_Shelter' || proRecordTypeDeveloperName == 'Group_Care'
                    || proRecordTypeDeveloperName == 'Foster_Care_Agency' || proRecordTypeDeveloperName == 'Adoption_Agency') {
                pPage = EEC_Util.lastRPStepMap.get(licenseTransation.Last_Reached_Step__c);
            } else if (proRecordTypeDeveloperName == 'Other_Eligible_Provider' || proRecordTypeDeveloperName == 'Public_School' || proRecordTypeDeveloperName == 'Private_School') {
                pPage = EEC_Util.lastCBCStepMap.get(licenseTransation.Last_Reached_Step__c);
            } else if(proRecordTypeDeveloperName == 'Informal_Child_Care') {
                pPage = EEC_Util.lastInformalCareStepMap.get(licenseTransation.Last_Reached_Step__c);
            }
        } else {
            pPage = Page.EEC_transactionprovider;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        pPage.getParameters().put('member', licenseTransation.Provider__c);
        return pPage;
    }
    public void discardTrans() {
        Savepoint sp = Database.setSavepoint();
        try {
            update new Licensing_Transaction__c(id = navigateLicenseRecordId, Status__c = 'Cancelled', Status_Reason__c = 'Applicant withdrew');
        } catch (DMLException e) {
            Database.rollback(sp);
        }
    }
    public void sendTaxCertEmailNotification() {
        List<Licensing_Transaction__c> licenseTransList = new List<Licensing_Transaction__c>();
        for (Licensing_Transaction__c licenseObj : [
                SELECT Id,Provider__c,Tax_Certification_Status__c,Submission_Confirmation_Sent__c
                FROM Licensing_Transaction__c
                WHERE id = :navigateLicenseRecordId
        ]) {
            if (licenseObj.Tax_Certification_Status__c != 'Completed') {
                licenseObj.Submission_Confirmation_Sent__c = false;
                licenseTransList.add(licenseObj);
            }
        }
        if (licenseTransList != null && licenseTransList.size() > 0) {
            update licenseTransList;
        }
    }
    public void updateFeePaidDueDiligenceCheklist() {
        List<Transaction_Due_Diligence__c> feePaymentist = new List<Transaction_Due_Diligence__c>();
        List<Licensing_Transaction__c> updatePaymentMailedField = new List<Licensing_Transaction__c>();
        for (Transaction_Due_Diligence__c transDueDelObj : [select id,Unique_API_Name__c,Status__c,Completion_Date__c,Licensing_Transaction__r.Payment_Mailed__c from Transaction_Due_Diligence__c Where Unique_API_Name__c = :feePaymentCheckList AND Licensing_Transaction__c = :navigateLicenseRecordId]) {
            transDueDelObj.Status__c = 'Completed';
            transDueDelObj.Completion_Date__c = DateTime.now();
            transDueDelObj.Licensing_Transaction__r.Payment_Mailed__c = true;
            updatePaymentMailedField.add(transDueDelObj.Licensing_Transaction__r);
            feePaymentist.add(transDueDelObj);
        }
        if (feePaymentist != null && feePaymentist.size() > 0) {
            update feePaymentist;
        }
        if (updatePaymentMailedField != null && updatePaymentMailedField.size() > 0) {
            update updatePaymentMailedField;
        }
    }
    public String recordIdClicked { get; private set; }
    public void getBrcRecordData() {
        recordIdClicked = navigateLicenseRecordId;
        licenseTransactionWrapperList = new List<SelectedTransactionContactWrapper>();
        for (Transaction_Contact__c transObj : [select id,Licensing_Transaction__c,BRC_Consent_Status__c,BRC_Consent_Signed_Date__c,BRC_Required__c,Role__c,First_Name__c,Last_Name__c from Transaction_Contact__c Where Licensing_Transaction__c = :navigateLicenseRecordId AND (BRC_Consent_Status__c = 'Sent' OR BRC_Consent_Status__c = 'Completed')]) {
            licenseTransactionWrapperList.add(new SelectedTransactionContactWrapper(transObj));
        }
    }
    public void resetBrcRequiredField() {
        Set<Id> transactionRecordIds = new Set<Id>();
        List<Transaction_Contact__c> transcontactList = new List<Transaction_Contact__c>();
        for (SelectedTransactionContactWrapper selectedRecord : licenseTransactionWrapperList) {
            if (selectedRecord.checked) {
                selectedRecord.transactionContactWrapper.BRC_Required__c = false;
                selectedRecord.transactionContactWrapper.BRC_Consent_Request_Date__c = null;
                selectedRecord.transactionContactWrapper.BRC_Consent_Status__c = '';
                selectedRecord.transactionContactWrapper.BRC_Consent_Signed_Date__c = null;
                transactionRecordIds.add(selectedRecord.transactionContactWrapper.Id);
                transcontactList.add(selectedRecord.transactionContactWrapper);
            }
        }
        update transcontactList;
        List<Transaction_Contact__c> transcontactList1 = new List<Transaction_Contact__c>();
        for (Transaction_Contact__c transObj1 : [
                SELECT id,Licensing_Transaction__c,BRC_Required__c,First_Name__c,Last_Name__c,
                        BRC_Consent_Request_Date__c,BRC_Consent_Status__c
                FROM Transaction_Contact__c
                WHERE id IN :transactionRecordIds
        ]) {
            transObj1.BRC_Required__c = true;
            transcontactList1.add(transObj1);
        }
        update transcontactList1;
    }
    public class SelectedTransactionContactWrapper {
        public Boolean checked { get; set; }
        public Transaction_Contact__c transactionContactWrapper { get; set; }
        public SelectedTransactionContactWrapper(Transaction_Contact__c transactionContactWrapper) {
            this.transactionContactWrapper = transactionContactWrapper;
        }
    }
    public class TransRecWrapperClass {
        public Licensing_Transaction__c transRec    { get; set; }
        public boolean isTaxCertfShow               { get; set; }
        public boolean isbrcConsentShow             { get; set; }
        public boolean isfeePaymentShow             { get; set; }
        public boolean isfccContactShow             { get; set; }
        public boolean isGSAAndRPContactShow        { get; set; }
        public boolean showAddContactsButton        { get; set; }
        public TransRecWrapperClass(Licensing_Transaction__c transRec, boolean showAddContactsButton) {
            this.transRec = transRec;
            isTaxCertfShow = false;
            isbrcConsentShow = false;
            isfeePaymentShow = false;
            isfccContactShow = false;
            isGSAAndRPContactShow = false;
            this.showAddContactsButton = showAddContactsButton;
        }
    }
    public void selectAll() {
        if (isSelected) {
            for (SelectedTransactionContactWrapper w : licenseTransactionWrapperList) {
                w.checked = true;
            }
        } else {
            for (SelectedTransactionContactWrapper w : licenseTransactionWrapperList) {
                w.checked = false;
            }
        }
    }
}