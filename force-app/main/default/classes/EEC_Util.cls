/**
* EEC_Util
*
* This class is a place meant for all generic functions that will be shared accross the application.
* @author Darkis
* @testClass EEC_TestUtil
*/
public class EEC_Util {

    private static final Blob cryptoKey = Blob.valueOf('HZxE4kqHZg5RQbQA');
    public static Map<String, PageReference> lastStepMapForOnePageApplication = new Map<String, PageReference>{
            'Instructions' => Page.EEC_TransactionInstructions,
            'Review & Submission' => Page.EEC_ReviewSummarySubmission
    };

    public static Map<String, PageReference> lastStepMap = new Map<String, PageReference>{
            'Daily Routine and Activities' => Page.EEC_TechnicalAssistance,
            'Instructions' => Page.EEC_TransactionInstructions,
            'Transaction / Provider Information' => Page.EEC_TransactionProvider,
            'Residential Program Details' => Page.EEC_TransactionProvider,
            'Placement Agency Additional Information' => Page.EEC_TransactionProvider,
            'Corporation and Administrator Info' => Page.EEC_TransactionProvider,
            'Household Members' => Page.EEC_HouseHoldMembers,
            'Licensing Status and Capacity' => Page.EEC_LicenseStatusCapacityInfo,
            'Assistant Information' => Page.EEC_Transaction_AssistantInfo,
            'EEC Involvement Experience & Professional Exp.' => Page.EEC_InvolvementExperience,
            'Involvement / Professional Experience' => Page.EEC_InvolvementExperience,
            'Background Information' => Page.EEC_BackgroundInformation,
            'Training Information' => Page.EEC_TrainingInformation,
            'Indoor / Outdoor space information' => Page.EEC_IndoorSpacePage,
            'Daily Routine Activities / Technical Assistance' => Page.EEC_TechnicalAssistance,
            'Attachments' => Page.EEC_LicensingAttachment,
            'Review Summary and Submission' => Page.EEC_ReviewSummarySubmission,
            'Review & Submission' => Page.EEC_ReviewSummarySubmission,
            'Daily Routine & Activities' => Page.EEC_Transaction_DailyRandA,
            'Assistant Review Summary and Submission' => Page.EEC_ReviewSummarySubmissionAssistant,
            'Designation of Admin Responsilibity' => Page.EEC_DesignationOfAdministrative,
            'Operation Details' => Page.EEC_OperationDetailInfo,
            'Capacity Information' => Page.eec_capacityinformation,
            'Capacity Info' => Page.EEC_TransactionProvider,
            'Licensee Information page' => Page.EEC_OwnershipAdministratorInfo,
            'Ownership and Administrator Info' => Page.EEC_OwnershipAdministratorInfo,
            'Ownership and Administrator information' => Page.EEC_OwnershipAdministratorInfo,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance,
            'Residential Program Details' => Page.EEC_TransactionProvider,
            'Placement Agency Additional Information' => Page.EEC_TransactionProvider,
            'Residential Program Detail' => Page.EEC_ResidentialProgramDetail,
            'Indoor / Outdoor space info' => Page.eec_indoorspacegsapage,
            'Placement Agency Additional Info' => Page.EEC_PlacementAgency,
            'Designation of Administrative Responsibility' => Page.EEC_designationofadministrative,
            'Corporation and Administrator Information' => Page.EEC_TransactionProvider,
            'Involvement / Professional Experience' => Page.EEC_AssistantInvolvementExperience
    };
    //FCC and FCC_Assistant map
    public static Map<String, PageReference> lastFCCStepMap = new Map<String, PageReference>{
            'Instructions' => Page.EEC_transactioninstructions,
            'Transaction / Provider Information' => Page.EEC_transactionprovider,
            'Individuals Regularly on Premise' => Page.EEC_householdmembers,
            'Licensing/Capacity Info' => Page.EEC_licensestatuscapacityinfo,
            'Licensing Status and Capacity' => Page.EEC_licensestatuscapacityinfo,
            'Involvement & Professional Experience' => Page.EEC_InvolvementExperience,
            'Involvement / Professional Experience' => Page.EEC_InvolvementExperience,
            'EEC Involvement Experience & Professional Exp.' => Page.EEC_InvolvementExperience,
            'Background Information' => Page.EEC_BackgroundInformation,
            'Training Information' => Page.EEC_TrainingInformation,
            'Indoor/Outdoor Space Info' => Page.eec_indoorspacepage,
            'Indoor / Outdoor space information' => Page.EEC_IndoorSpacePage,
            'Technical Assistance' => Page.EEC_TechnicalAssistance,
            'Attachments' => Page.EEC_licensingattachment,
            'Review Summary and Submission' => Page.EEC_ReviewSummarySubmission,
            'Review & Submission' => Page.EEC_ReviewSummarySubmission,
            'Daily Routine & Activities' => Page.EEC_Transaction_DailyRandA,
            'Daily Routine and Activities' => Page.EEC_Transaction_DailyRandA,
            'Daily Routing Activities / Technical Assistance' => Page.EEC_Transaction_DailyRandA,
            'Assistant Info' => Page.EEC_Transaction_AssistantInfo,
            'Assistant Information' => Page.EEC_Transaction_AssistantInfo,
            'Transaction/Provider Info' => Page.EEC_transactionprovider,
            'Instruction' => Page.EEC_transactioninstructions,
            'Daily Routine Activities / Technical Assistance' => Page.EEC_TechnicalAssistance,
            'Household Members' => Page.EEC_HouseHoldMembers,
            'License Status and Capacity' => Page.EEC_LicenseStatusCapacityInfo,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance
    };

    public static Map<String, PageReference> lastFCCAssitantStepMap = new Map<String, PageReference>{
            'Instructions' => Page.EEC_transactioninstructions,
            'Transaction / Provider Information' => Page.EEC_transactionprovider,
            'Transaction / Assistant Information' => Page.EEC_transactionprovider,
            'Individuals Regularly on Premise' => Page.EEC_householdmembers,
            'Licensing/Capacity Info' => Page.EEC_licensestatuscapacityinfo,
            'Licensing Status and Capacity' => Page.EEC_licensestatuscapacityinfo,
            'Involvement / Professional Experience' => Page.EEC_AssistantInvolvementExperience,
            'Background Information' => Page.EEC_BackgroundInformation,
            'Training Information' => Page.EEC_TrainingInformation,
            'Indoor/Outdoor Space Info' => Page.eec_indoorspacepage,
            'Indoor / Outdoor space information' => Page.EEC_IndoorSpacePage,
            'Technical Assistance' => Page.EEC_TechnicalAssistance,
            'Attachments' => Page.EEC_licensingattachment,
            'Review Summary and Submission' => Page.eec_reviewsummarysubmissionassistant,
            'Review & Submission' => Page.eec_reviewsummarysubmissionassistant,
            'Daily Routine & Activities' => Page.EEC_Transaction_DailyRandA,
            'Daily Routing Activities / Technical Assistance' => Page.EEC_Transaction_DailyRandA,
            'Daily Routine and Activities' => Page.EEC_Transaction_DailyRandA,
            'Assistant Info' => Page.EEC_Transaction_AssistantInfo,
            'Assistant Information' => Page.EEC_Transaction_AssistantInfo,
            'Transaction/Provider Info' => Page.EEC_transactionprovider,
            'Instruction' => Page.EEC_transactioninstructions,
            'Involvement / Professional Experience' => Page.EEC_AssistantInvolvementExperience,
            'Assistant Review Summary and Submission' => Page.EEC_ReviewSummarySubmissionAssistant,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance
    };

    //GSA  map
    public static Map<String, PageReference> lastGSAStepMap = new Map<String, PageReference>{
            'Instructions' => Page.EEC_transactioninstructions,
            'Transaction / Program Information' => Page.EEC_transactionprovider,
            'Transaction / Provider Information' => Page.EEC_transactionprovider,
            'Ownership and Administrator information' => Page.EEC_ownershipadministratorinfo,
            'Ownership and Administrator Info' => Page.EEC_ownershipadministratorinfo,
            'Corporation and Administrator Information' => Page.EEC_ownershipadministratorinfo,
            'Designation of Administrative Responsibility' => Page.EEC_designationofadministrative,
            'Licensee Contact Information' => Page.EEC_ownershipadministratorinfo,
            'Designation of Admin Responsilibity' => Page.EEC_DesignationOfAdministrative,
            'Capacity Information' => Page.EEC_capacityinformation,
            'Capacity Info' => Page.EEC_capacityinformation,
            'Operation details Information' => Page.EEC_operationdetailinfo,
            'Indoor/Outdoor Space Info' => Page.EEC_indoorspacegsapage,
            'Technical Assistance' => Page.eec_technicalassistance,
            'Attachments' => Page.EEC_licensingattachment,
            'Review Summary and Submission' => Page.EEC_gsareviewsummary,
            'Review & Submission' => Page.EEC_gsareviewsummary,
            'Transaction/Provider Info' => Page.EEC_transactionprovider,
            'Instruction' => Page.EEC_transactioninstructions,
            'Operation Details' => Page.EEC_OperationDetailInfo,
            'Indoor / Outdoor space information' => Page.EEC_indoorspacegsapage,
            'Indoor / Outdoor space info' => Page.EEC_indoorspacegsapage,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance,
            'Household Members' => Page.EEC_HouseHoldMembers//,
            //'Payment Information' => Page.EEC_SubmitPayment
    };
    //RP  map
    public static Map<String, PageReference> lastRPStepMap = new Map<String, PageReference>{
            'Instructions' => Page.EEC_transactioninstructions,
            'Transaction / Provider Information' => Page.EEC_transactionprovider,
            'Ownership and Administrator information' => Page.EEC_ownershipadministratorinfo,
            'Ownership and Administrator Info' => Page.EEC_ownershipadministratorinfo,
            'Residential Program Details' => Page.EEC_ResidentialProgramDetail,
            'Technical Assistance' => Page.EEC_TechnicalAssistance,
            'Attachments' => Page.EEC_licensingattachment,
            'Review Summary and Submission' => Page.EEC_rp_reviewsummary,
            'Review & Submission' => Page.EEC_rp_reviewsummary,
            'Placement Agency Additional info' => Page.EEC_PlacementAgency,
            'Placement Agency Additional Info' => Page.EEC_PlacementAgency,
            'Transaction/Provider Info' => Page.EEC_transactionprovider,
            'Instruction' => Page.EEC_transactioninstructions,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance,
            'Corporation and Administrator Info' => Page.EEC_TransactionProvider,
            'Indoor / Outdoor space information' => Page.EEC_indoorspacegsapage
    };

    public Static Map<String, String> recordTypeMap = new Map<String, String>{
            'Apply for a New License' => 'FCC_New_License',
            'Apply for License Renewal' => 'FCC_Renewal',
            'Apply for an License Upgrade' => 'FCC_License_Upgrade',
            'Apply for a Change of Address' => 'Change_of_Address',
            'Notify Change of Room usage' => 'FCC_Change_Room_Floor_Level',
            'Notify Change in Household / Individuals Regularly on the Premises' => 'FCC_Change_of_Household',
            'Request Re-issuance of License Certificate' => 'Re_issuance_of_License_Cert',
            'Re-Activate License' => 'FCC_Re_Active',
            'De-Activate License' => 'FCC_Inactivate',
            'Close Prior Expiration' => 'Close_Prior_Expiration'
    };

    public Static Map<String, String> assistantRecordTypeMap = new Map<String, String>{
            'Apply for an License Upgrade' => 'FCC_Assistant_License_Upgrade',
            'Apply for a New License' => 'FCC_Assistant_New_License',
            'Apply for Renewal' => 'FCC_Assistant_Renewal',
            'Request Re-issuance of License Certificate' => 'Re_issuance_of_License_Cert',
            'Re-Activate License' => 'FCC_Re_Active',
            'De-Activate License' => 'FCC_Inactivate'
    };
    //CBC  map
    public static Map<String, PageReference> lastCBCStepMap = new Map<String, PageReference>{
            'Instructions' => Page.EEC_transactioninstructions,
            'Transaction / Program Information' => Page.EEC_transactionprovider,
            'Transaction / Provider Information' => Page.EEC_transactionprovider,
            'Ownership and Administrator information' => Page.EEC_ownershipadministratorinfo,
            'Ownership and Administrator Info' => Page.EEC_ownershipadministratorinfo,
            'Corporation and Administrator Information' => Page.EEC_ownershipadministratorinfo,
            'Designation of Administrative Responsibility' => Page.EEC_designationofadministrative,
            'Designation of Admin Responsilibity' => Page.EEC_DesignationOfAdministrative,
            'Capacity Information' => Page.EEC_capacityinformation,
            'Capacity Info' => Page.EEC_capacityinformation,
            'Operation details Information' => Page.EEC_operationdetailinfo,
            'Indoor/Outdoor Space Info' => Page.EEC_indoorspacegsapage,
            'Technical Assistance' => Page.eec_technicalassistance,
            'Attachments' => Page.EEC_licensingattachment,
            'Review Summary and Submission' => Page.EEC_CBCReviewSummary,
            'Review & Submission' => Page.EEC_CBCReviewSummary,
            'Transaction/Provider Info' => Page.EEC_transactionprovider,
            'Instruction' => Page.EEC_transactioninstructions,
            'Operation Details' => Page.EEC_OperationDetailInfo,
            'Indoor / Outdoor space information' => Page.EEC_indoorspacegsapage,
            'Indoor / Outdoor space info' => Page.EEC_indoorspacegsapage,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance,
            'Household Members' => Page.EEC_HouseHoldMembers
    };

    public static Map<String, PageReference> lastSummerCampStepMap = new Map<String, PageReference>{
            'Instructions' => Page.EEC_transactioninstructions,
            'Transaction / Program Information' => Page.EEC_transactionprovider,
            'Transaction / Provider Information' => Page.EEC_transactionprovider,
            'Ownership and Administrator information' => Page.EEC_ownershipadministratorinfo,
            'Ownership and Administrator Info' => Page.EEC_ownershipadministratorinfo,
            'Corporation and Administrator Information' => Page.EEC_ownershipadministratorinfo,
            'Designation of Administrative Responsibility' => Page.EEC_designationofadministrative,
            'Designation of Admin Responsilibity' => Page.EEC_DesignationOfAdministrative,
            'Capacity Information' => Page.EEC_capacityinformation,
            'Capacity Info' => Page.EEC_capacityinformation,
            'Operation details Information' => Page.EEC_operationdetailinfo,
            'Indoor/Outdoor Space Info' => Page.EEC_indoorspacegsapage,
            'Technical Assistance' => Page.eec_technicalassistance,
            'Attachments' => Page.EEC_licensingattachment,
            'Review Summary and Submission' => Page.EEC_SMReviewSummary,
            'Review & Submission' => Page.EEC_SMReviewSummary,
            'Transaction/Provider Info' => Page.EEC_transactionprovider,
            'Instruction' => Page.EEC_transactioninstructions,
            'Operation Details' => Page.EEC_OperationDetailInfo,
            'Indoor / Outdoor space information' => Page.EEC_indoorspacegsapage,
            'Indoor / Outdoor space info' => Page.EEC_indoorspacegsapage,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance,
            'Household Members' => Page.EEC_HouseHoldMembers
    };

    public static Map<String, PageReference> lastInformalCareStepMap = new Map<String, PageReference>{
            'Instructions' => Page.EEC_transactioninstructions,
            'Transaction / Provider Information' => Page.EEC_transactionprovider,
            'Individuals Regularly on Premise' => Page.EEC_householdmembers,
            'Licensing/Capacity Info' => Page.EEC_licensestatuscapacityinfo,
            'Licensing Status and Capacity' => Page.EEC_licensestatuscapacityinfo,
            'Information About Location of Care' => Page.EEC_licensestatuscapacityinfo,
            'Involvement & Professional Experience' => Page.EEC_InvolvementExperience,
            'Involvement / Professional Experience' => Page.EEC_InvolvementExperience,
            'EEC Involvement Experience & Professional Exp.' => Page.EEC_InvolvementExperience,
            'Background Information' => Page.EEC_BackgroundInformation,
            'Training Information' => Page.EEC_TrainingInformation,
            'Indoor/Outdoor Space Info' => Page.eec_indoorspacepage,
            'Indoor / Outdoor space information' => Page.EEC_IndoorSpacePage,
            'Technical Assistance' => Page.EEC_TechnicalAssistance,
            'Attachments' => Page.EEC_licensingattachment,
            'Review Summary and Submission' => Page.EEC_ICCReviewSummary,
            'Review & Submission' => Page.EEC_ICCReviewSummary,
            'Daily Routine & Activities' => Page.EEC_Transaction_DailyRandA,
            'Daily Routine and Activities' => Page.EEC_Transaction_DailyRandA,
            'Assistant Info' => Page.EEC_Transaction_AssistantInfo,
            'Assistant Information' => Page.EEC_Transaction_AssistantInfo,
            'Transaction/Provider Info' => Page.EEC_transactionprovider,
            'Instruction' => Page.EEC_transactioninstructions,
            'Daily Routine Activities / Technical Assistance' => Page.EEC_TechnicalAssistance,
            'Household Members' => Page.EEC_HouseHoldMembers,
            'License Status and Capacity' => Page.EEC_LicenseStatusCapacityInfo,
            'Variance Details' => Page.EEC_TechnicalAssistance,
            'Techincal Assistance' => Page.EEC_TechnicalAssistance
    };


    public static String encryptGetParam(String param) {
        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', EEC_Util.cryptoKey, Blob.valueOf(param))), 'UTF-8');
    }

    public static String decryptGetParam(String param) {
        Blob paramBlob = EncodingUtil.base64Decode(param);
        return Crypto.decryptWithManagedIV('AES128', EEC_Util.cryptoKey, paramBlob).toString();
    }

    /**
    * addMemberIDPageParameter
    *
    * @description This function will encrypt an account Id if necessary and attach it to the given PageReference.
    * @author Darkis
    * @created 26 Jan 2016
    * @param accountId The account ID that may need to be encrytped.
    * @param pPage PageReference The desired destination.
    * @param encrypt Boolean A flag to tell the function to encrypt the param or not.
    * @return PageReference
    */
    public static PageReference addMemberIDPageParameter(String accountId, PageReference pPage, Boolean encrypt) {
        if (String.isNotBlank(accountId)) {
            pPage.getParameters().put('member', (encrypt ? EEC_Util.encryptGetParam(accountId) : accountId));
        }
        return pPage;
    }
    /**
    * Change the lookup for city into select option
    * @author Bemnet
    *
    */

    public static EEC_PaginatedSelectList allCityList() {
        EEC_PaginatedSelectList allCityList = new EEC_PaginatedSelectList();
        for (City__c c : [select id, Name, State__c from City__c where isdeleted = false order by Name]) {
            allCityList.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
        }
        return allCityList;
    }
    public static EEC_PaginatedSelectList maCityList() {
        EEC_PaginatedSelectList maCityList = new EEC_PaginatedSelectList();
        for (City__c c : [select id, Name, State__c from City__c where State__c = 'MA' AND isdeleted = false order by Name]) {
            maCityList.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
        }
        return maCityList;
    }


    /*
    * Method Name: createActivityHistory
    * Description: Method to create activity history
    * @param: None
    * @return: void
    */
    public static void createActivityHistory(String emailBody, String emailSubject, String parentId, list<String> setOfEmailAddress) {
        String textBody;
        emailBody = emailBody.stripHtmlTags();
        // Creating Task for showing in Activity History Section
        Integer MAX_LENGTH_FOR_TASK_DESC = 32000;
        Task objTask = new Task();
        objTask.Subject = 'Email: ' + emailSubject;
        objTask.ActivityDate = Date.today();
        objTask.Status = 'Completed';
        objTask.Type = 'Email';

        objTask.Priority = 'Normal';
        objTask.Description = 'To: ' + setOfEmailAddress + '\n\nSubject: ' + emailSubject + '\nBody: \n';
        if (!Test.isRunningTest()) {
            //textBody = textBody.replace('<br>','');
            textBody = emailBody;
        } else {
            //textBody = '';
            textBody = emailBody;
        }
        objTask.Description += textBody;
        system.debug('--objTask Description: ' + objTask.Description);

        // Check For max-length of Description of Task
        objTask.Description = (objTask.Description.length() > MAX_LENGTH_FOR_TASK_DESC) ? objTask.Description.subString(0, MAX_LENGTH_FOR_TASK_DESC) : objTask.Description;

        //else if((existingProjectId != null && existingProjectId != '') && existingProjectDeliverabelid==null) {
        objTask.WhatId = parentId;

        /*String developerName;
        if(objectName == 'Lead') {
            objTask.WhoId = existingProjectId;
            developerName = 'Lead_Activity';
        } else {
            objTask.WhatId = existingProjectId;
            developerName = 'Opportunity_Activity';
        }*/

        system.debug(objTask);

        // Insert Task Record
        insert objTask;

        system.debug('TaskId ' + objTask.Id);


    }

    //Email notification when a Batch job processes
    public static void batchEmailSuccess(Database.BatchableContext apexJob, string apexJobName) {

        string messageBody;
        string messageSubject;
        messageSubject = 'Apex Batch Job ' + apexJobName + ' is Complete';
        AsyncApexJob a = [
                Select Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                from AsyncApexJob
                where Id = :apexJob.getJobId()
        ];

        messageBody = '<html><body><h2>The batch apex job ' + apexJobName + ' processed successfully.</h2><br/><br/>';
        messageBody = messageBody + 'Job Id:- ' + a.Id + '<br/>';
        messageBody = messageBody + 'No of Errors:- ' + a.NumberOfErrors + '<br/>';
        messageBody = messageBody + 'Job Items Processed:- ' + a.JobItemsProcessed + '<br/>';
        messageBody = messageBody + 'Total Job Items:- ' + a.TotalJobItems + '<br/></body></html>';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[]{
                a.CreatedBy.Email
        };


        if (toAddresses.size() > 0) {
            mail.setToAddresses(toAddresses);
        }
        mail.setSubject(messageSubject);
        mail.setHtmlBody(messageBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
    public static void batchEmailFailure(Database.BatchableContext apexJob, String apexJobName, string errorMessage) {

        String messageBody = '';
        String messageSubject = '';
        AsyncApexJob a = [
                Select Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                from AsyncApexJob
                where Id = :apexJob.getJobId()
        ];
        messageSubject = 'Apex Batch Job ' + apexJobName + ' failed';


        messageBody = '<html><body><h2>The batch apex job ' + apexJobName + ' failed. Here is the error message;</h2><br/><br/>';
        messageBody = messageBody + '\t' + errorMessage + '<br/>';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[]{
                a.CreatedBy.Email
        };


        if (toAddresses.size() > 0) {
            mail.setToAddresses(toAddresses);
        }
        mail.setSubject(messageSubject);
        mail.setHtmlBody(messageBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

    @InvocableMethod(label='Quick Exit' description='Doesn\'t do anything, just a short cut to exit a Process Flow')
    public static void QuickExit() {
    }

    /*
    * Method Name: getRecordType
    * Description: return a record type based on object name and record type developer name
    * @param: String sObjectName
    * @param: String recTypeDevName
    * @return: RecordType
    */
    public static RecordType getRecordType(String sObjectName, String recTypeDevName) {
        return [select Id,Name from RecordType where DeveloperName = :recTypeDevName and SobjectType = :sObjectName];
    }

    public static void resetAfterSubmissionContactChecklistItems(Id transactionId, Transaction_Contact__c transConRec) {
        List<Transaction_Due_Diligence__c> listToBeUpdate = new List<Transaction_Due_Diligence__c>();
        Set<String> brcChecklistItems = new Set<String>();
        brcChecklistItems.add(EEC_DueDiligenceHepler.brcInformationCheckList);
        brcChecklistItems.add(EEC_DueDiligenceHepler.reviewCoriResult);
        brcChecklistItems.add(EEC_DueDiligenceHepler.reviewSoriResult);
        brcChecklistItems.add(EEC_DueDiligenceHepler.reviewDcfResult);
        brcChecklistItems.add(EEC_DueDiligenceHepler.requestSupervisorApproval);
        brcChecklistItems.add(EEC_DueDiligenceHepler.supervisorApprovalCheckList);
        brcChecklistItems.add(EEC_DueDiligenceHepler.enterBRCInformationInBRCApp);
        brcChecklistItems.add(EEC_DueDiligenceHepler.reviewRFingureprintResult);
        List<Licensing_Transaction__c> licenseTransactionList = new List<Licensing_Transaction__c>();
        for (Transaction_Due_Diligence__c transaDueDilrec : [SELECT Id,Unique_API_Name__c,Licensing_Transaction__c,Completion_Date__c,Status__c,
                                                                Associated_Status__c, Associated_Status_Reason__c,Licensing_Transaction__r.Status__c,
                                                                Licensing_Transaction__r.Status_Reason__c
                                                            FROM Transaction_Due_Diligence__c
                                                            WHERE Licensing_Transaction__c = :transactionId
                                                            ORDER BY Sequence__c NULLS LAST
        ]) {
            if(transConRec.Status__c == 'Active' && brcChecklistItems.contains(transaDueDilrec.Unique_API_Name__c)){
                transaDueDilrec.Status__c = 'Pending';
                transaDueDilrec.Completion_Date__c = null;
                listToBeUpdate.add(transaDueDilrec);
            }
            if ( licenseTransactionList.isEmpty() && transConRec.Status__c == 'Active' && transaDueDilrec.Status__c != 'Completed'
                    &&(transaDueDilrec.Associated_Status__c != transaDueDilrec.Licensing_Transaction__r.Status__c 
                    || transaDueDilrec.Associated_Status_Reason__c != transaDueDilrec.Licensing_Transaction__r.Status_Reason__c)) {
                Licensing_Transaction__c licenseTransation = new Licensing_Transaction__c(id = transaDueDilrec.Licensing_Transaction__c);
                licenseTransation.Status_Reason__c = transaDueDilrec.Associated_Status_Reason__c;
                licenseTransation.Status__c = transaDueDilrec.Associated_Status__c;
                licenseTransactionList.add(licenseTransation);
            }
        }
        if (!listToBeUpdate.isEmpty()) {
            update listToBeUpdate;
        }
        if (!licenseTransactionList.isEmpty()) {
            update licenseTransactionList;
        }
    }

    // remove cookies bracket
    public static string removeCookiesBracket(String value) {

        // value = value.substring(0, value.length()-2);
        // value = value.substring(2);

        Boolean valueCheckfirst = value.contains('{{');
        Boolean valueCheckLast = value.contains('}}');
        if (valueCheckfirst) {
            value = value.substring(2);
        }
        if (valueCheckLast) {
            value = value.substring(0, value.length() - 2);
        }

        System.debug('String After Concat--->' + value);

        return value;
    }

    public static Licensing_Transaction__c removeScriptElements(Licensing_Transaction__c trans) {


        if (trans.Evening_Overnight_Weekend_Care_Desc__c != null) {
            trans.Evening_Overnight_Weekend_Care_Desc__c = removeCookiesBracket(trans.Evening_Overnight_Weekend_Care_Desc__c);
        }
        /*
         if(trans.Children_Home_Schooled_Description__c != null){
               trans.Children_Home_Schooled_Description__c  = removeCookiesBracket(trans.Children_Home_Schooled_Description__c);
           }
         if(trans.Approved_Foster_Care_Provider_Descrip__c != null){
         trans.Approved_Foster_Care_Provider_Descrip__c  = removeCookiesBracket(trans.Approved_Foster_Care_Provider_Descrip__c);
         }
         if(trans.Becoming_Foster_Care_Provider_Descrip__c != null){
         trans.Becoming_Foster_Care_Provider_Descrip__c  = removeCookiesBracket(trans.Becoming_Foster_Care_Provider_Descrip__c);
          }
         if(trans.Bus_Operated_Out_of_Own_Home_Descrip__c != null){
          trans.Bus_Operated_Out_of_Own_Home_Descrip__c = removeCookiesBracket(trans.Bus_Operated_Out_of_Own_Home_Descrip__c);
         }
         if(trans.Use_Family_Child_Care_System_Descrip__c != null){
         trans.Use_Family_Child_Care_System_Descrip__c  = removeCookiesBracket(trans.Use_Family_Child_Care_System_Descrip__c);
         } */
        return trans;
    }

    // remove cookies bracket
    /*  public static List<String> removeCookiesBracket(list<String> tranlist){

            // value = value.substring(0, value.length()-2);
            // value = value.substring(2);

            list<String> responseTranlist = new list<String>();

            for(String value : tranlist){
                Boolean valueCheckfirst = value.contains('{{');
                Boolean valueCheckLast = value.contains('}}');
                if(valueCheckfirst){
                    value=value.substring(2);
                }
                if(valueCheckLast){
                    value = value.substring(0, value.length()-2);
                }
                responseTranlist.add(value);
            }

    return responseTranlist;
    }  */
     
}