public without sharing class PsrStatusInfo {

    @AuraEnabled
    public static Boolean fetchApplicationWorkOrderInfo(String applicationId){
        Boolean isVallid = true;
        for (Application_Work_Order__c appWorkOrder :
        [SELECT Id,Application__c,Status__c  FROM Application_Work_Order__c WHERE Application__c =:applicationId]){
            if(appWorkOrder.Status__c == 'Ready for Review'){
                isVallid = false;
            }else{
                isVallid = true;
                break;
            }
        }

        return isVallid;
    }
 
    @AuraEnabled
    public static string createInspectionRecords(String applicationId){
            List<Application__c> applications = [SELECT Id,Inspector__c FROM Application__c WHERE Id =:applicationId];
            List<Inspection__c> inspectionList = new List<Inspection__c>();
            List<User> u =[SELECT Username,ContactId, Contact.Name,Contact.AccountId, Contact.Account.Name 
                            FROM User WHERE Id =: UserInfo.getUserId()];

            List<Application_Work_Order__c> applicationWorkOrderList = [SELECT Id,Application_Contact__r.Contact__r.AccountId FROM Application_Work_Order__c WHERE Application__c =:applicationId];
            for(Application_Work_Order__c applicationWorkOrder : applicationWorkOrderList){
                Inspection__c inspection = new Inspection__c();
                if(!u.isEmpty() && u[0].Contact.AccountId != null){
                    inspection.Account__c =u[0].Contact.AccountId;
                }else{
                    inspection.Account__c = applicationWorkOrder.Application_Contact__r.Contact__r.AccountId;
                }
                inspection.Application__c = applicationId;
                inspection.Application_Work_Order__c = applicationWorkOrder.Id;
                inspection.Inspection_Status__c = 'To Be Scheduled';
                inspection.Type__c = 'Inspection';
                inspection.Inspector__c = applications[0].Inspector__c;
                inspectionList.add(inspection);
            }
            for(Application_Work_Order__c applicationWorkOrder : applicationWorkOrderList){
                applicationWorkOrder.Status__c = 'Inspection Requested';
            }

            if(applicationWorkOrderList.size() > 0){
                update applicationWorkOrderList;
            }
            
            try {
              if(!inspectionList.isEmpty()){
                  insert inspectionList;
              }else{
                  return 'No Application Work Order are available';
              }
            } catch (Exception e) {
                return 'Something went wrong please try after some time';
            }
        
     return  'Inspection has been requested successfully';
    }
    @AuraEnabled
    public static Map<String,Decimal> getStatusInfo(){
        List<String> statusValuesList= new List<String>();
        Map<String,Decimal> statusToCountMap = new Map<String,Decimal>();
        for( Application__c ecr : [SELECT ID, Status__c FROM Application__c WHERE CreatedById = :userInfo.getUserId() ]){
            if(!statusToCountMap.containsKey(ecr.Status__c)){
                statusToCountMap.put(ecr.Status__c,0);
            }
            statusToCountMap.put(ecr.Status__c,statusToCountMap.get(ecr.Status__c)+1);
        }
        return statusToCountMap;
    }
    @AuraEnabled
    public static String fetchPicklistValue(String applicationId){
        System.debug('applicationId'+applicationId);
        List<Application__c> app =[SELECT ID,Payment_Mode__c FROM Application__c WHERE ID =: applicationId];
        String pickval = app.size()>0 ? app[0].Payment_Mode__c : '';
        System.debug(app[0].Payment_Mode__c);
        return pickval;
    }
    @AuraEnabled
    public static List<StatusWrapper> statusList(String status){
        List<StatusWrapper> wrapEcrList = new List<StatusWrapper>();
        //if(wrapEcrList == null) {

        for(Application__c ecr : [SELECT ID,Name, Status__c,Site_Name__c,Street__c,City__c,Zip__c,State__c,Owner.Name, Submission_Date__c,Physical_Street_address__c,
            (SELECT Id,Status__c FROM Application_Work_Orders__r)
          FROM Application__c
        WHERE Status__c = :status AND CreatedById = :userInfo.getUserId() ORDER BY CreatedDate DESC]) {
            // As each Account is processed we create a new wrapAccount object and add it to the wrapAccountList
            wrapEcrList.add(new StatusWrapper(ecr));
        }
        //}
        return wrapEcrList;
    }

    @AuraEnabled
    public static String downloadPermitFile(String recordId){
       System.debug('recordId: ' + recordId);
        String url = '/sfc/servlet.shepherd/version/download/';
        ContentDocumentLink conetentDocumentLinkObject = new ContentDocumentLink();
        String contentVersionId ='';
        String contentDocumentId = '';
        if(recordId != null && recordId != ''){
            for(ContentDocumentLink cld : [SELECT Id, ContentDocument.Title, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=: recordId]){
                System.debug('CLD: ' + cld);
                if(cld.ContentDocument.Title.contains('Permit')){
                    contentDocumentId = cld.ContentDocumentId;
                    break;
                }
            }
            contentVersionId = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId LIMIT 1].Id;
            //url = '/psr/sfc/servlet.shepherd/version/download/'+contentVersionId+'?asPdf=false&operationContext=CHATTER';
            url = System.Label.Portal_URL + 'showfile?id=' + contentDocumentId;
        }
        System.debug('URL Is : ' + url);
        return url;
    }

    @AuraEnabled 
    public static List<ApplicationDocumentWrapper> fetchApplicationDocuments(String applicationId){
        List<ApplicationDocumentWrapper> wrapperList = new List<ApplicationDocumentWrapper>();
        List<Id> applicationDocumentIds= new List<Id>();
        Map<Id,Application_Document__c> applicationDocumentMap= new Map<Id,Application_Document__c>();
        Map<Id,ApplicationDocumentWrapper> applicationDocumentWrapperMap= new Map<Id,ApplicationDocumentWrapper>();
        for(Application_Document__c ad :[SELECT ID,Document_Name__c,Status__c, Application__c,Is_Required__c FROM Application_Document__c WHERE Application__c = :applicationId]){
            applicationDocumentIds.add(ad.Id);
            applicationDocumentMap.put(ad.Id,ad);
            ApplicationDocumentWrapper adw = new ApplicationDocumentWrapper();
            adw.Id = ad.Id;
            adw.applicationId = ad.Id;
            adw.DocumentName =ad.Document_Name__c;
            adw.Status = ad.Status__c;
            adw.isRequired = ad.Is_Required__c;
            //adw.uploadDocName =cdl.ContentDocument.Title;
            wrapperList.add(adw);
            applicationDocumentWrapperMap.put(ad.Id,adw);
        }
        
        for(ContentDocumentLink cdl:[SELECT Id, LinkedEntityId, ContentDocument.Title,ContentDocument.Id
                                               FROM ContentDocumentLink 
                                               WHERE LinkedEntityId IN :applicationDocumentIds]){
              if(applicationDocumentMap.containsKey(cdl.LinkedEntityId)){
                  List<ContentDoc> condocList= applicationDocumentWrapperMap.get(cdl.LinkedEntityId).uploadDoc;
                  ContentDoc cd = new ContentDoc();
                  cd.contId= cdl.ContentDocument.Id;
                  cd.contDocumentName =cdl.ContentDocument.Title;
                  condocList.add(cd);
                  System.debug('cd'+cd);
                  System.debug('condocList'+condocList);
              }                                     

        }
        return wrapperList;
        //return [SELECT ID,Document_Name__c,Status__c, Application__c FROM Application_Document__c WHERE Application__c = :applicationId ];
    }
    public class StatusWrapper {
        @AuraEnabled public String ID {get; set;}
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public String Status {get; set;}
        @AuraEnabled public String SiteName {get; set;}
        @AuraEnabled public String Street {get; set;}
        @AuraEnabled public String City {get; set;}
        @AuraEnabled public String Zip {get; set;}
        @AuraEnabled public String State {get; set;}
        @AuraEnabled public Boolean statusValue{get;set;}
        @AuraEnabled public Boolean isNotDraft{get;set;}
        @AuraEnabled public String ownerName{get;set;}
        @AuraEnabled public String submmisionDate{get;set;}
        @AuraEnabled public Boolean statusValueApp{get;set;}
        @AuraEnabled public Boolean showRequestInspection{get;set;}
        @AuraEnabled public String PhysicalStreet {get;set;}
  

        public StatusWrapper(Application__c ecr) {
            this.ID = ecr.ID;
            this.Name =ecr.Name;
            this.ownerName = ecr.Owner.Name;
            this.Status =ecr.Status__c;
            this.statusValue = ecr.Status__c == 'Approved' || ecr.Status__c == 'Closed' ? true : false;
            this.statusValueApp = ecr.Status__c == 'Approved' ? true : false;
            this.isNotDraft = ecr.Status__c != 'Draft' ? true : false;
            this.SiteName =ecr.Site_Name__c;
            this.Street =ecr.Street__c;
            this.City =ecr.City__c;
            this.Zip =ecr.Zip__c;
            this.State =ecr.State__c;
            this.PhysicalStreet = ecr.Physical_Street_address__c;
            //System.debug('Date Updated ' + ecr.Submission_Date__c.month() + '/' + ecr.Submission_Date__c.day() + '/' + ecr.Submission_Date__c.year());
            if(ecr.Submission_Date__c != null){
                this.submmisionDate = (ecr.Submission_Date__c.month() + '/' + ecr.Submission_Date__c.day() + '/' + ecr.Submission_Date__c.year());
            }else{
                this.submmisionDate = '';
            }
            for(Application_Work_Order__c app : ecr.Application_Work_Orders__r){
                if(app.Status__c == 'Ready for Review' && this.showRequestInspection != false){
                    this.showRequestInspection = true;
                }
                else{
                    this.showRequestInspection = false;
                }
            }
            
        }
    }

    public class ApplicationDocumentWrapper{
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String DocumentName {get; set;}
        @AuraEnabled public String Status {get; set;}
        @AuraEnabled public String applicationId {get; set;}
        @AuraEnabled public string uploadDocName {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        @AuraEnabled public List<ContentDoc> uploadDoc{get;set;}
        public ApplicationDocumentWrapper(){
            uploadDoc = new List<ContentDoc>();
        }

        
    }
    public class ContentDoc {
            @AuraEnabled public String contId {get; set;}
            @AuraEnabled public String contDocumentName {get; set;} 
    }
    
}