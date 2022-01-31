public class NYSDOH_InventoryController {
    
    @AuraEnabled
    public static  List<Equipment__c> fetchInventory(){
        User currentUser = getCurrentUser();
        Id accountId = currentUser.AccountId;

        return [Select id,Available_Quantity__c,Equipment_Type__c,Used_Quantity__c,Total_Quantity__c,Usage_Quantity__c
             from Equipment__c Where Health_Care_Facility__c =: accountId Order by Equipment_Type__c ASC];
    }
    @AuraEnabled
    public static  String updateInventory(List<Equipment__c> equipmentList){
        try{
            update equipmentList;
            return 'success';
        } catch(DMLException ex) {
            return ex.getDMLMessage(0);
        }
    }

    private static User getCurrentUser() {
        User currentUser = [SELECT Id, Name, AccountId, ContactId, Profile.Name FROM User WHERE Id =:UserInfo.getUserId()];
        return currentUser;
    }
}