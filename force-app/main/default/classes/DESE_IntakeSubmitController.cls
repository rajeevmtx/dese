public  class DESE_IntakeSubmitController {
    

    @AuraEnabled
    public static String updateProjectStatus(String projectId){
        try {
            Project__c newProject = [SELECT ID,Program_Version__c FROM Project__c WHERE Id =:projectId];
            Program_version__c pv = [SELECT ID,(SELECT ID,Name FROM Solicitation__r) FROM program_version__c WHERE Id =:newProject.Program_Version__c];
            newProject.Solicitation_Round__c = pv.Solicitation__r[0].Id;
            newProject.Status__c = 'Submitted';
            update newProject;
            Project__c project = [SELECT ID,Name FROM Project__c WHERE Id = :projectId];
            return project.Name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}