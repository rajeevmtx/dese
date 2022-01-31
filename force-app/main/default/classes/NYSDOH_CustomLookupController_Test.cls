@isTest
public class NYSDOH_CustomLookupController_Test {

    @isTest
    static void findRecordsTest() {
        String objectName = 'Account';       
        String searchField = 'Name';
        String searchKey = 'Test';
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);
        NYSDOH_CustomLookupController.findRecords(accountList[0].Name, objectName, searchField);
        
       List<Account> forAssertion = [SELECT Name FROM Account WHERE  Id =: accountList[0].Id];
       System.assertEquals('Test Account Name', forAssertion[0].Name, 'Expected Test Account Name');
    }
}