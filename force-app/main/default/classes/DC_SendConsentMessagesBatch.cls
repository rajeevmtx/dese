/**
 * @author Vishnu Kumar
 * @email vishnu.kumar@mtxb2b.com
 * @desc This batch class send the consent message to the users.
*/
global class DC_SendConsentMessagesBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc QueryLocator method for batch class to do a query on existing data.
    */
    global Database.QueryLocator start(Database.BatchableContext context) {
        Date days_out = Date.today();        
        //Query all the subjects if
        //1. Disposition is Monitoring
        //2. User Consent is Pending or blank
        //3. Today's date is between Departure_Date and Monitoring_End_Date
        String query = 'SELECT Id,Consent__c,Disposition__c,Departure_Date__c,Monitoring_End_Date__c,Primary_Cell_Number__c '+
            ' FROM Subject__c '+
            ' WHERE Departure_Date__c <=:days_out AND Monitoring_End_Date__c >=:days_out '+
            ' AND Disposition__c = \'Monitoring\' AND ( Consent__c = \'Pending\' OR Consent__c = null) ';
        
        return Database.getQueryLocator(query);
    }   
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc Logic Execute method, logic writern for sending daily outbound messages.
    */
    global void execute(Database.BatchableContext context, List<Subject__c> subjects) {
        List<Conversation__c> newOutboundConversation = new List<Conversation__c>();
        
        //Fetch Step 2: Follow Up message template
        DC_Daily_Message__mdt dailyMessage = [SELECT Message__c, Sequence__c FROM DC_Daily_Message__mdt Where Sequence__c = 1];
       
        for(Subject__c sub : subjects){
            //Send Message
            TwilioSF.TwilioApiClientResponse response = DC_SendOutboundMessageController.sendTwilioMessage(sub.Primary_Cell_Number__c, dailyMessage.Message__c );

            //Handle Response
            if( response.getHtttpStatusCode() == 200 || response.getHtttpStatusCode() == 201 ){
                Conversation__c newConvo = new Conversation__c(); 
                newConvo.Message__c = dailyMessage.Message__c;
                newConvo.Subject__c = sub.Id;
                newConvo.From__C = sub.Primary_Cell_Number__c;
                newConvo.Type__c = 'Outbound';
                newConvo.Message_Sequence__c = dailyMessage.Sequence__c;
                newConvo.Is_Message_Sent__c = true;
                newOutboundConversation.add( newConvo );
                
                //Update subject record fields
                sub.Consent__c = 'Pending';
            }
        }
        
        //Update Subjects
        update subjects;
        
        //Insert outbound messages
        if( !newOutboundConversation.isEmpty() ){
            insert newOutboundConversation;
        }
    }

    global void finish(Database.BatchableContext context) {}
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method execute batch run with 5 records per batch.
    */
    public static void executeBatchJob(){
        Database.executebatch(new DC_SendConsentMessagesBatch(), 5);
    }
}