public class NysDohGetAllAccounts {
    @AuraEnabled (cacheable=true)
    public static List<Account> getAllTestAccounts(){
        return [Select Id, Name FROM Account WHERE Type = 'Testing Site'];
    }
}