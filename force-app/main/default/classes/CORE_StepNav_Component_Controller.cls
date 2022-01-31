/*
* Class Name: CORE_StepNav_Component_Controller
* Description: Controller to handle the funtionalities of CORE_StepNav_Component
* Author/Date:  Harshit Jain    4/26/2016
*
* Date         New/Modified  Author             Description
* 5/7/2017     Modified      Harshit Jain       T-02333
*/

public class CORE_StepNav_Component_Controller {

    public String projectId;
    public String applicationNumber{get; set;}
    public boolean isCTenantProject{get; set;}
    public String applicationId{get;set;}
    public String programId;
    public String caseId{get; set;}
    public String currentPageName {get; set;}
    public Integer currentStepNumber { get;set; }
    public Project__c projectObj {get;set;}
    public List<Wizard_Template_Page__c> projTempPagesList {get; set;}
    public boolean isPayeeApp {get;set;}
    public Boolean isMigratedApplication {get; set;} // Will be TRUE for the Migrated Projects. Project must be created by Integration User and also have a Legacy Application #
    public Boolean isProposal {get; set;}
    public Boolean isNoRecordFoundError {get;set;}
    public Boolean isRedirectToLastPage {get;set;}
    public Boolean isGreenBankSolicitation {get;set;}
    public String applicationLastPage{get;set;}
      public String greenBankLogoURL {get; set;}

    public Boolean isDueDatePassed {get; set;}
    public Boolean isRollingSolicitationLockDown {get; set;}
    public Boolean isReadOnlyProposalApplicationWizard  {get; set;}
    public Boolean isExceptionalAccessProvided {get; set;}
    public Boolean isPortalUser {get; set;}

    private String templateType;
    private String payeeType;
    private Map<String, Integer> pageToSequanceMap = new Map<String, Integer>();
    private static final String CONTRACTOR_APP_TEMPLATE_TYPE = 'Contractor Application';
    private static final String APPLICATION_INTAKE_TEMPLATE_TYPE = 'Application Intake';
    private static final String PROPOSAL_APPLICATION_TEMPLATE_TYPE = 'Proposal Application';
    private static final String PAYEE_APPLICATION_TEMPLATE_TYPE = 'Payee Application';
    private static final String MODIFICATION_APPLICATION_TEMPLATE_TYPE = 'Change Modification Application';
    private static final String CON_APP_NY_SUN_APPLICATION_RECORD_TYPE_DEV_NAME = 'NY_Sun_Application';
    private static final String CON_APP_TYPE_PAYEE = 'payee';
    private static String GREEN_BANK_LOGO = 'NY_Green_Bank_Logo';

    public Wizard_Template_Page__c currentTempPage {
        get{
            if(pageToSequanceMap.containsKey(currentPageName)) {
                currentStepNumber = pageToSequanceMap.get(currentPageName);
                currentTempPage = projTempPagesList[currentStepNumber - 1];
            }
            return currentTempPage;
        }
        private set;
    }

    public CORE_StepNav_Component_Controller() {
       
       
        isMigratedApplication = false;
        projTempPagesList = new List<Wizard_Template_Page__c>();
        projectId = Apexpages.currentPage().getParameters().get('ProjectId');
        applicationId = Apexpages.currentPage().getParameters().get('ApplicationId');
        caseId = Apexpages.currentPage().getParameters().get('caseId');
        payeeType = ApexPages.currentPage().getParameters().get('type');
        //securityKey = ApexPages.currentPage().getParameters().get('key');

        applicationNumber = '';
        greenBankLogoURL = '';
        isCTenantProject = false;

        isProposal = false;
        isDueDatePassed = false;
        isExceptionalAccessProvided = false;
        isRollingSolicitationLockDown = false;
        isReadOnlyProposalApplicationWizard = false;
        isPortalUser = false;

        isNoRecordFoundError = false;
        isRedirectToLastPage = false;


        for(User objUser : [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()]) {
          isPortalUser = (objUser.ContactId != null);
        }

        /*if(String.isNotBlank(applicationId)) {
            isPayeeApp = false;

            List<Contractor_Application__c> conAppList = [SELECT Id, Name, Type__c, RecordType.DeveloperName,Status__c
                                                            FROM Contractor_Application__c
                                                           WHERE Id =: applicationId];
            if(conAppList.size() <= 0) {
                isNoRecordFoundError = true;
            } else if(CON_APP_NY_SUN_APPLICATION_RECORD_TYPE_DEV_NAME.equalsIgnoreCase(conAppList[0].RecordType.DeveloperName)
                                 && CON_APP_TYPE_PAYEE.equalsIgnoreCase(conAppList[0].Type__c)){
                isPayeeApp = true;
            }

            if(conAppList.size() > 0 && conAppList[0].Status__c != 'Unsubmitted') {
                isRedirectToLastPage = true;
            }
        }*/
         if(String.isNotBlank(projectId)) {
            for(Project__c project : [Select  Id, Status__c,Feedback_Rebate_Reserved__c,
                                              Eligible_for_Reserved_Incentive__c,Legacy_Application__c,
                                              Application_Number__c,
                                              Concept_Paper__c, Proposal__c, Program_Version__r.NY_Green_Bank_RFP__c,
                                              Program_Version__r.Solicitation_Type__c,Solicitation_Round__c,
                                              Solicitation_Round__r.Concept_Paper_Due_Date__c,
                                              Solicitation_Round__r.Due_Date__c,
                                              RecordType.Name, RecordType.DeveloperName
                                        FROM  Project__c
                                        WHERE Id =: projectId]) {

                isMigratedApplication = String.isNotBlank(project.Legacy_Application__c);
                projectObj = project;

                applicationNumber = project.Application_Number__c;

                if(project.RecordType != null && project.RecordType.Name == 'Commercial Tenant'){
                    isCTenantProject = true;
                } else if(project.Proposal__c || project.Concept_Paper__c) {
                    isProposal = true;

                    isRollingSolicitationLockDown = (project.Status__c != Project_Helper.PROJECT_STATUS_UNSUBMITTED &&
                                                     project.Program_Version__r.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_ROLLING
                                                    );
                    isDueDatePassed = ( ( project.Concept_Paper__c && project.Solicitation_Round__c != null && project.Solicitation_Round__r.Concept_Paper_Due_Date__c < system.now()) ||
                                        (!project.Concept_Paper__c && project.Solicitation_Round__c != null && project.Solicitation_Round__r.Due_Date__c < system.now())
                                      );
                    isExceptionalAccessProvided = Solicitation_Helper.checkForExceptionalAccess();

                    isReadOnlyProposalApplicationWizard = (isPortalUser && (isDueDatePassed || isRollingSolicitationLockDown) && !isExceptionalAccessProvided);
                }
                isGreenBankSolicitation = (project.Program_Version__r.NY_Green_Bank_RFP__c) ? true : false;
                if(project.Program_Version__r.NY_Green_Bank_RFP__c != null && project.Program_Version__r.NY_Green_Bank_RFP__c) {
                    List<Document> logoDocumentList = [select Id from Document where DeveloperName =: GREEN_BANK_LOGO];
                    if(logoDocumentList.size() > 0) {
                        greenBankLogoURL = Label.Core_NYSERDA_Internal_URL + 'servlet/servlet.ImageServer?id=' + logoDocumentList[0].Id + '&oid='+ UserInfo.getOrganizationId();
                    }
                }
            }

            if(projectObj == null) {
                isNoRecordFoundError = true;
            }
        }

        projTempPagesList = getTempPagesList();

        if(projTempPagesList.size() > 0) {
            programId = projTempPagesList[0].Wizard_Template__r.Program__c;
            applicationLastPage = projTempPagesList[projTempPagesList.size() - 1].Page_Name__c;
        }
        List<Program_Template_Page__c> pTemplatePages = [Select Page_Description__c
                                                           From Program_Template_Page__c
                                                          Where Program_Template__r.Program__c =:programId
                                                            And Program_Template__r.Template_Type__c =:templateType
                                                       Order By Sequence__c ASC];
        for(Integer i=0; i<projTempPagesList.size(); i++) {
            if(pTemplatePages.size() > i) {
                projTempPagesList[i].Page_Description__c = pTemplatePages[i].Page_Description__c;
                pageToSequanceMap.put(projTempPagesList[i].Page_Name__c, Integer.valueOf(projTempPagesList[i].Sequence__c));
            }
        }

    }

    /*
    * Method Name: openPage
    * Description: Method for opening page
    * @param: none
    * @return: pageReference
    */

    public Pagereference openPage() {
     
           return PageNavigationUtility.getTargetPageURL(projectId, currentPageName, applicationId);
   
    }

    /*
        * Method Name: getTempPagesList
        * Description: get all the data of Wizard_Template_Page__c object in a list
        * @param: none
        * @return: List<Wizard_Template_Page__c>
        */

    private List<Wizard_Template_Page__c> getTempPagesList() {
        String query = 'SELECT ';
        for(String fieldName : getTemplatePageFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Wizard_Template_Page__c';

        System.debug('**applicationId**'+applicationId);
        System.debug('**caseId**'+caseId);
        System.debug('**projectId**'+projectId);

        if(String.isNotBlank(caseId) || String.isNotBlank(projectId) || String.isNotBlank(applicationId)) { // Case: 00006041 - fix for Too Many query rows
            if(caseId != null && caseId != ''){
                templateType = MODIFICATION_APPLICATION_TEMPLATE_TYPE;
                query += ' WHERE Wizard_Template__r.Case__c = \'' + CORE_Helper.doEscapeSingleQuotes(caseId) + '\' ORDER BY Sequence__c ASC';
            } else {
                if(projectId != null){
                    if(isProposal) {
                        templateType = PROPOSAL_APPLICATION_TEMPLATE_TYPE;
                    } else {
                        templateType = APPLICATION_INTAKE_TEMPLATE_TYPE;
                    }

                    query += ' WHERE Wizard_Template__r.Project__c = \'' + CORE_Helper.doEscapeSingleQuotes(projectId) + '\' ORDER BY Sequence__c ASC';
                } else if(applicationId != null) {
                    if(payeeType == 'payee') {
                        templateType = PAYEE_APPLICATION_TEMPLATE_TYPE;
                    } else {
                        templateType = CONTRACTOR_APP_TEMPLATE_TYPE;
                    }
                    query += ' WHERE Wizard_Template__r.Service_Provider_Application__c = \'' + CORE_Helper.doEscapeSingleQuotes(applicationId) + '\' ORDER BY Sequence__c ASC';
                }
            }
        } else {
           query += ' WHERE Id = null '; // Case 00006041: STOP the query from returning rows
           return (new List<Wizard_Template_Page__c>());
        }

        System.debug('**query**'+query);

        // Added by TK : Issue I-02455
        List<Wizard_Template_Page__c> wizardTemplateList = Database.query(query);
        if(projectObj != null && projectObj.Concept_Paper__c) {
            for(Wizard_Template_Page__c tempPage : wizardTemplateList) {
                if(tempPage.Name != null && tempPage.Name.contains('Proposal')) {
                    tempPage.Name = tempPage.Name.replace('Proposal', 'Concept Paper');
                }
            }
        }
        //system.assert(false, wizardTemplateList);

        return wizardTemplateList;
    }

    /*
    * Method Name: getTemplatePageFieldList
    * Description: get all the template page fields in a list
    * @param: none
    * @return: static List<String>
    */

    private static List<String> getTemplatePageFieldList(){
        return new List<String>{'Id',
                                'Name',
                                'Wizard_Template__r.Program__c',
                                'Wizard_Template__r.Solicitation__r.Name',
                                'Wizard_Template__r.Solicitation__r.Solicitation_Number__c',
                                'Page_Name__c',
                                'Page_Type__c',
                                'Wizard_Template__c',
                                'Sequence__c',
                                'Status__c',
                                'Wizard_Template__r.Program__r.Name',
                                'Wizard_Template__r.Project__r.Program_Version__r.Name',
                                'Wizard_Template__r.Program__r.Application_Type__c',
                                'Page_Description__c',
                                'Wizard_Template__r.Program__r.Description__c'
        };

    }
}