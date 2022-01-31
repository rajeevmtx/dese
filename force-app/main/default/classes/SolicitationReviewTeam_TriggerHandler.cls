/*
*
* Class Name:  SolicitationReviewTeam_TriggerHandler
* Description:  Handler class fot SolicitationReviewTeam_Trigger
* Author/Date:  Harshit Jain / March 16, 2017
*
  Date          New/Modified    Author           Description
* 03/16/2017     New             Ajay Gautam      S-00704
* 07/17/2017     Modified        Ajay Gautam      Share records with non-scoring member in batch scoring
* 09/03/2017     Modified        Ajay Gautam      T-03099: Implement NDA Process for Internal Review Team and Scoring Committee Members
* 09/14/2017   Modified          Ajay Gautam        S-01055 - Multi round with concept paper and parallel activities
*
*
*/

public without sharing class SolicitationReviewTeam_TriggerHandler {

  /*
    * Method Name: afterUpdate
    * Description: Method to handle after update event's actions
    * @param: Map<Id, Solicitation_Review_Team__c>, Map<Id, Solicitation_Review_Team__c>
    * @return: void
  */
    public static void afterUpdate(Map<Id, Solicitation_Review_Team__c> newMap, Map<Id, Solicitation_Review_Team__c> oldMap) {
      shareProjectWithExternalUser(newMap, OldMap);
      shareProjectsWithReviewTeamOnSumRank((List<Solicitation_Review_Team__c>) Trigger.new, oldMap); // I-02738
      sendReviewTeamNotifications((List<Solicitation_Review_Team__c>) Trigger.new, oldMap); // T-03099
    }

    /*
    * Method Name: afterInsert
    * Description: Method to handle after insert event's actions
    * @param: List<Solicitation_Review_Team__c>, List<Solicitation_Review_Team__c>
    * @return: void
  */
    public static void afterInsert(List<Solicitation_Review_Team__c> newList, Map<Id, Solicitation_Review_Team__c> oldMap) {
      shareProjectsWithReviewTeamOnSumRank(newList, oldMap);
      //shareProjectsWithReviewTeamOnBatchRank(newList, null);
      sendReviewTeamNotifications(newList, null);
    } 

  /*
    * Method Name: afterDelete
    * Description: Method to handle after delete event's actions
    * @param: List<Solicitation_Review_Team__c>
    * @return: void
  */
    public static void afterDelete(List<Solicitation_Review_Team__c> oldReviewTeamList) {
      //dropProjectSharingAfterReviewTeamDelete(oldReviewTeamList, Schema.Project__share.RowCause.Review_Team__c);
    }
  

    /* Method Name: sendReviewTeamNotifications
    * Description: T-03099: Implement NDA Process for Internal Review Team and Scoring Committee Members
    * @param: list<Solicitation_Review_Team__c> newList
    * @param: Map<Id, Solicitation_Review_Team__c> oldMap -- old map
    * @return: void
    */

    public static Set<Id> processedRecordIds_sendReviewTeamNotifications_NotificationPicklist = new Set<Id>();
    public static void sendReviewTeamNotifications(List<Solicitation_Review_Team__c> newList, Map<Id, Solicitation_Review_Team__c> oldMap) {

      List<Solicitation_Review_Team__c> lstReviewTeam_NotificationPicklistBased = new List<Solicitation_Review_Team__c>();

      for(Solicitation_Review_Team__c objReviewTeam : newList) {

        if(String.isNotBlank(objReviewTeam.Notification_Type__c)) {
              // Setting values
              if(Trigger.isInsert && oldMap == null) {
                  System.debug('>>> INSERT Event -- Notification_Type__c = ' + objReviewTeam.Notification_Type__c);
                  if(String.isNotBlank(objReviewTeam.Notification_Type__c)
                     && !processedRecordIds_sendReviewTeamNotifications_NotificationPicklist.contains(objReviewTeam.Id)) {
                         lstReviewTeam_NotificationPicklistBased.add(objReviewTeam);
                         processedRecordIds_sendReviewTeamNotifications_NotificationPicklist.add(objReviewTeam.Id);
                     }
              }
              // Updates
              if(Trigger.isUpdate && oldMap != null) {

                  if(oldMap.get(objReviewTeam.id) != null) {
                      System.debug('>>> UPDATE Event -- NEW Notification_Type__c = ' + objReviewTeam.Notification_Type__c +
                                                      ' OLD Notification_Type__c = ' + oldMap.get(objReviewTeam.id).Notification_Type__c);
                  }

                  if((String.isNotBlank(objReviewTeam.Notification_Type__c) &&
                        !objReviewTeam.Notification_Type__c.equalsIgnoreCase(oldMap.get(objReviewTeam.id).Notification_Type__c))
                     && (!processedRecordIds_sendReviewTeamNotifications_NotificationPicklist.contains(objReviewTeam.Id))) {
                         lstReviewTeam_NotificationPicklistBased.add(objReviewTeam);
                         processedRecordIds_sendReviewTeamNotifications_NotificationPicklist.add(objReviewTeam.Id);
                     }
              }
        }
      }

      if(lstReviewTeam_NotificationPicklistBased.size() > 0) {
          /*CORE_EmailNotificationUtil.corePrepareAndSendEmailViaEmailConfig_NotificationPicklistBased( 'Solicitation_Review_Team__c',
                                                                                                      lstReviewTeam_NotificationPicklistBased,
                                                                                                      'Notification_Type__c', true);*/
      }

    }

 

    /*
    * Method Name: dropProjectSharingAfterReviewTeamDelete
    * Description: Delete project sharing if Review Team record is deleted.
                   Also invoked by SolicitationGroupMember_TriggerHandler.ShareProjectWithNewInsertedMember();
    * @param: List<Solicitation_Review_Team__c> oldReviewTeamList
    * @return: void
    * Update: 05/09/2017 - Ajay Gautam
    */
    public static void dropProjectSharingAfterReviewTeamDelete(List<Solicitation_Review_Team__c> oldReviewTeamList, String sharingReason) {
      Map<Id, Set<Id>> userIdWiseSolicitationMap =  new Map<Id, Set<Id>>();

      for(Solicitation_Review_Team__c objTeam : oldReviewTeamList) {
        if(objTeam.Solicitation__c != null && objTeam.Member__c != null) {
          if(!userIdWiseSolicitationMap.containsKey(objTeam.Member__c)) {
            userIdWiseSolicitationMap.put(objTeam.Member__c, new Set<Id>());
          }
          userIdWiseSolicitationMap.get(objTeam.Member__c).add(objTeam.Solicitation__c);
        }
      }

      if(userIdWiseSolicitationMap.size() > 0) {

        List<UserToSolicitationIdWrapper> lstUserToSolicitationIdWrapper = new List<UserToSolicitationIdWrapper>();
        for(Id userId : userIdWiseSolicitationMap.keySet()) {
          lstUserToSolicitationIdWrapper.add(new UserToSolicitationIdWrapper(userId, userIdWiseSolicitationMap.get(userId)));
        }
        String jsonVersionForCustomMap = JSON.serialize(lstUserToSolicitationIdWrapper);
        dropProjectSharingAfterReviewTeamDeleteOps_FutureMethod(jsonVersionForCustomMap, sharingReason);
      }

    }




    /*
      * Method Name: dropProjectSharingAfterReviewTeamDeleteOps_FutureMethod
      * Description: Method to drop project sharing
      * @param: String, String
      * @return: void
    */
    @future
    public static void dropProjectSharingAfterReviewTeamDeleteOps_FutureMethod(String jsonVersionForCustomMap, String sharingReason) {

      Set<Id> solicitationIds = new Set<Id>();
      Map<Id, Set<Id>> userIdWiseSolicitationMap = new Map<Id, Set<Id>>();
      Map<Id, Map<Id, List<Project__Share>>> userIdAndSolicitationWiseSharingMap = new Map<Id, Map<Id, List<Project__Share>>>();

      for( UserToSolicitationIdWrapper objWrapper :
                (List<UserToSolicitationIdWrapper>) JSON.deserialize(jsonVersionForCustomMap, List<UserToSolicitationIdWrapper>.class)) {

        userIdWiseSolicitationMap.put(objWrapper.userId, objWrapper.solicitationIds);
      }

      if(userIdWiseSolicitationMap != null && userIdWiseSolicitationMap.size() > 0 && String.isNotBlank(sharingReason) ) {

        for(Set<Id> solicitationIdLoop : userIdWiseSolicitationMap.values()) {
          solicitationIds.addAll(solicitationIdLoop);
        }
        solicitationIds.remove(null);

        if(solicitationIds.size() > 0) {

          // Find Project Sharing records
          Map<Id, List<Project__Share>> solicitationIdToShareMap = new Map<Id, List<Project__Share>>();

          for(Project__Share objShare : [SELECT UserOrGroupId, RowCause,
                                                Parent.Program_Version__c, ParentId, Id
                                         FROM   Project__Share
                                         WHERE  UserOrGroupId IN :userIdWiseSolicitationMap.keySet()
                                         AND    RowCause = :sharingReason
                                         AND    Parent.Program_Version__c IN :solicitationIds
                                         ORDER BY UserOrGroupId]) {

              if(!userIdAndSolicitationWiseSharingMap.containsKey(objShare.UserOrGroupId)) {
                userIdAndSolicitationWiseSharingMap.put(objShare.UserOrGroupId, new Map<Id, List<Project__Share>>());
              }
              solicitationIdToShareMap = userIdAndSolicitationWiseSharingMap.get(objShare.UserOrGroupId);

              if(!solicitationIdToShareMap.containsKey(objShare.Parent.Program_Version__c)) {
                solicitationIdToShareMap.put(objShare.Parent.Program_Version__c, new List<Project__Share>());
              }
              solicitationIdToShareMap.get(objShare.Parent.Program_Version__c).add(objShare);
          }

          // Delete Project sharing records
          List<Project__Share> lstSharesToBeDeleted = new List<Project__Share>();
          Map<Id, Set<Id>> userWiseProjectIds = new Map<Id, Set<Id>>();


          for(Id userId : userIdWiseSolicitationMap.keySet()) {
            Set<Id> projectIds = new Set<Id>();
            if(userIdAndSolicitationWiseSharingMap.containsKey(userId)) {
              for(Id solicitationIdOriginal : userIdWiseSolicitationMap.get(userId)) {
                if(userIdAndSolicitationWiseSharingMap.get(userId) != null
                    && userIdAndSolicitationWiseSharingMap.get(userId).containsKey(solicitationIdOriginal)) {
                  // Remove specific sharing only
                  lstSharesToBeDeleted.addAll(userIdAndSolicitationWiseSharingMap.get(userId).get(solicitationIdOriginal));

                  for(Project__Share objShareTemp : userIdAndSolicitationWiseSharingMap.get(userId).get(solicitationIdOriginal)) {
                    projectIds.add(objShareTemp.ParentId);
                  }
                }
              }
            }
            userWiseProjectIds.put(userId, projectIds);
          }

          if(lstSharesToBeDeleted.size() > 0) {
            delete lstSharesToBeDeleted;

            // Find Project Document sharing
            if(userWiseProjectIds.size() > 0) {

              // how many documents we can tackle here
              Integer iAvailableCount  = (Utility_Sharing.LIMIT_DML_ROWS_DEFINED - Limits.getDmlRows());

              Set<Id> projectIdsALL = new Set<Id>();
              for(Set<Id> projectIds : userWiseProjectIds.values()) {
                projectIdsALL.addAll(projectIds);
              }

              List<Project_Document__Share> lstDocShare = [SELECT UserOrGroupId, RowCause, ParentId
                                                           FROM   Project_Document__Share
                                                           WHERE  Parent.Project__c IN :projectIdsALL
                                                           AND    UserOrGroupId IN :userWiseProjectIds.keySet()
                                                           AND    RowCause = :sharingReason LIMIT :iAvailableCount];
              if(lstDocShare.size() > 0) {
                delete lstDocShare;
              }
            }
          }
        }
      }
    }



    // I-02738 and T-03099
    /*
    * Method Name: shareProjectsWithReviewTeamOnSumRank
    * Description: share project records for Sum Rank solicitation
    * @param: List<Solicitation_Review_Team__c> newReviewTeamList
    * @param: Map<Id, Solicitation_Review_Team__c> oldMap
    * @return: void
    * Added: 4/12/2017 - Ajay Gautam
    */
    private static void shareProjectsWithReviewTeamOnSumRank(List<Solicitation_Review_Team__c> newReviewTeamList, Map<Id, Solicitation_Review_Team__c> oldReviewTeamMap) {
      Boolean isInsert = (Trigger.isInsert || (newReviewTeamList != null && oldReviewTeamMap == null));
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationIdsToCheck = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Map<Id, List<Utility_Sharing.SharingRecordUser>> sumRankSolicitationToProcess = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();

      for(Solicitation_Review_Team__c objTeam : newReviewTeamList) {
        if(objTeam.Solicitation__c != null && objTeam.Member__c != null && objTeam.NDA_Signed_Date__c != null &&
              (isInsert || (!isInsert && oldReviewTeamMap != null && oldReviewTeamMap.get(objTeam.Id) != null &&
                                         objTeam.NDA_Signed_Date__c != oldReviewTeamMap.get(objTeam.Id).NDA_Signed_Date__c)
              )
            ) {
              if(!solicitationIdsToCheck.containsKey(objTeam.Solicitation__c)) {
                solicitationIdsToCheck.put(objTeam.Solicitation__c, new List<Utility_Sharing.SharingRecordUser>());
              }
              solicitationIdsToCheck.get(objTeam.Solicitation__c).add(new Utility_Sharing.SharingRecordUser(objTeam.Member__c, Utility_Sharing.ACCESS_WRITE));
        }
      }
      // Check if Sum Rank solicitation
      if(solicitationIdsToCheck.size() > 0) {
        for(Program_Version__c objSolicitation : [SELECT  Id, Score_Type__c
                                                  FROM    Program_Version__c
                                                  WHERE   Id IN :solicitationIdsToCheck.keySet()
                                                  AND     (Score_Type__c = :Solicitation_Helper.SUM_OF_RANK_SCORE_TYPE OR Score_Type__c = null)]) {
          sumRankSolicitationToProcess.put(objSolicitation.Id, solicitationIdsToCheck.get(objSolicitation.Id));
        }

        if(sumRankSolicitationToProcess.size() > 0) {
          // Share projects with review team
          Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
          for(Project__c project : [SELECT  Id, Program_Version__c,
                                            Solicitation_Round__c, Solicitation_Group__c
                                    FROM    Project__c
                                    WHERE   Program_Version__c IN: sumRankSolicitationToProcess.keySet()
                                    AND     Solicitation_Round__r.Status__c =: CORE_Helper.SOLICITATION_ROUND_OPEN_STATUS
                                    AND     Status__c = : Project_Helper.PROJECT_STATUS_UNDER_REVIEW]) {

            if(sumRankSolicitationToProcess.containsKey(project.Program_Version__c)) {
              Utility_Sharing.SharingRecordUser[] users = sumRankSolicitationToProcess.get(project.Program_Version__c);
              if (users.size() > 0) {
                Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                shareRecordsToGrant.add(shareGrant);
              }
            }
          }
          // grant record access
          if(shareRecordsToGrant.size() > 0) {

            //Utility_Sharing.sharingReasonOverride = Schema.Project__share.RowCause.Review_Team__c;
            Utility_Sharing.shareObjects('Project__c',shareRecordsToGrant);

            Utility_Sharing.sharingReasonOverride = Schema.Project_Document__share.RowCause.Review_Team__c;
            ProjectSharing_Helper.solicitation_assignDocSharing(shareRecordsToGrant);

            Utility_Sharing.sharingReasonOverride = null;
          }
        } 
      }
    }


    /*
    * Method Name: shareProjectsWithReviewTeamOnBatchRank
    * Description: share project records for Batch Rank solicitation
    * @param: List<Solicitation_Review_Team__c> newReviewTeamList
    * @param: Map<Id, Solicitation_Review_Team__c> oldMap
    * @return: void
    * Added: 07/19/2017 - Ajay Gautam
    */
    /*
    private static void shareProjectsWithReviewTeamOnBatchRank(List<Solicitation_Review_Team__c> newReviewTeamList, Map<Id, Solicitation_Review_Team__c> oldReviewTeamMap) {
      Boolean isInsert = (Trigger.isInsert || (newReviewTeamList != null && oldReviewTeamMap == null));
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationIdsToCheck = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Map<Id, List<Utility_Sharing.SharingRecordUser>> batchRankSolicitationToProcess = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();

      // Share projects with non-scoring members in readOnly mode for batch rank
      for(Solicitation_Review_Team__c objTeam : newReviewTeamList) {
        if(   objTeam.Solicitation__c != null && objTeam.Member__c != null && !objTeam.Scoring_Committee__c &&
            (!objTeam.Is_External_User__c || (objTeam.Is_External_User__c && objTeam.NDA_Signed_Date__c != null)) &&
            (isInsert && oldReviewTeamMap == null)
          ) {
          if(!solicitationIdsToCheck.containsKey(objTeam.Solicitation__c)) {
            solicitationIdsToCheck.put(objTeam.Solicitation__c, new List<Utility_Sharing.SharingRecordUser>());
          }
          solicitationIdsToCheck.get(objTeam.Solicitation__c).add(new Utility_Sharing.SharingRecordUser(objTeam.Member__c, Utility_Sharing.ACCESS_READ));
        }
      }
      // Check if Batch Rank solicitation
      if(solicitationIdsToCheck.size() > 0) {
        for(Program_Version__c objSolicitation : [SELECT  Id, Score_Type__c
                                                  FROM    Program_Version__c
                                                  WHERE   Id IN :solicitationIdsToCheck.keySet()
                                                  AND     (Score_Type__c = :Solicitation_Helper.BATCH_RANK_SCORE_TYPE)]) {
          batchRankSolicitationToProcess.put(objSolicitation.Id, solicitationIdsToCheck.get(objSolicitation.Id));
        }

        if(batchRankSolicitationToProcess.size() > 0) {
          // Share projects with review team
          Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};
          for(Project__c project : [SELECT  Id, Program_Version__c,
                                            Solicitation_Round__c, Solicitation_Group__c
                                    FROM    Project__c
                                    WHERE   Program_Version__c IN: batchRankSolicitationToProcess.keySet()
                                    AND     Solicitation_Round__r.Status__c =: CORE_Helper.SOLICITATION_ROUND_OPEN_STATUS
                                    AND     Status__c = : Project_Helper.PROJECT_STATUS_UNDER_REVIEW]) {

            if(batchRankSolicitationToProcess.containsKey(project.Program_Version__c)) {
              Utility_Sharing.SharingRecordUser[] users = batchRankSolicitationToProcess.get(project.Program_Version__c);
              if (users.size() > 0) {
                Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                shareRecordsToGrant.add(shareGrant);
              }
            }
          }
          // grant record access
          if(shareRecordsToGrant.size() > 0) {

            Utility_Sharing.sharingReasonOverride = Schema.Project__share.RowCause.Review_Team_Non_Scoring_Member__c;
            Utility_Sharing.shareObjects('Project__c',shareRecordsToGrant);

            Utility_Sharing.sharingReasonOverride = Schema.Project_Document__share.RowCause.Review_Team_Non_Scoring_Member__c;
            ProjectSharing_Helper.solicitation_assignDocSharing(shareRecordsToGrant);

            Utility_Sharing.sharingReasonOverride = null;
          }
        }
      }
    }
    */

    /*
    * Method Name: shareProjectWithExternalUser
    * Description: Share associated solicilation projects with external users once user sign there NDA
    * @param: Map<Id, Solicitation_Review_Team__c> newMap
    * @param: Map<Id, Solicitation_Review_Team__c> oldMap
    * @return: void
    * Added: 4/12/2017 - Ajay Gautam
    */
    private static void shareProjectWithExternalUser(Map<Id, Solicitation_Review_Team__c> newMap, Map<Id, Solicitation_Review_Team__c> oldMap) {
      Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationWithReviewTeamMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
      Set<Id> validReviewTeamIds = New Set<Id>();

      for(Solicitation_Review_Team__c team : newMap.values()) {
        if(team.NDA_Signed_Date__c != null && team.NDA_Signed_Date__c != oldMap.get(team.Id).NDA_Signed_Date__c) {
          validReviewTeamIds.add(team.Id);
        }
      }

      for(Solicitation_Group_Member__c grpMember: [SELECT  Solicitation_Group__c, Solicitation_Review_Team__c,
                                                           Solicitation_Review_Team__r.Member__c
                                                   FROM    Solicitation_Group_Member__c
                                                   WHERE   Solicitation_Review_Team__c IN: validReviewTeamIds]) {
        if(!solicitationWithReviewTeamMap.containsKey(grpMember.Solicitation_Group__c)) {
          solicitationWithReviewTeamMap.put(grpMember.Solicitation_Group__c, new List<Utility_Sharing.SharingRecordUser>());
        }
        solicitationWithReviewTeamMap.get(grpMember.Solicitation_Group__c).add(new Utility_Sharing.SharingRecordUser(grpMember.Solicitation_Review_Team__r.Member__c, Utility_Sharing.ACCESS_WRITE));
      }

      // Share projects with review team
      Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};

      for(Project__c project : [SELECT Id, Program_Version__c, Solicitation_Round__c, Solicitation_Group__c
                                FROM   Project__c
                                WHERE  Program_Version__c IN: solicitationWithReviewTeamMap.keySet()
                                AND    Solicitation_Round__r.Status__c =: CORE_Helper.SOLICITATION_ROUND_OPEN_STATUS
                                AND    Status__c =: Project_Helper.PROJECT_STATUS_UNDER_REVIEW]) {

        if(solicitationWithReviewTeamMap.containsKey(project.Solicitation_Group__c)) {
                Utility_Sharing.SharingRecordUser[] users = solicitationWithReviewTeamMap.get(project.Solicitation_Group__c);
                if (users.size() > 0) {
                    Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(project.Id,users);
                    shareRecordsToGrant.add(shareGrant);
                }
            }
      }

      // grant record access
        if(shareRecordsToGrant.size() > 0) {

          //Utility_Sharing.sharingReasonOverride = Schema.Project__share.RowCause.Review_Team__c;
          Utility_Sharing.shareObjects('Project__c',shareRecordsToGrant);

          Utility_Sharing.sharingReasonOverride = Schema.Project_Document__share.RowCause.Review_Team__c;
          ProjectSharing_Helper.solicitation_assignDocSharing(shareRecordsToGrant);

          Utility_Sharing.sharingReasonOverride = null;
        } 
    }

  /*
    * Class Name: UserToSolicitationIdWrapper
    * Description: Wrapper class to contain userId and solicitationIds
  */
    public class UserToSolicitationIdWrapper {
      Id userId;
      Set<Id> solicitationIds = new Set<Id>();
      public UserToSolicitationIdWrapper(Id userId, Set<Id> solicitationIds) {
        this.userId = userId;
        this.solicitationIds = solicitationIds;
      }
    }


}