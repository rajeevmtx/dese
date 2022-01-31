/**
 * @author Vishnu Kumar
 * @email vishnu.kumar@mtxb2b.com
 * @desc This class fetches the conversation records.
*/
public with sharing class DC_ConversationsController {
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method fetches the conversation records.
    */
    @AuraEnabled
    public static List<Conversation__c> getConversations(String recId){
        Subject__c subject = [select id,Primary_Cell_Number__c,consent__c from Subject__c Where id =: recId ];
        //Fetch Conversation records based on the phone number and subject id
        if(subject.consent__c !='NO'){
            List<Conversation__c> conversationList = [SELECT Id, Is_User_Replied__c, Message__c, Message_Sequence__c, 
                                                  Type__c, CreatedDate , Is_Message_Sent__c 
                                                  FROM Conversation__c 
                                                  WHERE From__c = :subject.Primary_Cell_Number__c OR
                                                  Subject__c =: subject.Id
                                                  ORDER BY CreatedDate desc , Random_Increment_Number__c desc];
                                                  return conversationList;
        }
        return null;
    }

}