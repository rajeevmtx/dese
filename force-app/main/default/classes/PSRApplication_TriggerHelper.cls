public with sharing class PSRApplication_TriggerHelper {
   public static void insertApplicationDocumentRecords(List<Application__c> applicationList){
       List<Application_Document__c> applicationDocuments = new List<Application_Document__c>();
       for(Application__c application :applicationList){
           Application_Document__c Ad1 = new Application_Document__c();
           Ad1.Document_Name__c ='Driver License';
           Ad1.Application__c =application.id;
           Ad1.Status__c = 'Draft';
           applicationDocuments.add(Ad1);
           Application_Document__c Ad2 = new Application_Document__c();
           Ad2.Document_Name__c ='Birth Certificate';
           Ad2.Application__c =application.id;
           Ad2.Status__c = 'Draft';
           applicationDocuments.add(Ad2);
       }
       if(applicationDocuments.size()>0){
           insert applicationDocuments;
       }

   }
   
   public static void insertApplicationContacts(List<Application__c> applicationList){
       Contact contact = new Contact();
       
       for(User user : [SELECT Contact.Id, Contact.Account.Name FROM User WHERE Id =: UserInfo.getUserId()]){
           contact = user.Contact;
       }
       
       if(contact.Id == null){
           return;
       }
       
       List< Application_Contacts__c> applicationContacts = new List< Application_Contacts__c>();
       
       for(Application__c application : applicationList){
           applicationContacts.add(new Application_Contacts__c(Contact__c = contact.Id, Application__c = application.Id,
                                                               Company_Name__c = contact.Account.Name, Contact_Type__c = 'Contractor'));
       }
       
       if(applicationContacts.size()>0){
           insert applicationContacts;
       }

   }
}