public with sharing class EEC_TransactionRoutingController {
    public string memberId{get;set;}
    public EEC_TransactionRoutingController(){
        List<Account> tempAccount = [Select Id,OwnerID From Account Where ID in(Select Accountid From User Where id = :Userinfo.getUserId()) Limit 1];
        if (tempAccount != null && tempAccount.size() == 1) {
            memberId = tempAccount.get(0).Id;
        } 
    }
}