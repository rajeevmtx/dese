/*
* Class Name: PROPOSAL_CORE_Contact_Controller
* Description: Controller to handle the functionalities of PROPOSAL_CORE_Contact_Page
* Author/Date:  Tarun Khandelwal   1/14/2017
*
* Date         New/Modified      Author             Description
* 05/09/2017   Modified          Harshit Jain       T-02333
* 05/09/2017   Modified          Tarun Khandelwal   T-02335
* 06/05/2017   Modified          Ajay Gautam        T-02464 FIX - Read projects from project role using account/contact of the logged in user
* 06/30/2017   Modified          Ajay Gautam        T-02655 - Add exception for paper submission process
* 09/14/2017   Modified          Ajay Gautam        S-01055 - Multi round with concept paper and parallel activities
*
*/

public with sharing class PROPOSAL_CORE_Contact_Controller extends ProposalBase_Controller{

    public String selectedCustomerProjectRole {get; set;}
    public transient List<Project_Role__c> customerProjectRoleList{get; set;}
    public Project_Role__c customerProjectRole {get; set;}
    public Boolean isReadOnlyApplication {get; set;} // Obsolete
    public Boolean isPrimaryContactPresent {get; set;}
    public static final String CONST_NEW_YORK = 'New York';
    public static final Set<String> Role= new Set<String>();
    public String taxIdNumber {get; set;}
    public Boolean isSSN {get; set;}
    public List<SelectOption> companyTypeOptionList {get; set;}

    public List<String> listOfCompanyType {
        get{
            listOfCompanyType = new List<String>();
            if(String.isNotBlank(customerProjectRole.Company_Type__c)){
                for(String val : customerProjectRole.Company_Type__c.split(';')) {
                    listOfCompanyType.add(val);
                }
            }
            return listOfCompanyType;
        }

        set{
            /*customerProjectRole.Company_Type__c = '';
            for(String val : value){
                customerProjectRole.Company_Type__c += val + ';';
            }
            customerProjectRole.Company_Type__c.removeEnd(';');*/
        }
    }

    public PROPOSAL_CORE_Contact_Controller() {
        customerProjectRoleList = new List<Project_Role__c>();
        isPrimaryContactPresent = false;
        Role.add('Project Co-ordinator');
        if(project.Program_Version__r.NY_Green_Bank_RFP__c) {
            setCompanyTypeOptionList();
        }
        customerProjectRole = new Project_Role__c();

        getCustomerProjectRoleList();
        checkForPrimaryContact();
    }

     /*
    * Method Name: getCustomerProjectRoleList
    * Description: get all the project roles of customer in List
    * @param: None
    * @return: void
    */

    private void getCustomerProjectRoleList() {
        String query = 'SELECT ';
        for(String fieldName : getProjectRoleFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Project_Role__c WHERE Project__c = \'' + CORE_Helper.doEscapeSingleQuotes(projectId) + '\' AND Role__c NOT IN :Role ORDER BY Primary_Customer_Contact__c DESC';

        customerProjectRoleList = Database.query(query);
    }

    /*
    * Method Name: checkForPrimaryContact
    * Description: check if the contact is primary or not
    * @param: None
    * @return: void
    */

    private void checkForPrimaryContact() {
        for(Project_Role__c projectRoleRec : customerProjectRoleList) {
            if(projectRoleRec.Primary_Customer_Contact__c) {
                isPrimaryContactPresent = true;
                break;
            }
        }
    }

    /*
    * Method Name: resetCustomerProjectRole
    * Description: Reset the customer roles
    * @param: None
    * @return: Pagereference
    */

    public Pagereference resetCustomerProjectRole() {
        customerProjectRole = new Project_Role__c(State__c = CONST_NEW_YORK);
        customerProjectRole.Project__c = projectId;
        selectedCustomerProjectRole = null;
        customerProjectRole.Primary_Customer_Contact__c = isPrimaryContactPresent ? false : true;
        customerProjectRole.Company_Type__c = null;
        return null;
    }

    public List<String> listOfSelectedCompanyType{
        get{
            listOfSelectedCompanyType = new List<String>();

            if(String.isNotBlank(customerProjectRole.Company_Type__c)){
                for(String val : customerProjectRole.Company_Type__c.split(';')) {
                    listOfSelectedCompanyType.add(val);
                }
            }
            return listOfSelectedCompanyType;
        }

        set{
            customerProjectRole.Company_Type__c = '';
            for(String val : value){
                customerProjectRole.Company_Type__c += val + '; ';
            }
            customerProjectRole.Company_Type__c.removeEnd('; ');
        }
    }

    /*
    * Method Name: saveCustomerProjectRole
    * Description: Insert or Update the project Role
    * @param: None
    * @return: Pagereference
    */

    public Pagereference saveCustomerProjectRole() {
        Id accountId = null;

        if(customerProjectRole.Id == null) {
          customerProjectRole.Project__c = projectId;

          // T-02464 - Change intermediary page listing based on logged in user account instead of createdby
          for(User user : [SELECT ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()]){
              accountId = (user.ContactId != null) ? user.Contact.AccountId : null;
          }
          customerProjectRole.Account__c = accountId;
          // T-02464 - These roles will populate Account__c on the basis of logged in user's account

        }
        if(String.isNotBlank(taxIdNumber)) {
            customerProjectRole.Tax_Identification_Type__c = taxIdNumber;
        }
        if(customerProjectRole.Tax_Identification_Type__c == 'SSN') {
            customerProjectRole.Employee_Identification_Number_EIN__c = null;
        }
        customerProjectRole.Role__c = 'Proposer';

        Pagereference pg;
        if(!checkForDueDate() || isExceptionalAccessProvided) { // T-02655
            upsert customerProjectRole;
            pg = new PageReference('/apex/PROPOSAL_CORE_Contact_Page?ProjectId=' + projectId);
            pg.setRedirect(true);
        } else {
            isDueDatePassed = true;
            pg = null;
        }
        return pg;
    }

    /*
    * Method Name: deleteCustomerProjectRole
    * Description: delete the selected project Role
    * @param: None
    * @return: Pagereference
    */

    public Pagereference deleteCustomerProjectRole() {
        try {
            delete new Project_Role__c(Id = selectedCustomerProjectRole);
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
        }
        Pagereference pg = new PageReference('/apex/PROPOSAL_CORE_Contact_Page?ProjectId=' + projectId);
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: cloneProjectRole
    * Description: clone the selected project Role
    * @param: None
    * @return: Pagereference
    */

    public PageReference cloneProjectRole() {
        getCustomerProjectRole();
        selectedCustomerProjectRole = null;
        customerProjectRole.Role__c = '';
        customerProjectRole.Id = null;
        customerProjectRole.Account__c = null;
        customerProjectRole.Contact__c = null;
        return null;
    }

    /*
    * Method Name: getCustomerProjectRole
    * Description: get the project roles of customer
    * @param: None
    * @return: Pagereference
    */
    public PageReference getCustomerProjectRole() {
        String query = 'SELECT ';
        for(String fieldName : getProjectRoleFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Project_Role__c WHERE Id = \'' + CORE_Helper.doEscapeSingleQuotes(selectedCustomerProjectRole) + '\' ';

        List<Project_Role__c> projectRoleList = Database.query(query);
        if(projectRoleList.size() > 0) {
            customerProjectRole = projectRoleList[0];
            if(customerProjectRole.Tax_Identification_Type__c == 'SSN') {
                isSSN = true;
            } else {
                isSSN = false;
            }
        }
        return null;
    }

    /*
    * Method Name: setCompanyTypeOptionList
    * Description: get picklist values of Company Type
    * @param:None
    * @return: void
    */
    private void setCompanyTypeOptionList() {
        companyTypeOptionList = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDsc = Project_Role__c.Company_Type__c.getDescribe();
        List<Schema.PickListEntry> fieldDscPickVal = fieldDsc.getPickListValues();
        for(Schema.PickListEntry pickListOption : fieldDscPickVal){
            companyTypeOptionList.add(new SelectOption(pickListOption.getLabel(), pickListOption.getValue()));
        }
    }

    /*
    * Method Name: getProjectRoleFieldList
    * Description: get fields list of project role
    * @param:None
    * @return: List<String>
    */

    private List<String> getProjectRoleFieldList(){
        List<String> fieldList = new List<String>{  'Id',
                                                    'Account__c',
                                                    'Contact__c',
                                                    'Name',
                                                    'FirstName__c',
                                                    'LastName__c',
                                                    'Address_1__c',
                                                    'Address_2__c',
                                                    'City__c',
                                                    'zip__c',
                                                    'County__c',
                                                    'State__c',
                                                    'Email__c',
                                                    'Phone__c',
                                                    'Project__c',
                                                    'Role__c',
                                                    'Primary_Customer_Contact__c',
                                                    'Company_Name__c',
                                                    'Company_Type__c',
                                                    'Company_Website__c',
                                                    'Title__c',
                                                    'Company_TIN_Confirmation__c',
                                                    'Tax_Identification_Type__c',
                                                    'Employee_Identification_Number_EIN__c',
                                                    'DUNS_Number__c',
                                                    'Alternate_Party__c',
            										'Preferred_method_of_communication__c'
                                                };
        return fieldList;
    }
}