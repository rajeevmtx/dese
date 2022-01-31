/*
* Class Name:  ProjectRole_Helper
* Description: Helper class dealing with Project_Role__c records
* Author/Date:
*
*/

public class ProjectRole_Helper
{
    public static final String PROJECT_PROPOSER_ROLE = 'Proposer';
    public static final String PROJECT_CONTRACTOR_ROLE = 'Contractor';
    public static final String PROJECT_BUILDER_ROLE = 'Builder';
    public static final String PROJECT_CUSTOMER_ROLE = 'Customer';
    public static final String PROJECT_COORDINATOR_ROLE = 'Project Co-ordinator';
    public static final String PROJECT_MANAGER_ROLE = 'Project Manager';
    public static final String PROJECT_VENDOR_ROLE = 'Vendor';
    public static final String PROJECT_PAYEE_ROLE = 'Payee';
    public static final String PROJECT_EXTERNAL_IMPLEMENTATION_CONTRACTOR_ROLE = 'External Implementation Contractor';
    public static final String PROJECT_REPORTING_CONTACT_ROLE = 'Reporting Contact';
    public static final String PROJECT_IMPLEMENTATION_PARTNER_ROLE = 'Implementation Partner';
    public static final String PROJECT_SUB_CONTRACTOR_ROLE = 'Subcontractor';
    public static final String PRIMARY_CONTACT_MODIFICATION_ERROR_MSG = 'Primary contact of contractor only changed by primary contractor.';
    public static final String ROLE_PERMISSION_SIGNATORY = 'Read-Write-Upload Documents-Signatory';
    public static final String ROLE_PERMISSION_RWU = 'Read-Write-Upload Documents';
    public static final String ROLE_PERMISSION_READONLY = 'Read Only';
    public static final String ROLE_PERMISSION_NOACCESS = 'No Access';


    //public static final Set<Id> EXCLUDED_RECORDTYPE_ID_FOR_PROJ_COORDINATOR =  new Set<Id>{NYSUN_Helper.CommercialProjectRecordType.Id, NYSUN_Helper.ResidentialProjectRecordType.Id}; // We do not need to Project Coordinator role for NY Sun.

    public static final Set<String> CONST_VALID_ROLE_CONTRACTOR= new Set<String>{PROJECT_CONTRACTOR_ROLE};
    public static final Set<String> CONST_VALID_ROLES_BUILDER= new Set<String>{PROJECT_BUILDER_ROLE};
    public static final Set<String> CONST_VALID_ROLES_CUSTOMER= new Set<String>{PROJECT_CUSTOMER_ROLE};
    public static final Set<String> CONST_VALID_ROLES_PAYEE = new Set<String>{PROJECT_PAYEE_ROLE};
    // rahuls91221 - Merge field in "Notification On Project Cancellation" email template
    // value will be replaced with Primary Customer Name at run time.
    public static final String PROJECT_CANCELLATION_HOSTCUSTOMERFULLNAME = '{HostCustomerFullName}';

      /*
      * Method Name: defaultContractorRolesOnInsert
      * Description: Make to creating default Contractor Roles On Inserting records
      * @param: Project__c[] records
      * @return: static void
      */
    public static void defaultContractorRolesOnInsert(Project__c[] records)
    {
        Set<Id> programVersions = new Set<Id>();
        for (Project__c record :records)
        {
          /*  if (record.RecordTypeId == PS_Helper.PSRecordType.Id || record.RecordTypeId == NYSUN_Helper.CommercialProjectRecordType.Id || record.RecordTypeId == ZEV_Helper.ZeroEmissionVehiclesProjectRecordType.Id || record.RecordTypeId == CHP_Helper.CHPProjectRecordType.Id)
                programVersions.add(record.program_version__c);*/
        }
        if (programVersions.size() > 0)
        {
            Map<Id,Program_Version__c> programVersionMap = new Map<Id,Program_Version__c>([SELECT Id,Program__c
                                                                                            FROM Program_Version__c
                                                                                            WHERE Id IN :programVersions]);
            Map<Id,Program_Partnership__c> partnershipMap = new Map<Id,Program_Partnership__c>();
            for (Program_Partnership__c partnership :[SELECT Account__c,account__r.name,Program__c,
                                                         Default_Primary_Contact__c, Default_Primary_Contact__r.FirstName,
                                                         Default_Primary_Contact__r.LastName, Default_Primary_Contact__r.Phone,
                                                         Default_Primary_Contact__r.Email
                                                         FROM Program_Partnership__c
                                                         WHERE Program__c != null
                                                         AND account__c = :Utility_User_Helper.currentLoggedInUser.AccountId ])
            {
                partnershipMap.put(partnership.program__c,partnership);
            }
            Project_Role__c[] rolesToInsert = new Project_Role__c[]{};
            for (Project__c record :records)
            {
                if(programVersionMap.containsKey(record.program_version__c) && partnershipMap.containsKey(programVersionMap.get(record.program_version__c).program__c)) {
                    Program_Partnership__c partnership = partnershipMap.get(programVersionMap.get(record.program_version__c).program__c);
                    Project_Role__c pr = new Project_Role__c();
                    pr.account__c = partnership.account__c;
                    pr.role__c = PROJECT_CONTRACTOR_ROLE;
                    pr.project__c = record.Id;
                    pr.FirstName__c = partnership.Default_Primary_Contact__r.FirstName;
                    pr.LastName__c = partnership.Default_Primary_Contact__r.LastName;
                    pr.Phone__c = partnership.Default_Primary_Contact__r.Phone;
                    pr.Email__c = partnership.Default_Primary_Contact__r.Email;
                    pr.Company_Name__c = partnership.account__r.name;
                    pr.Contact__c = partnership.Default_Primary_Contact__c;
                    pr.Primary_Customer_Contact__c = true;
                    rolesToInsert.add(pr);
                }

            }
            if (rolesToInsert.size() > 0)
                insert rolesToInsert;
        }
    }
}