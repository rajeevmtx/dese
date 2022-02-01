public with sharing class DashboardController {
    public DashboardController() {

    }
    @AuraEnabled
    public static Map<String, Decimal> getStatusInfo(){   //getting Proposal Statuses of Logged In User
        try {
            Map<String,Decimal> statusToCountMap = new Map<String,Decimal>();
            for( Project__c ecr : [SELECT Id, Status__c FROM Project__c WHERE CreatedById = :userInfo.getUserId() ]){
                if(!statusToCountMap.containsKey(ecr.Status__c)){
                    statusToCountMap.put(ecr.Status__c,0);
                }
                statusToCountMap.put(ecr.Status__c,statusToCountMap.get(ecr.Status__c)+1);
            }
            return statusToCountMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getProposalRecords(String status){
        try {
            List<Project__c> projects = new List<Project__c>([
                SELECT Id, Status__c, Name,Program_Version__r.Name,Program_Version__c FROM Project__c WHERE Status__c =: status AND CreatedById = :userInfo.getUserId()
                ORDER BY CreatedDate DESC
            ]);
            return JSON.serialize(projects);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}