/*
* Class Name:  CORE_Proposal_Review_Landing_Controller
* Description: Extension class for CORE_Proposal_Review_Landing_Page
* Author/Date: Tarun Khandelwal ,  4/11/2017
*
*/

public with sharing class CORE_Proposal_Review_Landing_Controller {

    public String solicitationId {get; set;}
    public List<SolicitationWrapper> solicitationWrapperList {get; set;}

    public CORE_Proposal_Review_Landing_Controller() {
        solicitationId = ApexPages.currentPage().getParameters().get('SolicitationId');
        solicitationWrapperList = new List<SolicitationWrapper>();

        List<Solicitation_Review_Team__c> reviewTeamList = [select Solicitation__c
                                    from Solicitation_Review_Team__c
                                                             where Member__c =: UserInfo.getUserId()];
        Set<Id> solicitationIdSet = new Set<Id>();
        for(Solicitation_Review_Team__c reviewTeamRec : reviewTeamList) {
            solicitationIdSet.add(reviewTeamRec.Solicitation__c);
        }

        List<Program_Version__c> solicitaionList = [select Name,
                                  (select Id, Name from Solicitation__r where Status__c = 'Open' OR Status__c = 'Closed')
                               from Program_Version__c
                                                    where (Status__c =: Solicitation_Helper.TYPE_OPEN OR Status__c =: Solicitation_Helper.TYPE_CLOSED)
                                                    AND Id IN : solicitationIdSet];

        for(Program_Version__c solicitaionRec : solicitaionList) {
            for(Solicitation_Round__c objRound : solicitaionRec.Solicitation__r) {
              solicitationWrapperList.add(new SolicitationWrapper(solicitaionRec, new List<Solicitation_Round__c>{objRound}));
            }
        }
    }


    public class SolicitationWrapper {
        public String solicitationName {get; set;}
        public String roundName {get; set;}
        public Id roundId {get; set;}
        public Id solicitationId {get; set;}

        public SolicitationWrapper(Program_Version__c solicitaionRec, List<Solicitation_Round__c> roundList) {
            this.solicitationName = solicitaionRec.Name;
            this.roundName = (roundList.size() > 0) ? roundList[0].Name : '';
            this.roundId = (roundList.size() > 0) ? roundList[0].Id : '';
            this.solicitationId = solicitaionRec.Id;
        }
    }
}