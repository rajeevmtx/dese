/*
* Class Name: ProposalBase_Controller
* Description: Base Page Controller for Proposal. All Proposal Controller inherits from this. Controls things that are common across proposal, such as navigation and submission.
* Author/Date: Tarun Khandelwal   1/14/2017
*
* Date         New/Modified      Author             Description
* 09/19/2017   Modified          Harshit Jain       Added param for rolling solicitation lockdown
* 06/30/2017   Modified          Ajay Gautam        T-02655 - Add exception for paper submission process
* 09/14/2017   Modified          Ajay Gautam        S-01055 - Multi round with concept paper and parallel activities
*
*/

public without sharing abstract class ProposalBase_Controller extends Base_Page_Controller{

    // Property to store project Id
    public String projectId {get; set;}
    
    // Domain URL
    public String domainURL{get; set;}

    // Property to store project detail
    public Project__c project {get; set;}

    // Program Id
    public String programId;

    // Properties used on VF page
    public Boolean isDueDatePassed {get; set;}
    public Boolean isRollingSolicitationLockDown {get; set;}
    public Boolean isProjectIsInEditableWizardStatuses {get;set;}

    public Boolean isReadOnlyApplicationWizard  {get; set;}
    public Boolean isExceptionalAccessProvided {get; set;}

    // Current page name
    public String currentPage{get; set;}

    // Constructor
    public ProposalBase_Controller() {
        isDueDatePassed = false;
        isExceptionalAccessProvided = false;
        isRollingSolicitationLockDown = false;
        projectId = Apexpages.currentPage().getParameters().get('ProjectId');
        domainURL = URL.getSalesforceBaseUrl().toExternalForm();
        getProjectDetails();
        isDueDatePassed = checkForDueDate();
        isProjectIsInEditableWizardStatuses = projectIsInEditableWizardStatuses();
        isExceptionalAccessProvided = checkForExceptionalAccess(); // T-02655
        isReadOnlyApplicationWizard = (  ((isDueDatePassed || (!isDueDatePassed && !isProjectIsInEditableWizardStatuses)) || isRollingSolicitationLockDown)
                                       && !isExceptionalAccessProvided
                                       );

    }


    /*
    * Method Name: checkForExceptionalAccess
    * Description: Checking for exceptional access.
    *              T-02655 - Add exception for paper submission process
    * @param:  N/A
    * @return: Boolean
    */
    public virtual Boolean checkForExceptionalAccess() {
        return Solicitation_Helper.checkForExceptionalAccess();
    }

    /*
    * Method Name: projectIsInEditableWizardStatuses -- Security review fix
    * Description: Checking for project status where wizard is editable
    * @param:  none
    * @return: virtual Boolean
    */
    public virtual Boolean projectIsInEditableWizardStatuses() {
        Boolean isEditableWizardStatuses = false;
        if( (Project_Helper.PROJECT_STATUS_UNSUBMITTED.equalsIgnoreCase(project.Status__c)) ||
            (Project_Helper.PROJECT_STATUS_SUBMITTED.equalsIgnoreCase(project.Status__c))) {
            isEditableWizardStatuses = true;
        }
        return isEditableWizardStatuses;
    }

    /*
    * Method Name: getProjectDetails
    * Description: get project list
    * @param:  N/A
    * @return: void
    */
    private void getProjectDetails() {

        // Fetch project detailr record based on project Id
        List<Project__c> projectList = [SELECT  Application_Number__c, Concept_Paper__c, Proposal__c,
                                                Solicitation_Round__r.Concept_Paper_Due_Date__c,
                                                Solicitation_Round__c, Program_Version__c, Signed_Date__c,
                                                Solicitation_Round__r.Due_Date__c, Status__c,
                                                Program_Version__r.Program__r.Name, Program_Version__r.Name,
                                                Program_Version__r.NY_Green_Bank_RFP__c, EnvelopeId__c,
                                                Program_Version__r.Required_Site_on_Concept_Paper__c,
                                                Program_Version__r.Required_Site_on_Proposal__c,
                                                Program_Version__r.Solicitation_Type__c /*,
                                                Program_Version__r.Hide_TaxId_and_DUNS_Number__c */
                                        FROM    Project__c
                                        WHERE   Id = : CORE_Helper.doEscapeSingleQuotes(projectId)];
        if(projectList.size() > 0) {
            project = projectList[0];
            isRollingSolicitationLockDown = (project.Status__c != Project_Helper.PROJECT_STATUS_UNSUBMITTED && project.Program_Version__r.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_ROLLING) ? true :false;
        } else {
            project = new Project__c();
        }
    }

    /*
    * Method Name: checkForDueDate
    * Description: Checking for due date
    * @param:  N/A
    * @return: Boolean
    */
    public virtual Boolean checkForDueDate() {
        Boolean isDueDatePassed = false;
        if( ( project.Concept_Paper__c && project.Solicitation_Round__r.Concept_Paper_Due_Date__c < system.now()) ||
            (!project.Concept_Paper__c && project.Solicitation_Round__r.Due_Date__c < system.now())) {
            isDueDatePassed = true;
        }
        return isDueDatePassed;
    }

    /*
    * Method Name: next
    * Description: getting next URL
    * @param:  N/A
    * @return: Pagereference
    */
    public virtual Pagereference next() {
        return PageNavigationUtility.getNextPageURL(projectId, currentPage, null);
    }

    /*
    * Method Name: previous
    * Description: getting previous URL
    * @param:  N/A
    * @return: Pagereference
    */
    public virtual Pagereference previous() {
        return PageNavigationUtility.getPreviousPageURL(projectId, currentPage, null);
    }
}//EOF