//
// Controller for Zero Emission Vehicles Documents Page
//
// June 10, 2016     George Acker     original
global with sharing class ZEV_APPINTAKE_Documents_Controller extends AppIntakeBase_Controller
{
    public ZEV_APPINTAKE_Documents_Controller(){

    }
    public Integer rowNumber{get; set;}
    public Map<String, Attachment> projContentIdToAttachmentRecMap{get; set;}
    public Map<String, Attachment> projContentIdToNewAttachMap{get; set;}
    public Map<String, Boolean> projContentIdToConditionallyRequiredMap{get; set;}
    public List<OtherDocument> otherDocumentList {get; set;}
    public List<Project_Content__c> projectContentList;
    public List<Project_Content__c> projectContent {get;set;}
    public project__C project {
        get{
            if(project ==null){
                project = [select Application_Number__c from project__c where id = : CORE_Helper.doEscapeSingleQuotes(projectId)];
            }
            return project;
        }
        private set;
    }

    public String supportedFileType{
		get {
	    	String supportedFileType = '';
	    	if(Documents_File_Extensions__c.getAll() != null){
	    		for(String fileType : Documents_File_Extensions__c.getAll().keySet()){
	    			if(supportedFileType != '') {
	    				supportedFileType += ', ';
	    			}
	    			supportedFileType += fileType;
	    		}
	    	}
	    	return supportedFileType;
    	}
	}

    public void getProjectContentList() {
        projectContent = ZEV_APPINTAKE_PaperWorkRecord_Service.getProjectContentList(projectId);
        projContentIdToAttachmentRecMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getAttachmentList(projectContent);

        projContentIdToNewAttachMap = new Map<String, Attachment>();
        for(Project_Content__c projContentRec : projectContent) {
            projContentIdToNewAttachMap.put(projContentRec.Id, new Attachment());
        }
        getDocApprovalStatus(projectContent);

        // Get Other Document List
        List<Project_Content__c> otherProjContentList = ZEV_APPINTAKE_PaperWorkRecord_Service.getOtherProjectContentList(projectId);
        Map<String, Attachment> otherProjectContentIdToAttachmentRecMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getAttachmentList(otherProjContentList);
        Map<String, String> otherDocIdToStatusMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getDocApprovalStatus(otherProjContentList);

        otherDocumentList = new List<OtherDocument>();
        for(Project_Content__c projContent : otherProjContentList) {
            OtherDocument otherDoc = new OtherDocument(projContent.Id, projContent.Document_Title__c,
                                                       new Attachment(),
                                                       otherProjectContentIdToAttachmentRecMap.get(projContent.Id),
                                                       otherDocIdToStatusMap.get(projContent.Id));
            otherDocumentList.add(otherDoc);
        }

        if(otherDocumentList.size() == 0) {
            addDocumentInOtherDocumentList();
        }

        try {
            projContentIdToConditionallyRequiredMap = ZEV_APPINTAKE_PaperWorkRecord_Service.checkForConditionallyRequired(projectContent);
            for(Project_Content__c projContent : projectContent) {
                if(projContentIdToConditionallyRequiredMap.containsKey(projContent.Id)) {
                    projContent.Document_Criteria_Met__c = projContentIdToConditionallyRequiredMap.get(projContent.Id);
                }
            }
            if(projectContent.size() > 0) {
                update projectContent;
            }
            projectContent = ZEV_APPINTAKE_PaperWorkRecord_Service.getProjectContentList(projectId);

        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }

    public PageReference addDocumentInOtherDocumentList() {
        otherDocumentList.add(new OtherDocument(null, '', new Attachment(), new Attachment(), ''));
        return null;
    }

    public PageReference removeDocumentFromList() {
        OtherDocument otherDoc = otherDocumentList.remove(rowNumber);
        if(otherDoc.documentId != null) {
            Project_Content__c projectContent = new Project_Content__c(Id = otherDoc.documentId);
            delete projectContent;
        }
        return null;
    }

    public Map<String, String> projContentIdToDocStatusMap{get; set;}

    public void getDocApprovalStatus(List<Project_Content__c> projectContentList) {
        projContentIdToDocStatusMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getDocApprovalStatus(projectContent);
    }

    public String projectContentId {get; set;}
    public String projectContentName {get; set;}
    public List<Project_Document__c> attachmentHistory {get; set;}
    public Boolean hasError {get; set;}

    public void getAttachmentHistory() {
        attachmentHistory = ZEV_APPINTAKE_PaperWorkRecord_Service.getAttachmentHistory(projectContentId);
    }

    public Pagereference validateAndNext() {
        hasError = false;
        //saveProjectContentList();
        //system.assert(false, projContentNameToNewAttachMap);
        ZEV_APPINTAKE_PaperWorkRecord_Service.saveDocuments(projContentIdToNewAttachMap, projectContent, projectId);
        saveOtherDocuments();
        getProjectContentList();

        for(Project_Content__c projContentRec : projectContent) {
            if((projContentRec.Mandatory_by_default__c && projContentIdToConditionallyRequiredMap != null || (projContentIdToConditionallyRequiredMap.containsKey(projContentRec.Id) && projContentIdToConditionallyRequiredMap.get(projContentRec.Id)))
               && (projContentRec.Documents__r.size() == 0)) {
                   hasError = true;
               }
        }
        PageReference returnPage;

        if(hasError) {
            /*returnPage = new PageReference('/apex/ZEV_APPINTAKE_Documents_Page?ProjectId=' +projectId);
            returnPage.setRedirect(true);
            return returnPage;*/
            return null;
        } else {
            currentPage = 'ZEV_APPINTAKE_Documents_Page';
            return next();
        }
    }


    public PageReference saveProjectContentList() {
        //system.assert(false, projContentNameToNewAttachMap);
        ZEV_APPINTAKE_PaperWorkRecord_Service.saveDocuments(projContentIdToNewAttachMap, projectContent, projectId);

        saveOtherDocuments();

        // For Refreshing List
        getProjectContentList();

        PageReference ReturnPage = new PageReference('/apex/ZEV_APPINTAKE_Documents_Page?ProjectId=' +projectId);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }


    public PageReference saveOtherDocuments() {
        ZEV_APPINTAKE_PaperWorkRecord_Service.saveOtherDocuments(otherDocumentList, projectId);
        return null;
    }



    public class OtherDocument {

        public String documentId {get; set;}
        public String documentName {get; set;}
        public Attachment attach {get; set;}
        public Attachment recentAttach {get; set;}
        public String status {get; set;}

        public OtherDocument(String docId, String docName, Attachment attachRec, Attachment recentAttachRec, String docStatus) {
            documentId = docId;
            documentName = docName;
            attach = attachRec;
            recentAttach = recentAttachRec;
            status = docStatus;
        }
    }
}