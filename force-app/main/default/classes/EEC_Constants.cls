/**
 * Created by Rahul Jangir on 5/13/2019.
 */

public with sharing class EEC_Constants {
    /* DO not change the record type Record_Type__c field */

    //License Transaction Record Type
    public static final String LT_FCC_NEW_LICENSE                                  =     'FCC_New_License';
    public static final String LT_FCC_ASSISTANT_LICENSE_UPGRADE                    =     'FCC_Assistant_License_Upgrade';
    public static final String LT_FCC_ASSISTANT_CHANGE_OF_ADDRESS                  =     'FCC_Assistant_Change_of_Address';
    public static final String LT_FCC_ASSISTANT_NEW_LICENSE                        =     'FCC_Assistant_New_License';
    public static final String LT_FCC_ASSISTANT_RENEWAL                            =     'FCC_Assistant_Renewal';
    public static final String LT_FCC_CHANGE_ROOM_FLOOR_LEVEL                      =     'FCC_Change_Room_Floor_Level';
    public static final String LT_FCC_CHANGE_OF_HOUSEHOLD                          =     'FCC_Change_of_Household';
    public static final String LT_FCC_CHANGE_OF_NAME                               =     'FCC_Change_of_Name';
    public static final String LT_FCC_DOWNGRADE_CAPACITY                           =     'FCC_Downgrade_Capacity';
    public static final String LT_FCC_INACTIVATE                                   =     'FCC_Inactivate';
    public static final String LT_FCC_LICENSE_UPGRADE                              =     'FCC_License_Upgrade';
    public static final String LT_FCC_PROVIDER_ASSISTANT_UPDATE                    =     'FCC_Provider_Assistant_Update';
    public static final String LT_FCC_RE_ACTIVE                                    =     'FCC_Re_Active';
    public static final String LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT     =     'FCC_Regular_Assistant_to_Certified_Assistant';
    public static final String LT_FCC_RENEWAL                                      =     'FCC_Renewal';
    public static final String LT_GSA_CHANGE_OF_ADMIN_AUTHORITY                    =     'GSA_Change_of_Admin_Authority';
    public static final String LT_GSA_LICENSE_CHANGE                               =     'GSA_License_Change';
    public static final String LT_GSA_MOVE                                         =     'GSA_Move';
    public static final String LT_GSA_NEW_LICENSE                                  =     'GSA_New_License';
    public static final String LT_GSA_RENEWAL                                      =     'GSA_Renewal';
    public static final String LT_GSA_TEMPORARY_MOVE                               =     'GSA_Temporary_Move';
    public static final String LT_PLACEMENT_CHANGE_IN_LICENSE                      =     'Placement_Change_in_License';
    public static final String LT_PLACEMENT_MOVE                                   =     'Placement_Move';
    public static final String LT_PLACEMENT_NEW_LICENSE                            =     'Placement_New_License';
    public static final String LT_PLACEMENT_RENEWAL                                =     'Placement_Renewal';
    public static final String LT_R_P_CHANGE_OF_ADMIN_AUTHORITY                    =     'R_P_Change_of_Admin_Authority';
    public static final String LT_RE_ISSUANCE_OF_LICENSE_CERT                      =     'Re_issuance_of_License_Cert';
    public static final String LT_RESIDENTIAL_CHANGE_IN_LICENSE                    =     'Residential_Change_in_License';
    public static final String LT_RESIDENTIAL_LICENSE_RENEWAL                      =     'Residential_License_Renewal';
    public static final String LT_RESIDENTIAL_MOVE                                 =     'Residential_Move';
    public static final String LT_RESIDENTIAL_NEW_LICENSE                          =     'Residential_New_License';
    public static final String LT_VARIAMCE_ON_REGULATION_REQUEST                   =     'Variance_On_Regulation_Request';
    public static final String LT_CONTACT_MANAGEMENT                               =     'Contact_Management';
    public static final String LT_EEC_FCC_MODIFICATION                             =     'EEC_FCC_Modification';
    public static final String LT_EEC_GSA_MODIFICATION                             =     'EEC_GSA_Modification';
    public static final String LT_EEC_RP_MODIFICATION                              =     'EEC_RP_Modification';
    public static final String LT_EEC_LICENSEE_MANAGEMENT_API_NAME                 =     'Licensee_Management';
    public static final String LT_BACKGROUND_RECORD_CHECK                          =     'Background_Record_Check';
    public static final String LT_CHANGE_OF_ADDRESS                                =     'Change_of_Address';
    public static final String LT_CHANGE_OF_PROVIDER_NAME                          =     'Change_of_Provider_Name';
    public static final String LT_CLOSE_PRIOR_EXPRIRATION                          =     'Close_Prior_Expiration';
    public static final String LT_SUMMER_CAMP_NEW_APPLICATION                      =     'Summer_Camp_New_Application';
    public static final String LT_CBC_NEW_LICENSE_APPLICATION                      =     'CBC_New_License_Application';
    public static final String LT_INFORMAL_CARE_NEW_APPLICATION                    =     'Informal_Care_New_Application';
    public static final String LT_CHILD_CARE_LICENSING_EXEMPTION                   =     'Child_Care_Licensing_Exemption';
    public static final String LT_PUBLIC_SCHOOL_NEW_APPLICATION                    =     'Public_School_New_Funding_Application';
    public static final String LT_PRIVATE_SCHOOL_NEW_APPLICATION                   =     'Private_School_New_Funding_Application';
    public static final String LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION         =     'Other_Eligible_Providers_New_Funding_Application';
    public static final String LT_LICENSEE_BRC_RENEWAL_NEW_APPLICATION             =     'Licensee_BRC_Renewal';
    public static final String LT_LEGACY_SYSTEM_TRANSACTION                        =     'Legacy_System_Transaction';
    public static final String LT_CLOSE_FUNDED_API_NAME                            =     'Close_Funded_Program';
	public static final String LT_CLOSE_INFORMAL_CHILD_CARE_API_NAME               =     'Closed_Informal_Child_Care_Program';

    //Provider Record Type Name
    public static final String PRO_ADOPTION_AGENCY                                 =     'Adoption_Agency';
    public static final String PRO_FCC_ASSISTANT                                   =     'FCC_Assistant';
    public static final String PRO_EXEMPT_CBC_CARE                                 =     'Exempt_CBC_Care';
    public static final String PRO_FCC                                             =     'FCC';
    public static final String PRO_FOSTER_CARE_AGENCY                              =     'Foster_Care_Agency';
    public static final String PRO_FUNDED_CARE                                     =     'Funded_Care';
    public static final String PRO_GROUP_CARE                                      =     'Group_Care';
    public static final String PRO_GROUP_AND_SCHOOL_AGE                            =     'Group_And_School_Age';
    public static final String PRO_INDEPENDENT_CHILD_CARE_NON_RELATIVE             =     'Independent_Child_Care_Non_Relative';
    public static final String PRO_INFORMAL_CHILD_CARE                             =     'Informal_Child_Care';
    public static final String PRO_LARGE_GROUP                                     =     'Large_Group';
    public static final String PRO_SMALL_GROUP                                     =     'Small_Group';
    public static final String PRO_SUMMER_CAMP                                     =     'Summer_Camp';
    public static final String PRO_TEMPORARY_SHELTER                               =     'Temporary_Shelter';
    public static final String PRO_UMBRELLA                                        =     'Umbrella';
    public static final String PRO_UNLICENSED_PROVIDER                             =     'Unlicensed_Provider';
    public static final String PRO_PRIVATE_SCHOOL                                  =     'Private_School';
    public static final String PRO_PUBLIC_SCHOOL                                   =     'Public_School';
    public static final String PRO_OTHER_ELIGIBLE_PROVIDER                         =     'Other_Eligible_Provider';


//Account
    public static final String PRO_ARE_YOU_SWITHCHING_SMALL_LARGE                 =     'Yes';
    public static final String PRO_ARE_YOU_SWITHCHING_LARGE_SMALL                 =     'Yes';

    //Inspection Item Record Type
    public static final String INS_STANDARD_VISIT_ITEM                             =     'Standard Visit Item';

    //Provider Closed Status Reason
    public static final String PRO_C_S_REASON_VOLUNTARY_CLOSURE                    =     'Voluntary Closure';
    public static final String PRO_C_S_REASON_NEW_APPLICATION_WITHDRAWN            =     'New Application Withdrawn';
    public static final String PRO_C_S_REASON_LEGAL_ACTION                         =     'Legal Action';
    public static final String PRO_C_S_REASON_INCOMPLETE_APPLICATION               =     'Incomplete Application';
    public static final String PRO_C_S_REASON_BRC_ISSUE                            =     'BRC Issue';
    public static final String PRO_C_S_REASON_BRC                                  =     'BRC';
    public static final String PRO_C_S_REASON_MOVED_NO_NOTICE_GIVEN                =     'Moved, no notice given';
    public static final String PRO_C_S_REASON_FAILURE_TO_RENEW                     =     'Failure to Renew';
    public static final String PRO_C_S_REASON_CLOSED                               =     'Closed';

    //Provider Exempt Status
    public static final String PRO_EXEMPT_STATUS_EXEMPT                            =     'Not Funded';
    public static final String PRO_NOT_FUNDED_STATUS                               =     'Not Funded';
    public static final String PRO_FUNDED_STATUS                                   =     'Funded';
    //Provider Exempt Provider Status
    public static final String PRO_EXEMPT_PRO_STATUS                               =     'New Funding Application in progress';

    //License Transaction Group Type
    public static final String LT_GROUP_TYPE_SMALL_GROUP                           =     'Small Group (<=10)';
    public static final String LT_GROUP_TYPE_LARGE_GROUP                           =     'Large Group (>10)';


    //Provider Record Type  LabeL*
    public static final String PRO_LABEL_FAMILY_CHILD_CARE                         =     'Family Child Care';
    public static final String PRO_LABEL_FCC_ASSISTANT                             =     'FCC Assistant';
    public static final String PRO_LABEL_LARGE_GROUP                               =     'Large Group';
    public static final String PRO_LABEL_SMALL_GROUP                               =     'Small Group';
    public static final String PRO_LABEL_GROUP_CARE                                =     'Group Care';
    public static final String PRO_LABEL_TEMPORARY_SHELTER                         =     'Temporary Shelter';
    public static final String PRO_LABEL_ADOPTION_AGENCY                           =     'Adoption Agency';
    public static final String PRO_LABEL_FASTER_CARE_AGENCY                        =     'Foster Care Agency';
    public static final String PRO_LABEL_INFORMAL_CHILD_CARE                       =     'Informal Child Care';
    public static final String PRO_LABEL_UNLICENSED                                =     'Unlicensed';

    //licenseRecord Type contains label
    public static final String LT_LABEL_RENEWAL                                    =     'Renewal';
    public static final String LT_LABEL_NEW_LICENSE                                =     'New_License';
    public static final String LT_LABEL_MOVE                                       =     'Move';
    public static final String LT_LABEL_CHANGE_IN_LICENSE                          =     'Change_in_License';
    public static final String LT_LABEL_LICENSE_CHANGE                             =     'License_Change';
    public static final String LT_LABEL_FCC_RE_ACTIVE                              =     'FCC Re-Active';

    // Inspection Type of Visit picklist
    public static final String VISIT_TYPE_PRE_LICENSING                            =      'Pre-Licensing';
    public static final String VISIT_TYPE_CHANGE_OF_LOCATION                       =      'Change of Location';
    public static final String VISIT_TYPE_LICENSE_CHANGE                           =      'License Change';
    public static final String VISIT_TYPE_RE_ACTIVATE_PROVIDER                     =      'Re-Activate Provider';
    public static final String VISIT_TYPE_CHANGE_OF_SPACE                          =      'Change of Space';
    public static final String VISIT_TYPE_LICENSE_UPGRADE                          =      'License Upgrade';
    public static final String VISIT_TYPE_PROGRESS                                 =      'Progress';
    public static final String VISIT_TYPE_PROVISIONAL_90_DAY_MONITORING            =      'Provisional License 90-day Monitoring';
    public static final String VISIT_TYPE_PROVISIONAL_LICENSE_RENEWAL              =      'Provisional License Renewal';
    public static final String VISIT_TYPE_MONITORING                               =      'Monitoring';
    public static final String VISIT_TYPE_RENEWAL_MONITORING                       =      'Renewal - Monitoring';
    public static final String VISIT_TYPE_RENEWAL_ENHANCED_MONITORING              =      'Renewal - Enhanced Monitoring';
    public static final String VISIT_TYPE_RENEWAL_FULL_REVIEW                      =      'Renewal - Full Review';
    public static final String VISIT_TYPE_ENHANCED_MONITORING                      =      'Enhanced Monitoring';

    // Record Types Visits
    public static final String VISIT_GSA_LICENSING_VISIT                           =     'GSA_Licensing_Visit';
    public static final String VISIT_FCC_LICENSING_VISIT                           =     'FCC_Licensing_Visit';
    public static final String VISIT_RESIDENTIAL_LICENSING_VISIT                   =     'Residential_Licensing_Visit';
    public static final String VISIT_PLACEMENT_LICENSING_VISIT                     =     'Placement_Licensing_Visit';
    
    // Visit Announcement Type 
    public static final String ANNOUNCEMENT_TYPE_SEMI_ANNOUNCED                    =     'Semi-Announced';
    public static final String ANNOUNCEMENT_TYPE_UNANNOUNCED                       =     'Unannounced';
    public static final String ANNOUNCEMENT_TYPE_ANNOUNCED                         =     'Announced';

    
    //Licensee Transaction Status
    public static final String LT_UNSUBMITTED                                      =     'Unsubmitted';
    public static final String LT_SUBMITTED                                        =     'Submitted';
    public static final String LT_UNDER_REVIEW                                     =     'Under Review';
    public static final String LT_CLOSED                                           =     'Closed';
    public static final String LT_CANCELLED                                        =     'Cancelled';
    public static final String LT_T0_SUBMIT                                        =     'To Submit';
    public static final String LT_PENDING_MANAGER_APPROVAL                         =     'Pending Manager Approval';
    public static final String LT_APPROVED_BY_MANAGER	                           =     'Approved By Manager';
    public static final String LT_CLOSED_PROCESSED                                 =     'Closed (Processed)';
    public static final String LT_CLOSED_LICENSE_UPDATED                           =     'Closed (License Issued / Updated)';
    public static final String LT_CANCELLED_BY_APPLICANT                           =     'Cancelled (by Applicant)';
    public static final String LT_CANCELLED_BY_EEC_USER                            =     'Cancelled (by EEC User)';
    public static final String LT_CLOSED_EEC_APPLICATION_INCOMPLETE_DENIED         =     'Closed (EEC Application Incomplete / Denied)';
    public static final String LT_STATUS_REASON_PENDING_LICENSOR_REVIEW            =     'Pending Licensor Review';

    public static final String LT_SOURCE_PROVIDER_PORTAL                           =     'Provider Portal';

    public static final String LT_REASON_CLOSED_CANCELLED_PORTAL                         =     'Cancelled by portal user';
    public static final String LT_REASON_CLOSED_CANCELLED_EEC_USER                         =     'Cancelled by EEC user';

    //Licensee Transaction Status Reason
    public static final String LT_STATUS_REASON_LICENSE_ISSUED                     =     'License Issued';
    public static final String LT_STATUS_REASON_APPLICATION_WITHDREW               =     'Applicant withdrew';
    public static final String LT_STATUS_REASON_PENDING_PROVIDER_RESPONSE          =     'Pending Provider Response';
    public static final String LT_STATUS_REASON_PENDING_ADMIN_REVIEW               =     'Pending Admin Review';
    public static final String LT_STATUS_REASON_PENDING_SUPERVISOR_APPROVAL        =     'Pending Supervisor Approval';
    public static final String LT_STATUS_REASON_PENDING_F_ADMIN_ACTION             =     'Pending Final Admin Action';
    public static final String LT_STATUS_REASON_LACK_OF_RESPONSE                   =     'Lack of Response';
    public static final String LT_STATUS_REASON_BRC_NOT_SUITABLE                   =     'BRC Not Suitable';
    public static final String LT_STATUS_REASON_PENDING_BRC_STAFF_RESPONSE         =     'Pending BRC Staff Response';
    public static final String LT_STATUS_REASON_PENDING_BRC_STAFF_REVIEW           =     'Pending BRC Staff Review';
    public static final String LT_STATUS_REASON_PENDING_LICENSOR_APPROVAL          =     'Pending Licensor Approval';
    public static final String LT_STATUS_REASON_PENDING_F_BRC_STAFF_ACTION         =     'Pending Final BRC Staff Action';
    public static final String LT_STATUS_REASON_PENDING_F_LICENSOR_ACTION          =     'Pending Final Licensor Action';

    //Provider License Status
    public static final String PRO_LICENSED                                        =     'Licensed';
    public static final String PRO_NOT_LICENSED                                    =     'Not Licensed';
    public static final String PRO_APPROVED                                        =     'Approved';
    public static final String PRO_NOT_APPROVED                                    =     'Not Approved';
    public static final String PRO_REGISTERED                                      =     'Registered';
    public static final String PRO_CLOSED                                          =     'Closed';

    //Provider Meeting Participant
    public static final String PRO_MEETING_PARTICIPATION_STATUS_REGISTERED         =     'Registered';
    public static final String PRO_MEETING_PARTICIPATION_STATUS_CANCELLED        =     'Cancelled';
    public static final String PRO_MEETING_PARTICIPATION_STATUS_RENEWAL            =     'Renewal (GSA)';
    public static final String PRO_MEETING_PARTICIPATION_STATUS_OPEN_REGIS           =     'Open for registration';

     //Provider Status
     public static final String PRO_STATUS_CLOSED                                  =     'Closed';
     public static final String PRO_STATUS_VOLUNTARY_CLOSURE                       =     'Voluntary Closure';
     public static final String PRO_STATUS_APPLICATION_WITHDRAWN_CLOSED            =     'Application Withdrawn / Closed';
     public static final String PRO_STATUS_NEW_APPLICATION_IN_PROGRESS             =     'New application in progress';
     public static final String PRO_STATUS_CURRENT                                 =     'Current';
     public static final String PRO_STATUS_RENEWAL_IN_PROGRESS                     =     'Renewal in progress';

    //Provider License Type
    public static final String PRO_FIRST_PROVISIONAL                               =     'First Provisional';
    public static final String PRO_SECOND_PROVISIONAL                              =     'Second Provisional';
    public static final String PRO_REGULAR                                         =     'Regular';
    public static final String PRO_FAMILY                                          =     'Family';
    public static final String PRO_FFC                                             =     'FFC';
    public static final String CONTACT_ACTIVE_STATUS                               =     'Active';

    // Transaction Due Diligence Status
    public static final String DUE_PENDING                                         =     'Pending';
    public static final String DUE_COMPLETED                                       =     'Completed';
    public static final String DUE_NOT_APPLICABLE                                  =     'Not Applicable';

    // Transaction Due Diligence CheckList Name
    public static final String TRANS_DUE_CHECKLIST_NAME_SUBMIT_APPLICATION_FEE                                   =     'Submit application fee payment';
    public static final String TRANS_DUE_CHECKLIST_NAME_SUBMIT_BACKGROUND_RECORD_CHECK                           =     'Submit background record check consent form';
    public static final String TRANS_DUE_CHECKLIST_NAME_SUBMIT_TAX_CERTIFICATION                                 =     'Submit Tax Certification form';

    //Additional Information Record Type
    public static final String AI_OTHER_LICENSES_HELD                              =     'Other_Licenses_Held';
    public static final String AI_OTHER_LICENSE_APPLICATIONS                       =     'Other_License_Applications';
    public static final String AI_ADMIN_CIVIL_CRIMINAL_ACTION_DETAIL               =     'Admin_civil_criminal_action_detail';
    public static final String AI_STATE_FEDERAL_INVESTIGATION_DETAIL               =     'State_federal_investigation_detail';

    //MTX Story Status
    public static final String STATUS_CLOSED                                       =      'Closed';
    public static final String STORY_NAME                                          =      'LEAD Phase 3 Support';

    public static final String NON_COMPLIANT_CORRECTIVE_PLAN_PROVIDER_SUBMITTED    =      'Provider Submitted, EEC to Review';
    public static final String NON_COMPLIANT_CORRECTIVE_PLAN_ACCEPTED              =      'EEC Accepted';

    //MTX Issue
    public static final String MTX_ISSUE_STATUS_NEW                                =      'New';

    //OrgWideEmailAddress
    public static final String ORGWIDE_EMAIL_ADDRESS_DISPLAY_NAME                  =      'EEC LEAD Alert';

    //Document Status
    public static final String DOCUMENT_STATUS_REVIEWED                            =      'Reviewed';
    public static final String DOCUMENT_STATUS_APPROVED                            =      'Approved';
    public static final String DOCUMENT_STATUS_UNSUBMITTED                         =      'Unsubmitted';
    public static final String DOCUMENT_RESPONSIBLE_PARTY_PROVIDER                 =      'Provider';
    public static final String DOCUMENT_RESPONSIBLE_PARTY_UMBRELLA                 =      'Umbrella';
    public static final String DOCUMENT_RESPONSIBLE_PARTY_UNSUBMITTED              =      'Unsubmitted';
    public static final String DOCUMENT_RESPONSIBLE_PARTY_LICENSOR                 =      'Licensor';
    public static final String DOCUMENT_STATUS_SUBMITTED                           =      'Submitted';
    public static final String DOCUMENT_NO_ATTACHMENT                              =      'No Attachment';
    public static final String DOCUMENT_RETURNED_FOR_REVISION                      =      'Returned for Revision';
    public static final String DOCUMENT_LEGACY_REVIEWED                            =      'Legacy Reviewed';

    //Transaction Contact
    public static final String TC_ROLE_REGULARLY_ON_PREMISE                        =      'Regularly on Premise';
    public static final String TC_ROLE_LICENSEE                                    =      'Licensee';
      public static final String TC_ROLE_OTHER_CONTACT                             =      'Other Contact';
    public static final String TC_ROLE_HOUSEHOLD_MEMBER                            =      'Household Member';
    public static final String TC_BRC_ROLE_LICENSEE                                =      'Licensee';
    public static final String TC_ROLE_ASSISTANT                                   =      'Assistant';
    public static final String TC_BRC_ROLE_PROGRAM_ADMINISTRATOR                   =      'BRC Program Administrator';
    public static final String TC_SUITABILITY_PENDING                              =      'Pending';
    public static final String TC_SUITABILITY_NOT_SUITABLE                         =      'Not Suitable';
    public static final String TC_STATUS_ACTIVE                                    =      'Active';
    public static final String TC_STATUS_TO_UPLOAD                                 =      'To Upload';
    public static final String TC_STATUS_INACTIVE                                  =      'Inactive';
    public static final String TC_ROLE_HOUSEHOLD                                   =      'Household';
    public static final String TC_MODE_REQUIRED                                    =      'Required';
    public static final String TC_ROLE_PROGRAM_DIRECTOR                            =      'Program Director';
    public static final String TC_ROLE_ASSISTANT_DIRECTOR                          =      'Assistant Director';
    public static final String TC_ROLE_EXECUTIVE_DIRECTOR                          =      'Executive Director';
    public static final String TC_ROLE_ADMINISTRATIVE_DESIGNEE                     =      'Administrative Designee';
    public static final String TC_ROLE_SITE_COORDINATOR                            =      'Site Coordinator';
    public static final String TC_ROLE_QUALITY_ASSURANCE_DIRECTOR                  =      'Quality Assurance Director';
    public static final String TC_ROLE_MAIN_CONTACT                                =      'Main Contact';
    public static final String TC_ROLE_PARTNER                                     =      'Partner';
    public static final String TC_ROLE_OWNER                                       =      'Owner';
    public static final String TC_ROLE_FUNDING_SOURCE                              =      'Funding Source';
    public static final String TC_ROLE_BOARD_CHAIR                                 =      'Board Chair';
    public static final String TC_ROLE_HR_STAFF                                    =      'HR Staff';
    public static final String TC_ROLE_OTHER                                       =      'Other';
    public static final String TC_CM_BRC_SCENARIO_LICENSEE_UPDATE                  =      'Licensee Update';
    public static final String TC_CM_BRC_SCENARIO_PROGRAM_A_UPDATE                 =      'Program Administrator Update';

    // Transaction Contact
    public static final String TC_DO_YOU_NEED_BRC_FORM                             =      'Yes';
    public static final String TC_DO_YOU_NEED_BRC_FORM_NO                          =      'NO';
	public static final String TC_BRC_CONSENT_STATUS                          	   =      'Completed';

    // intervention Transaction
    public static final String IT_STATUS_SUBMITTED                                 =      'Submitted';


    // Investigation
    public static final String INVESTIGATION_OVERSIGHT_STATUS                      =      'Published to Website';

    // Investigation Status
    public static final String INVESTIGATION_STATUS_CLOSED                         =      'Closed';
    public static final String INVESTIGATION_STATUS_CLOSED_LEGACY_INVES            =      'Closed (Legacy Investigation)';
    public static final String INVESTIGATION_STATUS_REPORT_TO_BE_SENT_TO_PRO       =      'Report to be sent to Provider';
    public static final String INVESTIGATION_STATUS_REPORT_SENT_TO_PROVIDER        =      'Report Sent to Provider, Awaiting feedback';
    public static final String INVESTIGATION_STATUS_FEEDBACK_RECEVIED_TO_REVIEW    =      'Feedback received, to review';

    //Intervation Record Type
    public static final String INTERVATION_INTERNAL_INVESTIGATION                  =      'Internal_Investigation';
    public static final String INTERVATION_OTHER_INVESTIGATION                  =      'Other_Intervention	';

    //Transaction Due Diligence  
    public static final String TRANSACTION_DUE_DILIGENCE_PROVIDER                  =      'Provider';
    public static final String TRANSACTION_DUE_DILIGENCE_ADMIN                     =      'Admin';
    public static final String TRANSACTION_DUE_DILIGENCE_LICENSOR                  =      'Licensor';
    public static final String TRANSACTION_DUE_DILIGENCE_SYSTEM                    =      'System';
    public static final String TRANSACTION_DUE_DILIGENCE_SUPERVISOR                =      'Supervisor';
    public static final String TRANSACTION_DUE_DILIGENCE_MONITOR                   =      'Monitor';
    public static final String TRANSACTION_DUE_DILIGENCE_BRCSTAFF                  =      'BRC Staff';
    public static final String TRANSACTION_DUE_DILIGENCE_EEC_MONITORS              =      'EEC Monitors';

    // User Role 
    public static final String USER_ROLE_ADMIN                                     =      'Admin';
    public static final String USER_ROLE_LICENSOR                                  =      'Licensor';
    public static final String USER_ROLE_SUPERVISOR                                =      'Supervisor';
    public static final String USER_ROLE_EEC_MONITORS                              =      'EEC Monitors';
    public static final String USER_ROLE_BRCSTAFF                                  =      'BRC Staff';
    public static final String USER_ROLE_PROVIDER                                  =      'Provider';

    public static final String USER_ROLE_REGIONAL_DIRECTOR                         =      'Regional Director';
    public static final String USER_ROLE_EXECUTIVE_AND_DIRECTORS                   =      'Executive and Directors';
    public static final String USER_ROLE_SYSTEM_ADMINISTRATOR                      =      'System Administrator';
    //public static final String USER_ROLE_PROVIDER                                  =      'Provider';
    

    //Inspection Item /Visit Item result
    public static final String INSPECTION_RESULT                                   =      'Non-Compliant';
    public static final String INSPECTION_RESULT_NOT_APPLICABLE                    =      'Not Applicable';
    public static final String VISIT_ITEM_INSPECTION_RESULT_COMPLIANT              =      'Compliant';

    // Inspection Item Correction Plan Status
    public static final String INSPECTION_ITEM_CORRECTION_PLAN_EEC_ACCEPTED        =      'EEC Accepted';
    public static final String INSPECTION_ITEM_CORRECTION_PLAN_PROVIDER_SUBMITTED  =      'Provider To Submit';
    public static final String INSPECTION_ITEM_CORRECTION_PLAN_SUBMITTED_TO_REVIEW =      'Provider Submitted, EEC to Review';

    // Non Compliant Correction Plan Status
    public static final String NON_COMPLIANT_CORRECTION_PLAN_EEC_ACCEPTED          =      'EEC Accepted';
    public static final String NON_COMPLIANT_CORRECTION_PLAN_PROVIDER_SUBMITTED    =      'Provider To Submit';
    public static final String NON_COMPLIANT_CORRECTION_PLAN_SUBMITTED_TO_REVIEW   =      'Provider Submitted, EEC to Review';

    // Inspection Item Record Type Developer Name
    public static final String INSPECTION_ITEM_STANDARD_ITEM                       =      'Standard_Item';
    public static final String INSPECTION_ITEM_ADDITIONAL_INSPECTION_ITEM          =      'Additional_Inspection_Item';

    // Case status
    public static final String CASE_STATUS_CLOSED                                  =      'Closed';
    public static final String CASE_NO_NON_COMPLIANCE_SERIOUS_INJURY				=	  'No Non-Compliance Serious Injury';

    //Transaction Document Status
    public static final String TRANSACTION_DOCUMENT_STATUS_REVIEWED                 =      'Reviewed';
     public static final String TRANSACTION_DOCUMENT_STATUS_NEW_ATTACHEMT           =      'New Attachment';
    public static final String TRANSACTION_DOCUMENT_STATUS_RETURNED_FOR_REVISION    =      'Returned for Revision';
    public static final String TRANSACTION_DOCUMENT_STATUS_ATTACHMENT_NO_ATTACHMENT =      'No Attachment';
    public static final String TRANSACTION_DOCUMENT_STATUS_SUBMITTED                =      'Submitted';
    public static final String TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED              =      'Unsubmitted';
    public static final String TRANSACTION_DOCUMENT_STATUS_LEGACY_REVIEWED          =      'Legacy Reviewed';
    public static final String TRANSACTION_DOCUMENT_ATTACHMENT_STATUS               =      'Attachment(s) Available';

    //Transaction Document Name
    public static final String TRANSACTION_DOCUMENT_NAME_TAX_CERTI_STATEMENT        =      'Tax Certification Statement';

    //Transaction Document mode
    public static final String TRANSACTION_DOCUMENT_MODE_ADDITIONAL                 =      'Additional';
     public static final String TRANSACTION_DOCUMENT_MODE_REQUIRED                  =      'Required';
    public static final String TRANSACTION_DOCUMENT_MODE_OPTIONAL                   =      'Optional';
    public static final String TRANSACTION_DOCUMENT_MODE_VARIANCE                   =      'Variance';
    public static final String TRANSACTION_DOCUMENT_MODE_INDIVIDUAL                 =      'Individual';

//Transaction Document mandatory
    public static final String TRANSACTION_DOCUMENT_MANDATORY                       =      'Mandatory';

    //Intervation Status
    public static final String INTERVATION_STATUS_TO_SUBMIT                         =      'To Submit';
    public static final String INTERVATION_STATUS_SUBMITTED                         =      'Submitted';
    public static final String INTERVATION_STATUS_DONE                              =      'Done';

    //User Info
    public static final String GRT_USER_TYPE_POWER_PARTNER                           =      'PowerPartner';
    public static final String GRT_USER_TYPE_POWER_CUSTOMER_SUCCESS                  =      'PowerCustomerSuccess';
    public static final String GRT_USER_TYPE_CSP_LITE_PORTAL                         =      'CspLitePortal';
    public static final String GRT_USER_TYPE_CUSTOMER_SUCCESS                        =      'CustomerSuccess';

    // S3 File
    public static final String S3_FILE_STATUS_SUBMITTED                             =      'Submitted';
    public static final String S3_FILE_STATUS_LEGACY_REVIEWED                       =      'Legacy Reviewed';

    // Provider Meeting
    public static final String PROVIDER_MEETING_OPEN_FOR_RESISTRATION               =      'Open for registration';
    public static final String PROVIDER_MEETING_CLOSED_FOR_RESISTRATION             =      'Closed for registration';

    //  Region Recordtype Developer name
    public static final String REGION_LICENSING_REGION                              =      'Licensing_Region';

    // Provider Provider Status
    public static final String PROVIDER_STATUS_CLOSED                               =      'Closed';
    public static final String PROVIDER_STATUS_VOLUNTARY_CLOSURE                    =      'Voluntary Closure';
    public static final String PROVIDER_STATUS_INACTIVE                             =      'Inactive';
	// Provider License_Type
	public static final String PROVIDER_LICENSE_TYPE                                =      'Regular Approval';

	// LICENSE TRANSACTION License_Type
	public static final String LT_LICENSE_TYPE_REGULAR_APPROVAL                     =      'Regular Approval';

   // Provider Provider Regulatory Status
   public static final String PROVIDER_REGULATORY_STATUS_INACTIVE                   =      'Inactive';

	// license transaction License Requested
	public static final String LT_LICENSE_REQUESTED_REGULAR_ASSISTANT                                     =      'Regular Assistant';
    public static final String LT_LICENSE_REQUESTED_CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT_6               =      'Certified Family Child Care Assistant (6)';
    public static final String LT_LICENSE_REQUESTED_CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT_8               =      'Certified Family Child Care Assistant (8)';
    public static final String LT_LICENSE_REQUESTED_CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT_10              =      'Certified Family Child Care Assistant (10)';

   // license transaction Provider Regulatory Status
   public static final String LT_REGULATORY_STATUS_ACTIVE                           =      'Active';
   // license transaction Independent Child Care Type
   public static final String LT_INDEPENDENT_CHILD_STATUS_ACTIVE_NON_RELATIVES      =      'Non-relatives only';
   public static final String LT_INDEPENDENT_CHILD_STATUS_ACTIVE_BOTH_RELATIVE      =      'Both relatives and non-relatives';


    //Provider Certified As
    public static final String CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT                =      'Certified Family Child Care Assistant';
    public static final String CERIFIED_REGULAR_ASSISTANT                           =       'Regular Assistant';

    // Inspection / Visit Status
    public static final String VISIT_STATUS_TO_BE_SCHEDULED                         =      'To be scheduled';
    public static final String VISIT_STATUS_SCHEDULED                               =      'Scheduled';
    public static final String VISIT_STATUS_VISIT_COMPLETED                         =      'Visit Completed';
    public static final String VISIT_STATUS_PENDING_APPROVAL                        =      'Pending Approval';
    public static final String VISIT_STATUS_REPORT_TO_BE_SENT_TO_PRO                =      'Report to be sent to Provider';
    public static final String VISIT_STATUS_REPORT_SENT_TO_PROVIDER                 =      'Report Sent to Provider, Awaiting feedback';
    public static final String VISIT_STATUS_FEEDBACK_RECEVIED_TO_REVIEW             =      'Feedback received, to review';
    public static final String VISIT_STATUS_CLOSED                                  =      'Closed';
    public static final String VISIT_STATUS_CANCELLED                               =      'Cancelled';


    // Inspection / Visit Record Type
    public static final String VISIT_LEGACY_SYSTEM_IMPORT_VISIT_NON_COMPLI           =      'Legacy_System_Import_Visit_Non_Compliance';
    public static final String VISIT_INVESTIGATION_VISITS                            =      'Investigation_Visits';


    // Case Record Type
    public static final String CASE_COMPLAINT                                         =      'Complaint';
    public static final String CASE_INCIDENT                                          =      'Incident';
    public static final String CASE_LEGACY_CASE                                       =      'Legacy_Case';
    public static final String CASE_REQUIRED_NOTIFICATION                             =      'Required_Notification';
    public static final String CASE_SGLSA_INJURY                                      =      'SGLSA_Injury';

    // Inspection
    public static final String INSPECTION_OVERSIGHT_STATUS_REVIEW_IN_PROGRESS       =      'Review in Progress';
    public static final String INSPECTION_OVERSIGHT_STATUS                          =      'Published to Website';
    public static final String INSPECTION_OVERSIGHT_STATUS_LEGAL_REVIEW_REQUIRED    =      'Legal Review Required';

    public static final String INSPECTION_RESULT_COMPLIANT                          =      'Compliant';
    public static final String INSPECTION_RESULT_NON_COMPLIANT                      =      'Non-Compliant';
    public static final String INSPECTION_RESULT_NOT_ASSESSED                        =      'Not Assessed';
    public static final String INSPECTION_RESULT_NOT_ASSESSED_TOOL_ABANDONED        =      'Non Assessed (tool abandoned)';

    // Condition And Limitation
    public static final String CONDITION_LIMITATION_STATUS_APPROVED                 =      'Approved';
    public static final String CONDITION_LIMITATION_STATUS_PENDING_APPROVAL         =      'Pending Approval';
    public static final String CONDITION_LIMITATION_STATUS_EXPIRED                  =      'Expired';
    // Conditions and Limitations
    //this constant replace in staging in missing element class reopace to above
   // public static final String CONDITION_STATUS_PENDING_APPROVAL                    =      'Pending Approval';

    //License Transaction Last Reached steps
    public static final String LT_LAST_REACHED_INSTRUCTION                               =      'Instructions';
    public static final String LT_LAST_REACHED_TRANSACTION_PRO_INFO                      =      'Transaction / Provider Information';
    public static final String LT_LAST_REACHED_HOUSEHOLD_MEMBER                          =      'Household Members';
    public static final String LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO    =      'License Status and Capacity / Assistant Information	';
    public static final String LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP      =      'Involvement & Professional Experience';
    public static final String LT_LAST_REACHED_BACKGROUND_INFO                           =      'Background Information';
    public static final String LT_LAST_REACHED_TRAINING_INFO                             =      'Training Information';
    public static final String LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO                  =      'Indoor / Outdoor space information';
    public static final String LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE  =      'Daily Routing Activities / Technical Assistance';
    public static final String LT_LAST_REACHED_ATTACHMENTS                               =      'Attachments';
    public static final String LT_LAST_REACHED_REVIEW_SUMMARY_AND_SUBMISSION             =      'Review Summary and Submission';
    public static final String LT_LAST_REACHED_LICENSING_STATUS_AND_CAPACITY             =      'Licensing Status and Capacity';
    public static final String LT_LAST_REACHED_ASSISTANT_INFORMATION                     =      'Assistant Information';
    public static final String LT_LAST_REACHED_PAYMENT_INFORMATION                       =      'Payment information';
    public static final String LT_LAST_REACHED_REVIEW_SUBMISSION                         =      'Review & Submission';
    public static final String LT_LAST_REACHED_OWNERSHIP_ADMINISTRATOR_INFO              =      'Ownership and Administrator Info';
    public static final String LT_LAST_REACHED_VARIANCE_DETAILS                          =      'Variance Details';
    public static final String LT_LAST_REACHED_INFORMATION_ABOUT_LOCATION_CARE           =      'Information About Location of Care';
    public static final String LT_LAST_REACHED_CAPACITY_INFO                             =      'Capacity Info';
    public static final String LT_LAST_REACHED_RESIDENTIAL_PROGRAM_DETAILS               =      'Residential Program Details';
    public static final String LT_LAST_REACHED_PLACEMENT_AGENCY_ADDITIONAL_INFO          =      'Placement Agency Additional Information';
    public static final String LT_LAST_REACHED_DESIGNATION_ADMIN_RESPONSIBILITY          =      'Designation of Administrative Responsibility';
     public static final String LT_LAST_REACHED_OPERATION_DETAILS                        =      'Operation Details';
     public static final String LT_LAST_REACHED_OPERATION_DETAILS_INFORMATION            =      'Operation details Information';
     public static final String LT_LAST_REACHED_CLOSE_FUNDING_INFO                       =      'Close Funding Info';

  // License Transaction Application
    public static final String LT_APP_NEW_APPLICATION                                        =      'New Application';
    public static final String LT_APP_APPLY_FOR_RENEWAL                                      =      'Apply for Renewal';
    public static final String LT_APP_APPLY_FOR_UPGRADE                                      =      'Apply for an Upgrade';
    public static final String LT_APP_APPLY_FOR_CHANGE_OF_ADDRESS                            =      'Apply for a Change of Address';
    public static final String LT_APP_APPLY_FOR_CHANGE_OF_PROVIDER_NAME                      =      'Apply for a Change in Provider Name';
    public static final String LT_APP_APPLY_FOR_RENEWAL_AS_ASSISTANT                         =      'Apply for Renewal as an Assistant';
    public static final String LT_APP_PROVISIONAL_TO_REGULAR                                 =      'Provisional to Regular';
    public static final String LT_APP_CHANGE_OF_LICENSED_ROOM                                =      'Change of Licensed Room';
    public static final String LT_APP_CHANGE_OF_HOUSEHOLD_MEMBER_INDIVISUALS_REGULARLY       =      'Notify EEC - Change of Household Members / Individuals Regularly on the Premises';
    public static final String LT_APP_REQUEST_RE_ISSUANCE_OF_LICENSE                         =      'Request Re-Issuance of License';
    public static final String LT_APP_RE_ACTIVATE_LICENSE_CERTIFICATE                        =      'Re-Activate License / Certificate';
    public static final String LT_APP_INACTIVE_LICENSE_CERTIFICATE                           =      'Inactive License / Certificate';
    public static final String LT_APP_INTEND_TO_CLOSE_PROGRAM                                =      'Intend to Close Program';
    public static final String LT_APP_FCC_DOWNGRADE_CAPACITY                                 =      'FCC Downgrade Capacity';
    public static final String LT_APP_REQUEST_VARIANCE_ON_REGULATIONS                        =      'Request a Variance on Regulations';
    public static final String LT_APP_BACKGROUND_RECORD_CHECK                                =      'Background Record Check';
    public static final String LT_APP_EEC_FCC_MODIFICATION                                   =      'EEC FCC Modification';
    public static final String LT_APP_EEC_RP_MODIFICATION                                    =      'EEC RP Modification';
    public static final String LABEL_LT_APP_EEC_LICENSEE_MANAGEMENT                          =      'Licensee Management';
    public static final String LT_APP_EEC_GSA_MODIFICATION                                   =      'EEC GSA Modification';
    public static final String LT_APP_APPLY_FOR_LICENSE_CHANGE                               =      'Apply for a License Change';
    public static final String LT_APP_APPLY_FOR_MOVE                                         =      'Apply for a Move';
    public static final String LT_APP_APPLY_FOR_TEMPORARY_MOVE                               =      'Apply for a Temporary Move';
    public static final String LT_APP_REPORT_CHANGE_IN_PROVIDER_NAME                         =      'Report a Change in Provider Name';
    public static final String LT_APP_DESIGNATION_OF_ADMINISTRATIVE_AUTHORITY                =      'Designation of Administrative Authority';
    public static final String LT_APP_REPORT_CHANGE_IN_OWNERSHIP_ADMINISTRATIVE_DESIGNEE     =      'Report a Change in Ownership or Administrative Designee';
    public static final String LT_APP_CONTACT_MANAGEMENT                                     =      'Contact Management';
    public static final String LT_APP_CBC_NEW_FUNDING_APPLICATION                            =      'CBC New Funding Application';
    public static final String LT_APP_CHILD_CARE_LICENSING_EXEMPTION                         =      'Child Care Licensing Exemption';
    public static final String LT_APP_SUMMER_CAMP_NEW_FUNDING_APPLICATION                    =      'Summer Camp New Funding Application';
    public static final String LT_APP_INFORMAL_CAMP_NEW_FUNDING_APPLICATION                  =      'Informal Care New Funding Application';
    public static final String LT_APP_APPLY_TO_UPGRADE_DOWNGRADE_CAPACITY                    =      'Apply to Upgrade/Downgrade Capacity' ;
    public static final String LT_APP_APPLY_TO_BECOME_CERTIFIED_ASSISTANT                    =      'Apply to become a Certified Assistant' ;
    public static final String LT_APP_APPLY_TO_CHANGE_IN_ASSISTANT_NAME                      =      'Apply for a Change in Assistant Name' ;
    public static final String LT_APP_APPLY_TO_BE_LICENSED_FCC_PROVIDER                      =      'Apply to be licensed as FCC Provider' ;
    public static final String LABEL_LT_PRIVATE_SCHOOL_NEW_FUNDING_APPLICATION               =      'Private School New Funding Application' ;
    public static final String LABEL_LT_PUBLIC_SCHOOL_NEW_FUNDING_APPLICATION                =      'Public School New Funding Application' ;
    public static final String LABEL_LT_OTHER_ELIGIBLE_PROVIDERS_NEW_FUNDING_APPLICATION     =      'Other Eligible Providers New Funding Application' ;
    public static final String LABEL_LT_CLOSED_FUNDED_PROGRAM                                =      'Close Funding' ;
	public static final String LABEL_LT_CLOSED_INFORMAL_CHILD_CARE_PROGRAM                   =      'Close Funding' ;

    // license transaction Legacy Transaction Type
    public static final String LT_LEGACY_TRANSACTION_TYPE_RE_OPEN_PROGRAM                    =      'Re-Open Program';
    public static final String LT_LEGACY_TRANSACTION_TYPE_RE_OPEN_CERTIFICATE                =      'Re-open Certificate';


  // Investigation Outcome Code picklist
    public static final String I_O_CODE_IO1_DEATH                                            =      'IO1: Death';
    public static final String I_O_CODE_IO2_SERIOUS_INJURY                                   =      'IO2: Serious Injury';
    public static final String I_O_CODE_IO3_SUBSTANTIATED_CHILD_ABUSE                        =      'IO3: Substantiated Child Abuse';
    public static final String I_O_CODE_NO_DEATH_SUBSTANTIATED_CHILD_ABUSE_SERIOUS_INJURY    =      'No Death,Substantiated Child Abuse,Serious Injury';

    // Contact Role 
    public static final String CONTACT_ROLE_DIRECTOR                                         =      'Director';
    public static final String CONTACT_ROLE_OWNER                                            =      'Owner';
    public static final String CONTACT_ROLE_DESIGNEE                                         =      'Designee';
    public static final String CONTACT_ROLE_BOARD_CHAIR                                      =      'Board Chair';
    public static final String CONTACT_ROLE_FUNDING_SOURCE                                   =      'Funding Source';
    public static final String CONTACT_ROLE_LICENSEE                                         =      'Licensee';
    public static final String CONTACT_ROLE_ASSISTANT                                        =      'Assistant';
    public static final String CONTACT_ROLE_PROGRAM_DIRECTOR                                 =      'Program Director';
    public static final String CONTACT_ROLE_EXECUTIVE_DIRECTOR                               =      'Executive Director';
    public static final String CONTACT_ROLE_HOUSHOLD_MEMBER                                  =     'Household Member';
    public static final String CONTACT_ROLE_REGULARLY_ON_PREMISE                             =      'Regularly on Premise';
    public static final String CONTACT_ROLE_PROGRAM_ADMINISTRATOR                            =      'BRC Program Administrator';
    public static final String CONTACT_ROLE_ADMINISTRATIVE_DESIGNEE                          =      'Administrative Designee';
     public static final String CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD                     =      'Program Director / Administrative Head';
     public static final String CONTACT_ROLE_PARTNER                                         =      'Partner';

    // Contact Role Status
    public static final String CONTACT_LICENSEE                                              =      'Licensee';

     // Contact
        public static final String CONTACT_ROLE_STATUS_ACTIVE                                =      'Active';
        public static final String CONTACT_ROLE_STATUS_INACTIVE                              =      'Inactive';

    // Contact Status
    public static final String CONTACT_STATUS_ACTIVE                                         =      'Active';
    public static final String CONTACT_STATUS_INACTIVE                                       =      'Inactive';

    // Task Status
    public static final String TASK_STATUS_COMPLETED                                         =      'Completed';
    public static final String TASK_STATUS_PRIORITY_NORMAL                                   =      'Normal';
    public static final String TASK_STATUS_NOT_STARTED                                       =      'Not Started';
    public static final String TASK_PRIORITY_MEDIUM                                          =      'Medium';
    public static final String TASK_DESCRIPTION_MAKE_USER_INACTIVE                           =      'Make the user inactive';
    public static final String TASK_DESCRIPTION_ACTIVATE_USER                                =      'Activate the user';

    //LT Renewal Type
        public static final String LT_RENEWAL_TYPE_PROVISIONAL_TO_REGULAR                    =      'Provisional to Regular';
        public static final String LT_RENEWAL_TYPE_RENEWAL                                   =      'Renewal';

    // Provider Room In Use                                                                                                         
    public static final String PROVIDER_ROOM_IN_USE                                          =      'In Use';

    // Lead Configuration
    public static final String LEAD_CONFIG_FCC_ASSISTANT                                     =      'FCC Assistant';
    public static final String LEAD_CONFIG_LARGE_GROUP                                       =      'Large Group';
    public static final String LEAD_CONFIG_SMALL_GROUP                                       =      'Small Group';
    public static final String LEAD_CONFIG_FCC                                               =      'Family Child Care';
    public static final String LEAD_CONFIG_PRE_TRANSACTION_TYPE                              =      'Per_Transaction_Type';
    public static final String LEAD_CONFIG_PRE_PROVIDER_TYPE                                 =      'Per_Provider_Type';

       // License Transaction Ownership Type
     public static final String LT_OWNERSHIP_TYPE_DOING_BUSINESS_AS_DBA                      =      'Doing Business As (DBA)';
     public static final String LT_OWNERSHIP_TYPE_NON_PROFIT_CORP                            =      'Non-Profit Corp';
     public static final String LT_OWNERSHIP_TYPE_FOR_PROFIT_CROP                            =      'For Profit Corp.';
     public static final String LT_OWNERSHIP_TYPE_PARTERSHIP                                 =      'Partnership';
     public static final String LT_OWNERSHIP_TYPE_INDIVIDUAL                                 =      'Individual';
     public static final String LT_OWNERSHIP_TYPE_UNINCORPORATED                             =      'Unincorporated';

     // Provider Ownership Type
     public static final String PRO_OWNERSHIP_TYPE_DOING_BUSINESS_AS_DBA                      =      'Doing Business As (DBA)';
     public static final String PRO_OWNERSHIP_TYPE_NON_PROFIT_CORP                            =      'Non-Profit Corp';
     public static final String PRO_OWNERSHIP_TYPE_FOR_PROFIT_CROP                            =      'For Profit Corp.';
     public static final String PRO_OWNERSHIP_TYPE_PARTERSHIP                                 =      'Partnership';
     public static final String PRO_OWNERSHIP_TYPE_INDIVIDUAL                                 =      'Individual';

     //Investigation Outcome Code
     public static final String IOC_INJURY                                                    =      'Injury';
      public static final String IOC_ABUSE                                                    =      'Abuse';
      public static final String IOC_DEATH                                                    =      'Death';
    


    //EEC_DeatChildAbuseSeriousInjuryRptsCtrl
    public static final String LARGE_GROUP_TOTAL                                              =      'Large_Group_Total';
    public static final String GROUP_AND_SCHOOL_AGE_TOTAL                                     =      'Group_And_School_Age_Total';
    public static final String FCC_TOTAL                                                      =      'FCC_Total';
    public static final String UNLICENSED_PROVIDER_TOTAL                                      =      'Unlicensed_Provider_Total';
    public static final String FUNDED_CARE_TOTAL                                              =      'Funded_Care_Total';
    public static final Map<Integer, String> MONTH_NUMBER_MONTH_NAME_MAP                      =       new Map<Integer, String>{1 => 'January', 
                                                                                                        2 => 'February', 3 => 'March', 
                                                                                                        4 => 'April', 5 => 'May', 6 => 'June',
                                                                                                        7 => 'July', 8 => 'August', 9 => 'September',
                                                                                                        10 => 'October', 11 => 'November', 12 => 'December'};
    // Error Log RecordType
    public static final String DIFFERENTIAL_VISIT_ERROR_LOG                                   =       'Differential_Licensing_Visit_Batch_Error' ; 
    
    //create map for transaction document 
    

}