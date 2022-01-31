/*
*   Class Name: NYSUN_APPINTAKE_Contractor_Service
*   Description: Contractor Service of NYSUN_AppIntake
*
*   Author/Date: Harshit Jain/ 02/12/2016
*  
*                                                             
*/
public with sharing class NYSUN_APPINTAKE_Contractor_Service{
  /*
  public static Contact loadContractor(String projectId) {
        List<Project_Role__c> projectRoleList = [select Email__c, Phone__c, Contact__c, Contact__r.FirstName, Contact__r.LastName from Project_Role__c 
                                                    Where Project__c =: projectId AND (Role__c = 'Builder')];
        Contact conRec = new Contact();
        if(projectRoleList.size() == 0) { 
            return conRec;
        }
        
        Project_Role__c projectRole = projectRoleList[0];
        conRec.FirstName = projectRole.Contact__r.FirstName;
        conRec.LastName = projectRole.Contact__r.LastName;
        conRec.Email = projectRole.Email__c;
        conRec.Phone = projectRole.Phone__c;
        conRec.Id = projectRole.Contact__c;
        conRec.AccountId = projectRole.Id;
        return conRec;
    }
    */
    
    /*
  * Method Name: loadAppIntakeContractor
  * Description: get List of Project_Role__c on the basis of projectId and Role__c = 'Contractor' and create contact
  * @param: String projectId
  * @return: Contact                                                       
  */
    public static Contact loadAppIntakeContractor(String projectId) {
        List<Project_Role__c> projectRoleList = [select Email__c, Phone__c, Contact__c, Contact__r.FirstName, Contact__r.LastName from Project_Role__c 
                                                    Where Project__c =: projectId AND (Role__c = 'Contractor')];
        Contact conRec = new Contact();
        if(projectRoleList.size() == 0) {
            return conRec;
        }
        
        Project_Role__c projectRole = projectRoleList[0];
        conRec.FirstName = projectRole.Contact__r.FirstName;
        conRec.LastName = projectRole.Contact__r.LastName;
        conRec.Email = projectRole.Email__c;
        conRec.Phone = projectRole.Phone__c;
        conRec.Id = projectRole.Contact__c;
        conRec.AccountId = projectRole.Id;
        return conRec;
    }
  /*
  * Method Name: saveContact
  * Description: passing params to contact fields
  * @param: String contactName
  * @param: String contactEmail
  * @param: String contactPhone
  * @param: String contactId
  * @return: String                                                       
  */
    public static String saveContact(String contactName, String contactEmail, String contactPhone, String contactId) {
        Contact conRec = new Contact();
        //system.assert(false, contactId);
        if(contactId != null && contactId != '') {
            conRec.Id = contactId;
        }
        if(contactName != null && contactName.contains(' ')) {
            conRec.FirstName = contactName.split(' ')[0];
            conRec.LastName = contactName.substringAfter(' ');
        } else {
            conRec.LastName = contactName;
        }
        conRec.Email = contactEmail;
        conRec.Phone = contactPhone;
        
        if(conRec.LastName != null) {
            upsert conRec;
        }
        return conRec.Id; 
    }
    
    /*
  * Method Name: saveContractor
  * Description: upsert project role on the basis on contact
  * @param: String contractorContactId
  * @param: String projectId
  * @param: String projectRoleId
  * @return: null                                                       
  */
    public static void saveContractor(String contractorContactId, String projectId, String projectRoleId) {
        List<Contact> conList = [select Email, Phone, AccountId from Contact Where Id =: contractorContactId];
        String accountId;
        if(conList.size() > 0) {
            accountId = conList[0].AccountId;
        }
        
        Project_Role__c projectRole = new Project_Role__c();
        if(projectRoleId != null) {
            projectRole.Id = projectRoleId;
        } else {
            projectRole.Project__c = projectId;
            //projectRole.Name = 'Project Role - ' + String.valueOf(System.Today());
            projectRole.Role__c = 'Builder';
        }
        //RecordType commercialRTEM = Utility_RecordType_Helper.getRecordType('Project__c', RTEM_Helper.COMMERCIAL_RTEM_PROJECT_RECORD_TYPE_DEVELOPER_NAME);
        /*for(Project__c project : [SELECT Id FROM Project__c WHERE Id =: projectId 
                                  AND RecordTypeId =: commercialRTEM.Id]){
            
            projectRole.Role__c = 'System Provider';
        }*/
        
        projectRole.Contact__c = contractorContactId;
        projectRole.Account__c = accountId;
        if(conList.size() > 0) {
          projectRole.Email__c = conList[0].Email;
          projectRole.Phone__c = conList[0].Phone;
        }
        upsert projectRole; 
    }
    
    
}