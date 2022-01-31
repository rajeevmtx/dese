/**
 * PSR_InspectionDetailController Description
 * Created By Anand
 */
public class PSR_InspectionDetailController {

    @AuraEnabled
    public static List<PSR_InspectionWrapper> fetchInspectionDetails(String applicationWorkOrderId){
        List<PSR_InspectionWrapper> wrapList;
        wrapList = new List<PSR_InspectionWrapper>();
        try{

            List<PSR_PickListWrapper> categoryList = getPicklistfieldValues('Inspection_Item__c','Category__c');
            for(Inspection__c inspectionObj:[Select Id,Name,Inspection_Status_Reason__c,Application_Work_Order__c,
              Application_Work_Order__r.Application__r.Name,Inspector__r.Name,
              Inspection_Start_Date__c,
              Inspection_End_Date__c,
              ( Select Id,category__c,
              Inspection_Item_Name__c,
              Last_Corrective_Action_Feedback__c,
              Corrective_Action_Feedback__c,
              Non_Assessed_Item__c,
              Observations__c,
              Publish_To_Portal__c,
              Result__c
              FROM Inspection_Items__r
              )
              FROM Inspection__c WHERE Application_Work_Order__c = :applicationWorkOrderId]) {
                PSR_InspectionWrapper wrap =  new PSR_InspectionWrapper();
                wrap.categoryList = categoryList;
                wrap.inspectionId = inspectionObj.Id;
                wrap.inspectionName = inspectionObj.Name;
                wrap.applicationNumber = inspectionObj.Application_Work_Order__r.Application__r.Name;
                wrap.startDate = inspectionObj.Inspection_End_Date__c;
                wrap.endDate = inspectionObj.Inspection_Start_Date__c;
                wrap.inspectorName = inspectionObj.Inspector__r.Name;
                List<PSR_InspectionWrapper.InspectionItem> inspectionItemsList =
                  new List<PSR_InspectionWrapper.InspectionItem>();
                Integer nonComplianceCount=0;
                Integer complianceTotal=0;
                String resultVariation ='';
                if(inspectionObj.Inspection_Items__r.size()>0) {
                    Map<String,
                      List<Inspection_Item__c> > inspectionItemMap = new Map<String,List<Inspection_Item__c> >();
                    for(Inspection_Item__c inspectItem:inspectionObj.Inspection_Items__r) {
                        if(inspectionItemMap.containsKey(inspectItem.category__c)) {
                            inspectionItemMap.get(inspectItem.category__c).add(inspectItem);
                        }else{
                            inspectionItemMap.put(inspectItem.category__c,new List<Inspection_Item__c> {
                                inspectItem
                            });
                        }
                    }
                    for(String category:inspectionItemMap.keySet()) {
                        complianceTotal=0;
                        nonComplianceCount=0;
                        PSR_InspectionWrapper.InspectionItem inspectItemWrapper =
                          new PSR_InspectionWrapper.InspectionItem();
                        inspectItemWrapper.category = category;
                        inspectItemWrapper.inspectionItems = inspectionItemMap.get(category);
                        if(inspectItemWrapper.inspectionItems.size()>0) {
                            for(Inspection_Item__c inspecItem:inspectItemWrapper.inspectionItems) {
                                if(inspecItem.result__c == 'Non-Compliant') {
                                    nonComplianceCount++;
                                }
                                if(inspecItem.result__c == 'Non-Compliant'|| inspecItem.result__c == 'Compliant') {
                                    complianceTotal++;
                                }
                            }
                            resultVariation = string.valueof(complianceTotal - nonComplianceCount) +'/'+
                              string.valueof(complianceTotal);
                            inspectItemWrapper.hasNonCompliant= nonComplianceCount > 0 ? True : false;
                            inspectItemWrapper.inspectionItemVariance = resultVariation;
                        }
                        inspectionItemsList.add(inspectItemWrapper);
                    }
                    wrap.inspectionItemsList = inspectionItemsList;

                }
                wrapList.add(wrap);
            }
        }catch(exception e) {

        }
        return wrapList;
    }

    private static List<PSR_PickListWrapper> getPicklistfieldValues(String objName,String fieldName){
        List<PSR_PickListWrapper> pickListVal = new List<PSR_PickListWrapper>();
        try{
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);//From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                pickListVal.add(new PSR_PickListWrapper(a.getLabel(),a.getValue()));//add the value  to our final list
            }
        }catch(exception e) {

        }
        return pickListVal;
    }
}