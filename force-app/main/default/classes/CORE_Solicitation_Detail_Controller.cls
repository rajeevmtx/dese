/*
* Class Name: CORE_Solicitation_Detail_Controller
* Description: Controller class of CORE_Solicitation_Detail_Page
*/

public without sharing class CORE_Solicitation_Detail_Controller extends ProposalBase_Controller {
    public Program_Version__c solicitationRec {get;set;}
    public String solicitationId {get; set;}
    public boolean isProgramExist{get; set;}
    public Boolean hasError{get; set;}
    public String errorMessage{get; set;}
    public String pageTitle {get; set;}
    public String metaTagDescription {get; set;}
    public List<Program_Content__c> documentProgramContentList {get; set;}
    public Map<Id, String> programContentIdToAttachmentTypeMap {get; set;}
    public Map<Id, String> programContentIdToScriptTitleMap {get; set;}
    public String userIP {get; set;}
    public Boolean isDetailShown {get; set;}
    public String dueDate {get; set;} 
    
    public CORE_Solicitation_Detail_Controller() {
        documentProgramContentList = new List<Program_Content__c>();
        solicitationId = Apexpages.currentPage().getParameters().get('SolicitationId');
        UserIP = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        String documentRecTypeId = Utility_RecordType_Helper.getRecordType('Program_Content__c', 'Document').Id;
        
        List<DateTime> lstDueDates = new List<DateTime>();
        
        List<Program_Version__c> solicitationList = [SELECT Name, Concept_Paper__c, Concept_Paper_Pass_Score__c, Description__c, Short_Description__c,Solicitation_Beta_Review__c,
                                                     Submission_Outside_Salesforce__c, External_Link__c, NY_Green_Bank_RFP__c,
                                                     Display_Instructions_and_Portal_Guide__c, Manual_Submission_Only__c,Solicitation_Type__c,
                                                     Solicitation_Number__c,
                                                     ( SELECT  Due_Date__c, Concept_Paper_Due_Date__c
                                                      FROM    Solicitation__r
                                                      WHERE   Status__c = 'Open' Order BY Concept_Paper_Due_Date__c, Due_Date__c),
                                                     (SELECT Id FROM Program_Contents__r WHERE RecordTypeId =: documentRecTypeId)
                                                     FROM Program_Version__c WHERE Id =: solicitationId];
        if(solicitationList.size() > 0) {
            solicitationRec = solicitationList[0];
            if(solicitationRec.NY_Green_Bank_RFP__c) {
                pageTitle = (String.isNotBlank(solicitationRec.Solicitation_Number__c) ? solicitationRec.Solicitation_Number__c + ': ' :'') + solicitationRec.Name;
            } else {
                pageTitle = solicitationRec.Name + (String.isNotBlank(solicitationRec.Solicitation_Number__c) ? ' (' + solicitationRec.Solicitation_Number__c + ')' :'');
            }
            metaTagDescription = (solicitationRec.Description__c != null && solicitationRec.Description__c.length() > 156) ? solicitationRec.Description__c.subString(0,155) + ' ...' : solicitationRec.Description__c;
            
            
            // S-01055 - Multi round with concept paper and parallel activities
            /*
if(solicitationRec.Solicitation__r.size() > 0) {
if(solicitationRec.Solicitation__r[0].Concept_Paper_Due_Date__c != null && solicitationRec.Solicitation__r[0].Concept_Paper_Due_Date__c > system.now()) {
dueDate = solicitationRec.Solicitation__r[0].Concept_Paper_Due_Date__c.format('MM/dd/yyyy');
} else if(solicitationRec.Solicitation__r[0].Due_Date__c != null) {
dueDate = solicitationRec.Solicitation__r[0].Due_Date__c.format('MM/dd/yyyy');
}
}
*/
            
            dueDate = '';
            if(Solicitation_Helper.SOLICITATION_TYPE_ROLLING.equalsIgnoreCase(solicitationRec.Solicitation_Type__c) ||
               Solicitation_Helper.SOLICITATION_TYPE_OPEN_ENROLLMENT.equalsIgnoreCase(solicitationRec.Solicitation_Type__c)) { // T-02970
                   
                   dueDate = 'Continuous';
                   
               } if(Solicitation_Helper.SOLICITATION_TYPE_DUE_DATE.equalsIgnoreCase(solicitationRec.Solicitation_Type__c)) {
                   
                   for(Solicitation_Round__c obj : solicitationRec.Solicitation__r) {
                       if(solicitationRec.Concept_Paper__c && obj.Concept_Paper_Due_Date__c != null) {
                           lstDueDates.add(obj.Concept_Paper_Due_Date__c);
                       }
                       if(!solicitationRec.Concept_Paper__c && obj.Due_Date__c != null) {
                           lstDueDates.add(obj.Due_Date__c);
                       }
                   }
                   
                   lstDueDates.sort();
                   if(lstDueDates.size() > 0) {
                       for(Integer i=0; i < lstDueDates.size(); i++) {
                           dueDate += '<b>' + lstDueDates[i].format('MM/dd/yyyy') + '&nbsp;</b>' + ' (Round ' + (i+1) + ');  ';
                       }
                       if(String.isNotBlank(dueDate)) {
                           dueDate = dueDate.removeEnd(';  ');
                       }
                   }
               }
            // S-01055 - Multi round with concept paper and parallel activities
            
        }
        programContentIdToAttachmentTypeMap = new Map<Id, String>();
        programContentIdToScriptTitleMap = new Map<Id, String>();
        setProgramContentList(solicitationList);
        
        isProgramExist = false;
        hasError = false;
        isDetailShown = true;
        
        // Task T-02351 related changes
       // if(solicitationRec.Solicitation_Beta_Review__c && !UserIP.contains(CORE_Constants_Setting__c.getOrgDefaults().NYSERDA_Internal_IP__c)) {
         //   isDetailShown = false;
       // }
        
        /*for(User user : [SELECT Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()]){
accountId = (user.ContactId != null) ? user.Contact.AccountId : null;
contactId = (user.ContactId != null) ? user.ContactId : null;
}*/
    }
    
    /*
* Method Name: setProgramContentList
* Description: Sets the program content of controller
* @param: List<Program_Version__c> solicitationList
* @return: void
*/
    
    @testVisible
    private void setProgramContentList(List<Program_Version__c> solicitationList) {
        List<Id> programContentIdList = new List<Id>();
        for(Program_Version__c programVersionRec : solicitationList) {
            for(Program_Content__c programContentRec : programVersionRec.Program_Contents__r) {
                programContentIdList.add(programContentRec.Id);
            }
        }
        
        documentProgramContentList = [select Id, Document_Title__c,
                                      (Select Id, Name, ContentType from Attachments ORDER BY CreatedDate DESC)
                                      from Program_Content__c
                                      where Id IN: programContentIdList
                                      and Solicitation_Information__c = true
                                      Order BY Sequence__c ASC];
        
        for(Program_Content__c progContentRec : documentProgramContentList) {
            programContentIdToScriptTitleMap.put(progContentRec.Id, progContentRec.Document_Title__c.replace(' ','-').toLowerCase());
            if(progContentRec.Attachments.size() > 0) {
                String fileExtension = (progContentRec.Attachments[0].Name.split('\\.').size() > 1) ?
                    progContentRec.Attachments[0].Name.split('\\.')[progContentRec.Attachments[0].Name.split('\\.').size() - 1] : null;
                if(fileExtension != null) {
                    programContentIdToAttachmentTypeMap.put(progContentRec.Id, fileExtension.toUpperCase());
                } else {
                    programContentIdToAttachmentTypeMap.put(progContentRec.Id, '');
                }
            } else {
                programContentIdToAttachmentTypeMap.put(progContentRec.Id, '');
            }
        }
    }
}