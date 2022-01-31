/**
* @author Hiten Aggarwal
* @Date : 27-03-2020
*/

@istest
public class DC_FollowUpControllerTest {
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
      
    }
    @isTest
    private Static Void createSymptomsTest(){
        List<Subject__c> subList =  [Select Id,Primary_Cell_Number__c  FROM Subject__c ];
        
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
        symptom.Subject__c = subList[0].Id;
        
        String newSymptoms = JSON.serialize(symptom);
        symptom.Id = DC_FollowUpController.createSymptoms(newSymptoms);
        
        if(subList.size()>0){
          DC_FollowUpController.getSymptomsFollowUpRecords(subList[0].Id);
        }
        
    } 
      
}