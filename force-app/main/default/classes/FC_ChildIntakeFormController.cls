public without sharing class FC_ChildIntakeFormController {

    @AuraEnabled
    public static List<FosterCare> fetchPartiesInvolved(String caseId){
        System.debug('caseId>>>' + caseId);
        List<FosterCare> listOfFosterCare = new List<FosterCare>();
        try{
            if(String.isNotBlank(caseId) ){
                for(Parties_Involved__c piRecord : [SELECT Id, Party_Involved_Type__c, Collateral_Type__c, Relation_to_AV__c, Resource_Type__c,Party__c, Party__r.FirstName, Party__r.LastName
                                                            FROM Parties_Involved__c 
                                                            WHERE Case__c =: caseId]){
                    FosterCare fosterCareObject = new FosterCare();
                    fosterCareObject.partyInvolvedId = piRecord.Id;
                    fosterCareObject.contactId = piRecord.Party__c;
                    fosterCareObject.partyFirstName = piRecord.Party__r.FirstName;
                    fosterCareObject.partyLastName = piRecord.Party__r.LastName;
                    fosterCareObject.partyInvolvedType = piRecord.Party_Involved_Type__c;
                    fosterCareObject.collateralType = piRecord.Collateral_Type__c;
                    fosterCareObject.relationToAV = piRecord.Relation_to_AV__c;
                    fosterCareObject.resourceType = piRecord.Resource_Type__c;
                    

                    listOfFosterCare.add(fosterCareObject);            
                }
                return listOfFosterCare;
            }
            return null;
        }catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }

    @AuraEnabled
    public static List<AdditionalInformation> fetchAdditionalInformation(){
        List<AdditionalInformation> additionalInformationList = new List<AdditionalInformation>(); 
        Map<String,List<String>> lableWithTypeMap = new Map<String,List<String>>();

        try{
            for(Preference_Configuration__mdt metadata : [  SELECT Id,MasterLabel, Values__c 
                                                            FROM Preference_Configuration__mdt 
                                                            WHERE Values__c != null 
                                                            AND Related_To__c = 'Child']){
                List<String> typeList = metadata.Values__c.split(',');
                lableWithTypeMap.put(metadata.MasterLabel,typeList);
            }
            for(String str : lableWithTypeMap.keySet()){
            System.debug('str: '+str);
                List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>(); 
                for(String picklist : lableWithTypeMap.get(str)){
                    optionList.add(new SelectOptionWrapper(picklist,picklist));
                }
                additionalInformationList.add(new AdditionalInformation(str, false, optionList));
            }
            return additionalInformationList;
        }catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }

    @AuraEnabled
    public static Id createCase(String caseData){
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        System.debug('jsondata>>>' + caseData);
        try{
            FosterCare fosterCare = (FosterCare) JSON.deserialize(caseData, FosterCare.class);
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = caseRecordTypeId;
            caseRec.First_Name__c = fosterCare.childFirstName;
            caseRec.Last_Name__c = fosterCare.childLastName;
            caseRec.Subject = fosterCare.childFirstName + ' ' + fosterCare.childLastName;
            caseRec.Street__c = fosterCare.streetaddress;
            caseRec.City__c = fosterCare.city;
            caseRec.State__c = fosterCare.state;
            caseRec.Zip_Code__c = Decimal.ValueOf(fosterCare.zipcode);
            caseRec.Status = 'New';
            caseRec.Origin = 'Web';
            INSERT caseRec;

            return caseRec.Id;
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }

    @AuraEnabled
    public static Id createCaseForInternal(String caseData){
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Foster_Care_Child').getRecordTypeId();
        System.debug('jsondata>>>' + caseData);
        try{
            FosterCare fosterCare = (FosterCare) JSON.deserialize(caseData, FosterCare.class);
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = caseRecordTypeId;
            caseRec.First_Name__c = fosterCare.childFirstName;
            caseRec.Last_Name__c = fosterCare.childLastName;
            caseRec.Child_Age_Group__c = fosterCare.ageGroup;
            caseRec.Subject = fosterCare.childFirstName + ' ' + fosterCare.childLastName;
            caseRec.Street__c = fosterCare.streetaddress;
            caseRec.City__c = fosterCare.city;
            caseRec.State__c = fosterCare.state;
            caseRec.Zip_Code__c = Decimal.ValueOf(fosterCare.zipcode);
            caseRec.Status = 'New';
            caseRec.Origin = 'Web';
            INSERT caseRec;

            return caseRec.Id;
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }

    @AuraEnabled
    public static void saveAdditionalInformation(String jsondata, String caseId){
        try{
            Id recordTypeId = Schema.SObjectType.Preference_and_Condition__c.getRecordTypeInfosByDeveloperName().get('Foster_Care_Child').getRecordTypeId();
            List<AdditionalInformation> additionalInformationList = (List<AdditionalInformation>) JSON.deserialize(jsondata, List<AdditionalInformation>.class);
            System.debug('additionalInformationList>>>>' + additionalInformationList);
            List<Preference_and_Condition__c> preferenceList = new List<Preference_and_Condition__c>();
            for(AdditionalInformation information : additionalInformationList){
                Preference_and_Condition__c preference = new Preference_and_Condition__c();
                preference.Type__c = information.question;
                preference.Value__c = information.selected ? 'Yes' : 'No';
                preference.Case__c = caseId;
                preference.RecordTypeId = recordTypeId;
                preferenceList.add(preference);
            }
            if(!preferenceList.isEmpty()){
                insert preferenceList;
            }
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }

    @AuraEnabled
    public static void saveData(String jsondata, String caseId){
        System.debug('jsondata>>>' + jsondata);
        System.debug('caseId>>>' + caseId);
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Foster_Care_Child').getRecordTypeId();
        try{
            FosterCare fosterCare = (FosterCare) JSON.deserialize(jsondata, FosterCare.class);
            System.debug('fosterCare>>>' + fosterCare);
            Contact contactRec = new Contact();
            if(fosterCare.contactId != null)
                contactRec.Id = fosterCare.contactId;

            contactRec.FirstName = fosterCare.partyFirstName;
            contactRec.LastName = fosterCare.partyLastName;
            contactRec.RecordTypeId = contactRecordTypeId;
            UPSERT contactRec;
            System.debug('contactRec>>>' + contactRec);
            if(String.isNotBlank(caseId) && contactRec.Id != null){
                Parties_Involved__c partiesInvolved = new Parties_Involved__c(Case__c = caseId);
                if(fosterCare.partyInvolvedId != null)
                    partiesInvolved.Id  = fosterCare.partyInvolvedId;

                partiesInvolved.Party__c = contactRec.Id;
                //partiesInvolved.Case__c = caseId;
                partiesInvolved.Party_Involved_Type__c = fosterCare.partyInvolvedType;
                partiesInvolved.Collateral_Type__c = fosterCare.collateralType;
                partiesInvolved.Relation_to_AV__c = fosterCare.relationToAV;
                partiesInvolved.Resource_Type__c = fosterCare.resourceType;
                UPSERT partiesInvolved;
            }
            if(contactRec.Id != null){
                List<Preference_and_Condition__c> preferenceList = new List<Preference_and_Condition__c>();
                for(Preference_and_Condition__c preference : [SELECT Id,Foster_Care_Child__c FROM Preference_and_Condition__c WHERE Case__c =: caseId]){
                    preference.Foster_Care_Child__c = contactRec.Id;
                    preferenceList.add(preference);
                }
                if(!preferenceList.isEmpty()){
                    update preferenceList;
                }
            }
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage() );
        }
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName){
        List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>(); 
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            optionList.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
        }    
        return optionList;
    }

    @AuraEnabled
    public static void updateCase(String caseId){
        if(String.isNotBlank(caseId)){
            Case caseToBeUpdate = new Case();
            for(Case caseRec : [SELECT Id FROM Case WHERE Id =: caseId]){
                caseToBeUpdate.Id = caseRec.Id;
                caseToBeUpdate.Status = 'Submitted';
            }
            update caseToBeUpdate;
        }
    }

    public class SelectOptionWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
        }
    }

    public class FosterCare{

        @AuraEnabled public String childFirstName;
        @AuraEnabled public String childLastName;
        @AuraEnabled public String ageGroup;

        @AuraEnabled public String partyInvolvedId;
        @AuraEnabled public String partyFirstName;
        @AuraEnabled public String partyLastName;
        @AuraEnabled public String partyInvolvedType;
        @AuraEnabled public String collateralType;
        @AuraEnabled public String relationToAV;
        @AuraEnabled public String resourceType;

        @AuraEnabled public String streetaddress;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zipcode;

        @AuraEnabled public String party;
        @AuraEnabled public String caseRec;
        @AuraEnabled public String contactId;

        public FosterCare(){
            partyInvolvedId = '';
            contactId = '';
            childFirstName = '';
            childLastName = '';
            ageGroup = '';
            partyFirstName = '';
            partyLastName = '';
            partyInvolvedType = '';
            collateralType = '';
            relationToAV = '';
            resourceType = '';
            party = '';
            caseRec = '';
        }
    }

    public class AdditionalInformation{
        @AuraEnabled public String question;
        @AuraEnabled public Boolean selected;
        @AuraEnabled public List<SelectOptionWrapper> options;
        public AdditionalInformation(string question, boolean selected, List<SelectOptionWrapper> options){
            this.question = question;
            this.selected = selected;
            this.options = options;
        }
    }

    @AuraEnabled
    public static void saveNeglectAbuseData(SObject caseData){
        try {
            Case caseNow = (Case) caseData;
            update caseNow;
        } catch (Exception e) {
            System.debug('error: '+e.getMessage());
            throw new AuraHandledException(e.getMessage() + ' ' + e.getLineNumber());
        }
    }
}