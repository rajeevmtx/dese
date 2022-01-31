/*
*   Class Name: PROPOSAL_CORE_Listing_Controller
*   Description: class for PROPOSAL_CORE_Listing_Page
*   Author/Date: Harshit Jain/ 1/11/2017
*                                                        
*/
public without sharing class PROPOSAL_CORE_Listing_Controller {

    /*public final String ERROR_MESSAGE = 'There are no programs available for your Account.';
    public final String NY_SUN_RESIDENTIAL_TYPE = 'NY_Sun_Residential';
    public final String NY_SUN_COMMERCIAL_TYPE = 'NY_Sun_Commercial';
    public final String RTEM_TYPE = 'Commercial_Real_Time_Energy_Management';
    public final String PELLET_STOVE_TYPE = 'RHNY_Pellet_Stove';
    public final String ZEV_TYPE = 'Zero_Emission_Vehicles';
    public final String CHP_TYPE = 'Onsite_Power_Combined_Heat_and_Power';
    public final String CTenant_TYPE = 'Commercial_Tenant';*/

    public List<ProgramVersionDetail> programVersionList {get;set;}

    public PROPOSAL_CORE_Listing_Controller() {
        programVersionList = new List<ProgramVersionDetail>();
        List<Program_Version__c> programVersions = [Select Id, Concept_Paper__c, Concept_Paper_Pass_Score__c, Name, Description__c,Short_Description__c,
                                                            NY_Green_Bank_RFP__c,
                                                            (select Due_Date__c, Concept_Paper_Due_Date__c
                                                               from Solicitation__r where Status__c = 'Open'
                                                           order by CreatedDate DESC limit 1)
                                                      From Program_Version__c
                                                     //Where Status__c =: Solicitation_Helper.TYPE_OPEN
                                                        //AND RecordType.DeveloperName =: Solicitation_Helper.RECORD_TYPE_CLEAN_TRANSPORTAION
                                                  order by CreatedDate ASC];

        Set<Id> solicitationRoundIdSet = new Set<Id>();
        for(Program_Version__c progremVersionRec : programVersions) {
            if(progremVersionRec.Solicitation__r.size() > 0) {
                solicitationRoundIdSet.add(progremVersionRec.Solicitation__r[0].Id);
            }
        }
		system.debug('solicitationRoundIdSet:'+solicitationRoundIdSet);
        System.debug('programVersions'+programVersions);
        Map<Id, DateTime> solicitationRoundIdToDueDateMap = populateSolicitationRoundIdToDueDateMap(solicitationRoundIdSet);

        for(Program_Version__c progremVersionRec : programVersions) {
            /*
            if( progremVersionRec.Solicitation__r.size() > 0 && solicitationRoundIdToDueDateMap.containsKey(progremVersionRec.Solicitation__r[0].Id)
                && solicitationRoundIdToDueDateMap.get(progremVersionRec.Solicitation__r[0].Id) >= system.now()) {
                    programVersionList.add(new ProgramVersionDetail(progremVersionRec, solicitationRoundIdToDueDateMap.get(progremVersionRec.Solicitation__r[0].Id)));

            } else if(progremVersionRec.Concept_Paper__c &&  progremVersionRec.Solicitation__r.size() > 0
                    && progremVersionRec.Solicitation__r[0].Concept_Paper_Due_Date__c >= system.now()) {
                programVersionList.add(new ProgramVersionDetail(progremVersionRec, progremVersionRec.Solicitation__r[0].Concept_Paper_Due_Date__c));
            } else if(!progremVersionRec.Concept_Paper__c && progremVersionRec.Solicitation__r.size() > 0
                        && progremVersionRec.Solicitation__r[0].Due_Date__c >= system.now()) {
                programVersionList.add(new ProgramVersionDetail(progremVersionRec, progremVersionRec.Solicitation__r[0].Due_Date__c));
            }*/
            System.debug('progremVersionRec.Solicitation__r.size()'+progremVersionRec.Solicitation__r.size());
            if(progremVersionRec.Solicitation__r.size() > 0) {
                 if(progremVersionRec.Solicitation__r[0].Concept_Paper_Due_Date__c != null && progremVersionRec.Solicitation__r[0].Concept_Paper_Due_Date__c >= system.now()) {
                    programVersionList.add(new ProgramVersionDetail(progremVersionRec, progremVersionRec.Solicitation__r[0].Concept_Paper_Due_Date__c));
                 } else if(progremVersionRec.Solicitation__r[0].Due_Date__c != null && progremVersionRec.Solicitation__r[0].Due_Date__c >= system.now()) {
                    programVersionList.add(new ProgramVersionDetail(progremVersionRec, progremVersionRec.Solicitation__r[0].Due_Date__c));
                 } 
            }
            System.debug('programVersions22'+programVersionList);
        }
    }

      /*
      * Method Name: populateSolicitationRoundIdToDueDateMap
      * Description: Populate soliciatation round id to due date map
      * @param: Set<Id> solicitationRoundIdSet
      * @return: Map<Id, DateTime>                                                      
      */ 
        
    private Map<Id, DateTime> populateSolicitationRoundIdToDueDateMap(Set<Id> solicitationRoundIdSet) {
        Map<Id, DateTime> solicitationRoundIdToDueDateMap = new Map<Id, DateTime>();
        List<Solicitation_Round__c> solicitationRoundList = [select Id, Solicitation__r.Concept_Paper__c, Due_Date__c, Concept_Paper_Due_Date__c,
                                                                (select Status__c from Projects__r where Concept_Paper__c = true) from Solicitation_Round__c
                                                                where Id IN: solicitationRoundIdSet];

        for(Solicitation_Round__c soliciationRoundRec : solicitationRoundList) {
            if(soliciationRoundRec.Solicitation__r.Concept_Paper__c && soliciationRoundRec.Projects__r.size() > 0
                    && soliciationRoundRec.Projects__r[0].Status__c != 'Unsubmitted') {
                solicitationRoundIdToDueDateMap.put(soliciationRoundRec.Id, soliciationRoundRec.Due_Date__c);
            } else if(soliciationRoundRec.Solicitation__r.Concept_Paper__c) {
                solicitationRoundIdToDueDateMap.put(soliciationRoundRec.Id, soliciationRoundRec.Concept_Paper_Due_Date__c);

            } else if(!soliciationRoundRec.Solicitation__r.Concept_Paper__c) {
                solicitationRoundIdToDueDateMap.put(soliciationRoundRec.Id, soliciationRoundRec.Due_Date__c);
            }
        }

        return solicitationRoundIdToDueDateMap;
    }

    public class ProgramVersionDetail {
        public Program_Version__c programVersionRec {get; set;}
        public String dueDate {get; set;}

        public ProgramVersionDetail(Program_Version__c programVersionRec, DateTime dueDate) {
            this.programVersionRec = programVersionRec;
            this.dueDate = dueDate.format('MM/dd/yyyy hh:mm a');
        }
    }

    public PageReference urlRedirection() {

        string url = 'https://desedemo-demo-lp.cs196.force.com/dese/s/';

        PageReference page = new PageReference(url);
        page.setRedirect(true);
        return page;
  }
}