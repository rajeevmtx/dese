public class AdultProtectiveServiceController {
    
    @AuraEnabled
    public static Case createCase(String JsonData){
        try{
            CaseObjectInput caseObjInp = (CaseObjectInput) JSON.deserialize(JsonData, CaseObjectInput.class);

            Case caseRec = caseObjInp.getCase();
            caseRec.Status = 'Draft';
            caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Incident').getRecordTypeId();

            upsert caseRec; 

            return caseRec;
        }
        catch(Exception e){
            throw new AurahandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createPartiesInvolved(String JsonData){
        try{
            PartiesInvolvedInput pinv = (PartiesInvolvedInput) JSON.deserialize(JsonData, PartiesInvolvedInput.class);

            Contact con = new Contact();
            con.FirstName = pinv.FirstName;
            con.LastName = pinv.LastName;
            con.Sex__c = pinv.Gender;
            insert con;

            Parties_Involved__c pi = new Parties_Involved__c();
            pi.Relation_to_AV__c = pinv.Relation_to_AV;
            pi.Party_Involved_Type__c = pinv.Type;
            pi.Party__c = con.Id;
            pi.Case__c = pinv.caseId;
            insert pi;
        }
        catch(Exception e){
            throw new AurahandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createVictim(Contact contact, Case caserec){
        try{
            upsert contact;
            caserec.ContactId = contact.Id;
            String subject = '';
            if(contact.FirstName != null)
                subject += contact.FirstName;
            if(contact.LastName != null)
                subject += subject == '' ? contact.FirstName : ' ' + contact.FirstName;
            if(contact.MailingStreet != null)
                subject +=  ' - ' + contact.MailingStreet;
            if(contact.MailingCity != null)
                subject +=  subject.contains(' - ') ? ', ' + contact.MailingCity : ' - ' + contact.MailingCity;
            if(contact.MailingState != null)
                subject +=  subject.contains(' - ') ? ', ' + contact.MailingState : ' - ' + contact.MailingState;
            if(contact.MailingPostalCode != null)
                subject +=  subject.contains(' - ') ? ', ' + contact.MailingPostalCode : ' - ' + contact.MailingPostalCode;
            // if(contact.MailingPostalCode != null)
            //     subject +=  subject.contains(' - ') ? ', ' + contact.MailingPostalCode : ' - ' + contact.MailingPostalCode;
            caserec.Subject =  subject;//contact.FirstName + ' ' + contact.LastName + ' - ' + contact.MailingStreet + ',' + contact.MailingCity + ',' + contact.MailingState + ',' + contact.MailingPostalCode;
            upsert caserec; 
            // caserec = [SELECT Id, ContactId FROM Case WHERE Id =: caserec.Id];
            // contact.Id = caserec.ContactId;
            return 'success';
        }
        catch(Exception e){
            throw new AurahandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Parties_Involved__c> getAllAbusers(Id caseId, String type) {
        return  [SELECT Id, Party__c, Party__r.FirstName,Party__r.LastName,Party__r.Sex__c, 
        Collateral_Type__c, Resource_Type__c, Relation_to_AV__c 
        FROM Parties_Involved__c WHERE Case__c =: caseId AND Party_Involved_Type__c =: type];
    }

    @AuraEnabled
    public static String updateCase(Id caseId) {
        Case selectedCase = new Case(Id = caseId, Status = 'Submitted');
        try {
            update selectedCase;
            return 'success';
        } catch (DMLException ex) {
            return ex.getDMLMessage(0);
        }
    }
    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName){
        List<SelectOptionWrapper> opts = new List<SelectOptionWrapper>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            opts.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
        }    
        
        return opts;
    }

    public class PartiesInvolvedInput{
        @AuraEnabled public String Relation_to_AV;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String Gender;
        @AuraEnabled public String Type;
        @AuraEnabled public String caseId;
        @AuraEnabled public Id Id;
    }

    public class CaseObjectInput{
        @AuraEnabled public DateTime Date_and_Time_of_Incident;
        @AuraEnabled public String Street;
        @AuraEnabled public String City;
        @AuraEnabled public String County;
        @AuraEnabled public Decimal Zip_Code;
        @AuraEnabled public String Incident_Occurred_At;
        @AuraEnabled public String Incident_Other;
        @AuraEnabled public String Institution_Reporting_Facility;
        @AuraEnabled public String Abuse_Resulted_In;
        @AuraEnabled public String Abuse_Perpetrated_by_Others;
        @AuraEnabled public String Physical_Abuse;
        @AuraEnabled public Id Id;

        public case getCase(){
            Case caseObj = new Case();
            caseObj.Id = Id;
            caseObj.Date_and_Time_of_Incident__c = Date_and_Time_of_Incident;
            caseObj.Street__c = Street;
            caseObj.City__c = City;
            caseObj.County__c = County;
            caseObj.Zip_Code__c = Zip_Code;
            caseObj.Incident_Occurred_At__c = Incident_Occurred_At;
            caseObj.Incident_Other__c = Incident_Other;
            caseObj.Institution_Reporting_Facility__c = Institution_Reporting_Facility;
            caseObj.Abuse_Resulted_In__c = Abuse_Resulted_In;
            caseObj.Abuse_Perpetrated_by_Others__c = Abuse_Perpetrated_by_Others;
            caseObj.Physical_Abuse__c = Physical_Abuse;
            return caseObj;
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
}