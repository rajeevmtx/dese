/*
* Class Name: PROPOSAL_CORE_Budget_Controller
* Description: Controller to handle the functionalities of PROPOSAL_CORE_Budget_Page
* Author/Date:  Tarun Khandelwal ,  1/14/2017
*
* Date         New/Modified      Author             Description
* 5/7/2017     Modified          Harshit Jain       T-02333
* 5/19/2017    Modified         Harshit Jain        Lockdown porposal updation for rolling solictation after submission
* 06/30/2017   Modified          Ajay Gautam        T-02655 - Add exception for paper submission process
*
*/

public with sharing class PROPOSAL_CORE_Budget_Controller extends ProposalBase_Controller{

    public Project__c projectRec {get; set;}
    public Boolean isNextClicked {get; set;}

    public PROPOSAL_CORE_Budget_Controller() {
        getProjectInfo();
    }

    /*
    * Method Name: getProjectInfo
    * Description: get all the fields of Project object
    * @param: none
    * @return: void
    */

    private void getProjectInfo() {
        List<Project__c> projectList = [select Proposed_NYSERDA_Cost__c, Propsoed_Cost_Share__c, Proposed_Total_Cost__c,
                                               Concept_Paper__c, Solicitation_Round__r.Concept_Paper_Due_Date__c, Solicitation_Round__r.Due_Date__c,
                                               Program_Version__c, Program_Version__r.Proposed_Cost_Share_Required__c,
                                               Program_Version__r.NY_Green_Bank_RFP__c
                                          FROM Project__c
                                         WHERE Id =: CORE_Helper.doEscapeSingleQuotes(projectId)];
        if(projectList.size() > 0) {
            projectRec = projectList[0];
        } else {
            projectRec = new Project__c();
        }
    }

    /*
    * Method Name: saveBudgetInfo
    * Description: method to update the project record
    * @param: none
    * @return: PageReference
    */

    public PageReference saveBudgetInfo() {
        if((checkForDueDate() || isRollingSolicitationLockDown) && !isExceptionalAccessProvided) {
            isDueDatePassed = true;
            getProjectInfo();
        } else {
            if(projectRec.Id != null) {
                update projectRec;
            }
        }

        PageReference pg;
        if(isNextClicked) {
            pg = next();
        } else {
            pg = null;
        }
        return pg;
    }
}