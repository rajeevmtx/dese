public with sharing class PSR_CaseController {
    @AuraEnabled
    public static List<Case> fetchCases(){         
        String userId = UserInfo.getUserId();
        User lstUser = [SELECT Id, ContactId FROM User where Id = :userId];
        return [SELECT Id, CaseNumber, Subject, Status, Type, CreatedDate FROM CASE WHERE ContactId =: lstUser.ContactId AND Type != null ORDER BY CreatedDate DESC];
    }
    @AuraEnabled
    public static List<Project__c> fetchGrants(){         
        String userId = UserInfo.getUserId();
        User lstUser = [SELECT Id, ContactId FROM User where Id = :userId];
        return [SELECT Id,Name,Status__c, Submitted_Date__c, CreatedBy.Name  FROM Project__c WHERE CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC];
    }
}