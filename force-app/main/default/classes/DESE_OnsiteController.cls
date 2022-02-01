public with sharing class DESE_OnsiteController {

    @AuraEnabled
    public static List<Onsite_Activity_Item__c> fetchOnsiteItems(Id VisitId){
        try {
            return [SELECT Id,Name,Follow_up_notes__c,Status__c,Visitation__c FROM Onsite_Activity_Item__c WHERE Account__c  = :VisitId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createNewOnsiteItem(String VisitId, String name, String notes){
        try {
            Onsite_Activity_Item__c newItem = new Onsite_Activity_Item__c(Account__c  = VisitId,Status__c='Not Started', Follow_up_notes__c=notes,Name = name);
            insert newItem;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Onsite_Activity_Item__c> generateItems(Id VisitId){
        try {
            List<Onsite_Activity_Item__c> newItems = new List<Onsite_Activity_Item__c>();
            List<String> itemNames = new List<String>{'Student Identification','Community Involvement','Student Support Services','Program Plan and Evaluation','Record keeping'};
            for(String name:itemNames){
                String note = '';
                if(name == 'Tour the program'){
                    note = '<ol><li>Explain reason for visit.</li><li>Request following documents:<ol><li>Weekly and Monthly Restraint Review Logs.</li><li>Student Records: 2 day, 2 res</li><li>Staff Records: 2 day, 2 res</li><li>Set up Interviews:</li></ol></li></ol>';
                }
                newItems.add( new Onsite_Activity_Item__c (Name = name,Account__c  = VisitId,Status__c = 'Not Started',Follow_up_notes__c = note));
            }
            insert newItems;
            return newItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string copyToOthers(Id VisitId, List<Onsite_Activity_Item__c> items){
        try {
            List<Onsite_Activity_Item__c> newItems = new List<Onsite_Activity_Item__c>();
            for(Onsite_Activity_Item__c item:items){
                newItems.add( new Onsite_Activity_Item__c (Name = item.Name,Account__c  = VisitId,Follow_up_notes__c = item.Follow_up_notes__c));
            }
            insert newItems;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateRecords(String jsonData){
        try {
            List<Onsite_Activity_Item__c> recordList = (List<Onsite_Activity_Item__c>)JSON.deserialize(jsonData, List<Onsite_Activity_Item__c>.class);
            /*for(Onsite_Activity_Item__c item : recordList){
                if(item.Status__c == 'Submit For Approval'){
                    item.Status__c = 'Submitted For Approval';
                }
            }*/
            update recordList;
            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


     @AuraEnabled
    public static List<Account> getPrograms(String AccountId){
        try {
            
            List<Account> recs = [SELECT Id,Umbrella__c FROM Account WHERE Id = :AccountId];
            if(recs.size() == 1){
                Id accId ;
                if(recs[0].Umbrella__c == null){
                    accId = recs[0].Id;
                }
                else{
                    accId = recs[0].Umbrella__c;
                }
                //System.assert(false, accId);
                return [Select Id,name from Account where Umbrella__c = :accId];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendEmailToUsers(String recordId){
        List<EmailTemplate> lstEmailTemplate = [SELECT Id, Body, DeveloperName, HtmlValue, Name from EmailTemplate where DeveloperName='Orientation_Email_Template'];
        Messaging.SingleEmailMessage Objemail = new Messaging.SingleEmailMessage();
        Objemail.setToAddresses(new List<String>{'vikas.rathi@mtxb2b.com'});
        Objemail.setTemplateId(lstEmailTemplate[0].Id);
        Objemail.setTargetObjectId('00303000003HxHlAAK');
        Objemail.setWhatId(recordId);
        Objemail.setSaveAsActivity(false);
        Messaging.SendEmailResult [] rsendmailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Objemail});

        Id conDocument = '06903000001rVzUAAU';

        List<ContentDocumentLink> contentList = [SELECT ID,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId and ContentDocumentId = :conDocument];
        if(contentList.size()>0){
            delete contentList;
        }
         //Insert ContentDocumentLink
         ContentDocumentLink cDocLink = new ContentDocumentLink();
         cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
         //cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
         cDocLink.LinkedEntityId = recordId;//Add attachment parentId
         cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
         cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
         Insert cDocLink;
    }
}