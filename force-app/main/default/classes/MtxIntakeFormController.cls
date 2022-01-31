public with sharing class MtxIntakeFormController {
    @AuraEnabled(cacheable=true)
    public static list<Address_Information__c> getAddressInformation(String subjectId){
        return [SELECT Id, Address_Line_1__c, City__c, Country__c, State__c,
                RecordType.Name
               FROM Address_Information__c
               WHERE Subject__c = :subjectId];
    }
    @AuraEnabled(cacheable=true)
    public static list<Guardian_Information__c> getGuardianInformation(String subjectId){
        return [SELECT Id, Type__c,First_name__c,Last_Name__c,Primary_Cell_Number__c,Landline_Number__c
                FROM Guardian_Information__c
                WHERE Subject__c = :subjectId];
    }

    /**
     * @author Mahima Aggarwal
     * @email mahima.aggarwal@mtxb2b.com
     * @desc This method returns all the traveller of particular subject
    */
    @AuraEnabled
    public static String getTravelInfo(String subjectId){
        List<Traveller__c> travellerList = new List<Traveller__c>();
        travellerList = [SELECT Id FROM Traveller__c WHERE Subject__c = :subjectId ORDER BY CreatedDate desc LIMIT 1];
        
        if(travellerList.size() > 0){
            return travellerList[0].Id;
        }
        else{
            return '';
        }
    }

    /**
     * @author Mahima Aggarwal
     * @email mahima.aggarwal@mtxb2b.com
     * @desc This method returns all the symptom of particular subject
    */
    @AuraEnabled
    public static String getSymptomInfo(String subjectId){
        List<Symptoms__c> symptomsList = new List<Symptoms__c>();
        symptomsList = [SELECT Id FROM Symptoms__c WHERE Subject__c = :subjectId ORDER BY CreatedDate desc LIMIT 1];
        
        if(symptomsList.size() > 0){
            return symptomsList[0].Id;
        }
        else{
            return '';
        }
    }

    /**
     * @author Mahima Aggarwal
     * @email mahima.aggarwal@mtxb2b.com
     * @desc This method returns consent of particular subject
    */
    @AuraEnabled
    public static String getConsentInfo(String subjectId){
        List<Subject__c> subjectList = new List<Subject__c>();
        subjectList = [SELECT Id,Consent__c FROM Subject__c WHERE 
                      Id = :subjectId ORDER BY CreatedDate desc LIMIT 1];
        
        if(subjectList.size() > 0){
            return subjectList[0].Consent__c;
        }
        else{
            return '';
        }
           
    }
}