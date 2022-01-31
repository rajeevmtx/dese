@isTest
public class NYSDOH_RequestController_Test {
    
    //testmethod for DOH Hospital User
    @isTest
    static void fetchRequestsHospitalTest() {
        
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);
        List<Contact> contactList =NYSDOH_TestFactory.createContact(accountList[0].Id,true);
        Id profileId = [SELECT Id, Name from Profile where Name = 'DOH Hospital User' LIMIT 1].Id;
        User usr = NYSDOH_TestFactory.createUser('testABC@abc.com', 'test@gmail.com', false);
        usr.ProfileId = profileId ;
        usr.ContactId = contactList[0].Id;
        Test.startTest();
        insert usr;
        Test.stopTest();
        List<Account> aacountList = NYSDOH_TestFactory.createAccount(true);
        List<Request__c> resuestList = NYSDOH_TestFactory.createRequest(accountList[0].Id,true);
        List<Bid__c> bidList = NYSDOH_TestFactory.createBid(resuestList[0].Id,true);
        System.runAs(usr) {
            NYSDOH_RequestController.fetchRequests();
            NYSDOH_RequestController.fetchBids(resuestList[0].Id);
        }
        
    }
    
    //testmethod for DOH Supplier User
    @isTest
    static void fetchRequestsSupplierTest() {
        
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);
        List<Contact> contactList =NYSDOH_TestFactory.createContact(accountList[0].Id,true);
        Id profileId = [SELECT Id, Name from Profile where Name = 'DOH Supplier User' LIMIT 1].Id;
        User usr = NYSDOH_TestFactory.createUser('testABC@abc.com', 'test@gmail.com', false);
        usr.ProfileId = profileId ;
        usr.ContactId = contactList[0].Id;
        Test.startTest();
        insert usr;
        Test.stopTest();
        List<Account> aacountList = NYSDOH_TestFactory.createAccount(true);
        List<Request__c> resuestList = NYSDOH_TestFactory.createRequest(accountList[0].Id,true);
        List<Bid__c> bidList = NYSDOH_TestFactory.createBid(resuestList[0].Id,true);
        System.runAs(usr) {
            NYSDOH_RequestController.fetchRequests();
            NYSDOH_RequestController.fetchBids(resuestList[0].Id);
        }
        
    }
}