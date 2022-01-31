@isTest
public class MtxIntakeFormControllerTest {
    @testSetup static void setup() {
      
      
        Subject__c subject= new Subject__c();
        subject.Primary_Cell_Number__c  ='1234567890';
        subject.Consent__c ='Yes';
        subject.Disposition__c = 'Monitoring';
        insert subject;
        
        Conversation__c conversation = new Conversation__c();
        conversation.Message_Sequence__c =1;
        conversation.From__c = subject.Primary_Cell_Number__c;
        conversation.Is_User_Replied__c = true;
        conversation.Type__c = 'Outbound';
        conversation.subject__c = subject.id;
        insert conversation;

        Address_Information__c addressInformation = new Address_Information__c();
        addressInformation.Subject__c = subject.id;
        Insert addressInformation;
        
        Guardian_Information__c guardian = new Guardian_Information__c();
        guardian.Subject__c = subject.id;
        guardian.Landline_Number__c = '(555) 555-1234' ;
        guardian.Primary_Cell_Number__c = subject.Primary_Cell_Number__c;
        guardian.First_name__c = 'Test';
        guardian.Last_Name__c = 'Test';
        Insert guardian;
        
        Traveller__c travller = new Traveller__c();
        travller.Subject__c = subject.id;
        Insert travller;
        

        Symptoms__c symptom = new Symptoms__c();
        symptom.Abdominal_Pain__c = 'Yes';
        symptom.Chills__c = 'Yes';
        symptom.Cough__c = 'Yes';
        symptom.Did_you_take_any_anti_fever_medicine__c = true;
        symptom.Difficulty_Breathing__c = 'Yes';
        symptom.Fever__c = 'Yes';
        symptom.Headache__c = 'Yes';
        symptom.Muscle_Aches__c = 'Yes';
        symptom.Sore_Throat__c = 'Yes';
        symptom.Temperature__c = 98.20;
        symptom.Vomiting__c = 'Yes';
        symptom.Subject__c = subject.Id;
        Insert symptom;
        
        
    }
    @isTest
    private Static Void getAddressInformationTest(){
        Subject__c subject = [SELECT id from Subject__c Limit 1];
        Test.startTest();
         MtxIntakeFormController.getAddressInformation(subject.id);
        Test.stopTest();
   }
    @isTest
    private Static Void getGuardianInformationTest(){
        Subject__c subject = [SELECT id from Subject__c Limit 1];
        Test.startTest();
         MtxIntakeFormController.getGuardianInformation(subject.id);
        Test.stopTest();
    }
    
    @isTest
    private Static Void getTravelInfoTest(){
        Subject__c subject = [SELECT id from Subject__c Limit 1];
        Test.startTest();
         MtxIntakeFormController.getTravelInfo(subject.id);
        Test.stopTest();
    }
     @isTest
    private Static Void getSymptomInfoTest(){
        Subject__c subject = [SELECT id from Subject__c Limit 1];
        Test.startTest();
         MtxIntakeFormController.getSymptomInfo(subject.id);
        Test.stopTest();
    }
     @isTest
    private Static Void getConsentInfoTest(){
       Subject__c subject = [SELECT id from Subject__c Limit 1];
        Test.startTest();
         MtxIntakeFormController.getConsentInfo(subject.id);
        Test.stopTest();
    }
}