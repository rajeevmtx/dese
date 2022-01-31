/*
* Name: ApplicationWizard_Controller
* Author: Harshit Jain
* Desc: Web servide for application wizard
*/

global class ApplicationWizard_Controller {

    private static String DRAFT_STATUS = 'Draft';
    private static String UNSUBMITTED_STATUS = 'Unsubmitted';
    private static String SUMBMIT_PAGE_TYPE = 'Submit Application';
    private static String APPROVED_STATUS = 'Approved';

    /*
    * Method Name: jumpToWizardPage
    * Description: jump To Wizard Page based on project id
    * @param:  Id projectId
    * @return: static String
    */

    webservice static String jumpToWizardPage(Id projectId) {
        String pageName = '';

        Boolean isPortalUser = false;
        Boolean isDueDatePassed = false;
        Boolean isRollingSolicitationLockDown = false;

        Boolean isExceptionalAccessProvided = Solicitation_Helper.checkForExceptionalAccess();

        for(User objUser : [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()]) {
          isPortalUser = (objUser.ContactId != null);
        }

        List<Wizard_Template__c>  projectTemplates = [SELECT Id,Project__r.Status__c,
                                                             Project__r.Concept_Paper__c, Project__r.Proposal__c,
                                                             Project__r.Program_Version__r.Solicitation_Type__c,
                                                             Project__r.Solicitation_Round__r.Concept_Paper_Due_Date__c,
                                                             Project__r.Solicitation_Round__r.Due_Date__c,
                                                             Project__r.Solicitation_Round__c,
                                                             (  SELECT  Status__c, Page_Name__c, Page_Type__c
                                                                FROM    Wizard_Template_Pages__r ORDER BY Sequence__c)
                                                      FROM    Wizard_Template__c
                                                      WHERE   Project__c =: projectId];

        if(projectTemplates.size() > 0) {
            for(Wizard_Template_Page__c templatePage : projectTemplates[0].Wizard_Template_Pages__r) {

                // T-02597 - Proposer should not be able to see their proposal after it is Submitted.
                if( (projectTemplates[0].Project__r.Concept_Paper__c || projectTemplates[0].Project__r.Proposal__c) && isPortalUser) {


                    isRollingSolicitationLockDown = (projectTemplates[0].Project__r.Status__c != Project_Helper.PROJECT_STATUS_UNSUBMITTED &&
                                                     projectTemplates[0].Project__r.Program_Version__r.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_ROLLING
                                                    );

                    isDueDatePassed = ( ( projectTemplates[0].Project__r.Concept_Paper__c && projectTemplates[0].Project__r.Solicitation_Round__c != null && projectTemplates[0].Project__r.Solicitation_Round__r.Concept_Paper_Due_Date__c < system.now()) ||
                                        (!projectTemplates[0].Project__r.Concept_Paper__c && projectTemplates[0].Project__r.Solicitation_Round__c != null && projectTemplates[0].Project__r.Solicitation_Round__r.Due_Date__c < system.now())
                                      );

                  if((isRollingSolicitationLockDown || isDueDatePassed) && !isExceptionalAccessProvided) {
                    break;
                  }

                }
                // T-02597 - Proposer should not be able to see their proposal after it is Submitted.

                if((templatePage.Page_Type__c == SUMBMIT_PAGE_TYPE && projectTemplates[0].Project__r.Status__c != APPROVED_STATUS) || templatePage.Status__c == DRAFT_STATUS) {
                    return templatePage.Page_Name__c;
                }
                pageName = templatePage.Page_Name__c;
            }
        }

        return pageName;
    }

    /*
    * Method Name: jumpToServiceProviderWizardPage
    * Description: jump To Service Provider Wizard Page based on application id
    * @param:  Id ApplicationId
    * @return: static String
    */ 
 
    webservice static String jumpToServiceProviderWizardPage(Id ApplicationId) {
        String pageName = '';
        List<Wizard_Template__c> applicationTemplates = [Select Id, (Select Status__c, Page_Name__c from Wizard_Template_Pages__r order by Sequence__c) from Wizard_Template__c where Service_Provider_Application__c =: ApplicationId];

        if(applicationTemplates.size() > 0) {
            for(Wizard_Template_Page__c templatePage : applicationTemplates[0].Wizard_Template_Pages__r) {
                if(templatePage.Status__c == DRAFT_STATUS) {
                    return templatePage.Page_Name__c;
                }
                pageName = templatePage.Page_Name__c;
            }  
        }

        return pageName;
    }
}