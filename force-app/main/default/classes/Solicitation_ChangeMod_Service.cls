/*
* Class Name:  Solicitation_ChangeMod_Service
* Description: Utility class for Solicitation change modification related operations.
* Author/Date: Ajay Gautam/ 03/26/2017    Original [ Ref: S-00707 ]
*
* Date          New/Modified          Author            Description
* 03/26/2017    New                   Ajay Gautam       S-00705 / T-02179 Dev: Solicitation lock down
* 05/23/2017    Modified              Ajay Gautam       T-02361  Allow default project coordinator & contract office managers to initiate Change Modification Request
* 07/03/2017    Modified              Ajay Gautam       I-03053: Solicitation document attachments should not be editable without a change modification
*/

public without sharing class Solicitation_ChangeMod_Service {

   public static Boolean isChangeModAllowedForUser = false;
   public static String programContentPrefix = Program_Content__c.sObjectType.getDescribe().getKeyPrefix();
   public static final String CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION = 'Solicitation_Change_Modification';
   public static final String CASE_STATUS_UNSUBMITTED = 'Unsubmitted';
   public static final String CASE_STATUS_SUBMITTED = 'Submitted';
   
   // This will be invoked from Solicitation_TriggerHandler class
   // I-02707 allow on Insert
   /*
    * Method Name: lockDownSolicitationRecords_ALLOW_OnInsert
    * Description: This will be invoked from Solicitation_TriggerHandler class
    * @param: List<Program_Version__c> newListSolicitations
    * @param: Map<Id, Program_Version__c> oldMapSolicitations
    * @return: void
    *
    */
   public static void lockDownSolicitationRecords_ALLOW_OnInsert(List<Program_Version__c> newListSolicitations, Map<Id, Program_Version__c> oldMapSolicitations) {
     Boolean isInsert = (Trigger.isInsert || (newListSolicitations != null && oldMapSolicitations == null));
     for(Program_Version__c objSolicitation : newListSolicitations) {
       if(isInsert && oldMapSolicitations == null && !objSolicitation.Is_Apex_Context__c &&
              (
                objSolicitation.Solicitation_Announcement_Date__c != null
              )
              ) {
          objSolicitation.Is_Apex_Context__c = true;
       }
     }
   }

   // This will be invoked from Solicitation_TriggerHandler class
   // I-02707 allow on Insert
   /*
    * Method Name: lockDownSolicitationRecords_RESET_OnInsert
    * Description: This will be invoked from Solicitation_TriggerHandler class
    * @param: List<Program_Version__c> newListSolicitations
    * @param: Map<Id, Program_Version__c> oldMapSolicitations
    * @return: void
    *
    */
   public static void lockDownSolicitationRecords_RESET_OnInsert(List<Program_Version__c> newListSolicitations, Map<Id, Program_Version__c> oldMapSolicitations) {
     Boolean isInsert = (Trigger.isInsert || (newListSolicitations != null && oldMapSolicitations == null));
     Set<Id> solicitationIdsToRESET = new Set<Id>();
     for(Program_Version__c objSolicitation : newListSolicitations) {
       if(isInsert && oldMapSolicitations == null && objSolicitation.Is_Apex_Context__c) {
          solicitationIdsToRESET.add(objSolicitation.Id);
       }
     }
     if(solicitationIdsToRESET.size() > 0) {
       lockDownSolicitationRecords_RESET_OnInsert_FutureMethod(solicitationIdsToRESET);
     }
   }

    /*
    * Method Name: lockDownSolicitationRecords_RESET_OnInsert_FutureMethod
    * Description: Future method
    * @param: Set<Id> solicitationIdsToRESET
    * @return: void
    *
    */
   @future
   public static void lockDownSolicitationRecords_RESET_OnInsert_FutureMethod(Set<Id> solicitationIdsToRESET) { // I-02707
     List<Program_Version__c> eligibleSolicitations = new List<Program_Version__c>();
     if(solicitationIdsToRESET != null && solicitationIdsToRESET.size() > 0) {
       for(Id solicitationId : solicitationIdsToRESET) {
         if(solicitationId != null) {
           eligibleSolicitations.add(new Program_Version__c(Id = solicitationId, Is_Apex_Context__c = false));
         }
       }
     }
     if(eligibleSolicitations.size() > 0) {
       Database.update(eligibleSolicitations, false);
     }
   }

  /*
    * Method Name: lockDownSolicitationRecords
    * Description: T-02179: This will be invoked from Solicitation_TriggerHandler class
    * @param: List<Program_Version__c> newListSolicitations
    * @param: Map<Id, Program_Version__c> oldMapSolicitations
    * @return: void
    *
    */
   public static void lockDownSolicitationRecords(List<Program_Version__c> newListSolicitations, Map<Id, Program_Version__c> oldMapSolicitations) {
     List<Program_Version__c> eligibleSolicitations = new List<Program_Version__c>();
     Boolean isInsert = (Trigger.isInsert || (newListSolicitations != null && oldMapSolicitations == null));
     Date dateToday = Date.today();
     Set<String> fieldNames = new Set<String>();

     // Get field names
     fieldNames.addAll(CORE_Helper.fetchFieldsFromFieldSet('Program_Version__c',Solicitation_Helper.SOLICITATION_TO_LOCKDOWN_FIELD_SET_API_NAME));

     Boolean isEligible = false;
     for(Program_Version__c objSolicitation : newListSolicitations) { // T-02278
       isEligible = false;
       if(!isInsert && oldMapSolicitations != null && !objSolicitation.Is_Apex_Context__c && fieldNames.size() > 0 &&
              CORE_Solicitation_Lockdown_Settings__c.getInstance().Lock_Solicitation__c &&
              ( 
                (
                  Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES.contains(objSolicitation.Solicitation_Type__c) &&
                  objSolicitation.Solicitation_Announcement_Date__c != null && objSolicitation.Solicitation_Announcement_Date__c <= dateToday &&
                  Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS.contains(objSolicitation.Status__c)
                ) ||
                (
                    // Check if they are not changing the Solicitation_Announcement_Date__c or Type or Status itself from the Solicitation record
                    oldMapSolicitations.get(objSolicitation.Id) != null &&
                    (    // OLD version
                         Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES.contains(oldMapSolicitations.get(objSolicitation.Id).Solicitation_Type__c) &&
                         oldMapSolicitations.get(objSolicitation.Id).Solicitation_Announcement_Date__c != null &&
                         oldMapSolicitations.get(objSolicitation.Id).Solicitation_Announcement_Date__c <= dateToday &&
                         Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS.contains(oldMapSolicitations.get(objSolicitation.Id).Status__c)
                    ) &&
                    (
                       // NEW version
                       !Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES.contains(objSolicitation.Solicitation_Type__c) ||
                       (objSolicitation.Solicitation_Announcement_Date__c == null || objSolicitation.Solicitation_Announcement_Date__c > dateToday) ||
                       !Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS.contains(objSolicitation.Status__c)
                    )
                )
              )
              ) {

           if(
              // Check and allow: if they are changing the UNLOCKED one to LOCKED.
              // This should be okay, because next time this will be problem, but not now.
              oldMapSolicitations.get(objSolicitation.Id) != null &&
              (    // OLD version
                 !Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES.contains(oldMapSolicitations.get(objSolicitation.Id).Solicitation_Type__c) ||
                 ( oldMapSolicitations.get(objSolicitation.Id).Solicitation_Announcement_Date__c == null ||
                   oldMapSolicitations.get(objSolicitation.Id).Solicitation_Announcement_Date__c > dateToday
                 ) ||
                 !Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS.contains(oldMapSolicitations.get(objSolicitation.Id).Status__c)
              ) &&
              (
                 // NEW version
                 Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES.contains(objSolicitation.Solicitation_Type__c) &&
                 objSolicitation.Solicitation_Announcement_Date__c != null &&
                 objSolicitation.Solicitation_Announcement_Date__c <= dateToday &&
                 Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS.contains(objSolicitation.Status__c)
              )
           ) {
            isEligible = false;
            break;
           }

           Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Program_Version__c').getDescribe().fields.getMap();
           String strValueOld, strValueNew;

           if(oldMapSolicitations.get(objSolicitation.Id) != null && objSolicitation.Is_Apex_Context__c == oldMapSolicitations.get(objSolicitation.Id).Is_Apex_Context__c) {
             for(String fieldAPIName : fieldNames) {
               if(!isEligible && (objSolicitation.get(fieldAPIName) != oldMapSolicitations.get(objSolicitation.Id).get(fieldAPIName))) {

                 System.debug('>>> lockdown for '+ fieldAPIName);
                 System.debug('>>> lockdown OLD '+ fieldAPIName + ' = ' + oldMapSolicitations.get(objSolicitation.Id).get(fieldAPIName));
                 System.debug('>>> lockdown NEW '+ fieldAPIName + ' = ' + objSolicitation.get(fieldAPIName));

                 if(objectFields.containsKey(fieldAPIName) &&
                    (   objectFields.get(fieldAPIName).getDescribe().getType() == Schema.DisplayType.TextArea
                    ||  objectFields.get(fieldAPIName).getDescribe().getType() == Schema.DisplayType.String)) {

                   if(objSolicitation.get(fieldAPIName) != null && oldMapSolicitations.get(objSolicitation.Id).get(fieldAPIName) != null) {

                     strValueOld = String.valueOf(oldMapSolicitations.get(objSolicitation.Id).get(fieldAPIName));
                     strValueNew = String.valueOf(objSolicitation.get(fieldAPIName));

                     System.debug('>>> lockdown OLD '+ strValueOld + ' = ' + strValueOld);
                     System.debug('>>> lockdown NEW '+ strValueNew + ' = ' + strValueNew);

                     if(String.isNotBlank(strValueNew) && strValueNew.equalsIgnoreCase(strValueOld)) {
                       // false alarm
                       // Long/Rich text area field - Trigger is detecting field change even when no changes are made to the field
                       continue;
                     }
                   }
                 }

                 isEligible = true;
                 eligibleSolicitations.add(objSolicitation);
                 break;
               }
             }

             /*
             if(!isEligible) {
                // Check if they are not changing the Solicitation_Announcement_Date__c or Type or Status itself from the Solicitation record
                if(
                  oldMapSolicitations.get(objSolicitation.Id) != null &&
                  (    // OLD version
                       Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES.contains(oldMapSolicitations.get(objSolicitation.Id).Solicitation_Type__c) &&
                       oldMapSolicitations.get(objSolicitation.Id).Solicitation_Announcement_Date__c != null &&
                       oldMapSolicitations.get(objSolicitation.Id).Solicitation_Announcement_Date__c <= dateToday &&
                       Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS.contains(oldMapSolicitations.get(objSolicitation.Id).Status__c)
                  ) &&
                  (
                     // NEW version
                     !Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES.contains(objSolicitation.Solicitation_Type__c) ||
                     (objSolicitation.Solicitation_Announcement_Date__c == null || objSolicitation.Solicitation_Announcement_Date__c > dateToday) ||
                     !Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS.contains(objSolicitation.Status__c)
                  )
                ){

                  isEligible = true;
                  eligibleSolicitations.add(objSolicitation);
                }
                }
             */

           }
       }
     }
     if(eligibleSolicitations.size() > 0) {
       for(Program_Version__c objSolicitationWithError : eligibleSolicitations) {
         objSolicitationWithError.addError(Label.CORE_Solicitation_Lockdown_error_message);
       }
     }
   }
  /*
    * Method Name: checkIfChangeModAllowedForUser
    * Description: check whether mod is allowed for user
    * @param: Id solicitationId
    * @return: Boolean
    *
    */  
   public static Boolean checkIfChangeModAllowedForUser(Id solicitationId) {
     Boolean bResult = false;
     Id loggedInUserId = UserInfo.getUserId();

     for(Program_Version__c objSolicitation : [SELECT Solicitation_Manager__c, Default_Project_Coordinator__c, Program_Manager__c
                                               FROM   Program_Version__c
                                               WHERE  Id = :solicitationId] ) {

       if(objSolicitation.Solicitation_Manager__c != null && objSolicitation.Solicitation_Manager__c == loggedInUserId) {
         bResult = true;
         break;
       }

       if(objSolicitation.Program_Manager__c != null && objSolicitation.Program_Manager__c == loggedInUserId) {
         bResult = true;
         break;
       }

       if(objSolicitation.Default_Project_Coordinator__c != null && objSolicitation.Default_Project_Coordinator__c == loggedInUserId) { // T-02361
         bResult = true;
         break;
       }

     }

     // T-02361
     for(Group objGrp : [SELECT DeveloperName,
                                (SELECT UserOrGroupId
                                 FROM   GroupMembers
                                 WHERE  UserOrGroupId = :loggedInUserId)
                        FROM    Group
                        WHERE   DeveloperName = :Solicitation_Helper.GROUP_API_NAME_CONTRACT_OFFICE_MANAGER]) {

       if(objGrp.GroupMembers != null && objGrp.GroupMembers.size() > 0) {
         bResult = true;
         break;
       }
     }

     return bResult;
   }


  /*
    * Method Name: initiateChangeModForSolicitation
    * Description: invoked from CORE_ReqChangeModBtn_WebService class
    * @param: Id solicitationId
    * @return: ID
    *
    */
   public static Id initiateChangeModForSolicitation(Id solicitationId) {
     Id caseId = null;
      Id rcdTypeSolicitationId = (Utility_RecordType_Helper.getRecordType('Case', CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION) != null ?
                                      Utility_RecordType_Helper.getRecordType('Case', CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION).Id :
                                      null
                                );
      if(solicitationId != null) {
        Utility_Copy_Sobject.copyAll(Solicitation_Helper.SOLICITATION_TO_CASE_MAPPING_METADATA_TYPE_API_NAME, solicitationId, true);

        for(Case objCase : [SELECT  Id
                            FROM    Case
                            WHERE   RecordTypeId = :rcdTypeSolicitationId
                            AND     Program_Version__c = :solicitationId
                            AND     Project__c = null
                            AND     Status = : CASE_STATUS_UNSUBMITTED ORDER BY LastModifiedDate DESC LIMIT 1]) {
          caseId = objCase.Id;
        } 
 
      } 
  
     return caseId;
   }  
 

  /*
    * Method Name: submitActionsOnSolicitationChangeModIfApplicable
    * Description: invoked From Case_TriggerHandler
    * @param: List<Case> newCaseList
    * @param: Map<Id,Case> oldMapCase
    * @return: void
    *
    */
   public static void submitActionsOnSolicitationChangeModIfApplicable(List<Case> newCaseList, Map<Id,Case> oldMapCase) {

      List<String> sourceObjectIds = new List<String> ();
      List<String> targetObjectIds = new List<String> ();
      List<Case> applicableCasesBeingSubmitted = new List<Case>();
      Boolean isInsert = (Trigger.isInsert || (newCaseList != null && oldMapCase == null) );

      Id rcdTypeSolicitationId = (Utility_RecordType_Helper.getRecordType('Case', CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION) != null ?
                                      Utility_RecordType_Helper.getRecordType('Case', CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION).Id :
                                      null
                                );

     if(rcdTypeSolicitationId != null) {

      for(Case objCase : newCaseList) {
        if(objCase.Project__c == null && objCase.Program_Version__c != null &&
            objCase.RecordTypeId == rcdTypeSolicitationId  && CASE_STATUS_SUBMITTED.equalsIgnoreCase(objCase.Status) &&
           (isInsert || (!isInsert && !objCase.Status.equalsIgnoreCase(oldMapCase.get(objCase.Id).Status)))) {

          applicableCasesBeingSubmitted.add(objCase);
        }
      }

        // Approval Process - Case
        List<Approval.ProcessRequest> lstApprovalProcessRequests = new List<Approval.ProcessRequest>();
        List<Case> lstCases_ToBeUnlocked = new List<Case>(); // Update: Lock down the Case when the Case mod is Submitted (T-01508)
        for(Case objCaseVar : applicableCasesBeingSubmitted) {
          // Prepare Approval Process Request
          Approval.ProcessSubmitRequest appProcessReq = new Approval.ProcessSubmitRequest();
          appProcessReq.setObjectID(objCaseVar.Id);
          lstApprovalProcessRequests.add(appProcessReq);
          // Should Not be Locked
          //lstCases_ToBeUnlocked.add(objCaseVar);
        }
        if(lstApprovalProcessRequests.size() > 0) {
          try {
            Approval.ProcessResult[] results = Approval.process(lstApprovalProcessRequests, false);
          } catch(Exception e) {
            // Do Nothing
            System.debug('Exception: ' + e.getMessage());
          } finally {
            // Unlock the Case records
            // Approval.UnlockResult[] unlockList = Approval.unlock(lstCases_ToBeUnlocked, false);
          }
        }
        //End Of: Approval Process - Case

     }


   }


  /* 
    * Method Name: approvalActionsOnSolicitationChangeModIfApplicable
    * Description: invoked From Case_TriggerHandler
    * @param: List<Case> newCaseList
    * @param: Map<Id,Case> oldMapCase
    * @return: void
    *
    */
   public static void approvalActionsOnSolicitationChangeModIfApplicable(List<Case> newCaseList, Map<Id,Case> oldMapCase) {

    List<String> sourceObjectIds = new List<String> ();
    List<String> targetObjectIds = new List<String> ();
     Boolean isInsert = (Trigger.isInsert || (newCaseList != null && oldMapCase == null) );

     Id rcdTypeSolicitationId = (Utility_RecordType_Helper.getRecordType('Case', CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION) != null ?
                                      Utility_RecordType_Helper.getRecordType('Case', CASE_RECORD_TYPE_DEV_NAME_SOLICITATION_CHANGE_MODIFICATION).Id :
                                      null
                                );

     if(rcdTypeSolicitationId != null) {

      for(Case objCase : newCaseList) {
        if(objCase.Project__c == null && objCase.Program_Version__c != null &&
            objCase.RecordTypeId == rcdTypeSolicitationId  && Case_Helper.CASE_STATUS_APPROVED.equalsIgnoreCase(objCase.Status) &&
           (isInsert || (!isInsert && !objCase.Status.equalsIgnoreCase(oldMapCase.get(objCase.Id).Status)))) {

          targetObjectIds.add(objCase.Program_Version__c);
          sourceObjectIds.add(objCase.Id); 
        }
      }

      if(newCaseList.size() == 1 && targetObjectIds.size() > 0 && sourceObjectIds.size() > 0 && sourceObjectIds.size() == targetObjectIds.size()) {
        Utility_Copy_Sobject.copyAll(Solicitation_Helper.SOLICITATION_TO_CASE_MAPPING_METADATA_TYPE_API_NAME, newCaseList[0].Id, false); // This will always be in Trigger.size == 1

        // Sync Program content documents

         Id documentRecordTypeId_CaseContent = (Utility_RecordType_Helper.getRecordType('Case_Content__c', 'Documents') != null ?
                                                  Utility_RecordType_Helper.getRecordType('Case_Content__c', 'Documents').Id :
                                                  null
                                                );

         Id documentRecordTypeId_ProgramContent = (Utility_RecordType_Helper.getRecordType('Program_Content__c', 'Document') != null ?
                                                  Utility_RecordType_Helper.getRecordType('Program_Content__c', 'Document').Id :
                                                  null
                                                );

        Map<Id, Integer> programContentWiseSizeMap = new Map<Id, Integer>();
        Map<Id,Id> sourceTargetIdMap = new Map<Id,Id>(); // Map to support Attachment Copy

        for(Program_Content__c objProgContent : [SELECT Id,
                                                       (SELECT  Id
                                                        FROM    Attachments)
                                                 FROM   Program_Content__c
                                                 WHERE  Program_Version__c = :newCaseList[0].Program_Version__c
                                                 AND    RecordTypeId = :documentRecordTypeId_ProgramContent]) {

          programContentWiseSizeMap.put(objProgContent.Id, objProgContent.Attachments.size());

        }


        for(Case_Content__c objCaseContent : [SELECT Id, Program_Content__c,
                                                     (SELECT  Id
                                                      FROM    Attachments)
                                              FROM    Case_Content__c
                                              WHERE   Case__c = :newCaseList[0].Id
                                              AND     Program_Content__c != NULL
                                              AND     RecordTypeId = :documentRecordTypeId_CaseContent]) {

          if(programContentWiseSizeMap.containsKey(objCaseContent.Program_Content__c)) {

            if(objCaseContent.Attachments.size() > 0 ) { //&& objCaseContent.Attachments.size() != programContentWiseSizeMap.get(objCaseContent.Program_Content__c))
              sourceTargetIdMap.put(objCaseContent.Id, objCaseContent.Program_Content__c);
            }

          }

        }

        if(sourceTargetIdMap.size() > 0)
        {

        Set<Id> targetIds = new Set<Id>();
        List<Attachment> lstAttachment = new List<Attachment>();
        Map<Id, Attachment> mapForLstAttachment_LatestOnTop = new Map<Id, Attachment>();
        List<Attachment> lstAttachment_ToBeDeleted = new List<Attachment>();
        Id targetId = null;
        if(sourceTargetIdMap != null && sourceTargetIdMap.size() > 0)
        {
            Map<Id, List<Attachment>> srcObjWiseAttachment = new Map<Id, List<Attachment>>();
            for(Attachment objAttach : [  SELECT  Name, ParentId, Body
                                          FROM    Attachment
                                          WHERE   ParentId IN :sourceTargetIdMap.keySet() ORDER BY ParentId, CreatedDate DESC])
            {

                lstAttachment_ToBeDeleted.add(objAttach);

                if(!srcObjWiseAttachment.containsKey(objAttach.ParentId))
                {
                    srcObjWiseAttachment.put(objAttach.ParentId, new List<Attachment>());
                }
                srcObjWiseAttachment.get(objAttach.ParentId).add(objAttach);
            }

            if(srcObjWiseAttachment.size() > 0)
            {
                for(Id srcId : sourceTargetIdMap.keySet())
                {
                    targetId = sourceTargetIdMap.get(srcId);

                    if(targetId != null && srcObjWiseAttachment.containsKey(srcId))
                    {
                        for(Attachment objAttachment : srcObjWiseAttachment.get(srcId))
                        {
                            targetIds.add(targetId);
                            Attachment attachment = new Attachment();
                            attachment.ParentId = targetId;
                            attachment.Name = objAttachment.Name;
                            attachment.Body = objAttachment.Body;

                            if(mapForLstAttachment_LatestOnTop.containsKey(targetId)) {
                              mapForLstAttachment_LatestOnTop.put(targetId, Attachment);
                            } else {
                              lstAttachment.add(attachment);
                            }
                        }
                    }
                }
                try
                {
                    if(lstAttachment.size() > 0 || mapForLstAttachment_LatestOnTop.size() > 0)
                    {
                        lstAttachment_ToBeDeleted = [SELECT Id FROM Attachment WHERE ParentId IN :targetIds];
                        if(lstAttachment_ToBeDeleted.size() > 0) {
                          delete lstAttachment_ToBeDeleted;
                        }
                        if(lstAttachment.size() > 0) {
                          insert lstAttachment;
                        }
                        if(mapForLstAttachment_LatestOnTop.size() > 0) {
                          Long startTime = DateTime.now().getTime();
                          Long finishTime = DateTime.now().getTime();
                          while ((finishTime - startTime) < 100) {
                              //sleep for 0.1s
                              finishTime = DateTime.now().getTime();
                          }
                          insert mapForLstAttachment_LatestOnTop.values();
                        }

                    }
                }
                catch (Exception e)
                {
                      // Do Nothing
                }
                finally
                {
                    lstAttachment  = new List<Attachment>();
                    lstAttachment_ToBeDeleted = new List<Attachment>();
                    mapForLstAttachment_LatestOnTop = new Map<Id, Attachment>();
                }
            }
        }


        }


        List<Program_Version__c> solicitations = new List<Program_Version__c>();
        for(Id solicitationId : targetObjectIds) {
          solicitations.add(new Program_Version__c(Id = solicitationId, Is_Apex_Context__c = false));
        }

        if(solicitations.size() > 0) {
          update solicitations;
        }
      }

     }


   }


  /*
  * Method Name: lockAttachmentsOnSolicitationProgContentDocs
  * Description: I-03053: Solicitation document attachments should not be editable without a change modification
  *              This will be invoked from AttachmentTriggerHandler class
  * @param: list<Attachment> lstAttachments
  * @return: void
  */
  public static void lockAttachmentsOnSolicitationProgContentDocs(list<Attachment> lstAttachments) {

    Date dateToday = Date.today();
    Set<Id> programContentIds = new Set<Id>();
    String strVersionId = '';
    Map<Id, List<Attachment>> programContentWiseAttachmentsMap_All = new Map<Id, List<Attachment>>();

    Id documentRecordTypeId = (
                               Utility_RecordType_Helper.getRecordType('Program_Content__c','Document') != null ?
                               Utility_RecordType_Helper.getRecordType('Program_Content__c','Document').Id :
                               null
                               );

    if( CORE_Solicitation_Lockdown_Settings__c.getInstance().Lock_Solicitation__c &&
        !CORE_Solicitation_Lockdown_Settings__c.getInstance().Can_Edit_Program_Content_if_locked__c &&
        !System.isFuture()) {

        // Check if attachments are on program contents
        for(Attachment objAttachment : lstAttachments) {
          if(objAttachment.ParentId != null) {
            strVersionId = objAttachment.ParentId;
            if(strVersionId != null && strVersionId.startsWith(programContentPrefix)) {
              programContentIds.add(objAttachment.ParentId);
              if(!programContentWiseAttachmentsMap_All.containsKey(objAttachment.ParentId)) {
                programContentWiseAttachmentsMap_All.put(objAttachment.ParentId, new List<Attachment>());
              }
              programContentWiseAttachmentsMap_All.get(objAttachment.ParentId).add(objAttachment);
            }
          }
        }

        // Find program contents which are eligible for locking
        if(programContentIds.size() > 0) {
          for(Program_Content__c objProgContent : [ SELECT  Id
                                                    FROM    Program_Content__c
                                                    WHERE   Id IN :programContentIds
                                                    AND     RecordTypeId = :documentRecordTypeId
                                                    AND     Type__c != :ProgramContent_Helper.TYPE_SCORING_RUBRIC
                                                    AND     Program_Version__r.Status__c IN :Solicitation_Helper.LOCKDOWN_SOLICITATION_STATUS
                                                    AND     Program_Version__r.Solicitation_Type__c IN :Solicitation_Helper.LOCKDOWN_SOLICITATION_TYPES
                                                    AND     Program_Version__r.Solicitation_Announcement_Date__c <= :dateToday
                                                    AND     Program_Version__r.Is_Apex_Context__c = false
                                                    AND     RecordTypeId != NULL]) {
             if(programContentWiseAttachmentsMap_All.containsKey(objProgContent.Id)) {
               for(Attachment objAttachmentWithErr : programContentWiseAttachmentsMap_All.get(objProgContent.Id)) {
                 objAttachmentWithErr.addError(System.Label.Core_Solicitation_ProgramContent_Attachment_Lockdown_Error_Msg);
               }
             } 
          }  
        }
      }

  } // EndOf: lockAttachmentsOnSolicitationProgContentDocs


}