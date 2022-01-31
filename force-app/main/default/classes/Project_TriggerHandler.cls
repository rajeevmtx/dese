/*
*   Class Name: Project_TriggerHandler
*   Description: Handler class for project trigger
*
*/
public without sharing class Project_TriggerHandler { //Without Sharing mode is to allow Unlocking in Approval Process

    // variables
    public static Boolean isRecursionSafe_checkAndSetApprovalProcess = true;
    public static Boolean runOnceOnAfterUpdate = false;
    public static Map<Id, Set<String>> staticMapOfStatusLogging = new Map<Id, Set<String>>();

    /*
    * Method Name: beforeInsert
    * Description: calling this method before insert trigger event
    * @param: List<Project__c> newList
    * @return void
    */
    public static void beforeInsert(List<Project__c> newList)
    {
        updateProjectName(newList);
    }

    /*
    * Method Name: afterInsert
    * Description: calling this method after insert trigger event
    * @param: List<Project__c> newList
    * @return void
    */
    public static void afterInsert(Project__c[] newList)
    {
        copyProgramTemplate(newList);
        copyProgramContent(newList);
        ProjectRole_Helper.defaultContractorRolesOnInsert(newList);
        ProjectMilestones_Helper.defaultMilestonesOnInsert(newList);
        createProjectRoleFromProgram(newList);
        logProjectStatus(newList,null);

        afterInsertUpdate(newList,null);

        genericEmailModuleForProposalConceptPaper(newList, null); // T-01984
        //genericEmailModuleForIncentiveApplications(newList, null);
        setSolicitationManagerFlagForProposalConceptPaper(newList, null); // T-02189
        setScoringTeamFlagForProposalConceptPaper(newList, null); // S-00724

        

    }

    /*
    * Method Name: beforeUpdate
    * Description: calling this method before update trigger event
    * @param: Map<Id,Project__c> newMap
    * @param: Map<Id,Project__c> oldMap
    * @return void
    */
    public static void beforeUpdate(Map<Id,Project__c> newMap, Map<Id,Project__c> oldMap)
    {
        updateProjectName(newMap.values()); // AG: This was never in Update Event. Edit: I-02405 - Also run for UPDATE event but only on Proposal or Concept Paper.

    }

    /*
    * Method Name: afterUpdate
    * Description: calling this method after update trigger event
    * @param: Map<Id,Project__c> newMap
    * @param: Map<Id,Project__c> oldMap
    * @return void
    */
    public static void afterUpdate(List<Project__c> newList, Map<Id, Project__c> oldMap) {

        syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP(newList,OldMap); // Aoid dependency on CORE_Proposal_Review_Controller
        updateProposerAsContractorOnAwardedProposals(newList,OldMap); // Aoid dependency on CORE_Proposal_Review_Controller
        logProjectStatus(newList,oldMap);
        //ProposalScore_TriggerHandler.updateConceptPaperResultFromProject(newList,oldMap);   //Concept average result

        if(!Project_TriggerHandler.runOnceOnAfterUpdate) { // TRY TO AVOID PUTTING METHODS inside this
            // recursion helper static variable
            afterInsertUpdate(newList,oldMap);
            manageProjectNotification_Awarded(newList,oldMap);
            ProjectSharing_Helper.ShareWithSolicitationReviewTeam(newList,OldMap);
        }

        
        ProjectSharing_Helper.ShareWithSolicitationManager(newList,OldMap);
        genericEmailModuleForProposalConceptPaper(newList, oldMap); // T-01984
        //genericEmailModuleForIncentiveApplications(newList, oldMap);
        setSolicitationManagerFlagForProposalConceptPaper(newList, oldMap); // T-02189
        setScoringTeamFlagForProposalConceptPaper(newList, oldMap); // S-00724

    }




    /*
    * Method Name: afterInsertUpdate
    * Description: calling this method after insert update trigger event
    * @param: List<Project__c> newListProj
    * @param: Map<Id,Project__c> oldMapProj
    * @return void
    */
    public static void afterInsertUpdate(List<Project__c> newListProj, Map<Id,Project__c> oldMapProj) {

        if(isRecursionSafe_checkAndSetApprovalProcess) {
            isRecursionSafe_checkAndSetApprovalProcess = false;
        }

    }



    /*
    * Method Name: updateProposerAsContractorOnAwardedProposals
    * Description: calling this method after update trigger event
    *              Moved the recordType sync code to trigger to avoid dependency on CORE_Proposal_Review_Controller
    * @param: List<Project__c> newListProjects
    * @param: Map<Id, Project__c> oldMapProjects
    * @return: void
    */
    public static Set<Id> processedProjectIds_updateProposerAsContractorOnAwardedProposals = new Set<Id>();
    public static void    updateProposerAsContractorOnAwardedProposals(List<Project__c> newListProjects, Map<Id, Project__c> oldMapProjects) {

      Boolean isInsert = (Trigger.isInsert || (newListProjects != null && oldMapProjects == null));
      Set<Id> projectIdsForProjectRoleUpdate = new Set<Id>();

      for(Project__c objProject : newListProjects) {
          if((objProject.Proposal__c) &&
              objProject.RecordTypeId != null && Project_Helper.PROJECT_STATUS_AWARDED.equalsIgnoreCase(objProject.Status__c) &&
              (!isInsert &&  oldMapProjects.get(objProject.Id) != null
                         && !objProject.Status__c.equalsIgnoreCase(oldMapProjects.get(objProject.Id).Status__c))) {

              if(!processedProjectIds_updateProposerAsContractorOnAwardedProposals.contains(objproject.Id)) {
                processedProjectIds_updateProposerAsContractorOnAwardedProposals.add(objProject.Id);
                projectIdsForProjectRoleUpdate.add(objProject.Id);
              }
          }
      }

      // Update the project role
      if(projectIdsForProjectRoleUpdate != null && projectIdsForProjectRoleUpdate.size() > 0) {
        List<Project_Role__c> lstRoles = new List<Project_Role__c>();
        for(Project_Role__c objRole : [SELECT Id, Role__c, Project__c
                                       FROM   Project_Role__c
                                       WHERE  Project__c IN :projectIdsForProjectRoleUpdate
                                       AND    Role__c = :ProjectRole_Helper.PROJECT_PROPOSER_ROLE]) {

          objRole.Role__c = ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE;
          lstRoles.add(objRole);
        }
        if(lstRoles.size() > 0) {
          update lstRoles;
        }
      }
    }


    /*
    * Method Name: syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP
    * Description: calling this method after update trigger event
    *              Moved the recordType sync code to trigger to avoid dependency on CORE_Proposal_Review_Controller
    * @param: List<Project__c> newListProjects
    * @param: Map<Id, Project__c> oldMapProjects
    * @return: void
    */
    public static Set<Id> processedProjectIds_syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP = new Set<Id>();
    public static void syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP(List<Project__c> newListProjects, Map<Id, Project__c> oldMapProjects) {

      Boolean isInsert = (Trigger.isInsert || (newListProjects != null && oldMapProjects == null));
      Set<Id> projectIdsForProjectChildRecordUpdate = new Set<Id>();

      for(Project__c objProject : newListProjects) {
          if((objProject.Proposal__c || objProject.Concept_Paper__c) &&
              objProject.RecordTypeId != null &&
              (!isInsert && oldMapProjects.get(objProject.Id) != null &&
                          objProject.RecordTypeId != oldMapProjects.get(objProject.Id).RecordTypeId)) {

              if(!processedProjectIds_syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP.contains(objproject.Id)) {
                processedProjectIds_syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP.add(objProject.Id);

                projectIdsForProjectChildRecordUpdate.add(objProject.Id);

              }

          }
      }
      // Update the recordType on Document and Site as well
      if(projectIdsForProjectChildRecordUpdate != null && projectIdsForProjectChildRecordUpdate.size() > 0) {
        updateProjectDocumentWithProject(projectIdsForProjectChildRecordUpdate);
        updateProjectSiteWithProject(projectIdsForProjectChildRecordUpdate);
      }
    }

    /*
    * Method Name: updateProjectDocumentWithProject
    * Description: future Method to update project document with project.
                   Util method for syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP()
    * @param: Set<Id> projectIdsForProjectDocUpdate
    * @return: static void
    */
    @future
    public static void updateProjectDocumentWithProject(Set<Id> projectIdsForProjectDocUpdate) {
      List<Project_Document__c> lstDocuments = new List<Project_Document__c>();
      if(projectIdsForProjectDocUpdate != null && projectIdsForProjectDocUpdate.size() > 0) {
        for(Project__c objProject : [SELECT  Id,recordTypeId,
                                             recordType.DeveloperName,
                                             (SELECT Id, RecordTypeId
                                              FROM   Documents__r)
                                       FROM    Project__c
                                       WHERE   id IN :projectIdsForProjectDocUpdate]) {
          for(Project_Document__c objProjDoc : objProject.Documents__r){
              RecordType recType = Utility_RecordType_Helper.getRecordType('Project_Document__c',objProject.recordType.developerName); // This is not a SOQL inside loop, because Utility_RecordType_Helper takes care of it.
              if(recType != null) {
                lstDocuments.add(new Project_Document__c(Id = objProjDoc.Id, RecordTypeId = recType.Id));
              }
          }
        }
        if(lstDocuments.size() > 0) {
          update lstDocuments;
        }
      }
    }


    /*
    * Method Name: updateProjectSiteWithProject
    * Description: future Method to update project site with project
                   Util method for syncProjectDocAndProjectSiteRcdTypeForAwardedProposalCP()
    * @param: Set<Id> projectIdsForProjectSiteUpdate
    * @return: static void
    */
    @future
    public static void updateProjectSiteWithProject(Set<Id> projectIdsForProjectSiteUpdate) {
      List<Project_Site__c> lstSites = new List<Project_Site__c>();
      if(projectIdsForProjectSiteUpdate != null && projectIdsForProjectSiteUpdate.size() > 0) {
        for(Project__c objProject : [SELECT  Id,recordTypeId,
                                             recordType.DeveloperName,
                                             (SELECT RecordTypeId FROM Project_Site__r)
                                       FROM    Project__c
                                       WHERE   Id IN :projectIdsForProjectSiteUpdate]) {
          for(Project_Site__c objProjSite : objProject.Project_Site__r){
              RecordType recType = Utility_RecordType_Helper.getRecordType('Project_Site__c',objProject.recordType.developerName); // This is not a SOQL inside loop, because Utility_RecordType_Helper takes care of it.
              if(recType != null) {
                lstSites.add(new Project_Site__c(Id = objProjSite.Id, RecordTypeId = recType.Id));
              }
          }
        }
        if(lstSites.size() > 0) {
          update lstSites;
        }
      }
    }

    // T-02189: Notification to solicitation manager when pending review is updated.
    public static Set<Id> processedProjectIds_setScoringTeamFlagForProposalConceptPaper = new Set<Id>();

    /*
    * Method Name: setScoringTeamFlagForProposalConceptPaper
    * Description: calling this method after insert update trigger event
    * @param: List<Project__c> newListProjects
    * @param: Map<Id, Project__c> oldMapProjects
    * @return void
    */
    public static void setScoringTeamFlagForProposalConceptPaper(List<Project__c> newListProjects, Map<Id, Project__c> oldMapProjects) {
        Boolean isInsert = (Trigger.isInsert || (newListProjects != null && oldMapProjects == null));

        Set<Id> solicitations_ConceptPapers = new Set<Id>();
        Set<Id> solicitations_Proposals = new Set<Id>();
        Map<Id, Solicitation_Round__c> solicitationRounds = new Map<Id, Solicitation_Round__c>();

        Map<Id,Set<Id>> solicitationRoundsForSolicitation_CP = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> solicitationRoundsForSolicitation_Proposal = new Map<Id,Set<Id>>();

        for(Project__c objProject : newListProjects) {
            if((objProject.Proposal__c || objProject.Concept_Paper__c) && Project_Helper.PROJECT_STATUS_UNDER_REVIEW.equalsIgnoreCase(objProject.Status__c) &&
                (isInsert || (!isInsert && oldMapProjects.get(objProject.Id) != null &&
                              !objProject.Status__c.equalsIgnoreCase(oldMapProjects.get(objProject.Id).Status__c)))) {

                if(!processedProjectIds_setScoringTeamFlagForProposalConceptPaper.contains(objproject.Id)) {

                  processedProjectIds_setScoringTeamFlagForProposalConceptPaper.add(objProject.Id);

                  if(objProject.Concept_Paper__c && objProject.Solicitation_Round__c != null && !objProject.Round_Notify_Review_Team_Concept_Paper__c) {
                    solicitations_ConceptPapers.add(objProject.Program_Version__c);

                    if(!solicitationRoundsForSolicitation_CP.containsKey(objProject.Program_Version__c)) {
                      solicitationRoundsForSolicitation_CP.put(objProject.Program_Version__c, new Set<Id>());
                    }
                    solicitationRoundsForSolicitation_CP.get(objProject.Program_Version__c).add(objProject.Solicitation_Round__c);

                    if(!solicitationRounds.containsKey(objProject.Solicitation_Round__c)) {
                      solicitationRounds.put(objProject.Solicitation_Round__c, new Solicitation_Round__c(Id = objProject.Solicitation_Round__c));
                    }
                    solicitationRounds.get(objProject.Solicitation_Round__c).Notify_Review_Team_Concept_Paper__c = true;
                  }

                  if(objProject.Proposal__c && objProject.Solicitation_Round__c != null && !objProject.Round_Notify_Review_Team_Proposal__c) {

                    solicitations_Proposals.add(objProject.Program_Version__c);
                    if(!solicitationRoundsForSolicitation_Proposal.containsKey(objProject.Program_Version__c)) {
                      solicitationRoundsForSolicitation_Proposal.put(objProject.Program_Version__c, new Set<Id>());
                    }
                    solicitationRoundsForSolicitation_Proposal.get(objProject.Program_Version__c).add(objProject.Solicitation_Round__c);

                    if(!solicitationRounds.containsKey(objProject.Solicitation_Round__c)) {
                      solicitationRounds.put(objProject.Solicitation_Round__c, new Solicitation_Round__c(Id = objProject.Solicitation_Round__c));
                    }
                    solicitationRounds.get(objProject.Solicitation_Round__c).Notify_Review_Team_Proposal__c = true;
                  }

                }
            }
        }

        if(solicitations_ConceptPapers.size() > 0) {
          List<Program_version__c> lstSolictiations_toUpdate = new List<Program_version__c>();
          for(Program_version__c objSolicitation : [SELECT  Id, Notify_Review_Team_Concept_Paper__c,
                                                            Solicitation_Round_for_Notification__c
                                                    FROM    Program_version__c
                                                    WHERE   Id IN :solicitations_ConceptPapers
                                                    AND     Notify_Review_Team_Concept_Paper__c = false]) {

            objSolicitation.Notify_Review_Team_Concept_Paper__c = true;
            lstSolictiations_toUpdate.add(objSolicitation);
          }
          if(lstSolictiations_toUpdate.size() > 0) {

            for(Program_version__c obj : lstSolictiations_toUpdate) {
              if(solicitationRoundsForSolicitation_CP.containsKey(obj.Id)) {
                for(Id roundId : solicitationRoundsForSolicitation_CP.get(obj.Id)) {
                  obj.Solicitation_Round_for_Notification__c = roundId;
                }
              }
            }
            update lstSolictiations_toUpdate;
            if(solicitationRounds.size() > 0) {
              update solicitationRounds.values(); // S-01055 - Multi round with concept paper and parallel activities
            }
          }
        }

        if(solicitations_Proposals.size() > 0) {
          List<Program_version__c> lstSolictiations_toUpdate = new List<Program_version__c>();
          for(Program_version__c objSolicitation : [SELECT  Id, Notify_Review_Team_Proposal__c,
                                                            Solicitation_Round_for_Notification__c
                                                    FROM    Program_version__c
                                                    WHERE   Id IN :solicitations_Proposals
                                                    AND     Notify_Review_Team_Proposal__c = false]) {

            objSolicitation.Notify_Review_Team_Proposal__c = true;
            lstSolictiations_toUpdate.add(objSolicitation);
          }
          if(lstSolictiations_toUpdate.size() > 0) {

            for(Program_version__c obj : lstSolictiations_toUpdate) {
              if(solicitationRoundsForSolicitation_Proposal.containsKey(obj.Id)) {
                for(Id roundId : solicitationRoundsForSolicitation_Proposal.get(obj.Id)) {
                  obj.Solicitation_Round_for_Notification__c = roundId;
                }
              }
            }
            update lstSolictiations_toUpdate;
            if(solicitationRounds.size() > 0) {
              update solicitationRounds.values(); // S-01055 - Multi round with concept paper and parallel activities
            }
          }

        }

    }


    // T-02189: Notification to solicitation manager when pending review is updated.
    public static Set<Id> processedProjectIds_setSolicitationManagerFlagForProposalConceptPaper = new Set<Id>();
    /*
    * Method Name: setSolicitationManagerFlagForProposalConceptPaper
    * Description: Purpose to set solicitation manager flag for proposal concept paper
    * @param: List<Project__c> newListProjects
    * @param: Map<Id, Project__c> oldMapProjects
    * @return void
    *
    */
    public static void setSolicitationManagerFlagForProposalConceptPaper(List<Project__c> newListProjects, Map<Id, Project__c> oldMapProjects) {
        Boolean isInsert = (Trigger.isInsert || (newListProjects != null && oldMapProjects == null));

        List<Project__c> lstProjectEmails_StatusBased = new List<Project__c>();
        List<Project__c> lstProjectEmails_NotificationPicklistBased = new List<Project__c>();

        Set<Id> solicitations_ConceptPapers = new Set<Id>();
        Set<Id> solicitations_Proposals = new Set<Id>();

        Map<Id,Set<Id>> solicitationRoundsForSolicitation_CP = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> solicitationRoundsForSolicitation_Proposal = new Map<Id,Set<Id>>();

        Map<Id, Solicitation_Round__c> solicitationRounds = new Map<Id, Solicitation_Round__c>();

        for(Project__c objProject : newListProjects) {
            if((objProject.Proposal__c || objProject.Concept_Paper__c) && Project_Helper.PROJECT_STATUS_PENDING_REVIEW.equalsIgnoreCase(objProject.Status__c) &&
                (isInsert || (!isInsert && oldMapProjects.get(objProject.Id) != null &&
                              !objProject.Status__c.equalsIgnoreCase(oldMapProjects.get(objProject.Id).Status__c)))) {

                if(!processedProjectIds_setSolicitationManagerFlagForProposalConceptPaper.contains(objproject.Id)) {

                  processedProjectIds_setSolicitationManagerFlagForProposalConceptPaper.add(objProject.Id);

                  if(objProject.Concept_Paper__c && objProject.Solicitation_Round__c != null && !objProject.Round_Notify_Solicitation_Mgr_ConcPpr__c) {

                    solicitations_ConceptPapers.add(objProject.Program_Version__c);

                    if(!solicitationRoundsForSolicitation_CP.containsKey(objProject.Program_Version__c)) {
                      solicitationRoundsForSolicitation_CP.put(objProject.Program_Version__c, new Set<Id>());
                    }
                    solicitationRoundsForSolicitation_CP.get(objProject.Program_Version__c).add(objProject.Solicitation_Round__c);

                    if(!solicitationRounds.containsKey(objProject.Solicitation_Round__c)) {
                      solicitationRounds.put(objProject.Solicitation_Round__c, new Solicitation_Round__c(Id = objProject.Solicitation_Round__c));
                    }
                    solicitationRounds.get(objProject.Solicitation_Round__c).Notify_Solicitation_Mgr_Concept_Paper__c = true;
                  }

                  if(objProject.Proposal__c && objProject.Solicitation_Round__c != null && !objProject.Round_Notify_Solicitation_Mgr_Proposal__c) {
                    solicitations_Proposals.add(objProject.Program_Version__c);

                    if(!solicitationRoundsForSolicitation_Proposal.containsKey(objProject.Program_Version__c)) {
                      solicitationRoundsForSolicitation_Proposal.put(objProject.Program_Version__c, new Set<Id>());
                    }
                    solicitationRoundsForSolicitation_Proposal.get(objProject.Program_Version__c).add(objProject.Solicitation_Round__c);

                    if(!solicitationRounds.containsKey(objProject.Solicitation_Round__c)) {
                      solicitationRounds.put(objProject.Solicitation_Round__c, new Solicitation_Round__c(Id = objProject.Solicitation_Round__c));
                    }
                    solicitationRounds.get(objProject.Solicitation_Round__c).Notify_Solicitation_Manager_Proposal__c = true;

                  }
                }
            }
        }

        if(solicitations_ConceptPapers.size() > 0) {
          List<Program_version__c> lstSolictiations_toUpdate = new List<Program_version__c>();
          for(Program_version__c objSolicitation : [SELECT  Id, Notify_Solicitation_Mgr_Concept_Paper__c,
                                                            Solicitation_Round_for_Notification__c
                                                    FROM    Program_version__c
                                                    WHERE   Id IN :solicitations_ConceptPapers
                                                    AND     Notify_Solicitation_Mgr_Concept_Paper__c = false]) {

            objSolicitation.Notify_Solicitation_Mgr_Concept_Paper__c = true;
            lstSolictiations_toUpdate.add(objSolicitation);
          }
          if(lstSolictiations_toUpdate.size() > 0) {

            for(Program_version__c obj : lstSolictiations_toUpdate) {
              if(solicitationRoundsForSolicitation_CP.containsKey(obj.Id)) {
                for(Id roundId : solicitationRoundsForSolicitation_CP.get(obj.Id)) {
                  obj.Solicitation_Round_for_Notification__c = roundId;
                }
              }
            }
            update lstSolictiations_toUpdate;

            if(solicitationRounds.size() > 0) {
              update solicitationRounds.values(); // S-01055 - Multi round with concept paper and parallel activities
            }
          }
        }

        if(solicitations_Proposals.size() > 0) {
          List<Program_version__c> lstSolictiations_toUpdate = new List<Program_version__c>();
          for(Program_version__c objSolicitation : [SELECT  Id, Notify_Solicitation_Manager_Proposal__c,
                                                            Solicitation_Round_for_Notification__c
                                                    FROM    Program_version__c
                                                    WHERE   Id IN :solicitations_Proposals
                                                    AND     Notify_Solicitation_Manager_Proposal__c = false]) {

            objSolicitation.Notify_Solicitation_Manager_Proposal__c = true;
            lstSolictiations_toUpdate.add(objSolicitation);
          }
          if(lstSolictiations_toUpdate.size() > 0) {
            for(Program_version__c obj : lstSolictiations_toUpdate) {
              if(solicitationRoundsForSolicitation_Proposal.containsKey(obj.Id)) {
                for(Id roundId : solicitationRoundsForSolicitation_Proposal.get(obj.Id)) {
                  obj.Solicitation_Round_for_Notification__c = roundId;
                }
              }
            }
            update lstSolictiations_toUpdate;

            if(solicitationRounds.size() > 0) {
              update solicitationRounds.values(); // S-01055 - Multi round with concept paper and parallel activities
            }
          }
        }
    }

    // T-01984
    public static Set<Id> processedProjectIds_genericEmailModuleForProposalConceptPaper_Status = new Set<Id>();
    public static Set<String> processedProjectIds_genericEmailModuleForProposalConceptPaper_NotificationPicklist = new Set<String>();
    /*
      * Method Name: genericEmailModuleForProposalConceptPaper
      * Description: This method to expose generic email module for proposal concept paper
      * @param: List<Project__c> newListProjects
      * @param: Map<Id, Project__c> oldMapProjects
      * @return void
      */
    public static void genericEmailModuleForProposalConceptPaper(List<Project__c> newListProjects, Map<Id, Project__c> oldMapProjects) {

        List<Project__c> lstProjectEmails_StatusBased = new List<Project__c>();
        List<Project__c> lstProjectEmails_NotificationPicklistBased = new List<Project__c>();

        for(Project__c objProject : newListProjects) {
            if(objProject.Proposal__c || objProject.Concept_Paper__c) {
              // One of the values may need email
              if(String.isNotBlank(objProject.Status__c) || String.isNotBlank(objProject.Notifications_on_Approved_App_Hidden__c)) {

                // Setting values
                if(Trigger.isInsert && oldMapProjects == null) {

                  System.debug('>>> INSERT Event -- Status__c = ' + objProject.Status__c);
                  System.debug('>>> INSERT Event -- Notifications_on_Approved_App_Hidden__c = ' + objProject.Notifications_on_Approved_App_Hidden__c);

                  if(String.isNotBlank(objProject.Status__c) && !processedProjectIds_genericEmailModuleForProposalConceptPaper_Status.contains(objProject.Id)) {

                    lstProjectEmails_StatusBased.add(objProject);
                    processedProjectIds_genericEmailModuleForProposalConceptPaper_Status.add(objProject.Id);
                  }
                  if(String.isNotBlank(objProject.Notifications_on_Approved_App_Hidden__c)
                      && !processedProjectIds_genericEmailModuleForProposalConceptPaper_NotificationPicklist.contains(objProject.Id + '~' + objProject.Notifications_on_Approved_App_Hidden__c)) {

                    lstProjectEmails_NotificationPicklistBased.add(objProject);
                    processedProjectIds_genericEmailModuleForProposalConceptPaper_NotificationPicklist.add(objProject.Id + '~' + objProject.Notifications_on_Approved_App_Hidden__c);
                  }
                }

                // Updates
                if(Trigger.isUpdate && oldMapProjects != null) {


                  if(oldMapProjects.get(objProject.id) != null) {
                    System.debug('>>> UPDATE Event -- NEW Status__c = ' + objProject.Status__c + 'OLD Status__c = ' + oldMapProjects.get(objProject.id).Status__c);
                    System.debug('>>> UPDATE Event -- NEW Notifications_on_Approved_App_Hidden__c = ' + objProject.Notifications_on_Approved_App_Hidden__c +
                                ' OLD Notifications_on_Approved_App_Hidden__c = ' + oldMapProjects.get(objProject.id).Notifications_on_Approved_App_Hidden__c);
                  }

                  if((String.isNotBlank(objProject.Status__c) && !objProject.Status__c.equalsIgnoreCase(oldMapProjects.get(objProject.id).Status__c))
                     && (!processedProjectIds_genericEmailModuleForProposalConceptPaper_Status.contains(objProject.Id))) {

                    lstProjectEmails_StatusBased.add(objProject);
                    processedProjectIds_genericEmailModuleForProposalConceptPaper_Status.add(objProject.Id);
                  }
                  if((String.isNotBlank(objProject.Notifications_on_Approved_App_Hidden__c) && !objProject.Notifications_on_Approved_App_Hidden__c.equalsIgnoreCase(oldMapProjects.get(objProject.id).Notifications_on_Approved_App_Hidden__c))
                     && (!processedProjectIds_genericEmailModuleForProposalConceptPaper_NotificationPicklist.contains(objProject.Id + '~' + objProject.Notifications_on_Approved_App_Hidden__c))) {

                    lstProjectEmails_NotificationPicklistBased.add(objProject);
                    processedProjectIds_genericEmailModuleForProposalConceptPaper_NotificationPicklist.add(objProject.Id + '~' + objProject.Notifications_on_Approved_App_Hidden__c);
                  }
                }

              }
            }
        }   
        if(lstProjectEmails_StatusBased.size() > 0) {
          //CORE_EmailNotificationUtil.prepareAndSendProjectEmailViaEmailConfig_StatusBased(lstProjectEmails_StatusBased, true);
        }
        if(lstProjectEmails_NotificationPicklistBased.size() > 0) {
          //CORE_EmailNotificationUtil.prepareAndSendProjectEmailViaEmailConfig_NotificationPicklistBased(lstProjectEmails_NotificationPicklistBased, true);
        }
    } // EndOf: genericEmailModuleForProposalConceptPaper()



  //public static Set<Id> processedProjectIds_genericEmailModuleForIncentiveApplications_Status = new Set<Id>();
  //public static Set<Id> processedProjectIds_genericEmailModuleForIncentiveApplications_NotificationPicklist = new Set<Id>();

    /*
  * Method Name: genericEmailModuleForIncentiveApplications
  * Description: This method to expose generic email module for incentive applications
  * @param: List<Project__c> newListProjects
  * @param: Map<Id, Project__c> oldMapProjects
  * @return void
  */
 /*   public static void genericEmailModuleForIncentiveApplications(List<Project__c> newListProjects, Map<Id, Project__c> oldMapProjects) {

        List<Project__c> lstProjectEmails_StatusBased = new List<Project__c>();
        List<Project__c> lstProjectEmails_NotificationPicklistBased = new List<Project__c>();

        for(Project__c objProject : newListProjects) {
            if( Project_Helper.SET_OF_SUPPORTED_RECORDTYPE_IDS_GENERIC_EMAIL_MODULE_FOR_INCENTIVE_APPLICATIONS.contains(objProject.RecordTypeId) &&
                (!objProject.Proposal__c && !objProject.Concept_Paper__c)) {

              // One of the values may need email
              if(String.isNotBlank(objProject.Status__c) || String.isNotBlank(objProject.Notifications_on_Approved_App_Hidden__c)) {

                // Setting values
                if(Trigger.isInsert && oldMapProjects == null) {

                  System.debug('>>> INSERT Event -- Status__c = ' + objProject.Status__c);
                  System.debug('>>> INSERT Event -- Notifications_on_Approved_App_Hidden__c = ' + objProject.Notifications_on_Approved_App_Hidden__c);

                  if(String.isNotBlank(objProject.Status__c) && !processedProjectIds_genericEmailModuleForIncentiveApplications_Status.contains(objProject.Id)) {

                    lstProjectEmails_StatusBased.add(objProject);
                    processedProjectIds_genericEmailModuleForIncentiveApplications_Status.add(objProject.Id);
                  }
                  if(String.isNotBlank(objProject.Notifications_on_Approved_App_Hidden__c)
                      && !processedProjectIds_genericEmailModuleForIncentiveApplications_NotificationPicklist.contains(objProject.Id)) {

                    lstProjectEmails_NotificationPicklistBased.add(objProject);
                    processedProjectIds_genericEmailModuleForIncentiveApplications_NotificationPicklist.add(objProject.Id);
                  }
                }

                // Updates
                if(Trigger.isUpdate && oldMapProjects != null) {


                  if(oldMapProjects.get(objProject.id) != null) {
                    System.debug('>>> UPDATE Event -- NEW Status__c = ' + objProject.Status__c + 'OLD Status__c = ' + oldMapProjects.get(objProject.id).Status__c);
                    System.debug('>>> UPDATE Event -- NEW Notifications_on_Approved_App_Hidden__c = ' + objProject.Notifications_on_Approved_App_Hidden__c +
                                ' OLD Notifications_on_Approved_App_Hidden__c = ' + oldMapProjects.get(objProject.id).Notifications_on_Approved_App_Hidden__c);
                  }

                  if((String.isNotBlank(objProject.Status__c) && !objProject.Status__c.equalsIgnoreCase(oldMapProjects.get(objProject.id).Status__c))
                     && (!processedProjectIds_genericEmailModuleForIncentiveApplications_Status.contains(objProject.Id))) {

                    lstProjectEmails_StatusBased.add(objProject);
                    processedProjectIds_genericEmailModuleForIncentiveApplications_Status.add(objProject.Id);
                  }
                  if((String.isNotBlank(objProject.Notifications_on_Approved_App_Hidden__c) && !objProject.Notifications_on_Approved_App_Hidden__c.equalsIgnoreCase(oldMapProjects.get(objProject.id).Notifications_on_Approved_App_Hidden__c))
                     && (!processedProjectIds_genericEmailModuleForIncentiveApplications_NotificationPicklist.contains(objProject.Id))) {

                    lstProjectEmails_NotificationPicklistBased.add(objProject);
                    processedProjectIds_genericEmailModuleForIncentiveApplications_NotificationPicklist.add(objProject.Id);
                  }
                }

              }
            }
        }
        if(lstProjectEmails_StatusBased.size() > 0) {
          CORE_EmailNotificationUtil.prepareAndSendProjectEmailViaEmailConfig_StatusBased(lstProjectEmails_StatusBased, true);
        }
        if(lstProjectEmails_NotificationPicklistBased.size() > 0) {
          CORE_EmailNotificationUtil.prepareAndSendProjectEmailViaEmailConfig_NotificationPicklistBased(lstProjectEmails_NotificationPicklistBased, true);
        }
    } // EndOf: genericEmailModuleForIncentiveApplications
*/

  /*
  * Method Name: copyProgramTemplate
  * Description: purpose to copy program template
  * @param: List<Project__c> newProjectList
  * @return void
  */
    public static void copyProgramTemplate(List<Project__c> newProjectList) {

        Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Program_Version__c, Program_Version__r.Program__c,
                                         Concept_Paper__c, Proposal__c
                                        FROM Project__c where Id IN :newProjectList]);

        List<Id> programIdList = new List<Id>();
        Map<Id, List<Id>> programIdToProjectRecIdsMap = new Map<Id, List<Id>>();

        for(Project__c projRec : projectMap.values()) {
            if(projRec.Program_Version__c != null && projRec.Program_Version__r.Program__c != null) {
                programIdList.add(projRec.Program_Version__r.Program__c);
                if(!programIdToProjectRecIdsMap.containsKey(projRec.Program_Version__r.Program__c)) {
                    programIdToProjectRecIdsMap.put(projRec.Program_Version__r.Program__c, new List<Id>{projRec.Id});
                } else {
                    List<Id> existingProjIdList = programIdToProjectRecIdsMap.get(projRec.Program_Version__r.Program__c);
                    existingProjIdList.add(projRec.Id);
                }
            }
        }


        List<Program_Template__c> programTemplateList = [select Description__c, Program__c, Status__c, Template_Type__c, Solicitation__c,
                                                         (select Page_Name__c, Name, Page_Type__c, Program_Template__c, Sequence__c,Page_Description__c from Program_Template_Pages__r)
                                                         from Program_Template__c
                                                         Where Program__c IN :programIdList
                                                           AND (Template_Type__c = 'Application Intake'
                                                          OR Template_Type__c = 'Proposal Application') AND Status__c = 'Active'];


        if(programTemplateList.size() == 0) {
            return;
        }
        List<Wizard_Template__c> wizardTemplateListToInsert = new List<Wizard_Template__c>();

    Project__c project;
        for(Program_Template__c progTemplateRec : programTemplateList) {
            for(Id projectId : programIdToProjectRecIdsMap.get(progTemplateRec.Program__c)) {
              project = projectMap.get(projectId);
              if(((project.Concept_Paper__c || project.Proposal__c) && progTemplateRec.Template_Type__c == 'Proposal Application'
                    && progTemplateRec.Solicitation__c == project.Program_Version__c)
                || (!project.Concept_Paper__c && !project.Proposal__c && progTemplateRec.Template_Type__c == 'Application Intake')) {
                Wizard_Template__c wizardTemplateRec = new Wizard_Template__c();
                  wizardTemplateRec.Description__c = progTemplateRec.Description__c;
                  wizardTemplateRec.Program__c = progTemplateRec.Program__c;
                  wizardTemplateRec.Project__c = projectId;
                  wizardTemplateRec.Solicitation__c = progTemplateRec.Solicitation__c;
                  wizardTemplateRec.Status__c = progTemplateRec.Status__c;
                  wizardTemplateRec.Template_Type__c = progTemplateRec.Template_Type__c;
                  wizardTemplateListToInsert.add(wizardTemplateRec);
              }
            }
        }

        if(wizardTemplateListToInsert.size() > 0) {
            insert wizardTemplateListToInsert;
        }

        List<Wizard_Template_Page__c> wizardTempPageList = new List<Wizard_Template_Page__c>();
        for(Program_Template__c progTemplateRec : programTemplateList) {
            for(Program_Template_Page__c programTempPageRec : progTemplateRec.Program_Template_Pages__r) {
                for(Wizard_Template__c wizardTemplateRec : wizardTemplateListToInsert) {
                  if((progTemplateRec.Template_Type__c == 'Proposal Application' && progTemplateRec.Solicitation__c == wizardTemplateRec.Solicitation__c)
                    || progTemplateRec.Template_Type__c != 'Proposal Application') {

                      Wizard_Template_Page__c wizardTempPageRec = new Wizard_Template_Page__c();
                      wizardTempPageRec.Page_Name__c = programTempPageRec.Page_Name__c;
                      wizardTempPageRec.Page_Type__c = programTempPageRec.Page_Type__c;
                      wizardTempPageRec.Wizard_Template__c = wizardTemplateRec.Id;
                      wizardTempPageRec.Sequence__c = programTempPageRec.Sequence__c;
                      wizardTempPageRec.Name = programTempPageRec.Name;
                      wizardTempPageRec.Page_Description__c = programTempPageRec.Page_Description__c;
                      wizardTempPageRec.Status__c = 'Draft';
                      wizardTempPageList.add(wizardTempPageRec);
                }
                }
            }
        }

        if(wizardTempPageList.size() > 0) {
            insert wizardTempPageList;
        }
    }

  /*
  * Method Name: copyProgramContent
  * Description: To copy program content
  * @param: List<Project__c> newProjectList
  * @return void
  */
    public static void copyProgramContent(List<Project__c> newProjectList) {
        try{
                    List<Id> programVersionIdList = new List<Id>();
            for(Project__c projectRec : newProjectList) {
                programVersionIdList.add(projectRec.Program_Version__c);
            }

            List<Program_Content__c> programContentList = [select Id, Name, Document_Title__c, Mandatory_by_default__c, Program_Version__c, RecordType.DeveloperName,
                                                           Validation_Logic__c, Conditionally_Required__c, Type__c, Sub_Type__c, Document_Placement__c, Value__c, Picklist_Value__c, Explanation_Required_On__c,
                                                           CheckList_Name__c, Display_Label__c, Active__c, Sequence__c, Description__c, Concept_Paper__c,Upload_Document__c,Question_Type__c,Help_Text__c
                                                           from Program_Content__c
                                                           where Program_version__c IN :programVersionIdList];

            Map<Id, List<Program_Content__c>> programVersionToProgramContentsMap = new Map<Id, List<Program_Content__c>>();
            for(Program_Content__c progContentRec : programContentList) {
                if(!programVersionToProgramContentsMap.containsKey(progContentRec.Program_Version__c)) {
                    programVersionToProgramContentsMap.put(progContentRec.Program_Version__c, new List<Program_Content__c>{progContentRec});
                } else {
                    List<Program_Content__c> existingProgContentList = programVersionToProgramContentsMap.get(progContentRec.Program_Version__c);
                    existingProgContentList.add(progContentRec);
                }
            }

            String documentRecTypeId = Utility_RecordType_Helper.getRecordType('Project_Content__c', 'Documents').Id;
            String RTEMRecTypeId = Utility_RecordType_Helper.getRecordType('Project_Content__c', 'Due_Diligence').Id;
            String proposalRecordTypeID = Utility_RecordType_Helper.getRecordType('Project_Content__c', 'Proposal').Id;
            String incentiveFactorRecordTypeId = (Utility_RecordType_Helper.getRecordType('Project_Content__c', 'Incentive_Factor') != null ? Utility_RecordType_Helper.getRecordType('Project_Content__c', 'Incentive_Factor').Id : null);

            List<Project_Content__c> projContentListToInsert = new List<Project_Content__c>();
            for(Project__c projRec : newProjectList) {
                if(programVersionToProgramContentsMap.get(projRec.Program_Version__c) != null) {
                    for(Program_Content__c progContentRec : programVersionToProgramContentsMap.get(projRec.Program_Version__c)) {
                        Project_Content__c projContentRec = new Project_Content__c();

                        if(progContentRec.RecordType.DeveloperName == 'Document' && progContentRec.Type__c == Project_Helper.PROJECT_APPLICATION_TYPE) {
                        	
                                if((projRec.Concept_Paper__c && progContentRec.Concept_Paper__c)
                                  || (projRec.Proposal__c && progContentRec.Upload_Document__c)
                                  || (!projRec.Proposal__c && !projRec.Concept_Paper__c && !progContentRec.Concept_Paper__c)) {
                                  projContentRec.RecordTypeId = documentRecTypeId;
                                  projContentRec.Document_Title__c = progContentRec.Document_Title__c;
                                  projContentRec.Mandatory_by_default__c = progContentRec.Mandatory_by_default__c;
                                  projContentRec.Validation_Logic__c = progContentRec.Validation_Logic__c;
                                  projContentRec.Conditionally_Required__c = progContentRec.Conditionally_Required__c;
                                  projContentRec.Project__c = projRec.Id;
                                  projContentRec.Type__c = progContentRec.Type__c;
                                  projContentRec.Sub_Type__c = progContentRec.Sub_Type__c;
                                  projContentRec.Sequence__c = progContentRec.Sequence__c;
                                  projContentRec.Concept_Paper__c = progContentRec.Concept_Paper__c;
                                  projContentRec.Configured_From_Solicitation__c = true; // just to distinguish, whether the program content is copied from project content or not.
                                  projContentListToInsert.add(projContentRec);
                                }
                        
                        } else if(progContentRec.RecordType.DeveloperName == 'Due_Diligence') {
                            projContentRec.RecordTypeId = RTEMRecTypeId;
                            projContentRec.CheckList_Name__c = progContentRec.CheckList_Name__c;
                            projContentRec.Display_Label__c = progContentRec.Display_Label__c;
                            projContentRec.Active__c = progContentRec.Active__c;
                            // Begin of change 6/12/2016 T-01218
                            // As part T-01218 we are populating Type and Sub_Type__c also
                            // while creating the Project content
                            projContentRec.Type__c = progContentRec.Type__c;
                            projContentRec.Sub_Type__c = progContentRec.Sub_Type__c;
                            // End of Change 6/12/2016 T-01218
                            projContentRec.Sequence__c = progContentRec.Sequence__c;
                            projContentRec.Project__c = projRec.Id;
                            projContentListToInsert.add(projContentRec);

                        } else if(progContentRec.RecordType.DeveloperName == 'Incentive_Factor') {
                            projContentRec.RecordTypeId = incentiveFactorRecordTypeId;
                            projContentRec.Display_Label__c = progContentRec.Display_Label__c;
                            projContentRec.Active__c = progContentRec.Active__c;
                            projContentRec.Sequence__c = progContentRec.Sequence__c;
                            projContentRec.Project__c = projRec.Id;
                            projContentRec.Value__c = progContentRec.Value__c;
                            projContentListToInsert.add(projContentRec);
                            // Sean M added 7/10/2017: If this is a LSR project, copy down the Proposal questions from the Soliciation for projects that are created manually
                        } 
					}
                }
            }

            if(projContentListToInsert.size() > 0) {
                insert projContentListToInsert;
            }
        } catch(DMLException e) {

        }
    }


  /*
  * Method Name: createProjectRoleFromProgram
  * Description: This method create a project role record for project
  * @param: List<Project__c> newProjectList
  * @return void
  */
    public static void createProjectRoleFromProgram(List<Project__c> newProjectList) {
        List<Project__c> chpProjectList = new List<Project__c>();
        List<Project__c> otherProjectList = new List<Project__c>();

        for(Project__c projectRec : newProjectList) {
                otherProjectList.add(projectRec);
            
        }



        Map<Id, Project__c> projectIdToProjectMap = new Map<Id, Project__c>([select Program_Version__r.Default_Project_Coordinator__c,RecordTypeId,
                                                                             Program_Version__r.Default_Project_Coordinator__r.FirstName,
                                                                             Program_Version__r.Default_Project_Coordinator__r.LastName,
                                                                             Program_Version__r.Default_Project_Coordinator__r.CompanyName,
                                                                             Program_Version__r.Default_Project_Coordinator__r.Email,
                                                                             Program_Version__r.Default_Project_Coordinator__r.MobilePhone
                                                                             from Project__c where Id IN :otherProjectList]);
        List<Project_Role__c> projectRoleList = new List<Project_Role__c>();

       /* for(Project__c projectObj : otherProjectList){
            if(!ProjectRole_Helper.EXCLUDED_RECORDTYPE_ID_FOR_PROJ_COORDINATOR.contains(projectObj.RecordTypeId) &&
               projectIdToProjectMap.containsKey(projectObj.Id) && projectIdToProjectMap.get(projectObj.Id).Program_Version__r.Default_Project_Coordinator__c != null){

                   Project_Role__c projectRoleObj = new Project_Role__c();
                   projectRoleObj.User__c = projectIdToProjectMap.get(projectObj.Id).Program_Version__r.Default_Project_Coordinator__c;
                   projectRoleObj.FirstName__c = projectIdToProjectMap.get(projectObj.Id).Program_Version__r.Default_Project_Coordinator__r.FirstName;
                   projectRoleObj.LastName__c = projectIdToProjectMap.get(projectObj.Id).Program_Version__r.Default_Project_Coordinator__r.Lastname;
                   projectRoleObj.Phone__c = projectIdToProjectMap.get(projectObj.Id).Program_Version__r.Default_Project_Coordinator__r.MobilePhone;
                   projectRoleObj.Email__c = projectIdToProjectMap.get(projectObj.Id).Program_Version__r.Default_Project_Coordinator__r.Email;
                   projectRoleObj.Company_Name__c = projectIdToProjectMap.get(projectObj.Id).Program_Version__r.Default_Project_Coordinator__r.CompanyName;
                   projectRoleObj.Role__c = ProjectRole_Helper.PROJECT_COORDINATOR_ROLE;
                   projectRoleObj.Project__c = projectObj.Id;
                   projectRoleList.add(projectRoleObj);
               }
        }*/
        if(projectRoleList.size() > 0){
            Database.insert(projectRoleList,false);
        }

    }

       /*
    * Method Name: updateProjectName
    * Description: Purpose to update project name
    * @param: List<Project__c> newProjects
    * @return void
    */
    public static void updateProjectName(List<Project__c> newProjects){
        // Begin of change 6/8/2016 T-01171
        // Creating set to uniquely identify the Project where the Naming is not required.
        Set<id> setProgramVersion = new Set<id>();
        // End of change 6/8/2016 T-01171
        Map<Id, String> programTechnologyMap = new Map<Id, String>();
        Map<Id, Program_Version__c> programVersionMap = new Map<Id, Program_Version__c>();

        Set<Id> projectRecordTypesToSkip = new Set<Id>();

        // ########### Put all Skip logics here #######################
       
        // ########### Put all Skip logics here #######################


        for(Project__c project : newProjects) {
          // Edit: I-02405 - Also run for UPDATE event but only on Proposal or Concept Paper.
          if(!projectRecordTypesToSkip.contains(project.RecordTypeId) &&
                    (Trigger.isInsert || (Trigger.isUpdate && (project.Proposal__c || project.Concept_Paper__c)))) {
            programTechnologyMap.put(project.Program_Version__c, '');
          }
        }

        if(programTechnologyMap.size() > 0) {
            for(Program_Version__c programVer : [SELECT Id, Solicitation_Number__C,Solicitation_Type__c,
                                                        Project_Name_Technology__c,SkipProjectNamingConvention__c
                                                 FROM   Program_Version__c
                                                 WHERE  Id IN : programTechnologyMap.keySet() ]){
                // Begin of change 6/8/2016 T-01171
                // If the "Skip project Naming convention" is chekced then collect the Program version id
                if(!programVer.SkipProjectNamingConvention__c && !Solicitation_Helper.SKIP_NAMING_SOLICITATION_TYPES.contains(programVer.Solicitation_Type__c)) {
                  setProgramVersion.add(programVer.id);
                }
                // End of change 6/8/2016 T-01171
                if(programVer.Project_Name_Technology__c != null ) {
                  programTechnologyMap.put(programVer.Id, programVer.Project_Name_Technology__c);
                }
                programVersionMap.put(programVer.Id, programVer);
            }

            for(Project__c project : newProjects) {

                // KB (09/21/2017) : exclude project naming convention on update for new construction programs
                if(project.Id != null && project.RecordTypeId != null && projectRecordTypesToSkip.contains(project.RecordTypeId))
                {
                  continue;
                }

              // Edit: I-02405 - Also run for UPDATE event but only on Proposal or Concept Paper.
              if(Trigger.isInsert || (Trigger.isUpdate && (project.Proposal__c || project.Concept_Paper__c))) {

                project.Solicitation_Number__C = (programVersionMap.containsKey(project.Program_Version__c) ?
                                                  programVersionMap.get(project.Program_Version__c).Solicitation_Number__C :
                                                  null);
                // Begin of change 6/8/2016 T-01171
                // If the "Skip project Naming convention" is chekced and the project record type is "Clean Transportation"
                if(setProgramVersion.contains(project.Program_Version__c)) {

                    if(project.Proposal__c || project.Concept_Paper__c) {
                      //project.Name = 'TBD'; // I-02463 -- Change Project Name default from TBD - TBD to just TBD when skip project naming convention is checked
                    } else {
                      // End of change 6/8/2016 T-01171
                      project.Name = 'TBD - TBD - ' + programTechnologyMap.get(project.Program_Version__c);
                    }
                }
              }
            }
        }


    }

  /*
  * Method Name: logProjectStatus
  * Description: Purpose to log project status
  * @param: List<Project__c> newProjects
  * @param: Map<Id, Project__c> oldMap
  * @return void
  */
    public static void logProjectStatus(List<Project__c> newProjects, Map<Id, Project__c> oldMap){

        List<Project_Stage__c> newProjectStages = new List<Project_Stage__c>();

        for(Project__c project : newProjects) {

            if(String.isNotBlank(project.Status__c) &&
               (Trigger.isInsert || (Trigger.isUpdate && !project.Status__c.equalsIgnoreCase(oldMap.get(project.Id).Status__c)))){

                 if(!staticMapOfStatusLogging.containsKey(project.Id)) {
                   staticMapOfStatusLogging.put(project.Id, new Set<String>());
                 }

                 if(!staticMapOfStatusLogging.get(project.Id).contains(project.Status__c)) {
                     staticMapOfStatusLogging.get(project.Id).add(project.Status__c);
                     newProjectStages.add(new Project_Stage__c(Project__c = project.Id,
                                                             Status__c = project.Status__c,
                                                             Status_Date__c = DateTime.Now()));
                 }
               }
        }

        if(newProjectStages.size() > 0) {
            insert newProjectStages;
        }
    }


    // Begin of changes Gaurav Sinha S-00323
    /*
    * Purpose     : ZEV method to process to Send emails and/or handle Ops for Change Mod Notifications.
                    i) Emails to contractor, builder (S-00323)
    * Description : By Gaurav Sinha on Jul 27, 2016
    * @param      : newListProjects : List of projects, new version.
    * @param      : oldMapProject : Map of projects, old version.
    * Update      :  Case 00007685 - Ajay Gautam - 05/25/2017 - Moved outside static flag
    */

  
    /*
    * Purpose     : Send email when status is Awarded
    * Description : By Gaurav Sinha on Jul 27, 2016
    * @param      : newListProjects : List of projects, new version.
    * @param      : oldMapProject : Map of projects, old version.
    */
    public  static void manageProjectNotification_Awarded(List<Project__c> lstProjects,Map<id,project__c> oldMapProjects) {
        set<string> CONST_status = new set<string>{ 'Provisional', 'Full', 'Probation'};
            list<project__c> AwardedNotificationProjects = new List<project__c>();
        Map<id,List<Project__c>> programid = new Map<id,List<Project__c>> ();
        Set<id> Accountid = new set<id>();

        for(Project__c objProject : lstProjects) {
            System.debug(oldMapProjects.get(objProject.id));

            if(Clean_Transportation_Helper.PROJECT_STATUS_AWARDED.equalsIgnoreCase(objProject.Status__c)) {
                if(  !objProject.Status__c.equalsIgnoreCase(oldMapProjects.get(objProject.id).Status__c)) {
                    // Send Awarded Notifications Adviser
                    AwardedNotificationProjects.add(objProject);
                    if(objProject.program__c!=null){
                        if(programid.get(objProject.program__c)==null)
                            programid.put(objProject.program__c,new list<Project__c>{objProject});
                        else
                            programid.get(objProject.program__c).add(objProject);
                    }
                }
            }
        }
        // Account id for the accociated Primary retrieved
        for(Project_Role__c varloop:[SELECT  Contact__c, Contact__r.AccountId
                                     FROM    Project_Role__c
                                     WHERE   Role__c = :ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE
                                     AND     Primary_Customer_Contact__c = true
                                     and    Contact__c!=null
                                     and project__c in :AwardedNotificationProjects]){
            Accountid.add(varloop.Contact__r.AccountId);
        }
        // Reriving all the valid Program Partnerships
        // If a Program partner ship exist then we do need to send the email
        Map<id,List<Program_Partnership__c>> mapPP = new Map<id,List<Program_Partnership__c>>();
        for(Program_Partnership__c varloop :[select id,program__c
                                             from Program_Partnership__c
                                             where account__C in :accountid
                                             and   program__c in : programid.keyset()
                                             and program__r.Send_Contractor_Application_when_Awarded__c = true
                                             and status__c in:CONST_status ] ){
                                                 if(mapPP.get(  varloop.program__C)==null){

                                                     mapPP.put( varloop.program__C, new List<Program_Partnership__c>{ varloop});

                                                 }else{
                                                     mapPP.get(  varloop.program__C).add(Varloop);
                                                 }


                                             }
        List<Project__c> sendData = new List<Project__c>();
        for(Project__c varloop : AwardedNotificationProjects){
            if(mapPP.get(varloop.program__c)!=null){
                sendData.add(varloop);
            }
        }
        //if(!sendData.isempty())
          // CORE_EmailNotificationUtil.prepareAndSendProjectEmailViaEmailConfig_StatusBased(sendData, true);
    }


}//EOF