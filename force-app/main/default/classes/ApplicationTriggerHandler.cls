public without sharing class ApplicationTriggerHandler {
    public static final String CONFIG_TYPE_APPLICATION = 'Application';
    public static final String APPLICATION_STATUS_APPROVED = 'Approved';
    public static final String NOTIFY_SUBCONTRACTOR = 'Yes';
    public static final String DUE_DILIGENCE_UNIQUE_API_NAME = 'Applicant_submits_permit_application';

    public static void beforeUpdate(List<Application__c> newList){
        populateAgencyStaffandInspector(newList);       
    }
    public static void populateContactEmail(List<Application__c> newList){
        String contactEmail;    
       for(User user : [SELECT Contact.Id, Contact.Account.Name, Contact.Email, Contact.Account.Account_Type__c 
                        FROM User WHERE Id =: UserInfo.getUserId()]){
                            contactEmail = user.Contact.Email;
       }
       System.debug('contactEmail>'+contactEmail);
        for(Application__c applicationRec:newList){  
            applicationRec.Creator_User_Contact_Email__c = contactEmail;
        }        
    }
    public static void populateAgencyStaffandInspector(List<Application__c> newList){ 
       
        for(Application__c applicationRec:newList){
            applicationRec.Agency_Staff__c = System.Label.Permit_Agency_Staff_User;
            applicationRec.Inspector__c  = System.Label.Permit_Inspector_User;      
        }        
    }
    
    
    public static void createDueDiligence(List<Application__c> appList) {
        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
		Due_Diligence__c newDueDiligence;
        for(Due_Diligence_Config__c config : [SELECT Due_Diligence_Name__c, Due_Diligence_Unique_API_Name__c, Help_Text__c, Is_Active__c, Responsible_Party__c, Sequence__c,Reference_Link__c
                                                FROM Due_Diligence_Config__c
                                                WHERE Object_Type__c = :CONFIG_TYPE_APPLICATION
                                                AND Is_Active__c = true]) {
            for(Application__c app : appList) {
                newDueDiligence = new Due_Diligence__c();
                newDueDiligence.Application__c = app.Id;
                newDueDiligence.Due_Diligence_Name__c = config.Due_Diligence_Name__c;
                newDueDiligence.Due_Diligence_Unique_API_Name__c = config.Due_Diligence_Unique_API_Name__c;
                newDueDiligence.Is_Active__c = config.Is_Active__c;
                newDueDiligence.Responsible_Party__c = config.Responsible_Party__c;
                newDueDiligence.Sequence__c = config.Sequence__c;
                newDueDiligence.Reference_Link__c = config.Reference_Link__c;
                newDueDiligence.Help_Text__c = config.Help_Text__c;
                dueDiligenceList.add(newDueDiligence);
            }
        }
        
       // system.assert(false,dueDiligenceList);
        if(!dueDiligenceList.isEmpty()) {
            insert dueDiligenceList;
        }
    }

    public static void sendNotification(List<Application__c> newApplicationList) {
        Set<Id> appIdSet = new Set<Id>();
        List<Application_Work_Order__c> workOrdersList = new List<Application_Work_Order__c>();
        for(Application__c appRec : newApplicationList) {
            appIdSet.add(appRec.Id);
        }

        for(Application_Work_Order__c workOrderRec : [SELECT Id, Send_Notification__c, Application_Contact_Email__c, Application_Contact__r.Contact__r.Email
                                                        FROM Application_Work_Order__c
                                                        WHERE Application__c IN :appIdSet
                                                        AND Notify_Subcontractor__c = :NOTIFY_SUBCONTRACTOR
                                                        AND Application__r.Status__c = :APPLICATION_STATUS_APPROVED]) {
            Application_Work_Order__c newWorkOrder = new Application_Work_Order__c();
            newWorkOrder.Id = workOrderRec.Id;
            newWorkOrder.Send_Notification__c = true;
            newWorkOrder.Application_Contact_Email__c = workOrderRec.Application_Contact__r.Contact__r.Email;
            workOrdersList.add(newWorkOrder);
        }
        System.debug('wordkOrdersList here '+workOrdersList);
        if(!workOrdersList.isEmpty()){
            update workOrdersList;
        }
    }
    
    public static void insertApplicationDocumentRecords(List<Application__c> applicationList){
       List<Application_Document__c> applicationDocuments = new List<Application_Document__c>();
       for(Application__c application :applicationList){
           Application_Document__c Ad1 = new Application_Document__c();
           Ad1.Document_Name__c ='Progress Reports and content';
           Ad1.Application__c =application.id;
           Ad1.Status__c = 'Draft';
           applicationDocuments.add(Ad1);
           Application_Document__c Ad2 = new Application_Document__c();
           Ad2.Document_Name__c ='Screening Report';
           Ad2.Application__c =application.id;
           Ad2.Status__c = 'Draft';
           applicationDocuments.add(Ad2);
           Application_Document__c Ad3 = new Application_Document__c();
           Ad3.Document_Name__c ='IEP development and content';
           Ad3.Is_Required__c = true;
           Ad3.Application__c =application.id;
           Ad3.Status__c = 'Draft';
           applicationDocuments.add(Ad3);
           Application_Document__c Ad4 = new Application_Document__c();
           Ad4.Document_Name__c ='Resolution of disputes';
           Ad4.Application__c =application.id;
           Ad4.Status__c = 'Draft';
           applicationDocuments.add(Ad4);
           Application_Document__c Ad5 = new Application_Document__c();
           Ad5.Document_Name__c ='Transfer of student records';
           Ad5.Application__c =application.id;
           Ad5.Status__c = 'Draft';
           Ad5.Is_Required__c = true;
           applicationDocuments.add(Ad5);
       }
       if(applicationDocuments.size()>0){
           insert applicationDocuments;
       }

   }
   
   public static void insertApplicationContacts(List<Application__c> applicationList){
       Contact contact = new Contact();
       
       for(User user : [SELECT Contact.Id, Contact.Account.Name, Contact.Email, Contact.Account.Account_Type__c 
                        FROM User WHERE Id =: UserInfo.getUserId()]){
           contact = user.Contact;
       }
       
    
       if(contact != null){
          List< Application_Contacts__c> applicationContacts = new List< Application_Contacts__c>();
          List< Contact> contacts = new List< Contact>();
          Id staffRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Staff').getRecordTypeId();
          Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
          Account studentAccount = new Account();
          for(Account acc : [SELECT Id,Name FROM Account WHERE Name = 'John F. Kennedy School' LIMIT 1]){
            studentAccount = acc;
          }
          if(studentAccount.Id==null){
            studentAccount = new Account(Name = 'John F. Kennedy School');
            insert studentAccount;
          }          
            for(Application__c application : applicationList){
                contacts.add(new Contact(FirstName = 'John', LastName = 'Smith',Title = 'Teacher',AccountId = studentAccount.Id, Status__c = 'Active',Prof_Qualification_Reg_Number__c = 'C45676',RecordTypeId=staffRecordTypeId));
                contacts.add(new Contact(FirstName = 'Mary', LastName = 'Smith',Title = 'Supervisor',AccountId = studentAccount.Id, Status__c = 'Active',Prof_Qualification_Reg_Number__c = 'C45676',RecordTypeId=staffRecordTypeId));
                contacts.add(new Contact(FirstName = 'Paul', LastName = 'Walker',Email = 'paul.walker@jfkschools.com',AccountId = studentAccount.Id, Status__c = 'Active',RecordTypeId=studentRecordTypeId));
                contacts.add(new Contact(FirstName = 'Alan', LastName = 'Walker',Email = 'alan.walker@jfkschools.com',AccountId = studentAccount.Id, Status__c = 'Active',RecordTypeId=studentRecordTypeId));
                
            }
            if(!contacts.isEmpty()){
                insert contacts;
            }

           for(Application__c application : applicationList){
               applicationContacts.add(new Application_Contacts__c(Contact__c = contacts[0].Id, Application__c = application.Id,
                                                                   Company_Name__c = studentAccount.Name));
                applicationContacts.add(new Application_Contacts__c(Contact__c = contacts[1].Id, Application__c = application.Id,
                                                                   Company_Name__c = studentAccount.Name ));
                applicationContacts.add(new Application_Contacts__c(Contact__c = contacts[2].Id, Application__c = application.Id,
                                                                   Company_Name__c = studentAccount.Name, Enrollment_Number__c = 'JFK_001'));
                applicationContacts.add(new Application_Contacts__c(Contact__c = contacts[3].Id, Application__c = application.Id,
                                                                   Company_Name__c = studentAccount.Name, Enrollment_Number__c = 'JFK_002' ));
                applicationContacts.add(new Application_Contacts__c(Contact__c = contact.Id, Application__c = application.Id));
           }
           
           if(!applicationContacts.isEmpty()){
               insert applicationContacts;
           }
    
           if(contact.Account.Account_Type__c == 'Provider'){
                List<Application_Work_Order__c> appWorkOrders = new List<Application_Work_Order__c>();
    
                for(Application_Contacts__c temp :applicationContacts ){
                    appWorkOrders.add(new Application_Work_Order__c(Application__c = temp.Application__c,
                                                                    Application_Contact__c = temp.Id,
                                                                    Application_Contact_Email__c = contact.Email,
                                                                    Notify_Subcontractor__c = 'No',
                                                                    Status__c = 'Ready for Review',
                                                                    Work_Order_Name__c = 'Default Work Order',
                                                                    Work_Order_Type__c = 'General Construction'));
                }
        
                if(!appWorkOrders.isEmpty()){
                    Database.insert(appWorkOrders, false);
                }
           } 
           
       }
       
   }

   public static void updateDueDiligenceStatus(List<Application__c> applicationList){
       System.debug('in updateDueDiligenceStatus method ');
       List<Due_Diligence__c> updateDueDiligenceList = new List<Due_Diligence__c>();
       for(Due_Diligence__c dueDiligence : [SELECT Id,Status__c,Application__c,Application__r.Status__c FROM Due_Diligence__c 
                                                  WHERE Application__c IN:applicationList 
                                                  AND Due_Diligence_Unique_API_Name__c =:DUE_DILIGENCE_UNIQUE_API_NAME
                                                  AND Application__r.Status__c = 'Submitted']){
            System.debug('dueDiligence>>>>>'+dueDiligence);
            Due_Diligence__c dd = new Due_Diligence__c();
            dd.Id = dueDiligence.Id;
            dd.Status__c ='Completed';
            dd.Completed_Date__c = Date.today();                                         
            updateDueDiligenceList.add(dd);
        }
        System.debug(updateDueDiligenceList+'updateDueDiligenceList');
        if(!updateDueDiligenceList.isEmpty()){
            update updateDueDiligenceList;
        }
    }
    public static void updateLicenseInformation(List<Application__c> applicationList, Map<Id,Application__c> appliactonMap) {
        List<Account> accountToUpdate = new List<Account>();
        System.debug('updating licenses');
        for(Application__c application : applicationList) {
            System.debug('updating licenses '+(application.Applicant_Account__c != null));
            System.debug('updating licenses '+(application.Status__c == 'Approved'));
            System.debug('updating licenses '+(appliactonMap.get(application.Id).Status__c != application.Status__c));
            System.debug('updating licenses '+(appliactonMap.get(application.Id).Status__c != application.Status__c));
            System.debug('updating licenses '+(application.Issue_Date__c != null));
            System.debug('updating licenses '+(application.Issue_Date__c != appliactonMap.get(application.Id).Issue_Date__c));
            System.debug('updating licenses '+(application.Expiration_Date__c != null));
            System.debug('updating licenses '+(application.Expiration_Date__c != appliactonMap.get(application.Id).Expiration_Date__c));
            if(application.Applicant_Account__c != null && application.Status__c == 'Approved'  && appliactonMap.get(application.Id).Status__c != application.Status__c &&
            (application.Issue_Date__c != null  || application.Expiration_Date__c != null )) {
                Account selectedAccount = new Account();
                selectedAccount.Id = application.Applicant_Account__c;
                selectedAccount.First_Issue_Date__c = application.Issue_Date__c;
                selectedAccount.Last_Issue_Date__c = application.Issue_Date__c;
                selectedAccount.Renewal_date__c = application.Expiration_Date__c;
                accountToUpdate.add(selectedAccount);
            }
        }
        if(accountToUpdate.size() > 0) {
            update accountToUpdate;
        }
    }
}