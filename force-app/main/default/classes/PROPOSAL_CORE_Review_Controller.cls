/*
* Class Name: PROPOSAL_CORE_Review_Controller
* Description: Controller to handle the functionalities of  PROPOSAL_CORE_Review_Page
* Author/Date: Harshit Jain   1/11/2017
*
* Date         New/Modified      Author           Description
* 4/12/2017    Modified        Harshit Jain       T-02333
* 06/30/2017   Modified        Ajay Gautam        T-02655 - Add exception for paper submission process
* 08/04/2017   Modified        Ajay Gautam        Fix: Contractor role and Proposer role issue in filter
*
*/

global with sharing class PROPOSAL_CORE_Review_Controller extends ProposalBase_Controller {

    public List<Project_Role__c> projectRoleList {get; set;}
    public List<Project_Role__c> alternatePartyProjectRoleList {get; set;}
    public List<Project_Role__c> primaryProjectRoleList {get; set;}
    public List<Project_Site__c> projectSiteList {get; set;}
    public List<Project_Content__c> checklistQuestionList {get; set;}
    public List<Project_Content__c> contentQuestionList {get; set;}
    public List<Project_Content__c> disclosureQuestionList {get; set;}

    public Set<String> SET_ROLES_FOR_PROPOSAL_CONCEPT_PAPER_SUBMITTER = new Set<String>{ ProjectRole_Helper.PROJECT_PROPOSER_ROLE,
                                                                                         ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE};                                                                                            
    
    public PROPOSAL_CORE_Review_Controller() {
        project = new Project__c();
        projectRoleList = new List<Project_Role__c>();
        alternatePartyProjectRoleList = new List<Project_Role__c>();
        primaryProjectRoleList = new List<Project_Role__c>();

        projectSiteList = new List<Project_Site__c>();
        checklistQuestionList = new List<Project_Content__c>();
        contentQuestionList = new List<Project_Content__c>();
        disclosureQuestionList = new List<Project_Content__c>();

        Id proposalRecordTypeId = Utility_RecordType_Helper.getRecordType('Project_Content__c', Proposal_Helper.PROPOSAL_PROJECT_CONTENT_RECORD_TYPE_DEVELOPER_NAME).Id;
        List<Project__c> projectList = [SELECT TermsCondition__c, Statement__c, Program_Version__r.Name, Program_Version__r.Program__r.Name, Concept_Paper__c,
                                                Application_Number__c, Proposed_Proposal_Category__c, Company_Information__c,
                                                Description__c, Proposed_NYSERDA_Cost__c, Propsoed_Cost_Share__c, Proposed_Total_Cost__c,
                                                Program_Version__r.NY_Green_Bank_RFP__c,
                                                Program_Version__r.End_User_Types__c, Program_Version__r.Regions__c,
                                                Program_Version__r.Energy_System_Classification__c,
                                                Program_Version__r.Energy_System_Classification_Default__c,
                                                Program_Version__r.Primary_Supporting_Technologies__c,
                                                Program_Version__r.Primary_Supporting_Technology_Default__c,
                                                Program_Version__r.Size_of_Project_s__c, Program_Version__r.Panel_Manufacturer__c,
                                                Program_Version__r.Inverter_Manufacturer__c,
                                                End_User_Type__c,Regions__c, Signed_Date__c,
                                                Solicitation_Round__r.Due_Date__c, EnvelopeId__c,
                                                Solicitation_Round__r.Concept_Paper_Due_Date__c,
                                                (SELECT   FirstName__c, LastName__c, Address_1__c, Address_2__c, City__c, Zip__c, County__c, State__c, Tax_Identification_Type__c,
                                                          Email__c, Phone__c, Role__c, Primary_Customer_Contact__c, Company_Name__c, Title__c,
                                                          Company_TIN_Confirmation__c, Employee_Identification_Number_EIN__c, DUNS_Number__c, Alternate_Party__c,
                                                          Company_Type__c, Company_Website__c
                                                 FROM     Project_Roles__r
                                                 WHERE    Role__c IN :SET_ROLES_FOR_PROPOSAL_CONCEPT_PAPER_SUBMITTER
                                                 ORDER BY Role__c ASC, Primary_Customer_Contact__c DESC),

                                                 (SELECT  Site_Name__c, Address_1__c, Address_2__c, City__c, Zip__c, County__c, State__c,
                                                          Utility_Company__c, Electric_Utility_Account_Number__c, Is_Contributing_to_SBC__c
                                                  FROM    Project_Site__r),
                                                 (SELECT  Display_Label__c, Type__c, Proposal_Question_Answer__c, Sequence__c, Explanation_Required_On__c, Active__c,
                                                          Description__c, Question_Type__c, Date_Value__c
                                                  FROM    Project_Contents__r
                                                  WHERE   RecordTypeId =: proposalRecordTypeId Order by Sequence__c)
                                        FROM    Project__c
                                        WHERE   Id =: CORE_Helper.doEscapeSingleQuotes(projectId)];
        if(projectList.size() > 0) {
            project = projectList[0];
            projectRoleList = project.Project_Roles__r;

            for(Project_Role__c projectRoleRec : project.Project_Roles__r) {

                if(projectRoleRec.Alternate_Party__c) {
                    alternatePartyProjectRoleList.add(projectRoleRec);
                }

                if(projectRoleRec.Primary_Customer_Contact__c) {
                    primaryProjectRoleList.add(projectRoleRec);
                }

            }

            projectSiteList = project.Project_Site__r;
            for(Project_Content__c question : project.Project_Contents__r) {
                if(question.Type__c == 'Proposal Checklist Questions') {
                    checklistQuestionList.add(question);
                } else if(question.Type__c == 'Proposal Content Questions') {
                    contentQuestionList.add(question);
                } else if(question.Type__c == 'Proposal Disclosure Questions'){
                    disclosureQuestionList.add(question);
                }
            }
        }
    }
    
    @RemoteAction
    global static String getSiginingUrl(String projectId, String domainURL, String returnPageName, String pdfPageName){

        return CORE_APPINTAKE_Docusign_Service.getSiginingUrl(projectId, domainURL, returnPageName, pdfPageName);
    }

    @RemoteAction
    global static String getSignedDocument(String projectId){

        String attachmentId;

        for(Project_Document__c proDocument : [SELECT (SELECT Id FROM Attachments
                                               ORDER BY CreatedDate DESC limit 1)
                                               FROM Project_Document__c WHERE Project__c =: CORE_Helper.doEscapeSingleQuotes(projectId)
                                               AND Project_Content__r.Type__c =: CORE_Helper.TYPE_PROJECT_APP
                                               AND Project_Content__r.Sub_Type__c =: CORE_Helper.SUB_TYPE_CON_APP
                                               ORDER BY Version__c DESC limit 1]){

            for(Attachment attach : proDocument.Attachments){

                attachmentId = attach.Id;
            }
        }

        return attachmentId;
    }
    
    /**
    * Method Name: getApplicationReviewInfo
    * Description: Fetch Incentive Application Information for Review
    * @return Method does not return any value.
    */
    public void getApplicationReviewInfo() {
        
        System.debug('In getApplicationReviewInfo');
        if(String.valueOf(ApexPages.currentPage().getParameters()).contains('event')) {
          System.debug('In getParameters');
          String isSigned = ApexPages.currentPage().getParameters().get('event');
            if(project.Signed_Date__c == null && project.EnvelopeId__c != null && isSigned == 'signing_complete'){
                System.debug('In attachSignedDocument calling');
                CORE_APPINTAKE_Docusign_Service.attachSignedDocument(project.Id);
            }  
        }
    }
    
    /**
    * Method Name: checkSigningStatus
    * Description: To Check the status of Project
    * @return Method does not return any value.
    */
    public void checkSigningStatus(){
        for(Project__c pro : [SELECT Id, Concept_Paper__c, Proposal__c,
                              Solicitation_Round__r.Concept_Paper_Due_Date__c,
                              Solicitation_Round__c, Program_Version__c, Signed_Date__c,
                              Solicitation_Round__r.Due_Date__c, Status__c,
                              Program_Version__r.Program__r.Name, Program_Version__r.Name,
                              Program_Version__r.NY_Green_Bank_RFP__c, EnvelopeId__c,
                              Program_Version__r.Required_Site_on_Concept_Paper__c,
                              Program_Version__r.Required_Site_on_Proposal__c,
                              Program_Version__r.Solicitation_Type__c,
                              Statement__c, Application_Number__c,TermsCondition__c
                              FROM Project__c
                              WHERE Id =: CORE_Helper.doEscapeSingleQuotes(projectId)]){
            project = pro;
        }
    }

    /*
    * Method Name: saveAndNext
    * Description: Update project
    * @param:  none
    * @return: PageReference
    */
    public PageReference saveAndNext() {
        if(project.Id != null) {
            if((!checkForDueDate() && !isRollingSolicitationLockDown) || isExceptionalAccessProvided) { // T-02655
              update project;
            }
        }
        return next();
    }
}