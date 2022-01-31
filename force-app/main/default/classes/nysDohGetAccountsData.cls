public with sharing class nysDohGetAccountsData {
    @AuraEnabled
    public static List<Account> getAllTestAccounts(){
        return [Select Id, Name FROM Account WHERE Type = 'Testing Site'];
    }
}