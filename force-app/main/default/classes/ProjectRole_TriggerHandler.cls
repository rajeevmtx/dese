/*
* Class Name: ProjectRole_TriggerHandler
* Description: Handler class for the Project Role trigger.  Shares projects with appropriate contractors
* Author/Date:  
*
*/

public without sharing class ProjectRole_TriggerHandler {

    // @@ Nik/Ajay
    public static Set<Id> EXCLUDED_PROJECT_RECORDTYPES = new Set<Id>{
        (     Utility_RecordType_Helper.getRecordType('Project__c', 'Communities_Local_Government_Clean_Energy_Community') != null ?
         Utility_RecordType_Helper.getRecordType('Project__c', 'Communities_Local_Government_Clean_Energy_Community').Id :
         null
        )};

    public static Boolean isTriggerExecute = false;

    /*
    * Name : beforeInsert
    * Description : method to process functionalities on before insert
    * @param : Project_Role__c[] newList
    * @return : void
    */
    public static void beforeInsert(Project_Role__c[] newList) {
        populateProjectRoleField(newlIst, null);
    }

    /*
    * Name : beforeUpdate
    * Description : method to process functionalities on before update
    * @param : Project_Role__c[] newList
    * @param : Map<Id,Project_Role__c> oldMap
    * @return : void
    */
    public static void beforeUpdate(Project_Role__c[] newList, Map<Id,Project_Role__c> oldMap) {
        populateProjectRoleField(newlIst, oldMap);
        if(!isExecutedPrimaryChanges){
            restrictPrimaryChanges(newlIst, oldMap);
            isExecutedPrimaryChanges= true;
        }

    }

    /*
    * Name : afterInsert
    * Description : method to process functionalities on after Insert
    * @param : Project_Role__c[] newList
    * @return : void
    */
    public static void afterInsert(Project_Role__c[] newList) {
        ProjectSharing_Helper.shareProjectRecords(newList, null, null);
        resetPrimaryContact(newList);
        populateProjectField(newList, null);
        setPaymentAssignment(newList, null);
        createContactAndAccount(newList);
        sendApprovalCollaborateNotification(newList);
        primaryContactChangedRoles(newList);
        sendProjectRoleNotifications(newList, null);

        updateProjectName(trigger.new, false); // MOVED from trigger statements to here

    }

    /*
    * Name : afterUpdate
    * Description : method to process functionalities on after Update
    * @param : Project_Role__c[] newList
    * @param : Map<Id,Project_Role__c> newMap
    * @param : Map<Id,Project_Role__c> oldMap
    * @return : void
    */
    public static void afterUpdate(Project_Role__c[] newList, Map<Id,Project_Role__c> newMap, Map<Id,Project_Role__c> oldMap)
    {
        ProjectSharing_Helper.shareProjectRecords(newList,oldMap,null);
        resetPrimaryContact(newList);
        populateProjectField(newList,oldMap);
        setPaymentAssignment(newList,oldMap);
        primaryContactChangedRoles(newMap,oldMap);
        sendProjectRoleNotifications(newList, oldMap);

        updateProjectName(trigger.new, false); // MOVED from trigger statements to here

    }

  /*
  * Name : beforeDelete
  * Description : method to process functionalities on before Delete
  * @param : Project_Role__c[] oldList
  * @return : void
  */

    public static void beforeDelete(Project_Role__c[] oldList)
    {
        beforeDeleteOperation(oldList);
    }

  /*
  * Name : afterDelete
  * Description : method to process functionalities on after Delete
  * @param : Project_Role__c[] oldList
  * @return : void
  */
    public static void afterDelete(Project_Role__c[] oldList)
    {
        ProjectSharing_Helper.shareProjectRecords(null,null,oldList);

        updateProjectName(trigger.old, true);  // MOVED from trigger statements to here

    }

  /*
  * Name : afterUndelete
  * Description : method to process functionalities on after Undelete
  * @param : Project_Role__c[] newList
  * @return : void
  */
    public static void afterUndelete(Project_Role__c[] newList)
    {
        ProjectSharing_Helper.shareProjectRecords(newList,null,null);
    }

    /*
  * Name : primaryContactChangedRoles
  * Description : method to Change primary  Contact Roles
  * @param : List<Project_Role__c> roles
  * @return : void
  */
    public static void primaryContactChangedRoles( List<Project_Role__c> roles){
        Map<Id,Project_Role__c> roleMap = new Map<Id,Project_Role__c>();
        for(Project_Role__c role : roles){
            if(role.Primary_Customer_Contact__c ){
                roleMap.put(role.Id,role);
            }
        }
        validatePrimaryContact(roleMap);
    }

    /*
  * Name : primaryContactChangedRoles
  * Description : method to Change primary Contact Roles
  * @param : Map<Id,Project_Role__c> newMap
  * @param : Map<Id,Project_Role__c> oldMap
  * @return : void
  */
    public static void primaryContactChangedRoles( Map<Id,Project_Role__c> newMap, Map<Id,Project_Role__c> oldMap){
        Map<Id,Project_Role__c> roleMap = new Map<Id,Project_Role__c>();
        for(Project_Role__c role : newMap.values()){
            if((role.Primary_Customer_Contact__c != oldMap.get(role.Id).Primary_Customer_Contact__c) && role.Primary_Customer_Contact__c ){
                roleMap.put(role.Id,role);
            }
        }
        validatePrimaryContact(roleMap);
    }

    private static Boolean isExecutedPrimaryChanges = false;

    /*
  * Name : restrictPrimaryChanges
  * Description : method to restrict Primary Changes
  * @param : Project_Role__c[] newList
  * @param : Map<Id,Project_Role__c> oldMap
  * @return : void
  */
	public static final String CECProjectRecordType = 'Communities_Local_Government_Clean_Energy_Community';
	public static final String PROFILE_PORTAL_USER_BY_LOGIN = 'Portal User by Login';
    public static void restrictPrimaryChanges(Project_Role__c[] newList, Map<Id,Project_Role__c> oldMap){
        Map<Id,Project_Role__c> roleMap = new Map<Id,Project_Role__c>();
        Set<Id> projectIds = new set<Id>();
        System.debug('working 1-->');
        for(Project_Role__c role : newList){
            // need to consider only those project role in which primary contact or primary contractor changed
            System.debug('--role.Primary_Customer_Contact__c--> '+role.Primary_Customer_Contact__c);
            System.debug('--old.Primary_Customer_Contact__c--> '+oldMap.get(role.Id).Primary_Customer_Contact__c);
            System.debug('--role.Role__c -> '+role.Role__c);
            System.debug('--contractor Role__c -> '+ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE );
            if((role.Primary_Customer_Contact__c != oldMap.get(role.Id).Primary_Customer_Contact__c)  && role.Role__c == ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE ){
                roleMap.put(role.Id,role);
                projectIds.add(role.Project__c);
            }
        }
        System.debug('-- projectIds --> '+projectIds);
        set<Id> cecProjectIds = new set<Id>();
        Map<Id,Id> projectRoleMap = new  Map<Id,Id>();
        if(projectIds.size()>0){
            Map<Id,Id> roleContactMap = new Map<Id,Id>();
            for(Project__c project : [Select id,(Select id,Contact__c from Project_Roles__r where Primary_Customer_Contact__c = true AND Role__c =: ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE ), RecordType.Name from Project__c where ID IN : projectIds ]){
                if(project.RecordType.Name == CECProjectRecordType){
                    cecProjectIds.add(project.Id);
                    if(project.Project_Roles__r.size()>0 && project.Project_Roles__r[0].Contact__c!=null ){
                        projectRoleMap.put(project.Id, project.Project_Roles__r[0].Contact__c);
                        roleContactMap.put(project.Project_Roles__r[0].Contact__c, project.Project_Roles__r[0].Id);
                    }
                }
            }
            System.debug('-- cecProjectIds --> '+cecProjectIds);
            // Map<Id,Id> roleContactMap = new Map<Id,Id>();
            /*for(Project_Role__c role : roleMap.values()){
roleContactMap.put(role.Contact__c,role.Id);
}*/
            System.debug('-- roleContactMap --> '+roleContactMap);
            System.debug('projectRoleMap--> '+projectRoleMap);
            Map<Id,User> contactUserIdMap = new Map<Id,User>();
            User currentUser;
            if(roleContactMap.keyset().size()>0){
                Set<Id> userIds = new Set<Id>();
                userIds.addAll(roleContactMap.keyset());
                //userIds.add(userInfo.getUserId());
                System.debug('--userIds--> '+userIds);
                for(User user : [Select id, profile.Name, contactId from User where contactId IN : userIds OR Id =:userInfo.getUserId()]){
                    if(user.ContactId != null)
                        contactUserIdMap.put(user.contactId, user);
                    contactUserIdMap.put(user.Id, user);
                    System.debug('-user->'+user);

                }
                System.debug('-- contactUserIdMap --> '+contactUserIdMap);
                for(Project_Role__c role : roleMap.values()){
                    if(cecProjectIds.contains(role.Project__c)) {
                        System.debug('--projectRoleMap.get(role.Project__c)--> '+projectRoleMap.get(role.Project__c));
                        User user = contactUserIdMap.get(projectRoleMap.get(role.Project__c));
                        System.debug('-- user --> '+user);
                        //System.debug('--user.Profile.Name--> '+user.Profile.Name);
                        System.debug('--Profile_Helper.PROFILE_PORTAL_USER_BY_LOGIN-->'+PROFILE_PORTAL_USER_BY_LOGIN);
                        if(user!=null &&  user.Id != UserInfo.getUserId() && contactUserIdMap.get(UserInfo.getUserId()).profile.Name == PROFILE_PORTAL_USER_BY_LOGIN){ //this error only for portal user login
                            system.debug('-- error --> '+user.Id );
                            role.addError(ProjectRole_Helper.PRIMARY_CONTACT_MODIFICATION_ERROR_MSG);
                        }
                    }
                }
            }
        }
    } 

  /*
  * Name : validatePrimaryContact
  * Description : method to validate Primary Contact
  * @param : Map<Id, Project_Role__c> projectRoleMap
  * @return : void
  */
    public static void validatePrimaryContact(Map<Id, Project_Role__c> projectRoleMap){
        Map<String, String> projectRoleTypeMap  = new Map<String, String>();
        for(Project_Role__c role : projectRoleMap.values()) {
            if(role.Primary_Customer_Contact__c)
                projectRoleTypeMap.put(role.Project__c, role.Account__c);
        }
        Map<String, Map<String,List<Project_Role__c>>> roleMap = new Map<String, Map<String,List<Project_Role__c>>> ();
        if(projectRoleTypeMap.keySet().size()>0){
            for(Project_Role__c role : [Select id, Role__c, Account__c, Primary_Customer_Contact__c, Project__c,Project__r.RecordType.Name from Project_Role__c where Project__c IN : projectRoleTypeMap.keySet() and Account__c IN : projectRoleTypeMap.values() ]){
                if(role.Project__r.RecordType.Name == CECProjectRecordType){
                    if(roleMap.containsKey(role.Project__c)){
                        Map<String,List<Project_Role__c>> roleTempMap = roleMap.get(role.Project__c);
                        if(roleTempMap.containsKey(role.Account__c))
                            roleTempMap.get(role.Account__c).add(role);
                        else
                            roleTempMap.put(role.Account__c, new List<Project_Role__c>{role});

                    }else{ 
                        roleMap.put(role.Project__c, new Map<String,List<Project_Role__c>>{role.Account__c => new List<Project_Role__c>{role}} );
                    }
                }
            }

            List<Project_Role__c> rolesToUpdated = new List<Project_Role__c>();
            for(String projectId : roleMap.keySet()){
                Map<String,List<Project_Role__c>> roleTempMap = roleMap.get(projectId);
                for(String roleName : roleTempMap.keySet()){
                    for(Project_Role__c role : roleTempMap.get(roleName)){
                        if(!projectRoleMap.containsKey(role.Id) && role.Primary_Customer_Contact__c ){
                            role.Primary_Customer_Contact__c = false;
                            rolesToUpdated.add(role);
                        }
                    }
                }
            }
            if(rolesToUpdated.size()>0) update rolesToUpdated;
        }
    }

  /*
  * Name : beforeDeleteOperation
  * Description : method to restrict deletion of primary contact roles
  * @param : List<Project_Role__c> oldList
  * @return : void
  */

    public static void beforeDeleteOperation(List<Project_Role__c> oldList) {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        map<Id, Project_Role__c> projectRoleMap = new map<Id, Project_Role__c>([SELECT Id, Project__c, FirstName__c, LastName__c, Role__c, Company_Name__c,
                                                                                Project__r.RecordType.DeveloperName, Primary_Customer_Contact__c,Project__r.RecordTypeId,
                                                                                Project__r.Status__c
                                                                                FROM Project_Role__c
                                                                                WHERE Id IN : oldList]);

        for(Project_Role__c projectRoleRec : oldList) {
            if(projectRoleRec.Primary_Customer_Contact__c) {
                projectRoleRec.addError('Can\'t delete Primary Contact');
            }

            if(projectRoleMap.get(projectRoleRec.id).Project__r.Status__c != Project_Helper.PROJECT_STATUS_UNSUBMITTED
               && profileName.contains('Portal User by Login')) {
                   projectRoleRec.addError(Label.Core_Project_Role_Delete_Message);
			}
        }
    } 

  /*
  * Name : populateProjectRoleField
  * Description : method to populate Project Role Field
  * @param : Project_Role__c[] newList
  * @param : Map<Id,Project_Role__c> oldMap
  * @return : void
  */
    public static void  populateProjectRoleField(Project_Role__c[] newList, Map<Id,Project_Role__c> oldMap) {
        Boolean isInsert = (oldMap == null) ? true : false;
        Set<id> contactId = new Set<id>();
        Set<id> userId = new Set<id>();
        for(Project_Role__c varLoop: newlIst){
            if(varloop.contact__c !=null){
                contactId.add(varloop.contact__C);
            }else if (varloop.user__c !=null) {
                userId.add(varloop.user__c);
            }
        }
        map<id,contact> mapContact = new map<id,Contact>();
        map<id,user> mapuser = new map<id,user>();
        if(contactid.size() >0){
            mapContact = new map<id,contact>([select id,firstname,lastname,email,phone from contact where id in :contactid]);
        }
        if(userid.size() >0){
            mapuser = new map<id,user>([select id,firstname,lastname,email,phone from user where id in :userid]);
        }

        for(Project_Role__c varLoop: newlIst){
            if(mapContact.get(varloop.contact__c)!=null && (isInsert || varloop.contact__c != oldMap.get(varLoop.Id).contact__c)){
                varloop.firstName__c = mapContact.get(varloop.contact__c).firstName;
                varloop.lastName__c =  mapContact.get(varloop.contact__c).lastname;
                varloop.email__c =  mapContact.get(varloop.contact__c).email;
                varloop.phone__c =  mapContact.get(varloop.contact__c).phone;
            }else if (mapuser.get(varloop.user__c) !=null && (isInsert || varloop.user__c != oldMap.get(varLoop.Id).user__c)) {
                varloop.firstName__c =  mapuser.get(varloop.user__c).firstName;
                varloop.lastName__c =  mapuser.get(varloop.user__c).lastname;
                varloop.email__c =  mapuser.get(varloop.user__c).email;
                varloop.phone__c =  mapuser.get(varloop.user__c).phone;
            }
        }
        //System.assert(false, '-----newlIst-----'+ newlIst);
    }
    /*
    private static Boolean entryConditionForAfterInsert(List<Project_Role__c> newList) {
    Boolean isValidEntry = false;
    for(Project_Role__c projectRoleRec : newList) {
    if(projectRoleRec.Primary_Customer_Contact__c) {
    isValidEntry = true;
    }
    }
    return isValidEntry;
    }*/

  /*
  * Name : populateProjectRoleField
  * Description : Method to populate the Project Role First Name LastName and email on the project from the proeject role
  * @param : Project_Role__c[] newList
  * @param : Map<Id,Project_Role__c> oldMap
  * @return : void
  */

    public static void populateProjectField(Project_Role__c[] newList, Map<Id,Project_Role__c> oldMap) {
        Boolean isinsert = Trigger.isInsert;
        Project_Role__c oldRecordProjRole;
        Project__c objProject = null;
        Map<Id, Project__c> projectMapToUpdate = new Map<Id, Project__c> ();

        Set<Id> projectIds_For_PMField = new Set<Id>();  // I-03348
        Set<Id> projectIds_Having_PMField_BLANK = new Set<Id>();  // I-03348

        // I-03348: Avoid secondary PM issue
        for(Project_Role__c varLoop : newList) {
          if( ProjectRole_Helper.PROJECT_MANAGER_ROLE.equalsIgnoreCase(varloop.role__c) && isinsert && oldMap == null) {
            projectIds_For_PMField.add(varloop.Project__c);
          }
        }
        if(projectIds_For_PMField.size() > 0) {
          for(Project__c objProj : [SELECT  Id, Project_Manager_First_Name_Hidden__c, Project_Manager_Last_Name_Hidden__c
                                    FROM    Project__c
                                    WHERE   Id IN :projectIds_For_PMField]) {
            if(String.isBlank(objProj.Project_Manager_First_Name_Hidden__c) && String.isBlank(objProj.Project_Manager_Last_Name_Hidden__c)) {
              projectIds_Having_PMField_BLANK.add(objProj.Id);
            }
          }
        }
        // I-03348: Avoid secondary PM issue

        for(Project_Role__c varLoop : newList){

            oldRecordProjRole = isinsert? null : oldMap.get(VarLoop.id);
            // Populating details on Parent Project about Project Manager
            if( ProjectRole_Helper.PROJECT_MANAGER_ROLE.equalsIgnoreCase(varloop.role__c) &&
               ((isinsert  && (varLoop.Primary_Customer_Contact__c || projectIds_Having_PMField_BLANK.contains(varLoop.Project__c))) ||
                (!isinsert &&  oldRecordProjRole != null &&
                 (
                  varLoop.FirstName__c != oldRecordProjRole.FirstName__c ||
                  varLoop.LastName__c != oldRecordProjRole.LastName__c ||
                  varLoop.email__c != oldRecordProjRole.email__c ||
                  varLoop.role__c != oldRecordProjRole.role__c ||
                  varLoop.Phone__c != oldRecordProjRole.Phone__c ||
                  varLoop.Project__c != oldRecordProjRole.Project__c ||
                  (varLoop.Primary_Customer_Contact__c && varLoop.Primary_Customer_Contact__c != oldRecordProjRole.Primary_Customer_Contact__c)
                 )
                )
               )
              ) {

                  projectIds_Having_PMField_BLANK.remove(varLoop.Project__c); // I-03348: If current thread has 2 project role record on same project,
                                                                              //          then only the first one gets in.

                  if(!projectMapToUpdate.containsKey(varLoop.Project__c)) {
                      projectMapToUpdate.put(varLoop.Project__c, new Project__c(Id = varLoop.Project__c));
                  }
                  objProject = projectMapToUpdate.get(varLoop.Project__c);
                  objProject.Project_Manager_First_Name_Hidden__c = varLoop.FirstName__c;
                  objProject.Project_Manager_Last_Name_Hidden__c = varLoop.LastName__c;
                  objProject.Project_Manager_Email_Hidden__c =  varLoop.Email__c;
                  objProject.Project_Manager_Phone__c =  varLoop.Phone__c;
              }

            // Populating detail for the Primary contractor
            if( ProjectRole_Helper.CONST_VALID_ROLE_CONTRACTOR.contains(varloop.role__c) && varLoop.Primary_Customer_Contact__c &&
               ((isinsert) ||
                ( varLoop.FirstName__c != oldRecordProjRole.FirstName__c ||
                 varLoop.LastName__c != oldRecordProjRole.LastName__c ||
                 varLoop.email__c != oldRecordProjRole.email__c ||
                 varLoop.role__c != oldRecordProjRole.role__c ||
                 varLoop.Primary_Customer_Contact__c != oldRecordProjRole.Primary_Customer_Contact__c ||
                 varLoop.Project__c != oldRecordProjRole.Project__c
                )
               )
              ) {
                  if(!projectMapToUpdate.containsKey(varLoop.Project__c)) {
                      projectMapToUpdate.put(varLoop.Project__c, new Project__c(Id = varLoop.Project__c));
                  }
                  objProject = projectMapToUpdate.get(varLoop.Project__c);
                  objProject.Primary_Contractor_First_Name_Hidden__c = varLoop.FirstName__c;
                  objProject.Primary_Contractor_Last_Name_Hidden__c = varLoop.LastName__c;
                  objProject.Primary_Contractor_Email_Hidden__c =  varLoop.Email__c;
                  objProject.Primary_Contractor_Account_name_Hidden__c = varLoop.Account_Name_Hidden__c;
              }

            // Populating detail for the Primary Builder
            if( ProjectRole_Helper.CONST_VALID_ROLES_BUILDER.contains(varloop.role__c) && varLoop.Primary_Customer_Contact__c &&
               ((isinsert) ||
                ( varLoop.FirstName__c != oldRecordProjRole.FirstName__c ||
                 varLoop.LastName__c != oldRecordProjRole.LastName__c ||
                 varLoop.email__c != oldRecordProjRole.email__c ||
                 varLoop.role__c != oldRecordProjRole.role__c ||
                 varLoop.Primary_Customer_Contact__c != oldRecordProjRole.Primary_Customer_Contact__c ||
                 varLoop.Project__c != oldRecordProjRole.Project__c
                )
               )
              ) {
                  if(!projectMapToUpdate.containsKey(varLoop.Project__c)) {
                      projectMapToUpdate.put(varLoop.Project__c, new Project__c(Id = varLoop.Project__c));
                  }
                  objProject = projectMapToUpdate.get(varLoop.Project__c);
                  objProject.Builder_First_Name__c = varLoop.FirstName__c;
                  objProject.Builder_Last_Name__c = varLoop.LastName__c;
                  objProject.Builder_Email__c =  varLoop.Email__c;
                  objProject.Builder_Account_Name__c = varLoop.Account_Name_Hidden__c;
              }
 
              // Populating detail for the Project Payee
            if( ProjectRole_Helper.CONST_VALID_ROLES_PAYEE.contains(varloop.role__c) && varLoop.Primary_Customer_Contact__c &&
               ((isinsert) ||
                ( varLoop.FirstName__c != oldRecordProjRole.FirstName__c ||
                 varLoop.LastName__c != oldRecordProjRole.LastName__c ||
                 varLoop.email__c != oldRecordProjRole.email__c ||
                 varLoop.role__c != oldRecordProjRole.role__c ||
                 varLoop.Primary_Customer_Contact__c != oldRecordProjRole.Primary_Customer_Contact__c ||
                 varLoop.Project__c != oldRecordProjRole.Project__c
                )
               )
              ) {
                  if(!projectMapToUpdate.containsKey(varLoop.Project__c)) {
                      projectMapToUpdate.put(varLoop.Project__c, new Project__c(Id = varLoop.Project__c));
                  }
                  objProject = projectMapToUpdate.get(varLoop.Project__c);
                 /* objProject.Payee_First_Name__c = varLoop.FirstName__c;
                  objProject.Payee_Last_Name__c = varLoop.LastName__c;
                  objProject.Payee_Email__c =  varLoop.Email__c;
                  objProject.Payee_Account_Name__c = varLoop.Account_Name_Hidden__c;*/
              }


            // Populating detail for the Primary Customer
            if( ProjectRole_Helper.CONST_VALID_ROLES_CUSTOMER.contains(varloop.role__c) && varLoop.Primary_Customer_Contact__c &&
               ((isinsert) ||
                ( varLoop.FirstName__c != oldRecordProjRole.FirstName__c ||
                 varLoop.LastName__c != oldRecordProjRole.LastName__c ||
                 varLoop.email__c != oldRecordProjRole.email__c ||
                 varLoop.role__c != oldRecordProjRole.role__c ||
                 varLoop.Primary_Customer_Contact__c != oldRecordProjRole.Primary_Customer_Contact__c ||
                 varLoop.Project__c != oldRecordProjRole.Project__c
                )
               )
              ) {
                  if(!projectMapToUpdate.containsKey(varLoop.Project__c)) {
                      projectMapToUpdate.put(varLoop.Project__c, new Project__c(Id = varLoop.Project__c));
                  }
                  objProject = projectMapToUpdate.get(varLoop.Project__c);
                  objProject.Customer_First_Name__c = varLoop.FirstName__c;
                  objProject.Customer_Last_Name__c = varLoop.LastName__c;
                  objProject.Customer_Email__c =  varLoop.Email__c;
                  objProject.Customer_Account_Name__c = varLoop.Account_Name_Hidden__c;
              }


            // Populating detail for the Primary Proposer // S-00695
            if( ProjectRole_Helper.PROJECT_PROPOSER_ROLE.equalsIgnoreCase(varloop.role__c) && varLoop.Primary_Customer_Contact__c &&
               ((isinsert) ||
                ( varLoop.FirstName__c != oldRecordProjRole.FirstName__c ||
                 varLoop.LastName__c != oldRecordProjRole.LastName__c ||
                 varLoop.email__c != oldRecordProjRole.email__c ||
                 varLoop.role__c != oldRecordProjRole.role__c ||
                 varLoop.Primary_Customer_Contact__c != oldRecordProjRole.Primary_Customer_Contact__c ||
                 varLoop.Project__c != oldRecordProjRole.Project__c
                )
               )
              ) {
                  if(!projectMapToUpdate.containsKey(varLoop.Project__c)) {
                      projectMapToUpdate.put(varLoop.Project__c, new Project__c(Id = varLoop.Project__c));
                  }
                  objProject = projectMapToUpdate.get(varLoop.Project__c);
                  objProject.Primary_Proposer_First_Name__c = varLoop.FirstName__c;
                  objProject.Primary_Proposer_Last_Name__c = varLoop.LastName__c;
                  objProject.Primary_Proposer_Email__c =  varLoop.Email__c;
                  objProject.Primary_Proposer_Account_Name__c = varLoop.Account_Name_Hidden__c;
                  //system.assert(false,objProject);
                  
              }

        }
		//system.assert(false,projectMapToUpdate);
        if(projectMapToUpdate != null && projectMapToUpdate.size() > 0) {
            update projectMapToUpdate.values();
        }
    }


  /*
  * Name : resetPrimaryContact
  * Description : Method to reset Primary Contact
  * @param : Project_Role__c[] newList
  * @return : void
  */
    private static void resetPrimaryContact(List<Project_Role__c> newList) {
        Set<Id> projectIdSet = new Set<Id>();
        Map<Id, Set<String>> primaryContactRoles = new Map<Id,Set<String>>();

        for(Project_Role__c projectRoleRec : newList) {
            if(projectRoleRec.Primary_Customer_Contact__c) {
                projectIdSet.add(projectRoleRec.Project__c);
                if(!primaryContactRoles.containsKey(projectRoleRec.Project__c)) {
                    primaryContactRoles.put(projectRoleRec.Project__c, new Set<String>());
                }
                primaryContactRoles.get(projectRoleRec.Project__c).add(projectRoleRec.Role__c);
            }
        }

        List<Project_Role__c> existingProRoleList = [select Primary_Customer_Contact__c, Role__c, Project__c
                                                     from Project_Role__c
                                                     where Id NOT IN : newList
                                                     AND Project__c IN : projectIdSet
                                                     AND Project__r.RecordTypeId NOT IN :EXCLUDED_PROJECT_RECORDTYPES
                                                     AND Primary_Customer_Contact__c = true];

        for(Project_Role__c projectRoleRec : existingProRoleList) {
            if(primaryContactRoles.containsKey(projectRoleRec.Project__c)
               && primaryContactRoles.get(projectRoleRec.Project__c).contains(projectRoleRec.Role__c)) {

                   projectRoleRec.Primary_Customer_Contact__c = false;

               }
        }

        if(existingProRoleList.size() > 0) {
            isTriggerExecute = true;
            update existingProRoleList;
        }
    }

    /*
    * Name : updateProjectName
    * Description : Method to update Project Name
    * @param : Project_Role__c[] newList
    * @param : boolean isDelete
    * @return : void
    */
    public static void updateProjectName(List<Project_Role__c> projectRoles, boolean isDelete){
        Set<Id> projectRecordTypesToSkip = new Set<Id>();
        Set<Id> projectRoleIdsToSkip = new Set<Id>();
        Map<Id, String> projectRoleNameMap = new Map<Id, String>();
        Map<Id, List<Project_Site__c>> projectSiteMap = new Map<Id, List<Project_Site__c>>();

        Set<Id> projectRoleIds = new Set<Id>();

        Set<Id> projectIds = new Set<Id>();


        // ########### Put all Skip logics here #######################

        for(Project_Role__c objRole : [SELECT Id
                                       FROM   Project_Role__c
                                       WHERE  Id IN :projectRoles
                                       AND    Project__r.RecordTypeId IN :projectRecordTypesToSkip]) {
          projectRoleIdsToSkip.add(objRole.Id);
        }


        for(Project_Role__c role : projectRoles) {
          if(!projectRoleIdsToSkip.contains(role.Id)) {
            if(role.Role__c == 'Customer'){
              projectIds.add(role.Project__c);
              projectRoleIds.add(role.Id);
            }
          }
        }


        if(projectIds.size() > 0) {

            for(Project_Site__c site : [SELECT  Utility_Sector__c, Project__c
                                        FROM    Project_Site__c
                                        WHERE   Project__c IN: projectIds]) {
                if(!projectSiteMap.containsKey(site.Project__c)) {
                    projectSiteMap.put(site.Project__c, new List<Project_Site__c>());
                }
                projectSiteMap.get(site.Project__c).add(site);
            }

            if(isDelete) {
                List<Project_Role__c> projectRoleList = [SELECT Project__c, FirstName__c, LastName__c, Role__c, Company_Name__c,
                                                         Project__r.RecordType.DeveloperName, Primary_Customer_Contact__c
                                                         FROM Project_Role__c
                                                         WHERE Project__c IN : projectIds
                                                         AND Role__c = 'Customer'
                                                         AND Id NOT IN : projectRoleIds];

                projectRoleNameMap = createProjectRoleNamingMap(projectRoleList, projectSiteMap);
            } else {
                List<Project_Role__c> projectRoleList = [SELECT Project__c, FirstName__c, LastName__c, Role__c, Company_Name__c,
                                                         Primary_Customer_Contact__c, Project__r.RecordType.DeveloperName
                                                         FROM Project_Role__c
                                                         WHERE Project__c IN : projectIds
                                                         AND Role__c = 'Customer'];

                projectRoleNameMap = createProjectRoleNamingMap(projectRoleList, projectSiteMap);
            }

            //If Project Role is not inserted yet then replace project role name with TBD
            if(projectRoleNameMap.size() == 0) {
              for(Id projectId : projectIds) {
                  projectRoleNameMap.put(projectId, 'TBD');
              }
            }

            List<Project__c> toUpdateProjects = new List<Project__c>();

            String projectRole;

            String projectAddress;

            String projectTechnology;

            for(Project__c project : [SELECT  Id, Name, recordtypeid, recordType.DeveloperName,
                                              Program_Version__r.Project_Name_Technology__c,
                                              Program_Version__r.SkipProjectNamingConvention__c,
                                              Program_Version__r.Project_Primary_Name__c, Program_Version__r.Solicitation_Type__c
                                      FROM    Project__c
                                      WHERE   Id IN : projectRoleNameMap.keySet()
                                      AND     Status__C = :PROJECT_HELPER.PROJECT_STATUS_UNSUBMITTED ]){// Naming will change only if the project status is unsubmitted


                  if(projectRoleNameMap.containsKey(project.Id) &&
                     projectRoleNameMap.get(project.Id) != null && (project.Program_Version__r.Project_Primary_Name__c == null
                                                                    || project.Program_Version__r.Project_Primary_Name__c == 'Primary Customer')){
                          projectRole = projectRoleNameMap.get(project.Id).contains('-') ?  projectRoleNameMap.get(project.Id).replaceAll('-', '') : projectRoleNameMap.get(project.Id);
                  } else {
                    projectRole = 'TBD';
                  }

                  //Add Site Address
                  List<String> tempList = project.Name != null ? project.Name.split('-') : null;

                  if(tempList != null && tempList.size() > 2){
                      projectAddress = '- ';
                      for(Integer i = 1; i < tempList.size() - 1; i++){
                          projectAddress += tempList.get(i);
                      }
                  }else{
                      projectAddress = '- TBD';
                  }

                  // Add Technology Name
                  if(project.Program_Version__r.Project_Name_Technology__c == null){
                      projectTechnology = '- TBD';
                  }else{
                      projectTechnology = '- ' + project.Program_Version__r.Project_Name_Technology__c;
                  }

                  if((projectRole + projectAddress + projectTechnology).length() >= 78){
                      if(projectRole.trim().length() >= 20){
                          projectRole = projectRole.subString(0, 18);
                      }
                      if(projectAddress.trim().length() >= 40){
                          projectAddress = projectAddress.subString(0, 38);
                      }
                      if(projectTechnology.trim().length() >= 20){
                          projectTechnology = projectTechnology.subString(0, 19);
                      }
                  }
                  // Begin of change 6/8/2016 T-01171
                  // If the "Skip project Naming convention" is chekced and the project record type is "Clean Transportation"
                  if(!project.Program_Version__r.SkipProjectNamingConvention__c && !Solicitation_Helper.SKIP_NAMING_SOLICITATION_TYPES.contains(project.Program_Version__r.Solicitation_Type__c)) {
                      // End of change 6/8/2016 T-01171
                      project.Name = projectRole.trim() + ' ' + projectAddress.trim() + ' ' + projectTechnology.trim();
                  }
                  toUpdateProjects.add(project);
            }
            if(toUpdateProjects.size() > 0){
                update toUpdateProjects;
            }
        }
    }
  /*
  * Name : createProjectRoleNamingMap
  * Description : Method to create Project Role Naming Map
  * @param : List<Project_Role__c> projectRoles
  * @param : Map<Id, List<Project_Site__c>> projectSiteMap
  * @return : Map<Id, String>
  */
    public static Map<Id, String> createProjectRoleNamingMap(List<Project_Role__c> projectRoles, Map<Id, List<Project_Site__c>> projectSiteMap) {
        Map<Id, String> projectRoleNameMap = new Map<Id, String>();
/*
        for(Project_Role__c role : projectRoles) {
            if((!projectRoleNameMap.containsKey(role.Project__c) || role.Primary_Customer_Contact__c) && role.Role__c == 'Customer') {
                if(role.Project__r.RecordType.DeveloperName == NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME ||
                   role.Project__r.RecordType.DeveloperName == RTEM_Helper.COMMERCIAL_RTEM_PROJECT_RECORD_TYPE_DEVELOPER_NAME ||
                   (role.Project__r.RecordType.DeveloperName == NYSUN_Helper.RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME
                    && projectSiteMap.containsKey(role.Project__c) && String.isNotBlank(projectSiteMap.get(role.Project__c)[0].Utility_Sector__c)
                    && projectSiteMap.get(role.Project__c)[0].Utility_Sector__c == NYSUN_Helper.NON_RESIDENTIAL_UTILITY_SECTOR)) {
                        projectRoleNameMap.put(role.Project__c, (String.isBlank(role.Company_Name__c) ? '' : role.Company_Name__c));
                    } else {
                        projectRoleNameMap.put(role.Project__c, (String.isBlank(role.FirstName__c) ? '' : role.FirstName__c) + (role.LastName__c != null ? ' ' + role.LastName__c : ''));
                    }
            }
        }
*/
        return projectRoleNameMap;
    }

  /*
  * Name : createProjectRoleNamingMap
  * Description : Method to create Project Role Naming Map
  * @param : List<Project_Role__c> projectRoles
  * @return : Map<Id, String>
  */

    public static Map<Id, String> createProjectRoleNamingMap(List<Project_Role__c> projectRoles) {
        Map<Id, String> projectRoleNameMap = new Map<Id, String>();
/*
        for(Project_Role__c role : projectRoles) {
            if((!projectRoleNameMap.containsKey(role.Project__c)) && role.Role__c == CTenant_Helper.PAYEE) {
                if(role.Project__r.RecordType.DeveloperName == CTenant_Helper.CTenant_PROJECT_RECORD_TYPE_DEVELOPER_NAME) {
                    projectRoleNameMap.put(role.Project__c, (String.isBlank(role.Company_Name__c) ? '' : role.Company_Name__c));
                }
            }
        }
*/
        return projectRoleNameMap;
    }

  /*
  * Name : setPaymentAssignment
  * Description : Method to set Payment Assignment
  * @param : List<Project_Role__c> newList
  * @param : Map<Id,Project_Role__c> oldMap
  * @return : Map<Id, String>
  */
	public static final String PROJECT_ROLE_PAYEE = 'Payee';
	
    public static void setPaymentAssignment(List<Project_Role__c> newList, Map<Id,Project_Role__c> oldMap){
        Set<Id> projectIds = new Set<Id>();
        Set<String> projectRolesToFind = new Set<String>{'Payee', ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE};
            List<Project__c> projList = new List<Project__c>();

        for(Project_Role__c role : newList){
            if(role.Role__c == 'Payee' || role.Role__c == 'Contractor'){
                projectIds.add(role.Project__c);
            }
        }

        if(projectIds.size() > 0){
            for(Project__c project : [ SELECT id, Name, (SELECT  Email__c, Project__c , Role__c, Contact__c, Phone__c, Company_Name__c, Primary_Customer_Contact__c
                                                         FROM    Project_Roles__r
                                                         WHERE   Role__c IN : projectRolesToFind)
                                      FROM Project__c
                                      WHERE Id IN : projectIds]){

                                          string payeeCompany = null;
                                          string contractorCompany = null;
                                          if(project.Project_Roles__r != null && project.Project_Roles__r.size() >= 2) {
                                              for(Project_Role__c role : project.Project_Roles__r){
                                                  if(PROJECT_ROLE_PAYEE.equalsIgnoreCase(role.Role__c)) {
                                                      payeeCompany = role.Company_Name__c;
                                                  }
                                                  if(ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(role.Role__c) && role.Primary_Customer_Contact__c) {
                                                      contractorCompany = role.Company_Name__c;
                                                  }
                                              }

                                              if(payeeCompany != null && contractorCompany != null && payeeCompany != contractorCompany){
                                                  project.Payment_Assignment__c = true;
                                                  projList.add(project);
                                              } else { 
                                                  project.Payment_Assignment__c = false;
                                                  projList.add(project);
                                              }
                                          }
                                      }
        }

        if(projList.size() > 0){
            update projList;
        }
    }

  /*
  * Name : createContactAndAccount
  * Description : Method to create Contact And Account
  * @param : List<Project_Role__c> newList
  * @return : void
  */ 

    public static void createContactAndAccount(List<Project_Role__c> newList) {
        isTriggerExecute = true;
        try {
            List<Account> accListToInsert = new List<Account>();
            List<Contact> contactListToInsert = new List<Contact>();
            List<Database.SaveResult> srList;
            Map<Id, String> projectRoleIdToDuplicateIdMap = new Map<Id, String>();
            Map<Integer, Set<Id>> listIndexToDuplicateIdSetMap = new Map<Integer, Set<Id>>();
            Map<Id, Account> projectRoleIdToAccountRecMap = new Map<Id, Account>();
            Map<Id, Contact> projectRoleIdToContactRecMap = new Map<Id, Contact>();

            List<Project_Role__c> newList_Eligible = new List<Project_Role__c>();

            for(Project_Role__c projectRoleRec : newList) {
               if(!projectRoleRec.Use_Program_Approval_for_Sign_Up_Request__c && projectRoleRec.user__c == null) {
                 // Initiate process only if
                 // 1. Program Approval is not needed
                 //   AND 2. User lookup is blank. If user lookup is set then no need to look for contact (AG 07/18/2017)
                 newList_Eligible.add(projectRoleRec);
               }
            }

            // T-02464 - Change intermediary page listing based on logged in user account instead of createdby
            Map<Id, Project_Role__c> accountAutoPopulatingRolesMap = new Map<Id, Project_Role__c>();
            if(newList_Eligible.size() > 0) {
              accountAutoPopulatingRolesMap = new Map<Id, Project_Role__c>([ SELECT  Id, Account__c
                                                                             FROM    Project_Role__c
                                                                             WHERE   Id IN :newList_Eligible
                                                                             AND     Role__c IN : Solicitation_Helper.ROLES_TO_SET_ACCOUNT_BY_LOGIN_USER_DETAILS
                                                                             AND     (Project__r.Concept_Paper__c = true OR Project__r.Proposal__c = true)
                                                                             AND      Account__c != null
                                                                            ]);
            }
            // T-02464 - These roles will populate Account__c on the basis of logged in user's account


            // AG: Added condition to include account creation logic for the contact where Account__c was placed by respective controller
            // T-02464 - These roles will populate Account__c on the basis of logged in user's account
            for(Project_Role__c projectRoleRec : newList_Eligible) {
                if((projectRoleRec.Account__c == null || (projectRoleRec.Account__c != null &&
                                                          projectRoleRec.Contact__c == null &&
                                                          accountAutoPopulatingRolesMap.containsKey(projectRoleRec.Id))
                    ) && String.isNotBlank(projectRoleRec.Company_Name__c)) {
                  Account acc = new Account(Name = projectRoleRec.Company_Name__c);
                  accListToInsert.add(acc);
                }
            }

            if(accListToInsert.size() > 0) {
              srList = Database.insert(accListToInsert, false);
              listIndexToDuplicateIdSetMap = getDuplicateIds(srList);
            }

          Integer counter = 0;
          for(Project_Role__c projectRoleRec : newList_Eligible) {
            if((projectRoleRec.Account__c == null || (projectRoleRec.Account__c != null &&
                                                      projectRoleRec.Contact__c == null &&
                                                      accountAutoPopulatingRolesMap.containsKey(projectRoleRec.Id))
                ) && String.isNotBlank(projectRoleRec.Company_Name__c) && accListToInsert.size() > counter) {
              projectRoleIdToAccountRecMap.put(projectRoleRec.Id, accListToInsert[counter]);

            if(listIndexToDuplicateIdSetMap.containsKey(counter)) {
              String duplicateIds = '';
            for(String dupId : listIndexToDuplicateIdSetMap.get(counter)) {
              duplicateIds += dupId + ';';
            }
            if(!projectRoleIdToDuplicateIdMap.containsKey(projectRoleRec.Id)) {
              projectRoleIdToDuplicateIdMap.put(projectRoleRec.Id, '');
            }
            String dupIds = projectRoleIdToDuplicateIdMap.get(projectRoleRec.Id);
            dupIds += duplicateIds;
            projectRoleIdToDuplicateIdMap.put(projectRoleRec.Id, dupIds);
            }
            counter++;
            }
          }

         // Same For Contact List
         for(Project_Role__c projectRoleRec : newList_Eligible) {
            if(projectRoleRec.Contact__c == null && String.isNotBlank(projectRoleRec.LastName__c)) {

                Contact conRec = new Contact();
                conRec.FirstName = projectRoleRec.FirstName__c;
                conRec.LastName = projectRoleRec.LastName__c;
                conRec.Email = projectRoleRec.Email__c;
                conRec.Phone = projectRoleRec.Phone__c;

                // Address Fields
                conRec.MailingStreet = (projectRoleRec.Address_1__c != null) ? projectRoleRec.Address_1__c : '';
                conRec.MailingStreet += (projectRoleRec.Address_2__c != null) ? ', ' + projectRoleRec.Address_2__c : '';
                conRec.MailingCity = projectRoleRec.City__c;
                conRec.MailingState = projectRoleRec.State__c;
                conRec.MailingCountry = projectRoleRec.County__c;
                conRec.MailingPostalCode = projectRoleRec.Zip__c;

                if(projectRoleIdToAccountRecMap.containsKey(projectRoleRec.Id)) {
                  conRec.AccountId = projectRoleIdToAccountRecMap.get(projectRoleRec.Id).Id;
                }
                  contactListToInsert.add(conRec);
            }
          }

        if(contactListToInsert.size() > 0) {
            srList = Database.insert(contactListToInsert, false);
            listIndexToDuplicateIdSetMap = getDuplicateIds(srList);
        }

        counter = 0;
        for(Project_Role__c projectRoleRec : newList_Eligible) {
            if(projectRoleRec.Contact__c == null && String.isNotBlank(projectRoleRec.LastName__c) && contactListToInsert.size() > counter) {
            projectRoleIdToContactRecMap.put(projectRoleRec.Id, contactListToInsert[counter]);

            if(listIndexToDuplicateIdSetMap.containsKey(counter)) {
              String duplicateIds = '';
            for(String dupId : listIndexToDuplicateIdSetMap.get(counter)) {
              duplicateIds += dupId + ';';
            }
            if(!projectRoleIdToDuplicateIdMap.containsKey(projectRoleRec.Id)) {
              projectRoleIdToDuplicateIdMap.put(projectRoleRec.Id, '');
            }
            String dupIds = projectRoleIdToDuplicateIdMap.get(projectRoleRec.Id);
            dupIds += duplicateIds;
            projectRoleIdToDuplicateIdMap.put(projectRoleRec.Id, dupIds);
            }
            counter++;
            }
        }

        // Update Project Role Record with newly inserted Account and Contact Id
        List<Project_Role__c> projectRoleListToUpdate = new List<Project_Role__c>();
        for(Project_Role__c projectRoleRec : newList_Eligible) {

          System.debug('>>> Account set already projectRoleRec.Account__c = ' + projectRoleRec.Account__c);

          Project_Role__c prRec = new Project_Role__c(Id = projectRoleRec.Id);
            if(projectRoleIdToAccountRecMap.containsKey(projectRoleRec.Id) && (!accountAutoPopulatingRolesMap.containsKey(projectRoleRec.Id))) {
              // added condition to avoid Account__c stamping if this is already set from the respective controller
              // T-02464 - These roles will populate Account__c on the basis of logged in user's account
              prRec.Account__c = projectRoleIdToAccountRecMap.get(projectRoleRec.Id).Id;
            }
            if(projectRoleIdToContactRecMap.containsKey(projectRoleRec.Id)) {
              prRec.Contact__c = projectRoleIdToContactRecMap.get(projectRoleRec.Id).Id;
            }
            prRec.Duplicate_Information__c = (projectRoleIdToDuplicateIdMap.containsKey(projectRoleRec.Id)) ?
            projectRoleIdToDuplicateIdMap.get(projectRoleRec.Id) : '';
            projectRoleListToUpdate.add(prRec);
        }

        if(projectRoleListToUpdate.size() > 0) {
          update projectRoleListToUpdate;
        }

        } catch(Exception e) {
            system.debug('Exception Found : ' + e);

            // Find duplicate Ids
            //system.assert(false, 'Catch of Main Method');
        }
    }

/*
// Ajay/Harshit: This is for Commercial Tenant only, and not needed now.
    public static void createContactAndAccount(List<Project_Role__c> projectRoles) {
        Map<Id, Id> roleContactIdMap = new Map<Id, Id>();

        try{
            isTriggerExecute = true;

            List<Project_Role__c> newList = new List<Project_Role__c>();

            for(Project_Role__c projectRole : projectRoles){
                if(projectRole.Account__c == null && projectRole.Contact__c == null
                   && (!projectRole.Use_Program_Approval_for_Sign_Up_Request__c)){

                    newList.add(projectRole);
                }
            }

            if(newList.size() > 0){
                Set<String> companies = new Set<String>();
                Set<String> firstNames = new Set<String>();
                Set<String> lastNames = new Set<String>();
                Set<String> emails = new Set<String>();

                for(Project_Role__c role : newList){
                    if(role.Company_Name__c != null){
                        companies.add(role.Company_Name__c);
                    }

                    if(role.Email__c != null){
                        emails.add(role.Email__c);
                    }

                    if(role.FirstName__c != null){
                        firstNames.add(role.FirstName__c);
                    }

                    if(role.LastName__c != null){
                        lastNames.add(role.LastName__c);
                    }
                }

                Map<Id, Set<Id>> roleAccountIdsMap = new Map<Id, Set<Id>>();

                for(Account acc : [SELECT Id, Name, Website FROM Account
                                   WHERE Name IN : companies]){

                                       for(Project_Role__c role : newList){
                                           if(acc.Name == role.Company_Name__c){
                                               if(role.Email__c != null){
                                                   List<String> tempList = role.Email__c.split('@');
                                                   if(tempList.size() > 1){
                                                       tempList = tempList.get(1).split('\\.');

                                                       if(tempList.size() > 0){
                                                           if(acc.Website != null && acc.Website.contains(tempList.get(0))){
                                                               if(!roleAccountIdsMap.containsKey(role.Id)){
                                                                   roleAccountIdsMap.put(role.Id, new Set<Id>());
                                                               }

                                                               roleAccountIdsMap.get(role.Id).add(acc.Id);
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }

                Map<Id, Set<Id>> roleContactIdsMap = new Map<Id, Set<Id>>();
                Map<Id, Id> contactAccountIdMap = new Map<Id, Id>();

                for(Contact con : [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE
                                   FirstName IN : firstNames OR
                                   LastName IN : lastNames OR
                                   Email IN : emails]){

                                       for(Project_Role__c role : newList){
                                           if(role.FirstName__c ==  con.FirstName &&
                                              role.LastName__c ==  con.LastName &&
                                              role.Email__c == con.Email){

                                                  if(!roleContactIdsMap.containsKey(role.Id)){
                                                      roleContactIdsMap.put(role.Id, new Set<Id>());
                                                  }

                                                  roleContactIdsMap.get(role.Id).add(con.Id);
                                              }
                                       }

                                       contactAccountIdMap.put(con.Id, con.AccountId);
                                   }

                List<Contact> contactsToInsert = new List<Contact>();
                List<Account> accountsToInsert = new List<Account>();
                Set<Id> existingAssocaitedRoles = new Set<Id>();
                List<Project_Role__c> projectRolesToUpdate = new List<Project_Role__c>();
                Map<Id, Id> existingAssocaitedAccountRoles = new Map<Id, Id>();

                List<Id> existingAccountIds = new List<Id>();

                for(Project_Role__c role : newList){
                    if(roleAccountIdsMap.containsKey(role.Id) && roleAccountIdsMap.get(role.Id) != null){

                        if(roleAccountIdsMap.get(role.Id).size() == 1){
                            List<Id> tempAccIds = new List<Id>();
                            tempAccIds.addAll(roleAccountIdsMap.get(role.Id));

                            existingAssocaitedAccountRoles.put(role.Id, tempAccIds.get(0));
                            existingAccountIds.add(tempAccIds.get(0));

                            if(roleContactIdsMap.containsKey(role.Id) && roleContactIdsMap.get(role.Id) != null){

                                if(roleContactIdsMap.get(role.Id).size() == 1){

                                    List<Id> tempConIds = new List<Id>();
                                    tempConIds.addAll( roleContactIdsMap.get(role.Id));

                                    if(contactAccountIdMap.get(tempConIds.get(0)) == tempAccIds.get(0)){
                                        existingAssocaitedRoles.add(role.Id);

                                        Project_Role__c tempRole = new Project_Role__c(Id = role.Id, Account__c = tempAccIds.get(0),
                                                                                       Contact__c = tempConIds.get(0));
                                        projectRolesToUpdate.add(tempRole);
                                        roleContactIdMap.put(role.Id, tempConIds.get(0));
                                    }
                                }
                            }
                        }
                    }

                    if(!existingAssocaitedAccountRoles.containsKey(role.Id)){
                        accountsToInsert.add(new Account(Name = role.Company_Name__c));
                    }

                    if(!existingAssocaitedRoles.contains(role.Id)){
                        String mailingStreet = ((role.Address_1__c != null) ? role.Address_1__c : '');
                        mailingStreet += ((role.Address_2__c != null) ? ', ' + role.Address_2__c : '');

                        contactsToInsert.add(new Contact(FirstName = role.FirstName__c,
                                                         LastName = role.LastName__c,
                                                         Email = role.Email__c,
                                                         Phone = role.Phone__c,
                                                         MailingStreet = mailingStreet,
                                                         MailingCity = role.City__c,
                                                         MailingState = role.State__c,
                                                         MailingCountry = role.County__c,
                                                         MailingPostalCode = role.Zip__c));
                    }
                }

                if(accountsToInsert.size() > 0){
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.AllowSave = true;
                    Database.insert(accountsToInsert, dml);
                }

                for(Account acc : accountsToInsert){
                    existingAccountIds.add(acc.Id);
                }

                for(Integer i=0; i<existingAccountIds.size(); i++){
                    if(i < contactsToInsert.size() &&
                       existingAccountIds.get(i) != null){

                           contactsToInsert.get(i).AccountId = existingAccountIds.get(i);
                       }
                }

                if(contactsToInsert.size() > 0){
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.AllowSave = true;
                    Database.insert(contactsToInsert, dml);
                }

                for(Project_Role__c role : newList){
                    if(!existingAssocaitedRoles.contains(role.Id)){
                        Project_Role__c tempRole = new Project_Role__c(Id = role.Id);

                        if(existingAssocaitedAccountRoles.containsKey(role.Id)
                           && existingAssocaitedAccountRoles.get(role.Id) != null){

                               tempRole.Account__c = existingAssocaitedAccountRoles.get(role.Id);
                           }else{
                               for(Account acc : accountsToInsert){
                                   if(acc.Name == role.Company_Name__c){
                                       tempRole.Account__c = acc.Id;
                                   }
                               }
                           }

                        for(Contact con : contactsToInsert){
                            if(role.FirstName__c ==  con.FirstName &&
                               role.LastName__c ==  con.LastName &&
                               role.Email__c == con.Email){
                                   tempRole.Contact__c = con.Id;
                                   roleContactIdMap.put(role.Id, con.Id);
                               }
                        }

                        projectRolesToUpdate.add(tempRole);
                    }
                }

                if(projectRolesToUpdate.size() > 0){
                    update projectRolesToUpdate;
                }

                sendCollaborateNotification(projectRoles, roleContactIdMap);
            }
        }catch(DMLException e){
            system.debug('Exception Found : ' + e);
        }catch(Exception e){
            system.debug('Exception Found : ' + e);
        }
    }

*/

  /*
  * Name : getDuplicateIds
  * Description : Method to get Duplicate Ids
  * @param : List<Database.SaveResult> srList
  * @return : Map<Integer, Set<Id>>
  */
    private static Map<Integer, Set<Id>> getDuplicateIds(List<Database.SaveResult> srList) {
        Map<Integer, Set<Id>> listIndexToDuplicateIdSetMap = new Map<Integer, Set<Id>>();
        Set<Id> duplicateIds = new Set<Id>();
        Integer counter = 0;
        for(Database.SaveResult sr : srList) {
            try {
                if (!sr.isSuccess()) {
                    for(Database.Error duplicateError : sr.getErrors()){
                        Datacloud.DuplicateResult duplicateResult = ((Database.DuplicateError)duplicateError).getDuplicateResult();
                        for(Datacloud.MatchResult matchedResult : duplicateResult.getMatchResults()) {
                            for(Datacloud.MatchRecord matchRecord : matchedResult.getMatchRecords()) {
                                duplicateIds.add(String.valueOf(matchRecord.getRecord().get('Id')));
                            }
                        }
                    }
                    listIndexToDuplicateIdSetMap.put(counter, duplicateIds);
                } else {
                    listIndexToDuplicateIdSetMap.put(counter, new Set<Id>());
                }
            } catch(Exception e) {
                listIndexToDuplicateIdSetMap.put(counter, new Set<Id>());
            }
            counter++;
        }

        return listIndexToDuplicateIdSetMap;
    }

  /*
  * Name : sendCollaborateNotification
  * Description : Method to send Collaborate Notification
  * @param : List<Project_Role__c> newRoles
  * @param : Map<Id, Id> roleContactIdMap
  * @return : void
  */
    public static void sendCollaborateNotification(List<Project_Role__c> newRoles, Map<Id, Id> roleContactIdMap){
        try{
            Set<String> validPermissions = new Set<String>{'Read Only', 'Read-Write-Upload Documents',
                'Read-Write-Upload Documents-Signatory'};

            Map<Id, Id> projectRoleContactIdMap = new Map<Id, Id>();

            Map<Id, String> projectRoleEmailMap = new Map<Id, String>();

            Set<String> setOfPECRoles; // set of primary energy consultant role ids used for new construction program

            // id is role id and value is project id
            Map<Id, String> mapOfRoleIdAndProjectId = new Map<Id, String>();

            Map<Id, Set<String>> mapOfProjectIdAndRoleId = new Map<Id, Set<String>>();

            for(Project_Role__c role : newRoles){
                if(role.Permission__c != null && validPermissions.contains(role.Permission__c)){

                    if(role.Contact__c != null){
                        projectRoleContactIdMap.put(role.Id, role.Contact__c);
                    }else if(roleContactIdMap.containsKey(role.Id)){
                        projectRoleContactIdMap.put(role.Id, roleContactIdMap.get(role.Id));
                    }

                    projectRoleEmailMap.put(role.Id, role.Email__c);
                    mapOfRoleIdAndProjectId.put(role.Id, role.Project__c);
                }


                if(mapOfProjectIdAndRoleId.containsKey(role.Project__c))
                {
                  setOfPECRoles = mapOfProjectIdAndRoleId.get(role.Project__c);
                }
                else
                {
                  setOfPECRoles = new Set<String>();
                }
                if(role.Role__c == 'Primary Energy Consultant')
                {
                  setOfPECRoles.add(role.Id);
                }
                if(setOfPECRoles.size() > 0)
                {
                  mapOfProjectIdAndRoleId.put(role.Project__c, setOfPECRoles);
                }
            }

            Map<Id, String> mapOfProjectIdAndProjectRecordTypeName = new Map<Id, String>();
            if(mapOfRoleIdAndProjectId != null && mapOfRoleIdAndProjectId.size() > 0)
            {
                for(Project__c project : [  SELECT Id, RecordType.DeveloperName
                                            FROM Project__c
                                            WHERE Id in :mapOfRoleIdAndProjectId.values()])
                {
                    mapOfProjectIdAndProjectRecordTypeName.put(project.Id, project.RecordType.DeveloperName);
                }
            }

            Set<String> setToAvoidProjectRoles = new Set<String>();
            if(mapOfProjectIdAndProjectRecordTypeName != null && mapOfProjectIdAndProjectRecordTypeName.size() > 0 &&
              mapOfProjectIdAndRoleId != null && mapOfProjectIdAndRoleId.size() > 0)
            {
              String recordTypeName;
              for(String projectId : mapOfProjectIdAndProjectRecordTypeName.keySet())
              {
                recordTypeName = mapOfProjectIdAndProjectRecordTypeName.get(projectId);
              }
            }



            system.debug('@@@ projectRoleContactIdMap '+ projectRoleContactIdMap);
            system.debug('@@@ projectRoleEmailMap '+ projectRoleEmailMap);

            if(projectRoleContactIdMap.size() > 0 || projectRoleEmailMap.size() > 0){

                Map<Id, Project__c> roleProjectMap = new Map<Id, Project__c>();
                Map<Id, String> roleFirstNameMap = new Map<Id, String>();

                for(Project_Role__c role : [SELECT Id, Project__r.Application_Number__c, Project__r.Id, FirstName__c
                                            FROM Project_Role__c WHERE ID IN : projectRoleEmailMap.keySet()]){

                                                roleProjectMap.put(role.Id, role.Project__r);
                                                roleFirstNameMap.put(role.Id, role.FirstName__c);
                                            }

                Set<Id> existingUserRoles = new Set<Id>();

                for(User user : [SELECT Id, ContactId, Email FROM User
                                 WHERE (ContactId IN: projectRoleContactIdMap.values()
                                        OR Email IN : projectRoleEmailMap.values())
                                 AND IsActive =: true
                                 AND ContactId != null]){

                                     for(Id roleId : projectRoleContactIdMap.keySet()){
                                         system.debug('@@@ user contactId '+ user.ContactId +', role contactId '+projectRoleContactIdMap.get(roleId));
                                         if(user.ContactId == projectRoleContactIdMap.get(roleId)){
                                             existingUserRoles.add(roleId);
                                         }
                                     }
                                 }

                Map<String, EmailTemplate> mapOfExistinUserEmailTemplates = new Map<String, EmailTemplate>();
                Map<String, EmailTemplate> mapOfNewUserEmailTemplates = new Map<String, EmailTemplate>();
        Set<String> setOfTemplates = new Set<String>();
        setOfTemplates.add('Core_Invite_existing_users_to_register_and_collaborate');
        setOfTemplates.add('Core_Invite_existing_users_to_collaborate');
        setOfTemplates.add('NC_Invite_existing_users_to_register_and_collaborate');
        setOfTemplates.add('NC_Invite_existing_users_to_collaborate');

                for(EmailTemplate template : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE
                                              DeveloperName in : setOfTemplates]){

                                                  if(template.DeveloperName == 'Core_Invite_existing_users_to_register_and_collaborate'){
                                                      mapOfNewUserEmailTemplates.put('Commercial_Tenant', template);
                                                  }else if(template.DeveloperName == 'Core_Invite_existing_users_to_collaborate'){
                                                      mapOfExistinUserEmailTemplates.put('Commercial_Tenant', template);
                                                  }
                                              }

                List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();
                Id projectId;
                for(Id projectRoleId : projectRoleEmailMap.keySet()){

          if(setToAvoidProjectRoles != null && setToAvoidProjectRoles.contains(projectRoleId))
          {
            continue;
          }
                    EmailTemplate tempEmailTemplate = new EmailTemplate();
                    if(existingUserRoles.contains(projectRoleId)){
                        if(mapOfRoleIdAndProjectId != null && mapOfProjectIdAndProjectRecordTypeName != null)
                        {
                            if(mapOfRoleIdAndProjectId.containsKey(projectRoleId))
                            {
                                projectId = mapOfRoleIdAndProjectId.get(projectRoleId);
                                
                            }
                        }
                    }else{
                        if(mapOfRoleIdAndProjectId != null && mapOfProjectIdAndProjectRecordTypeName != null)
                        {
                            if(mapOfRoleIdAndProjectId.containsKey(projectRoleId))
                            {
                                projectId = mapOfRoleIdAndProjectId.get(projectRoleId);
                                
                            }
                        }
                    }

                    if(tempEmailTemplate != null){
                        Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(tempEmailTemplate.Id, null, projectRoleId);
                        Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                        mailToBeSent.saveAsActivity = false;
                        mailToBeSent.setToAddresses(new List<String>{projectRoleEmailMap.get(projectRoleId)});
                        notifications.add(mailToBeSent);
                    }
                }
                notifications = CORE_Helper.setOrgWideEmailAddress_CORE(notifications);
                Messaging.sendEmail(notifications);
                System.debug('>>> Email Sent');
            }
        }catch(Exception e){
            system.debug('@@@ In sendCollaborateNotification method Catch Exception : '+e.getMessage());
        }
    }

  /*
  * Name : sendApprovalCollaborateNotification
  * Description : Method to send Approval Collaborate Notification
  * @param : List<Project_Role__c> newRoles
  * @return : void
  */
    public static void sendApprovalCollaborateNotification(List<Project_Role__c> newRoles){
        try{
            Set<String> validPermissions = new Set<String>{'Read Only', 'Read-Write-Upload Documents',
                'Read-Write-Upload Documents-Signatory'};

            Map<Id, Id> projectRoleContactIdMap = new Map<Id, Id>();
            Map<Id, String> projectRoleEmailMap = new Map<Id, String>();
            List<Project_Role__c> projectRolesToUpdate = new List<Project_Role__c>();
            List<User> shareProjectWithExitingUsers = new List<User>();

            Set<String> companies = new Set<String>();
            Set<String> firstNames = new Set<String>();
            Set<String> lastNames = new Set<String>();
            Set<String> emails = new Set<String>();

            List<Project_Role__c> validRoles = new List<Project_Role__c>();
            Map<Id, Project_Role__c> roleIdMap = new Map<Id, Project_Role__c>();

            for(Project_Role__c role : newRoles){
                if(role.Permission__c != null && validPermissions.contains(role.Permission__c)
                   && role.Use_Program_Approval_for_Sign_Up_Request__c){

                    emails.add(role.Email__c);
                    companies.add(role.Company_Name__c);
                    firstNames.add(role.FirstName__c);
                    lastNames.add(role.LastName__c);

                    validRoles.add(role);
                    roleIdMap.put(role.Id, role);
                }
            }

            if(validRoles.size() > 0){

                Map<Id, boolean> roleAccountExistMap = new Map<Id, boolean>();

                for(Account acc : [SELECT Id, Name FROM Account
                                   WHERE Name IN : companies]){

                      for(Project_Role__c role : validRoles){
                        if(role.Company_Name__c == acc.Name){
                            roleAccountExistMap.put(role.Id, true);
                        }
                      }
                }

                Map<Id, boolean> roleContactExistMap = new Map<Id, boolean>();

                for(Contact con : [SELECT Id, FirstName, LastName, Email
                                   FROM Contact WHERE
                                   FirstName IN : firstNames OR
                                   LastName IN : lastNames OR
                                   Email IN : emails]){

                      for(Project_Role__c role : validRoles){
                        if(role.FirstName__c == con.FirstName && role.LastName__c == con.LastName
                           && role.Email__c == con.Email){
                            roleContactExistMap.put(role.Id, true);
                        }
                      }
                }

        Set<String> projectIds = new Set<String>();
                Map<Id, User> rolePortalUserExistMap = new Map<Id, User>();
                Map<Id, boolean> roleNonPortalUserExistMap = new Map<Id, boolean>();

                for(User usr : [SELECT Id, Email, AccountId, ContactId, Profile.Name FROM User WHERE
                                Email IN : emails]){

                    for(Project_Role__c role : validRoles){
                        if(role.Email__c == usr.Email){
                            if(usr.ContactId != null && usr.Profile.Name == PROFILE_PORTAL_USER_BY_LOGIN){
                                rolePortalUserExistMap.put(role.Id, usr);
                            }else{
                                roleNonPortalUserExistMap.put(role.Id, true);
                            }
                            projectIds.add(role.Project__c);
                        }
                    }
                }
 
                List<Program_Partnership_Request__c> partnershipRequests =
                                                        new List<Program_Partnership_Request__c>();

                //EmailTemplate registerationTemplate = new EmailTemplate();
                EmailTemplate templateEmailToProgramStaff = new EmailTemplate();
                EmailTemplate templateEmailToRoleCreater = new EmailTemplate();

                Map<String, EmailTemplate> mapOfProjectRecordTypeAndEmailTemplateToExistingUser = new Map<String, EmailTemplate>();
                Map<String, EmailTemplate> mapOfProjectRecordTypeAndEmailTemplateForRegistration = new Map<String, EmailTemplate>();

                //EmailTemplate templateEmailToExistingUser = new EmailTemplate();
        //EmailTemplate templateEmailToExistingUserNewConstruction = new EmailTemplate();
                for(EmailTemplate temp : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE
                                          DeveloperName = 'Core_Invite_existing_users_to_register_and_collaborate'
                                          OR DeveloperName = 'Core_Program_Staff_Approval_Action_Needed_Notification'
                                          OR DeveloperName = 'Core_Project_Role_Request_is_Under_Review'
                                          OR DeveloperName = 'Core_Invite_existing_users_to_collaborate'
                                          OR DeveloperName = 'NC_Invite_existing_users_to_collaborate'
                                          OR DeveloperName = 'NC_Invite_existing_users_to_register_and_collaborate'
                                          ]){
                    
                     if(temp.DeveloperName == 'Core_Program_Staff_Approval_Action_Needed_Notification'){
                        templateEmailToProgramStaff = temp;
                    }else if(temp.DeveloperName == 'Core_Project_Role_Request_is_Under_Review'){
                        templateEmailToRoleCreater = temp;
                    }
                }

                Map<Id, String> roleApplicationNumberMap = new Map<Id, String>();
                Map<Id, String> roleToCreateByEmailMap = new Map<Id, String>();
                String ProgramStaffGroupName;
                String PMRoleEmail;
        Map<String, String> mapOfProjectIdAndRecordType = new Map<String, String>();
                for(Project_Role__c role : [SELECT Id, Project__r.Application_Number__c, CreatedBy.Email, Email__c, Role__c, Project__c,
                                                   Project__r.Program_Version__r.Program__r.Program_Staff_Group_Name__c, Project__r.RecordType.DeveloperName
                                            FROM Project_Role__c WHERE Id IN : validRoles
                                            OR (Role__c =: ProjectRole_Helper.PROJECT_MANAGER_ROLE AND Project__c in : projectIds)]){

                    roleApplicationNumberMap.put(role.Id, role.Project__r.Application_Number__c);
                    roleToCreateByEmailMap.put(role.Id, role.CreatedBy.Email);
                    ProgramStaffGroupName = role.Project__r.Program_Version__r.Program__r.Program_Staff_Group_Name__c;
                    if(role.Role__c == ProjectRole_Helper.PROJECT_MANAGER_ROLE)
                        PMRoleEmail = role.Email__c;

                   if(!mapOfProjectIdAndRecordType.containsKey(role.Project__c))
                      mapOfProjectIdAndRecordType.put(role.Project__c, role.Project__r.RecordType.DeveloperName);
                }

                List<Messaging.SingleEmailMessage> registrationMails = new List<Messaging.SingleEmailMessage>();
                List<Messaging.SingleEmailMessage> collaborationMails = new List<Messaging.SingleEmailMessage>();
        String projectRecordTypeName;
                for(Project_Role__c role : validRoles){

                  if(mapOfProjectIdAndRecordType.containskey(role.Project__c))
                  {
                    projectRecordTypeName = mapOfProjectIdAndRecordType.get(role.Project__c);
                  }

 
                    //Existing Portal User
                    if(rolePortalUserExistMap.containsKey(role.Id) && rolePortalUserExistMap.get(role.Id) != null){
                        //GS Pending : Need Program PartnerShipRecord
                        Project_Role__c tempRole = new Project_Role__c(Id = role.Id);
                        tempRole.Account__c = rolePortalUserExistMap.get(role.Id).AccountId;
                        tempRole.Contact__c = rolePortalUserExistMap.get(role.Id).ContactId;
                        tempRole.User__c = rolePortalUserExistMap.get(role.Id).Id;
                        projectRolesToUpdate.add(tempRole);
                        shareProjectWithExitingUsers.add(rolePortalUserExistMap.get(role.Id));
                        if(mapOfProjectRecordTypeAndEmailTemplateToExistingUser.containsKey(projectRecordTypeName))
                        {
                          prepareCollaborationMails(collaborationMails, mapOfProjectRecordTypeAndEmailTemplateToExistingUser.get(projectRecordTypeName), role);
                        }
                    //Existng Non Portal User
                    }else if(roleNonPortalUserExistMap.containsKey(role.Id) && roleNonPortalUserExistMap.get(role.Id) && mapOfProjectRecordTypeAndEmailTemplateForRegistration.containsKey(projectRecordTypeName)){
                        prepareSignupEmail(role, mapOfProjectRecordTypeAndEmailTemplateForRegistration.get(projectRecordTypeName), registrationMails, roleApplicationNumberMap);

                    // Any Account or Contact Match
                    }else if((roleAccountExistMap.containsKey(role.Id) && roleAccountExistMap.get(role.Id)) ||
                       (roleContactExistMap.containsKey(role.Id) && roleContactExistMap.get(role.Id))){

                        String verficationCode = String.valueOf(math.random());

                        if(verficationCode.length() > 40){
                            verficationCode = verficationCode.subString(0, 39);
                        }

                        partnershipRequests.add(new Program_Partnership_Request__c(Program__c = role.Program_Id__c,
                                                Status__c = 'Open',
                                                Email_Verification_Code__c = verficationCode,
                                                Email_Address_Verified__c = 'Verified',
                                                Company_Name__c = role.Company_Name__c,
                                                Street_Address__c = role.Address_1__c,
                                                State__c = role.State__c,
                                                City__c = role.City__c,
                                                Zip_Code__c = role.Zip__c,
                                                First_Name__c = role.FirstName__c,
                                                Last_Name__c = role.LastName__c,
                                                Title__c = role.Title__c,
                                                Email__c = role.Email__c,
                                                Phone__c = role.Phone__c,
                                                Project_Role__c = role.Id));

                    //Consider New User
                    }else{
                      if(mapOfProjectRecordTypeAndEmailTemplateForRegistration.containsKey(projectRecordTypeName))
                      {
                          prepareSignupEmail(role, mapOfProjectRecordTypeAndEmailTemplateForRegistration.get(projectRecordTypeName), registrationMails, roleApplicationNumberMap);
                      }
                    }
                }

                if(partnershipRequests.size() > 0){
                    insert partnershipRequests;

                    //List<String> programStaffEmailIds = groupMemberEmailAddresses(ProgramStaffGroupName);
                    List<Messaging.SingleEmailMessage> existingUserMails = new List<Messaging.SingleEmailMessage>();

                    for(Program_Partnership_Request__c request : partnershipRequests){
                        /* Managed by workflow role
                        Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(templateEmailToProgramStaff.Id, null, request.Id);
                        Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                        mailToBeSent.saveAsActivity = false;
                        mailToBeSent.setToAddresses(new List<String>{PMRoleEmail});
                        existingUserMails.add(mailToBeSent);
                        */
                        Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(templateEmailToRoleCreater.Id, null, request.Project_Role__c);
                        Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                        mailToBeSent.saveAsActivity = false;
                        mailToBeSent.setToAddresses(new List<String>{roleToCreateByEmailMap.get(request.Project_Role__c)});
                        existingUserMails.add(mailToBeSent);

                    }

                    if(existingUserMails.size() > 0){
                        existingUserMails = CORE_Helper.setOrgWideEmailAddress_CORE(existingUserMails);
                        Messaging.sendEmail(existingUserMails);
                    }
                }

                if(projectRolesToUpdate.size() > 0){
                    update projectRolesToUpdate;
                }

                if(shareProjectWithExitingUsers.size() > 0){
                    ProjectSharing_Helper.shareByUser(shareProjectWithExitingUsers);
                }

                if(registrationMails.size() > 0){
                    registrationMails = CORE_Helper.setOrgWideEmailAddress_CORE(registrationMails);
                    Messaging.sendEmail(registrationMails);
                }

                if(collaborationMails.size() > 0){
                    collaborationMails = CORE_Helper.setOrgWideEmailAddress_CORE(collaborationMails);
                    Messaging.sendEmail(collaborationMails);
                }
            }
        }catch(DMLException e){

        }catch(Exception e){

        }
    }

  /*
  * Name : prepareSignupEmail
  * Description : Method to prepare Signup Email
  * @param : Project_Role__c role
  * @param : EmailTemplate registerationTemplate
  * @param : List<Messaging.SingleEmailMessage> registrationMails
  * @param : Map<Id, String> roleApplicationNumberMap
  * @return : void
  */
    private static void prepareSignupEmail(Project_Role__c role, EmailTemplate registerationTemplate,
                                           List<Messaging.SingleEmailMessage> registrationMails, Map<Id, String> roleApplicationNumberMap){

        Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(registerationTemplate.Id, null, role.Id);
        Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
        mailToBeSent.setSubject(newEmail.subject);
        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
        mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
        mailToBeSent.saveAsActivity = false;
        mailToBeSent.setToAddresses(new List<String>{role.Email__c});
        registrationMails.add(mailToBeSent);
    }
  /*
  * Name : prepareCollaborationMails
  * Description : Method to prepare Collaboration Mails
  * @param : Project_Role__c role
  * @param : EmailTemplate templateEmailToExistingUser
  * @param : List<Messaging.SingleEmailMessage> collaborationMails
  * @return : void
  */
    private static void prepareCollaborationMails(List<Messaging.SingleEmailMessage> collaborationMails, EmailTemplate templateEmailToExistingUser,
                                                  Project_Role__c role){

        Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(templateEmailToExistingUser.Id, null, role.Id);
        mailToBeSent.setSubject(newEmail.subject);
        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
        mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
        mailToBeSent.saveAsActivity = false;
        mailToBeSent.setToAddresses(new List<String>{role.Email__c});
        collaborationMails.add(mailToBeSent);
    }
  /*
  * Name : groupMemberEmailAddresses
  * Description : Method to get group Member Email Addresses
  * @param : String PubGroupName
  * @return : List<String>
  */
    public static List<String> groupMemberEmailAddresses(String PubGroupName){
        List<String> mailToAddresses = new List<String>();
        Set<Id> idList = new Set<Id>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name =: PubGroupName];
        for (GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId);
        }

        User[] usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr) {
            mailToAddresses.add(u.email);
        }
        return mailToAddresses;
    }


    /* Method Name: sendProjectRoleNotifications
    * Description: T-03093: SQA QA Manager Approval Notification
    * @param: list<Project_Role__c> newList
    * @param: Map<Id, Project_Role__c> oldMap -- old map
    * @return: void
    */

    public static Set<Id> processedRecordIds_sendProjectRoleNotifications_NotificationPicklist = new Set<Id>();
    public static void sendProjectRoleNotifications(List<Project_Role__c> newList, Map<Id, Project_Role__c> oldMap) {

      List<Project_Role__c> lstProjectRoleEmails_NotificationPicklistBased = new List<Project_Role__c>();

      for(Project_Role__c objProjectRole : newList) {

        if(String.isNotBlank(objProjectRole.Project_Role_Notification_Type__c)) {
              // Setting values
              if(Trigger.isInsert && oldMap == null) {
                  System.debug('>>> INSERT Event -- Project_Role_Notification_Type__c = ' + objProjectRole.Project_Role_Notification_Type__c);
                  if(String.isNotBlank(objProjectRole.Project_Role_Notification_Type__c)
                     && !processedRecordIds_sendProjectRoleNotifications_NotificationPicklist.contains(objProjectRole.Id)) {
                         lstProjectRoleEmails_NotificationPicklistBased.add(objProjectRole);
                         processedRecordIds_sendProjectRoleNotifications_NotificationPicklist.add(objProjectRole.Id);
                     }
              }
              // Updates
              if(Trigger.isUpdate && oldMap != null) {
                  if(oldMap.get(objProjectRole.id) != null) {
                      System.debug('>>> UPDATE Event -- NEW Project_Role_Notification_Type__c = ' + objProjectRole.Project_Role_Notification_Type__c +
                                   ' OLD Project_Role_Notification_Type__c = ' + oldMap.get(objProjectRole.id).Project_Role_Notification_Type__c);
                  }
                  if((String.isNotBlank(objProjectRole.Project_Role_Notification_Type__c) &&
                      !objProjectRole.Project_Role_Notification_Type__c.equalsIgnoreCase(oldMap.get(objProjectRole.id).Project_Role_Notification_Type__c))
                     && (!processedRecordIds_sendProjectRoleNotifications_NotificationPicklist.contains(objProjectRole.Id))) {
                         lstProjectRoleEmails_NotificationPicklistBased.add(objProjectRole);
                         processedRecordIds_sendProjectRoleNotifications_NotificationPicklist.add(objProjectRole.Id);
                     }
              }
        }
      }

      if(lstProjectRoleEmails_NotificationPicklistBased.size() > 0) {
          //CORE_EmailNotificationUtil.corePrepareAndSendEmailViaEmailConfig_NotificationPicklistBased('Project_Role__c',lstProjectRoleEmails_NotificationPicklistBased,'Project_Role_Notification_Type__c', true);
      }

    }






}