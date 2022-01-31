public without sharing class DESE_UserRegistrationController {

    @AuraEnabled
    public static string createPortalUser( String wrapperJSON){
        try {
            WrapperClass wrapper = (WrapperClass)JSON.deserialize(wrapperJSON, WrapperClass.class);
            List<User> existingUser = [SELECT ID FROM User WHERE Email = :wrapper.email];
            if(!existingUser.isEmpty()){
                return 'The Email Address you are trying to register with already has an account';
            }
            Account acc;
            List<Account> accList = [SELECT ID FROM Account WHERE Name = :wrapper.orgName];
            if(!accList.isEmpty()){
                acc = accList[0];
            } else{
                acc = new Account();
                Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('School').getRecordTypeId();
                acc.Name = wrapper.orgName;
                acc.RecordTypeId = accRecType;
                acc.Account_Status__c = 'TBD';
                acc.Account_Type__c = 'Provider';
                acc.OwnerId = '0053i000001y4vbAAA';
                acc.Monitoring_Lifecycle__c = 'Not Started';
                acc.Name_of_the_Person_to_Contact__c = wrapper.email;
                insert acc;
            }
            Id conRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();

            Contact con = new Contact();
            con.RecordTypeId = conRecType;
            con.FirstName = wrapper.firstName;
            con.LastName = wrapper.lastName;
            con.Email = wrapper.email;
            con.Phone = wrapper.phone;
            con.MailingStreet = wrapper.street;
            con.MailingCity = wrapper.city;
            con.MailingState = wrapper.state;
            con.MailingCountry = wrapper.country;
            con.MailingPostalCode = wrapper.postalcode;
            con.AccountId = acc.Id;

            insert con;

            Profile prof = [select id,userType from Profile where name='Permitting Community User' limit 1];

            String alias = (wrapper.firstName != null ? wrapper.firstName.substring(0,1).toUpperCase() :'') + 
                (wrapper.lastName.length() > 6 ? wrapper.lastName.substring(0,6) : wrapper.lastName);

            String nickname = ((wrapper.firstName != null && wrapper.firstName.length() > 0) ? wrapper.firstName.substring(0,1) : '' ) + wrapper.lastName.substring(0,1);
            nickname        = nickname + String.valueOf(Crypto.getRandomInteger()).substring(1,7);

            User userObj = new User(
                Username   = wrapper.email+'.mtxdese',
                Email      = wrapper.email,
                FirstName  = wrapper.firstName,
                LastName   = wrapper.lastName,
                Phone      = wrapper.phone,
                //Alternate_Contact_Number__c = wrapper.alternateContact,
                //SMS_Communication__c = wrapper.smsCommunication,
                //Email_Communication__c = wrapper.emailCommunication,
                MobilePhone= wrapper.phone,
                //Birthdate__c = wrapper.userBirthdate,
                ProfileId = prof.id,
                contactId = con.Id,
                emailEncodingKey  = 'UTF-8',
                languageLocaleKey ='en_US',
                localesIdKey = 'en_US',
                alias = alias,
                CommunityNickname= nickname,
                TimeZoneSidKey='America/Los_Angeles',
                Street = wrapper.street,
                City = wrapper.city, 
                State = wrapper.state,
                Country = wrapper.country, 
                PostalCode =wrapper.postalCode 
                 //Gender__c =wrapper.gender,
                //COT_GenderPronoun__c =wrapper.pronoun
            );

            String networkId = Network.getNetworkId();
            /**If using site to host the community the user should not hit s1 after logging in from mobile. */
            if(networkId != null && siteAsContainerEnabled(networkId)) userObj.put('UserPreferencesHideS1BrowserUI',true);
            INSERT userObj;
            return '';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static boolean siteAsContainerEnabled(Id networkId) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    

    public class WrapperClass{
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String street;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String postalcode;
        @AuraEnabled
        public String orgName;
    }

}