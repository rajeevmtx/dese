/**
 * @author Vishnu Kumar
 * @email vishnu.kumar@mtxb2b.com
 * @desc This class creates the Symptoms and fetch the Symptoms.
*/
public without sharing class DC_FollowUpController {
    
    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc This class creates the Symptoms and fetch the Symptoms.
    */
    @AuraEnabled
    public static string createSymptoms(string newSymptoms){
        Id followUpRecordTypeId = Schema.SObjectType.Symptoms__c.getRecordTypeInfosByDeveloperName().get('Follow_Up').getRecordTypeId();
        Symptoms__c Symptom = new Symptoms__c();
        Symptom = (Symptoms__c)System.JSON.deserialize(newSymptoms,Symptoms__c.Class);

        Symptom.RecordTypeId = followUpRecordTypeId;        
        insert Symptom;
        return Symptom.Id;   
    }

    /**
     * @author Vishnu Kumar
     * @email vishnu.kumar@mtxb2b.com
     * @desc Used to fetch follow up record type records of symptoms.
    */
    @AuraEnabled
    public static List<FollowUpWrapper> getSymptomsFollowUpRecords(string subjectId){
        List<FollowUpWrapper> followUpWrapperList = new List<FollowUpWrapper>();
        for (Symptoms__c symptom : [SELECT Id, Temperature__c,Did_you_take_any_anti_fever_medicine__c,CreatedDate FROM Symptoms__c 
                                    WHERE Subject__c =: subjectId 
                                    AND RecordType.DeveloperName = 'Follow_Up' ORDER BY CreatedDate desc]){
                FollowUpWrapper wrapper = new FollowUpWrapper(symptom);
                followUpWrapperList.add(wrapper);
        }
        return followUpWrapperList;    
    }

    // Inner Wrapper to Pass symptom records
    public class FollowUpWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String temperature;
        @AuraEnabled public String typeOfThermometer;
        @AuraEnabled public String createdDate;
        @AuraEnabled public String isMedicineTaken;

        public FollowUpWrapper(Symptoms__c symptom){
            Id = symptom.Id;
            temperature = symptom.Temperature__c+'';
            typeOfThermometer = 'F';
            Datetime dt = (Datetime)symptom.CreatedDate; 
            createdDate = dt.format('MM/dd/yyyy HH:MM a');
            isMedicineTaken = symptom.Did_you_take_any_anti_fever_medicine__c ? 'Yes' : 'No';
        }
    }
}