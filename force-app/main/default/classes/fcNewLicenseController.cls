public with sharing class fcNewLicenseController {
    //Method Create new Application Record
    @AuraEnabled
    public static Id addNewApplication(){
        try{
            User currentUser = [SELECT Id, Contact.AccountId, Contact.Account.Account_Type__c FROM User WHERE Id =: UserInfo.getUserId()];
            Application__c app = new Application__c();
            app.Status__c = 'Draft';
            app.Current_Step__c = currentUser.Contact.Account.Account_Type__c != 'Licensed' ? 1 : 0;
            app.recordtypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Foster Care New Application').getRecordTypeId();
            app.Applicant_Account__c = currentUser.Contact.AccountId;
            insert app;
            return app.Id;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String getAppNumber(Id appId){ 
        return (String)[SELECT Name FROM Application__c WHERE Id =: appId].Name;
    }


    @AuraEnabled
    public static void submitApplication(Id appId){
        try{
           Application__c appRec = [SELECT Id, Status__c FROM Application__c WHERE Id =:appId];
           appRec.Status__c = 'Submitted';
           update appRec; 
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String,Object> saveHomeInfo(Id applicationId, String homeContactJson){
        Map<String, Object> result = new Map<String, Object>();

        Application__c appRec = [SELECT Id, Physical_Street_address__c, County__c,City__c, State__c, Zip__c, Same_As_Physical_Address__c, Mailing_address__c,Mailing_City__c, Mailing_State__c,Mailing_Zip_code__c, Zip_code__c   FROM Application__c WHERE Id =:applicationId];
        System.debug('homeContactJson  -- '+ homeContactJson);
        HomeContactInfo homeContactDetails = (HomeContactInfo) JSON.deserialize(homeContactJson, HomeContactInfo.class);
        //HomeContactInfo homeContactDetails = (HomeContactInfo) JSON.deserialize(homeContactJson, HomeContactInfo.class);
        System.debug('homeContactDetails  -- '+ homeContactDetails);
            appRec.Physical_Street_address__c = homeContactDetails.physicalStreet;
            appRec.County__c = homeContactDetails.physicalCounty;
            appRec.City__c = homeContactDetails.physicalCity;
            appRec.State__c = homeContactDetails.physicalState;
            appRec.Zip__c = homeContactDetails.physicalZipCode; 
            appRec.Same_As_Physical_Address__c = homeContactDetails.physicalSameAsMailing ? 'Yes' : 'No';
            if(homeContactDetails.physicalSameAsMailing == false){
                appRec.Mailing_address__c = homeContactDetails.mailingAddress;
                appRec.Mailing_City__c = homeContactDetails.mailingCity;
                appRec.Mailing_State__c = homeContactDetails.mailingState;
                //appRec.Mailing_Zip_code__c =  Integer.valueOf(homeContactDetails.mailingZip);
            }else{
                appRec.Mailing_address__c = appRec.Physical_Street_address__c;
                appRec.Mailing_City__c = appRec.City__c ;
                appRec.Mailing_State__c = appRec.State__c;
                //appRec.Mailing_Zip_code__c =  Integer.valueOf(appRec.Zip__c);
            }
            update appRec; 
            result.put('success','Record Updated');
       
        return result;
    }

    public class HomeContactInfo{
        public String physicalStreet;
        public String physicalCity;
        public String physicalCounty;
        public String physicalState;
        public String physicalZipCode;
        public String mailingAddress;
        public String mailingCity;
        public String mailingState;
        public String mailingZip;
        public String homePhoneNumber;
        public Boolean physicalSameAsMailing;
        
       
       public HomeContactInfo(){
           this.physicalStreet= '';
           this.physicalCity= '';
           this.physicalCounty = '';
           this.physicalState = '';
           this.physicalZipCode= '';
           this.mailingAddress= '';
           this.mailingCity= '';
           this.mailingZip= '';
           this.mailingState= '';
           this.homePhoneNumber= '';
           this.physicalSameAsMailing = false;
       }
   } 
}