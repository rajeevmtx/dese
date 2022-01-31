/**
 * @author Shubham Dadhich
 * @email shubham.dadhich@mtxb2b.com
 * @desc This batch class send the follow message to the users.
*/
global class DC_SendFollowUpMessagesBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts, Database.Stateful {
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc QueryLocator method for batch class to do a query on existing data.
    */
    global Database.QueryLocator start(Database.BatchableContext context) {
        Date days_out = Date.today();
        Integer maxFollowUp = Integer.valueOf(Label.DC_Total_Follow_Up_Limit);
        
        //Query all the subjects if
        //1. Disposition is Monitoring
        //2. User Consent is Yes
        //3. Today's date is between Departure_Date and Monitoring_End_Date
        //4. Follow Up Count is less than Max follow up count
        String query = 'SELECT Id,Name,Follow_Up_Count__c,Consent__c,Disposition__c,Departure_Date__c,Monitoring_End_Date__c,Primary_Cell_Number__c '+
            ' FROM Subject__c '+
            ' WHERE Departure_Date__c <=:days_out AND Monitoring_End_Date__c >=:days_out '+
            ' AND Disposition__c = \'Monitoring\' AND Consent__c = \'Yes\' '+
            ' AND Follow_Up_Count__c < : maxFollowUp';
        
        return Database.getQueryLocator(query);
    }   
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc Logic Execute method, logic writern for sending daily outbound messages.
    */
    global void execute(Database.BatchableContext context, List<Subject__c> subjects) {
        System.debug('List of subjects ='+subjects);
        List<Conversation__c> newOutboundConversation = new List<Conversation__c>();
        
        //Fetch Step 2: Follow Up message template
        DC_Daily_Message__mdt dailyMessage = [SELECT Message__c, Sequence__c FROM DC_Daily_Message__mdt Where Sequence__c = 2];
        
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
                sub.Follow_Up_Count__c = (sub.Follow_Up_Count__c!=null) ? sub.Follow_Up_Count__c+1 : 1;
                if( sub.Follow_Up_Count__c == Integer.valueOf(Label.DC_Total_Follow_Up_Limit) ){
                   sub.Engaged__c = false; 
                }
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
     * @desc Execute method to run bacth on scheduled call.
    */
    global void execute(SchedulableContext SC) {
        executeBatchJob();
    }
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method execute batch run with 5 records per batch.
    */
    public static void executeBatchJob(){
        Database.executebatch(new DC_SendFollowUpMessagesBatch(), 5);
    }
}