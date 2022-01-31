public with sharing class PSRApplication_TriggerHandler {
    public static void handleAfterInsert(List<Application__c> applicationList){
        PSRApplication_TriggerHelper.insertApplicationDocumentRecords(applicationList);
        PSRApplication_TriggerHelper.insertApplicationContacts(applicationList);
    }
}