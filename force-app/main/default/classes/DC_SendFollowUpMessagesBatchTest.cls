@isTest
public class DC_SendFollowUpMessagesBatchTest {
     
    @testSetup static void setup() {
        Date days_out = Date.today();
        Integer maxFollowUp = Integer.valueOf(Label.DC_Total_Follow_Up_Limit);
        List<Subject__c> subList = new List<Subject__c>();  
        
        for(integer i=0 ; i<10 ; i++){
            Subject__c subject1= new Subject__c();
            //subject1.Primary_Cell_Number__c  ='123456789'+i;
            subject1.Departure_Date__c = date.today() - 5;
            subject1.Monitoring_End_Date__c =date.today() + 10;
            subject1.Consent__c ='Yes';
            subject1.Follow_Up_Count__c = maxFollowUp -10;
            subject1.Disposition__c = 'Monitoring';
            subList.add(subject1);
        }
        insert subList;
       
        
    }
    @isTest
    private Static Void runBatchTest(){
        Test.startTest();
        
        DC_SendFollowUpMessagesBatch obj = new DC_SendFollowUpMessagesBatch();
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
        
    }

  
}