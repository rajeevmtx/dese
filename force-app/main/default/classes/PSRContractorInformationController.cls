public class PSRContractorInformationController {
    @AuraEnabled
    public static Account getAccountInformation(){
        return [SELECT Contact.Account.Id FROM User WHERE Id =: UserInfo.getUserId()].Contact.Account;
    }
}