public with sharing class InspectionItemsController {
    @AuraEnabled
    public static List<Inspection_Item__c> getInspectionItemsRecords(String idField){
        List<Inspection_Item__c> inspectionItemList = new List<Inspection_Item__c>();
        inspectionItemList = [SELECT Id, Name, Inspection_Item_Name__c, Regulation__c,Category__c,Regulation_New__c,Regulation_New__r.Name,
                                Result__c, Observations__c, Inspection__r.Inspection_Status_Reason__c 
                                FROM Inspection_Item__c WHERE Inspection__c = :idField];
        return inspectionItemList;
    }

    @AuraEnabled
    public static void updateInspectionItemsRecords(String category, String result, String observation,String idField){
        List<Inspection_Item__c> inspectionItemList = new List<Inspection_Item__c>();
        if(category == null || category == ''){
            inspectionItemList=[SELECT Category__c,Result__c,Observations__c FROM Inspection_Item__c
                                WHERE Result__c='' AND Inspection__c = :idField];
        }
        else{
            inspectionItemList=[SELECT Category__c,Result__c,Observations__c FROM Inspection_Item__c
                                WHERE Result__c='' AND Category__c = :category AND Inspection__c = :idField];
        }

        for(Inspection_Item__c inspectionItem : inspectionItemList){
            inspectionItem.Result__c = result;
            inspectionItem.Observations__c = observation;
        }

        if(inspectionItemList.size()>0){
            update inspectionItemList;
        }
    }
    @AuraEnabled
    public static List<ContentDocumentLink> viewAllFiles(String expenseItemId){
        List<ContentDocumentLink> fileList = new List<ContentDocumentLink>();
        fileList = [SELECT ContentDocumentId,ContentDocument.Title, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Inspection_Item__c WHERE Id= :expenseItemId ) and LinkedEntity.Type='Inspection_Item__c'];
        if(fileList.size()>0){
            return fileList;
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static List<Inspection_Item__c> filterInspectionItemsRecords(String category, String result, String type,String idField){
        List<Inspection_Item__c> inspectionItemList = new List<Inspection_Item__c>();
        if(type == 'result'){
            inspectionItemList=[SELECT Id, Name, Inspection_Item_Name__c, Regulation__c,Category__c,Regulation_New__c,Regulation_New__r.Name,
                                Result__c, Observations__c,Inspection__r.Inspection_Status_Reason__c
                                FROM Inspection_Item__c
                                WHERE Result__c = :result AND Inspection__c = :idField];
        }
        else if(type == 'category'){
            inspectionItemList=[SELECT Id, Name, Inspection_Item_Name__c,Regulation__c, Category__c,Regulation_New__c,Regulation_New__r.Name,
                                Result__c, Observations__c,Inspection__r.Inspection_Status_Reason__c 
                                FROM Inspection_Item__c
                                WHERE Category__c = :category AND Inspection__c = :idField];
        }

        return inspectionItemList;
    }
     
    @AuraEnabled
    public static void inspectionComplete(String idField){
        Inspection__c inspection = [SELECT Id,Inspection_Status_Reason__c 
                                    FROM Inspection__c WHERE Id = :idField LIMIT 1];

        inspection.Inspection_Status__c = '	In Progress';
        inspection.Inspection_Status_Reason__c = 'Inspection Conducted';

        update inspection;
    }

    @AuraEnabled
    public static string getregulationDetails(string regid){
        try {
            Regulation__c reg = [SELECT ID,Applicable_To__c,Article__c,Name,Parent_Regulation__c,Parent_Regulation__r.Name  FROM Regulation__c WHERE Id = :regid];
            return JSON.serialize(reg);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}