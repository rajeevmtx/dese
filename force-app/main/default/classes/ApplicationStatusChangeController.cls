public class ApplicationStatusChangeController {
	@AuraEnabled
    public static void changeStatus(String appId) {
        if(String.isNotBlank(appId)){
         	Project__c project = new Project__c();
            project.Id = appId;
            project.Status__c = 'Payment Processed';
            update project;   
        }
    }
}