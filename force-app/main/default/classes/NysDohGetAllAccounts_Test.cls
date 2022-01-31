@isTest
public class NysDohGetAllAccounts_Test {
    @TestSetup
    static void makeData(){
        Account createAccount = new Account();
        createAccount.Name = 'TestAccount';
        createAccount.Type = 'Testing Site';
        insert createAccount;
    }
    @isTest
    static void getAllTestAccountsTest(){
        List<Account> accountList = NysDohGetAllAccounts.getAllTestAccounts();
        System.debug('accountList >>>>' + accountList);
        System.assertEquals(!accountList.isEmpty(), true);
    }
    
    
}