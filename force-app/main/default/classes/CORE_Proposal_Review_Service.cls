/*
* Class Name:  CORE_Proposal_Review_Service
* Description: service Class which returns list of review team members
*
*/

public without sharing class CORE_Proposal_Review_Service {

   /*
    * Method Name: getReviewTeamMembers
    * Description: Method to fetch List<Solicitation_Review_Team__c>
    * @param: String solicitationId
    * @return: List<Solicitation_Review_Team__c>
    */
    public static List<Solicitation_Review_Team__c> getReviewTeamMembers(String solicitationId) {
      return [SELECT Id, Member__c, Member__r.Name,
                     Scoring_Committee__c, Solicitation__c
                  From Solicitation_Review_Team__c
                 WHERE Solicitation__c =: solicitationId
                   AND Scoring_Committee__c = true
                   AND Member__c != null
                  ];
    }

   /*
    * Method Name: getReviewTeamGroupMembers
    * Description: Method to fetch List<Solicitation_Group_Member__c>
    * @param: String solicitationGroupId
    * @return: List<Solicitation_Group_Member__c>
    */
    public static List<Solicitation_Group_Member__c> getReviewTeamGroupMembers(String solicitationGroupId) {
      return [SELECT  Solicitation_Review_Team__r.Member__c, Solicitation_Review_Team__r.Member__r.ContactId,
                      Solicitation_Review_Team__c, Solicitation_Group__c, Solicitation_Review_Team__r.Member__r.Name
              FROM    Solicitation_Group_Member__c
              WHERE   Solicitation_Group__c = :solicitationGroupId
              AND     Solicitation_Review_Team__r.Member__c != null];
    }

}