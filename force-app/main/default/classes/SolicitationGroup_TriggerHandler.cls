/*
*   Class Name: SolicitationGroup_TriggerHandler
*   Description: Class used as helper for SolicitationGroup trigger
*
*   Author/Date: 
*                                                          
*/
public with sharing class SolicitationGroup_TriggerHandler {
  
  /*
  * Method Name: afterInsertEvent
  * Description: calling this method after insertion of Event.       
  * @param: List<Solicitation_Group__c> newList
  * @return: void                                                      
  */
  public static void afterInsertEvent(List<Solicitation_Group__c> newList) {
    Set<Id> solicitationRoundIdSet = new Set<Id>();
    for(Solicitation_Group__c solicitationGroup : newList) {
      solicitationRoundIdSet.add(solicitationGroup.Solicitation_Round__c);
    }
    solicitationRoundIdSet.remove(null);
    
    // Find Solicitation Manager from Solicitation and Prepare Map
    List<Solicitation_Round__c> solicitationRoundList = [select Solicitation__c, Solicitation__r.Solicitation_Manager__c from Solicitation_Round__c 
                                  where Id IN: solicitationRoundIdSet];
    Map<Id, Id> solicitationIdToSolicitationManagerIdMap = new Map<Id, Id>();
    Map<Id, Solicitation_Round__c> solicitationRoundIdToSolicitationRoundRecMap = new Map<Id, Solicitation_Round__c>();
    for(Solicitation_Round__c roundRec : solicitationRoundList) {
      if(!solicitationIdToSolicitationManagerIdMap.containsKey(roundRec.Solicitation__c) && roundRec.Solicitation__r.Solicitation_Manager__c != null) {
        solicitationIdToSolicitationManagerIdMap.put(roundRec.Solicitation__c, roundRec.Solicitation__r.Solicitation_Manager__c);
      }
      solicitationRoundIdToSolicitationRoundRecMap.put(roundRec.Id, roundRec);
    }
    
    // If there is no Solicitation Manager, there is no need to insert anything
    if(solicitationIdToSolicitationManagerIdMap.size() == 0) {
      return;
    }
    
    // To check wheather the solicitation Manager lies in Solicitation Review Team or Not.
    List<Solicitation_Review_Team__c> reviewTeamList = [select Solicitation__c from Solicitation_Review_Team__c 
                                where Solicitation__c IN: solicitationIdToSolicitationManagerIdMap.keySet()
                                    AND Member__c IN: solicitationIdToSolicitationManagerIdMap.values()
                                    AND Scoring_Committee__c = true];
    
    Map<Id, Solicitation_Review_Team__c> solicitationIdToManagerReviewTeamIdMap = new Map<Id, Solicitation_Review_Team__c>();
    for(Solicitation_Review_Team__c reviewTeam : reviewTeamList) {
      if(solicitationIdToSolicitationManagerIdMap.containsKey(reviewTeam.Solicitation__c)) {
        solicitationIdToManagerReviewTeamIdMap.put(reviewTeam.Solicitation__c, reviewTeam);
      }
    }
    
    // Check for Solicitation Manager - If not in Review Team then insert this
    List<Solicitation_Review_Team__c> managerReviewTeamListToInsert = new List<Solicitation_Review_Team__c>();
    for(Solicitation_Group__c solicitationGroup : newList) {
      if( solicitationRoundIdToSolicitationRoundRecMap.containsKey(solicitationGroup.Solicitation_Round__c) &&
        !solicitationIdToManagerReviewTeamIdMap.containsKey(solicitationRoundIdToSolicitationRoundRecMap.get(solicitationGroup.Solicitation_Round__c).Solicitation__c) &&
        solicitationRoundIdToSolicitationRoundRecMap.get(solicitationGroup.Solicitation_Round__c).Solicitation__r.Solicitation_Manager__c != null) {
          Solicitation_Review_Team__c managerReviewTeamRec = new Solicitation_Review_Team__c();
          managerReviewTeamRec.Solicitation__c = solicitationRoundIdToSolicitationRoundRecMap.get(solicitationGroup.Solicitation_Round__c).Solicitation__c;
          managerReviewTeamRec.Member__c = solicitationRoundIdToSolicitationRoundRecMap.get(solicitationGroup.Solicitation_Round__c).Solicitation__r.Solicitation_Manager__c;
          managerReviewTeamRec.Scoring_Committee__c = true;
          managerReviewTeamListToInsert.add(managerReviewTeamRec);
          solicitationIdToManagerReviewTeamIdMap.put(solicitationRoundIdToSolicitationRoundRecMap.get(solicitationGroup.Solicitation_Round__c).Solicitation__c, managerReviewTeamRec);
        }
    }
    if(managerReviewTeamListToInsert.size() > 0) {
      insert managerReviewTeamListToInsert;
    }
    
    
    // If Solicitation Manager exists in Solicitation Review Team, Insert Manager as a Solicitation Group Member
    List<Solicitation_Group_Member__c> groupMemberListToInsert = new List<Solicitation_Group_Member__c>();
    for(Solicitation_Group__c solicitationGroup : newList) {
      
      if( solicitationRoundIdToSolicitationRoundRecMap.containsKey(solicitationGroup.Solicitation_Round__c) &&
        solicitationIdToManagerReviewTeamIdMap.containsKey(solicitationRoundIdToSolicitationRoundRecMap.get(solicitationGroup.Solicitation_Round__c).Solicitation__c)) {
        
        Solicitation_Group_Member__c groupMemberToInsert = new Solicitation_Group_Member__c();
        groupMemberToInsert.Solicitation_Group__c = solicitationGroup.Id;
        groupMemberToInsert.Is_Solicitation_Manager__c = true;
        groupMemberToInsert.Solicitation_Review_Team__c = 
                  solicitationIdToManagerReviewTeamIdMap.get(solicitationRoundIdToSolicitationRoundRecMap.get(solicitationGroup.Solicitation_Round__c).Solicitation__c).Id;
        groupMemberListToInsert.add(groupMemberToInsert);
      }
    }
    
    if(groupMemberListToInsert.size() > 0) {
      insert groupMemberListToInsert;
    }
  }
}