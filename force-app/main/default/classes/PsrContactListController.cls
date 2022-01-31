/**
 * Created by ashishPandey on 22-01-2020.
 */
public without sharing class PsrContactListController {
    @AuraEnabled(cacheable=true)
    public static list<ActionContactWrapper> getAllContacts(Id applicationId, String recordTypeName) {
        List<ActionContactWrapper> actionContactWrapperList = new List<ActionContactWrapper>();
        for(Application_Contacts__c apc : [SELECT Id, Contact__c, Contact__r.AccountId, Contact__r.Status__c, Contact__r.FirstName, Contact__r.LastName,Contact__r.Name, Contact__r.Start_Date__c , Contact__r.Prof_Qualification_Reg_Number__c, Contact__r.Comments__c, Contact__r.Title ,Contact__r.Email, Contact__r.Phone,Enrollment_Number__c, Contact_Type__c, Company_Name__c FROM Application_Contacts__c WHERE Application__c =: applicationId AND Contact__c != null AND Contact__r.RecordType.Name=:recordTypeName ORDER BY CreatedDate desc]) {
            actionContactWrapperList.add(new ActionContactWrapper(apc));
        }
        return actionContactWrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static ActionContactWrapper getApplicationContact(Id applicationContactId) {
        ActionContactWrapper actionContactWrapper = new ActionContactWrapper(new Application_Contacts__c());
        for(Application_Contacts__c apc : [SELECT Id, Contact__c, Contact__r.AccountId, Contact__r.Status__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Start_Date__c , Contact__r.Prof_Qualification_Reg_Number__c, Contact__r.Comments__c, Contact__r.Title,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact_Type__c, Company_Name__c,Enrollment_Number__c FROM Application_Contacts__c WHERE Id =: applicationContactId AND Contact__c != null ORDER BY CreatedDate desc]) {
            actionContactWrapper = new ActionContactWrapper(apc);
        }
        return actionContactWrapper;
    }
    @AuraEnabled
    public static String createContact(String jsonString, String recordTypeName) {
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Savepoint sp = Database.setSavepoint();
        try{
            ActionContactWrapper actionContactWrapper = (ActionContactWrapper)JSON.deserialize(jsonString,ActionContactWrapper.class);
            Account selectedAccount = new Account();
            if(String.isNotBlank(actionContactWrapper.accountId))
                selectedAccount.Id = actionContactWrapper.accountId;
            if(String.isNotBlank(actionContactWrapper.companyName))    
            selectedAccount.Name = actionContactWrapper.companyName;
            else
            selectedAccount.Name = actionContactWrapper.firstName+' '+actionContactWrapper.lastName+' Account';
            selectedAccount.OwnerId = System.Label.AdminUserId;
            System.debug(selectedAccount.OwnerId);
            upsert selectedAccount;
            Contact selectedContact = new Contact();
            if(String.isNotBlank(actionContactWrapper.contactId))
                selectedContact.Id = actionContactWrapper.contactId;
            selectedContact.FirstName = actionContactWrapper.firstName;
            selectedContact.LastName = actionContactWrapper.lastName;
            selectedContact.Email = actionContactWrapper.email;
            selectedContact.Phone = actionContactWrapper.phone;
            selectedContact.AccountId = selectedAccount.Id;
            selectedContact.Title = actionContactWrapper.title;
            selectedContact.Comments__c = actionContactWrapper.comments;
            selectedContact.RecordTypeId = recordTypeId;
            selectedContact.Prof_Qualification_Reg_Number__c = actionContactWrapper.elarNumber;
            selectedContact.Start_Date__c = actionContactWrapper.hireDate;
            selectedContact.Status__c = actionContactWrapper.status;
            upsert selectedContact;
            Application_Contacts__c applicationContact = new Application_Contacts__c();
            if(String.isNotBlank(actionContactWrapper.id))
                applicationContact.id = actionContactWrapper.id;
            else
                applicationContact.Application__c = actionContactWrapper.applicationId;
            applicationContact.Contact_Type__c = actionContactWrapper.type;
            applicationContact.Company_Name__c = actionContactWrapper.companyName;
            applicationContact.Enrollment_Number__c = actionContactWrapper.enrollmentnumber;
            applicationContact.Contact__c = selectedContact.Id;
            upsert applicationContact;
            //System.debug(selectedAccount.OwnerId);
            //System.debug('====='+[SELECT Id,USERRoleId FROM User WHERE Id =: System.Label.AdminUserId].USERRoleId);
            /* List<User> userList = [SELECT Id FROM User WHERE ContactId = : selectedContact.Id AND ContactId != null];
            if(userList.isEmpty() ) {
                List<Profile> profileList = [SELECT Id FROM Profile WHERE Name = 'Permitting Community User' LIMIT 1];
                if(profileList.size() > 0) {
                    User newUser = new User();
                    newUser.firstName = selectedContact.firstName;
                    newUser.lastName = selectedContact.lastName;
                    newUser.ContactId = selectedContact.Id;
                    newUser.Username = selectedContact.email;
                    newUser.Email = selectedContact.email;
                    // newUser.CommunityNickname = 'nickname';
                    // newUser.Alias = '';
                    newUser.communityNickname = (selectedContact.LastName.length() > 30 ? selectedContact.LastName.substring(0,30) :  selectedContact.LastName) + '_' + Integer.valueOf(Math.random()*1000000);
                    newUser.alias = string.valueof(selectedContact.FirstName.substring(0,1) + selectedContact.LastName.substring(0,1) + Integer.valueOf(Math.random()*1000000) );
                    newUser.ProfileId = profileList[0].id;
                    newUser.TimeZoneSidKey = 'America/Phoenix'; // Required
                    newUser.LocaleSidKey = 'en_US'; // Required
                    newUser.EmailEncodingKey = 'ISO-8859-1'; // Required
                    newUser.LanguageLocaleKey = 'en_US'; // Required
                    insert newUser;
                }
            } */
        } catch(DMLException ex) {
            Database.rollback( sp );
            return ex.getDmlMessage(0);
        } catch(Exception ex) {
            Database.rollback( sp );
            return ex.getMessage();
        }
        return 'success';
    }
    @AuraEnabled
    public static Contact getContact(String email) {
        Contact contact = new Contact();
        for(Contact selectedContact : [SELECT Id, Phone, Email, FirstName, LastName, AccountId, Account.Name FROM Contact WHERE Email =: email AND AccountId != null LIMIT 1]) {
            contact = selectedContact;
        }
        return contact;
    }
    public class ActionContactWrapper {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String phone {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String companyName {get;set;}
        @AuraEnabled public String contactId {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String applicationId {get;set;}
        @AuraEnabled public String enrollmentnumber{get;set;}
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public Date hireDate {get; set;}
        @AuraEnabled public String comments {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String elarNumber {get; set;}
        public ActionContactWrapper(Application_Contacts__c apc) {
            this.name = apc.Contact__r.Name;
            this.firstName = apc.Contact__r.FirstName;
            this.lastName = apc.Contact__r.LastName;
            this.email = apc.Contact__r.Email;
            this.phone = apc.Contact__r.Phone;
            this.type = apc.Contact_Type__c;
            this.companyName = apc.Company_Name__c;
            this.contactId = apc.Contact__c;
            this.accountId = apc.Contact__r.AccountId;
            this.enrollmentnumber = apc.Enrollment_Number__c;
            this.id = apc.Id;
            this.comments = apc.Contact__r.Comments__c;
            this.status = apc.Contact__r.Status__c;
            this.elarNumber = apc.Contact__r.Prof_Qualification_Reg_Number__c;
            this.title = apc.Contact__r.Title;
        }
    }
}