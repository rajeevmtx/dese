public class AssessmentTriggerHelper {
    public static final String CONFIG_TYPE_APPLICATION = 'Assessment';

    public static void run() {

        if( Trigger.isAfter && Trigger.isInsert ){
            createDueDiligence();
        }
    }

    private static void createDueDiligence() {
        List<Assessment__c> assessments = (List<Assessment__c>)Trigger.New;

        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
        
        for(Due_Diligence_Config__c config : [SELECT Due_Diligence_Name__c, Due_Diligence_Unique_API_Name__c, Help_Text__c, Is_Active__c, Responsible_Party__c, Sequence__c,Reference_Link__c
                                                FROM Due_Diligence_Config__c
                                                WHERE Object_Type__c = :CONFIG_TYPE_APPLICATION
                                                AND Is_Active__c = true]) {

            for(Assessment__c assessment : assessments) {
                Due_Diligence__c newDueDiligence = new Due_Diligence__c();
                newDueDiligence.Assessment__c = assessment.Id;
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
        
        if(!dueDiligenceList.isEmpty()) {
            insert dueDiligenceList;
        }
    }
}