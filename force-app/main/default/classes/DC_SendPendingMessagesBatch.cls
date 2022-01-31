/**
 * @author Vishnu Kumar
 * @email vishnu.kumar@mtxb2b.com
 * @desc This batch class query outbond pending message and send them.
*/
global class DC_SendPendingMessagesBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts {
	
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method query all outbound Conversation records which are not sent yet to twilio.
    */
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id,From__c, Message__c,Is_Message_Sent__c FROM Conversation__c Where Is_Message_Sent__c = false AND Type__c = \'Outbound\' ';
        return Database.getQueryLocator(query);
    }  
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method get called to process the data and send the message.
    */
    global void execute(Database.BatchableContext context, List<Conversation__c> conversations) {
        for( Conversation__c conv : conversations ){
            //Send Message
            TwilioSF.TwilioApiClientResponse response = DC_SendOutboundMessageController.sendTwilioMessage(conv.From__c, conv.Message__c );
            
            //Handle Response and update message to sent as true
            if( response.getHtttpStatusCode() == 200 || response.getHtttpStatusCode() == 201 ){
                conv.Is_Message_Sent__c = true;
            }
        }
        
        update conversations;
    }
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method get called after all the batch get processed and it schedule the batch in next 5 minutes.
    */
    global void finish(Database.BatchableContext context) {
        //batchable, jobName, minutesFromNow, scopeSize
        System.scheduleBatch(new DC_SendPendingMessagesBatch(), 'DC_SendPendingMessagesBatchSchedule', 1, 5);
    }


    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method schedule the batch class with 5 records per batch.
    */
    global void execute(SchedulableContext SC) {
        Database.executebatch(new DC_SendPendingMessagesBatch(), 5);
    }
}