/**
* @author S Anand
* @desc This is Test class of TwilioMessageStatusTrigger.
*/
@istest
private class DC_TwilioMessageStatusTriggerTest {
    
    @testSetup static void setup() {
        List<Subject__c> subList = new List<Subject__c>();  
        for(integer i=0;i<2;i++){
            Subject__c subject1= new Subject__c();
            subject1.Primary_Cell_Number__c  ='123456789'+i;
            subject1.Consent__c = (i==0) ? 'Yes':'No';
            
            subject1.Disposition__c = 'Monitoring';
            subList.add(subject1);
        }
        insert subList;
        List<Conversation__c> convList = new List<Conversation__c>();
       
        for(Integer i=0;i<2;i++){
            Conversation__c conv1 = new Conversation__c();
            conv1.Message_Sequence__c = i+1;
            conv1.From__c = subList[i].Primary_Cell_Number__c;
            conv1.Is_User_Replied__c = true;
            conv1.Type__c = 'Outbound';
            convList.add(conv1);
        }    
         for(Integer i=0;i<2;i++){
            Conversation__c conv1 = new Conversation__c();
            conv1.Message_Sequence__c = i+1;
            conv1.From__c = subList[i].Primary_Cell_Number__c;
            conv1.Is_User_Replied__c = false;
            conv1.Type__c = 'Outbound';
            convList.add(conv1);
        } 
        
        
        insert convList;
        
        
    }
    
    @isTest
    private Static Void eventTest(){
        List<Subject__c> subList =  [Select Id,Primary_Cell_Number__c  FROM Subject__c ];
        List<TwilioSF__Twilio_Message_Status__e> eventsList = new List<TwilioSF__Twilio_Message_Status__e>();
        Test.startTest();
        for(Integer i=0;i<2;i++){
        TwilioSF__Twilio_Message_Status__e event = new TwilioSF__Twilio_Message_Status__e();
        event.TwilioSF__From__c = subList[i].Primary_Cell_Number__c;
        event.TwilioSF__Body__c  = 'yes';
        eventsList.add(event);
            
        }
        Database.SaveResult[] sr = EventBus.publish(eventsList);
        Test.stopTest();
        List<Conversation__c> convListUpdate = [Select Id,Type__c FROM Conversation__c WHERE Type__c = 'Inbound'];
        System.assertEquals(convListUpdate.size(),2 );
        List<Conversation__c> convListUpdateForReply = [Select Id,Is_User_Replied__c FROM Conversation__c  WHERE Is_User_Replied__c = True];
        System.assertEquals(convListUpdate.size(),2 );
        
        
    }   
    
    @isTest
    private Static Void eventTestNegative(){
        List<Conversation__c> convList = new List<Conversation__c>();
        for(Conversation__c conv :  [Select Id,Is_User_Replied__c  FROM Conversation__c ]){
            conv.Is_User_Replied__c = false;
            convList.add(conv);
        }
        update convList;
        Map<Decimal,DC_Daily_Message__mdt> sequenceAndDailyMessage = new Map<Decimal,DC_Daily_Message__mdt>();
        for( DC_Daily_Message__mdt dm : [Select id,Message__c,Reply_on_No__c,Reply_on_Yes__c,Sequence__c from DC_Daily_Message__mdt] ){
            sequenceAndDailyMessage.put(dm.Sequence__c, dm);
        }
        List<Subject__c> subList =  [Select Id,Primary_Cell_Number__c  FROM Subject__c ];
        List<TwilioSF__Twilio_Message_Status__e> eventsList = new List<TwilioSF__Twilio_Message_Status__e>();
        Test.startTest();
        for(Integer i=0;i<2;i++){
        TwilioSF__Twilio_Message_Status__e event = new TwilioSF__Twilio_Message_Status__e();
        event.TwilioSF__From__c = subList[i].Primary_Cell_Number__c;
        event.TwilioSF__Body__c  = 'No';
        eventsList.add(event);
            
        }        Database.SaveResult[] sr = EventBus.publish(eventsList);
        Test.stopTest();
        for(Subject__c subTest :  [Select Id,Primary_Cell_Number__c,Consent__c  FROM Subject__c WHERE Primary_Cell_Number__c=:eventsList[0].TwilioSF__From__c ]){
            System.assertEquals(subTest.Consent__c,'No');
        }
        //   List<Conversation__c> convListUpdate = [Select Id,Type__c FROM Conversation__c WHERE Type__c = 'OutBound' AND Id NOT IN:convList];
        //   System.assertEquals(convListUpdate.size(),4 );
        
        
        
    }
}