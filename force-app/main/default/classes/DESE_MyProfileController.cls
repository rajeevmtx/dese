public class DESE_MyProfileController {


    @AuraEnabled
    public static string getContactDetails(){
        try {
            User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Contact con = [SELECT Id, FirstName,LastName, Email, Phone, MobilePhone,MailingStreet,District__c,Gender__c, MailingCity, MailingCountry, MailingState, MailingPostalCode FROM Contact WHERE Id = :u.ContactId];
            return JSON.serialize(con);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateContactDetails(String contactJSON){
        try {
            Contact con = (Contact)JSON.deserialize(contactJSON,Contact.class);
            update con;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    


    public class ContactWrapper{
        @AuraEnabled
        public String FirstName;
        @AuraEnabled
        public String LastName;
        @AuraEnabled
        public String Email;
        @AuraEnabled
        public String Phone;
        @AuraEnabled
        public String strStreet;
        @AuraEnabled
        public String strCity;
        @AuraEnabled
        public String strState;
        @AuraEnabled
        public String strCountry;
        @AuraEnabled
        public String strPostalCode;
    }


}