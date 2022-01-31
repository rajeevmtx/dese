@isTest
public class DC_SendPendingMessagesBatchTest {
    
         
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
         // conv1.Is_User_Replied__c = false;
            conv1.Is_Message_Sent__c = false ;
            conv1.Type__c = 'Outbound';
            convList.add(conv1);
        }    
         for(Integer i=0;i<2;i++){
            Conversation__c conv1 = new Conversation__c();
            conv1.Message_Sequence__c = i+1;
            conv1.From__c = subList[i].Primary_Cell_Number__c;
            conv1.Is_Message_Sent__c = false ;
            conv1.Is_User_Replied__c = false;
            conv1.Type__c = 'Outbound';
            convList.add(conv1);
        } 
  
        insert convList;
        
        
    }
    @isTest
    private Static Void runBatchTest(){
            Test.startTest();
            
            DC_SendPendingMessagesBatch obj = new DC_SendPendingMessagesBatch();
            DataBase.executeBatch(obj); 
            
            Test.stopTest();
        }
    }