/*
*   Class Name: Utility_CopyProposalQuestions
*   Description: Purpose to copy proposal question toprogram content
*
*   Author/Date: Harshit Jain/February 20, 2017
*                        
*/
public with sharing class Utility_CopyProposalQuestions {

  /*
  * Method Name: copyProposalQuesToProgramContent
  * Description: copy proposal question to program content list on the basis of solicitationIds
  * @param:  String objMapperName
  * @param:  Set<Id> solicitationIds
  * @return: void                                                       
  */
    public static void copyProposalQuesToProgramContent(Set<Id> solicitationIds) {

        List<Program_Content__c> programContentList = new List<Program_Content__c>();

        Id proposalRecordTypeId = Utility_RecordType_Helper.getRecordType('Program_Content__c',ProgramContent_Helper.PROPOSAL_RECORDTYPE).Id;

        Program_Content__c programContent;
        
        List<Proposal_Question__mdt> proposalQuestionLst =[SELECT Active__c,Display_Label__c,
                                                                  Explanation_Required_On__c,Question_Type__c,Sequence__c,Type__c,Help_Text__c
                                                             FROM Proposal_Question__mdt] ; 
                                                             
        for(Id solicitationId : solicitationIds){
            for(Proposal_Question__mdt proposalQuestion : proposalQuestionLst) {
                programContent = new Program_Content__c();
                programContent.recordTypeId = proposalRecordTypeId;
                programContent.Program_Version__c = solicitationId;
                programContent.Active__c =  proposalQuestion.Active__c;
                programContent.Display_Label__c = proposalQuestion.Display_Label__c;
                programContent.Type__c = proposalQuestion.Type__c;
                programContent.Sequence__c = proposalQuestion.Sequence__c;
                programContent.Question_Type__c = proposalQuestion.Question_Type__c;
                programContent.Explanation_Required_On__c = proposalQuestion.Explanation_Required_On__c;
                programContent.Help_Text__c= proposalQuestion.Help_Text__c;
                programContentList.add(programContent);
            }
        }
 
        if(programContentList.size() > 0){
            insert programContentList;
        }

    }
}