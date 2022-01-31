public without sharing class FC_ParentPreferenceController {
    @AuraEnabled
    public static List<Preference_and_Condition__c> getPrefrences() {
        Id AccountId = [SELECT Id,AccountId FROM User WHERE Id =: userinfo.getuserid() AND AccountId != null].AccountId;
        return [
            SELECT Id,Name, Type__c, Value__c, Start_Date__c, End_Date__c,Duration_Required__c
            FROM Preference_and_Condition__c
            WHERE Foster_Parent__c =: AccountId
        ];
    }

    @AuraEnabled
    public static List<Preference_and_Condition__c> getPrefrencesInternal(Id caseId) {
        String sObjName = caseId.getsobjecttype().getDescribe().getName();
        Id recordTypeId = Schema.SObjectType.Preference_and_Condition__c.getRecordTypeInfosByDeveloperName().get('Foster_Care_Child').getRecordTypeId();
        if(sObjName == 'Case'){
            return [
                SELECT Id,Name, Type__c, Value__c, Start_Date__c, End_Date__c,Duration_Required__c
                FROM Preference_and_Condition__c
                WHERE Case__c =: caseId
                AND RecordTypeId =: recordTypeId
            ];    
        }else{
            return [
                SELECT Id,Name, Type__c, Value__c, Start_Date__c, End_Date__c,Duration_Required__c
                FROM Preference_and_Condition__c
                WHERE Foster_Care_Child__c =: caseId
                AND RecordTypeId =: recordTypeId
            ];
        }
    }
    @AuraEnabled
    public static List<PreferencesAndConditions> getAccountPrefrences(String accountId) {
        
        List<PreferencesAndConditions> preferencesAndConditionsList = new List<PreferencesAndConditions>();

        for(Preference_and_Condition__c preferences : 
            [SELECT Id,Name, Type__c, Value__c, Start_Date__c, End_Date__c,Duration_Required__c,Weightage__c
            FROM Preference_and_Condition__c
            WHERE Foster_Parent__c =: accountId]){
                    PreferencesAndConditions preferencesAndConditions = new PreferencesAndConditions(preferences);
                    preferencesAndConditionsList.add(preferencesAndConditions);
            }

        if(preferencesAndConditionsList.size() > 0){
            return preferencesAndConditionsList;
        }else{ 
            return null;
        }
    }

    @AuraEnabled
    public static void setPreferenceWeightage(String perferenceId,String weightage){

        Preference_and_Condition__c preference = [SELECT Id,Name, Type__c, Value__c, Start_Date__c, End_Date__c,Duration_Required__c,Weightage__c 
                                                FROM Preference_and_Condition__c
                                                WHERE Id =: perferenceId limit 1];
        preference.Weightage__c = weightage;
        update preference;
    }
    
    @AuraEnabled
    public static List<Preference_and_Condition__c> savePrefrences(String jsonData) {
        PreferencesAndConditions preferences = (PreferencesAndConditions) JSON.deserialize(JsonData, PreferencesAndConditions.class);
        List<Preference_and_Condition__c> prefrenceList = new List<Preference_and_Condition__c>();
        Preference_and_Condition__c prefrenceRec = new Preference_and_Condition__c();
        System.debug('preferences>>>' + preferences);
        prefrenceRec.Id = preferences.preferenceId;
        prefrenceRec.Type__c = preferences.type;
        prefrenceRec.Value__c = preferences.value;
        prefrenceRec.Start_Date__c = preferences.startDate;
        prefrenceRec.End_Date__c = preferences.endDate;
        prefrenceList.add(prefrenceRec);
        System.debug('prefrenceList>>>' + prefrenceList);
        UPDATE prefrenceList;

        return prefrenceList;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklist(String type){ 
        List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>(); 
        List<String> typeList = new List<String>();
        for(Preference_Configuration__mdt metadata : [SELECT Id,MasterLabel, Values__c 
                                                        FROM Preference_Configuration__mdt 
                                                        WHERE Values__c != null 
                                                        AND Field_Type__c = 'Picklist'
                                                        AND Related_To__c = 'Parent'
                                                        AND MasterLabel =: type 
                                                        LIMIT 1]){
            typeList = metadata.Values__c.split(',');
        }
        for(String str : typeList){
            optionList.add(new SelectOptionWrapper(str,str));
        }    
        return optionList;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklistForChild(String type){ 
        List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>(); 
        List<String> typeList = new List<String>();
        for(Preference_Configuration__mdt metadata : [SELECT Id,MasterLabel, Values__c 
                                                        FROM Preference_Configuration__mdt 
                                                        WHERE Values__c != null 
                                                        AND Field_Type__c = 'Picklist'
                                                        AND Related_To__c = 'Child'
                                                        AND MasterLabel =: type 
                                                        LIMIT 1]){
            typeList = metadata.Values__c.split(',');
        }
        for(String str : typeList){
            optionList.add(new SelectOptionWrapper(str,str));
        }    
        return optionList;
    }

    public class SelectOptionWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
        }
    }

    public class PreferencesAndConditions{
        @AuraEnabled public String preferenceId;
        @AuraEnabled public String value;
        @AuraEnabled public String type;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String pereferenceName;
        @AuraEnabled public String weightage;
        @AuraEnabled public Boolean durationRequired;

        public PreferencesAndConditions(){
            preferenceId = '';
            value = '';
            type = '';
            startDate = null;
            endDate = null;
        }
        public PreferencesAndConditions(Preference_and_Condition__c preference){
            preferenceId = preference.Id;
            value = preference.Value__c;
            type = preference.Type__c;
            startDate = preference.Start_Date__c;
            endDate = preference.End_Date__c;
            pereferenceName = preference.Name;
            weightage  = preference.Weightage__c == null ? '0' : preference.Weightage__c;
            durationRequired = preference.Duration_Required__c;
        }
    }
    
    
}