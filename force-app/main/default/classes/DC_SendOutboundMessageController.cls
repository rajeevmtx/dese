/**
 * @author Vishnu Kumar
 * @email vishnu.kumar@mtxb2b.com
 * @desc This class provide methods to send the outbound twilio messages.
*/
public class DC_SendOutboundMessageController {
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method send the Request Consent outbound twilio messages.
    */
    @AuraEnabled
    public static void requestConsent(Id subjectId){
        //Fetch Subject Record
        Subject__c sub = [SELECT Id, Primary_Cell_Number__c,Disposition__c,Departure_Date__c,Monitoring_End_Date__c,Consent__c FROM Subject__c WHERE Id = :subjectId];
        
        //If the consent is already yes then no need to send any message
        if( sub.Consent__c == 'Yes' ){
            throw new AuraHandledException( Label.DC_Label_6 );
        }

        //If the consent is no then no need to send any message
        if( sub.Consent__c == 'No' ){
            throw new AuraHandledException( Label.DC_Label_7 );
        }

        //Consent should not be triggered if subject is not in Monitoring
        if( sub.Disposition__c != 'Monitoring' ){
            throw new AuraHandledException( Label.DC_Label_1 );
        }
        
        //Throw error if today's date is not between Departure Date and Monitoring End Date
        
        if( (sub.Departure_Date__c == null && sub.Monitoring_End_Date__c < Date.today()) || ( sub.Departure_Date__c != null && !(sub.Departure_Date__c <= Date.today() && sub.Monitoring_End_Date__c >= Date.today()) ) ){
            throw new AuraHandledException( Label.DC_Label_2 );
        }
                
        //Fetch Step 1: Consent	message template
        DC_Daily_Message__mdt dailyMessage = [SELECT Message__c, Sequence__c FROM DC_Daily_Message__mdt Where Sequence__c = 1];
		
        //Send Message
        TwilioSF.TwilioApiClientResponse response= sendTwilioMessage(sub.Primary_Cell_Number__c, dailyMessage.Message__c );
        //Handle Response
        if( response.getHtttpStatusCode() == 200 || response.getHtttpStatusCode() == 201 ){
            Conversation__c newConvo = new Conversation__c(); 
            newConvo.Message__c = dailyMessage.Message__c;
            newConvo.Subject__c = sub.Id;
            newConvo.From__C = sub.Primary_Cell_Number__c;
            newConvo.Type__c = 'Outbound';
            newConvo.Message_Sequence__c = dailyMessage.Sequence__c;
            newConvo.Is_Message_Sent__c = true;
            newConvo.Is_User_Replied__c = false;
            insert newConvo;
            
            //sub.Consent__c = 'Pending';
        	update sub;
        }
        else{
            throw new AuraHandledException( 'Error: '+ response.getErrorMessage() );
        }
    }
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method send the Follow Up outbound twilio messages.
    */
    @AuraEnabled
    public static void requestFollowUp(Id subjectId){
        //Fetch Subject Record
        Subject__c sub = [SELECT Id, Primary_Cell_Number__c,Follow_Up_Count__c,Consent__c,Disposition__c,Departure_Date__c,Monitoring_End_Date__c  FROM Subject__c WHERE Id = :subjectId];
        
        //Follow up should not be triggered if subject haven't Consent yet.
        if( sub.Consent__c != 'Yes' ){
            throw new AuraHandledException( Label.DC_Label_3 );
        }
        
        //Follow up should not be triggered if subject is not in Monitoring
        if( sub.Disposition__c != 'Monitoring' ){
            throw new AuraHandledException( Label.DC_Label_1 );
        }
        
        //Show error to user if it does exceed max limit of continues follow up
        if( sub.Follow_Up_Count__c >= Integer.valueOf(Label.DC_Total_Follow_Up_Limit) ){
            throw new AuraHandledException( Label.DC_Label_4.replace('{!MAX_LIMIT}', Label.DC_Total_Follow_Up_Limit) );
        }
        
        //Throw error if today's date is not between Departure Date and Monitoring End Date
        if( (sub.Departure_Date__c == null && sub.Monitoring_End_Date__c < Date.today()) || ( sub.Departure_Date__c != null && !(sub.Departure_Date__c <= Date.today() && sub.Monitoring_End_Date__c >= Date.today()) )){
            throw new AuraHandledException( Label.DC_Label_5 );
        }
        
        //Fetch Step 2: Follow Up message template
        DC_Daily_Message__mdt dailyMessage = [SELECT Message__c, Sequence__c FROM DC_Daily_Message__mdt Where Sequence__c = 2];
        
        //Send Message
        TwilioSF.TwilioApiClientResponse response = sendTwilioMessage(sub.Primary_Cell_Number__c, dailyMessage.Message__c );

        //Handle Response
        if( response.getHtttpStatusCode() == 200 || response.getHtttpStatusCode() == 201 ){
            Conversation__c newConvo = new Conversation__c(); 
            newConvo.Message__c = dailyMessage.Message__c;
            newConvo.Subject__c = sub.Id;
            newConvo.From__C = sub.Primary_Cell_Number__c;
            newConvo.Type__c = 'Outbound';
            newConvo.Message_Sequence__c = dailyMessage.Sequence__c;
            newConvo.Is_Message_Sent__c = true;
            newConvo.Is_User_Replied__c = false;
            insert newConvo;
            
            sub.Follow_Up_Count__c = (sub.Follow_Up_Count__c!=null) ? sub.Follow_Up_Count__c+1 : 1;
            if( sub.Follow_Up_Count__c == Integer.valueOf(Label.DC_Total_Follow_Up_Limit) ){
               sub.Engaged__c = false; 
            }
        	update sub;
        }
        else{
            throw new AuraHandledException( 'Error: '+ response.getErrorMessage() );
        }
    }
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This is generic method to send the twilio messages.
    */
    public static TwilioSF.TwilioApiClientResponse sendTwilioMessage(String mobileNumber, String smsBody){
        Twilio_Config__c twilioConfig = Twilio_Config__c.getInstance();

        TwilioSF.TwilioApiClient api = new TwilioSF.TwilioApiClient(twilioConfig.AccountSid__c, twilioConfig.Token__c);
        api.addUrlPart('Accounts');
        api.addUrlPart(twilioConfig.AccountSid__c);
        api.addUrlPart('Messages.json');
		api.addParam('To', mobileNumber);
        api.addParam('From',twilioConfig.From_Twilio_Number__c);
        api.addParam('Body',smsBody);
        if(!test.isRunningTest())
            return api.doPost();
        else{
            string jsstring='{"contentType":"application/json","charset":"utf-8","httpStatus":"201"}';
            return (TwilioSF.TwilioApiClientResponse)JSON.deserialize(jsstring, TwilioSF.TwilioApiClientResponse.class); 
        }
    }
}