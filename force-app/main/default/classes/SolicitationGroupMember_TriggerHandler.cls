/*
*
* Class Name:  SolicitationGroupMember_TriggerHandler
* Description:  Handler class fot SolicitationGroupMember_Trigger
* Author/Date:  
*
*/

public without sharing class SolicitationGroupMember_TriggerHandler {

  /*
    * Method Name: afterInsertEvent
    * Description: Method to handle after insert event actions
    * @param: List<Solicitation_Group_Member__c>
    * @return: void
  */
    public static void afterInsertEvent(List<Solicitation_Group_Member__c> newList) {
        ShareProjectWithNewInsertedMember(newList);
    }

  /*
    * Method Name: beforeDelete
    * Description: Method to handle before delete event actions
    * @param: List<Solicitation_Group_Member__c>
    * @return: void
  */
    public static void beforeDelete(List<Solicitation_Group_Member__c> oldGroupMemberList) {
      removeProjectSharingOnGroupMemberDelete(oldGroupMemberList);
    }


    /*
    * Method Name: removeProjectSharingOnGroupMemberDelete
    * Description: Remove project sharing if Group member is deleted
    * @param: List<Solicitation_Group_Member__c> oldGroupMemberList
    * @return: void
    * Update: 05/09/2017 - Ajay Gautam
    */

    private static void removeProjectSharingOnGroupMemberDelete(List<Solicitation_Group_Member__c> oldGroupMemberList) {
      Map<Id, Set<Id>> userIdWiseGroupMap =  new Map<Id, Set<Id>>();

      // Get all eligible Member__c
      for(Solicitation_Group_Member__c grpMemberObj : [ SELECT  Solicitation_Group__c, Solicitation_Review_Team__r.Member__c
                                                        FROM    Solicitation_Group_Member__c
                                                        WHERE   Id IN :oldGroupMemberList
                                                        AND     Solicitation_Review_Team__r.Scoring_Committee__c = true
                                                        AND     Solicitation_Review_Team__r.Member__c != NULL
                                                        AND     Solicitation_Review_Team__r.NDA_Signed_Date__c != null
                                                        ALL ROWS ]) {
          if(!userIdWiseGroupMap.containsKey(grpMemberObj.Solicitation_Review_Team__r.Member__c)) {
            userIdWiseGroupMap.put(grpMemberObj.Solicitation_Review_Team__r.Member__c, new Set<Id>());
          }
          userIdWiseGroupMap.get(grpMemberObj.Solicitation_Review_Team__r.Member__c).add(grpMemberObj.Solicitation_Group__c);
        }

      if(userIdWiseGroupMap.size() > 0) {
        List<UserToGroupIdWrapper> lstUserToGroupIdWrapper = new List<UserToGroupIdWrapper>();
        for(Id userId : userIdWiseGroupMap.keySet()) {
          lstUserToGroupIdWrapper.add(new UserToGroupIdWrapper(userId, userIdWiseGroupMap.get(userId)));
        }
        String jsonVersionForCustomMap = JSON.serialize(lstUserToGroupIdWrapper);
        //deleteProjectSharingOnGroupMemberDeleteOps_FutureMethod(jsonVersionForCustomMap, Schema.Project__share.RowCause.Review_Team__c);
      }
    }

  /*
    * Method Name: deleteProjectSharingOnGroupMemberDeleteOps_FutureMethod
    * Description: Method to delete project sharing
    * @param: String, String
    * @return: void
  */
    @future
    public static void deleteProjectSharingOnGroupMemberDeleteOps_FutureMethod(String jsonVersionForCustomMap, String sharingReason) {

      Set<Id> groupIds = new Set<Id>();
      Set<Id> userIdsInScope = new Set<Id>();
      Map<Id, Set<Id>> userIdWiseGroupMap = new Map<Id, Set<Id>>();
      Map<Id, Map<Id, List<Project__Share>>> userIdAndGroupWiseSharingMap = new Map<Id, Map<Id, List<Project__Share>>>();
      Map<Id, List<Project__Share>> groupIdToShareMap = new Map<Id, List<Project__Share>>();

      for( UserToGroupIdWrapper objWrapper :
                (List<UserToGroupIdWrapper>) JSON.deserialize(jsonVersionForCustomMap, List<UserToGroupIdWrapper>.class)) {

        userIdWiseGroupMap.put(objWrapper.userId, objWrapper.groupIds);
        groupIds.addAll(objWrapper.groupIds);
        userIdsInScope.add(objWrapper.userId);
      }

      // Find Project Sharing records
      for(Project__Share objShare : [SELECT UserOrGroupId, RowCause,
                                            Parent.Solicitation_Group__c, ParentId, Id
                                     FROM   Project__Share
                                     WHERE  UserOrGroupId IN :userIdsInScope
                                     //AND    RowCause = :Schema.Project__share.RowCause.Review_Team__c
                                     AND    Parent.Solicitation_Group__c IN :groupIds
                                     ORDER BY UserOrGroupId]) {

          if(!userIdAndGroupWiseSharingMap.containsKey(objShare.UserOrGroupId)) {
            userIdAndGroupWiseSharingMap.put(objShare.UserOrGroupId, new Map<Id, List<Project__Share>>());
          }

          groupIdToShareMap = userIdAndGroupWiseSharingMap.get(objShare.UserOrGroupId);

          if(!groupIdToShareMap.containsKey(objShare.Parent.Solicitation_Group__c)) {
            groupIdToShareMap.put(objShare.Parent.Solicitation_Group__c, new List<Project__Share>());
          }
          groupIdToShareMap.get(objShare.Parent.Solicitation_Group__c).add(objShare);
      }

      // Delete Project sharing records
      List<Project__Share> lstSharesToBeDeleted = new List<Project__Share>();
      Map<Id, Set<Id>> userWiseProjectIds = new Map<Id, Set<Id>>();

      for(Id userId : userIdWiseGroupMap.keySet()) {
        Set<Id> projectIds = new Set<Id>();

        if(userIdAndGroupWiseSharingMap.containsKey(userId)) {
          for(Id groupIdOriginal : userIdWiseGroupMap.get(userId)) {
            if(userIdAndGroupWiseSharingMap.get(userId) != null
                && userIdAndGroupWiseSharingMap.get(userId).containsKey(groupIdOriginal)) {

              // Remove specific sharing only
              lstSharesToBeDeleted.addAll(userIdAndGroupWiseSharingMap.get(userId).get(groupIdOriginal));

              for(Project__Share objShareTemp : userIdAndGroupWiseSharingMap.get(userId).get(groupIdOriginal)) {
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

          System.debug('>>> iAvailableCount = ' + iAvailableCount);
          System.debug('>>> projectIdsALL  = ' + projectIdsALL);
          System.debug('>>> userWiseProjectIds.keySet()  = ' + userWiseProjectIds.keySet());

          List<Project_Document__Share> lstDocShare = [SELECT UserOrGroupId, RowCause, ParentId
                                                       FROM   Project_Document__Share
                                                       WHERE  Parent.Project__c IN :projectIdsALL
                                                       AND    UserOrGroupId IN :userWiseProjectIds.keySet()
                                                       /*AND    RowCause = :Schema.Project_Document__share.RowCause.Review_Team__c LIMIT :iAvailableCount*/];

          System.debug('>>> lstDocShare.size() = ' + lstDocShare.size());

          if(lstDocShare.size() > 0) {
            delete lstDocShare;
          }
        }
      }
    }


    /*
    * Method Name: ShareProjectWithNewInsertedMember
    * Description: Create project sharing if Review Team member is added to group
    * @param: List<Solicitation_Group_Member__c> newList
    * @return: void
    * Update: 05/09/2017 - Ajay Gautam
    */
    private static void ShareProjectWithNewInsertedMember(List<Solicitation_Group_Member__c> newList) {
        Map<Id, List<Utility_Sharing.SharingRecordUser>> solicitationGrpWithReviewTeamMap = new Map<Id, List<Utility_Sharing.SharingRecordUser>>();
        Utility_Sharing.SharingRecord[] shareRecordsToGrant = new Utility_Sharing.SharingRecord[]{};

        Map<Id, Solicitation_Review_Team__c> reviewTeamMap = new Map<Id,Solicitation_Review_Team__c>(); // Remove other sharings if added to a group
        Set<Id> reviewTeamIds = new Set<Id>();

        Set<Id> solicitationGroupIdSet = new Set<Id>();
        for(Solicitation_Group_Member__c groupMemberRec : newList) {
            solicitationGroupIdSet.add(groupMemberRec.Solicitation_Group__c);
        }
        solicitationGroupIdSet.remove(null);
        List<Solicitation_Group__c> solicitationGroupList = [SELECT Id,
                                                                    (SELECT Solicitation_Group__c
                                                                     FROM   Projects__r
                                                                     WHERE  Status__c = :Project_Helper.PROJECT_STATUS_UNDER_REVIEW)
                                                             FROM   Solicitation_Group__c
                                                             WHERE  Id IN: solicitationGroupIdSet];

        // Get all inserted Solicitation Member which has valid user and Signed NDA.
        List<Solicitation_Group_Member__c> groupMemberList = [SELECT  Solicitation_Group__c,
                                                                      Solicitation_Review_Team__r.Member__c,
                                                                      Solicitation_Review_Team__r.Solicitation__c,
                                                                      Solicitation_Review_Team__c
                                                              FROM    Solicitation_Group_Member__c
                                                              WHERE   Id IN: newList
                                                              AND     Solicitation_Review_Team__r.Scoring_Committee__c = true
                                                              AND     Solicitation_Review_Team__r.Member__c != NULL
                                                              AND     Solicitation_Review_Team__r.NDA_Signed_Date__c != NULL];

        for(Solicitation_Group_Member__c groupMemberRec : groupMemberList) {
            reviewTeamIds.add(groupMemberRec.Solicitation_Review_Team__c);
            if(!solicitationGrpWithReviewTeamMap.containsKey(groupMemberRec.Solicitation_Group__c)) {
                solicitationGrpWithReviewTeamMap.put(groupMemberRec.Solicitation_Group__c, new List<Utility_Sharing.SharingRecordUser>());
            }
            solicitationGrpWithReviewTeamMap.get(groupMemberRec.Solicitation_Group__c).add(new Utility_Sharing.SharingRecordUser(groupMemberRec.Solicitation_Review_Team__r.Member__c, Utility_Sharing.ACCESS_WRITE));
        }

        //Share projects with review team
        for (Solicitation_Group__c solicitationGroupRec : solicitationGroupList) {
            for(Project__c projectRec : solicitationGroupRec.Projects__r) {
                if (solicitationGrpWithReviewTeamMap.containsKey(projectRec.Solicitation_Group__c)) {
                    Utility_Sharing.SharingRecordUser[] users = solicitationGrpWithReviewTeamMap.get(projectRec.Solicitation_Group__c);
                    if (users.size() > 0) {
                        Utility_Sharing.SharingRecord shareGrant = new Utility_Sharing.SharingRecord(projectRec.Id, users);
                        shareRecordsToGrant.add(shareGrant);
                    }
                }
            }
        }

        // grant record access
        if (shareRecordsToGrant.size() > 0) {

            //Utility_Sharing.sharingReasonOverride = Schema.Project__share.RowCause.Review_Team__c;
            Utility_Sharing.shareObjects('Project__c',shareRecordsToGrant);

            //Utility_Sharing.sharingReasonOverride = Schema.Project_Document__share.RowCause.Review_Team__c;
            ProjectSharing_Helper.solicitation_assignDocSharing(shareRecordsToGrant);

            Utility_Sharing.sharingReasonOverride = null;
        }

        /*
        // Remove other sharings if added to a group
        if(reviewTeamIds.size() > 0) {
          reviewTeamMap = new Map<Id,Solicitation_Review_Team__c>([SELECT Id, Member__c, Solicitation__c
                                                                   FROM   Solicitation_Review_Team__c
                                                                   WHERE  Id IN :reviewTeamIds]);
          if(reviewTeamMap.size() > 0) {
            SolicitationReviewTeam_TriggerHandler.dropProjectSharingAfterReviewTeamDelete(reviewTeamMap.values(),
                                                                                          Schema.Project__share.RowCause.Review_Team_Non_Scoring_Member__c);
          }
        }
        */

    }

  /*
    * Class Name: UserToGroupIdWrapper
    * Description: Wrapper class to contain userId and groupIds info
  */
    public class UserToGroupIdWrapper {
      Id userId;
      Set<Id> groupIds = new Set<Id>();
      public UserToGroupIdWrapper(Id userId, Set<Id> groupIds) {
        this.userId = userId;
        this.groupIds = groupIds;
      }
    }


}