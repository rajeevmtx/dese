public with sharing class DESE_SwitchController {

    @AuraEnabled
    public static string getToolsList(String recordId){
        try {
            Inspection__c inspection = [SELECT ID,Application__r.Permit_Type__c,Justification__c,Tool__c,Tool__r.Name,Inspection_Status__c FROM Inspection__c WHERE ID =:recordId];
            List<Tool__c> toolList = [SELECT Id,Name,(SELECT ID FROM Tool_items__r) FROM Tool__c WHERE Active__c = true  and Id != :inspection.Tool__c];//and Permit_Type__c = :inspection.Application__r.Permit_Type__c
            List<Tool__c> availableTools = new List<Tool__c>();
            for(Tool__c tool : toolList){
                if(tool.Tool_items__r.size() > 0){
                    availableTools.add(tool);
                }
            }
            SwitchWrapper wrapper = new SwitchWrapper();
            wrapper.inspectionRecord = inspection;
            wrapper.toolList = new List<Tool__c>();
            wrapper.toolList.addAll(availableTools);
            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateInspectionTool(String recordId, String toolId, String justify){
        try {
            Inspection__c inspection = new Inspection__c(Id=recordId);
            inspection.Tool__c = toolId;
            inspection.Justification__c = justify;
            update inspection;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    public class SwitchWrapper{
        @AuraEnabled
        public Inspection__c inspectionRecord;
        @AuraEnabled
        public List<Tool__c> toolList;
    }


}