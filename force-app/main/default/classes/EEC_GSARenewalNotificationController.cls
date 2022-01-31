global with sharing class EEC_GSARenewalNotificationController {
    public String selectedRegion                        { get; set; }
    public List<SelectOption> regionList                { get; set; }
    private Map<Id, Region__c> regionMap;
    public String selectedRenewalType                   { get; set; } 
    public string selectedProgramType                   { get; set; }
    public String usermeetingId                         { get; set; }
    public Contact contact                              { get; set; }
    public String orgWideAddress                        { get; set; }
    public EmailTemplate emailTemplate                  { get; set; }
    public String regionAddress                         { get; set; }
    public String regionPhone                           { get; set; }
    public String regionFax                             { get; set; }
    public String attachmentIdString                    { get; set; }
    public Boolean showAttachmentComponent              { get; set; }
    public String deletedAttachmentId                   { get; set; }
    public String pageErrorMessage                      { get; set; }
    public EEC_GSARenewalNotificationController() {
        contact = new Contact();
        deletedAttachmentId = '';
        pageErrorMessage = '';
        showAttachmentComponent = false;
        regionList = new List<SelectOption>();
        regionMap = new Map<Id, Region__c>();
        regionAddress = '';
        regionPhone = '';
        regionFax = '';
        attachmentIdString = '';
        usermeetingId = '';
        List<OrgWideEmailAddress> orgList = [SELECT Id
                                            FROM OrgWideEmailAddress
                                            WHERE DisplayName = 'EEC LEAD Alert'];
        emailTemplate = [SELECT Id, Name
                        FROM EmailTemplate
                        WHERE DeveloperName = 'GSA_Renewal_Notification_Template'];
        orgWideAddress = !orgList.isEmpty() ? orgList[0].Id : '';
        User user = [SELECT Id, Region__c FROM User WHERE Id = :userInfo.getUserId()];
        regionList.add(new SelectOption('', '--None--'));
        for (Region__c region : [SELECT Id, Name,City__c, Email__c, State__c,
                                        Fax__c, Number__c, Phone__c, Street__c, Zip__c
                                    FROM Region__c
                                    WHERE RecordType.DeveloperName = :EEC_Constants.REGION_LICENSING_REGION
                                    Order By Number__c]) {
            regionList.add(new SelectOption(region.Id, region.Name));
            regionMap.put(region.Id, region);
            if (String.isNotBlank(user.Region__c) && user.Region__c == region.name) {
                selectedRegion = region.Id;
            }
        }
    }
    public List<Attachment> getAttachmentList() {
        List<Attachment> attachmentList = new List<Attachment>();
        if(String.isNotBlank(attachmentIdString)) {
            Set<Id> attachmentIdSet = (Set<Id>)JSON.deserialize(attachmentIdString, Set<Id>.class);
            attachmentList = [SELECT Id, Name, BodyLength FROM Attachment WHERE Id IN :attachmentIdSet];
        }
        return attachmentList;
    }
    public List<Account> getProviderWrapperList() {
        List<Account> providerWrapperList = new List<Account>();
        Date startRenewalDate = contact.BRC_Expiration_Date__c;
        Date endRenewalDate = contact.BRC_Renewal_Date__c;
        if(String.isNotBlank(selectedRegion)) {
            String query = 'SELECT Id, Name,Provider_Status__c, RecordType.Name, Renewal_date__c,' +
                                'Provider_Address_1__c, Provider_City__r.Name,State__c,Provider_Zip_Code__c, ' +
                                'Provider_Email__c,License_Status__c,OwnerId ' +
                            'FROM Account ' +
                            'WHERE Renewal_date__c >= :startRenewalDate' +
                            ' AND Renewal_date__c <= :endRenewalDate' +
                            ' AND Region__c = \'' + selectedRegion + '\'' +
                            ' AND Provider_Email__c != null' +
                            ' AND Provider_Status__c != \'' + EEC_Constants.PROVIDER_STATUS_CLOSED + '\'' +
                            ' AND Provider_Status__c != \'' + EEC_Constants.PROVIDER_STATUS_VOLUNTARY_CLOSURE + '\'';
            if (selectedRenewalType == 'Renewal Meeting' && startRenewalDate != null && endRenewalDate != null) {
                query += ' AND Is_GSA__c = true LIMIT 999';
                providerWrapperList = Database.query(query);
            } else if (selectedProgramType == 'FCC' && startRenewalDate != null && endRenewalDate != null) {
                query += ' AND Is_FCC__c = true AND Id NOT IN (SELECT AccountId FROM USER) LIMIT 999';
                providerWrapperList = Database.query(query);
            } else if (selectedProgramType == 'FCC Assistant' && startRenewalDate != null && endRenewalDate != null) {
                query += ' AND RecordType.Name = \'' + EEC_Constants.PRO_FCC_ASSISTANT + '\' AND Id NOT IN (SELECT AccountId FROM USER) LIMIT 999';
                providerWrapperList = Database.query(query);
            }
        }
        return providerWrapperList;
    }
    public List<MeetingWrapper> getMeetingList() {
        List<MeetingWrapper> meetingList = new List<MeetingWrapper>();
        if (String.isNotBlank(selectedRegion)) {
            for (Provider_Meeting__c meeting : [SELECT Id, Scheduled_Start__c, Scheduled_End__c
                                                FROM Provider_Meeting__c
                                                WHERE Meeting_Type__c = 'Renewal (GSA)'
                                                AND Meeting_Region__c = :selectedRegion
                                                AND Scheduled_Start__c != null
                                                AND Scheduled_End__c != null
                                                AND Meeting_Status__c = 'Open for registration'
                                                ORDER BY Scheduled_Start__c]) {
                meetingList.add(new MeetingWrapper(meeting));
            }
            if(!meetingList.isEmpty()) {
                usermeetingId = meetingList[0].meetingId;
            }
            if (String.isNotBlank(selectedRegion)) {
                Region__c region = regionMap.get(selectedRegion);
                regionAddress = region.Street__c + ', ' + region.City__c + ', ' + region.State__c + ', ' + region.Zip__c;
                regionPhone = region.Phone__c;
                regionFax = region.Fax__c;
            }
        }
        return meetingList;
    }
    @RemoteAction
    public static String sendEmailToProvider(String emailTemplateId, String accountIdArray, 
        String attachmentIdArray, String meetingHtml, String regionAddress, String regionPhone,
        String regionFax, String additionalComments, String orgWideAddress, String emailTemplateName) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> emailAttachmentList = new List<Messaging.Emailfileattachment>();
        if(String.isNotBlank(attachmentIdArray)) {
            Set<Id> attachmentIdSet = (Set<Id>)JSON.deserialize(attachmentIdArray, Set<Id>.class);
            if (!attachmentIdSet.isEmpty()) {
                List<Attachment> attachmentList = new List<Attachment>();
                for (Attachment attachment : [SELECT Name, Body FROM Attachment WHERE Id IN :attachmentIdSet]) {
                    Messaging.Emailfileattachment emailAttach = new Messaging.Emailfileattachment();
                    emailAttach.setFileName(attachment.Name);
                    emailAttach.setBody(attachment.body);
                    emailAttachmentList.add(emailAttach);
                    attachmentList.add(attachment);
                }
                delete attachmentList;
            }
        }
        if(String.isNotBlank(accountIdArray)) {
            Set<Id> providerIdSet = (Set<Id>)JSON.deserialize(accountIdArray, Set<Id>.class);
            Map<Id, Account> accountIdDetailMap = new Map<Id, Account>([SELECT Id, Name, Renewal_date__c, Provider_Email__c,
                                                                            OwnerId  
                                                                        FROM Account
                                                                        WHERE Id IN :providerIdSet]);
            String templateBody = '';
            List<Task> taskList = new List<Task>();
            Messaging.SingleEmailMessage tempSingleEmail = Messaging.renderStoredEmailTemplate(emailTemplateId, null, null);
            Messaging.SingleEmailMessage emailToBeSent;
            Task task;
            for(Id providerId : providerIdSet) {
                templateBody = Test.isRunningTest() ? tempSingleEmail.plaintextbody : tempSingleEmail.htmlbody;
                templateBody = templateBody.replace('[Meeting List]', meetingHTML);
                templateBody = templateBody.replace('[Address]', regionAddress);
                templateBody = templateBody.replace('[Phone]', regionPhone);
                templateBody = templateBody.replace('[Fax]', regionFax);
                templateBody = templateBody.replace('[Provider Name]', accountIdDetailMap.get(providerId).Name);
                templateBody = templateBody.replace('[ProviderName]', accountIdDetailMap.get(providerId).Name);
                templateBody = templateBody.replace('[Provider Renewal Date]', String.valueOf(accountIdDetailMap.get(providerId).Renewal_date__c));
                templateBody = templateBody.replace('[Additional Comments]', additionalComments);
                emailToBeSent = new Messaging.SingleEmailMessage();
                emailToBeSent.setOrgWideEmailAddressId(orgWideAddress);
                emailToBeSent.setSubject(tempSingleEmail.subject);
                emailToBeSent.setHtmlBody(templateBody);
                emailToBeSent.setPlainTextBody(tempSingleEmail.PlainTextBody);
                emailToBeSent.setToAddresses(new List<String>{accountIdDetailMap.get(providerId).Provider_Email__c});
                emailToBeSent.setFileAttachments(emailAttachmentList);
                emailList.add(emailToBeSent);
                task = new Task();
                task.Status = 'Completed';
                task.Priority = 'Normal';
                task.OwnerId = accountIdDetailMap.get(providerId).OwnerId;
                task.Subject = emailTemplateName + ' Notification';
                task.WhatId = providerId;
                task.Description = 'EmailTemplate-GSA_Renewal_Notification_Template';
                task.ActivityDate = Date.today();
                taskList.add(task);
            }
            if(!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            } 
            if(!taskList.isEmpty()) {
                insert taskList;
            }
            return 'Success';
        } else {
            return 'Error occured contact to system administrator.';
        }
    }
    @RemoteAction @ReadOnly
    public static String retrieveEmailTemplateBody(String emailTemplateId) {
        return JSON.serialize(Messaging.renderStoredEmailTemplate(emailTemplateId, null, null));
    }
    public void deleteAttachmentRecord() {
        if(String.isNotBlank(attachmentIdString) && String.isNotBlank(deletedAttachmentId)) {
            Set<Id> attachmentIdSet = (Set<Id>)JSON.deserialize(attachmentIdString, Set<Id>.class);
            if (!attachmentIdSet.isEmpty()) {
                attachmentIdSet.remove(deletedAttachmentId);
                try {
                    delete [SELECT Id FROM Attachment WHERE Id =: deletedAttachmentId];    
                    attachmentIdString = JSON.serialize(attachmentIdSet);    
                } catch(Exception ex) {
                    pageErrorMessage = 'Error occured ' + ex.getMessage() + ' line number ' + ex.getLineNumber();
                }
            }
        }
    } 
    public class MeetingWrapper {
        public String timings    { get; set; }
        public String meetingId  { get; set; }
        public MeetingWrapper(Provider_Meeting__c meeting) {
            this.meetingId = meeting.Id;
            this.timings = meeting.Scheduled_Start__c.format('MMM d, yyyy h:mm a','America/New_York') + ' to ' + meeting.Scheduled_End__c.format('h:mm a','America/New_York');
        }
    }
}