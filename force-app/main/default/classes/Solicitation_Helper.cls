/*
*   Class Name: Solicitation_Helper
*   Description: Helper class for solicitation records
*
*
*/
public without sharing class Solicitation_Helper {

    public static final String SOLICITATION_TYPE_DUE_DATE = 'Due Date / Multi Round';
    public static final String SOLICITATION_TYPE_ROLLING = 'Rolling Solicitation';
    public static final String SOLICITATION_TYPE_OPEN_ENROLLMENT = 'Open Enrollment';
    public static final String SUM_OF_RANK_SCORE_TYPE = 'Sum of Rank';
    public static final String BATCH_RANK_SCORE_TYPE = 'Batch Rank';
    public static final String INVOICE_VOUCHER_TYPE = 'Voucher';
    public static final STRING RECORD_TYPE_CLEAN_TRANSPORTAION = 'Clean_Transportation';
    public static final STRING TYPE_OPEN = 'Open';
    public static final STRING TYPE_CLOSED = 'Closed';
    public static final STRING TYPE_DRAFT = 'Draft';
    
    public static final STRING MEASURE_CAPTURES_AT_SITE = 'Site'; 
    public static final STRING MEASURE_CAPTURES_AT_VEHICLE = 'Vehicle';
    public static final STRING MEASURE_CAPTURES_AT_COMMUNITY = 'Community';

    public static Integer CONST_ROUND_DUE_TIME_HH = ( CORE_Constants_Setting__c.getOrgDefaults().Solicitation_Round_Due_Date_Timing_HH__c != null ?
                                                      Integer.valueOf(CORE_Constants_Setting__c.getOrgDefaults().Solicitation_Round_Due_Date_Timing_HH__c) :
                                                      null
                                                    );

    public static final String GROUP_API_NAME_CORE_SOLICITATION_PAPER_SUBMISSION_GROUP = 'Core_Solicitation_Paper_Submission_Group'; // T-02655

    public static final String SOLICITATION_RECORDTYPE_DEVELOPERNAME = 'Clean_Transportation';

    public static final String GROUP_API_NAME_CONTRACT_OFFICE_MANAGER = 'Contract_Office_Manager';

    public static final String SOLICITATION_TO_CASE_MAPPING_METADATA_TYPE_API_NAME = 'CORE_Solicitation_to_Case_Mapping';

    public static final String SOLICITATION_TO_LOCKDOWN_FIELD_SET_API_NAME = 'Solicitation_Lockdown_fields';

    public static final Set<String> LOCKDOWN_SOLICITATION_TYPES = new Set<String>{SOLICITATION_TYPE_DUE_DATE,SOLICITATION_TYPE_ROLLING};
    public static final Set<String> LOCKDOWN_SOLICITATION_STATUS = new Set<String>{TYPE_OPEN,TYPE_CLOSED};
    public static final Set<String> SKIP_NAMING_SOLICITATION_TYPES = new Set<String>{SOLICITATION_TYPE_DUE_DATE,SOLICITATION_TYPE_ROLLING};

    // T-02464 - Change intermediary page listing based on logged in user account instead of createdby
    public static final Set<String> ROLES_TO_SET_ACCOUNT_BY_LOGIN_USER_DETAILS = new Set<String>{ ProjectRole_Helper.PROJECT_PROPOSER_ROLE,
                                                                                                  ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE
                                                                                                };
    // T-02464 - These roles will populate Account__c on the basis of logged in user's account
 

    public static final Set<String> SOLICITATION_MGMT_PENDING_REVIEW_AND_AFTER_STATUSES = new Set<String>{
                                                                                      Project_Helper.PROJECT_STATUS_PENDING_REVIEW,
                                                                                      Project_Helper.PROJECT_STATUS_UNDER_REVIEW,
                                                                                      Project_Helper.PROJECT_STATUS_AWARDED,
                                                                                      Project_Helper.PROJECT_STATUS_NOT_AWARDED,
                                                                                      Project_Helper.PROJECT_STATUS_COMPLETED,
                                                                                      Project_Helper.PROJECT_STATUS_CLOSED,
                                                                                      Project_Helper.PROJECT_STATUS_APPROVED,
                                                                                      Project_Helper.PROJECT_STATUS_REJECTED,
                                                                                      Project_Helper.PROJECT_STATUS_CANCELLED,
                                                                                      'Terminated',
                                                                                      'Non-Responsive',
                                                                                      'Ineligible'
                                                                                      };

    /*
    * Method Name: checkForExceptionalAccess
    * Description: Checking for exceptional access.
    *              T-02655 - Add exception for paper submission process
    * @param:  none
    * @return: Boolean
    */
    public static Boolean checkForExceptionalAccess() {
        Boolean bResultVal = false;
        Id loggedInUserId = UserInfo.getUserId();

        if(String.isNotBlank(Solicitation_Helper.GROUP_API_NAME_CORE_SOLICITATION_PAPER_SUBMISSION_GROUP)) {
          for(Group objGrp : [SELECT DeveloperName,
                                      (SELECT UserOrGroupId
                                       FROM   GroupMembers
                                       WHERE  UserOrGroupId = :loggedInUserId)
                              FROM    Group
                              WHERE   DeveloperName = :Solicitation_Helper.GROUP_API_NAME_CORE_SOLICITATION_PAPER_SUBMISSION_GROUP]) {

             if(objGrp.GroupMembers != null && objGrp.GroupMembers.size() > 0) {
               bResultVal = true;
               break;
             }
          }
        }

        return bResultVal;
    }


}