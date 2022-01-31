@istest
public class DC_SendOutboundMessageControllerTest {
    @testSetup static void docreatesetup() {
        Subject__c subject1= new Subject__c();
        subject1.Primary_Cell_Number__c  ='1234567890';
        subject1.Disposition__c='Monitoring';
        subject1.Consent__c='Yes';
        subject1.Follow_Up_Count__c=Integer.valueOf(Label.DC_Total_Follow_Up_Limit)-1;
        subject1.Monitoring_End_Date__c=system.today()+10;
        subject1.Departure_Date__c=system.today()-10;
        insert subject1;
        system.assertEquals('1234567890', subject1.Primary_Cell_Number__c);
        
        DC_Daily_Message__mdt dailyMessage = [SELECT Message__c, Sequence__c FROM DC_Daily_Message__mdt Where Sequence__c = 1];
        SYSTEM.DEBUG('dailyMessage:'+dailyMessage);
        list<Twilio_Config__c> t= new list<Twilio_Config__c>();
        Twilio_Config__c tw= NEW  Twilio_Config__c();//[select id,AccountSid__c,From_Twilio_Number__c,Token__c from Twilio_Config__c limit 1];
        tw.AccountSid__c='AC10038fdf5235c774f140a6c76c68323a';
        tw.From_Twilio_Number__c='+17185501627';
        tw.Token__c='cac5077edb7c99383c8d9dc717fb7446';
        t.add(tw);
        insert t;
        system.assertEquals(t.size()>0, true);
        system.debug('TW:'+TW);
        
        
    }
    @istest
    public static void doexecute1(){
        Subject__c sc=[select id,Primary_Cell_Number__c ,Disposition__c,Consent__c,Departure_Date__c from Subject__c limit 1 ];
        DC_Daily_Message__mdt dailyMessage = [SELECT Message__c, Sequence__c FROM DC_Daily_Message__mdt Where Sequence__c = 1];
        Twilio_Config__c t= [select id,AccountSid__c,From_Twilio_Number__c,Token__c from Twilio_Config__c limit 1];
                
      /*     
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Twilioapiclientresp');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        test.setMock(TwilioSF.TwilioApiClientResponse.class,mock);
        */  
        
        test.setMock(HttpCalloutMock.class, new DC_sendOutboundmessagecontrollermock());
        test.startTest();
        
        try {
           DC_SendOutboundMessageController.requestFollowUp(sc.Id);
        }
        catch(exception e){
        }     
        //  DC_SendOutboundMessageController.requestConsent(subject1.Id);
        test.stopTest();
    }
    @istest
    public static void doexecute2(){
        Subject__c sc=[select id,Primary_Cell_Number__c ,Disposition__c,Consent__c,Departure_Date__c from Subject__c limit 1 ];
        sc.Consent__c = 'pending';
        update sc;
        DC_Daily_Message__mdt dailyMessage = [SELECT Message__c, Sequence__c FROM DC_Daily_Message__mdt Where Sequence__c = 1];
        Twilio_Config__c t= [select id,AccountSid__c,From_Twilio_Number__c,Token__c from Twilio_Config__c limit 1];
        Test.setMock(HttpCalloutMock.class, new DC_sendOutboundmessagecontrollermock());
        test.startTest();
        //  DC_SendOutboundMessageController.requestFollowUp(sc.Id);
        try{
            DC_SendOutboundMessageController.requestConsent(sc.Id);
          }
        catch(exception e){
        }     
        
        test.stopTest();
    }
}