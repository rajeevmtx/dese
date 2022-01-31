public with sharing class MtxTravelerInfoController {
    @AuraEnabled
    public static String checkDuplicateSubject(String fname, String lname, Date dob, String phone){
        List<Subject__c> subjectList = new List<Subject__c>();
        subjectList = [SELECT Id FROM Subject__c WHERE 
                                        First_Name__c = :fname AND
                                        Last_Name__c = :lname AND
                                        Date_of_Birth__c = :dob AND
                                        Primary_Cell_Number__c = :phone ORDER BY CreatedDate desc LIMIT 1];
        
        if(subjectList.size() > 0){
            return subjectList[0].Id;
        }
        else{
            return '';
        }
           
    }
}