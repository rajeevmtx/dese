/**
 * Created by arunm on 22-03-2020.
 */

public without sharing class NYSDOH_RequestController {

    @AuraEnabled
    public static User getCurrentUser() {
        User currentUser = [SELECT Id, Name, AccountId, ContactId, Profile.Name FROM User WHERE Id =:UserInfo.getUserId()];
        return currentUser;
    }

    @AuraEnabled
    public static List<Request__c> fetchRequests() {
        User currentUser = getCurrentUser();
        Id accountId = currentUser.AccountId;
        String requestQuery = 'SELECT Id, Hospital__c, Hospital__r.Name, Item_Name__c, Quantity__c, Status__c, Type__c FROM Request__c';
        if(currentUser.Profile.Name  == 'DOH Hospital User') {
            requestQuery += ' WHERE Hospital__c =:accountId';
        }
        return (List<Request__c>)Database.query(requestQuery);
    }

    @AuraEnabled
    public static List<Bid__c> fetchBids(String requestId) {
        User currentUser = getCurrentUser();
        Id currentUserId = currentUser.Id;
        String bidQuery = 'SELECT Id, Bid_Status__c, Amount__c FROM Bid__c';
        if(currentUser.Profile.Name  == 'DOH Hospital User') {
            bidQuery += ' WHERE Request__c =:requestId';
        }
        else if(currentUser.Profile.Name  == 'DOH Supplier User') {
            bidQuery += ' WHERE Request__c =:requestId AND CreatedById =:currentUserId';
        }
        return (List<Bid__c>)Database.query(bidQuery);
    }
}