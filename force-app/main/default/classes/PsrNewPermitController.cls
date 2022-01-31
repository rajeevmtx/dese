public class PsrNewPermitController {
    //Method Create new Application Record
    @AuraEnabled
    public static Id addNewApplication(String permitType){
        try{
            Id selfAssessmentRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Self_Assessment_Application').getRecordTypeId();

            User currentUser = [SELECT Id, Contact.AccountId, Contact.Account.Account_Type__c,Contact.Account.Account_Status__c FROM User WHERE Id =: UserInfo.getUserId()];
            Application__c app = new Application__c();
            app.Status__c = 'Draft';
            app.Current_Step__c = 1;
            app.Permit_Type__c = permitType;
            app.RecordTypeId = selfAssessmentRecordTypeId;
            app.Applicant_Account__c = currentUser.Contact.AccountId;
            insert app;
            if(currentUser.Contact.Account.Account_Status__c == 'Registered'){
                Account acc = new Account(Id=currentUser.Contact.AccountId);
                acc.Account_Status__c = 'New application in progress';
                update acc;
            }
            

            return app.Id;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
	
    @AuraEnabled
    public static Boolean isProvider(){
        return [SELECT Contact.Account.Account_Type__c FROM User WHERE Id =: UserInfo.getUserId()].Contact.Account.Account_Type__c == 'Provider';
    }
    
    @AuraEnabled
    public static Boolean isLicensed(){
        return [SELECT Contact.Account.Account_Type__c FROM User WHERE Id =: UserInfo.getUserId()].Contact.Account.Account_Type__c == 'Licensed';
    }

    @AuraEnabled
    public static Boolean isFosterCare(){
        return [SELECT Contact.Account.Account_Type__c FROM User WHERE Id =: UserInfo.getUserId()].Contact.Account.Account_Type__c == 'Foster Care';
    }

    @AuraEnabled
    public static Integer getCurrentStep(Id appId){
        return (Integer)[SELECT Current_Step__c FROM Application__c WHERE Id =: appId].Current_Step__c;
    }

    @AuraEnabled
    public static String getAppNumber(Id appId){ 
        return (String)[SELECT Name FROM Application__c WHERE Id =: appId].Name;
    }

    @AuraEnabled
    public static Id addAppContact(String AppId, String ContactId){
        try{
            Application_Contacts__c appCon = new Application_Contacts__c();
            appCon.Application__c=AppId;
            appCon.Contact__c=ContactId;
            insert appCon;
            return appCon.Id;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void submitApplication(Id appId){
        try{
           Application__c appRec = [SELECT Id, Status__c FROM Application__c WHERE Id =:appId];
           appRec.Status__c = 'Submitted';
           appRec.Issue_Date__c = Date.today();
           appRec.Expiration_Date__c = Date.today().addYears(2);
           update appRec; 
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String checkFormCriteria(){
        try {
            User u = [SELECT ID,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Contact con = [SELECT ID,Account.Form_1_Criteria__c, Account.Form_2_Criteria__c,Account.Account_Status__c FROM Contact WHERE Id = :u.ContactId];
            if(con.Account.Account_Status__c == 'Registered' || con.Account.Account_Status__c == 'New application in progress' || con.Account.Account_Status__c == 'Current' || con.Account.Account_Status__c == 'Application Withdrawn / Closed'){
                return 'Form1';
            } 
            if(con.Account.Account_Status__c == 'Expired' || con.Account.Account_Status__c == 'Renewal in progress' || con.Account.Account_Status__c == 'Program Status under review'){
                return 'Form2';
            }
            if(con.Account.Account_Status__c == 'Closed'){
                return 'Form12';
            }
            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}