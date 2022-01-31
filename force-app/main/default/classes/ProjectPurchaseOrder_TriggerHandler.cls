/*
*   Class Name: ProjectPurchaseOrder_TriggerHandler
*   Description: Trigger Handler for Project Purchase Order
*   
*   Author/Date: Ghanshyam Saini/ July 26, 2016 
*                          
*/ 
public class ProjectPurchaseOrder_TriggerHandler {
  
  /*
  * Method Name: beforeInsert
  * Description: Perform all operations in this method need to in before insert call  
  * @param: list<Project_Purchase_Order__c> newList
  * @return: void                                                      
  */
    public static void beforeInsert(list<Project_Purchase_Order__c> newList){
        populateFinalStatus(newList, null);
    }

    /*
  * Method Name: beforeUpdate
  * Description: Perform all operations in this method need to in before update call 
  * @param: list<Project_Purchase_Order__c> newList
  * @param: map<Id,Project_Purchase_Order__c> oldMap
  * @return: void                                                      
  */ 
    public static void beforeUpdate(list<Project_Purchase_Order__c> newList, map<Id,Project_Purchase_Order__c> oldMap){
        populateFinalStatus(newList, oldMap);
    }
  
  /*
  * Method Name: afterInsertUpdate
  * Description: Perform all operations in this method need to in after insert update update call 
  * @param: list<Project_Purchase_Order__c> newList
  * @param: map<Id,Project_Purchase_Order__c> oldMap
  * @return: void                                                      
  */
    public static void afterInsertUpdate(list<Project_Purchase_Order__c> newList, map<Id,Project_Purchase_Order__c> oldMap) {
      updateProjectStatusFromPO(newList, oldMap);
    }

    /*
  * Method Name: populateFinalStatus
  * Description:  Used to populate the Status field with the result of combination of PO_Status__c and Budget_Status__c fields : T-01526
  * @param: list<Project_Purchase_Order__c> newList
  * @param: map<Id,Project_Purchase_Order__c> oldMap
  * @return: void                                                       
  */
    private static void populateFinalStatus(list<Project_Purchase_Order__c> newList, map<Id,Project_Purchase_Order__c> oldMap){

      Boolean isInsert = Trigger.isInsert;

      List<NEIS_Status_Mapping__mdt> listNEIS_StatusMapping = new List<NEIS_Status_Mapping__mdt>();
      listNEIS_StatusMapping = [SELECT MasterLabel, DeveloperName, Field_1__c, Field_2__c, Value_1__c, Value_2__c, Result_Status__c
                                FROM NEIS_Status_Mapping__mdt
                                WHERE MasterLabel =: ProjectPurchaseOrder_Helper.PROJECT_PURCHASE_ORDER_API_NAME];
 
      map<String,NEIS_Status_Mapping__mdt> statusKeyToMDTMap = new map<String,NEIS_Status_Mapping__mdt>();
      for(NEIS_Status_Mapping__mdt mdtObj : listNEIS_StatusMapping){
          String key = mdtObj.Value_1__c + '|' + mdtObj.Value_2__c;
          if(!statusKeyToMDTMap.containsKey(key))
              statusKeyToMDTMap.put(key, mdtObj);
      }

      for(Project_Purchase_Order__c ppoObj : newList){
          String mappingKey = ppoObj.PO_Status__c + '|' + ppoObj.Budget_Status__c;
          if(statusKeyToMDTMap.containsKey(mappingKey)
                  && statusKeyToMDTMap.get(mappingKey).Field_1__c == ProjectPurchaseOrder_Helper.PROJECT_PURCHASE_ORDER_PO_STATUS_API_NAME
                  && statusKeyToMDTMap.get(mappingKey).Field_2__c == ProjectPurchaseOrder_Helper.PROJECT_PURCHASE_ORDER_BUDGET_STATUS_API_NAME){

              ppoObj.Status__c = statusKeyToMDTMap.get(mappingKey).Result_Status__c;
          }
      }

    }
  
  /*
  * Method Name: updateProjectStatusFromPO
  * Description:  Used to Update project status field with the result of combination of PO_Status__c and Budget_Status__c fields : T-01526
  * @param: list<Project_Purchase_Order__c> newList
  * @param: map<Id,Project_Purchase_Order__c> oldMap
  * @return: void                                                      
  */
    private static void updateProjectStatusFromPO(list<Project_Purchase_Order__c> newList, map<Id,Project_Purchase_Order__c> oldMap) {
      Boolean isUpdate = (Trigger.isUpdate && oldMap != null);
      Map<Id, Project__c> projectsToBeUpdated = new Map<Id, Project__c>();

      set<Id> projectIds = new set<Id>();
      for(Project_Purchase_Order__c objPO :  newList) {
        projectIds.add(objPO.Project__c);
      }

      map<Id,Project__c> projectIdToProjectMap = new map<Id,Project__c>([Select Id, RecordType.DeveloperName, Status__c from Project__c where Id IN: projectIds]);

      for(Project_Purchase_Order__c objPO :  newList) {
          if(objPO.Project__c !=null && String.isNotBlank(objPO.NEIS_PO_ID__c) && ProjectPurchaseOrder_Helper.PO_STATUS_APPROVED.equalsIgnoreCase(objPO.Status__c) &&
             (!isUpdate ||
              (isUpdate && (!ProjectPurchaseOrder_Helper.PO_STATUS_APPROVED.equalsIgnoreCase(oldMap.get(objPO.id).Status__c) ||
                            !objPO.NEIS_PO_ID__c.equalsIgnoreCase(oldMap.get(objPO.id).NEIS_PO_ID__c))
              )
             )){

             if(Project_Helper.SET_OF_NYS_PROJECT_RECORD_TYPE_DEV_NAME_FOR_PO_SYNC.contains(projectIdToProjectMap.get(objPO.Project__c).recordType.DeveloperName)) {
               // NY Sun
               if(Project_Helper.PROJECT_STATUS_PENDINGAPPROVAL.equalsIgnoreCase(projectIdToProjectMap.get(objPO.Project__c).Status__c) ||
                  Project_Helper.PROJECT_STATUS_RECEIVED.equalsIgnoreCase(projectIdToProjectMap.get(objPO.Project__c).Status__c)) {
                 // Case: 00002528
                 // PO: When PO is synced, we only move from Pending Approval to Approved.
                 // Exceptional: also added Received to the list to make it less restrictive
                 projectsToBeUpdated.put(objPO.Project__c, new Project__c(Id = objPO.Project__c, Status__c = Project_Helper.PROJECT_STATUS_APPROVED));
               }
             } else {
               // Rest of the Record Types should behave as is
               projectsToBeUpdated.put(objPO.Project__c, new Project__c(Id = objPO.Project__c, Status__c = Project_Helper.PROJECT_STATUS_APPROVED, NEIS_PO_ID__c = objPO.NEIS_PO_ID__c));
             }
          }
      }
      if(projectsToBeUpdated.size() > 0) {
        update projectsToBeUpdated.values();
      }
    }


}