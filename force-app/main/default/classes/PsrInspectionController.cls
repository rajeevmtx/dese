public without sharing class PsrInspectionController {  
    public PsrInspectionController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Inspection> getInpectionsData(){  
        //Get User's Account details
        Id currentUser = UserInfo.getUserId();
        List < User > userList = [select contactId, contact.AccountId from User u where u.Id = :currentUser];
        Id contactId = userList[0].contactId;
        Id accountId = userList[0].contact.AccountId;
        //Collection Variables to hold records
        List<Inspection__c> inspectionsList = new List<Inspection__c>();
        List<Inspection> returnList = new List<Inspection>();
        system.debug('accountId'+accountId);
        if(contactId != null){
            for(Inspection__c rec : [SELECT Id, Name, Corrective_Action_Required__c,Inspection_Status__c,Inspection_Start_Date__c,
                                            (SELECT Id, Name, Correction_Plan__c, Correction_Plan_Status__c, Corrective_Action_Feedback__c, Date_Implemented__c,
                                                    Inspection_Item_Name__c, Observations__c, Result__c, Publish_To_Portal__c 
                                                    FROM Inspection_Items__r 
                                                    WHERE (Correction_Plan_Status__c = 'To Collect' OR Correction_Plan_Status__c = 'To Submit') 
                                                          AND Result__c = 'Non-Compliant' AND Publish_To_Portal__c = true)
                                            FROM Inspection__c 
                                            WHERE Inspection_Status__c != 'Closed' AND 
                                                  Application_Work_Order__r.Application_Contact__r.Contact__c =:contactId]){

                                                if(rec.Inspection_Items__r != null && rec.Inspection_Items__r.size() > 0){
                                                    inspectionsList.add(rec);
                                                    Inspection obj = new Inspection();
                                                    obj.parentId = rec.Id;
                                                    obj.name = rec.Name;
                                                    obj.inspectionDate = rec.Inspection_Start_Date__c;
                                                    List<InspectionItem> tempList = new List<InspectionItem>();
                                                    for(Inspection_Item__c child : rec.Inspection_Items__r){
                                                        tempList.add(new InspectionItem(child));
                                                    }
                                                    obj.items = tempList;
                                                    returnList.add(obj);
                                                }

                                            }

        }

        return returnList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Inspection_Item__c> getInspectionItems(Id parentId){
        List<Inspection_Item__c> items = new List<Inspection_Item__c>();
        for(Inspection_Item__c item : [SELECT Id, Name, Correction_Plan__c, Correction_Plan_Status__c, Corrective_Action_Feedback__c, Date_Implemented__c,
                                                    Inspection_Item_Name__c, Observations__c, Result__c, Publish_To_Portal__c 
                                                    FROM Inspection_Item__c WHERE Inspection__c =:parentId AND Result__c = 'Non-Compliant']){
                                                        items.add(item);
                                                    }

        return items;
    }

    @AuraEnabled
    public static void updateInspectionItems(String response, Boolean isSubmit){
        system.debug('response+++'+response);
        List<Inspection> responseList = (List<Inspection>)JSON.deserializeStrict(response, List<Inspection>.class);
        system.debug('responseList+++++'+responseList);
        List<String> inspectionsIds = new List<String>();
        List<Inspection_Item__c> listToUpdate = new List<Inspection_Item__c>();
        for(Inspection rec : responseList){
            inspectionsIds.add(rec.parentId);
            if(rec.items != null){
                for(InspectionItem item : rec.items){
                    Inspection_Item__c child = new Inspection_Item__c(Id = item.recId);
                    child.Observations__c = item.observations;
                    child.Date_Implemented__c = item.dateImplemented;
                    child.Correction_Plan__c = item.correctionPlan;
                    system.debug('isSubmit+++++'+isSubmit);
                    system.debug('item.dateImplemented+++++'+item.dateImplemented);
                    system.debug('item.correctionPlan+++++'+item.correctionPlan);
                    if(item.dateImplemented != null && item.correctionPlan != null && isSubmit){
                        child.Correction_Plan_Status__c = 'Submitted, Inspector To Review';
                    }
                    listToUpdate.add(child);
                }
            }
        }
        //Update Inspection Items
        if(listToUpdate.size() > 0)
        update listToUpdate;
        List<Inspection__c> inspectionsToUpdate = new List<Inspection__c>();
        for(Inspection__c rec : [SELECT Id, Inspection_Status__c, (SELECT Id, Correction_Plan_Status__c FROM Inspection_Items__r) 
                                        FROM Inspection__c WHERE Id IN :inspectionsIds]){
                                            List<Inspection_Item__c> childRecsList = new List<Inspection_Item__c>();
                                            if(rec.Inspection_Items__r != null){
                                                for(Inspection_Item__c child : rec.Inspection_Items__r){
                                                    if(child.Correction_Plan_Status__c == 'Submitted, Inspector To Review'){
                                                        childRecsList.add(child);
                                                    }
                                                }
                                                if(childRecsList.size() == rec.Inspection_Items__r.size()){
                                                    rec.Inspection_Status__c = 'Pending Completion';
                                                    rec.Inspection_Status_Reason__c = 'Corrective Action Under Review';
                                                    inspectionsToUpdate.add(rec);
                                                }
                                            }
                                        }
        //Update Insepction Records
        if(inspectionsToUpdate.size() > 0)
        update inspectionsToUpdate;
    }

    @AuraEnabled
    public static void saveInspectionRecord(String response){
         system.debug('response+++'+response);
        List<Inspection_Item__c> responseList = (List<Inspection_Item__c>)JSON.deserializeStrict(response, List<Inspection_Item__c>.class);
        system.debug('responseList+++++'+responseList);
        update responseList;
        
    }

    @AuraEnabled
    public static void getPublishedRecords(String publishedResponse){
        List<Inspection_Item__c> updateList = new List<Inspection_Item__c>();
        List<Inspection_Item__c> updateInspectionItemsList = new List<Inspection_Item__c>();
        Set<Id> inspectionParentSet = new Set<Id>();
        Set<Id> inspectionItemSet = new Set<Id>();
        List<Inspection_Item__c> publishedRecordsList = (List<Inspection_Item__c>)JSON.deserializeStrict(publishedResponse, List<Inspection_Item__c>.class);
        if(!publishedRecordsList.isEmpty()) {
            for(Inspection_Item__c inspectionItemRec: publishedRecordsList) {
                if(inspectionItemRec != null && inspectionItemRec.Id != null) {
                    Inspection_Item__c inspectionItem = new Inspection_Item__c();
                    inspectionItem.Id = inspectionItemRec.Id;
                    inspectionItem.Publish_To_Portal__c = true;
                    inspectionItem.Correction_Plan_Status__c = 'To Submit';
                    updateInspectionItemsList.add(inspectionItem);
                    //I-16164 Chandana - Start
                    inspectionItemSet.add(inspectionItemRec.Id);
                    //I-16164 Chandana - End
                }
            }
        }
        Set<Inspection_Item__c> updateInspectionSet = new Set<Inspection_Item__c>(updateInspectionItemsList);
        updateList.addAll(updateInspectionSet);
        if(updateList.size()>0){
            update updateList;
        }
        //I-16164 Chandana - Start
        if(!inspectionItemSet.isEmpty()) {
            for(Inspection_Item__c inspecItemRec : [SELECT Id, Inspection__c FROM Inspection_Item__c WHERE Id IN: inspectionItemSet])
            {
                inspectionParentSet.add(inspecItemRec.Inspection__c);
            }
        }

        List<Inspection__c> inspectionsUpdateList = new List<Inspection__c>();
        if(!inspectionParentSet.isEmpty()) {
            for(Inspection__c inspectionRec : [SELECT Id, Inspection_Status__c, Inspection_Status_Reason__c, Application_Work_Order__r.Application_Contact__r.Contact__r.Email FROM Inspection__c WHERE Id IN: inspectionParentSet]) 
            {
                inspectionRec.Inspection_Status__c = 'Pending Completion';
                inspectionRec.Inspection_Status_Reason__c = 'Corrective Action Required';
                inspectionRec.Contractor__c = inspectionRec.Application_Work_Order__r.Application_Contact__r.Contact__r.Email;
                inspectionsUpdateList.add(inspectionRec);
            }
        }
        if(inspectionsUpdateList.size() > 0)
        {
            update inspectionsUpdateList;
        }
        //I-16164 Chandana - End
    }

    @AuraEnabled
    public static void getAcceptCorrectiveRecords(String acceptCorrectiveResponse){
        List<Inspection_Item__c> updateList = new List<Inspection_Item__c>();
        List<Inspection_Item__c> updateInspectionItemsList = new List<Inspection_Item__c>();
        List<Inspection_Item__c> acceptCorrectiveRecordsList = (List<Inspection_Item__c>)JSON.deserializeStrict(acceptCorrectiveResponse, List<Inspection_Item__c>.class);
        if(!acceptCorrectiveRecordsList.isEmpty()) {
            for(Inspection_Item__c inspectionItemRec: acceptCorrectiveRecordsList) {
                if(inspectionItemRec != null && inspectionItemRec.Id != null) {
                    Inspection_Item__c inspectionItem = new Inspection_Item__c();
                    inspectionItem.Id = inspectionItemRec.Id;
                    inspectionItem.Correction_Plan_Status__c = 'Accepted';
                    updateInspectionItemsList.add(inspectionItem);
                }
            }
        }
        Set<Inspection_Item__c> updateInspectionSet = new Set<Inspection_Item__c>(updateInspectionItemsList);
        updateList.addAll(updateInspectionSet);
        if(updateList.size()>0){
            update updateList;
        }
        
    }

    public class Inspection{
        @AuraEnabled public String parentId;
        @AuraEnabled public String name;
        @AuraEnabled public Datetime inspectionDate;
        @AuraEnabled public List<InspectionItem> items;
        @AuraEnabled public Boolean showChilds = false; 
    }

    public class InspectionItem{
        @AuraEnabled public String recId;
        @AuraEnabled public String name;
        @AuraEnabled public String observations;
        @AuraEnabled public String correctionPlan;
        @AuraEnabled public Date dateImplemented;
        @AuraEnabled public String feedback;

        public InspectionItem(Inspection_Item__c rec){
            this.recId = rec.Id;
            this.name = rec.name;
            this.observations = rec.Observations__c != null ? rec.Observations__c : '';
            this.correctionPlan = rec.Correction_Plan__c != null ? rec.Correction_Plan__c : '';
            this.dateImplemented = rec.Date_Implemented__c;
            this.feedback = rec.Corrective_Action_Feedback__c != null ? rec.Corrective_Action_Feedback__c : '';
        }
    }
}