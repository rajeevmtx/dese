public with sharing class CaseTriggerHandler {
    public static final String CONFIG_TYPE_APPLICATION = 'Application';
    public static final String CONFIG_TYPE_APPLICATIONWORKORDER = 'Application Work Order';
    public static final String CONFIG_TYPE_CASE = 'Case';

    public static void onAfterInsert(List<Case> newCaseList) {
        createDueDiligence(newCaseList);
    }

    public static void onAfterUpdate() {
        updateAccountPermitType();
    }

    private static void createDueDiligence(List<Case> caseList) {
        List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();

        for(Due_Diligence_Config__c config : [SELECT Due_Diligence_Name__c, Due_Diligence_Unique_API_Name__c, Help_Text__c, Is_Active__c, Responsible_Party__c, Sequence__c,Reference_Link__c
                                                FROM Due_Diligence_Config__c
                                                WHERE Object_Type__c = :CONFIG_TYPE_APPLICATION
                                                AND Is_Active__c = true]) {
            for(Case c : caseList) {
                Due_Diligence__c newDueDiligence = new Due_Diligence__c();
                newDueDiligence.Case__c = c.Id;
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

    private static void updateAccountPermitType(){
        Map<Id,Case> oldMap = (Map<Id,Case>)Trigger.oldMap;

        Map<Id, Set<String> > AccIdAndPermits = new Map<Id, Set<String> >();

        for( Case caseRec : (List<Case>)Trigger.New ) {
            if( caseRec.Status != oldMap.get( caseRec.Id ).Status && caseRec.Status == 'Approved' && caseRec.AccountId != null ){
                Set<String> lstPerTps = new Set<String>();

                if( AccIdAndPermits.containsKey(caseRec.AccountId) ){
                    lstPerTps = AccIdAndPermits.get(caseRec.AccountId);
                }
                lstPerTps.add( caseRec.Request_Permit_Type__c );

                AccIdAndPermits.put(caseRec.AccountId, lstPerTps);
            }
        }

        List<Account> accsUpt = [Select id,Request_Permit_Type__c from Account where id in : AccIdAndPermits.keySet() ];
        for( Account acc : accsUpt ){
            Set<String> lstPerTps = AccIdAndPermits.get(acc.Id);
            lstPerTps.add(acc.Request_Permit_Type__c);

            acc.Request_Permit_Type__c = String.join( new List<String>(lstPerTps), ';' );
        }

        update accsUpt;
    }
}