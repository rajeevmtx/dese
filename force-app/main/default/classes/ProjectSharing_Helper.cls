/*
* Class Name:  ProjectSharing_Helper
* Description: Helper class specific to sharing for Projects and child records
               This class is broken up into three main parts:
               1) Handle sharing when there is DML around project roles.  This requires granting/removing access
               on the project object as well as any existing child objects
               2) Handle sharing when there is DML around child objects of a project that aren't Master/Detail (Documents).
                This is a series of generic trigger-like methods (after insert) that can be called from a TriggerHandler.
               3) Handle sharing when a new community user is created.
               This grants access to all projects and child objects for the account the user is tied to.
* Author/Date:  Das Nobel ,  1/16/2016
*
*/

// January 10, 2016     George Acker     original

public without sharing class ProjectSharing_Helper
{
    public static final String documentApiName = 'Project_Document__c';
    public static final String documentProjectRef = 'Project__c';
    public static final String documentCaseRef = 'Case__c';

  /*
  * Method Name: afterInsertUser
  * Description: handles sharing when users are inserted
  * @param: User[] newList
  * @return: static void
  */

    public static void afterInsertUser(User[] newList)
    {
        shareByUser(newList);
    }

  /*
  * Method Name: shareByUser
  * Description: Method for sharing record with users
  * @param: User[] userList
  * @return: static void
  */

    public static void shareByUser(User[] userList)
    {
        Map<Id,Utility_Sharing.SharingRecordUser[]> accountUsers = new Map<Id,Utility_Sharing.SharingRecordUser[]>();
        for (User u :userList)
        {
            if (u.AccountId != null)
            {
                if (!accountUsers.containsKey(u.AccountId))
                    accountUsers.put(u.AccountId,new Utility_Sharing.SharingRecordUser[]{});
                accountUsers.get(u.AccountId).add(new Utility_Sharing.SharingRecordUser(u.Id,Utility_Sharing.ACCESS_WRITE));
            }
        }

        Set<Id> projectsToQuery = new Set<Id>();

        // build out what records need what users added
        Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
        Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap = new Map<Id,Utility_Sharing.SharingRecord[]>();
        for (Project_Role__c r :[SELECT account__c,project__c,Permission__c, Project__r.Program_Version__r.Program__r.Use_Program_Approval_for_Sign_Up_Request__c
                     FROM Project_Role__c
                     WHERE account__c IN :accountUsers.keySet()])
        {
            if (accountUsers.containsKey(r.Account__c))
            {
                Utility_Sharing.SharingRecordUser[] users = accountUsers.get(r.Account__c);
                if (users.size() > 0)
                {
                  if(r.Project__r.Program_Version__r.Program__r.Use_Program_Approval_for_Sign_Up_Request__c){
                    for(Utility_Sharing.SharingRecordUser userRcd : users){
                      if(r.Permission__c == ProjectRole_Helper.ROLE_PERMISSION_READONLY){
                        userRcd.accessLevel = Utility_Sharing.ACCESS_READ;
                      }
                    }
                  }
                    Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(r.Project__c,users);
                    shareRecordsToGrant.add(shareGrant);
                    if (!shareRecordsToGrantMap.containsKey(r.Project__c))
                        shareRecordsToGrantMap.put(r.Project__c,new Utility_Sharing.SharingRecord[]{});
                    shareRecordsToGrantMap.get(r.Project__c).add(shareGrant);
                    projectsToQuery.add(r.Project__c);
                }
            }
        }
        processChildrenAndShareRecords(projectsToQuery,shareRecordsToGrantMap,null,shareRecordsToGrant,null);

        // Case: 00005585
        // Case Sharing: Share Case records related to Project using the existing Sharing Mechanism
        Set<Id> casesToQuery = new Set<Id>();
        List<Case_Role__c> caseRoleList = new List<Case_Role__c>();
        Utility_Sharing.SharingRecord[] shareRecordsToGrant_Case = new Utility_Sharing.SharingRecord[]{};
        Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap_Case = new Map<Id,Utility_Sharing.SharingRecord[]>();

        if(projectsToQuery != null && projectsToQuery.size() > 0) {

          for(Case_Role__c objCaseRole : [  SELECT  Account__c, Case__c
                                            FROM    Case_Role__c
                                            WHERE   Project__c IN :projectsToQuery
                                            AND     Account__c IN :accountUsers.keySet()
                                            AND     Case__c != null
                                            AND     Account__c != null]) {

            if (accountUsers.containsKey(objCaseRole.Account__c))
            {
                Utility_Sharing.SharingRecordUser[] users_case = accountUsers.get(objCaseRole.Account__c);
                if (users_case.size() > 0)
                {
                    Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(objCaseRole.Case__c,users_case);
                    shareRecordsToGrant_Case.add(shareGrant);

                    if (!shareRecordsToGrantMap_Case.containsKey(objCaseRole.Case__c)) {
                        shareRecordsToGrantMap_Case.put(objCaseRole.Case__c,new Utility_Sharing.SharingRecord[]{});
                    }
                    shareRecordsToGrantMap_Case.get(objCaseRole.Case__c).add(shareGrant);
                    casesToQuery.add(objCaseRole.Case__c);
                }
            }
          }
          // Share Case and related records
          if(casesToQuery.size() > 0) {
            processChildrenAndShareCaseRecords(casesToQuery,shareRecordsToGrantMap_Case,null,shareRecordsToGrant_Case,null);
          }

        } //EndOf Case: 00005585

    }

  /*
  * Method Name: afterInsertChild
  * Description: Method to call from trigger of a child object to handle sharing
  * @param: sObject[] newList, String sObjectType, String projectField
  * @return: static void
  */

    public static void afterInsertChild(sObject[] newList, String sObjectType, String projectField)
    {
        shareChildRecords(newList,null,sObjectType,projectField);
    }

  /*
  * Method Name: afterUpdateChild
  * Description: Method to call from trigger of a child object to handle sharing
  * @param: sObject[] newList, Map<Id,sObject> oldMap, String sObjectType, String projectField
  * @return: static void
  */

    public static void afterUpdateChild(sObject[] newList, Map<Id,sObject> oldMap, String sObjectType, String projectField)
    {
        shareChildRecords(newList,oldMap,sObjectType,projectField);
    }

  /*
  * Method Name: afterUndeleteChild
  * Description: Method to call from trigger of a child object to handle sharing
  * @param: sObject[] newList, String sObjectType, String projectField
  * @return: static void
  */

    public static void afterUndeleteChild(sObject[] newList, String sObjectType, String projectField)
    {
        shareChildRecords(newList,null,sObjectType,projectField);
    }

  /*
  * Method Name: shareChildRecords
  * Description: Method to sharing child records
  * @param: Project_Role__c[] newList, Map<Id,sObject> oldMap, String sObjectType, String projectField
  * @return: static void
  */
    @testVisible
    private static void shareChildRecords(Project_Role__c[] newList, Map<Id,sObject> oldMap, String sObjectType, String projectField)
    {
        Set<sObject> accessToGrant = new Set<sObject>();
        Set<sObject> accessToRemove = new Set<sObject>();
        Set<Id> projectsToQuery = new Set<Id>();

        if (newList != null)
        {
            for (sObject r :newList)
            {
                Id projectId = (Id) r.get(projectField);
                // if we are inserting or undeleting (or updating and project has changed)
                // then we need to add access
                if (projectId != null && (oldMap == null || (Id) oldMap.get(r.Id).get(projectField) != projectId))
                {
                    accessToGrant.add(r);
                    projectsToQuery.add(projectId);
                    system.debug(projectId);
                }
                // if we are updating and the old project value was populated and changed
                // then we need to remove access
                if (oldMap != null)
                {
                    Id oldProjectId = (Id) oldMap.get(r.Id).get(projectField);
                    if (oldProjectId != null && oldProjectId != projectId)
                    {
                        accessToRemove.add(oldMap.get(r.Id));
                        projectsToQuery.add(oldProjectId);
                    }
                }
            }
        }

        Set<Id> accountsToQuery = new Set<Id>();

        // Find accounts tied to projects we care about
        Map<Id,Set<Id>> projectAccountMap = new Map<Id,Set<Id>>();
        for (Project_Role__c r : [SELECT Account__c,Project__c FROM Project_Role__c WHERE Project__c IN :projectsToQuery])
        {
            if (!projectAccountMap.containsKey(r.Project__c))
                projectAccountMap.put(r.Project__c,new Set<Id>());
            projectAccountMap.get(r.Project__c).add(r.Account__c);
            accountsToQuery.add(r.Account__c);
        }
        accountsToQuery.remove(null);

        system.debug(accountsToQuery);
        // Find users tied to any accounts we need to add or remove access for
        Map<Id,Utility_Sharing.SharingRecordUser[]> accountUsers = new Map<Id,Utility_Sharing.SharingRecordUser[]>();
        for (User u :[SELECT Id,AccountId FROM User WHERE isActive = true and AccountId IN :accountsToQuery])
        {
            if (!accountUsers.containsKey(u.AccountId))
                accountUsers.put(u.AccountId,new Utility_Sharing.SharingRecordUser[]{});
            accountUsers.get(u.AccountId).add(new Utility_Sharing.SharingRecordUser(u.Id,Utility_Sharing.ACCESS_WRITE));
        }

        Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
        for (sObject r :accessToGrant)
        {
            Id projectId = (Id) r.get(projectField);
            if (projectAccountMap.containsKey(projectId))
            {
                for (Id accountId :projectAccountMap.get(projectId))
                {
                    if (accountUsers!=null && accountUsers.size() > 0 && accountUsers.containsKey(accountId))
                    {
                        Utility_Sharing.SharingRecordUser[] users = accountUsers.get(accountId);
                        if (users!=null && users.size() > 0)
                        {
                            Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(r.Id,users);
                            shareRecordsToGrant.add(shareGrant);
                        }
                    }
                }
            }
        }

        Utility_Sharing.SharingRecord[] shareRecordsToRemove = new Utility_Sharing.SharingRecord[]{};
        for (sObject r :accessToRemove)
        {
            Id projectId = (Id) r.get(projectField);
            if (projectAccountMap!=null && projectAccountMap.containsKey(projectId))
            {
                for (Id accountId :projectAccountMap.get(projectId))
                {
                    if (accountUsers!=null && accountUsers.size()!=0 && accountUsers.containsKey(accountId))
                    {
                        Utility_Sharing.SharingRecordUser[] users = accountUsers.get(accountId);
                        if (users!=null && users.size() > 0)
                        {
                            Utility_Sharing.SharingRecord shareRemove = new Utility_Sharing.SharingRecord(r.Id,users);
                            shareRecordsToRemove.add(shareRemove);
                        }
                    }
                }
            }
        }

        // remove record access
        if (shareRecordsToRemove!=null && shareRecordsToRemove.size() > 0 && !string.isBlank(sObjectType))
            Utility_Sharing.unshareObjects(sObjectType,shareRecordsToRemove);

        // grant record access
        if (shareRecordsToGrant!=null && shareRecordsToGrant.size() > 0 && !string.isBlank(sObjectType))
            Utility_Sharing.shareObjects(sObjectType,shareRecordsToGrant);
    }

   /*
    * Method Name: shareProjectRecords
    * Description: Method to handle sharing for Projects when Project_Role__c records fire triggers
    * @param: Project_Role__c[] newList, Map<Id,Project_Role__c> oldMap, Project_Role__c[] oldList
    * @return: static void
    */

    public static void shareProjectRecords(Project_Role__c[] newList, Map<Id,Project_Role__c> oldMap, Project_Role__c[] oldList)
    {
        Set<Project_Role__c> accessToGrant = new Set<Project_Role__c>();
        Set<Project_Role__c> accessToRemove = new Set<Project_Role__c>();
        Set<Id> accountsToQuery = new Set<Id>();
        Set<Id> projectsToLookupRoles = new Set<Id>();


        // insert, update, undelete
        if (newList != null)
        {
            for (Project_Role__c r : [SELECT Id, account__c,project__c,Permission__c, Project__r.Program_Version__r.Program__r.Use_Program_Approval_for_Sign_Up_Request__c
                          FROM Project_Role__c
                          WHERE Id IN :newList])
            {

                // if we are inserting or undeleting (or updating and account has changed + Permission updated) and account is populated
                // then we need to add access
                if (r.Account__c != null && (oldMap == null || oldMap.get(r.Id).Account__c != r.Account__c ||
                               oldMap.get(r.Id).Permission__c != r.Permission__c))
                {
                    accessToGrant.add(r);
                    accountsToQuery.add(r.Account__c);
                    projectsToLookupRoles.add(r.Project__c);
                }
                // if we are updating and the old account value was populated and changed
                // then we need to remove access
                if (oldMap != null && oldMap.get(r.Id).Account__c != null && oldMap.get(r.Id).Account__c != r.Account__c)
                {
                    accessToRemove.add(oldMap.get(r.Id));
                    accountsToQuery.add(oldMap.get(r.Id).Account__c);
                    projectsToLookupRoles.add(r.Project__c);
                }
            }
        }
        // delete
        if (oldList != null)
        {
            for (Project_Role__c r :oldList)
            {
                // if we are deleting and the record had an account we need to remove access
                if (r.Account__c != null)
                {
                    accessToRemove.add(r);
                    accountsToQuery.add(r.Account__c);
                    projectsToLookupRoles.add(r.Project__c);
                }
            }
        }

        // Find users tied to any accounts we need to add or remove access for
        Map<Id,Utility_Sharing.SharingRecordUser[]> accountUsers = new Map<Id,Utility_Sharing.SharingRecordUser[]>();
        Map<Id,Utility_Sharing.SharingRecordUser[]> accountUsersReadAccess = new Map<Id,Utility_Sharing.SharingRecordUser[]>();
        for (User u :[SELECT Id,AccountId FROM User WHERE AccountId IN :accountsToQuery AND IsActive =: true])
        {
            if (!accountUsers.containsKey(u.AccountId))
                accountUsers.put(u.AccountId,new Utility_Sharing.SharingRecordUser[]{});
            accountUsers.get(u.AccountId).add(new Utility_Sharing.SharingRecordUser(u.Id,Utility_Sharing.ACCESS_WRITE));
            if (!accountUsersReadAccess.containsKey(u.AccountId))
                accountUsersReadAccess.put(u.AccountId,new Utility_Sharing.SharingRecordUser[]{});
            accountUsersReadAccess.get(u.AccountId).add(new Utility_Sharing.SharingRecordUser(u.Id,Utility_Sharing.ACCESS_READ));
        }

        // Find other project roles tied to the projects we care about (excluding the ones in this set)
        // This is important in case the same account is added multiple times
        // We don't want to remove access if one of the 2 records is deleted
        sObject[] recordsToIgnore = newList == null ? oldList : newList;
        Map<Id,Set<Id>> otherProjectRoles = new Map<Id,Set<Id>>();
        for (Project_Role__c r :[SELECT Id,Project__c,Account__c FROM Project_Role__c WHERE Project__c IN :projectsToLookupRoles AND Id NOT IN :recordsToIgnore])
        {
            if (!otherProjectRoles.containsKey(r.Project__c))
                otherProjectRoles.put(r.Project__c,new Set<Id>());
            otherProjectRoles.get(r.Project__c).add(r.Account__c);
        }

        Set<Id> projectsToQuery = new Set<Id>();

        /* TBD with Ajay and Nik
        //grant read access to another CEC projects for a CEC account
        Map<Id,Project__c> cecProjectIdToProjectMap = new Map<Id,Project__c>();
        for(Project__c proj : [Select id,RecordTypeId FROM Project__c WHERE RecordTypeId =: CEC_CommunityHelper.PROJECT_RECORD_TYPE.Id]){
          cecProjectIdToProjectMap.put(proj.id, proj);
        }
        */

        // build out what records need what users added
        Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
        Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap = new Map<Id,Utility_Sharing.SharingRecord[]>();
        for (Project_Role__c r :accessToGrant)
        {
            if (!(otherProjectRoles.containsKey(r.Project__c) && otherProjectRoles.get(r.Project__c).contains(r.Account__c)))
            {
                if (accountUsers.containsKey(r.Account__c))
                {
                    Utility_Sharing.SharingRecordUser[] users = accountUsers.get(r.Account__c);
                    if (users.size() > 0)
                    {
                      if(r.Project__r.Program_Version__r.Program__r.Use_Program_Approval_for_Sign_Up_Request__c){
                      for(Utility_Sharing.SharingRecordUser userRcd : users){
                        if(r.Permission__c == ProjectRole_Helper.ROLE_PERMISSION_READONLY){
                          userRcd.accessLevel = Utility_Sharing.ACCESS_READ;
                        }
                      }
                    }
                        Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(r.Project__c,users);
                        shareRecordsToGrant.add(shareGrant);
                        if (!shareRecordsToGrantMap.containsKey(r.Project__c))
                            shareRecordsToGrantMap.put(r.Project__c,new Utility_Sharing.SharingRecord[]{});
                        shareRecordsToGrantMap.get(r.Project__c).add(shareGrant);
                        projectsToQuery.add(r.Project__c);
                    }
                }

                /* TBD with Ajay and Nik
                //CEC project Handling
                if (accountUsersReadAccess != null && accountUsersReadAccess.containsKey(r.Account__c)
                                                   && cecProjectIdToProjectMap.get(r.Project__c) != null)
                {
                    Utility_Sharing.SharingRecordUser[] users = accountUsersReadAccess.get(r.Account__c);
                    if (users.size() > 0)
                    {
                      for(Id projId : cecProjectIdToProjectMap.keySet()){
                        if(projId != r.Project__c){
                          Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(projId,users);
                            shareRecordsToGrant.add(shareGrant);
                            if (!shareRecordsToGrantMap.containsKey(projId))
                                shareRecordsToGrantMap.put(projId,new Utility_Sharing.SharingRecord[]{});
                            shareRecordsToGrantMap.get(projId).add(shareGrant);
                            projectsToQuery.add(projId);
                        }
                      }
                    }
                }
                */
            }
        }

        // build out what records need what users removed
        Utility_Sharing.SharingRecord[] shareRecordsToRemove = new Utility_Sharing.SharingRecord[]{};
        Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap = new Map<Id,Utility_Sharing.SharingRecord[]>();
        for (Project_Role__c r :accessToRemove)
        {
            if (!(otherProjectRoles.containsKey(r.Project__c) && otherProjectRoles.get(r.Project__c).contains(r.Account__c)))
            {
                if (accountUsers.containsKey(r.Account__c))
                {
                    Utility_Sharing.SharingRecordUser[] users = accountUsers.get(r.Account__c);
                    if (users.size() > 0)
                    {
                        Utility_Sharing.SharingRecord shareRemove = new Utility_Sharing.SharingRecord(r.Project__c,users);
                        shareRecordsToRemove.add(shareRemove);
                        if (!shareRecordsToRemoveMap.containsKey(r.Project__c))
                            shareRecordsToRemoveMap.put(r.Project__c,new Utility_Sharing.SharingRecord[]{});
                        shareRecordsToRemoveMap.get(r.Project__c).add(shareRemove);
                        projectsToQuery.add(r.Project__c);
                    }
                }
            }
        }

        processChildrenAndShareRecords(projectsToQuery,shareRecordsToGrantMap,shareRecordsToRemoveMap,shareRecordsToGrant,shareRecordsToRemove);
    }

    /*
    * Method Name: shareCaseRecords
    * Description: Method to handle sharing for Cases when Case_Role__c records fire triggers
    * @param: Case_Role__c[] newList, Map<Id,Case_Role__c> oldMap, Case_Role__c[] oldList
    * @return: static void
    */

    public static void shareCaseRecords(Case_Role__c[] newList, Map<Id,Case_Role__c> oldMap, Case_Role__c[] oldList)
    {
        Set<Case_Role__c> accessToGrant = new Set<Case_Role__c>();
        Set<Case_Role__c> accessToRemove = new Set<Case_Role__c>();
        Set<Id> accountsToQuery = new Set<Id>();
        Set<Id> casesToLookupRoles = new Set<Id>();


        // insert, update, undelete
        if (newList != null)
        {
            for (Case_Role__c r :newList)
            {
                // if we are inserting or undeleting (or updating and account has changed) and account is populated
                // then we need to add access
                if (r.Account__c != null && (oldMap == null || oldMap.get(r.Id).Account__c != r.Account__c))
                {
                    accessToGrant.add(r);
                    accountsToQuery.add(r.Account__c);
                    casesToLookupRoles.add(r.Case__c);
                }
                // if we are updating and the old account value was populated and changed
                // then we need to remove access
                if (oldMap != null && oldMap.get(r.Id).Account__c != null && oldMap.get(r.Id).Account__c != r.Account__c)
                {
                    accessToRemove.add(oldMap.get(r.Id));
                    accountsToQuery.add(oldMap.get(r.Id).Account__c);
                    casesToLookupRoles.add(r.Case__c);
                }
            }
        }
        // delete
        if (oldList != null)
        {
            for (Case_Role__c r :oldList)
            {
                // if we are deleting and the record had an account we need to remove access
                if (r.Account__c != null)
                {
                    accessToRemove.add(r);
                    accountsToQuery.add(r.Account__c);
                    casesToLookupRoles.add(r.Case__c);
                }
            }
        }

        // Find users tied to any accounts we need to add or remove access for
        Map<Id,Utility_Sharing.SharingRecordUser[]> accountUsers = new Map<Id,Utility_Sharing.SharingRecordUser[]>();
        for (User u :[SELECT Id,AccountId FROM User WHERE AccountId IN :accountsToQuery AND IsActive =: true])
        {
            if (!accountUsers.containsKey(u.AccountId))
                accountUsers.put(u.AccountId,new Utility_Sharing.SharingRecordUser[]{});
            accountUsers.get(u.AccountId).add(new Utility_Sharing.SharingRecordUser(u.Id,Utility_Sharing.ACCESS_WRITE));
        }

        // Find other project roles tied to the projects we care about (excluding the ones in this set)
        // This is important in case the same account is added multiple times
        // We don't want to remove access if one of the 2 records is deleted
        sObject[] recordsToIgnore = newList == null ? oldList : newList;
        Map<Id,Set<Id>> otherProjectRoles = new Map<Id,Set<Id>>();
        for (Case_Role__c r :[SELECT Id,Case__c,Account__c FROM Case_Role__c WHERE Case__c IN :casesToLookupRoles AND Id NOT IN :recordsToIgnore])
        {
            if (!otherProjectRoles.containsKey(r.Case__c))
                otherProjectRoles.put(r.Case__c,new Set<Id>());
            otherProjectRoles.get(r.Case__c).add(r.Account__c);
        }

        Set<Id> casesToQuery = new Set<Id>();

        // build out what records need what users added
        Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
        Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap = new Map<Id,Utility_Sharing.SharingRecord[]>();
        for (Case_Role__c r :accessToGrant)
        {
            if (!(otherProjectRoles.containsKey(r.Case__c) && otherProjectRoles.get(r.Case__c).contains(r.Account__c)))
            {
                if (accountUsers.containsKey(r.Account__c))
                {
                    Utility_Sharing.SharingRecordUser[] users = accountUsers.get(r.Account__c);
                    if (users.size() > 0)
                    {
                        Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(r.Case__c,users);
                        shareRecordsToGrant.add(shareGrant);
                        if (!shareRecordsToGrantMap.containsKey(r.Case__c))
                            shareRecordsToGrantMap.put(r.Case__c,new Utility_Sharing.SharingRecord[]{});
                        shareRecordsToGrantMap.get(r.Case__c).add(shareGrant);
                        casesToQuery.add(r.Case__c);
                    }
                }
            }
        }

        // build out what records need what users removed
        Utility_Sharing.SharingRecord[] shareRecordsToRemove = new Utility_Sharing.SharingRecord[]{};
        Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap = new Map<Id,Utility_Sharing.SharingRecord[]>();
        for (Case_Role__c r :accessToRemove)
        {
            if (!(otherProjectRoles.containsKey(r.Case__c) && otherProjectRoles.get(r.Case__c).contains(r.Account__c)))
            {
                if (accountUsers.containsKey(r.Account__c))
                {
                    Utility_Sharing.SharingRecordUser[] users = accountUsers.get(r.Account__c);
                    if (users.size() > 0)
                    {
                        Utility_Sharing.SharingRecord shareRemove = new Utility_Sharing.SharingRecord(r.Case__c,users);
                        shareRecordsToRemove.add(shareRemove);
                        if (!shareRecordsToRemoveMap.containsKey(r.Case__c))
                            shareRecordsToRemoveMap.put(r.Case__c,new Utility_Sharing.SharingRecord[]{});
                        shareRecordsToRemoveMap.get(r.Case__c).add(shareRemove);
                        casesToQuery.add(r.Case__c);
                    }
                }
            }
        }

        processChildrenAndShareCaseRecords(casesToQuery,shareRecordsToGrantMap,shareRecordsToRemoveMap,shareRecordsToGrant,shareRecordsToRemove);
    }

   /*
    * Method Name: processChildrenAndShareRecords
    * Description: Method to processing Children And Sharing Records
    * @param: Set<Id> projectsToQuery,Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap,Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap,Utility_Sharing.SharingRecord[] shareRecordsToGrant,Utility_Sharing.SharingRecord[] shareRecordsToRemove
    * @return: static void
    */

    private static void processChildrenAndShareRecords(Set<Id> projectsToQuery,
                                                       Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap,
                                                       Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap,
                                                       Utility_Sharing.SharingRecord[] shareRecordsToGrant,
                                                       Utility_Sharing.SharingRecord[] shareRecordsToRemove)
    {
        //query documents that belong to the projects we are granting/removing access
        sObject[] projectDocs = getChildRecords(documentApiName,documentProjectRef,projectsToQuery);
        Utility_Sharing.SharingRecord[] docRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
        Utility_Sharing.SharingRecord[] docRecordsToRemove = new Utility_Sharing.SharingRecord[]{};
        processChildRecordSharing(projectDocs,documentProjectRef,shareRecordsToGrantMap,shareRecordsToRemoveMap,docRecordsToGrant,docRecordsToRemove);

        // remove project access
        if (shareRecordsToRemove != null && shareRecordsToRemove.size() > 0)
            Utility_Sharing.unshareObjects('Project__c',shareRecordsToRemove);
        // remove document access
        if (docRecordsToRemove != null && docRecordsToRemove.size() > 0)
            Utility_Sharing.unshareObjects(documentApiName,docRecordsToRemove);
        // grant project access
        if (shareRecordsToGrant.size() > 0)
            Utility_Sharing.shareObjects('Project__c',shareRecordsToGrant);
        // grant document access
        if (docRecordsToGrant.size() > 0)
            Utility_Sharing.shareObjects(documentApiName,docRecordsToGrant);


    }

    /*
    * Method Name: processChildrenAndShareCaseRecords
    * Description: Method to processing children and sharing records on fire trigger
    * @param: Set<Id> casesToQuery,Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap,Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap, Utility_Sharing.SharingRecord[] shareRecordsToGrant, Utility_Sharing.SharingRecord[] shareRecordsToRemove
    * @return: static void
    */

    private static void processChildrenAndShareCaseRecords(Set<Id> casesToQuery,Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap,Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap, Utility_Sharing.SharingRecord[] shareRecordsToGrant, Utility_Sharing.SharingRecord[] shareRecordsToRemove)
    {
        //query documents that belong to the projects we are granting/removing access
        sObject[] projectDocs = getChildRecords(documentApiName,documentCaseRef,casesToQuery);
        Utility_Sharing.SharingRecord[] docRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
        Utility_Sharing.SharingRecord[] docRecordsToRemove = new Utility_Sharing.SharingRecord[]{};
        processChildRecordSharing(projectDocs,documentCaseRef,shareRecordsToGrantMap,shareRecordsToRemoveMap,docRecordsToGrant,docRecordsToRemove);

        // remove project access
        if (shareRecordsToRemove != null && shareRecordsToRemove.size() > 0)
            Utility_Sharing.unshareObjects('Case',shareRecordsToRemove);
        // remove document access
        if (docRecordsToRemove != null && docRecordsToRemove.size() > 0)
            Utility_Sharing.unshareObjects(documentApiName,docRecordsToRemove);
        // grant project access
        if (shareRecordsToGrant.size() > 0)
            Utility_Sharing.shareObjects('Case',shareRecordsToGrant);
        // grant document access
        if (docRecordsToGrant.size() > 0)
            Utility_Sharing.shareObjects(documentApiName,docRecordsToGrant);
    }

    /*
    * Method Name: getChildRecords
    * Description: Method to getting child records
    * @param: String sObjectType, String parentField, Set<Id> records
    * @return: static sObject[]
    */

    private static sObject[] getChildRecords(String sObjectType, String parentField, Set<Id> records)
    {
        return Database.Query('SELECT Id,' + CORE_Helper.doEscapeSingleQuotes(parentField) + ' FROM ' + CORE_Helper.doEscapeSingleQuotes(sObjectType) + ' WHERE ' + CORE_Helper.doEscapeSingleQuotes(parentField) + ' IN :records');
    }

    /*
    * Method Name: processChildRecordSharing
    * Description: Method to sharing child records
    * @param: sObject[] records, String parentField, Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap, Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap, Utility_Sharing.SharingRecord[] shareRecordsToGrant, Utility_Sharing.SharingRecord[] shareRecordsToRemove
    * @return: static void
    */

    private static void processChildRecordSharing(sObject[] records, String parentField, Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToGrantMap, Map<Id,Utility_Sharing.SharingRecord[]> shareRecordsToRemoveMap, Utility_Sharing.SharingRecord[] shareRecordsToGrant, Utility_Sharing.SharingRecord[] shareRecordsToRemove)
    {
        for (sObject r :records)
        {
            Id pId = (Id) r.get(parentField);
            if (shareRecordsToGrantMap.containsKey(pId))
            {
                for (Utility_Sharing.SharingRecord sr :shareRecordsToGrantMap.get(pId))
                {
                    shareRecordsToGrant.add(new Utility_Sharing.SharingRecord(r.Id,sr.users));
                }
            }
            if (shareRecordsToRemoveMap != null && shareRecordsToRemoveMap.containsKey(pId))
            {
                for (Utility_Sharing.SharingRecord sr :shareRecordsToRemoveMap.get(pId))
                {
                    shareRecordsToRemove.add(new Utility_Sharing.SharingRecord(r.Id,sr.users));
                }
            }
        }
    }

    /*
    * Method Name: ShareWithSolicitationReviewTeam
    * Description: handle sharing for projects with solicitation review team when project go to under review statuss
    * @param: Project__c[] newList, Map<Id,Project__c> oldMap
    * @return: static void
    */
    public static void ShareWithSolicitationReviewTeam(Project__c[] newList, Map<Id,Project__c> oldMap) {
    	
      List<Project__c> sumRankUnderReviewProjects = new List<Project__c>();
      List<Project__c> batchRankUnderReviewProjects = new List<Project__c>();
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationGrpWithReviewTeamMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationWithReviewTeamMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};

      Set<Id> projectIds_NonScoringMembers = new Set<Id>();

      for(Project__c project : newList) { 
        if( (project.Concept_Paper__c || project.Proposal__c)
              && project.Status__c.equalsIgnoreCase(Project_Helper.PROJECT_STATUS_UNDER_REVIEW)
              && !oldMap.get(project.Id).Status__c.equalsIgnoreCase(Project_Helper.PROJECT_STATUS_UNDER_REVIEW)) {

        if(project.Solicitation_Group__c != null) {
            batchRankUnderReviewProjects.add(project);
            //projectIds_NonScoringMembers.add(project.id); // Share records with non-scoring member in batch scoring
            solicitationGrpWithReviewTeamMap.put(project.Solicitation_Group__c, new List<Utility_Sharing.SharingRecordUser>());
        } else {
            sumRankUnderReviewProjects.add(project);
            solicitationWithReviewTeamMap.put(project.Program_Version__c, new List<Utility_Sharing.SharingRecordUser>());
        }

        }
      }

      // Share with group member in case of batch rank
      if(solicitationGrpWithReviewTeamMap.size() > 0) {
        shareRecordsToGrant.addAll(shareWithSolicitationReviewTeam_BatchRankGroups_Util(batchRankUnderReviewProjects, solicitationGrpWithReviewTeamMap.keySet()));
      }

      // Share with review team in case of sum rank
      if(solicitationWithReviewTeamMap.size() > 0) {
        shareRecordsToGrant.addAll(shareWithSolicitationReviewTeam_SumRank_Util(sumRankUnderReviewProjects, solicitationWithReviewTeamMap.keySet()));
      }

      // grant record access
      if (shareRecordsToGrant.size() > 0) {

        Utility_Sharing.sharingReasonOverride = Schema.Project__share.RowCause.Review_Team__c ;
        Utility_Sharing.shareObjects('Project__c',shareRecordsToGrant);

        Utility_Sharing.sharingReasonOverride = Schema.Project_Document__share.RowCause.Review_Team__c;
        solicitation_assignDocSharing(shareRecordsToGrant);

        Utility_Sharing.sharingReasonOverride = null;

        //if(projectIds_NonScoringMembers.size() > 0) {
          //shareWith_NonScoring_SolicitationReviewTeam_BatchRank_FutureMethod(projectIds_NonScoringMembers);
        //}

      }
    } 



   /*
    * Method Name: shareWith_NonScoring_SolicitationReviewTeam_BatchRank_FutureMethod
    * Description: Method to sharing SumRank_Util with Solicitation Review Team
    * @param: List<Project__c> sumRankUnderReviewProjects,Set<Id> solicitationIds
    * @return: static List<Utility_Sharing.SharingRecord>
    */

    /*

    @future
    public static void shareWith_NonScoring_SolicitationReviewTeam_BatchRank_FutureMethod (Set<Id> projectIds_NonScoringMembers) {

      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationWithReviewTeamMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};




      //Share with review team in case of sum rank
      if(solicitationIds != null && sumRankUnderReviewProjects != null &&
           solicitationIds.size() > 0 && sumRankUnderReviewProjects.size() > 0) {
        for(Solicitation_Review_Team__c reviewTeam: [SELECT Member__c, Solicitation__c
                                     FROM Solicitation_Review_Team__c
                                    WHERE Solicitation__c IN :solicitationIds
                                      AND (
                                           (Member__c != null AND Member__r.ContactId = null) OR
                                           (NDA_Signed_Date__c != null AND Member__r.ContactId != null)
                                          )]) {
            if(!solicitationWithReviewTeamMap.containsKey(reviewTeam.Solicitation__c)) {
              solicitationWithReviewTeamMap.put(reviewTeam.Solicitation__c, new List<Utility_Sharing.SharingRecordUser>());
            }
            solicitationWithReviewTeamMap.get(reviewTeam.Solicitation__c).add(new Utility_Sharing.SharingRecordUser(reviewTeam.Member__c,Utility_Sharing.ACCESS_WRITE));
          }

           for (Project__c project :sumRankUnderReviewProjects)
           {
                if (solicitationWithReviewTeamMap.containsKey(project.Program_Version__c))
                {
                    Utility_Sharing.SharingRecordUser[] users = solicitationWithReviewTeamMap.get(project.Program_Version__c);
                    if (users.size() > 0)
                    {
                        Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                        shareRecordsToGrant.add(shareGrant);
                    }
                }
            }

      }

      return shareRecordsToGrant;

    }

    */


   /*
    * Method Name: shareWithSolicitationReviewTeam_SumRank_Util
    * Description: Method to sharing SumRank_Util with Solicitation Review Team
    * @param: List<Project__c> sumRankUnderReviewProjects,Set<Id> solicitationIds
    * @return: static List<Utility_Sharing.SharingRecord>
    */

    public static List<Utility_Sharing.SharingRecord> shareWithSolicitationReviewTeam_SumRank_Util (List<Project__c> sumRankUnderReviewProjects,
                                                                                                    Set<Id> solicitationIds) {

      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationWithReviewTeamMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};

      //Share with review team in case of sum rank
      if(solicitationIds != null && sumRankUnderReviewProjects != null &&
           solicitationIds.size() > 0 && sumRankUnderReviewProjects.size() > 0) {
        for(Solicitation_Review_Team__c reviewTeam: [SELECT Member__c, Solicitation__c
                                     FROM Solicitation_Review_Team__c
                                    WHERE Solicitation__c IN :solicitationIds
                                    AND   Member__c != NULL
                                    AND   Member__r.IsActive = true
                                      AND (
                                           (Member__c != null AND Member__r.ContactId = null) OR
                                           (NDA_Signed_Date__c != null AND Member__r.ContactId != null)
                                          )]) {
            if(!solicitationWithReviewTeamMap.containsKey(reviewTeam.Solicitation__c)) {
              solicitationWithReviewTeamMap.put(reviewTeam.Solicitation__c, new List<Utility_Sharing.SharingRecordUser>());
            }
            solicitationWithReviewTeamMap.get(reviewTeam.Solicitation__c).add(new Utility_Sharing.SharingRecordUser(reviewTeam.Member__c,Utility_Sharing.ACCESS_WRITE));
          }

           for (Project__c project :sumRankUnderReviewProjects)
           {
                if (solicitationWithReviewTeamMap.containsKey(project.Program_Version__c))
                {
                    Utility_Sharing.SharingRecordUser[] users = solicitationWithReviewTeamMap.get(project.Program_Version__c);
                    if (users.size() > 0)
                    {
                        Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                        shareRecordsToGrant.add(shareGrant);
                    }
                }
            }

      }

      return shareRecordsToGrant;

    }

    /*
    * Method Name: shareWithSolicitationReviewTeam_BatchRankGroups_Util
    * Description: Method to sharing BatchRankGroups_Util with Solicitation Review Team
    * @param: List<Project__c> batchRankUnderReviewProjects,Set<Id> solicitationGroupIds
    * @return: static List<Utility_Sharing.SharingRecord>
    */

    public static List<Utility_Sharing.SharingRecord> shareWithSolicitationReviewTeam_BatchRankGroups_Util (List<Project__c> batchRankUnderReviewProjects,
                                                                                                            Set<Id> solicitationGroupIds) {
      Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationGrpWithReviewTeamMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();

      // Share with group member in case of batch rank
      if(solicitationGroupIds != null && batchRankUnderReviewProjects != null &&
           solicitationGroupIds.size() > 0 && batchRankUnderReviewProjects.size() > 0) {

        // build out the list of user that require access to project
          for(Solicitation_Group_Member__c reviewTeam: [SELECT Solicitation_Review_Team__r.NDA_Signed_Date__c, Solicitation_Review_Team__r.Scoring_Committee__c,
                                                               Solicitation_Review_Team__r.Member__c, Solicitation_Review_Team__r.Member__r.ContactId,
                                                               Solicitation_Review_Team__c, Solicitation_Group__c
                                                        FROM   Solicitation_Group_Member__c
                                                        WHERE  Solicitation_Group__c IN : solicitationGroupIds
                                                        AND    Solicitation_Review_Team__r.Member__c != null
                                                        AND    Solicitation_Review_Team__r.Member__r.IsActive = true
                                                         AND (
                                                             (Solicitation_Review_Team__r.Member__c != null AND Solicitation_Review_Team__r.Member__r.ContactId = null)
                                                          OR (Solicitation_Review_Team__r.NDA_Signed_Date__c != null AND Solicitation_Review_Team__r.Member__r.ContactId != null)
                                                         )]) {

            if(!solicitationGrpWithReviewTeamMap.containsKey(reviewTeam.Solicitation_Group__c)) {
              solicitationGrpWithReviewTeamMap.put(reviewTeam.Solicitation_Group__c, new List<Utility_Sharing.SharingRecordUser>());
            }
            solicitationGrpWithReviewTeamMap.get(reviewTeam.Solicitation_Group__c).add(new Utility_Sharing.SharingRecordUser(reviewTeam.Solicitation_Review_Team__r.Member__c,Utility_Sharing.ACCESS_WRITE));
          }

          //Share projects with review team
            for (Project__c project :batchRankUnderReviewProjects)
            {
                if (solicitationGrpWithReviewTeamMap.containsKey(project.Solicitation_Group__c))
                {
                    Utility_Sharing.SharingRecordUser[] users = solicitationGrpWithReviewTeamMap.get(project.Solicitation_Group__c);
                    if (users.size() > 0)
                    {
                        Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                        shareRecordsToGrant.add(shareGrant);
                    }
                }
            }
      }
      return shareRecordsToGrant;
    }


    /*
    * Method Name: ShareWithSolicitationManager
    * Description: Method to handle sharing for projects with solicitation review team when project go to under review status
    * @param: Project__c[] newList, Map<Id,Project__c> oldMap
    * @return: static void
    */

    public static void ShareWithSolicitationManager(Project__c[] newList, Map<Id,Project__c> oldMap) {
      List<Project__c> underPendingReviewProjects = new List<Project__c>();
      for(Project__c project : newList) {
        if((project.Concept_Paper__c || project.Proposal__c) &&
            project.Program_Version__c != null && String.isNotBlank(project.Status__c) &&
            project.Status__c.equalsIgnoreCase(Project_Helper.PROJECT_STATUS_PENDING_REVIEW) &&
            !oldMap.get(project.Id).Status__c.equalsIgnoreCase(Project_Helper.PROJECT_STATUS_PENDING_REVIEW)) {

          underPendingReviewProjects.add(project);
        }
      }
      if(underPendingReviewProjects.size() > 0) {
        shareWithSolicitationManager_UtilOps(underPendingReviewProjects);
      }
    }

    /*
    * Method Name: shareWithSolicitationManager_UtilOps
    * Description: Utility Method to handle sharing for projects with solicitation review team when project go to under review status
    * @param: Project__c[] applicableProjects - list of projects to work on
    * @return: static void
    */
    public static void shareWithSolicitationManager_UtilOps(Project__c[] applicableProjects) {

      List<Project__c> underPendingReviewProjects = new List<Project__c>();
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationManagerMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationCoordinatorMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationProgramManagerMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();

      for(Project__c project : applicableProjects) {
        if(project.Program_Version__c != null && String.isNotBlank(project.Status__c)) {
          underPendingReviewProjects.add(project);
          solicitationManagerMap.put(project.Program_Version__c, new List<Utility_Sharing.SharingRecordUser>());
          solicitationCoordinatorMap.put(project.Program_Version__c, new List<Utility_Sharing.SharingRecordUser>());
          solicitationProgramManagerMap.put(project.Program_Version__c, new List<Utility_Sharing.SharingRecordUser>());
        }
      }

      //build out the list of user that require access to project
      for(Program_Version__c solicitation : [ SELECT  Solicitation_Manager__c, Default_Project_Coordinator__c, Program_Manager__c,
                                                      Solicitation_Manager__r.IsActive, Default_Project_Coordinator__r.IsActive, Program_Manager__r.IsActive
                                              FROM    Program_Version__c
                                              WHERE   Id IN: solicitationManagerMap.keySet()
                                              AND     (Solicitation_Manager__c != null OR Default_Project_Coordinator__c != null OR Program_Manager__c != null)]) {

        if(solicitation.Solicitation_Manager__c != null && solicitation.Solicitation_Manager__r.IsActive && solicitationManagerMap.containsKey(solicitation.Id)) {
          solicitationManagerMap.get(solicitation.Id).add(new Utility_Sharing.SharingRecordUser(solicitation.Solicitation_Manager__c, Utility_Sharing.ACCESS_WRITE));
        }

        if(solicitation.Default_Project_Coordinator__c != null && solicitation.Default_Project_Coordinator__r.IsActive && solicitationCoordinatorMap.containsKey(solicitation.Id)) {
          solicitationCoordinatorMap.get(solicitation.Id).add(new Utility_Sharing.SharingRecordUser(solicitation.Default_Project_Coordinator__c, Utility_Sharing.ACCESS_WRITE));
        }

        // I-03009 - Added Program Manager to the sharing list
        if(solicitation.Program_Manager__c != null && solicitation.Program_Manager__r.IsActive && solicitationProgramManagerMap.containsKey(solicitation.Id)) {
          solicitationProgramManagerMap.get(solicitation.Id).add(new Utility_Sharing.SharingRecordUser(solicitation.Program_Manager__c, Utility_Sharing.ACCESS_WRITE));
        }
        // I-03009 - Added Program Manager to the sharing list

      }

      //Share projects with Solicitation Manager
      Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
        for (Project__c project : underPendingReviewProjects)
        {
            if (solicitationManagerMap.containsKey(project.Program_Version__c))
            {
                Utility_Sharing.SharingRecordUser[] users = solicitationManagerMap.get(project.Program_Version__c);
                if (users.size() > 0)
                {
                    Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                    shareRecordsToGrant.add(shareGrant);
                }
            }

            if (solicitationCoordinatorMap.containsKey(project.Program_Version__c))
            {
                Utility_Sharing.SharingRecordUser[] users = solicitationCoordinatorMap.get(project.Program_Version__c);
                if (users.size() > 0)
                {
                    Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                    shareRecordsToGrant.add(shareGrant);
                }
            }

            // I-03009
            if (solicitationProgramManagerMap.containsKey(project.Program_Version__c))
            {
                Utility_Sharing.SharingRecordUser[] users = solicitationProgramManagerMap.get(project.Program_Version__c);
                if (users.size() > 0)
                {
                    Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                    shareRecordsToGrant.add(shareGrant);
                }
            }


        }

        // grant record access
        if (shareRecordsToGrant.size() > 0) {

          Utility_Sharing.sharingReasonOverride = Schema.Project__share.RowCause.Solicitation_Management__c;
          Utility_Sharing.shareObjects('Project__c',shareRecordsToGrant);

          Utility_Sharing.sharingReasonOverride = Schema.Project_Document__share.RowCause.Solicitation_Management__c;
          solicitation_assignDocSharing(shareRecordsToGrant);

          Utility_Sharing.sharingReasonOverride = null;

        }
    }



    /*
    * Method Name: solicitation_assignDocSharing
    * Description: Method to Sharing documents using utility sharing
    * @param: Utility_Sharing.SharingRecord[] shareRecordsToGrant_PROJECTS
    * @return: static void
    */

    public static void solicitation_assignDocSharing(Utility_Sharing.SharingRecord[] shareRecordsToGrant_PROJECTS) {
      Set<Id> projectIds = new Set<Id>();
      Utility_Sharing.SharingRecord[] shareRecordsToGrant_DOCUMENTS = new Utility_Sharing.SharingRecord[]{};
      Map<Id, List<Utility_Sharing.SharingRecord>> projectWiseSharingMap = new Map<Id, List<Utility_Sharing.SharingRecord>>();

      if(shareRecordsToGrant_PROJECTS != null && shareRecordsToGrant_PROJECTS.size() > 0) {

        for(Utility_Sharing.SharingRecord objSharingClass : shareRecordsToGrant_PROJECTS) {
          if(objSharingClass.recordId != null) {
            projectIds.add(objSharingClass.recordId);
            if(!projectWiseSharingMap.containsKey(objSharingClass.recordId)) {
              projectWiseSharingMap.put(objSharingClass.recordId, new List<Utility_Sharing.SharingRecord>());
            }
            projectWiseSharingMap.get(objSharingClass.recordId).add(objSharingClass);
          }
        }

        for(Project__c  objProject : [SELECT Id,
                                            (SELECT Id
                                             FROM   Documents__r)
                                     FROM   Project__c
                                     WHERE  Id IN :projectIds]) {
          for(Utility_Sharing.SharingRecord objSharingClass : projectWiseSharingMap.get(objProject.Id)) {
            for(Project_Document__c objDoc : objProject.Documents__r) {
              Utility_Sharing.SharingRecord shareGrantDoc = new Utility_Sharing.SharingRecord(objDoc.Id,objSharingClass.users);
              shareRecordsToGrant_DOCUMENTS.add(shareGrantDoc);
            }
          }
        }

        if(shareRecordsToGrant_DOCUMENTS.size() > 0) {
          Utility_Sharing.shareObjects(documentApiName,shareRecordsToGrant_DOCUMENTS);
        }

      }

    }

}