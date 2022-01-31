/*
* Class Name: PROPOSAL_CORE_Site_Controller
* Description: Controller to handle the functionalities of  PROPOSAL_CORE_Site_Page
* Author/Date: Tarun Khandelwal   1/14/2017
*
* Date         New/Modified      Author             Description
* 4/21/2017      Modified      Ajay Gautam         --------------
*
*/

public with sharing class PROPOSAL_CORE_Site_Controller extends ProposalBase_Controller{

    public List<Project_Site__c> projectSiteList {get; set;}
    public Project_Site__c site {get; set;}
    public String selectedProjectSiteId {get; set;}
    public Boolean isSiteRequired {get; set;}

    public PROPOSAL_CORE_Site_Controller() {
        //super();
        projectSiteList = new List<Project_Site__c>();
        getProjectSiteList();
        isSiteRequired = false;

        if((project.Program_Version__r.Required_Site_on_Concept_Paper__c && project.Concept_Paper__c) ||
            (project.Program_Version__r.Required_Site_on_Proposal__c && project.Proposal__c)) {
                isSiteRequired = true;
        }
    }

    /*
    * Method Name: getProjectSiteList
    * Description: get the list of project site
    * @param:  none
    * @return: void
    */

    private void getProjectSiteList() {
        String query = 'SELECT ';
        for(String fieldName : getProjectSiteFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Project_Site__c WHERE Project__c = \'' + CORE_Helper.doEscapeSingleQuotes(projectId) + '\' ORDER BY CreatedDate ASC';

        projectSiteList = Database.query(query);
    }


    /*
    * Method Name: getProjectSite
    * Description: get the project site
    * @param:  none
    * @return: void
    */

    public void getProjectSite() {
        String query = 'SELECT ';
        for(String fieldName : getProjectSiteFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Project_Site__c WHERE Id = \'' + CORE_Helper.doEscapeSingleQuotes(selectedProjectSiteId) + '\' ORDER BY CreatedDate ASC';

        site = Database.query(query);
    }


    /*
    * Method Name: resetProjectSite
    * Description: reset project site
    * @param:  none
    * @return: void
    */

    public void resetProjectSite() {
        site = new Project_Site__c();
        site.State__c = 'New York';
    }


    /*
    * Method Name: deleteProjectSite
    * Description: delete selected project sites
    * @param:  none
    * @return: Pagereference
    */

    public Pagereference deleteProjectSite() {
        if(selectedProjectSiteId != null) {
            Project_Site__c projectSiteRec = new Project_Site__c(Id = selectedProjectSiteId);
            delete projectSiteRec;
        }
        return getCurrentPageReference();
    }

    /*
    * Method Name: saveProjectSite
    * Description: save and update selected project sites
    * @param:  none
    * @return: Pagereference
    */

    public PageReference saveProjectSite() {
        RecordType recType = null;
        Id siteRecordTypeId = null;
        String projRecordTypeDevName = '';

        if(projectId != null) {
          for(Project__c obj : [SELECT  recordType.developerName
                                FROM    Project__c
                                WHERE   Id = :projectId]) {
            projRecordTypeDevName = obj.recordType.developerName;
          }

          if(String.isNotBlank(projRecordTypeDevName)) {
            recType = Utility_RecordType_Helper.getRecordType('Project_Site__c',projRecordTypeDevName);
          } //else {
           // recType = Utility_RecordType_Helper.getRecordType('Project_Site__c',Clean_Transportation_Helper.SOLICITATION_SUBMISSION_PROJECT_RECORD_TYPE_DEVELOPER_NAME);
          //}

          if(recType != null && recType.Id != null) {
            siteRecordTypeId = recType.Id;
          }
        }

        if(String.isBlank(site.Project__c)) {
            site.Project__c = projectId;
            if(siteRecordTypeId != null) {
              site.RecordTypeId = siteRecordTypeId;
            }
        }
        upsert site;
        return getCurrentPageReference();
    }


    /*
    * Method Name: getCurrentPageReference
    * Description: save selected project sites
    * @param:  none
    * @return: Pagereference
    */
    private PageReference getCurrentPageReference() {
        Pagereference pg = new Pagereference('/apex/PROPOSAL_CORE_Site_Page?ProjectId=' + projectId);
        pg.setRedirect(true);
        return pg;
    }

    private List<String> getProjectSiteFieldList(){
        List<String> fieldList = new List<String>{  'Id',
                                                    'Site_Name__c',
                                                    'Address_1__c',
                                                    'Address_2__c',
                                                    'City__c',
                                                    'Zip__c',
                                                    'County__c',
                                                    'State__c',
                                                    'NYISO_Zone__c',
                                                    'Utility_Company__c',
                                                    'Project__c',
                                                    'Electric_Utility_Account_Number__c',
                                                    'Regional_Economic_Development_Council__c',
                                                    'Is_Contributing_to_SBC__c',
                                                    'Gas_Utility_Company__c',
                                                    'Gas_Utility_Account_Number__c',
                                                    'RecordTypeId'
                                                };
        return fieldList;
    }
}