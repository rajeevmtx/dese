/*
* Class Name:  Case_Helper
* Description: Helper class dealing with Case records
* Author/Date:  Ajay Gautam ,  7/6/2016    
*                                                            
*/

public class Case_Helper {

  public static final String CASE_STATUS_SUBMITTED = 'Submitted';
  public static final String CASE_STATUS_UNSUBMITTED = 'Unsubmitted';
  public static final String CASE_STATUS_PENDING_APPROVAL = 'Pending Approval';
  public static final String CASE_STATUS_APPROVED = 'Approved';
  public static final String CASE_STATUS_REJECTED = 'Rejected';
  public static final String TEMPLATE_PAGE_DRAFT_STATUS = 'Draft';

  public static final Set<String> SET_CASE_STATUS_APPROVED_REJECTED = new Set<String>{CASE_STATUS_APPROVED, CASE_STATUS_REJECTED};

  public static final Set<String> SET_CASE_STATUS_FOR_REQ_MOD_BUTTON = new Set<String>{CASE_STATUS_SUBMITTED, CASE_STATUS_UNSUBMITTED};

  public static final String CASE_RECORD_TYPE_DEV_NAME_NY_SUN_RESIDENTIAL = 'NY_Sun_Residential';
  public static final String CASE_RECORD_TYPE_DEV_NAME_NY_SUN_COMMERCIAL = 'NY_Sun_Commercial';
  public static final String CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION = 'Solicitation_Change_Modification';

  public static final String DOCUMENTS_CASE_RECORD_TYPE_DEVELOPER_NAME = 'Documents';
  public static final String PROJECT_DOCUMENT_STATUS_APPROVE = 'Approve';

  public static final String PROJECT_DOCUEMNT_NOT_APPROVED_ERROR_MESSAGE_STRING
            = 'One or more of the required documents for this case are not approved. Please review and approve/reject the remaining documents.';

} //EOF