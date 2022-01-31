public with sharing class SymptomsController {
    @AuraEnabled
    public static List<SymptomWrapper> getSymptomData(){
        List<SymptomWrapper> wrapperList = new List<SymptomWrapper>();
        for(Symptom__mdt metadata : [SELECT Id,Questions__c FROM Symptom__mdt]){
            SymptomWrapper wrapper = new SymptomWrapper();
            wrapper.question = metadata.Questions__c;
            wrapperList.add(wrapper);
        }
        if(!wrapperList.isEmpty()){
            return wrapperList; 
        }
        return null;
    }
    public class SymptomWrapper{
        @AuraEnabled public String question;
        public SymptomWrapper(){
            this.question = '';
        }
    }
}