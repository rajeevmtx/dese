public class UserInfoDetails {
    @AuraEnabled
    public static String getUserDetails() {
        return  [Select Id , Name ,Email from User where Id =:UserInfo.getUserId()].Name;
    }
    @AuraEnabled
    public static String fetchUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static String getAccountName() {
         return [SELECT Id, Name, Contact.Account.Name FROM User WHERE Id=:UserInfo.getUserId()].Contact.Account.Name; 
    }

    @AuraEnabled
    public static status getStatus(){
        
        status statusRecord = new status();
        for(Volunteer__c vol : [SELECT Id, Status__c FROM Volunteer__c]){
            if(vol.Status__c == 'Submitted'){
                statusRecord.Submitted++;
            }else if(vol.Status__c == 'Available'){
                statusRecord.Available++;
            }else if(vol.Status__c == 'Not Available'){
                statusRecord.NotAvailable++;
            }
        }
        

        return statusRecord;
    }

    public class status{
        @AuraEnabled public Integer Submitted;
        @AuraEnabled public Integer Available;
        @AuraEnabled public Integer NotAvailable;
        public status(){
            Submitted = 0;
            Available=  0;
            NotAvailable = 0;
        }
    }
}