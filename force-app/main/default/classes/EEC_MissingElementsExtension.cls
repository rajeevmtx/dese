public without sharing class EEC_MissingElementsExtension {
    public Licensing_Transaction__c licensingTransaction                        { get; set; }
    public list<Transaction_Due_Diligence__c> transactionDueDiligenceList       { get; set; }
    public Boolean isEditMode                                                   { get; set; }
    public boolean reloadPage                                                   { get; set; } 
    public boolean isPendingDoc                                                 { get; set; }
    public boolean isVisitPresent;
    public boolean isVisitClosed;
    public boolean isVisitCompleted;
    public boolean isPendingVariance                                            { get; set; }
    public boolean isMissinglicensorRecommendation                              { get; set; }
    public string reviewDocumnetCheklistItem                                    { get; set; }
    public string varianceChecklistItem                                         { get; set; }
    public string visitAssociation                                              { get; set; }
    public string superVisorChecklistItem                                       { get; set; }
    public string requestSupervisorChecklistItem                                { get; set; }
    public string feePaymentChecklistItem                                       { get; set; } 
    public string filledCapacityChecklistItem                                   { get; set; }
    public String licenseRecordTypeName                                         { get; set; }
    public string FilledRegulatoryStatusChecklistItem                           { get; set; }
    public string filledFilledLicenseTypeChecklistItem                          { get; set; }
    public string filledLicensedIssueDateExpirationDateChecklistItem            { get; set; }
    public string requestSupervisorApprovalChecklistItem                        { get; set; }
    public string certifiedAssistantCapacity                                    { get; set; }
    public string closeTransactionGenerateLicenseItem                           { get; set; }
    public string userRole                                                      { get; set; }
    private string managerid;
    private string profileName;
    public boolean isManager                                                    { get; set; }
    public boolean isResetAllow                                                 { get; set; }
    public Integer selectedDDItemSequance                                       { get; set; }
    public string reviewedCPRCertificationItem                                  { get; set; }
    public string reviewedFirstAidCertificationItem                             { get; set; }
    public string reviewedParentalConsentFormItem                               { get; set; }
    public string reviewedTrainingInformationItem                               { get; set; }

    private Map<String, String> licenseTransactionContactMap;
    private String LTRecordTypeDeveloperName;
    private String ProRecordTypeDeveloperName;
    public EEC_MissingElementsExtension(ApexPages.StandardController stdCtrl){
        licensingTransaction = (Licensing_Transaction__c)stdCtrl.getRecord();
        reloadPage = true;
        isVisitPresent = false;
        isVisitClosed = false;
        isVisitCompleted = false;
        isPendingDoc = false;
        isPendingVariance = false;
        isMissinglicensorRecommendation = false;
        isManager = false;
        isResetAllow = false;
        certifiedAssistantCapacity = EEC_DueDiligenceHepler.certifiedAssistantCapacity;
        reviewDocumnetCheklistItem = EEC_DueDiligenceHepler.reviewAllDocuments;
        reviewedCPRCertificationItem  = EEC_DueDiligenceHepler.REVIEWED_CPR_CERTIFICATION;
        reviewedFirstAidCertificationItem = EEC_DueDiligenceHepler.REVIEWED_FIRST_AID_CERTIFICATION;
        reviewedParentalConsentFormItem = EEC_DueDiligenceHepler.REVIEWED_PARENTAL_CONSENT_FORM;
        reviewedTrainingInformationItem = EEC_DueDiligenceHepler.REVIEWED_TRANING_INFORMATION;
        closeTransactionGenerateLicenseItem = EEC_DueDiligenceHepler.closeTransactionGenerateLicense;
        varianceChecklistItem  = EEC_DueDiligenceHepler.reviewVarianceRequest;
        visitAssociation = EEC_DueDiligenceHepler.visitAssociation;
        requestSupervisorChecklistItem = EEC_DueDiligenceHepler.requestSupervisorApproval;
        superVisorChecklistItem = EEC_DueDiligenceHepler.supervisorApprovalCheckList;
        feePaymentChecklistItem = EEC_DueDiligenceHepler.reviewAndEnterApplicationFeePayment;
        FilledRegulatoryStatusChecklistItem = EEC_DueDiligenceHepler.FilledRegulatoryStatus;
        filledCapacityChecklistItem = EEC_DueDiligenceHepler.filledLicensedCapacity;
        filledFilledLicenseTypeChecklistItem = EEC_DueDiligenceHepler.filledLicenseType;
        filledLicensedIssueDateExpirationDateChecklistItem = EEC_DueDiligenceHepler.filledLicensedIssueDateExpirationDate;
        requestSupervisorApprovalChecklistItem = EEC_DueDiligenceHepler.requestSupervisorApproval;
        for(Licensing_Transaction__c licenseTransaction :[select id,Assigned_To__c,transactionRecordTypeDeveloperName__c,Integrated_Pest_Management_Date__c,
                                                                Building_inspection_expiration_Date__c,Fire_Inspection_Issue_date__c,Health_Inspection_Expiration_Date__c,
                                                                Assigned_To__r.ManagerId,Legacy_System_Transaction_Number__c,Regulatory_Status__c, providerRecordTypeDeveloperName__c
                                                            FROM Licensing_Transaction__c Where Id =:licensingTransaction.Id]){
            if(licenseTransaction.Assigned_To__r.ManagerId == UserInfo.getUserId()){ 
                isManager = true;
            }
            LTRecordTypeDeveloperName = licenseTransaction.transactionRecordTypeDeveloperName__c;
            ProRecordTypeDeveloperName = licenseTransaction.providerRecordTypeDeveloperName__c;
        }
        for(Variance_on_Regulation__c varRec : [SELECT Id,Name,Decision__c,Licensor_Recommendation__c,Source_Transaction__c,
                                                Brief_explanation_for_license__c,Supervisor_Recommendation__c
                                                    FROM Variance_on_Regulation__c 
                                                    WHERE Source_Transaction__c =: licensingTransaction.ID]){
            if(varRec.Licensor_Recommendation__c == null && isMissinglicensorRecommendation == false){
                isMissinglicensorRecommendation = true;
            }
            if(varRec.Decision__c == null && isPendingVariance == false){
                isPendingVariance = true;
            }
        }
        for(Transaction_Document__c transDoc : [SELECT Id,Name,Status__c,Licensing_Transaction__c ,Document__r.Not_Applicable__c
                                                    FROM Transaction_Document__c 
                                                    WHERE Licensing_Transaction__c =: licensingTransaction.ID]){
            if(transDoc.Status__c != null && transDoc.Status__c != EEC_Constants.TRANSACTION_DOCUMENT_STATUS_REVIEWED 
                    && !isPendingDoc && transDoc.Document__r.Not_Applicable__c == false){
                isPendingDoc = true;
            }
        }
        for(User usr:[SELECT id,UserRole.Name,ManagerId,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()]){
            profileName = usr.Profile.Name;
            managerid = usr.ManagerId;
            if(usr.UserRole.Name != null){ 
                userRole = usr.UserRole.Name;
            }
        }
        if(String.isNotBlank(userRole) 
                && (userRole.containsIgnoreCase('Regional Director') 
                || userRole.containsIgnoreCase(EEC_Constants.TRANSACTION_DUE_DILIGENCE_PROVIDER) 
                || userRole.containsIgnoreCase(EEC_Constants.TRANSACTION_DUE_DILIGENCE_SUPERVISOR))) {
            isResetAllow = true;
        }
        fetchTransactionDueDiligence();
    }
    public void fetchTransactionDueDiligence(){
        transactionDueDiligenceList = new list<Transaction_Due_Diligence__c>();
        for(Transaction_Due_Diligence__c trans: [SELECT ID,Associated_Status__c,Associated_Status_Reason__c,Enable_Not_Applicable__c,Help_Text__c,
                                                        Checklist_Name__c,Licensing_Transaction__c,Responsible_Party__c,Status__c,Sequence__c,Unique_API_Name__c,
                                                        Completion_Date__c,LastModifiedBy.name,Automated__c,Video_Link__c, Licensing_Transaction__r.Status__c,
                                                        Licensing_Transaction__r.Building_inspection_expiration_Date__c,Licensing_Transaction__r.Fire_Inspection_Issue_date__c,
                                                        Licensing_Transaction__r.Integrated_Pest_Management_Date__c,Licensing_Transaction__r.Health_Inspection_Expiration_Date__c,
                                                        Licensing_Transaction__r.transactionRecordTypeDeveloperName__c,Licensing_Transaction__r.Regulatory_Status__c,Licensing_Transaction__r.providerRecordTypeDeveloperName__c
                                                    FROM Transaction_Due_Diligence__c  
                                                    WHERE Licensing_Transaction__c =: licensingTransaction.ID ORDER BY Sequence__c]){
            transactionDueDiligenceList.add(trans);                         
        }
        String contactManagementRecordTypeId = Schema.SObjectType.Licensing_Transaction__c.getRecordTypeInfosByDeveloperName().containsKey(EEC_Constants.LT_Contact_Management) 
                ? Schema.SObjectType.Licensing_Transaction__c.getRecordTypeInfosByDeveloperName().get(EEC_Constants.LT_Contact_Management).getRecordTypeId()
                : null;
            if(licensingTransaction.RecordTypeId == contactManagementRecordTypeId) {
                checkBRCLicenseFieldStatus(true,false);
            } else if(ProRecordTypeDeveloperName =='Large_Group'
                    || ProRecordTypeDeveloperName =='Small_Group'
                    || ProRecordTypeDeveloperName =='Public_School'
                    || ProRecordTypeDeveloperName =='Private_School'
                    || ProRecordTypeDeveloperName =='Other_Eligible_Provider'){
                checkBRCLicenseFieldStatus(false,true);
            } else {
                checkBRCLicenseFieldStatus(false,false);
            }
    }
    public PageReference setEditMode() {  
        isEditMode = true;  
        return null; 
    } 
    public PageReference cancelChanges() {
        fetchTransactionDueDiligence();
        isEditMode = false;   
        return null; 
    }
    public PageReference saveTransactionDueDiligence(){
        list<Conditions_and_Limitations__c> conditionList = [SELECT Id,
                                                                    Condition_Status__c
                                                                FROM Conditions_and_Limitations__c 
                                                                WHERE Source_Transaction__c=:licensingTransaction.id 
                                                                AND Condition_Status__c =: EEC_Constants.CONDITION_LIMITATION_STATUS_PENDING_APPROVAL];
       // try {
            reloadPage = true;
            list<Transaction_Due_Diligence__c> transDueDiligenceListToUpdate = new list<Transaction_Due_Diligence__c>();
            list<Licensing_Transaction__c> LicenseTransationList = new list<Licensing_Transaction__c>();
            Boolean isPendingChecklist = false;
            Boolean isRequestSupervisorNA = false;
            if(transactionDueDiligenceList.size() > 0) {
                for(Transaction_Due_Diligence__c trans: transactionDueDiligenceList) {
                    if((trans.Status__c == EEC_Constants.DUE_COMPLETED || trans.Status__c  == EEC_Constants.DUE_NOT_APPLICABLE) && trans.Completion_Date__c == null) {
                        if(trans.Responsible_Party__c == EEC_Constants.TRANSACTION_DUE_DILIGENCE_ADMIN 
                                && (!userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_ADMIN) 
                                && !userRole.contains('Regional Director') 
                                && !userRole.contains('Executive and Directors')  
                                && profileName !='System Administrator')){
                            reloadPage = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only admins are allowed to complete the admin checklist items.'));
                            return null;
                        }
                        if(trans.Responsible_Party__c == EEC_Constants.TRANSACTION_DUE_DILIGENCE_LICENSOR 
                                && (!userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_LICENSOR) 
                                && !userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_SUPERVISOR) 
                                && !userRole.contains('Regional Director') 
                                && !userRole.contains('Executive and Directors') 
                                && profileName != 'System Administrator')){
                            if((trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Public_School' 
                                    || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Private_School'
                                    || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Other_Eligible_Provider' 
                                    || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Summer_Camp' 
                                    || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Informal_Child_Care')
                                    && !userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_EEC_MONITORS)) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only EEC Monitors are allowed to complete the Licensor checklist items.'));
                            } else if(trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Public_School' 
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Private_School'
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Other_Eligible_Provider' 
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Summer_Camp' 
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Informal_Child_Care') {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only Licensors are allowed to complete the Licensor checklist items.'));
                            }
                            return null;
                        }
                        if(trans.Responsible_Party__c == EEC_Constants.TRANSACTION_DUE_DILIGENCE_SUPERVISOR 
                                && (!userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_SUPERVISOR) 
                                && !userRole.contains('Regional Director') 
                                && !userRole.contains('Executive and Directors') 
                                && profileName !='System Administrator')){
                            reloadPage = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only Supervisors are allowed to complete the Supervisor checklist items.'));
                            return null;
                        }
                        if(trans.Responsible_Party__c == EEC_Constants.TRANSACTION_DUE_DILIGENCE_LICENSOR 
                                && trans.Unique_API_Name__c == requestSupervisorChecklistItem 
                                && (!userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_LICENSOR) 
                                && !userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_SUPERVISOR) 
                                && !userRole.contains('Regional Director') && !userRole.contains('Executive and Directors') 
                                && profileName !='System Administrator')){
                            if((trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Public_School' 
                                || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Private_School'
                                || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Other_Eligible_Provider' 
                                || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Summer_Camp' 
                                || trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Informal_Child_Care')
                                && !userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_EEC_MONITORS)) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only EEC Monitors are allowed to complete the Request For Supervisor Approval checklist items.'));
                            }  else if(trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Public_School' 
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Private_School'
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Other_Eligible_Provider' 
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Summer_Camp' 
                                    && trans.Licensing_Transaction__r.providerRecordTypeDeveloperName__c != 'Informal_Child_Care') {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only Licensors are allowed to complete the Request For Supervisor Approval checklist items.'));
                            }
                            return null;
                        }
                        if(trans.Responsible_Party__c == EEC_Constants.TRANSACTION_DUE_DILIGENCE_BRCSTAFF 
                                && (!userRole.contains(EEC_Constants.TRANSACTION_DUE_DILIGENCE_BRCSTAFF) 
                                && !userRole.contains('Executive and Directors') 
                                && profileName !='System Administrator')){
                            reloadPage = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only BRC Staff is allowed to complete the BRC Staff checklist items.'));
                            return null;
                        } 
                    }
                    if(trans.Status__c == EEC_Constants.DUE_PENDING || String.isBlank(trans.Status__c)) {
                        isPendingChecklist = true;
                    } 
                    if(trans.Status__c == EEC_Constants.DUE_NOT_APPLICABLE 
                            && trans.Completion_Date__c == null 
                            && trans.Unique_API_Name__c == requestSupervisorChecklistItem) {
                        if(conditionList.size() > 0){
                            reloadPage = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This transaction must go through supervisor approval.'));
                            return null;
                        }
                         if(LTRecordTypeDeveloperName == EEC_Constants.LT_FCC_RENEWAL
                            && licensingTransaction.Capacity__c > (String.isBlank(licensingTransaction.Current_Provider_Capacity__c) ? 0 : Integer.valueOf(licensingTransaction.Current_Provider_Capacity__c))) {
                            reloadPage = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This transaction must go through supervisor approval.'));
                            return null;
                        }
                        isRequestSupervisorNA = true;
                    }
                    if(trans.Unique_API_Name__c == superVisorChecklistItem && isRequestSupervisorNA) {
                        trans.Status__c = EEC_Constants.DUE_NOT_APPLICABLE;
                    }
                    if( (trans.Status__c == EEC_Constants.DUE_COMPLETED ||  trans.Status__c == EEC_Constants.DUE_NOT_APPLICABLE) && trans.Completion_Date__c == null) {
                        if(trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c != EEC_Constants.LT_Contact_Management 
                                && trans.Unique_API_Name__c == EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY &&
                            licenseTransactionContactMap.containsKey(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase())){
                            reloadPage = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, licenseTransactionContactMap.get(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase())));
                            return null;
                        }
                        if(trans.Status__c == EEC_Constants.DUE_COMPLETED  && trans.Completion_Date__c == null) {
                            if(trans.Unique_API_Name__c == EEC_DueDiligenceHepler.reviewCoriResult 
                                    && licenseTransactionContactMap.containsKey(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewCoriResult.toLowerCase())){
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, licenseTransactionContactMap.get(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewCoriResult.toLowerCase())));
                                return null;
                            }
                            if(trans.Unique_API_Name__c == EEC_DueDiligenceHepler.reviewDcfResult 
                                    && licenseTransactionContactMap.containsKey(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewDcfResult.toLowerCase())){
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, licenseTransactionContactMap.get(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewDcfResult.toLowerCase())));
                                return null;
                            }
                            if(trans.Unique_API_Name__c == EEC_DueDiligenceHepler.reviewSoriResult 
                                    && licenseTransactionContactMap.containsKey(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewSoriResult.toLowerCase())){
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, licenseTransactionContactMap.get(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewSoriResult.toLowerCase())));
                                return null;
                            }
                            if(trans.Unique_API_Name__c == EEC_DueDiligenceHepler.FingerprintingSuitabilityDetermination 
                                    && licenseTransactionContactMap.containsKey(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.FingerprintingSuitabilityDetermination.toLowerCase())){
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, licenseTransactionContactMap.get(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.FingerprintingSuitabilityDetermination.toLowerCase())));
                                return null;
                            }
                            if(trans.Unique_API_Name__c == EEC_DueDiligenceHepler.assistantFingerprints 
                                    && licenseTransactionContactMap.containsKey(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.assistantFingerprints.toLowerCase())){
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, licenseTransactionContactMap.get(trans.Licensing_Transaction__c + EEC_DueDiligenceHepler.assistantFingerprints.toLowerCase())));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == requestSupervisorChecklistItem && isPendingChecklist) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please complete all pending checklist items before requesting for supervisor approval.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == requestSupervisorChecklistItem && (managerid == null || managerid == '')) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not allowed to submit for approval until a supervisor is assigned to your user.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == reviewDocumnetCheklistItem) {
                                if (checkforApprovedDoc(trans.Licensing_Transaction__c)) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review all uploaded documents prior to completing this checklist item.'));
                                    return null;
                                }
                            }
                            // for Icc
                           /* if (trans.Unique_API_Name__c == reviewedCPRCertificationItem) {
                                if (checkforApprovedDoc(trans.Licensing_Transaction__c)) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Reviewed CPR Certification uploaded  documents prior to completing this checklist item.'));
                                    return null;
                                }
                            }
                            if (trans.Unique_API_Name__c == reviewedFirstAidCertificationItem) {
                                if (checkforApprovedDoc(trans.Licensing_Transaction__c)) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Reviewed First Aid Certification uploaded documents prior to completing this checklist item.'));
                                    return null;
                                }
                            }
                            if (trans.Unique_API_Name__c == reviewedParentalConsentFormItem) {
                                if (checkforApprovedDoc(trans.Licensing_Transaction__c)) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Reviewed Parental Consent Form uploaded prior to completing this checklist item.'));
                                    return null;
                                }
                            }
                            if (trans.Unique_API_Name__c == reviewedCPRCertificationItem) {
                                if (checkforApprovedDoc(trans.Licensing_Transaction__c)) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review uploaded Reviewed CPR Certification documents prior to completing this checklist item.'));
                                    return null;
                                }
                            } */
                            // End
                            if (trans.Unique_API_Name__c == varianceChecklistItem) {
                                if (checkforVarianceMissingRecomdtn(trans.Licensing_Transaction__c)) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review all variance requests and provide licensor decision prior to completing this checklist item.'));
                                    return null;
                                }
                            }
                            if (trans.Unique_API_Name__c == superVisorChecklistItem) {
                                if (checkforVarianceSupervisorApproval(trans.Licensing_Transaction__c) == true) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide variance final decision prior to completing this checklist item.'));
                                    return null;
                                }
                            }
                            if (trans.Unique_API_Name__c == feePaymentChecklistItem 
                                    && licensingTransaction.Associated_Fee__c != null 
                                    && licensingTransaction.Associated_Fee__c > 0) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review captured payment information prior to completing this checklist item.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == filledCapacityChecklistItem 
                                    && ((licensingTransaction.Capacity__c == null 
                                    && ProRecordTypeDeveloperName != EEC_Constants.PRO_FCC_ASSISTANT) 
                                    || (licensingTransaction.Certificate_Granted__c == null 
                                    && ProRecordTypeDeveloperName == EEC_Constants.PRO_FCC_ASSISTANT))) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review licensed capacity information prior to completing this checklist item.'));
                                return null;
                            }
                            //checking Regulatory Status field null
                            if (trans.Unique_API_Name__c == FilledRegulatoryStatusChecklistItem 
                                    && ((trans.Licensing_Transaction__r.Regulatory_Status__c == null 
                                    && (trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == 'EEC_FCC_Modification' ||
                                    trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_FCC_NEW_LICENSE 
                                    || trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_FCC_RENEWAL 
                                    || trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_FCC_INACTIVATE)))) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review Regulatory Status information prior to completing this checklist item.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == certifiedAssistantCapacity 
                                    && (licensingTransaction.Certificate_Granted__c == null 
                                    && ProRecordTypeDeveloperName == EEC_Constants.PRO_FCC_ASSISTANT)) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review Certificate Granted prior to completing this checklist item.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == filledFilledLicenseTypeChecklistItem && licensingTransaction.License_Type__c == null) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review license type prior to completing this checklist item.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == filledLicensedIssueDateExpirationDateChecklistItem 
                                    && licensingTransaction.License_Issue_Date__c == null 
                                    && licensingTransaction.License_Expiration_Date__c == null) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please review license dates prior to completing this checklist item.'));
                                return null;
                            }
                            if ((trans.Unique_API_Name__c == requestSupervisorApprovalChecklistItem) 
                                    && ((trans.Licensing_Transaction__r.Building_inspection_expiration_Date__c != null 
                                    && trans.Licensing_Transaction__r.Building_inspection_expiration_Date__c <= Date.TODAY()) 
                                    || (trans.Licensing_Transaction__r.Health_Inspection_Expiration_Date__c != null 
                                    && trans.Licensing_Transaction__r.Health_Inspection_Expiration_Date__c <= Date.TODAY())
                                    || (trans.Licensing_Transaction__r.Fire_Inspection_Issue_date__c != null 
                                    && trans.Licensing_Transaction__r.Fire_Inspection_Issue_date__c.addDays(365) <= Date.TODAY()) 
                                    || (trans.Licensing_Transaction__r.Integrated_Pest_Management_Date__c != null 
                                    && trans.Licensing_Transaction__r.Integrated_Pest_Management_Date__c.addDays(365) <= Date.TODAY()))
                                    && ((trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_LICENSE_CHANGE || trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_NEW_LICENSE || trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_RENEWAL || trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_MOVE || trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_TEMPORARY_MOVE))) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Make Sure that Inspection Date have not been expired.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == visitAssociation) {
                                checkforVisit(trans.Licensing_Transaction__c);
                                if (!isVisitPresent) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide visit details prior to completing this checklist item.'));
                                    return null;
                                } else if (!isVisitClosed && (LTRecordTypeDeveloperName == EEC_Constants.LT_FCC_NEW_LICENSE || LTRecordTypeDeveloperName == EEC_Constants.LT_FCC_RENEWAL
                                        || LTRecordTypeDeveloperName == EEC_Constants.LT_GSA_NEW_LICENSE || LTRecordTypeDeveloperName == EEC_Constants.LT_GSA_RENEWAL
                                        || LTRecordTypeDeveloperName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE || LTRecordTypeDeveloperName == EEC_Constants.LT_PLACEMENT_RENEWAL
                                        || LTRecordTypeDeveloperName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE || LTRecordTypeDeveloperName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                                        || LTRecordTypeDeveloperName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY)) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Visit should be closed prior to completing this checklist item.'));
                                    return null;
                                } else if (LTRecordTypeDeveloperName == EEC_Constants.LT_CHANGE_OF_ADDRESS && ProRecordTypeDeveloperName == EEC_Constants.PRO_FCC && !isVisitCompleted) {
                                    reloadPage = false;
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Visit should be completed prior to completing this checklist item.'));
                                    return null;
                                }
                            }
                            if (trans.Unique_API_Name__c == closeTransactionGenerateLicenseItem && isPendingChecklist) {
                                reloadPage = false;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have to complete all due diligence checklist items before proceeding forward.'));
                                return null;
                            }
                            if (trans.Unique_API_Name__c == closeTransactionGenerateLicenseItem 
                                    || trans.Unique_API_Name__c == EEC_DueDiligenceHepler.reclosedTransaction) {
                                Licensing_Transaction__c licenseTransaction = new Licensing_Transaction__c(Id = trans.Licensing_Transaction__c, Status__c = EEC_Constants.LT_CLOSED, Status_Reason__c = 'License Issued');
                                if(!LicenseTransationList.contains(licenseTransaction)) {
                                    LicenseTransationList.add(licenseTransaction);
                                }
                            }
                            transDueDiligenceListToUpdate.add(trans);
                        }
                        if(trans.Status__c == EEC_Constants.DUE_NOT_APPLICABLE 
                                && trans.Completion_Date__c == null){
                            transDueDiligenceListToUpdate.add(trans);
                        }
                    }
                    if((trans.Status__c == EEC_Constants.DUE_PENDING || trans.Status__c == null)
                            && trans.Completion_Date__c != null){
                        transDueDiligenceListToUpdate.add(trans);
                    }
                    if(trans.Licensing_Transaction__r.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_Contact_Management 
                            && (trans.Status__c == EEC_Constants.DUE_COMPLETED 
                            || trans.Status__c == EEC_Constants.DUE_NOT_APPLICABLE) 
                            && licenseTransactionContactMap.containsKey(trans.Licensing_Transaction__c + trans.Responsible_Party__c + trans.Unique_API_Name__c.toLowerCase())) {
                        reloadPage = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, licenseTransactionContactMap.get(trans.Licensing_Transaction__c + trans.Responsible_Party__c + trans.Unique_API_Name__c.toLowerCase())));
                        return null;
                    }
                }
                for(Transaction_Due_Diligence__c trans: transDueDiligenceListToUpdate){
                    if((trans.Status__c == EEC_Constants.DUE_COMPLETED 
                            || trans.Status__c == EEC_Constants.DUE_NOT_APPLICABLE) 
                            && trans.Completion_Date__c == null){
                        trans.Completion_Date__c = DateTime.now();
                    }if((trans.Status__c == EEC_Constants.DUE_PENDING || trans.Status__c == null) && trans.Completion_Date__c != null){
                        trans.Status__c = EEC_Constants.DUE_PENDING;
                        trans.Completion_Date__c = null;
                    }
                }
              if(transDueDiligenceListToUpdate.size() > 0){
                    update transDueDiligenceListToUpdate;
                }
                if(LicenseTransationList.size() > 0) {
                    update LicenseTransationList;
                }
            }
            isEditMode = false;
       // }catch(Exception e){
        //    reloadPage = false;
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage()));
        //}
        return null;    
    }
    
    public boolean checkforApprovedDoc(string licTransID){
        for(Transaction_Document__c transDoc : [SELECT Id,Name,Status__c,Licensing_Transaction__c,Document__r.Not_Applicable__c
                                                    FROM Transaction_Document__c 
                                                    WHERE Licensing_Transaction__c =: licTransID ]){
            if(transDoc.Status__c != EEC_Constants.TRANSACTION_DOCUMENT_STATUS_REVIEWED && transDoc.Document__r.Not_Applicable__c == false){
                isPendingDoc = true;
                break;  
            }
        }
        return isPendingDoc;
    } 
    public boolean checkforVarianceMissingRecomdtn(string licTransID){
        for(Variance_on_Regulation__c varRec : [SELECT Id,Name,Decision__c,Licensor_Recommendation__c,Source_Transaction__c 
                                                    FROM Variance_on_Regulation__c 
                                                    WHERE Source_Transaction__c =: licTransID]){
            if(string.isBlank(varRec.Licensor_Recommendation__c)){
                isMissinglicensorRecommendation = true;
                break;  
            }
        }
        return isMissinglicensorRecommendation;
    }
    public boolean checkforVarianceSupervisorApproval(string licTransID){
        for(Variance_on_Regulation__c varRec : [SELECT Id,Name,Supervisor_Recommendation__c,Decision__c
                                                    FROM Variance_on_Regulation__c 
                                                    WHERE Source_Transaction__c =: licTransID]){
            if( varRec.Decision__c == null){
                isPendingVariance = true;
                break;  
            }
        }
        return isPendingVariance;
    }
    public PageReference resetDDItems() {
        reloadPage = true;
        Licensing_Transaction__c transation;
        list<Transaction_Due_Diligence__c> ddTobeReset = new list<Transaction_Due_Diligence__c>();
        for(Transaction_Due_Diligence__c trans: [SELECT ID,Associated_Status__c,Associated_Status_Reason__c,Enable_Not_Applicable__c,Help_Text__c,
                                                        Checklist_Name__c,Licensing_Transaction__c,Responsible_Party__c,Status__c,Sequence__c,Unique_API_Name__c,
                                                        Completion_Date__c,LastModifiedBy.name,Automated__c,Video_Link__c, Licensing_Transaction__r.Status_Reason__c
                                                    FROM Transaction_Due_Diligence__c  
                                                    WHERE Sequence__c >=: selectedDDItemSequance
                                                    AND Automated__c = false
                                                    AND Status__c =: EEC_Constants.DUE_COMPLETED
                                                    AND Licensing_Transaction__c =: licensingTransaction.Id
                                                    ORDER BY Sequence__c]){
            trans.Status__c = EEC_Constants.DUE_PENDING;
            trans.Completion_Date__c = null;
            ddTobeReset.add(trans);      
            if(selectedDDItemSequance == trans.Sequence__c && trans.Licensing_Transaction__r.Status_Reason__c != trans.Associated_Status_Reason__c) {
                transation = new Licensing_Transaction__c(Id=trans.Licensing_Transaction__c, Status__c=trans.Associated_Status__c, Status_Reason__c=trans.Associated_Status_Reason__c);
            }
        }
        try {
            if(ddTobeReset.size() > 0 ) {
                update ddTobeReset;
            }
            if(transation != null) {
                update transation;
            }
        } catch(Exception e){
            reloadPage = false;
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        } 
        return null;
    }
    // ICC Checklist Items 
    /*public void checkDuediligenceCheckListItems(){
    Map<String, String> dueDiligenceCheckLIstItemsMap = new Map<String, String>{
        'Reviewed_CPR_Certification' => reviewedCPRCertificationItem,'Reviewed_Training_Information' => reviewedTrainingInformationItem,
        'Reviewed_Parental_Consent_Form' => reviewedParentalConsentFormItem,  
        'Reviewed_First_Aid_Certification' => reviewedFirstAidCertificationItem.toUpperCase()};    

    Map<String, string> transactionDocumentMap = new Map<String, String>();
    Map<String, String> transactionDocumentMapList = new Map<String, String>();
        
        for(Transaction_Document__c transObj : [SELECT Id,Name,Status__c,Licensing_Transaction__c,Document__r.Not_Applicable__c
                                                    FROM Transaction_Document__c WHERE Licensing_Transaction__c = :licensingTransaction.Id]){
            if(transactionDocumentMap.containsKey(transObj.Licensing_Transaction__c)) {  
                transactionDocumentMap.put(transObj.Name,transObj.Transaction_Document_Name__c);
                System.debug('transactionDocumentMap------>'+transactionDocumentMap);
            }
       } 
    } */
    public boolean checkforVisit(string licTransID) {
       
        return isVisitPresent;
    }
    public void checkBRCLicenseFieldStatus(Boolean contactManagementLicensetransaction,Boolean isGSA) {
        licenseTransactionContactMap = new Map<String, String>();
        if(contactManagementLicensetransaction) {
            for (Transaction_Contact__c transactionContact : [Select Id,
                                                                    Licensing_Transaction__c,
                                                                    BRC_Role__c,
                                                                    FP_Scan_Date__c,
                                                                    Suitability_Date__c,
                                                                    Suitability__c,
                                                                    Licensing_Transaction__r.Provider__r.Is_GSA__c,
                                                                    Licensing_Transaction__r.Provider__r.Is_R_P__c
                                                                From Transaction_Contact__c
                                                                WHERE Licensing_Transaction__c =: licensingTransaction.Id
                                                                AND BRC_Consent_Status__c != null
                                                                AND Status__c =: EEC_Constants.TC_STATUS_ACTIVE
                                                                AND (BRC_Role__c =: EEC_Constants.TC_BRC_ROLE_LICENSEE 
                                                                OR BRC_Role__c =: EEC_Constants.TC_BRC_ROLE_PROGRAM_ADMINISTRATOR)
                                                                AND (FP_Scan_Date__c = null
                                                                OR Suitability__c =: EEC_Constants.TC_SUITABILITY_PENDING
                                                                OR Suitability__c =: EEC_Constants.TC_SUITABILITY_NOT_SUITABLE
                                                                OR Suitability_Date__c = null
                                                                OR Suitability__c = null)
                                                                AND BRC_Required__c = true]) {
                if(transactionContact.BRC_Role__c == EEC_Constants.TC_BRC_ROLE_LICENSEE && 
                    !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_Constants.TRANSACTION_DUE_DILIGENCE_BRCSTAFF + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase())) {
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_Constants.TRANSACTION_DUE_DILIGENCE_BRCSTAFF + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase(), 'To complete this item all License FP Scan Date, Suitability Date (overall), Suitability should be completed.');
                }
                if(transactionContact.BRC_Role__c == EEC_Constants.TC_BRC_ROLE_PROGRAM_ADMINISTRATOR && 
                    !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_Constants.TRANSACTION_DUE_DILIGENCE_LICENSOR + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase())
                    && (transactionContact.Licensing_Transaction__r.Provider__r.Is_GSA__c || transactionContact.Licensing_Transaction__r.Provider__r.Is_R_P__c)) {
                    if(transactionContact.FP_Scan_Date__c == null && transactionContact.Suitability__c != null && transactionContact.Suitability_Date__c != null &&
                        transactionContact.Suitability__c != EEC_Constants.TC_SUITABILITY_PENDING && transactionContact.Suitability__c != EEC_Constants.TC_SUITABILITY_NOT_SUITABLE){
                        continue;
                    }
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_Constants.TRANSACTION_DUE_DILIGENCE_LICENSOR + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase(), 'To complete this item all Program Administrator FP Scan Date, Suitability Date (overall), Suitability should be completed.');
                }
            }
        }else if(isGSA){
            Set<String> approveResultSet = new Set<String>{'Not Suitable'};
            for (Transaction_Contact__c transactionContact : [Select Id,
                    Licensing_Transaction__c,Suitability__c,
                    BRC_Role__c,
                    Fingerprinting_Results__c,
                    Role__c,
                    Licensing_Transaction__r.providerRecordTypeDeveloperName__c,
                    Status__c,
                    Licensing_Transaction__r.Provider__r.Is_GSA__c,
                    Licensing_Transaction__r.Provider__r.Is_R_P__c
            FROM Transaction_Contact__c
            WHERE Licensing_Transaction__c =: licensingTransaction.Id
            AND BRC_Consent_Status__c != null
            AND Status__c = :EEC_Constants.TC_STATUS_ACTIVE
            AND BRC_Required__c = true]) {
                if(transactionContact.Suitability__c != 'Suitable'
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase())){
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase(), 'You can not complete this checklist item because licensee is not suitable');
                }
                if((String.isBlank(transactionContact.Suitability__c))
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase())){
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.REVIEW_BRC_RESULT_SUITABILITY.toLowerCase(), 'You must fill out the suitability result for the all applicable licensee.');
                }
            }
        } else {
            Set<String> approveResultSet = new Set<String>{'Approved after discretionary review','Approved','Suitable','Fingerprinting Not Required'};
            for (Transaction_Contact__c transactionContact : [Select Id,
                                                                Licensing_Transaction__c,
                                                                CORI_Result__c,
                                                                DCF_Result__c,
                                                                SORI_Result__c,
                                                                BRC_Role__c,
                                                                Fingerprinting_Results__c,
                                                                Role__c,
                                                                Licensing_Transaction__r.providerRecordTypeDeveloperName__c,
                                                                Status__c,
                                                                Licensing_Transaction__r.Provider__r.Is_GSA__c,
                                                                Licensing_Transaction__r.Provider__r.Is_R_P__c
                                                            FROM Transaction_Contact__c
                                                            WHERE Licensing_Transaction__c =: licensingTransaction.Id
                                                            AND BRC_Consent_Status__c != null
                                                            AND Status__c = :EEC_Constants.TC_STATUS_ACTIVE
                                                            AND BRC_Required__c = true]) {
                if((String.isBlank(transactionContact.CORI_Result__c) 
                        || !approveResultSet.contains(transactionContact.CORI_Result__c))
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewCoriResult.toLowerCase())){
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewCoriResult.toLowerCase(), 'To complete this item all BRC contacts result should be either "Approved after Discretionary review" or "Approved".');
                }
                if((String.isBlank(transactionContact.DCF_Result__c) 
                        || !approveResultSet.contains(transactionContact.DCF_Result__c))
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewDcfResult.toLowerCase())){
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewDcfResult.toLowerCase(), 'To complete this item all BRC contacts result should be either "Approved after Discretionary review" or "Approved".');
                }
                if((String.isBlank(transactionContact.SORI_Result__c) 
                        || !approveResultSet.contains(transactionContact.SORI_Result__c))
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewSoriResult.toLowerCase())){
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.reviewSoriResult.toLowerCase(), 'To complete this item all BRC contacts result should be either "Approved after Discretionary review" or "Approved".');
                }
                if(String.isBlank(transactionContact.Fingerprinting_Results__c) 
                        && (transactionContact.Licensing_Transaction__r.Provider__r.Is_GSA__c 
                        || transactionContact.Licensing_Transaction__r.Provider__r.Is_R_P__c)
                        && transactionContact.BRC_Role__c == 'Licensee'
                        && !approveResultSet.contains(transactionContact.Fingerprinting_Results__c)
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.FingerprintingSuitabilityDetermination.toLowerCase())) {
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.FingerprintingSuitabilityDetermination.toLowerCase(), 'To complete this fingerprinting item all fingerprinting results should be Suitable.');
                }
               /* if(String.isBlank(transactionContact.Fingerprinting_Results__c)
                        && (transactionContact.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'FCC'
                        || transactionContact.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Private_School'
                        || transactionContact.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Other_Eligible_Provider'
                        || transactionContact.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Public_School'
                        || transactionContact.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Summer_Camp'
                        || transactionContact.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'Informal_Child_Care' )
                        && transactionContact.Role__c == 'Licensee'
                        && !approveResultSet.contains(transactionContact.Fingerprinting_Results__c)
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.FingerprintingSuitabilityDetermination.toLowerCase())) {
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.FingerprintingSuitabilityDetermination.toLowerCase(), 'To complete this fingerprinting item all fingerprinting results should be Suitable.');
                } */
                if(String.isBlank(transactionContact.Fingerprinting_Results__c) 
                        && transactionContact.Licensing_Transaction__r.providerRecordTypeDeveloperName__c == 'FCC_Assistant' 
                        && transactionContact.Role__c == 'Assistant'
                        && !approveResultSet.contains(transactionContact.Fingerprinting_Results__c)
                        && !licenseTransactionContactMap.containsKey(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.assistantFingerprints.toLowerCase())) {
                    licenseTransactionContactMap.put(transactionContact.Licensing_Transaction__c + EEC_DueDiligenceHepler.assistantFingerprints.toLowerCase(), 'To complete this fingerprinting item all fingerprinting results should be Suitable.');
                }
            }
        }
    }
}