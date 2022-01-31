public with sharing class APS_InvestigationModeController {
    @AuraEnabled
    public static List<Investigation_Item__c> getInvestigationItemsRecords(String idField){
        List<Investigation_Item__c> investigationItemList = new List<Investigation_Item__c>();
        investigationItemList = [SELECT Id, Name, Investigation_Item_Name__c, Category__c,
                                Result__c, Observations__c, Investigation__r.Status__c 
                                FROM Investigation_Item__c WHERE Investigation__c = :idField ORDER BY Category__c];
        return investigationItemList;
    }

    @AuraEnabled
    public static void updateInvestigationItemsRecords(String category, String result, String observation,String idField){
        List<Investigation_Item__c> investigationItemList = new List<Investigation_Item__c>();
        if(category == null || category == ''){
            investigationItemList=[SELECT Category__c,Result__c,Observations__c FROM Investigation_Item__c
                                WHERE Result__c='' AND Investigation__c = :idField];
        }
        else{
            investigationItemList=[SELECT Category__c,Result__c,Observations__c FROM Investigation_Item__c
                                WHERE Result__c='' AND Category__c = :category AND Investigation__c = :idField];
        }

        for(Investigation_Item__c investigationItem : investigationItemList){
            investigationItem.Result__c = result;
            investigationItem.Observations__c = observation;
        }

        if(investigationItemList.size()>0){
            update investigationItemList;
        }
    }
    @AuraEnabled
    public static List<ContentDocumentLink> viewAllFiles(String expenseItemId){
        List<ContentDocumentLink> fileList = new List<ContentDocumentLink>();
        fileList = [SELECT ContentDocumentId,ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink 
                    WHERE LinkedEntityId in ( SELECT Id FROM Investigation_Item__c WHERE Id= :expenseItemId ) 
                    AND LinkedEntity.Type='Investigation_Item__c'];
        if(fileList.size()>0){
            return fileList;
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static List<Investigation_Item__c> filterInvestigationItemsRecords(String category, String result, String type,String idField){
        List<Investigation_Item__c> investigationItemList = new List<Investigation_Item__c>();
        if(type == 'result'){
            investigationItemList=[SELECT Id, Name, Investigation_Item_Name__c, Category__c,
                                Result__c, Observations__c,Investigation__r.Status__c 
                                FROM Investigation_Item__c
                                WHERE Result__c = :result AND Investigation__c = :idField];
        }
        else if(type == 'category'){
            investigationItemList=[SELECT Id, Name, Investigation_Item_Name__c, Category__c,
                                Result__c, Observations__c,Investigation__r.Status__c 
                                FROM Investigation_Item__c
                                WHERE Category__c = :category AND Investigation__c = :idField];
        }

        return investigationItemList;
    }
     
    @AuraEnabled
    public static void investigationComplete(String idField){
        update new Investigation__c(Id = idField, Status__c = 'In Progress', Close_Reason__c = 'Investigation Completed');
    }
}