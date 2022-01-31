/*
*   Class Name: SolicitationRound_TriggerHandler
*   Description: Handler class for SolicitationRound_Trigger trigger
*
*   Date           New/Modified    User          Identifier                    Description
*   08/04/2017     New             Ajay Gautam                                 T-02833: Due Date 5 PM automation
*/

public with sharing class SolicitationRound_TriggerHandler {

    /*
    * Method Name: beforeInsert
    * Description: calling this method after update trigger event
    * @param: List<Solicitation_Round__c> newList
    * @return void
    */
    public static void beforeInsert(List<Solicitation_Round__c> newList) {
      setDueDatesTo5PM(newList, null);
    }


    /*
    * Method Name: beforeUpdate
    * Description: calling this method after update trigger event
    * @param: List<Solicitation_Round__c> newList
    * @param: Map<Id,Solicitation_Round__c> oldMap
    * @return void
    */
    public static void beforeUpdate(List<Solicitation_Round__c> newList, Map<Id, Solicitation_Round__c> oldMap) {
      setDueDatesTo5PM(newList,oldMap);
    }


    /* Method Name: setDueDatesTo5PM
    *  Description: T-02833: Due Date 5 PM automation
    *  @param: list<Solicitation_Round__c> newList
    *  @param: Map<Id, Solicitation_Round__c> oldMap
    *  @return: void
    */
    public static void setDueDatesTo5PM(List<Solicitation_Round__c> solicitationRoundList, Map<Id, Solicitation_Round__c> oldMap) {
      Datetime dtForTiming = null;
      Date dateForTiming = null;
      Time timeForTiming = null;

      Integer iValueForHH = Solicitation_Helper.CONST_ROUND_DUE_TIME_HH; // Get the HH values

      if(iValueForHH != null && iValueForHH > 0) {
        for(Solicitation_Round__c objRound : solicitationRoundList) {
          // Concept Paper
          if(objRound.Concept_Paper_Due_Date__c != null &&
               (oldMap == null || (oldMap != null && objRound.Concept_Paper_Due_Date__c  != oldMap.get(objRound.Id).Concept_Paper_Due_Date__c))) {
            dtForTiming = objRound.Concept_Paper_Due_Date__c;
            dateForTiming = dtForTiming.date();
            objRound.Concept_Paper_Due_Date__c = DateTime.newInstance(dateForTiming, Time.newInstance(iValueForHH, 00, 00, 00));
          }
          // Proposal Paper
          if(objRound.Due_Date__c != null &&
               (oldMap == null || (oldMap != null && objRound.Due_Date__c  != oldMap.get(objRound.Id).Due_Date__c))) {
            dtForTiming = objRound.Due_Date__c;
            dateForTiming = dtForTiming.date();
            objRound.Due_Date__c = DateTime.newInstance(dateForTiming, Time.newInstance(iValueForHH, 00, 00, 00));
          }
        }
      }

    }



}//EOF