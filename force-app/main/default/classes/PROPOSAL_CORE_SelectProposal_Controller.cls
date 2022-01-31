/*
* Class Name: PROPOSAL_CORE_SelectProposal_Controller
* Description: Controller to handle the functionalities of Proposal/concept Paper creation
* Author/Date:  Ajay Gautam ,  3/8/2017
*
* Date         New/Modified      Author             Description
* 05/09/2017   Modified          Harshit Jain       T-02333
* 06/01/2017   Modified          Ajay Gautam        T-02464 FIX - Read projects from project role using account/contact of the logged in user
* 06/30/2017   Modified          Ajay Gautam        T-02655 - Add exception for paper submission process
* 09/14/2017   Modified          Ajay Gautam        S-01055 - Multi round with concept paper and parallel activities
*
*/

public with sharing class PROPOSAL_CORE_SelectProposal_Controller {

    public Program_Version__c solicitationRec {get;set;}
    public String solicitationId {get; set;}
    public String projectId {get; set;}
    public List<ProjectDetail> projectDetailList {get; set;}
    public List<ProjectDetail> conceptPaperList {get; set;}
    public List<ProjectDetail> proposalList {get; set;}
    public List<MenuItem> lstMenuItems { get; set; }
    public String accountId, contactId, accountName;
    public string greenBankLogoURL{get;set;}
    public Boolean conceptPaperNeededOnProject {get; private set;}
    public Boolean conceptPaperPassedOnProject {get; private set;}
    public List<Project__c> existingConceptPaperProjectList_PASSED {get; private set;}

    public Boolean isDueDatePassed {get; set;}
    public Boolean isConceptPaperDueDatePassed {get; set;}
    public Boolean isExceptionalAccessProvided {get; set;}

    private static String GREEN_BANK_LOGO = 'NY_Green_Bank_Logo';
    private String SITE_PAGE_NAME = 'PROPOSAL_CORE_Site_Page';

    public class ProjectDetail {
        public String principalInvestigator {get; set;}
        public Project__c projectRec {get; set;}

        public Boolean isDueDatePassed_Project {get; set;}
        public Boolean isConceptPaperDueDatePassed_Project {get; set;}
        public Boolean isAlreadySubmittedProposalOnCP  {get; set;}

        public ProjectDetail(Project__c projectRec, String primaryContactName) {
          this.principalInvestigator = primaryContactName;
          this.projectRec = projectRec;
          this.isDueDatePassed_Project = true;
          this.isConceptPaperDueDatePassed_Project = true;
          this.isAlreadySubmittedProposalOnCP = false;

          // S-01055 - Due date calculations - Project Level to support multi round
          if(projectRec.Solicitation_Round__c != null) {
              this.isConceptPaperDueDatePassed_Project = (projectRec.Solicitation_Round__r.Concept_Paper_Due_Date__c < system.now());
              this.isDueDatePassed_Project = (projectRec.Solicitation_Round__r.Due_Date__c < system.now());
          }

          this.isAlreadySubmittedProposalOnCP = (projectRec.Projects__r.size() > 0 && projectRec.Projects__r[0].Status__c != 'Unsubmitted');

        }
    }

    public Id selectedRoundPaperSubmission {get;set;}
    public Boolean isConceptPaperSelectedPaperSubmission {get;set;}

    public PROPOSAL_CORE_SelectProposal_Controller() {
        lstMenuItems = new List<MenuItem>();
        lstMenuItems.add(new MenuItem('Grants Listing', 'Review Grants Listing.', ' fa-bar-chart', 'PROPOSAL_CORE_Listing_Page'));
        lstMenuItems.add(new MenuItem('Proposal Listing', 'Review Proposal Listing.', 'fa-list', 'PROPOSAL_CORE_Listing_Page'));

        conceptPaperNeededOnProject = false;
        conceptPaperPassedOnProject = false;
        projectId = '';
         existingConceptPaperProjectList_PASSED = new List<Project__c>();
        conceptPaperList = new List<ProjectDetail>();
        proposalList = new List<ProjectDetail>();

        for(User user : [SELECT Contact.AccountId, Contact.Account.Name FROM User WHERE Id =: UserInfo.getUserId()]){
            accountId = (user.ContactId != null) ? user.Contact.AccountId : null;
            contactId = (user.ContactId != null) ? user.ContactId : null;
            accountName = user.Contact.Account.Name;
        }
        solicitationId = Apexpages.currentPage().getParameters().get('SolicitationId');

        try {
          // Paper Submission -- Exceptional scenario
          selectedRoundPaperSubmission =        (  Apexpages.currentPage().getParameters().containsKey('selectedRoundPaperSubmission')?
                                                     Id.valueOf(Apexpages.currentPage().getParameters().get('selectedRoundPaperSubmission')):
                                                     null
                                                   );
          isConceptPaperSelectedPaperSubmission = (  Apexpages.currentPage().getParameters().containsKey('isConceptPaperSelectedPaperSubmission')?
                                                     Boolean.valueOf(Apexpages.currentPage().getParameters().get('isConceptPaperSelectedPaperSubmission')):
                                                     false
                                                   );
        } catch(Exception e) {
          // Do nothing
          selectedRoundPaperSubmission = null;
          isConceptPaperSelectedPaperSubmission = false;
        }

        List<Program_Version__c> solicitationList = [SELECT Name, Concept_Paper__c, Concept_Paper_Pass_Score__c, NY_Green_Bank_RFP__c,
                                                            Solicitation_Type__c,Solicitation_Number__c,
                                                            ( SELECT  Due_Date__c, Concept_Paper_Due_Date__c
                                                              FROM    Solicitation__r
                                                              WHERE   Status__c = 'Open' ORDER BY Concept_Paper_Due_Date__c, Due_Date__c)
                                                     FROM   Program_Version__c
                                                     WHERE  Id =: solicitationId];

                                                     // WHERE   Status__c = 'Open' ORDER BY CreatedDate DESC LIMIT 1 )

        if(solicitationList.size() > 0) {
            solicitationRec = solicitationList[0];
            checkAndListExistingProjects();
            if(solicitationRec.NY_Green_Bank_RFP__c) {
            List<Document> logoDocumentList = [select Id from Document where DeveloperName =: GREEN_BANK_LOGO];
            if(logoDocumentList.size() > 0) {
              greenBankLogoURL = Label.Core_NYSERDA_Internal_URL + 'servlet/servlet.ImageServer?id=' + logoDocumentList[0].Id + '&oid='+ UserInfo.getOrganizationId();
            }
          }
        }

        isDueDatePassed = checkForDueDate();
        isConceptPaperDueDatePassed = checkForConceptPaperDueDate();
        isExceptionalAccessProvided = Solicitation_Helper.checkForExceptionalAccess(); // T-02655
    }

    /*
    * Method Name: checkAndListExistingProjects
    * Description: Method for checking existing Project List. T-02117:Allow portal user to submit multiple proposals/CP
    * @param: none
    * @return: PageReference
    */

    public PageReference checkAndListExistingProjects() {

        // Keep it local to method in order to avoid heavy page size

        List<Project__c> existingProjectList = new List<Project__c>();
        //Id solicitationRoundId = (solicitationRec.Solicitation__r.size() > 0) ? solicitationRec.Solicitation__r[0].Id : null;


        // FIX - Read projects from project role using account/contact of the logged in user (Ajay Gautam 06/01/2017 T-02464)
        Set<Id> projectIdsFromRelatedRole = new Set<Id>();
        Set<String> SET_ROLES_FOR_PROPOSAL_CONCEPT_PAPER_SUBMITTER = new Set<String>{ ProjectRole_Helper.PROJECT_PROPOSER_ROLE,
                                                                                      ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE};
        for(Project_Role__c objRole : [ SELECT  Role__c, Project__c,
                                                Contact__r.AccountId, Contact__c, Account__c
                                        FROM    Project_Role__c
                                        WHERE   Role__c IN :SET_ROLES_FOR_PROPOSAL_CONCEPT_PAPER_SUBMITTER
                                        AND     Account__c = :accountId
                                        AND     (Project__r.Concept_Paper__c = true OR Project__r.Proposal__c = true)
                                        AND     Project__r.Program_Version__c =: solicitationRec.Id
                                        AND     Account__c != null]) {

                                          //AND     Project__r.Solicitation_Round__c = :solicitationRoundId

          projectIdsFromRelatedRole.add(objRole.Project__c);
        }
        //EndOf: FIX - Read projects from project role using account/contact of the logged in user  (Ajay Gautam 06/01/2017 T-02464)

        existingProjectList = [ SELECT  Status__c, Concept_Paper_Result__c, Concept_Paper__c, Proposal__c,Recommendation__c,
                                                  Name, Proposed_Total_Cost__c, CreatedBy.Name,
                                                  Program_Version__c, Program_Version__r.Solicitation_Type__c,
                                                  Solicitation_Round__c,Solicitation_Round__r.Name,
                                                  Solicitation_Round__r.Due_Date__c,Solicitation_Round__r.Concept_Paper_Due_Date__c,
                                                  Solicitation_Round__r.Status__c,
                                                  (SELECT FirstName__c, LastName__c from Project_Roles__r where Primary_Customer_Contact__c = true limit 1),
                                                  (Select Concept_Paper__c, Proposal__c,Status__c From Projects__r WHERE Proposal__c = true LIMIT 1)
                                          FROM    Project__c
                                          WHERE   (Id IN :projectIdsFromRelatedRole) // FIX: Read projects from project role also
                                          AND     Program_Version__c =: solicitationRec.Id
                                          ];

                              //AND     Solicitation_Round__c = :solicitationRoundId

        for(Project__c projectRec : existingProjectList) {
            if(projectRec.Concept_Paper__c) {
                if(projectRec.Project_Roles__r.size() > 0) {
                    conceptPaperList.add(new ProjectDetail(projectRec, projectRec.Project_Roles__r[0].FirstName__c + ' ' + projectRec.Project_Roles__r[0].LastName__c));
                } else {
                    conceptPaperList.add(new ProjectDetail(projectRec, projectRec.CreatedBy.Name));
                }
            } else if(projectRec.Proposal__c) {
                if(projectRec.Project_Roles__r.size() > 0) {
                    proposalList.add(new ProjectDetail(projectRec, projectRec.Project_Roles__r[0].FirstName__c + ' ' + projectRec.Project_Roles__r[0].LastName__c));
                } else {
                    proposalList.add(new ProjectDetail(projectRec, projectRec.CreatedBy.Name));
                }
            }
        }


      //conceptPaperNeededOnProject = (conceptPaperNeededOnProject && !conceptPaperPassedOnProject);
      return null; // For future scope if we need this method to behave as Action attribute
    }

    /*
    * Method Name: navigateToExistingProject
    * Description: Method to navigate existing Project
    * @param: none
    * @return: PageReference
    */

    public PageReference navigateToExistingProject() {
      System.debug('>>> projectId = ' + projectId);
      String currentPageName = ApplicationWizard_Controller.jumpToWizardPage(projectId);
      System.debug('>>> currentPageName = ' + currentPageName);
      PageReference nextPageURL = new PageReference('/apex/' + currentPageName + '?ProjectId='+ projectId);
      nextPageURL.setRedirect(true);
      return nextPageURL;
    }


    public Boolean isConceptPaper {get; set;}
    public List<Project__c> parentConceptPaperList;

    /*
    * Method Name: createNewProject
    * Description: Method to create new projects
    * @param: none
    * @return: PageReference
    */
    public PageReference createNewProject() {
        PageReference nextPageURL = null;

        // Keep it local to method in order to avoid heavy page size
        solicitationRec = solicitationRec;
        solicitationId = solicitationId;
        if(parentConceptPaperList == null) {
            parentConceptPaperList = new List<Project__c>();
        }

        String projectId = insertProject(isConceptPaper, parentConceptPaperList);
        nextPageURL = PageNavigationUtility.getNextPageURL(projectId, 'Programs_Page', null);
        if(nextPageURL != null) {
            nextPageURL.setRedirect(true);
        }
        return nextPageURL;
    }

    /*
    * Method Name: checkForExistingProposal
    * Description: Method for checking For Existing Proposal
    * @param: none
    * @return: PageReference
    */

    public PageReference checkForExistingProposal() {
        if(String.isBlank(projectId)) {
            return null;
        }

        List<Project__c> existingProposalList = [select Id, Solicitation_Round__c from Project__c where Parent_Project__c =: projectId];
        PageReference nextPageURL = null;
        if(existingProposalList.size() > 0) {
            projectId = existingProposalList[0].Id;
            nextPageURL = navigateToExistingProject();
        } else {
            isConceptPaper = false;
            parentConceptPaperList = [select Id, Solicitation_Round__c from Project__c where Id =: projectId];
            nextPageURL = createNewProject();
        }
        return nextPageURL;
    }

    /*
    * Method Name: checkForDueDate
    * Description: Method for checking due date
    * @param: none
    * @return: Boolean
    */

    public Boolean checkForDueDate() {
        Boolean isDueDatePassed = false;
        /*
        if(solicitationRec.Solicitation__r.size() > 0 && solicitationRec.Solicitation__r[0].Due_Date__c < system.now()) {
            isDueDatePassed = true;
        }
        */
        for(Solicitation_Round__c objRound : solicitationRec.Solicitation__r) {
          if(objRound.Due_Date__c != null && objRound.Due_Date__c < system.now()) {
            isDueDatePassed = true;
          } else {
            isDueDatePassed = false;
            break;
          }
        }

        return isDueDatePassed;
    }

    /*
    * Method Name: checkForConceptPaperDueDate
    * Description: Method checking for Concept Paper Due Date
    * @param: none
    * @return: Boolean
    */

    public Boolean checkForConceptPaperDueDate() {
        Boolean isConceptPaperDueDatePassed = false;
        /*
        if(solicitationRec.Solicitation__r.size() > 0 && solicitationRec.Concept_Paper__c
          && solicitationRec.Solicitation__r[0].Concept_Paper_Due_Date__c < system.now()) {
            isConceptPaperDueDatePassed = true;
        }
        */
        for(Solicitation_Round__c objRound : solicitationRec.Solicitation__r) {
          if(objRound.Concept_Paper_Due_Date__c != null && objRound.Concept_Paper_Due_Date__c < system.now()) {
            isConceptPaperDueDatePassed = true;
          } else {
            isConceptPaperDueDatePassed = false;
            break;
          }
        }
        return isConceptPaperDueDatePassed;
    }

    /*
    * Method Name: setProject
    * Description: Method to set project
    * @param: none
    * @return: PageReference
    */

    public PageReference setProject() {
        Pagereference nextPageURL = null;
        isConceptPaper = false;
        Boolean conceptPaperOnProject = false;
        List<Project__c> existingConceptPaperProjectList = new List<Project__c>();
        List<Project__c> existingConceptPaperProjectList_PASSED  = new List<Project__c>();

        // Identify Solicitation Round  // I-02394
        //Id solicitationRoundId = fetchSolicitationRoundId(solicitationRec.Id);
        Id solicitationRoundId = null;
        // EndOf: Identify Solicitation Round

        if(solicitationRec != null) {

            isConceptPaper = solicitationRec.Concept_Paper__c;

            if(solicitationRec.Concept_Paper__c) {
                User currentUserInfo = Utility_User_Helper.currentLoggedInUser;
                accountId = currentUserInfo.AccountId;

                // FIX - Read projects from project role using account/contact of the logged in user (Ajay Gautam 06/01/2017 T-02464)
                Set<Id> projectIdsFromRelatedRole = new Set<Id>();
                for(Project_Role__c objRole : [ SELECT  Role__c, Project__c,
                                                        Contact__r.AccountId, Contact__c, Account__c
                                                FROM    Project_Role__c
                                                WHERE   Role__c = :ProjectRole_Helper.PROJECT_PROPOSER_ROLE
                                                AND     Account__c = :accountId
                                                AND     Project__r.Concept_Paper__c = true
                                                AND     Project__r.Program_Version__c =: solicitationRec.Id
                                                AND     Account__c != null]) {

                      // //AND     Project__r.Solicitation_Round__c = :solicitationRoundId

                  projectIdsFromRelatedRole.add(objRole.Project__c);
                }
                //EndOf: FIX - Read projects from project role using account/contact of the logged in user  (Ajay Gautam 06/01/2017 T-02464)


                existingConceptPaperProjectList = [ SELECT  Status__c, Concept_Paper_Result__c
                                                    FROM    Project__c
                                                    WHERE   (Id IN :projectIdsFromRelatedRole)
                                                    AND     Program_Version__c =: solicitationRec.Id
                                                    AND     Concept_Paper__c = true];

                     //AND     Solicitation_Round__c = :solicitationRoundId

                if(existingConceptPaperProjectList.size() > 0) {
                    return null;
                } else {
                    conceptPaperOnProject = true;
                }
            }
        }

        if(true) {
            if(!isConceptPaper) {
                conceptPaperOnProject = false;
            }

            conceptPaperOnProject = (conceptPaperOnProject && existingConceptPaperProjectList_PASSED.size() == 0);

            if(!checkForDueDate() || isExceptionalAccessProvided) { // T-02655


              // FIX - Read projects from project role using account/contact of the logged in user (Ajay Gautam 06/01/2017 T-02464)
              Set<Id> projectIdsFromRelatedRole = new Set<Id>();
              Set<String> SET_ROLES_FOR_PROPOSAL_CONCEPT_PAPER_SUBMITTER = new Set<String>{ ProjectRole_Helper.PROJECT_PROPOSER_ROLE,
                                                                                            ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE};
              for(Project_Role__c objRole : [ SELECT  Role__c, Project__c,
                                                      Contact__r.AccountId, Contact__c, Account__c
                                              FROM    Project_Role__c
                                              WHERE   Role__c IN :SET_ROLES_FOR_PROPOSAL_CONCEPT_PAPER_SUBMITTER
                                              AND     Account__c = :accountId
                                              AND     Project__r.Proposal__c = true
                                              AND     Project__r.Program_Version__c =: solicitationRec.Id
                                              AND     Account__c != null]) {

                                              //AND     Project__r.Solicitation_Round__c = :solicitationRoundId

                projectIdsFromRelatedRole.add(objRole.Project__c);
              }
              //EndOf: FIX - Read projects from project role using account/contact of the logged in user  (Ajay Gautam 06/01/2017 T-02464)

              List<Project__c> existingProposalList = [ SELECT  Status__c, Concept_Paper_Result__c, Concept_Paper__c, Proposal__c
                                                                  FROM    Project__c
                                                                  WHERE   (Id IN :projectIdsFromRelatedRole)
                                                                  AND     Program_Version__c =: solicitationRec.Id
                                                                  AND     Proposal__c = true
                                                                  ORDER BY CreatedDate Desc LIMIT 1];

                                                                  //AND     Solicitation_Round__c = :solicitationRoundId

              if(existingProposalList.size() == 0) {
                  // Let's create new Proposal record here
                  String projectId = insertProject(conceptPaperOnProject, existingConceptPaperProjectList_PASSED);
                  nextPageURL = PageNavigationUtility.getNextPageURL(projectId, 'Programs_Page', null);
                  return nextPageURL;
              } else {
                  // There is one existing Proposal at minimum, navigate to Display All Proposals
                 return null; // T-02117: Allow portal user to submit multiple proposals/CP
              }

            } else {
                isDueDatePassed = true;
                return null;
            }
        } else {
            return null;
        }
    }

    /*
    * Method Name: fetchSolicitationRoundId
    * Description: Method for Fetching Open Solicitation Round record Id
    * @param: Id solicitationId
    * @return: Id
    */

    public Id fetchSolicitationRoundId(Id solicitationId, Boolean conceptPaper) {
        Id solicitationRoundId = null;
        Datetime dtNow = System.now();
        Datetime cpDueDate, proposalDueDate;

        System.debug('>>> conceptPaper = ' + conceptPaper);

        List<Solicitation_Round__c> solicitationRoundList = [SELECT Id, Concept_Paper_Due_Date__c, Due_Date__c
                                                             FROM   Solicitation_Round__c
                                                             WHERE  Solicitation__c =: solicitationId
                                                             AND    Status__c = 'Open' ORDER BY Concept_Paper_Due_Date__c, Due_Date__c];
        if(solicitationRoundList.size() > 0) {
          if(conceptPaper) {
            for(Solicitation_Round__c objRound : solicitationRoundList) {
              if(objRound.Concept_Paper_Due_Date__c > dtNow) {
                if(cpDueDate == null || cpDueDate > objRound.Concept_Paper_Due_Date__c) {
                  cpDueDate = objRound.Concept_Paper_Due_Date__c;
                  solicitationRoundId = objRound.Id;
                }
              }
            }
          } else {
            for(Solicitation_Round__c objRound : solicitationRoundList) {
              if(objRound.Due_Date__c > dtNow) {
                if(proposalDueDate == null || proposalDueDate > objRound.Due_Date__c) {
                  proposalDueDate = objRound.Due_Date__c;
                  solicitationRoundId = objRound.Id;
                }
              }
            }
          }
        }

        System.debug('>>> solicitationRoundId = ' + solicitationRoundId);
        return solicitationRoundId;
    }


    /*
    * Method Name: insertProject
    * Description: Method for inserting projects
    * @param: Boolean conceptPaperOnProject, List<Project__c> existingConceptPaperProjectList
    * @return: Id
    */

    public Id insertProject(Boolean conceptPaperOnProject, List<Project__c> existingConceptPaperProjectList) {
        Project__c projectRec = new Project__c();
        projectRec.Program_Version__c = solicitationId;
        List<Program_Version__c> programVersionList = new List<Program_Version__c>();

        // Identify Solicitation Round  // I-02394
        //Id solicitationRoundId = fetchSolicitationRoundId(solicitationId);
        Id solicitationRoundId = null;
        // EndOf: Identify Solicitation Round


        if(String.isNotBlank(solicitationId)) {
            programVersionList = [SELECT Concept_Paper__c, Required_Site_on_Concept_Paper__c,Required_Site_on_Proposal__c,
                                         Certification_Statement_for_Applicant__c,Program__c
                                  FROM   Program_Version__c
                                  WHERE  Id =: solicitationId];

            if(programVersionList.size() > 0) {

                  projectRec.Statement__c = Label.CORE_Default_Solicitation_AttestationStatement;

                if(programVersionList[0].Concept_Paper__c && !conceptPaperOnProject) {
                    projectRec.Parent_Project__c = (existingConceptPaperProjectList.size() > 0) ? existingConceptPaperProjectList[0].Id : null;
                    projectRec.Solicitation_Round__c = (existingConceptPaperProjectList.size() > 0) ? existingConceptPaperProjectList[0].Solicitation_Round__c : null;
                }
            }
        }

        solicitationRoundId = fetchSolicitationRoundId(solicitationRec.Id, conceptPaperOnProject); // S-01055

        if(projectRec.Solicitation_Round__c == null && solicitationRoundId != null) {
            projectRec.Solicitation_Round__c = solicitationRoundId;
        }

        if(programVersionList.size() > 0) {
            projectRec.Program__c = programVersionList[0].Program__c;
        }

        projectRec.Concept_Paper__c = conceptPaperOnProject;
        projectRec.Proposal__c = !conceptPaperOnProject;

        // ######### Paper Submisison Exceptional #########
        if(selectedRoundPaperSubmission != null) {
          projectRec.Solicitation_Round__c = selectedRoundPaperSubmission;
          projectRec.Concept_Paper__c = isConceptPaperSelectedPaperSubmission;
          projectRec.Proposal__c = !isConceptPaperSelectedPaperSubmission;
        }
        // ######### Paper Submisison Exceptional #########

        projectRec.Name = 'TBD';
        projectRec.Status__c = 'Unsubmitted';
        projectRec.RecordTypeId = Utility_RecordType_Helper.getRecordType('Project__c', 'Solicitation_Submission').Id;
        system.debug('project records ====>> '+projectRec);
        insert projectRec;
		
        // Temporary Code for Demo - Need To Remove 
        for(Project__c pro : [SELECT Id,Name,Application_Number__c FROM Project__c where id=: projectRec.Id]){
            projectRec.Name = 'Devereux Advanced Behavioral Health - ' + pro.Application_Number__c;
        }
        update projectRec;
        // Temporary Code for Demo - Need To Remove 
        
        copyProgramContents(solicitationId, projectRec.Id);


        if(programVersionList.size() > 0 && programVersionList[0].Concept_Paper__c && !conceptPaperOnProject) {
            copyRelatedDataFromConceptPaperToProposal(projectRec.Parent_Project__c, projectRec.Id);
        }

        // I-02375: Concept Paper: Site page optional can be configured at solicitation. If this is not needed then REMOVE it from Project level.
        if(programVersionList.size() > 0 && conceptPaperOnProject && !programVersionList[0].Required_Site_on_Concept_Paper__c) {
            removeSiteTemplate(projectRec.Id);
        }

        // I-02406
        if(programVersionList.size() > 0 && !conceptPaperOnProject && !programVersionList[0].Required_Site_on_Proposal__c) {
            removeSiteTemplate(projectRec.Id);
        }

        return projectRec.Id;
    }

    /*
    * Method Name: copyProgramContents
    * Description: Method copying program contents
    * @param: Id solicitationId, Id projectId
    * @return: void
    */

    @testVisible
    private void copyProgramContents(Id solicitationId, Id projectId) {
        Id proposalRecordTypeId = Utility_RecordType_Helper.getRecordType('Program_Content__c', Proposal_Helper.PROPOSAL_PROGRAM_CONTENT_RECORD_TYPE_DEVELOPER_NAME).Id;

        List<Program_Content__c> programContentList = [select Display_Label__c, Type__c, Sequence__c, Explanation_Required_On__c, Active__c, Question_Type__c,
                                                            Concept_Paper__c, Help_Text__c
                                                            from Program_Content__c where Program_Version__c =: solicitationId AND RecordTypeId =: proposalRecordTypeId
                                                            AND Active__c = true];
        proposalRecordTypeId = Utility_RecordType_Helper.getRecordType('Project_Content__c', Proposal_Helper.PROPOSAL_PROJECT_CONTENT_RECORD_TYPE_DEVELOPER_NAME).Id;

        List<Project_Content__c> projectContentList = new List<Project_Content__c>();
        for(Program_Content__c programContentRec : programContentList) {
            Project_Content__c projectContentRec = new Project_Content__c();
            projectContentRec.Active__c = programContentRec.Active__c;
            projectContentRec.Display_Label__c = programContentRec.Display_Label__c;
            projectContentRec.Type__c = programContentRec.Type__c;
            projectContentRec.Sequence__c = programContentRec.Sequence__c;
            projectContentRec.Explanation_Required_On__c = programContentRec.Explanation_Required_On__c;
            projectContentRec.Question_Type__c = programContentRec.Question_Type__c;
            projectContentRec.Project__c = projectId;
            projectContentRec.Help_Text__c = programContentRec.Help_Text__c;
            projectContentRec.RecordTypeId = proposalRecordTypeId;
            projectContentList.add(projectContentRec);
        }

        if(projectContentList.size() > 0) {
            insert projectContentList;
        }
    }

    /*
    * Method Name: copyRelatedDataFromConceptPaperToProposal
    * Description: Method copying related data from Concept Paper to Proposal
    * @param: Id conceptPaperProjectId, Id proposalProjectId
    * @return: void
    */

    @testVisible
    private void copyRelatedDataFromConceptPaperToProposal(Id conceptPaperProjectId, Id proposalProjectId) {
        List<Project__c> conceptPaperDetailList = [select Description__c, Proposed_Proposal_Category__c, Proposed_NYSERDA_Cost__c, Propsoed_Cost_Share__c, Proposed_Total_Cost__c,
                                                        Company_Information__c, Name,
                                                    (Select Account__c, Contact__c, Name, FirstName__c, LastName__c, Address_1__c, Address_2__c, City__c, zip__c, County__c, State__c,
                                                            Email__c, Phone__c, Project__c, Role__c, Primary_Customer_Contact__c, Company_Name__c, Title__c, Company_TIN_Confirmation__c,
                                                            Tax_Identification_Type__c, Employee_Identification_Number_EIN__c, DUNS_Number__c, Alternate_Party__c
                                                     from Project_Roles__r),
                                                     (Select Site_Name__c, Address_1__c, Address_2__c, City__c, Zip__c, County__c, State__c, NYISO_Zone__c, Utility_Company__c,
                                                        Project__c, Electric_Utility_Account_Number__c, Regional_Economic_Development_Council__c, Is_Contributing_to_SBC__c,
                                                        Gas_Utility_Company__c, Gas_Utility_Account_Number__c from Project_Site__r)
                                                from Project__c where Id =: conceptPaperProjectId];

        if(conceptPaperDetailList.size() > 0) {
            Project__c proposalRec = new Project__c(Id= proposalProjectId);
            proposalRec.Description__c = conceptPaperDetailList[0].Description__c;
            proposalRec.Name = conceptPaperDetailList[0].Name;
            proposalRec.Company_Information__c = conceptPaperDetailList[0].Company_Information__c;
            proposalRec.Proposed_Proposal_Category__c = conceptPaperDetailList[0].Proposed_Proposal_Category__c;
            proposalRec.Proposed_NYSERDA_Cost__c = conceptPaperDetailList[0].Proposed_NYSERDA_Cost__c;
            proposalRec.Propsoed_Cost_Share__c = conceptPaperDetailList[0].Propsoed_Cost_Share__c;
            update proposalRec;

            List<Project_Role__c> contactListToInsert = new List<Project_Role__c>();
            for(Project_Role__c projectRoleRec : conceptPaperDetailList[0].Project_Roles__r) {
                Project_Role__c projectRoleRec_new = new Project_Role__c();
                projectRoleRec_new = projectRoleRec.clone(false, true);
                projectRoleRec_new.Project__c = proposalProjectId;
                contactListToInsert.add(projectRoleRec_new);
            }

            if(contactListToInsert.size() > 0) {
                insert contactListToInsert;
            }

            List<Project_Site__c> projectSiteListToInsert = new List<Project_Site__c>();
            for(Project_Site__c projectSiteRec : conceptPaperDetailList[0].Project_Site__r) {
                Project_Site__c projectSiteRec_new = new Project_Site__c();
                projectSiteRec_new = projectSiteRec.clone(false, true);
                projectSiteRec_new.Project__c = proposalProjectId;
                projectSiteListToInsert.add(projectSiteRec_new);
            }
            if(projectSiteListToInsert.size() > 0) {
                insert projectSiteListToInsert;
            }
        }
    }


    /*
    * Method Name: removeSiteTemplate
    * Description: Method removing site template
    * @param: Id projectId
    * @return: void
    */

    public void removeSiteTemplate(Id projectId) {
        List<Wizard_Template_Page__c> wizardTempPageList = [SELECT  Page_Name__c, Sequence__c
                                                            FROM    Wizard_Template_Page__c
                                                            WHERE   Wizard_Template__r.Project__c =: projectId
                                                            ORDER BY Sequence__c ASC];

        List<Wizard_Template_Page__c> wizardTempListToDel = new List<Wizard_Template_Page__c>();
        Boolean hasSiteDeleted = false;
        for(Wizard_Template_Page__c wizardTempPageRec : wizardTempPageList) {
            if(wizardTempPageRec.Page_Name__c == SITE_PAGE_NAME) {
                wizardTempListToDel.add(wizardTempPageRec);
                hasSiteDeleted = true;
            }
            if(hasSiteDeleted) {
                wizardTempPageRec.Sequence__c -= 1;
            }
        }

        if(wizardTempPageList.size() > 0) {
            update wizardTempPageList;
        }

        if(wizardTempListToDel.size() > 0) {
            delete wizardTempListToDel;
        }
    }
      public class MenuItem {
        public string name { get; set; }
        public string description { get; set; }
        public string icon { get; set; }
        public string destination { get; set; }

        public MenuItem(string name, string description, string icon, string destination) {
            this.name = name;
            this.description = description;
            this.icon = icon;
            this.destination = destination;
        }
    }
}