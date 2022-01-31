public without sharing class AccountTriggerHandler {

    public static void afterInsert(List<Account> newList){
        createPreferences(newList);
    }

    public static void createPreferences(List<Account> newList){
        set<Id> accountIds = new set<Id>();
        List<Preference_and_Condition__c> listOfPrefConRecords = new List<Preference_and_Condition__c>();

        for(Account acc:newList){
            String developerName = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getDeveloperName();
            if(developerName =='Foster_Care_Agency'){
                accountIds.add(acc.Id);

            }

        }
        Preference_and_Condition__c prefConditionRec;
        if(!accountIds.isEmpty()){
            for(Preference_Configuration__mdt pre:[SELECT Duration_Required__c,Field_Type__c,Mandatory__c,Preference_Type__c,Related_To__c,Values__c,MasterLabel
                                                     FROM Preference_Configuration__mdt WHERE Related_To__c ='Parent']){
                for(Id accIds:accountIds){
                    prefConditionRec = new  Preference_and_Condition__c();
                    prefConditionRec.Duration_Required__c =  pre.Duration_Required__c;
                    prefConditionRec.Field_Type__c = pre.Field_Type__c;
                    prefConditionRec.Mandatory__c = pre.Mandatory__c;
                    prefConditionRec.Type__c = pre.MasterLabel;
                    prefConditionRec.Foster_Parent__c = accIds;
                    
                    listOfPrefConRecords.add(prefConditionRec);

                }
                                                       
            }

            if(!listOfPrefConRecords.isEmpty()){
                insert listOfPrefConRecords;
            }

        }
       
       
        
    }
}