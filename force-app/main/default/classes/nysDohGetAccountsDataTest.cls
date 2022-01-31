@isTest
private class nysDohGetAccountsDataTest {

    @TestSetup
    static void setup(){
        Account acc =  new Account(
        Name = 'Test Account',
        Type = 'Testing Site'
       );
       insert acc;
    }
   
   @isTest static void getAccountsTest(){
   List<Account> accList = nysDohGetAccountsData.getAllTestAccounts();
   System.assertEquals(accList[0].Name,'Test Account');
   } 
}