public with sharing class DueDiligenceController {
    @AuraEnabled
    public static List<Due_Diligence__c> getDueDiligenceRecords(String idField){
        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
        if(idField!=null || idField!=''){
            Schema.DescribeSObjectResult applicationPrefix = Application__c.sObjectType.getDescribe();
            Schema.DescribeSObjectResult applicationWorkOrderPrefix = Application_Work_Order__c.sObjectType.getDescribe();
            Schema.DescribeSObjectResult casePrefix = Case.sObjectType.getDescribe();
            Schema.DescribeSObjectResult inspectionPrefix = Inspection__c.sObjectType.getDescribe();
            //Schema.DescribeSObjectResult assessmentPrefix = Assessment__c.sObjectType.getDescribe();
            Schema.DescribeSObjectResult investigationPrefix = Investigation__c.sObjectType.getDescribe();

            if(idField.substring(0, 3) == applicationPrefix.getKeyPrefix() ){
                dueDiligenceList = [SELECT Id, Due_Diligence_Name__c, Responsible_Party__c, Reference_Link__c,
                                                            Status__c, Completed_Date__c, LastModifiedBy.Name
                                                            FROM Due_Diligence__c WHERE Application__c = :idField  ORDER BY Sequence__c ASC];
            }
            else if(idField.substring(0, 3) == applicationWorkOrderPrefix.getKeyPrefix()){
                dueDiligenceList = [SELECT Id, Due_Diligence_Name__c, Responsible_Party__c,Reference_Link__c,
                                                            Status__c, Completed_Date__c, LastModifiedBy.Name
                                                            FROM Due_Diligence__c WHERE Application_Work_Order__c = :idField ORDER BY Sequence__c ASC];
            }
            else if(idField.substring(0, 3) == casePrefix.getKeyPrefix()){
                dueDiligenceList = [SELECT Id, Due_Diligence_Name__c, Responsible_Party__c,Reference_Link__c,
                                                            Status__c, Completed_Date__c, LastModifiedBy.Name
                                                            FROM Due_Diligence__c WHERE Case__c = :idField ORDER BY Sequence__c ASC];
            }
            else if(idField.substring(0, 3) == inspectionPrefix.getKeyPrefix()){
                dueDiligenceList = [SELECT Id, Due_Diligence_Name__c, Responsible_Party__c,Reference_Link__c,
                                                            Status__c, Completed_Date__c, LastModifiedBy.Name
                                                            FROM Due_Diligence__c WHERE Inspection__c = :idField ORDER BY Sequence__c ASC];
            }
            /*else if(idField.substring(0, 3) == assessmentPrefix.getKeyPrefix()){
                dueDiligenceList = [SELECT Id, Due_Diligence_Name__c, Responsible_Party__c,Reference_Link__c,
                                                            Status__c, Completed_Date__c, LastModifiedBy.Name
                                                            FROM Due_Diligence__c WHERE Assessment__c = :idField ORDER BY Sequence__c ASC];
            }*/
            else if(idField.substring(0, 3) == investigationPrefix.getKeyPrefix()){
                dueDiligenceList = [SELECT Id, Due_Diligence_Name__c, Responsible_Party__c,Reference_Link__c,
                                                            Status__c, Completed_Date__c, LastModifiedBy.Name
                                                            FROM Due_Diligence__c WHERE Investigation__c = :idField ORDER BY Sequence__c ASC];
            }
        }
        return dueDiligenceList;
    }
    @AuraEnabled
    public static void updateDueDiligenceRecords(String jsonMap){
        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
        List<AssignmentWrapper> wrapperList = (List<AssignmentWrapper>) JSON.deserialize(jsonMap, List<AssignmentWrapper>.class);
        System.debug('wrapper here '+ wrapperList);

        for(AssignmentWrapper wrapper : wrapperList){
            Due_Diligence__c dueDiligence = new Due_Diligence__c();
            dueDiligence.Id = wrapper.Recid;
            dueDiligence.Status__c = wrapper.Status;

            if(wrapper.Status != 'Pending'){
                dueDiligence.Completed_Date__c = Date.today();
            }
            else{
                dueDiligence.Completed_Date__c = null;
            }

            dueDiligenceList.add(dueDiligence);
        }
        if(dueDiligenceList.size()>0){
            update dueDiligenceList;
        }
    }

    public class AssignmentWrapper {
        public String Recid;
        public String Status;
    }
}