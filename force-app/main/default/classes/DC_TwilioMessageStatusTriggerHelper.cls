/**
 * @author Vishnu Kumar
 * @email vishnu.kumar@mtxb2b.com
 * @desc This is helper class of TwilioMessageStatusTrigger.
*/
public class DC_TwilioMessageStatusTriggerHelper {
    
    public static void run(){
        if( Trigger.isInsert && Trigger.isAfter ){
            processTwilioMessage();
        }
    }
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This method process Twilio reply to subject.
    */
    public static void processTwilioMessage(){
        //Variables
        List <String> phoneNumbers = new List<String>();
        List <Conversation__c> conversations = new List<Conversation__c>();
        List<Conversation__c> autoReponseConversations = new List<Conversation__c>();
        Map<String, List<Subject__c>> phoneNumberAndSubjects = new Map<String, List<Subject__c>>();
        Map<String, String> messageReplies = new Map<String, String>();
        
        //Step 1: Get all the phone number
        for (TwilioSF__Twilio_Message_Status__e event : (List<TwilioSF__Twilio_Message_Status__e>)Trigger.New) {
            phoneNumbers.add(event.TwilioSF__From__c);
        }

        //Step 2: Fetch all the subject based on the mobile number and combine in list as per mobile number
        for (Subject__c subject: [SELECT Id, Primary_Cell_Number__c FROM Subject__c WHERE Primary_Cell_Number__c IN : phoneNumbers AND Disposition__c = 'Monitoring']) {
            List<Subject__c> subjects = new List<Subject__c>();
            
            if( phoneNumberAndSubjects.containsKey(subject.Primary_Cell_Number__c) ){
                subjects = phoneNumberAndSubjects.get(subject.Primary_Cell_Number__c);
            }
            subjects.add(subject);
            
            phoneNumberAndSubjects.put(subject.Primary_Cell_Number__c, subjects);
        }
        
        //Step 3: Finding that what was the latest message sent on the mobile number
        Map<String, Conversation__c> phoneNumerbAndLatestSequence = new Map<String, Conversation__c>();
        for( Conversation__c conversation : [SELECT id,Message_Sequence__c,From__c,Is_User_Replied__c FROM Conversation__c where From__c IN : phoneNumbers AND Type__c = 'Outbound' AND Message_Sequence__c != null order by CreatedDate asc]){
            phoneNumerbAndLatestSequence.put(conversation.From__c, conversation);
        }
        
        //Step 4: Message configuration as key with Sequence 
        Map<Decimal,DC_Daily_Message__mdt> sequenceAndDailyMessage = new Map<Decimal,DC_Daily_Message__mdt>();
        for( DC_Daily_Message__mdt dm : [Select id,Message__c,Reply_on_No__c,Reply_on_Yes__c,Sequence__c from DC_Daily_Message__mdt] ){
            sequenceAndDailyMessage.put(dm.Sequence__c, dm);
        }
        
        //Step 5: Process incoming message
        for( TwilioSF__Twilio_Message_Status__e event : (List<TwilioSF__Twilio_Message_Status__e>)Trigger.New ) {
            
            //Check if recently outbound message was sent and have Subject with it
            if( phoneNumerbAndLatestSequence.containsKey(event.TwilioSF__From__c) && phoneNumberAndSubjects.containsKey(event.TwilioSF__From__c) ){
                Conversation__c lastOutbondConversation = phoneNumerbAndLatestSequence.get(event.TwilioSF__From__c);
                
                //Handle Consent Reply
                if( lastOutbondConversation.Message_Sequence__c == 1 ){
                    
                    system.debug('--lastOutbondConversation-'+lastOutbondConversation);
                    
                    if( lastOutbondConversation.Is_User_Replied__c ){
                        messageReplies.put( event.TwilioSF__From__c , Label.DC_No_Response_Needed );
                    }
                    else{
                        //If user says Yes then mark the user as Engaged and Consent to Yes
                        if( event.TwilioSF__Body__c.equalsIgnoreCase('y') || event.TwilioSF__Body__c.equalsIgnoreCase('yes') ){
                            
                            for( Subject__c subject : phoneNumberAndSubjects.get(event.TwilioSF__From__c) ){
                                subject.Engaged__c = true;
                                subject.Consent__c = 'Yes';
                            }
                            
                            lastOutbondConversation.Is_User_Replied__c = true;
                            
                            messageReplies.put( event.TwilioSF__From__c , sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_Yes__c );
                            
                            conversations.add(lastOutbondConversation);
                        }
                        //If user says No then mark the user as Engaged and Consent to No
                        else if( event.TwilioSF__Body__c.equalsIgnoreCase('n') || event.TwilioSF__Body__c.equalsIgnoreCase('no') ){
                            
                            for( Subject__c subject : phoneNumberAndSubjects.get(event.TwilioSF__From__c) ){
                                subject.Engaged__c = true;
                                subject.Consent__c = 'No';
                            }
                            
                            lastOutbondConversation.Is_User_Replied__c = true;
                            
                            messageReplies.put( event.TwilioSF__From__c , sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_No__c );
                            
                            conversations.add(lastOutbondConversation);
                        }
                        //If user replied other answer instead of yes or no
                        else{
                            messageReplies.put( event.TwilioSF__From__c , Label.DC_Invalid_Reply );
                        }
                    }
                }
                //Handle Follow Up Reply
                else if( lastOutbondConversation.Message_Sequence__c == 2 ){
                    
                    if( lastOutbondConversation.Is_User_Replied__c ){
                        messageReplies.put( event.TwilioSF__From__c , Label.DC_No_Response_Needed );
                    }
                    else{
                        //If user says Yes then mark the user as Engaged and Symptom to true
                        if( event.TwilioSF__Body__c.equalsIgnoreCase('y') || event.TwilioSF__Body__c.equalsIgnoreCase('yes') ){
                            
                            Subject__c sub;
                            for( Subject__c subject : phoneNumberAndSubjects.get(event.TwilioSF__From__c) ){
                                subject.Engaged__c = true;
                                subject.Symptom__c  = true;
                                subject.Follow_Up_Count__c = 0;
                                System.debug('subject.Symptom__c >>'+subject.Symptom__c );
                                sub = subject;
                            }
                            
                            lastOutbondConversation.Is_User_Replied__c = true;
                            string msg = sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_Yes__c;
                            msg = msg.replace('{!ID}', sub.Id);
                            
                            messageReplies.put( event.TwilioSF__From__c ,  msg);
                            
                            conversations.add(lastOutbondConversation);
                        }
                        //If user says No then mark the user as Engaged and Symptom to false
                        else if( event.TwilioSF__Body__c.equalsIgnoreCase('n') || event.TwilioSF__Body__c.equalsIgnoreCase('no') ){
                            
                            for( Subject__c subject : phoneNumberAndSubjects.get(event.TwilioSF__From__c) ){
                                subject.Engaged__c = true;
                                subject.Symptom__c  = false;
                                subject.Follow_Up_Count__c = 0;
                            }
                            
                            lastOutbondConversation.Is_User_Replied__c = true;
                            
                            messageReplies.put( event.TwilioSF__From__c , sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_No__c );
                            
                            conversations.add(lastOutbondConversation);
                        }
                        //If user replied other answer instead of yes or no
                        else{
                            messageReplies.put( event.TwilioSF__From__c , Label.DC_Invalid_Reply );
                        }
                    }
                }
            }
        }
            
                /*for( Subject__c subject : phoneNumberAndSubjects.get(event.TwilioSF__From__c) ){
                    //Handle Consent Reply
                    if( lastOutbondConversation.Message_Sequence__c == 1 ){
                        
                        system.debug('--lastOutbondConversation-'+lastOutbondConversation);
                        
                        if( lastOutbondConversation.Is_User_Replied__c ){
                            messageReplies.put( event.TwilioSF__From__c , Label.DC_No_Response_Needed );
                        }
                        else{
                            //If user says Yes then mark the user as Engaged and Consent to Yes
                            if( event.TwilioSF__Body__c.equalsIgnoreCase('y') || event.TwilioSF__Body__c.equalsIgnoreCase('yes') ){
                                subject.Engaged__c = true;
                                subject.Consent__c = 'Yes';
                                lastOutbondConversation.Is_User_Replied__c = true;
                                
                                messageReplies.put( event.TwilioSF__From__c , sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_Yes__c );
                                
                                conversations.add(lastOutbondConversation);
                            }
                            //If user says No then mark the user as Engaged and Consent to No
                            else if( event.TwilioSF__Body__c.equalsIgnoreCase('n') || event.TwilioSF__Body__c.equalsIgnoreCase('no') ){
                                subject.Engaged__c = true;
                                subject.Consent__c = 'No';
                                lastOutbondConversation.Is_User_Replied__c = true;
                                
                                messageReplies.put( event.TwilioSF__From__c , sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_No__c );
                            
                                conversations.add(lastOutbondConversation);
                            }
                            //If user replied other answer instead of yes or no
                            else{
                                messageReplies.put( event.TwilioSF__From__c , Label.DC_Invalid_Reply );
                            }
                        }
                    }
                    //Handle Follow Up Reply
                    else if( lastOutbondConversation.Message_Sequence__c == 2 ){
                        
                        if( lastOutbondConversation.Is_User_Replied__c ){
                            messageReplies.put( event.TwilioSF__From__c , Label.DC_No_Response_Needed );
                        }
                        else{
                            //If user says Yes then mark the user as Engaged and Symptom to true
                            if( event.TwilioSF__Body__c.equalsIgnoreCase('y') || event.TwilioSF__Body__c.equalsIgnoreCase('yes') ){
                                subject.Engaged__c = true;
                                subject.Symptom__c  = true;
                                subject.Follow_Up_Count__c = 0;
                                lastOutbondConversation.Is_User_Replied__c = true;
                                string msg = sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_Yes__c;
                                msg = msg.replace('{!ID}', subject.Id);
                                
                                messageReplies.put( event.TwilioSF__From__c ,  msg);
                                
                                conversations.add(lastOutbondConversation);
                            }
                            //If user says No then mark the user as Engaged and Symptom to false
                            else if( event.TwilioSF__Body__c.equalsIgnoreCase('n') || event.TwilioSF__Body__c.equalsIgnoreCase('no') ){
                                subject.Engaged__c = true;
                                subject.Symptom__c  = false;
                                subject.Follow_Up_Count__c = 0;
                                lastOutbondConversation.Is_User_Replied__c = true;
                                
                                messageReplies.put( event.TwilioSF__From__c , sequenceAndDailyMessage.get(lastOutbondConversation.Message_Sequence__c).Reply_on_No__c );
                            
                                conversations.add(lastOutbondConversation);
                            }
                            //If user replied other answer instead of yes or no
                            else{
                                messageReplies.put( event.TwilioSF__From__c , Label.DC_Invalid_Reply );
                            }
                        }
                    }
                }
            }
        }*/
        
        integer incrementNumber = 1;
        //Create incoming Twilio message to Conversation record
        for (TwilioSF__Twilio_Message_Status__e event : (List<TwilioSF__Twilio_Message_Status__e>)Trigger.New) {
            if( phoneNumberAndSubjects.containsKey(event.TwilioSF__From__c) ){
                Conversation__c conversationObj = new Conversation__c();
                conversationObj.Subject__c = phoneNumberAndSubjects.get(event.TwilioSF__From__c)[0].Id;
                conversationObj.Message__c = event.TwilioSF__Body__c; 
                conversationObj.Type__c = 'Inbound';
                conversationObj.From__c = event.TwilioSF__From__c;
                conversationObj.Random_Increment_Number__c = incrementNumber;
                conversations.add(conversationObj);
                incrementNumber++;
            }
        }
        
        //Create Auto Response Conversation records and these will be picked by batch
        for( String phone : messageReplies.keySet() ){
            Conversation__c newConvo = new Conversation__c(); 
            newConvo.Message__c = messageReplies.get(phone);
            newConvo.Subject__c = phoneNumberAndSubjects.get(phone)[0].Id;
            newConvo.From__C = phone;
            newConvo.Type__c = 'Outbound';
            newConvo.Is_Message_Sent__c = false;
            newConvo.Random_Increment_Number__c = incrementNumber;
            conversations.add( newConvo );
            incrementNumber++;
        }
                
        //Update Subject's data
        if( !phoneNumberAndSubjects.isEmpty() ){
            List<Subject__c> subjectToUpdate = new List<Subject__c>();
            for( List<Subject__c> subs : phoneNumberAndSubjects.values() ){
                subjectToUpdate.addAll(subs);
            }
            update subjectToUpdate;
        }
        
        // Insert all conversations incoming response, auto response, last outbound message update
        if( !conversations.isEmpty() ) {
            upsert conversations;
        }
    }
}