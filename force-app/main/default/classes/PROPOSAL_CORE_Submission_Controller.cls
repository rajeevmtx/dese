/*
* Class Name: PROPOSAL_CORE_Submission_Controller
* Description: Controller to handle the functionalities of  PROPOSAL_CORE_Submission_Page
* Author/Date: Tarun Khandelwal   1/14/2017
*
* Date         New/Modified    Author            Description
* 4/26/2017    Modified      Harshit Jain        T-02333
* 5/17/2017    Modified      Tarun Khandelwal    T-02349
* 06/30/2017   Modified        Ajay Gautam        T-02655 - Add exception for paper submission process
* 09/14/2017   Modified          Ajay Gautam        S-01055 - Multi round with concept paper and parallel activities
*/

public without sharing class PROPOSAL_CORE_Submission_Controller extends ProposalBase_Controller{

    public String deadLineDate {get; set;}
    public String deadLineTime {get; set;}
    public Boolean isSubmitButtonClicked {get; set;}
    public Boolean isSubmissionAfterDueDate {get; set;}
    public Boolean isSubmittedAgain {get; set;}

    public PROPOSAL_CORE_Submission_Controller() {
        DateTime dt;
        if(project.Concept_Paper__c) {
            dt = project.Solicitation_Round__r.Concept_Paper_Due_Date__c;
        } else {
            dt = project.Solicitation_Round__r.Due_Date__c;
        }
        if(dt != null) {
	        deadLineDate = dt.format('MM/dd/yyyy');
	        deadLineTime = dt.format('hh:mm a');
        }
        isSubmitButtonClicked = (project.Status__c != 'Unsubmitted') ? true :false;
        isSubmissionAfterDueDate = false;
        isSubmittedAgain = false;
    }
    /*
    * Method Name: submit
    * Description: update project
    * @param:  none
    * @return: void
    */

    public void submit() {
        Integer maxProposalNumber = 0;
        if(project.Concept_Paper__c) {
            List<Project__c> projects = [SELECT Proposal_Number__c
                                         FROM   Project__c
                                         WHERE  Program_Version__c =  :project.Program_Version__c
                                         AND    Concept_Paper__c = true
                                         AND    Status__c != 'Unsubmitted'
                                         AND    Proposal_Number__c != null ORDER BY Proposal_Number__c DESC LIMIT 1];

            if(projects.size() > 0) {
              maxProposalNumber = (Integer) projects[0].Proposal_Number__c;
            }
        } else if(project.Proposal__c) {
            List<Project__c> projects = [SELECT Proposal_Number__c
                                         FROM   Project__c
                                         WHERE  Program_Version__c =  :project.Program_Version__c
                                         AND    Proposal__c = true
                                         AND    Status__c != 'Unsubmitted'
                                         AND    Proposal_Number__c != null ORDER BY Proposal_Number__c DESC LIMIT 1];

            if(projects.size() > 0) {
              maxProposalNumber = (Integer) projects[0].Proposal_Number__c;
            }
        }
        maxProposalNumber = (maxProposalNumber != null) ? maxProposalNumber : 0;
        project.Proposal_Number__c = maxProposalNumber + 1;

        isSubmitButtonClicked = true;
        isDueDatePassed = checkForDueDate();
        if(!isDueDatePassed || isExceptionalAccessProvided) {
            if(project.Status__c == 'Submitted') {
                isSubmittedAgain = true;
            } else {
                project.Status__c = 'Submitted';
                update project;
            }
            next();
        } else {
            isSubmissionAfterDueDate = true;
        }
    }
}