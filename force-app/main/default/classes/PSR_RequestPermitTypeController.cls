public class PSR_RequestPermitTypeController {
    
    @AuraEnabled
    public static List<RecordWrapper> fetchRequestPermitType(){        
        List<RecordWrapper> cases = new List<RecordWrapper>();
        
        User usrInfo = [Select id, Contact.AccountId from User Where id=: UserInfo.getUserId() ];

        for( Case caseRec : [Select Id,Status,CaseNumber,Description,CreatedDate,Request_Permit_Type__c from Case
        Where AccountId =: usrInfo.Contact.AccountId AND Request_Permit_Type__c != null] ){
            cases.add( new RecordWrapper(caseRec) );
        }

        return cases;
    }

     @AuraEnabled
    public static void saveRequestPermitType(String jsonData){        
        Map<String, object> queryParams = (Map<String, object>) JSON.deserializeUntyped(jsonData);

        try{
            User usrInfo = [Select id, Contact.AccountId,ContactId from User Where id=: UserInfo.getUserId() ];

            Case caseRec = new Case();
            caseRec.Description = (String) queryParams.get('Description');
            caseRec.Request_Permit_Type__c = (String) queryParams.get('Request_Permit_Type__c');
            caseRec.Status = 'Pending Approval'; 
            caseRec.Origin = 'Web';
            caseRec.AccountId = usrInfo.Contact.AccountId;
            caseRec.ContactId = usrInfo.ContactId;
            insert caseRec; 
        }
        catch(Exception e){
            throw new AuraHandledException('Error: '+ e.getMessage() );
        }
    }

    public class RecordWrapper{
        @AuraEnabled public sObject record;

        public RecordWrapper(sObject record){
            this.record = record;
        }
    }
}