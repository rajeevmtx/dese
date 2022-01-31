//
/*
*   Class Name: Solicitation_Notification_Service
*   Description: S-00724  Innovation: Workflow notification
*
*/
public without sharing class Solicitation_Notification_Service {

  // Constants
  public static String solicitationRoundPrefix = Solicitation_Round__c.sObjectType.getDescribe().getKeyPrefix();
  public static String programContentPrefix = Program_Content__c.sObjectType.getDescribe().getKeyPrefix();
  public static String contractOfficeManagerGroup_API_Name = Label.Core_Contract_Office_Manager_Group_API_Name;
 

  /*
  * Method Name: manageSolicitationScoringUnderReviewNotifications_ReviewTeam
  * Description:  S-00724: Prompt Reviewers
  *         After Solicitation Manager has reviewed all proposals/concept paper and filtered out ineligible submissions,
  *            changes status of all applications to 'Under Review' and Salesforce automatically sends this email.
  *         This will be invoked from Solicitation_TriggerHandler class
  * @param: List<Program_Version__c> newListSolicitations
  * @param: Map<Id, Program_Version__c> oldMapSolicitations
  * @return: void 
  */
  public static void manageSolicitationScoringUnderReviewNotifications_ReviewTeam(List<Program_Version__c> newListSolicitations,
                                                                Map<Id, Program_Version__c> oldMapSolicitations) {

    List<Program_Version__c> solicitationNotifications_ConceptPaper = new List<Program_Version__c>();
    List<Program_Version__c> solicitationNotifications_Proposal = new List<Program_Version__c>();

    for(Program_Version__c objSolicitaion : newListSolicitations) {

      if(objSolicitaion.Notify_Review_Team_Concept_Paper__c || objSolicitaion.Notify_Review_Team_Proposal__c) { // Applicable Solicitations only.

        if(objSolicitaion.Notify_Review_Team_Concept_Paper__c &&
              (Trigger.isInsert || (!oldMapSolicitations.get(objSolicitaion.Id).Notify_Review_Team_Concept_Paper__c))) {
          // Concept Paper
          solicitationNotifications_ConceptPaper.add(objSolicitaion);

        } else if(objSolicitaion.Notify_Review_Team_Proposal__c &&
              (Trigger.isInsert || (!oldMapSolicitations.get(objSolicitaion.Id).Notify_Review_Team_Proposal__c))) {

          // Proposal
          solicitationNotifications_Proposal.add(objSolicitaion);
        }
      }

    }

    List<Program_Version__c> lstResetFlagsOnSolicitations = new List<Program_Version__c>();

    if(solicitationNotifications_ConceptPaper.size() > 0) {
      sendNotificationToReviewTeam_UnderReview_CP(solicitationNotifications_ConceptPaper);

      for(Program_Version__c objSolicitation : solicitationNotifications_ConceptPaper) {
        lstResetFlagsOnSolicitations.add(new Program_Version__c(Id = objSolicitation.Id, Notify_Review_Team_Concept_Paper__c = false));
      }

    }

    if(solicitationNotifications_Proposal.size() > 0) {
      sendNotificationToReviewTeam_UnderReview_Proposal(solicitationNotifications_Proposal);

      for(Program_Version__c objSolicitation : solicitationNotifications_Proposal) {
        lstResetFlagsOnSolicitations.add(new Program_Version__c(Id = objSolicitation.Id, Notify_Review_Team_Proposal__c = false));
      }
    }

    if(lstResetFlagsOnSolicitations.size() > 0) {
      update lstResetFlagsOnSolicitations;
    }

  }

  /*
  * Method Name: manageSolicitationScoringUnderReviewNotifications_ReviewTeam
  * Description: Send notifications 1) Review team - all members
  * @param: List<Program_Version__c> newListSolicitations
  * @return: void
  */
  public static void sendNotificationToReviewTeam_UnderReview_CP(List<Program_Version__c> newListSolicitations) {
    sendNotificationToReviewTeam_Ops(newListSolicitations,Label.Solicitation_Concept_Paper_Ready_for_Review_Notification_to_Scoring_API_Name, false, true);
  }

  /*
  * Method Name: sendNotificationToReviewTeam_UnderReview_Proposal
  * Description: Send notifications 1) Review team - all members
  * @param: List<Program_Version__c> newListSolicitations
  * @return: void
  */
  public static void sendNotificationToReviewTeam_UnderReview_Proposal(List<Program_Version__c> newListSolicitations) {
    sendNotificationToReviewTeam_Ops(newListSolicitations,Label.Solicitation_Proposal_Ready_for_Review_Notification_to_Scoring_API_Name, false, true);
  }


  /*
  * Method Name: manageSolicitationScoringUnderReviewNotifications_ReviewTeam
  * Description:  S-00724: Remind Reviewers
  *         All reviewers receive this 2 days before the date of the PROPOSAL scoring committee meeting,
  *             provided the status of all proposals is 'Under Review'
  *         This will be invoked from Solicitation_TriggerHandler class
  * @param: List<Program_Version__c> newListSolicitations
  * @param: Map<Id, Program_Version__c> oldMapSolicitations
  * @return: void 
  */
  public static void manageSolicitationScoringReminderNotifications_ReviewTeam(List<Program_Version__c> newListSolicitations,
                                                                Map<Id, Program_Version__c> oldMapSolicitations) {

    List<Program_Version__c> solicitationNotifications_ConceptPaper = new List<Program_Version__c>();
    List<Program_Version__c> solicitationNotifications_Proposal = new List<Program_Version__c>();

    for(Program_Version__c objSolicitaion : newListSolicitations) {

      if(objSolicitaion.Concept_Paper_Scoring_Committee_Reminder__c || objSolicitaion.Proposal_Scoring_Committee_Reminder__c) { // Applicable Solicitations only.

        if(objSolicitaion.Concept_Paper_Scoring_Committee_Reminder__c &&
              (Trigger.isInsert || (!oldMapSolicitations.get(objSolicitaion.Id).Concept_Paper_Scoring_Committee_Reminder__c))) {
          // Concept Paper
          solicitationNotifications_ConceptPaper.add(objSolicitaion);

        } else if(objSolicitaion.Proposal_Scoring_Committee_Reminder__c &&
              (Trigger.isInsert || (!oldMapSolicitations.get(objSolicitaion.Id).Proposal_Scoring_Committee_Reminder__c))) {

          // Proposal
          solicitationNotifications_Proposal.add(objSolicitaion);
        }
      }

    }

    List<Program_Version__c> lstResetFlagsOnSolicitations = new List<Program_Version__c>();

    if(solicitationNotifications_ConceptPaper.size() > 0) {
      sendNotificationToReviewTeam_Ops(solicitationNotifications_ConceptPaper,Label.Solicitation_Concept_Paper_review_Scoring_Committee_Reminder_Notif_API_Name, false, true);

      for(Program_Version__c objSolicitation : solicitationNotifications_ConceptPaper) {
        lstResetFlagsOnSolicitations.add(new Program_Version__c(Id = objSolicitation.Id, Concept_Paper_Scoring_Committee_Reminder__c = false));
      }

    }

    if(solicitationNotifications_Proposal.size() > 0) {
      sendNotificationToReviewTeam_Ops(solicitationNotifications_Proposal,Label.Solicitation_Proposal_Ready_for_Review_Notification_to_Scoring_API_Name, false, true);

      for(Program_Version__c objSolicitation : solicitationNotifications_Proposal) { 
        lstResetFlagsOnSolicitations.add(new Program_Version__c(Id = objSolicitation.Id, Proposal_Scoring_Committee_Reminder__c = false));
      }

    } 

    if(lstResetFlagsOnSolicitations.size() > 0) {
      update lstResetFlagsOnSolicitations;
    }

  }


  /*
  public static void validateFromRoundAndSendEmails(List<Program_Version__c> lstSolicitations) {

    Map<Id, Program_Version__c> solicitationMap = new Map<Id, Program_Version__c>();
    Map<Id, List<Solicitation_Group__c>> solicitationGroupsWithRoundIdMap = new Map<Id, List<Solicitation_Group__c>>();
    Set<Id> solicitationRoundIds_bothTypes = new Set<Id>();


    Map<Id, Map<Id, Solicitation_Review_Team__c>> solicitationWiseReviewMap_ALL = new Map<Id, Map<Id, Solicitation_Review_Team__c>>();
    Map<Id, Map<Id, Solicitation_Review_Team__c>> solicitationWiseReviewMap_Reminder = new Map<Id, Map<Id, Solicitation_Review_Team__c>>();


    if(lstSolicitations != null && lstSolicitations.size() > 0) {
      for(Program_Version__c objSolicitation : [SELECT  Id, Score_Type__c,
                                                        (SELECT Status__c, Concept_Paper_Finalize_Score__c, Due_Date__c,
                                                                Concept_Paper_Due_Date__c, Scoring_Committee_Date__c,
                                                                Concept_Paper_Finalize_Score_Date__c, Proposal_Finalize_Score__c,
                                                                Proposal_Finalize_Score_Date__c
                                                         FROM   Solicitation__r
                                                         WHERE  Scoring_Committee_Date__c > TODAY
                                                         AND    Concept_Paper_Finalize_Score__c = false
                                                         AND    Status__c  = :SolicitationRound_Helper.STATUS_OPEN ORDER BY Concept_Paper_Due_Date__c ASC LIMIT 1),
                                                        (SELECT Member__c, Scoring_Committee__c
                                                         FROM   Solicitation_Review_Team__r
                                                         WHERE  Member__c != null
                                                         AND    Scoring_Committee__c = true),
                                                         (SELECT  Id, Program_Version__c,
                                                                  Solicitation_Round__c, Solicitation_Group__c
                                                          FROM    Projects__r
                                                          WHERE   Program_Version__c IN: sumRankSolicitationToProcess.keySet()
                                                          AND     Solicitation_Round__r.Status__c =: CORE_Helper.SOLICITATION_ROUND_OPEN_STATUS
                                                          AND     Status__c = : Project_Helper.PROJECT_STATUS_UNDER_REVIEW LIMIT 1)
                                                FROM    Program_Version__c
                                                WHERE   Id IN :lstSolicitations]) {
        if(objSolicitation.Solicitation__r != null && objSolicitation.Solicitation__r.size() > 0 &&
           objSolicitation.Projects__r != null && objSolicitation.Projects__r.size() > 0) {

          // There is an Open round looking for reminder.
          solicitationMap.put(objSolicitation.Id, objSolicitation);
          solicitationRoundIds_bothTypes.add(objSolicitation.Solicitation__r[0].Id);
          // Assumption: Only one open at a time, if not the atleast one at a time to close.

          Map<Id, Solicitation_Review_Team__c> mapTEMP = new Map<Id, Solicitation_Review_Team__c>();
          for(Solicitation_Review_Team__c objTeam : objSolicitation.Solicitation_Review_Team__r) {
            mapTEMP.put(objTeam.Id, objTeam);
          }
          solicitationWiseReviewMap_ALL.put(objSolicitation.Id, mapTEMP);
          solicitationWiseReviewMap_Reminder.put(objSolicitation.Id, new Map<Id, Solicitation_Review_Team__c>());
        }
      }
    }

    if(solicitationMap.size() > 0 && solicitationRoundIds_bothTypes.size() > 0) {
      Set<Id> groupBasedSolicitationRoundIds = new Set<Id>();
      Set<Id> solicitationGroupIds = new Set<Id>();

      for(Program_Version__c objSolicitation : solicitationMap.values()) {
        if(Solicitation_Helper.BATCH_RANK_SCORE_TYPE.equalsIgnoreCase(objSolicitation.Score_Type__c)) {
          for(Solicitation_Round__c objRound : objSolicitation.Solicitation__r) {
            groupBasedSolicitationRoundIds.add(objRound.Id);
          }
        }
      }

      // Fetch groups if needed
      if(groupBasedSolicitationRoundIds.size() > 0) {
        for(Solicitation_Group__c objSoliGroup : [SELECT Solicitation_Round__c,
                                                        (SELECT Solicitation_Review_Team__c, Is_Solicitation_Manager__c,
                                                                Solicitation_Review_Team__r.Member__c
                                                         FROM   Solicitation_Group_Members__r),
                                                        (SELECT Solicitation_Group__c
                                                         FROM   Projects__r
                                                         WHERE  Status__c = :Project_Helper.PROJECT_STATUS_UNDER_REVIEW LIMIT 1)
                                                  FROM   Solicitation_Group__c
                                                  WHERE  Solicitation_Round__c IN :groupBasedSolicitationRoundIds
                                                  ORDER BY  Solicitation_Round__c]) {
          solicitationGroupIds.add(objSoliGroup.Id);
          if(!solicitationGroupsWithRoundIdMap.containsKey(objSoliGroup.Solicitation_Round__c)) {
            solicitationGroupsWithRoundIdMap.put(objSoliGroup.Solicitation_Round__c, new List<Solicitation_Group__c>());
          }
          solicitationGroupsWithRoundIdMap.get(objSoliGroup.Solicitation_Round__c).add(objSoliGroup);
        }
      }

      /
      // Fetch Projects with Score
      Map<Id, List<Project__c>> solicitationWiseProjects = new Map<Id, List<Project__c>>();
      Map<Id, Set<Id>> projectWiseScorer = new Map<Id, Set<Id>>();

      for(Project__c objProject : [SELECT Id,Solicitation_Group__c, Program_Version__c,
                                          (SELECT Score__c, Scoring_Committee_Member__c
                                           FROM   Proposal_Scores__r
                                           WHERE  Scoring_Committee_Member__c != null)
                                   FROM   Project__c
                                   WHERE  Program_Version__c IN :solicitationMap.keySet()
                                   AND    Solicitation_Round__c IN :solicitationRoundIds_bothTypes
                                   AND    Status__c = :Project_Helper.PROJECT_STATUS_UNDER_REVIEW
                                   AND    (Concept_Paper__c = true OR Proposal__c = true)
                                   AND    (Solicitation_Group__c = null OR Solicitation_Group__c IN :solicitationGroupIds)
                                   ORDER BY Program_Version__c ]) {
        if(!solicitationWiseProjects.containsKey(objProject.Program_Version__c)) {
          solicitationWiseProjects.put(objProject.Program_Version__c, new List<Project__c>());
        }
        solicitationWiseProjects.get(objProject.Program_Version__c).add(objProject);

        Set<Id> scorerids = new Set<Id>();
        for(Proposal_Score__c objScroe : objProject.Proposal_Scores__r) {
          scorerids.add(objScroe.Scoring_Committee_Member__c);
        }
        projectWiseScorer.put(objProject.Id, scorerids);
      }
      /

      for(Id solicitationId : solicitationMap.keySet()) {

        Program_Version__c solicitationObj = solicitationMap.get(solicitationId);

        if(Solicitation_Helper.BATCH_RANK_SCORE_TYPE.equalsIgnoreCase(solicitationObj.Score_Type__c)) {
          // Batch rank

        } else if(Solicitation_Helper.SUM_OF_RANK_SCORE_TYPE.equalsIgnoreCase(solicitationObj.Score_Type__c) || String.isBlank(solicitationObj.Score_Type__c)) {
          // Sum of Rank

        }

      }
    }
  }
  */


  /*
  * Method Name: manageSolicitationAnnoucementNotifications_ReviewTeam
  * Description:  S-00724: Notify Reviewers on Solicitation Announcement
  *          This will be invoked from Solicitation_TriggerHandler class
  * @param: List<Program_Version__c> newListSolicitations
  * @param: Map<Id, Program_Version__c> oldMapSolicitations
  * @return: void
  */
  public static void manageSolicitationAnnoucementNotifications_ReviewTeam(List<Program_Version__c> newListSolicitations,
                                                                Map<Id, Program_Version__c> oldMapSolicitations) {

    Date dtToday = Date.today();
    List<Program_Version__c> solicitationNotifications_OnDate = new List<Program_Version__c>();
    List<Program_Version__c> solicitationNotifications_AfterDate = new List<Program_Version__c>();

    for(Program_Version__c objSolicitaion : newListSolicitations) {

      if(objSolicitaion.Solicitation_Announcement_Date__c != null) { // Applicable Solicitations only.

        if(objSolicitaion.Notify_on_Announcement_Dt_Review_Team__c &&
              (Trigger.isInsert || (!oldMapSolicitations.get(objSolicitaion.Id).Notify_on_Announcement_Dt_Review_Team__c))) {
          // On Announcement Date notifications
          solicitationNotifications_OnDate.add(objSolicitaion);

        } else if(objSolicitaion.Notify_Aft_Announcement_Dt_Review_Team__c && objSolicitaion.Solicitation_Announcement_Date__c < dtToday &&
              (Trigger.isInsert || (!oldMapSolicitations.get(objSolicitaion.Id).Notify_Aft_Announcement_Dt_Review_Team__c))) {

          // After Announcement Date notifications
          solicitationNotifications_AfterDate.add(objSolicitaion);
        }
      }

    }

    List<Program_Version__c> lstResetFlagsOnSolicitations = new List<Program_Version__c>();

    if(solicitationNotifications_OnDate.size() > 0) {
      sendNotificationToReviewTeam_OnDate(solicitationNotifications_OnDate);

      for(Program_Version__c objSolicitation : solicitationNotifications_OnDate) {
        lstResetFlagsOnSolicitations.add(new Program_Version__c(Id = objSolicitation.Id, Notify_on_Announcement_Dt_Review_Team__c = false));
      }

    }
    if(solicitationNotifications_AfterDate.size() > 0) {
      sendNotificationToReviewTeam_AfterDate(solicitationNotifications_AfterDate);

      for(Program_Version__c objSolicitation : solicitationNotifications_AfterDate) {
        lstResetFlagsOnSolicitations.add(new Program_Version__c(Id = objSolicitation.Id, Notify_Aft_Announcement_Dt_Review_Team__c = false));
      }

    }

    if(lstResetFlagsOnSolicitations.size() > 0) {
      update lstResetFlagsOnSolicitations;
    }


  }

  /*
  * Method Name: sendNotificationToReviewTeam_OnDate
  * Description: Send notifications 1) Review team - all members
  * @param: List<Program_Version__c> newListSolicitations
  * @return: void
  */
  public static void sendNotificationToReviewTeam_OnDate(List<Program_Version__c> newListSolicitations) {
    sendNotificationToReviewTeam_Ops(newListSolicitations,Label.Solicitation_On_Announcement_Dt_Reviewer_excl_Contract_Office_Mgr_Notif_Name, false, false);
  }
  /*
  * Method Name: sendNotificationToReviewTeam_OnDate
  * Description: Send notifications 1) Review team - internal members only
  * @param: List<Program_Version__c> newListSolicitations
  * @return: void
  */
  public static void sendNotificationToReviewTeam_AfterDate(List<Program_Version__c> newListSolicitations) {
    sendNotificationToReviewTeam_Ops(newListSolicitations,Label.Solicitation_Aft_Announcement_Dt_Reviewer_excl_Contract_Office_Mgr_Notif_Name, true, false);
  }

  /* 
  * Method Name: sendNotificationToReviewTeam_Ops
  * Description: Send notifications 1) Review team - internal members only
  * @param: List<Program_Version__c> newListSolicitations
  * @param: String emailTemplateName  
  * @param: Boolean isInternalOnly
  * @param: Boolean checkForUnderReview
  * @return: void
  */
  private static void sendNotificationToReviewTeam_Ops(List<Program_Version__c> newListSolicitations, String emailTemplateName,
                                                       Boolean isInternalOnly, Boolean checkForUnderReview) {

    Map<Id, Program_Version__c> solicitationMap = new Map<Id,Program_Version__c>();
    Map<Id, Set<String>> solicitationWiseEmailMap = new Map<Id, Set<String>>();
    Map<Id, Set<Id>> solicitationWiseMemberMap = new Map<Id, Set<Id>>();
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    List<Task> taskList = new List<Task>();
    Id emailTemplateId;

    if(emailTemplateName != null) {
      for(EmailTemplate objEmailTemplate : [SELECT  Id, DeveloperName
                                            FROM    EmailTemplate
                                            WHERE   DeveloperName = :emailTemplateName] ) {
        emailTemplateId = objEmailTemplate.Id;
      }
    }

    System.debug('>>> emailTemplateId = ' + emailTemplateId);

    if(newListSolicitations != null && newListSolicitations.size() > 0 && EmailTemplateId != null) {

      Map<Id, Map<Id,Solicitation_Review_Team__c>> solicitationWiseEligibleReviewTeams = new Map<Id, Map<Id,Solicitation_Review_Team__c>>();
      Map<Id,Solicitation_Review_Team__c> reviewTeamMap = new Map<Id,Solicitation_Review_Team__c>();
      Set<Id> sumRankSolicitationIds = new Set<Id>();
      Set<Id> batchRankSolicitationIds = new Set<Id>();
      Set<Id> batchRoundIds = new Set<Id>();
      Boolean eligibleGroup = false;

      for(Program_Version__c objSolicitation : newListSolicitations) {
        if(Solicitation_Helper.BATCH_RANK_SCORE_TYPE.equalsIgnoreCase(objSolicitation.Score_Type__c)) {
          // Batch rank
          batchRankSolicitationIds.add(objSolicitation.id);
        } else if(Solicitation_Helper.SUM_OF_RANK_SCORE_TYPE.equalsIgnoreCase(objSolicitation.Score_Type__c) || String.isBlank(objSolicitation.Score_Type__c)) {
          // Sum of Rank
          sumRankSolicitationIds.add(objSolicitation.id);
        }
      }

      Set<id> reviewTeamIds = new Set<Id>();

      // Fetch groups if needed
      if(batchRankSolicitationIds.size() > 0) {

        for(Program_Version__c objSolicitation : [SELECT  Id, Score_Type__c,
                                                          (SELECT Id, Concept_Paper_Due_Date__c, Due_Date__c
                                                           FROM   Solicitation__r
                                                           WHERE  Status__c  = 'Open'
                                                           ORDER BY Concept_Paper_Due_Date__c, Due_Date__c LIMIT 1)
                                                  FROM     Program_Version__c
                                                  WHERE    Id IN :batchRankSolicitationIds]) {
          for(Solicitation_Round__c objRound : objSolicitation.Solicitation__r) {
            batchRoundIds.add(objRound.Id);
          }
        }

        for(Solicitation_Group__c objSoliGroup : [SELECT Solicitation_Round__c, Solicitation_Round__r.Solicitation__c,
                                                        (SELECT Solicitation_Review_Team__c, Is_Solicitation_Manager__c,
                                                                Solicitation_Review_Team__r.Member__c,
                                                                Solicitation_Review_Team__r.Scoring_Committee__c
                                                         FROM   Solicitation_Group_Members__r
                                                         WHERE  Solicitation_Review_Team__r.Member__c != null
                                                         AND    Solicitation_Review_Team__r.NDA_Signed_Date__c != null
                                                         AND    Solicitation_Review_Team__r.Scoring_Committee__c = true),
                                                        (SELECT Id
                                                         FROM   Projects__r
                                                         WHERE  Status__c = :Project_Helper.PROJECT_STATUS_UNDER_REVIEW LIMIT 1)
                                                  FROM   Solicitation_Group__c
                                                  WHERE  Solicitation_Round__c IN :batchRoundIds
                                                  AND    Solicitation_Round__c != null
                                                  ORDER BY  Solicitation_Round__c]) {
          eligibleGroup = false;

          if(checkForUnderReview) {
            if(objSoliGroup.Projects__r != null && objSoliGroup.Projects__r.size() > 0) {
              eligibleGroup = true;
            }
          }

          if(!checkForUnderReview || eligibleGroup) {

            if(!solicitationWiseEligibleReviewTeams.containsKey(objSoliGroup.Solicitation_Round__r.Solicitation__c)) {
              solicitationWiseEligibleReviewTeams.put(objSoliGroup.Solicitation_Round__r.Solicitation__c, new Map<Id,Solicitation_Review_Team__c>());
            }

            for(Solicitation_Group_Member__c objGrpMember : objSoliGroup.Solicitation_Group_Members__r) {
              reviewTeamIds.add(objGrpMember.Solicitation_Review_Team__c);
              Solicitation_Review_Team__c objMember = new Solicitation_Review_Team__c(Id = objGrpMember.Solicitation_Review_Team__c,
                                                                                      Member__c = objGrpMember.Solicitation_Review_Team__r.Member__c,
                                                                                      Scoring_Committee__c = objGrpMember.Solicitation_Review_Team__r.Scoring_Committee__c);
              solicitationWiseEligibleReviewTeams.get(objSoliGroup.Solicitation_Round__r.Solicitation__c).put(objMember.Id, objMember);
            }
          }
        }
      }

      reviewTeamIds.remove(null);
      // Sum rank
      /*
      if(sumRankSolicitationIds.size() > 0) {
          for(Program_Version__c objSolicitation : [SELECT  Id,Score_Type__c,
                                                            (
                                                              SELECT  Id, Member__c,
                                                                      Member__r.Email, Email__c,
                                                                      NDA_Signed_Date__c
                                                              FROM    Solicitation_Review_Team__r
                                                              WHERE   Scoring_Committee__c = true
                                                            )
                                                    FROM    Program_Version__c
                                                    WHERE   Id IN :newListSolicitations]) {
            if(!solicitationWiseEligibleReviewTeams.containsKey(objSolicitation.Id)) {
              solicitationWiseEligibleReviewTeams.put(objSolicitation.Id, new Map<Id,Solicitation_Review_Team__c>());
            }
            for(Solicitation_Review_Team__c objMember : objSolicitation.Solicitation_Review_Team__r) {
              solicitationWiseEligibleReviewTeams.get(objSolicitation.Id).put(objMember.Id, objMember);
            }
          }
      }
      */

      if(reviewTeamIds.size() > 0 || sumRankSolicitationIds.size() > 0) {
        for(Solicitation_Review_Team__c objTeam : [ SELECT  Id, Member__c,Solicitation__c,
                                                            Member__r.Email, Email__c,
                                                            NDA_Signed_Date__c
                                                    FROM    Solicitation_Review_Team__c
                                                    WHERE   Scoring_Committee__c = true
                                                    AND     NDA_Signed_Date__c != null
                                                    AND     (Id IN :reviewTeamIds OR Solicitation__c IN :sumRankSolicitationIds)]) {
            if(!solicitationWiseEligibleReviewTeams.containsKey(objTeam.Solicitation__c)) {
              solicitationWiseEligibleReviewTeams.put(objTeam.Solicitation__c, new Map<Id,Solicitation_Review_Team__c>());
            }
            solicitationWiseEligibleReviewTeams.get(objTeam.Solicitation__c).put(objTeam.Id, objTeam);
        }
      }


      for(Id solicitationIdVar : solicitationWiseEligibleReviewTeams.keySet()) {

          reviewTeamMap = solicitationWiseEligibleReviewTeams.get(solicitationIdVar);

          solicitationWiseEmailMap.put(solicitationIdVar, new Set<String>());
          solicitationWiseMemberMap.put(solicitationIdVar, new Set<Id>());

          for(Solicitation_Review_Team__c objMember : reviewTeamMap.values()) {

            List<String> toemailIdsToSendEmail = new List<String>();
            Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
            Messaging.SingleEmailMessage newEmail;

            if(objMember.Member__c != null || (!isInternalOnly && String.isNotBlank(objMember.Email__c))) {
              if(objMember.Member__c != null) {
                if(!solicitationWiseMemberMap.get(solicitationIdVar).contains(objMember.Member__c)) {
                  solicitationWiseMemberMap.get(solicitationIdVar).add(objMember.Member__c);

                  newEmail = Messaging.renderStoredEmailTemplate(EmailTemplateId, objMember.Member__c, objMember.Id); // Object Must have 'Allow Activities' ON.
                  toemailIdsToSendEmail.add(objMember.Member__r.Email);
                }

              } else {
                if(!solicitationWiseEmailMap.get(solicitationIdVar).contains(objMember.Email__c)) {
                  solicitationWiseEmailMap.get(solicitationIdVar).add(objMember.Email__c);

                  newEmail = Messaging.renderStoredEmailTemplate(EmailTemplateId, null, objMember.Id); // Object Must have 'Allow Activities' ON.
                  toemailIdsToSendEmail.add(objMember.Email__c);
                }
              }

              if(newEmail != null) {
                mailToBeSent.setSubject(newEmail.subject);
                mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                if(toemailIdsToSendEmail.size() > 0) {
                  mailToBeSent.setToAddresses(toemailIdsToSendEmail);
                }
                // Secure the email sending
                if(toemailIdsToSendEmail.size() > 0) {
                  emailList.add(mailToBeSent);
                  //taskList.add(CORE_EmailNotificationUtil.createActivityHistory(mailToBeSent,objMember.Id));
                }
              }

            }
          }
      }
      if(emailList.size()>0) {
        emailList = CORE_Helper.setOrgWideEmailAddress_CORE(emailList);
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailList,false);
        System.debug('>>> emailResults = '+ emailResults);
      }
      if(taskList.size() > 0) {
        insert taskList;
      } 
    }

  }

  /*
  * Method Name: sendFinalProposalDeliverableSubmissionAlertToPM
  * Description: T-02229: Notify PM when the final deliverable is submitted
  *           This will be invoked from ProjectDeliverable_TriggerHandler class
  * @param: List<Project_Deliverables__c> newDeliverableList
  * @param: Map<Id,Project_Deliverables__c> oldMapDeliverables
  * @return: void
  */
  public static void sendFinalProposalDeliverableSubmissionAlertToPM(List<Project_Deliverables__c> newDeliverableList,
                                                                     Map<Id,Project_Deliverables__c> oldMapDeliverables) {
     Set<Id> projectsToBeChecked = new Set<Id>();
     Boolean isInsert = Trigger.isInsert;

      for(Project_Deliverables__c objDeliverable : newDeliverableList) {
        if(objDeliverable.Project__c != null && objDeliverable.Project_Milestone__c != null && objDeliverable.Project_Invoice__c == null
           && ProjectDeliverables_Helper.STATUS_SUBMITTED.equalsIgnoreCase(objDeliverable.Status__c) &&
           (isInsert || (!isInsert && !objDeliverable.Status__c.equalsIgnoreCase(oldMapDeliverables.get(objDeliverable.Id).Status__c)))) {

          projectsToBeChecked.add(objDeliverable.Project__c);
        }
      }

      if(projectsToBeChecked.size() > 0) {
        List<Project__c> projectsToBeUpdated = new List<Project__c>();
        for(Project__c objProj : [SELECT  Id, Notifications_on_Approved_App_Hidden__c,
                                          (SELECT Status__c
                                           FROM   Project_Deliverables__r
                                           WHERE  Project_Milestone__c != null
                                           AND    Project_Invoice__c = null
                                           AND    (Status__c = :ProjectDeliverables_Helper.STATUS_UNSUBMITTED OR Status__c = null)
                                           )
                                  FROM    Project__c
                                  WHERE   Id IN :projectsToBeChecked
                                  AND     Budget_Type__c != null
                                  AND     (Proposal__c = true OR Concept_Paper__c = true)]) {

          if(objProj.Project_Deliverables__r != null && objProj.Project_Deliverables__r.size() == 0) {
            projectsToBeUpdated.add(new Project__c(Id = objProj.Id,
                                                   Notifications_on_Approved_App_Hidden__c = Project_Helper.NOTIFICATION_FINAL_DELIVERABLE_SUBMITTED_ON_PROPOSAL_OR_CONCEPT_PAPER));
          }
        }
        if(projectsToBeUpdated.size() > 0) {
          update projectsToBeUpdated;
        }
      }
  }

  /*
  * Method Name: sendFinalProposalDeliverableApprovalButIncompleteMemoAlertToPM
  * Description: T-02229: Notify PM when the final deliverable is approved but RPU and/or PC & E is incomplete
  *           This will be invoked from ProjectDeliverable_TriggerHandler class
  * @param: List<Project_Deliverables__c> newDeliverableList
  * @param: Map<Id,Project_Deliverables__c> oldMapDeliverables
  * @return: void
  */
  public static void sendFinalProposalDeliverableApprovalButIncompleteMemoAlertToPM(List<Project_Deliverables__c> newDeliverableList,
                                                                     Map<Id,Project_Deliverables__c> oldMapDeliverables) {
     Set<Id> projectsToBeChecked = new Set<Id>();
     Boolean isInsert = Trigger.isInsert;

      for(Project_Deliverables__c objDeliverable : newDeliverableList) {
        if(objDeliverable.Project__c != null && objDeliverable.Project_Milestone__c != null && objDeliverable.Project_Invoice__c == null
           && ProjectDeliverables_Helper.STATUS_APPROVED.equalsIgnoreCase(objDeliverable.Status__c) &&
           (isInsert || (!isInsert && !objDeliverable.Status__c.equalsIgnoreCase(oldMapDeliverables.get(objDeliverable.Id).Status__c)))) {

          projectsToBeChecked.add(objDeliverable.Project__c);
        }
      }

      if(projectsToBeChecked.size() > 0) {
        List<Project__c> projectsToBeUpdated = new List<Project__c>();
        for(Project__c objProj : [SELECT  Id, Notifications_on_Approved_App_Hidden__c,
                                          (SELECT Status__c
                                           FROM   Project_Deliverables__r
                                           WHERE  Project_Milestone__c != null
                                           AND    Project_Invoice__c = null
                                           AND    (Status__c = :ProjectDeliverables_Helper.STATUS_UNSUBMITTED OR
                                                   Status__c = null OR
                                                   Status__c = :ProjectDeliverables_Helper.STATUS_SUBMITTED
                                                   )
                                           )
                                  FROM    Project__c
                                  WHERE   Id IN :projectsToBeChecked
                                  AND     Budget_Type__c != null
                                  AND     (Proposal__c = true OR Concept_Paper__c = true)
                                  AND     (RPU_Status__c != :Project_Helper.RPU_STATUS_REVIEW_COMPLETED OR
                                           PC_E_Status__c != :Project_Helper.PC_E_STATUS_REVIEW_COMPLETED )]) {

          if(objProj.Project_Deliverables__r != null && objProj.Project_Deliverables__r.size() == 0) {
            projectsToBeUpdated.add(new Project__c(Id = objProj.Id,
                                                   Notifications_on_Approved_App_Hidden__c = Project_Helper.NOTIFICATION_FINAL_DELIVERABLE_APPROVED_RPU_PCE_INCOMPLETE_ON_PROPOSAL_OR_CONCEPT_PAPER));
          }
        }
        if(projectsToBeUpdated.size() > 0) {
          update projectsToBeUpdated;
        }
      }
  }


  /*
  * Method Name: populateScoringRubricIdOnSolicitation
  * Description: T-02299: Scoring Rubric in Salesforce
  *           This will be invoked from AttachmentTriggerHandler class
  * @param: list<Attachment> newAttachments
  * @return: void
  */
  public static void populateScoringRubricIdOnSolicitation(list<Attachment> newAttachments) {

    Set<Id> programContentIds = new Set<Id>();
    String strVersionId = '';
    Map<Id, Id> solicitationWiseAttachmentId = new Map<Id, Id>();
    List<Program_Version__c> lstSolicitationsToBeUpdated = new List<Program_Version__c>();

    Id documentRecordTypeId = (
                               Utility_RecordType_Helper.getRecordType('Program_Content__c','Document') != null ?
                               Utility_RecordType_Helper.getRecordType('Program_Content__c','Document').Id :
                               null
                               );

    for(Attachment objAttachment : newAttachments) {
      if(objAttachment.ParentId != null) {
        strVersionId = objAttachment.ParentId;
        if(strVersionId.startsWith(programContentPrefix)) {
          programContentIds.add(objAttachment.ParentId);
        }
      }
    }

    // Find eligible Solicitations
    if(programContentIds.size() > 0) {



      for(Program_Content__c objProgramContent : [SELECT  Id, Program_Version__c,
                                                          (SELECT Id FROM Attachments ORDER BY CreatedDate DESC LIMIT 1)
                                                  FROM    Program_Content__c
                                                  WHERE   RecordTypeId = :documentRecordTypeId
                                                  AND     Type__c = :ProgramContent_Helper.TYPE_SCORING_RUBRIC
                                                  AND     Active__c = true
                                                  AND     Upload_Document__c = false
                                                  AND     Solicitation_Information__c = false
                                                  AND     Concept_Paper__c = false
                                                  ORDER BY CreatedDate DESC]) {

        if(!solicitationWiseAttachmentId.containsKey(objProgramContent.Program_Version__c)) {
          for(Attachment objAttach : objProgramContent.Attachments) {
            solicitationWiseAttachmentId.put(objProgramContent.Program_Version__c, objAttach.Id);
          }
        }

      }

      if(solicitationWiseAttachmentId.size() > 0) {
        for(Id solicitationId : solicitationWiseAttachmentId.keySet()) {
          lstSolicitationsToBeUpdated.add(new Program_Version__c(Id = solicitationId, Scoring_Rubric_Attachment_Id__c = solicitationWiseAttachmentId.get(solicitationId)));
        }
        if(lstSolicitationsToBeUpdated.size() > 0) {
          update lstSolicitationsToBeUpdated;
        }
      }
 
    } 
 
  }

  /*
  * Method Name: promptProgramDirectorForMemo
  * Description: T-02191: Prompt Director to Review Concept Paper Memo
  *           This will be invoked from AttachmentTriggerHandler class
  * @param: list<Attachment> newAttachments
  * @return: void
  */
  public static void promptProgramDirectorForMemo(list<Attachment> newAttachments) {
    Set<Id> solicitationRoundIds = new Set<Id>();
    String strVersionId = '';

    for(Attachment objAttachment : newAttachments) {
      if(objAttachment.ParentId != null) {
        strVersionId = objAttachment.ParentId;
        if(strVersionId.startsWith(solicitationRoundPrefix)) {
          solicitationRoundIds.add(objAttachment.ParentId);
        }
      }
    }
    // Find eligible Solicitations
    List<Program_Version__c> lstSolicitations = new List<Program_Version__c>();
    Map<Id, Solicitation_Round__c> solicitationInfoMapByRound = new Map<Id, Solicitation_Round__c>();

    if(solicitationRoundIds.size() > 0) {
      for(Solicitation_Round__c objRound : [SELECT  Id, Solicitation__c,
                                                    Concept_Paper_Due_Date__c, Status__c,
                                                    Solicitation__r.Program_Manager__c,
                                                    Solicitation__r.Program_Manager__r.Email,
                                                    Solicitation__r.Concept_Paper__c
                                            FROM    Solicitation_Round__c
                                            WHERE   Id IN :solicitationRoundIds
                                            AND     Solicitation__r.Concept_Paper__c = true
                                            AND     Solicitation__r.Program_Manager__c != null ]) {

        solicitationInfoMapByRound.put(objRound.Solicitation__c, objRound);
      }
    }

    if(solicitationInfoMapByRound.size() > 0) {
      // Prepare emails
      Id emailTemplateId;
      String emailTemplateName = Label.Core_Program_Director_Review_Concept_Paper_Memo_Notification_API_Name;
      for(EmailTemplate objEmailTemplate : [SELECT  Id, DeveloperName
                                            FROM    EmailTemplate
                                            WHERE   DeveloperName = :emailTemplateName] ) {
        emailTemplateId = objEmailTemplate.Id;
      }
      if(emailTemplateId != null) { 
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Task> taskList = new List<Task>();

        for(Id solicitationId : solicitationInfoMapByRound.keySet()) {
          List<String> toemailIdsToSendEmail = new List<String>();
          Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();

          Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(EmailTemplateId, null, solicitationId); // Object Must have 'Allow Activities' ON.

          if(newEmail != null) {
            mailToBeSent.setSubject(newEmail.subject);
            mailToBeSent.setHtmlBody(newEmail.HTMLBody);
            mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);

            toemailIdsToSendEmail.add(solicitationInfoMapByRound.get(solicitationId).Solicitation__r.Program_Manager__r.Email);
            if(toemailIdsToSendEmail.size() > 0) {
              mailToBeSent.setToAddresses(toemailIdsToSendEmail);
            }
            // Secure the email sending
            if(toemailIdsToSendEmail.size() > 0) {
              emailList.add(mailToBeSent);
              //taskList.add(CORE_EmailNotificationUtil.createActivityHistory(mailToBeSent,solicitationId));
            }
          }

        }
        if(emailList.size()>0) {
          emailList = CORE_Helper.setOrgWideEmailAddress_CORE(emailList);
          Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailList,false);
          System.debug('>>> emailResults = '+ emailResults);
        }
        if(taskList.size() > 0) {
          insert taskList;
        }
      }
    }
  }


} //EOF