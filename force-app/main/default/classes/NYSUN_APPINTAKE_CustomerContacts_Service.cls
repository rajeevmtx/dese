/*
*   Class Name: NYSUN_APPINTAKE_CustomerContacts_Service
*   Description: Customer Contacts Service of NYSUN_AppIntake
*
*   Author/Date: Harshit Jain/ 02/12/2016
*  
*                                                             
*/
public without sharing class NYSUN_APPINTAKE_CustomerContacts_Service{
    
    private static final Set<String> RTEM_EXPOSED_ROLES = new Set<String>{'Contractor', 'Builder', 'Customer', 'Payee'};
    private static final String PAYEE = 'Payee';
    
    /*
  * Method Name: getCustomerProjectRoleList
  * Description: get List of Project_Role__c on the basis of projectId
  * @param: String projectId
  * @return: List<Project_Role__c>                                                       
  */ 
    public static List<Project_Role__c> getCustomerProjectRoleList(String projectId) {
        String query = 'SELECT ';
        for(String fieldName : getProjectRoleFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Project_Role__c WHERE Project__c = \'' + CORE_Helper.doEscapeSingleQuotes(projectId) + '\' AND Role__c IN : RTEM_EXPOSED_ROLES ORDER BY CreatedDate DESC';
        
        List<Project_Role__c> customerProjectRoleList = Database.query(query);
      
        return customerProjectRoleList;
    }
    /*
  * Method Name: getCustomerCaseRoleList
  * Description: get List of Case_Role__c on the basis of CaseId
  * @param: String caseId
  * @return: List<Case_Role__c>                                                       
  */   
    public static List<Case_Role__c> getCustomerCaseRoleList(String caseId) {
        String query = 'SELECT Project_Role__c, ';
        for(String fieldName : getProjectRoleFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Case_Role__c WHERE Case__c = \'' + CORE_Helper.doEscapeSingleQuotes(caseId) + '\' AND Role__c IN : RTEM_EXPOSED_ROLES ORDER BY CreatedDate DESC';
        
        List<Case_Role__c> customerCaseRoleList = Database.query(query);
        return customerCaseRoleList;
    }
    /*
  * Method Name: getPayeeCustomerProjectRole
  * Description: get List of Project_Role__c on the basis of projectId
  * @param: String projectId
  * @return: List<Project_Role__c>                                                       
  */   
    public static List<Project_Role__c> getPayeeCustomerProjectRole(String projectId) {
      
        return [SELECT Id FROM Project_Role__c WHERE Project__c =: projectId AND Role__c =: PAYEE];
    }
    /*
  * Method Name: getPayeeCustomerProjectRole
  * Description: get List of Case_Role__c on the basis of caseId
  * @param: String caseId
  * @return: List<Case_Role__c>                                                       
  */
    public static List<Case_Role__c> getPayeeCustomerCaseRoleList(String caseId) {
      
        return [SELECT Id FROM Case_Role__c WHERE Case__c =: caseId AND Role__c =: PAYEE];
    }
    /*
  * Method Name: deleteCustomerProjectRole
  * Description: delete project role and redirect to NYSUN_APPINTAKE_Contacts_Page
  * @param: String customerProjectRoleId
  * @param: String projectId
  * @return: Pagereference                                                       
  */
    public static Pagereference deleteCustomerProjectRole(String customerProjectRoleId, String projectId) {
        try {
            delete new Project_Role__c(Id = customerProjectRoleId);
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
        }
        
        Pagereference pg = new PageReference('/apex/NYSUN_APPINTAKE_Contacts_Page?ProjectId=' + projectId);
        pg.setRedirect(true);
        return pg;
    }
    /*
  * Method Name: deleteCustomerCaseRole
  * Description: Delete case role and redirect to NYSUN_CHANGEMOD_Contacts_Page
  * @param: String customerCaseRoleId
  * @param: String caseId
  * @param: String projectId
  * @return: Pagereference                                                       
  */
    public static Pagereference deleteCustomerCaseRole(String customerCaseRoleId, String caseId, String projectId) {
        try {
            delete new Case_Role__c(Id = customerCaseRoleId);
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
        }
        
        Pagereference pg = new PageReference('/apex/NYSUN_CHANGEMOD_Contacts_Page?ProjectId=' + projectId + '&caseId=' + caseId);
        pg.setRedirect(true);
        return pg;
    }
    /*
  * Method Name: getCustomerProjectRole
  * Description: retrieve project role on the basis of customerId 
  * @param: String customerId
  * @return: Project_Role__c                                                       
  */
    public static Project_Role__c getCustomerProjectRole(String customerId) {
        String query = 'SELECT ';
        for(String fieldName : getProjectRoleFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Project_Role__c WHERE Id = \'' + CORE_Helper.doEscapeSingleQuotes(customerId) + '\' ';
        
        List<Project_Role__c> customerProjectRoleList = Database.query(query);
        Project_Role__c customerProjectRole = new Project_Role__c();
        if(customerProjectRoleList.size() > 0) {
            customerProjectRole = customerProjectRoleList[0];
        }
        return customerProjectRole;
    }
    /*
  * Method Name: getCustomerCaseRole
  * Description: retrieve case role on the basis of customerId 
  * @param: String customerId
  * @return: Case_Role__c                                                       
  */
    public static Case_Role__c getCustomerCaseRole(String customerId) {
        String query = 'SELECT Project_Role__c, ';
        for(String fieldName : getProjectRoleFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Case_Role__c WHERE Id = \'' + CORE_Helper.doEscapeSingleQuotes(customerId) + '\' ';
        
        List<Case_Role__c> customerCaseRoleList = Database.query(query);
        Case_Role__c customerCaseRole = new Case_Role__c();
        if(customerCaseRoleList.size() > 0) {
            customerCaseRole = customerCaseRoleList[0];
        }
        return customerCaseRole;
    }
    /*
  * Method Name: saveCustomerProjectRole
  * Description: upsert customerProjectRole and redirects to NYSUN_APPINTAKE_Contacts_Page 
  * @param: Project_Role__c customerProjectRole
  * @param: String projectId
  * @param: String selectedContactId
  * @return: Pagereference                                                       
  */
    public static Pagereference saveCustomerProjectRole(Project_Role__c customerProjectRole, String projectId, String selectedContactId){
        List<Contact> conList = [select AccountId from Contact Where Id =: selectedContactId];
        String accountId;
        if(conList.size() > 0) {
            accountId = conList[0].AccountId;
        }
        
        try {
            if(customerProjectRole.Id == null) {
                customerProjectRole.Project__c = projectId;
                if(customerProjectRole.Role__c == null){
                    customerProjectRole.Role__c = NYSUN_Helper.PROJECT_ROLE_CUSTOMER;
                }
                if(customerProjectRole.Role__c == NYSUN_Helper.PROJECT_ROLE_PAYEE) {
                    customerProjectRole.Primary_Customer_Contact__c = true;
                }
                if(selectedContactId != null && selectedContactId != ''){
                    customerProjectRole.Contact__c = selectedContactId;
                }
                customerProjectRole.Account__c = accountId;
            }
            
            boolean isCustomer = false;
            String oldEnvelopeId;
            
            for(Project__c pro : [SELECT Program_Version__r.Docusign_Signatory__c, EnvelopeId__c FROM Project__c WHERE Id =: projectId]){
                if(pro.Program_Version__r.Docusign_Signatory__c == NYSUN_Helper.PROJECT_ROLE_CUSTOMER){
                    isCustomer = true;
                } 
                
                oldEnvelopeId = pro.EnvelopeId__c;
            } 
            
            if(isCustomer){
                boolean resignRequired = false;
                for(Project_Role__c customer : [SELECT Id, FirstName__c, LastName__c, Email__c, Primary_Customer_Contact__c,
                                                                Phone__c, Company_Name__c, Role__c FROM Project_Role__c
                                                                WHERE Primary_Customer_Contact__c =: true
                                                                AND Project__c =: projectId
                                                                ORDER BY CreatedDate DESC limit 1]) {
                    
                    if(customerProjectRole.Id == customer.Id || customerProjectRole.Primary_Customer_Contact__c){
                        if(customer.FirstName__c != customerProjectRole.FirstName__c){
                            resignRequired = true;
                        }
                        
                        if(customer.LastName__c != customerProjectRole.LastName__c){
                            resignRequired = true;
                        }
                        
                        if(customer.Email__c != customerProjectRole.Email__c){
                            resignRequired = true;
                        }
                        
                        if(customer.Phone__c != customerProjectRole.Phone__c){
                            resignRequired = true;
                        }
                        
                        if(customer.Company_Name__c != customerProjectRole.Company_Name__c){
                            resignRequired = true;
                        }
                        
                        if(customerProjectRole.Id != null && customerProjectRole.Id == customer.Id &&
                           customerProjectRole.Primary_Customer_Contact__c != customer.Primary_Customer_Contact__c){
                            
                            resignRequired = true; 
                        }
                    }
                }
                
                if(resignRequired){
                    //NYSUN_APPINTAKE_Controller.setResignApplication(projectId, oldEnvelopeId);
                } 
            }
            upsert customerProjectRole;
            
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));      
        }
        
        Pagereference pg = new PageReference('/apex/NYSUN_APPINTAKE_Contacts_Page?ProjectId=' + projectId);
        pg.setRedirect(true);
        return pg;
    }
    
    /*
  * Method Name: saveCustomerCaseRole
  * Description: upsert customerCaseRole and redirects to NYSUN_CHANGEMOD_Contacts_Page 
  * @param: Case_Role__c customerCaseRole
  * @param: String caseId
  * @param: String selectedContactId
  * @param: String projectId
  * @return: Pagereference                                                       
  */
    public static Pagereference saveCustomerCaseRole(Case_Role__c customerCaseRole, String caseId, String selectedContactId, String projectId){
        List<Contact> conList = [select AccountId from Contact Where Id =: selectedContactId];
        String accountId;
        if(conList.size() > 0) {
            accountId = conList[0].AccountId;
        }
        
        try {
            if(customerCaseRole.Id == null) {
                customerCaseRole.Case__c = caseId;
                if(customerCaseRole.Role__c == null){
                    customerCaseRole.Role__c = NYSUN_Helper.PROJECT_ROLE_CUSTOMER;
                }
                if(selectedContactId != null && selectedContactId != ''){
                    customerCaseRole.Contact__c = selectedContactId;
                }
                customerCaseRole.Account__c = accountId;
            }
            
            boolean isCustomer = false;
            for(Project__c pro : [SELECT Program_Version__r.Docusign_Signatory__c FROM Project__c WHERE Id =: projectId]){
                if(pro.Program_Version__r.Docusign_Signatory__c == NYSUN_Helper.PROJECT_ROLE_CUSTOMER){
                    isCustomer = true;
                }
            }
            
            if(isCustomer){
                boolean resignRequired = false;
                for(Case_Role__c customer : [SELECT Id, FirstName__c, LastName__c, Email__c, Primary_Customer_Contact__c,
                                                                Phone__c, Company_Name__c, Role__c FROM Case_Role__c
                                                                WHERE Primary_Customer_Contact__c =: true
                                                                AND Case__c =: caseId
                                                                ORDER BY CreatedDate DESC limit 1]) {
                    
                    if(customerCaseRole.Id == customer.Id || customerCaseRole.Primary_Customer_Contact__c){
                        if(customer.FirstName__c != customerCaseRole.FirstName__c){
                            resignRequired = true;
                        }
                        
                        if(customer.LastName__c != customerCaseRole.LastName__c){
                            resignRequired = true;
                        }
                        
                        if(customer.Email__c != customerCaseRole.Email__c){
                            resignRequired = true;
                        }
                        
                        if(customer.Phone__c != customerCaseRole.Phone__c){
                            resignRequired = true;
                        }
                        
                        if(customer.Company_Name__c != customerCaseRole.Company_Name__c){
                            resignRequired = true;
                        }
                        
                        if(customerCaseRole.Id != null && customerCaseRole.Id == customer.Id &&
                                customerCaseRole.Primary_Customer_Contact__c != customer.Primary_Customer_Contact__c){
                            resignRequired = true; 
                        }
                    }
                }
                
                if(resignRequired){
                    //NYSUN_CHANGEMOD_Controller.setResignApplication(projectId);
                } 
            }
            upsert customerCaseRole;
            
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));      
        }
        
        Pagereference pg = new PageReference('/apex/NYSUN_CHANGEMOD_Contacts_Page?ProjectId=' + projectId + '&CaseId=' + caseId);
        pg.setRedirect(true);
        return pg;
    }
    /*
  * Method Name: getProjectRoleFieldList
  * Description: returns name of fields 
  * @param: null 
  * @return: List<String>                                                       
  */
    public static List<String> getProjectRoleFieldList(){
        List<String> fieldList = new List<String>{  'Id', 
                                                    'Account__c',
                                                    'Contact__c',
                                                    'Contact__r.Id',
                                                    'Name',
                                                    'FirstName__c',
                                                    'LastName__c',
                                                    'Email__c',
                                                    'Phone__c',
                                                    'Project__c',
                                                    'Role__c',
                                                    'Primary_Customer_Contact__c',
                                                    'Contact_Type__c',
                                                    'Company_Name__c',
                                                    'Title__c',
                                                    'Extension__c'
                                                };
        return fieldList;
    }
}