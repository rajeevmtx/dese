public without sharing class ApplicationWorkOrderTriggerHandler {
    public static final String CONFIG_TYPE_APPLICATION = 'Application';
    public static final String CONFIG_TYPE_APPLICATIONWORKORDER = 'Application Work Order';
    public static final String CONFIG_TYPE_CASE = 'Case';

    public static void onAfterInsert(List<Application_Work_Order__c> newApplicationWorkOrderList) {
        createDueDiligence(newApplicationWorkOrderList);
        //checkApplicationStatus(newApplicationWorkOrderList);
    }

    public static void createDueDiligence(List<Application_Work_Order__c> applicationWorkOrderList) {
        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
		Due_Diligence__c newDueDiligence;
        for(Due_Diligence_Config__c config : [SELECT Due_Diligence_Name__c, Due_Diligence_Unique_API_Name__c, Help_Text__c, Is_Active__c, Responsible_Party__c, Sequence__c
                                                FROM Due_Diligence_Config__c
                                                WHERE Object_Type__c = :CONFIG_TYPE_APPLICATION
                                                AND Is_Active__c = true]) {
            for(Application_Work_Order__c applicationWorkOrder : applicationWorkOrderList) {
                newDueDiligence = new Due_Diligence__c();
                newDueDiligence.Application_Work_Order__c = applicationWorkOrder.Id;
                newDueDiligence.Due_Diligence_Name__c = config.Due_Diligence_Name__c;
                newDueDiligence.Due_Diligence_Unique_API_Name__c = config.Due_Diligence_Unique_API_Name__c;
                newDueDiligence.Is_Active__c = config.Is_Active__c;
                newDueDiligence.Responsible_Party__c = config.Responsible_Party__c;
                newDueDiligence.Sequence__c = config.Sequence__c;
                newDueDiligence.Help_Text__c = config.Help_Text__c;
                dueDiligenceList.add(newDueDiligence);
            }
        }
        if(!dueDiligenceList.isEmpty()) {
            insert dueDiligenceList;
        }
    }
    //Dhana Prasad for updating Last notified date
   /* public static void checkApplicationStatus(List<Application_Work_Order__c> newApplicationWorkOrderList)
    {
         Set<Id> appIdSet = new Set<Id>();
        List<Application_Work_Order__c> updateOrderList =  new List<Application_Work_Order__c>();
        for(Application_Work_Order__c workOrder : newApplicationWorkOrderList)
         {
           
             {
             appIdSet.add(workOrder.Application__c);
             }
         }
         Map<Id,Application__c> appMap = new Map<Id,Application__c>( 
                                         [SELECT Id, Status__c
                                         FROM Application__c
                                         WHERE Id =: appIdSet 
                                         ]);
         for(Application_Work_Order__c workOrder : newApplicationWorkOrderList)
         {
             System.debug('workOrder'+workOrder);
             if(appMap != null)
             if(appMap.get(workOrder.Application__c).Status__c == 'Approved Permits')
             { 
                  System.debug('workOrder 2'+workOrder);
                 workOrder.Last_Notified_Date__c = System.today();
                 workOrder.Send_Notification__c =true;
                 updateOrderList.add(workOrder);
             }
         }
     
      if(updateOrderList.size()>0)
          update updateOrderList;
    }*/
}