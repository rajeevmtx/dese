@istest
public class DC_ConversationsControllerTest {
    @testSetup static void docreatesetup() {
        Subject__c subject1= new Subject__c();
        subject1.Primary_Cell_Number__c  ='1234567890';
        insert subject1;
        system.assertEquals('1234567890', subject1.Primary_Cell_Number__c);
        Conversation__c conver=new Conversation__c();
        conver.Is_User_Replied__c=false;
        conver.Message__c='yes';
        conver.Type__c='Inbound';
        conver.Subject__c=subject1.id;
        insert conver;
        system.assertEquals('Inbound', conver.Type__c);
        Conversation__c conver1=new Conversation__c();
        conver1.Is_User_Replied__c=false;
        conver1.Message__c='yes';
        conver1.Type__c='Outbound';
        conver1.Subject__c=subject1.id;
        insert conver1;
        system.assertEquals('Outbound', conver1.Type__c);
        
    }
    
    @istest 
    public static void dotestexecute(){
        Subject__c sc=[select id,Primary_Cell_Number__c from Subject__c];
        list<Conversation__c> son=[select Is_User_Replied__c,id,Message__c,Type__c,Subject__c from Conversation__c];        
        DC_ConversationsController DCC= new DC_ConversationsController();
        DC_ConversationsController.getConversations(sc.Id);
        //DC_ConversationsController.getLastRefreshConversation(sc.id);
        //DC_ConversationsController.saveLastRefreshConversation(sc.Id);
    }
}