public with sharing class PSR_ApplicationWorkOrderController {
    @AuraEnabled
    public static List<RecordWrapper> fetchApplicationContacts(Id appId){
        //I-16144 dhana Prasad added if condition for SubContractors
        List<RecordWrapper> applicationContactsList = new List<RecordWrapper>();
        for(Application_Contacts__c appContact : [SELECT Id, Contact__r.Name, Contact_Type__c
                                                    FROM Application_Contacts__c
                                                    WHERE Application__c = :appId
                                                    AND Contact__c != null
                                                    ]) {
            applicationContactsList.add(new RecordWrapper(appContact));                                  
        }
        return applicationContactsList;
    }
    @AuraEnabled
    public static Application_Work_Order__c fetchWorkOrder(Id workOrderId){ 
        return [SELECT Id, Work_Order_Name__c, Status__c, Application_Contact__r.Contact__r.Name, Last_Notified_Date__c, Work_Order_Type__c, 
                Application__r.Name, Name, Application__r.Status__c, Description__c FROM Application_Work_Order__c WHERE Id = : workOrderId];
    }
    @AuraEnabled
    public static List<RecordWrapper> fetchApplicationWorkOrder(Id appId){        
        List<RecordWrapper> appWorkOrdersList = new List<RecordWrapper>();
        for( Application_Work_Order__c appWorkOrderRec : [Select Id,Work_Order_Name__c,Status__c,Application_Contact__r.Contact__r.Name,Last_Notified_Date__c, Work_Order_Type__c, 
                                                          Application__r.Name, Application__r.Status__c, Name, Description__c from Application_Work_Order__c
                                                            WHERE Application__c = :appId] ){
            appWorkOrdersList.add( new RecordWrapper(appWorkOrderRec) );
        }
        return appWorkOrdersList; 
    }
    @AuraEnabled
    public static String deleteApplicationWorkOrderRecord(Id appWorkOrderId){
        Application_Work_Order__c workOrder = [SELECT Id FROM Application_Work_Order__c WHERE Id = :appWorkOrderId];
        if(workOrder != null) {
            delete workOrder;
            return 'Record deleted successfully';
        }
            return 'There was an error while deleting the record';
    }
    @AuraEnabled
    public static List<Application_Work_Order__c> fetchMyWorkOrders(){  
        List<User> userList = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != null];
        List<Application_Work_Order__c> applicationWorkOrderList = new List<Application_Work_Order__c>();
        if(userList.size() > 0) {
            applicationWorkOrderList = [Select Id,CreatedDate, Application__r.Name, Work_Order_Name__c,Status__c,Application_Contact__r.Contact__r.Name,Last_Notified_Date__c, Work_Order_Type__c, Application__r.Id, Name from Application_Work_Order__c WHERE Application_Contact__r.Contact__c =: userList[0].ContactId ORDER BY CreatedDate DESC];
        }
        return applicationWorkOrderList;
    }
    @AuraEnabled
    public static String updateNotifiedField(Id workOrderId){
        Application_Work_Order__c workOrder = [SELECT Id, Send_Notification__c, Application_Contact__r.Contact__r.Email, Application_Contact_Email__c FROM Application_Work_Order__c WHERE Id = :workOrderId];
        if(workOrder != null) {
            workOrder.Send_Notification__c = true;
            workOrder.Application_Contact_Email__c = workOrder.Application_Contact__r.Contact__r.Email;
            update workOrder;
            return 'Successfully updated';
        }
        return 'There was an error while updating the record';
    }
    @AuraEnabled(cacheable=true)
    public static List<InspectionWrapper> getInspectionList(Id workOrderId){
        Map<Id, Inspection__c> inspectionMap = new Map<Id, Inspection__c>([SELECT Id, Inspection_End_Date__c, Inspection_Start_Date__c, 
                                                                                Application_Work_Order__r.Application__r.Name, 
                                                                                Name, Inspector__r.Name, Number_of_Non_Compliant_items__c,
                                                                                Number_of_Inspection_Items__c
                                                                            FROM Inspection__c
                                                                            WHERE Application_Work_Order__c = :workOrderId]);
        Map<Id, Map<String, List<RecordWrapper>>> inspectionIdInspectionItemMap = new Map<Id, Map<String, List<RecordWrapper>>>();
        List<InspectionWrapper> inspectionWrapperList = new List<InspectionWrapper>();
        List<InspectionItemWrapper> inspectionItemWrapperList;
        for(Inspection_Item__c inspectionItem : [SELECT Id, Category__c, Result__c, Observations__c,
                                                    Correction_Plan__c, Inspection__c
                                                FROM Inspection_Item__c
                                                WHERE Inspection__r.Application_Work_Order__c = :workOrderId
                                                AND Category__c != null]) {
            if(!inspectionIdInspectionItemMap.containsKey(inspectionItem.Inspection__c)) {
                inspectionIdInspectionItemMap.put(inspectionItem.Inspection__c, new Map<String, List<RecordWrapper>>());
            }
            if(!inspectionIdInspectionItemMap.get(inspectionItem.Inspection__c).containsKey(inspectionItem.Category__c)) {
                inspectionIdInspectionItemMap.get(inspectionItem.Inspection__c).put(inspectionItem.Category__c, new List<RecordWrapper>());
            }
            inspectionIdInspectionItemMap.get(inspectionItem.Inspection__c).get(inspectionItem.Category__c).add(new RecordWrapper(inspectionItem));
        }
        for(Id inspectionId : inspectionIdInspectionItemMap.keySet()) {
            inspectionItemWrapperList = new List<InspectionItemWrapper>();
            for(String domainName : inspectionIdInspectionItemMap.get(inspectionId).keySet()) {
                inspectionItemWrapperList.add(new InspectionItemWrapper(domainName, inspectionIdInspectionItemMap.get(inspectionId).get(domainName)));
            }
            inspectionWrapperList.add(new InspectionWrapper(inspectionMap.get(inspectionId), inspectionItemWrapperList));
        }
        return inspectionWrapperList;
    }
    public class InspectionWrapper {
        @AuraEnabled public sObject record;
        @AuraEnabled public List<InspectionItemWrapper> inspectionItemWrapperList;
        public InspectionWrapper(sObject record, List<InspectionItemWrapper> inspectionItemWrapperList){
            this.record = record;
            this.inspectionItemWrapperList = inspectionItemWrapperList;
        }
    }
    public class InspectionItemWrapper {
        @AuraEnabled public String categoryName;
        @AuraEnabled public List<RecordWrapper> inspectionItemList;
        public InspectionItemWrapper(String categoryName, List<RecordWrapper> inspectionItemList){
            this.categoryName = categoryName;
            this.inspectionItemList = inspectionItemList;
        }
    }
    public class RecordWrapper{
        @AuraEnabled public sObject record;
        public RecordWrapper(sObject record){
            this.record = record;
        }
    }
}