public without sharing class DESE_IntakeSchoolController {

    @AuraEnabled
    public static String upsertSchool(Project_Content__c sch, Id projectId){
        try {
            sch.recordTypeId = '012030000000kQNAAY'; //Private School Service
            sch.Project__c = projectId;
            upsert sch;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Project_Content__c> getSchools(Id projectId){
        try {

            List<Project_Content__c> Schools =  [SELECT PSS_School_Name__c,PSS_School_Town__c,Participate_in_Title_I__c,Allocation_per_School_for_Service__c,Grades_Served__c,No_Children_in_Title_I_area__c,No_Children_with_low_income__c,Estimate_participant_in_Title_I__c,PSS_Amount_per_Low_Income_Student__c
                FROM Project_Content__c WHERE Project__c = :projectId AND RecordTypeId = '012030000000kQNAAY'];
            
                return Schools;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}