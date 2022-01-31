/*
*   Class Name: NYSUN_Helper
*   Description:  Helper class for NYSun
*            
*/
public class NYSUN_Helper
{

    public static final String NYS_PROJECT_TO_CASE_MAPPING_METADATA_TYPE_API_NAME = 'NYSUN_Project_to_Case_Mapping';

    public static final String RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Residential';
    public static final String COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Commercial';
    public static final String INVERTER_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Inverter';
    public static final String MODULES_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Modules';
    public static final String DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Documents';
    public static final String METER_DATA_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Meter_Data';


    public static final Set<String> CONST_SET_OF_PROJ_STATUS_FOR_DOCUMENT_UPLOAD_ON_MIGRATED_APP = new Set<String>{Project_Helper.PROJECT_STATUS_PENDINGAPPROVAL,
                                                                                                                   Project_Helper.PROJECT_STATUS_SUBMITTED,
                                                                                                                   Project_Helper.PROJECT_STATUS_RECEIVED,
                                                                                                                   Project_Helper.PROJECT_STATUS_APPROVED,
                                                                                                                   Project_Helper.PROJECT_STATUS_COMPLETED};



    public static final String PROJECT_ROLE_CUSTOMER = 'Customer';
    public static final String PROJECT_ROLE_CONTRACTOR = 'Contractor';
    public static final String PROJECT_ROLE_PAYEE = 'Payee';
    public static final Set<String> PROJECT_ROLE_SET = new Set<String>{PROJECT_ROLE_PAYEE, PROJECT_ROLE_CUSTOMER,PROJECT_ROLE_CONTRACTOR};

    public static final String RESIDENTIAL_REFERENCE_TYPE = 'NYSUN - Residential/Small Commercial';
    public static final String COMMERCIAL_REFERENCE_TYPE = 'NYSUN - Commercial and Industrial';

    public static final String PROJECT_NOTIFICATIONS_ON_APPROVED_APP_HIDDEN_180_AFTER = 'Approved - 180 days after'; // T-00788
    public static final String PROJECT_NOTIFICATIONS_ON_APPROVED_APP_HIDDEN_210_AFTER = 'Approved - 210 days after'; // T-00788
    public static final Set<String> CONST_SET_OF_APPROVED_NOTIFICATION_ROLES = new Set<String> {ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE,ProjectRole_Helper.PROJECT_BUILDER_ROLE, ProjectRole_Helper.PROJECT_CUSTOMER_ROLE}; // T-00788

    public static final String SIGNED_DOCUMENT_TITLE = 'Signed Project Application Form';
    public static final String DOCUMENT_STATUS_REJECT = 'Reject';

    public static final String  PAYEE_EMAIL_TEMPLATE_NAME = 'NY_Sun_Commercial_Payee_Contractor_Application_Creation_Notification';

    public static final String ACTIVE_STATUS = 'Active';

    public static final String APPROVED_STATUS = 'Approved';

    public static final String APPLICATION_TRACK1 = 'Track 1 - Project Maturity';
    public static final String APPLICATION_TRACK2 = 'Track 2 - Financial Security';

    public static final String NON_RESIDENTIAL_START_TAG = '&lt;non-residential&gt;';
    public static final String NON_RESIDENTIAL_END_TAG = '&lt;/non-residential&gt;';
    public static final String RESIDENTIAL_START_TAG = '&lt;residential&gt;';
    public static final String RESIDENTIAL_END_TAG = '&lt;/residential&gt;';
    public static final String AFFORDABLE_SOLAR_START_TAG = '&lt;affordable-solar&gt;';
    public static final String AFFORDABLE_SOLAR_END_TAG = '&lt;/affordable-solar&gt;';
    public static final String TRACK1_START_TAG = '&lt;track1&gt;';
    public static final String TRACK1_END_TAG = '&lt;/track1&gt;';
    public static final String TRACK2_START_TAG = '&lt;track2&gt;';
    public static final String TRACK2_END_TAG = '&lt;/track2&gt;';
    public static final String PAYMENT_ASSIGNMENT_START_TAG = '&lt;payment-assignment&gt;';
    public static final String PAYMENT_ASSIGNMENT_END_TAG = '&lt;/payment-assignment&gt;';
    public static final String GENERIC_START_TAG = '&lt;generic&gt;';
    public static final String GENERIC_END_TAG = '&lt;/generic&gt;';

    public static final String CONTRACTOR_STATUS_PROBATION = 'Probation';
    public static final String CONTRACTOR_STATUS_PROVISIONAL = 'Provisional';
    public static final String NON_RESIDENTIAL_UTILITY_SECTOR = 'Non-Residential';
    public static final String RESIDENTIAL_UTILITY_SECTOR = 'Residential';

    public static final String RESIDENTIAL_EMAIL_CONFIG = 'Approved GJGNY Residential';
    public static final String NON_RESIDENTIAL_EMAIL_CONFIG = 'Approved GJGNY Non-Residential';

    public static final String BASE_INCENTIVE_SUB_TYPE = 'Base Incentive';
    public static final String AFFORDABLE_SOLAR_INCENTIVE_SUB_TYPE = 'Affordable Solar Incentive';

    public static final String BATTERY_STORAGE_INCENTIVE_SUB_TYPE = 'Battery Storage Incentive';
    public static final String ENERGY_EFFICIENCY_INCENTIVE_SUB_TYPE = 'Energy Efficiency Incentive';

    public static final String TYPE_PROJECT_APP = 'Project Application';

    public static final String TYPE_MODIFICATION_APP = 'Change Modification Application';

    public static final String TYPE_PROJECT_DELIVERABLE = 'Project Deliverable';

    public static final String SUB_TYPE_CON_APP = 'Signed Application';

    public static final String SUB_TYPE_SIGNED_INVOICE = 'Signed Invoice';
    public static final String SUB_TYPE_SIGNED_25_OR_100_INVOICE = 'Signed Invoice 25% or 100%';
    public static final String SUB_TYPE_SIGNED_75_INVOICE = 'Signed Invoice 75%';

    public static final String SUB_TYPE_REQUEST_EXTENSION_DOCUMENT = 'Request Extension Document';
    public static final String SUB_TYPE_CESIR_REQUEST_EXTENSION_DOCUMENT = 'CESIR Extension Request Document';


    public static final String SUB_TYPE_REQUEST_EXTENSION = 'Request for Extension';
    public static final String SUB_TYPE_CESIR_REQUEST_EXTENSION = 'CESIR Extension Request';

    public static final Set<String> NYPA_ELETRIC_UTILITY_COMPANY_SET = new Set<String> {'Central Hudson Gas & Electric - NYPA',
                                                                                        'Consolidated Edison - NYPA',
                                                                                        'National Grid - NYPA',
                                                                                        'New York State Electric and Gas - NYPA',
                                                                                        'Orange and Rockland - NYPA',
                                                                                        'PSEG - NYPA',
                                                                                        'Rochester Gas and Electric - NYPA'};

    public static final String RESIDENTIAL_PROJECT_SITE_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Residential_Small_Commercial';
    public static final String COMMERCIAL_PROJECT_SITE_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Commercial_Industrial';

    public static final String PROGRAM_APPLICATION_TYPE_NY_SUN_RESIDENTIAL = 'NY_Sun_Residential';
    public static final String PROGRAM_APPLICATION_TYPE_NY_SUN_COMMERCIAL = 'NY_Sun_Commercial';
    public static final Set<String> SET_OF_NYS_APPLICATION_TYPE_FOR_PROG_RELATIONSHIPS = new Set<String>{PROGRAM_APPLICATION_TYPE_NY_SUN_RESIDENTIAL,
                                                                                                         PROGRAM_APPLICATION_TYPE_NY_SUN_COMMERCIAL};
    public static final String NY_SUN_CONTRACTOR_PERMISSION_SET_API_NAME = 'NY_Sun_Contractor_Permissions'; // T-01401

    public static final Set<String> NY_SUN_RESIDENTIAL_SUBMITTED_STATUSES = new Set<String>{ Project_Helper.PROJECT_STATUS_SUBMITTED,
                                                                                             Project_Helper.PROJECT_STATUS_PENDINGAPPROVAL,
                                                                                             Project_Helper.PROJECT_STATUS_RECEIVED};

    public static final Map<String,String> NYS_PROJECT_TO_PROJ_DOC_RCD_TYPE_DEV_NAME_MAPPING =
                                    new Map<String, String>{RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME => 'NY_Sun_Residential',
                                                            COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME => 'NY_Sun_Commercial'};

    public static RecordType ResidentialProjectRecordType
    {
        get
        {
            if (ResidentialProjectRecordType == null)
                ResidentialProjectRecordType = Utility_RecordType_Helper.getRecordType('Project__c',RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME);
            return ResidentialProjectRecordType;
        }
        set;
    }

    public static RecordType CommercialProjectRecordType
    {
        get
        {
            if (CommercialProjectRecordType == null)
                CommercialProjectRecordType = Utility_RecordType_Helper.getRecordType('Project__c',COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME);
            return CommercialProjectRecordType;
        }
        set;
    }

    // check if project is in a status deemed as "submitted"
    public static boolean isSubmittedStatus(String status)
    {
        if (NYSUN_Utility_IncentiveBlock_Helper.statusesThatCount.contains(status))
            return true; 
        return false;
    }
  
  /*
  * Method Name: uncompletetabsAndRejectProjectDocuments
  * Description: Uncomplete tabs and Reject Project documents
  * @param: Set<Id> projects
  * @return: void                                                      
  */
    public static void uncompletetabsAndRejectProjectDocuments(Set<Id> projects)
    {
        if (projects.size() > 0)
        {
          Set<String> uncompleteTabs = new Set<String>();
          uncompleteTabs.add(WizardTemplate_Helper.PAGETYPE_COMPONENTS);
          uncompleteTabs.add(WizardTemplate_Helper.PAGETYPE_REVIEW);
          uncompleteTabs.add(WizardTemplate_Helper.PAGETYPE_DOCUMENTS);
          uncompleteTabs.add(WizardTemplate_Helper.PAGETYPE_FINANCIALS);
          uncompleteTabs.add(WizardTemplate_Helper.PAGETYPE_SUBMIT);
          WizardTemplate_Helper.uncompleteProjectTabs(projects,uncompleteTabs);

          Project_Content__c[] signedProjectContents = [SELECT Id,Document_Title__c,Project__c FROM Project_Content__c
                                                        WHERE Project__c IN :projects
                                                        AND Document_Title__c =:NYSUN_Helper.SIGNED_DOCUMENT_TITLE];
          if (signedProjectContents.size() > 0)
          {
             Project_Document__c[] signedProjectDocuments = [SELECT Id,Status__c,Project_Content__c FROM Project_Document__c
                                                             WHERE Project_Content__c IN :signedProjectContents];
            if (signedProjectDocuments.size() > 0)
            {
              for (Project_Document__c pd :signedProjectDocuments)
              {
                 pd.Status__c = DOCUMENT_STATUS_REJECT;
              }
              update signedProjectDocuments;
            }
           }
         }
     }
}