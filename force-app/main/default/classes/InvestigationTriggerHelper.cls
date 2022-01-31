public class InvestigationTriggerHelper {
    public static final String CONFIG_TYPE_APPLICATION = 'Investigation';

    public static void run() {

        if( Trigger.isAfter && Trigger.isInsert ){
            createDueDiligence();
            createInvestigationItems();
        }
    }

    private static void createDueDiligence() {
        List<Investigation__c> assessments = (List<Investigation__c>)Trigger.New;

        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
        
        for(Due_Diligence_Config__c config : [SELECT Due_Diligence_Name__c, Due_Diligence_Unique_API_Name__c, Help_Text__c, Is_Active__c, Responsible_Party__c, Sequence__c,Reference_Link__c
                                                FROM Due_Diligence_Config__c
                                                WHERE Object_Type__c = :CONFIG_TYPE_APPLICATION
                                                AND Is_Active__c = true]) {

            for(Investigation__c assessment : assessments) {
                Due_Diligence__c newDueDiligence = new Due_Diligence__c();
                newDueDiligence.Investigation__c = assessment.Id;
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

    public static void createInvestigationItems() {
        List<Investigation__c> investigationList = (List<Investigation__c>)Trigger.New;
       
        List<Tool_Item__c> toolItemsList = new List<Tool_Item__c>(); 
        set<Id> newInvestigationsIds = new Set<Id>();
        set<String> permitType = new set<String>();
        Map<Id,String> investigationToPermitType = new Map<Id,String>();

       for(Tool_Item__c toolItem:[SELECT Id,Category__c,Description__c, Item_Name__c
                                  FROM Tool_Item__c WHERE Tool__r.Permit_Type__c = 'Child Welfare Investigation']){

            toolItemsList.add(toolItem);                                       
        }
        
        
        List<Investigation_Item__c> investigationItemList = new List<Investigation_Item__c>();

        if(!toolItemsList.isEmpty()){
           for(Investigation__c investigation : investigationList){
                for(Tool_Item__c toolItem : toolItemsList){
                    Investigation_Item__c investigationItem = new Investigation_Item__c();
                    investigationItem.Category__c = toolItem.Category__c;
                    investigationItem.Investigation_Item_Name__c = toolItem.Item_Name__c;
                    investigationItem.Investigation__c = investigation.Id;                        
                    investigationItemList.add(investigationItem);
                }
           } 
        }       
       
        if(investigationItemList.size()>0){
            insert investigationItemList;
        }
    }
}