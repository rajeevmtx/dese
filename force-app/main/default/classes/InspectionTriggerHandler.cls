public without sharing class InspectionTriggerHandler {
    public static final String CONFIG_TYPE_INSPECTION = 'Inspection';
    
    public static void onAfterInsert(List<Inspection__c> newInspectionList) {
        createDueDiligence(newInspectionList);
        //createInspectionItems(newInspectionList);
        //createEvents(newInspectionList,new Map<Id,Inspection__c>());
    }
    
    public static void onAfterUpdate(List<Inspection__c> newInspectionList,Map<Id,Inspection__c> oldMap) {
        createChildVisitAndNoComplianceItems(newInspectionList,oldMap);
        updateCloseStatusOnParentWorkOrder(newInspectionList,oldMap);
         //populateInspectionDateandTime(newInspectionList,oldMap);
         createInspectionItemsNew(newInspectionList,oldMap);
         createEvents(newInspectionList,oldMap);
    }

    public static void createEvents(List<Inspection__c> newInspectionList,Map<Id,Inspection__c> oldMap) {
        list<Inspection__c> listOfInspection = new List<inspection__C>();
        Inspection__c updaetInspection;
        List<Event> eventList= new List<Event>();
        
        if(oldMap != NULL && !oldMap.isEmpty() ){
            
            Map<Id,Inspection__c> mapEach= new Map<Id,Inspection__c>();
            for(Inspection__C each: newInspectionList){
                if((oldMap.get(each.id).Inspection_Start_Date__c != each.Inspection_Start_Date__c 
                    && each.Inspection_Start_Date__c != null) || (oldMap.get(each.id).Inspection_End_Date__c != each.Inspection_End_Date__c 
                    && each.Inspection_End_Date__c != null)){
                        mapEach.put(each.Id, each);
                    }
            }
            for(Event eachev: [SELECT Id, Subject, StartDatetime, EndDateTime, OwnerId, WhoId, WhatId FROM Event WHERE WhatId IN:mapEach.KeySet()]){
                eachev.StartDateTime=mapEach.get(eachev.WhatId).Inspection_Start_Date__c;
                eachev.EndDateTime=mapEach.get(eachev.WhatId).Inspection_End_Date__c;
                eventList.add(eachev);
            }
            If(eventList != NULL && !eventList.isEmpty()){
                try{update eventList;}
                catch(Exception ex){
                    System.debug('Error---'+ex.getMessage());
                }
            }
        }else{
            for(Inspection__C inspectionRec: [SELECT Id, Name, Application_Work_Order__r.Application_Contact__r.Contact__c, Inspection_Start_Date__c, Inspection_End_Date__c 
                FROM Inspection__c WHERE Id IN:newInspectionList]){
                        Event ev=new Event();
                        ev.WhatId=inspectionRec.Id;
                        ev.OwnerId='00503000001cUzPAAU';
                        ev.StartDateTime=inspectionRec.Inspection_Start_Date__c;
                        ev.EndDateTime=inspectionRec.Inspection_End_Date__c;
                        ev.WhoId=inspectionRec.Application_Work_Order__r.Application_Contact__r.Contact__c;
                        ev.Subject='Inspection Meeting - '+inspectionRec.Name;
                        ev.Description='This meeting is for inspection';
                        eventList.add(ev);
                
            }
            If(eventList != NULL && !eventList.isEmpty()){
                try{insert eventList;}
                catch(Exception ex){
                    System.debug('Error---'+ex.getMessage());
                }
            }
                
        }
        system.debug('Events--'+eventList);
        
    }
    public static void populateInspectionDateandTime(List<Inspection__c> inspectionList,Map<Id,Inspection__C> oldMap){

        list<Inspection__c> listOfInspectionToBeUpdated = new List<inspection__C>();
        Inspection__c updaetInspection;
        for(Inspection__C inspectionRec: inspectionList){
            if(oldMap.get(inspectionRec.id).Inspection_Start_Date__c != inspectionRec.Inspection_Start_Date__c 
                && inspectionRec.Inspection_Start_Date__c != null){
                    updaetInspection = new Inspection__c(Id =inspectionRec.Id);
                    updaetInspection.Date_of_Inspection__c = inspectionRec.Inspection_Start_Date__c.date();
                    updaetInspection.Time_of_Inspection__c = String.valueOf(inspectionRec.Inspection_Start_Date__c.time());
                    listOfInspectionToBeUpdated.add(updaetInspection);

            }

        }

        if(!listOfInspectionToBeUpdated.isEmpty()){
            update listOfInspectionToBeUpdated;
        }

    }
    
    public static void createDueDiligence(List<Inspection__c> inspectionList) {
        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
         Due_Diligence__c newDueDiligence;
        for(Due_Diligence_Config__c config : [SELECT Due_Diligence_Name__c, Due_Diligence_Unique_API_Name__c, Help_Text__c, Is_Active__c, Responsible_Party__c, Sequence__c,Reference_Link__c
                                              FROM Due_Diligence_Config__c
                                              WHERE Object_Type__c = :CONFIG_TYPE_INSPECTION
                                              AND Is_Active__c = true]) {
                                                  for(Inspection__c inspection : inspectionList) {
                                                      newDueDiligence = new Due_Diligence__c();
                                                      newDueDiligence.Inspection__c = inspection.Id;
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
    
    
    public static void createChildVisitAndNoComplianceItems(List<Inspection__c> newList,Map<Id,Inspection__c> oldMap){
        List<Inspection__c> listInspectionofInspection = new List<Inspection__c>();
        set<Id> inspectionId = new set<Id>();
        Inspection__c inspection;
        Inspection__c childInspectionRecord;
        Inspection_Item__c childInspectionItemRecord;
        Set<Id> workOrdersToBeClosed = new Set<Id>();
        
        List<Inspection__c> listOfNewChildInspections = new List<Inspection__c>();
        list<Inspection_Item__c> listOfChildInspectionItems= new List<Inspection_Item__c>();
        
        Map<Id,List<Inspection_Item__c>> mapOfInspectionItems = new Map<Id,List<Inspection_Item__c>>();
        for(Inspection__c inspec:newList){
            if( inspec.Re_Inspection_Required__c != oldMap.get(inspec.id).Re_Inspection_Required__c && inspec.Re_Inspection_Required__c =='Yes'){
                inspectionId.add(inspec.id);
            } 
        }
        
        system.debug('inspection'+inspectionId);
        for(Inspection__c inspectionRec:[SELECT id,Application_Work_Order__c ,Account__c,
                                         (SELECT ID,Observations__c,Inspection_Item_Name__c,Inspection__c 
                                          FROM Inspection_Items__r 
                                          WHERE Result__c ='Non-Compliant') 
                                         FROM Inspection__C 
                                         WHERE Id IN:inspectionId]){
                                             childInspectionRecord = new Inspection__c(Parent_Inspection__c = inspectionRec.id,Inspection_Status__c='To be Scheduled',Application_Work_Order__c = inspectionRec.Application_Work_Order__c ,Account__c = inspectionRec.Account__c );
                                             listOfNewChildInspections.add(childInspectionRecord);
                                             system.debug('listOfNewChildInspections'+listOfNewChildInspections);
                                             for(Inspection_Item__c inspectionItem : inspectionRec.Inspection_Items__r ){
                                                 
                                                 if(!mapOfInspectionItems.keySet().contains(inspectionRec.Id)){
                                                     mapOfInspectionItems.put(inspectionRec.Id, new List<Inspection_Item__c>());
                                                 }
                                                 mapOfInspectionItems.get(inspectionRec.id).add(inspectionItem);
                                                 system.debug('mapOfInspectionItems'+mapOfInspectionItems);
                                             }
                                         }
        
        if(!listOfNewChildInspections.isEmpty()){
            insert listOfNewChildInspections;
        }
        
       
        for(Inspection__c inspectionRec:[SELECT id,Parent_Inspection__c
                                         FROM Inspection__C 
                                         WHERE Parent_Inspection__c IN:inspectionId]){
                                             if(mapOfInspectionItems.containsKey(inspectionRec.Parent_Inspection__c)){
                                                 for(Inspection_Item__c inspectionItemRecords: mapOfInspectionItems.get(inspectionRec.Parent_Inspection__c)){
                                                     childInspectionItemRecord = new Inspection_Item__c();
                                                     childInspectionItemRecord.Observations__c = inspectionItemRecords.Observations__c;    
                                                     childInspectionItemRecord.Inspection_Item_Name__c = inspectionItemRecords.Inspection_Item_Name__c;    
                                                     childInspectionItemRecord.Inspection__c = inspectionRec.id;    
                                                     
                                                     listOfChildInspectionItems.add(childInspectionItemRecord);
                                                     
                                                     
                                                 }
                                                 
                                             }
                                             
                                         }
        
        if(!listOfChildInspectionItems.isEmpty()){
            insert listOfChildInspectionItems;
        }
       
    }
    
    
    public static void createInspectionItems(List<Inspection__c> inspectionList) {
        
        List<Tool_Item__c> toolItemsList = new List<Tool_Item__c>(); 
        set<Id> newInspectionsIds = new Set<Id>();
        set<String> permitType = new set<String>();
        Map<Id,String> inspectionToPermitType = new Map<Id,String>();
        
        for(Inspection__c inspectionRec:inspectionList){
            newInspectionsIds.add(inspectionRec.id);
        }
        
        
        for(Inspection__c inspectionRec:[SELECT Id,Application_Work_Order__r.Application__r.Permit_Type__c FROM Inspection__c WHERE Id IN:newInspectionsIds]){
            inspectionToPermitType.put(inspectionRec.Id,inspectionRec.Application_Work_Order__r.Application__r.Permit_Type__c);
        }
        
        
        for(Tool_Item__c toolItem:[SELECT Id,Category__c,Description__c, Item_Name__c,Tool__r.Permit_Type__c,Tool__r.Inspection_Type__c, Regulation__c 
                                   FROM Tool_Item__c WHERE Tool__r.Permit_Type__c =: inspectionToPermitType.values() AND Tool__r.active__c = true]){
                                       
                                       toolItemsList.add(toolItem);                                       
                                   }
        
        
        List<Inspection_Item__c> inspectionItemList = new List<Inspection_Item__c>();
        if(!toolItemsList.isEmpty()){
            System.debug('1. List has tools');
            for(Inspection__c inspection : inspectionList){
                if(String.IsBlank(inspection.Parent_Inspection__c) && inspectionToPermitType.containsKey(inspection.id) ){
                    System.debug('2. Permit Type matched');
                    for(Tool_Item__c toolItem : toolItemsList){
                        if(inspectionToPermitType.get(inspection.id) == toolItem.Tool__r.Permit_Type__c  
                           && toolItem.Tool__r.Inspection_Type__c =='New' ){
                               System.debug('3. Items created as all matched');
                               
                               Inspection_Item__c inspectionItem = new Inspection_Item__c();
                               inspectionItem.Category__c = toolItem.Category__c;
                               inspectionItem.Inspection_Item_Name__c = toolItem.Item_Name__c;
                               inspectionItem.Regulation__c = toolItem.Regulation__c;
                               inspectionItem.Inspection__c = inspection.Id;                        
                               inspectionItemList.add(inspectionItem);
                               
                           }
                        
                    }
                    
                }else if(inspection.Parent_Inspection__c != null){
                    for(Tool_Item__c toolItem : toolItemsList){
                        if(inspectionToPermitType.get(inspection.id) == toolItem.Tool__r.Permit_Type__c  
                           && toolItem.Tool__r.Inspection_Type__c !='New' ){
                               Inspection_Item__c inspectionItem = new Inspection_Item__c();
                               inspectionItem.Category__c = toolItem.Category__c;
                               inspectionItem.Inspection_Item_Name__c = toolItem.Item_Name__c;
                               inspectionItem.Inspection__c = inspection.Id;
                               
                               inspectionItemList.add(inspectionItem);
                           }
                    }
                    
                }
                
            }  
            
        }       
        
        if(inspectionItemList.size()>0){
            insert inspectionItemList;
        }
    }

    /**
     * Helper method to update 'Inspection Completed' status on Parent Application work order
     *
     * @param workOrdersToBeClosed is a set of Ids that meets criteria for Inspections
     */
    public static void updateCloseStatusOnParentWorkOrder(List<Inspection__c> newList,Map<Id,Inspection__c> oldMap){
        List<Application_Work_Order__c> listOfWOrkorder = new List<Application_Work_Order__c>();
        set<Id> workOrderIds = new Set<Id>();
        for(Inspection__c inspection: newList){
            if(inspection.Inspection_Status__c =='Closed' && inspection.Re_Inspection_Required__c != 'Yes'){
                    workOrderIds.add(inspection.Application_Work_Order__c);
            }
        }
        Application_Work_Order__c applicationWorkOrder;
        
        if(!workOrderIds.isEmpty()){
            for(Application_Work_Order__c workOrder :[SELECT id,Status__c 
                                                        FROM Application_Work_Order__c 
                                                       WHERE ID IN: workOrderIds]){

                applicationWorkOrder = new Application_Work_Order__c(Id=workOrder.Id,Status__c='Inspection Completed');
                listOfWOrkorder.add(applicationWorkOrder);
            }
        }
        if(!listOfWOrkorder.isEmpty()){
             update listOfWOrkorder;
        }

    }



    public static void createInspectionItemsNew(List<Inspection__c> inspectionList,Map<Id,Inspection__c> oldMap){
        List<Inspection__c> inspectionListWithnewTool = new List<Inspection__c>();
        Set<Id> setOfToolId = new Set<Id>();
        Set<Id> setOfInspectionId = new Set<Id>();
        for(Inspection__c inspection : inspectionList){
            if(inspection.Tool__c != oldMap.get(inspection.id).Tool__c){
                inspectionListWithnewTool.add(inspection);
                setOfToolId.add(inspection.Tool__c);
                setOfInspectionId.add(inspection.Id);
            }
        }
        List<Inspection_Item__c> oldInspectionItem = [SELECT ID FROM Inspection_Item__c WHERE inspection__C IN :setOfInspectionId];
        if(oldInspectionItem.size()>0){
            delete oldInspectionItem;
        }
        Map<Id,Tool__c> mapofTools = new Map<Id,Tool__c>([SELECT ID,Name,(SELECT Id,Category__c,Description__c, Item_Name__c,Tool__r.Permit_Type__c,Tool__r.Inspection_Type__c, Regulation__c,Regulation_New__c 
                                    FROM Tool_Items__r) FROM Tool__c WHERE Id IN :setOfToolId]);
        
        List<Inspection_Item__c> itemToInsert = new List<Inspection_Item__c>();
        for(Inspection__c inspection : inspectionListWithnewTool){
            for(Tool_Item__c toolItem : mapofTools.get(inspection.Tool__c).Tool_items__r){
                Inspection_Item__c inspectionItem = new Inspection_Item__c();
                inspectionItem.Category__c = toolItem.Category__c;
                inspectionItem.Inspection_Item_Name__c = toolItem.Item_Name__c;
                inspectionItem.Regulation__c = toolItem.Regulation__c;
                inspectionItem.Regulation_New__c = toolItem.Regulation_New__c;
                inspectionItem.Inspection__c = inspection.Id;                        
                itemToInsert.add(inspectionItem);
            }
        }
        if(itemToInsert.size() > 0){
            insert itemToInsert;
        }
    }

}