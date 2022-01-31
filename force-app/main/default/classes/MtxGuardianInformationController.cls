/**
 * @author Mahima Aggarwal
 * @email mahima.aggarwal@mtxb2b.com
 * @desc This class is the controller class for mtxGuardianInformation component.
*/
public with sharing class MtxGuardianInformationController {

    /**
     * @author Mahima Aggarwal
     * @email mahima.aggarwal@mtxb2b.com
     * @desc This method returns the age of Subject. Adding guardian is mandatory if age is less than 18
    */
    @AuraEnabled
    public static boolean isGuardianMandatory(String subjectId){
        System.debug('isGuardianMandatory');
        return ([SELECT Id,Age__c FROM Subject__c WHERE Id = :subjectId LIMIT 1].Age__c < 18);
    }

    /**
     * @author Mahima Aggarwal
     * @email mahima.aggarwal@mtxb2b.com
     * @desc This method returns all the guardians of particular subject
    */
    @AuraEnabled
    public static List<Guardian_Information__c> getAllGuardian(String subjectId){
        return [SELECT Id,Type__c,First_name__c,Last_Name__c,Primary_Cell_Number__c,Landline_Number__c 
         FROM Guardian_Information__c WHERE Subject__c = :subjectId ];
    }
}