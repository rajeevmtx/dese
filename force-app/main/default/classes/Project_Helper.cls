/*
*   Class Name: Project_Helper
*   Description: Helper class dealing with Project__c records
*
*   Author/Date: 
*  
*                                                             
*/
public class Project_Helper
{

   
    public static final String PROJECT_APPLICATION_TYPE = 'Project Application';

    public static final String PROJECT_STATUS_FIELD_API_NAME = 'Status__c';
    public static final String PROJECT_PROJECT_NOTIFICATION_TYPE_HIDDEN_FIELD_API_NAME = 'Notifications_on_Approved_App_Hidden__c';
    public static final String PAYMENT_ASSIGNMENT_FIELD_API_NAME = 'Payment_Assignment__c';

    public static final String BUDGET_TYPE_MILESTONE = 'Milestone';
    public static final String BUDGET_TYPE_TnM = 'T&M';

    public static final String CONCEPT_PAPER_RESULT_PASS = 'Pass';
    public static final String CONCEPT_PAPER_RESULT_FAIL = 'Fail';
  public static final String PROJECT_RECOUPMENT_STATUS_CLOSED = 'Closed';
  public static final String PROJECT_RECOUPMENT_STATUS_OPEN = 'Open';

    public static final String RPU_STATUS_REVIEW_COMPLETED = 'Review Completed';
    public static final String PC_E_STATUS_REVIEW_COMPLETED = 'Review Completed';

    public static final String PROJECT_RECOMMANDATION_FUND_AWARD = 'Fund-Award';
    public static final String PROJECT_RECOMMANDATION_FUNDABLE = 'Fundable';
    public static final String PROJECT_RECOMMANDATION_DO_NOT_FUND = 'Do Not Fund';
    public static final String PROJECT_RECOMMANDATION_ACCEPTED = 'Accepted';
    public static final String PROJECT_RECOMMANDATION_NOT_ACCEPTED = 'Not Accepted';

    public static final String PROJECT_STATUS_UNSUBMITTED = 'Unsubmitted';
    public static final String PROJECT_STATUS_SUBMITTED = 'Submitted';
    public static final String PROJECT_STATUS_PENDINGAPPROVAL = 'Pending Approval';
    public static final String PROJECT_STATUS_APPROVED = 'Approved';
    public static final String PROJECT_STATUS_CLOSED = 'Closed';
    public static final String PROJECT_STATUS_RECEIVED = 'Received';
    public static final String PROJECT_STATUS_UNDER_REVIEW = 'Under Review';
    public static final String PROJECT_STATUS_PENDING_REVIEW = 'Pending Review';
    public static final String PROJECT_STATUS_AWARDED = 'Awarded';
    public static final String PROJECT_STATUS_TERMINATE = 'Terminate'; // Task - T-03208
    public static final String PROJECT_STATUS_NOT_AWARDED = 'Not Awarded';
    public static final String PROJECT_STATUS_COMPLETED = 'Completed';
    public static final String PROJECT_STATUS_RISK_OF_TERMINATION = 'Risk of Project Termination';
    public static final String PROJECT_DOCUMENT_STATUS_APPROVE = 'Approve';
    public static final String PROJECT_DOCUEMNT_NOT_APPROVED_ERROR_MESSAGE_STRING
            = 'One or more of the required documents for this project are not approved. Please review and approve/reject the remaining documents.';

    public static final String NOTIFICATION_TYPE_PROJECT_EXTENSION_APPROVED = 'Project Extension Approved';
    public static final String NOTIFICATION_TYPE_CESIR_EXTENSION_APPROVED = 'CESIR Extension Approved';


    public static final String NOTIFICATION_FINAL_DELIVERABLE_SUBMITTED_ON_PROPOSAL_OR_CONCEPT_PAPER = 'Final deliverable submitted on Proposal or Concept paper';
    public static final String NOTIFICATION_FINAL_DELIVERABLE_APPROVED_RPU_PCE_INCOMPLETE_ON_PROPOSAL_OR_CONCEPT_PAPER = 'Final deliverable approved but RPU or PC E incomplete';

    // S-00434
    public static final String PROJECT_NOTIFICATION_CHANGE_MOD_APPROVED_INCENTIVE_AMOUNT_UNCHANGED = 'Change Mod Approved - Incentive Amount Unchanged';
    public static final String PROJECT_NOTIFICATION_CHANGE_MOD_APPROVED_INCENTIVE_AMOUNT_INCREASE = 'Change Mod Approved - Incentive Amount Increase';
    public static final String PROJECT_NOTIFICATION_CHANGE_MOD_APPROVED_INCENTIVE_AMOUNT_DECREASE = 'Change Mod Approved - Incentive Amount Decrease';

    public static final String PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_RESI_APPROVED_INCENTIVE_AMOUNT_UNCHANGED = 'GJGNY Residential Change Mod Approved - Incentive Amount Unchanged';
    public static final String PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_RESI_APPROVED_INCENTIVE_AMOUNT_DECREASE = 'GJGNY Residential Change Mod Approved - Incentive Amount Decrease';

    public static final String PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_NON_RESI_APPROVED_INCENTIVE_AMOUNT_UNCHANGED = 'GJGNY Non-Residential Change Mod Approved - Incentive Amount Unchanged';
    public static final String PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_NON_RESI_APPROVED_INCENTIVE_AMOUNT_DECREASE = 'GJGNY Non-Residential Change Mod Approved - Incentive Amount Decrease';
	
	public static final String RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Residential';
    public static final String COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Commercial';
    
    public static final Set<String> SET_OF_PROJECT_RECORD_TYPE_DEV_NAME_WITH_RECEIVED_STATUS = new Set<String>{RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                           COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME};

    public static final Set<String> SET_OF_NYS_PROJECT_RECORD_TYPE_DEV_NAME_FOR_PO_SYNC = new Set<String>{
                                                            RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                            COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME};

    public static final Set<String> SET_OF_CHANGE_MOD_NOTIFICATION_TYPES = new Set<String>{PROJECT_NOTIFICATION_CHANGE_MOD_APPROVED_INCENTIVE_AMOUNT_UNCHANGED,
                                                                                           PROJECT_NOTIFICATION_CHANGE_MOD_APPROVED_INCENTIVE_AMOUNT_INCREASE,
                                                                                           PROJECT_NOTIFICATION_CHANGE_MOD_APPROVED_INCENTIVE_AMOUNT_DECREASE,
                                                                                           PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_RESI_APPROVED_INCENTIVE_AMOUNT_UNCHANGED,
                                                                                           PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_RESI_APPROVED_INCENTIVE_AMOUNT_DECREASE,
                                                                                           PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_NON_RESI_APPROVED_INCENTIVE_AMOUNT_UNCHANGED,
                                                                                           PROJECT_NOTIFICATION_CHANGE_MOD_GJGNY_NON_RESI_APPROVED_INCENTIVE_AMOUNT_DECREASE};
    // S-00434


    // rahuls91221: T-01059
    public static final String PROJECT_STATUS_CANCELLED = 'Cancelled';
    public static final String PROJECT_STATUS_REJECTED = 'Rejected';

    public static final String CONCEPT_RESULT_PASS = 'Pass'; // Project_Helper
    public static final String CONCEPT_RESULT_FAIL = 'Fail'; // Project_Helper

    public static final String PROJECT_RPU_READY_FOR_REVIEW_STATUS = 'Ready for Review';
}