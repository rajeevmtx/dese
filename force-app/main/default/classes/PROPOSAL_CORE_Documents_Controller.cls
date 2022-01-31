/*
* Class Name: PROPOSAL_CORE_Documents_Controller
* Description: Controller to handle the functionalities of PROPOSAL_CORE_Documents_Page
* Author/Date:  Tarun Khandelwal   1/14/2017
*
* Date         New/Modified      Author             Description
* 04/11/2017    Modified          Harshit Jain        T-02333
* 05/19/2017    Modified          Harshit Jain        Lockdown porposal updation for rolling solictation after submission
* 06/26/2017    Modified          Ajay Gautam         I-03043 - Lock the select file button after submisison
* 06/30/2017   Modified          Ajay Gautam        T-02655 - Add exception for paper submission process
* 12/5/2018		Modified		  Sean McMullan	     00024964 - Warn user if they try to upload a blank file
*/

public with sharing class PROPOSAL_CORE_Documents_Controller extends ProposalBase_Controller{
    // Properties
    public Integer rowNumber{get; set;}
    public Map<String, Attachment> projContentIdToAttachmentRecMap{get; set;}
    public Map<String, Attachment> projContentIdToNewAttachMap{get; set;}
    public Map<String, Boolean> projContentIdToConditionallyRequiredMap{get; set;}
    public List<ZEV_APPINTAKE_Documents_Controller.OtherDocument> otherDocumentList {get; set;}
    public List<Project_Content__c> projectContentList;
    public List<Project_Content__c> projectContent {get;set;}
    public Boolean isSavedFunctionCalled {get; set;}
    public String DOCUMENT_RECORDTYPE_DEVELOPER_NAME = 'Documents';

    // Class property having getter method
    public String supportedFileType{
        get {  //getter method - returns supported File Types(Comma separated)
            String supportedFileType = '';
            if(Documents_File_Extensions__c.getAll() != null){ // File typea are available
                for(String fileType : Documents_File_Extensions__c.getAll().keySet()){ // Iterate over key set and set supported File Types(Comma separated)
                    if(supportedFileType != '') {
                        supportedFileType += ', ';
                    }
                    supportedFileType += fileType;
                }
            }
            return supportedFileType;
        }
    }

    // Constructor
    public PROPOSAL_CORE_Documents_Controller() {
        if(project != null) { // If project is not null
         isReadOnlyApplicationWizard = (((checkForDueDate() || (!checkForDueDate() && !isProjectIsInEditableWizardStatuses)) || isRollingSolicitationLockDown) && !isExceptionalAccessProvided); // I-03043 - Lock the select file button after submisison
        }
    }

    /*
    * Method Name: getProjectContentList
    * Description: get all the project content in a list
    * @param:  String projectId
    * @return: List<Project_Content__c>
    */
    private List<Project_Content__c> getProjectContentList(String projectId) {
        // Fetch Project Content records and their child documents from database by matching criteria
        List<Project_Content__c> projectContentList = [select Id, Name, Document_Title__c, Mandatory_by_default__c, Conditionally_Required__c, Validation_Logic__c,
                                                            Concept_Paper__c, Hide_From_External_Reviewer__c, CreatedById,
                                                            (select Id, Status__c from Documents__r Order by Version__c DESC), Document_Criteria_Met__c
                                                            from Project_Content__c
                                                            Where Project__c =: CORE_Helper.doEscapeSingleQuotes(projectId)
                                                            AND RecordType.DeveloperName = :DOCUMENT_RECORDTYPE_DEVELOPER_NAME
                                                            AND (Mandatory_by_default__c = true OR Conditionally_Required__c = true)
                                                            order By Sequence__c ASC];

        return checkForAccessForProjectContents(projectContentList);
    }

    /*
    * Method Name: getConceptPaperProjectContentList
    * Description: get concept paper project content list
    * @param:  String projectId
    * @return: List<Project_Content__c>
    */
    private List<Project_Content__c> getConceptPaperProjectContentList(String projectId) {
        // Fetch Project Content records and their child documents from database by matching criteria
        List<Project_Content__c> projectContentList = [select Id, Name, Document_Title__c, Mandatory_by_default__c, Concept_Paper__c, CreatedById,
                                                                Conditionally_Required__c, Validation_Logic__c, Hide_From_External_Reviewer__c,
                                                            (select Id, Status__c from Documents__r Order by Version__c DESC), Document_Criteria_Met__c
                                                            from Project_Content__c
                                                            Where Project__c =: CORE_Helper.doEscapeSingleQuotes(projectId)
                                                            AND RecordType.DeveloperName = :DOCUMENT_RECORDTYPE_DEVELOPER_NAME
                                                            AND Concept_Paper__c = true
                                                            order By Sequence__c ASC];

        return checkForAccessForProjectContents(projectContentList);
    }

    private List<Project_Content__c> checkForAccessForProjectContents(List<Project_Content__c> projectContentList) {
        List<Project_Content__c> applicableProjectContentList = new List<Project_Content__c>();
        Boolean isPortalUser = isPortalUser();

        if(isPortalUser) {
            for(Project_Content__c contRec : projectContentList) {
                if(!contRec.Hide_From_External_Reviewer__c || (contRec.Hide_From_External_Reviewer__c && contRec.CreatedById == UserInfo.getUserId())) {
                    applicableProjectContentList.add(contRec);
                }
            }
        } else {
            applicableProjectContentList = projectContentList;
        }
        return applicableProjectContentList;
    }

    private Boolean isPortalUser() {
        List<User> userList = [SELECT ContactId, Contact.AccountId FROM User where Id =: UserInfo.getUserId()];
        String contactId;
        if(userList.size() > 0) {
            contactId = userList[0].ContactId;
        }
        return (contactId != null);
    }

    /*
    * Method Name: getProjectContentList
    * Description: get project content list
    * @param:  N/A
    * @return: void
    */
    public void getProjectContentList() {
        isDueDatePassed = checkForDueDate(); // Check for due date and se boolean varaible
        if(!project.Concept_Paper__c) {
            projectContent = getProjectContentList(projectId); // Get project content record by project Id
        } else {
            projectContent = getConceptPaperProjectContentList(projectId); // Get concept paper project content record by project Id
        }

        // Get attachment for project content and set map - project content id to attachment map
        projContentIdToAttachmentRecMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getAttachmentList(projectContent);
        projContentIdToNewAttachMap = new Map<String, Attachment>();
        for(Project_Content__c projContentRec : projectContent) {
            projContentIdToNewAttachMap.put(projContentRec.Id, new Attachment());
        }

        // Get document approval status
        getDocApprovalStatus(projectContent);

        // Get Other Document List by project id
        List<Project_Content__c> otherProjContentList = checkForAccessForProjectContents(ZEV_APPINTAKE_PaperWorkRecord_Service.getOtherProjectContentList(projectId));

        // Get Attachment List for other project content and set map - other project content id to attachment map
        Map<String, Attachment> otherProjectContentIdToAttachmentRecMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getAttachmentList(otherProjContentList);

        // Get  Doc Approval Status for other project content and set map - other project content id to Doc Approval Status map
        Map<String, String> otherDocIdToStatusMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getDocApprovalStatus(otherProjContentList);

        // Set other Document List
        otherDocumentList = new List<ZEV_APPINTAKE_Documents_Controller.OtherDocument>();
        for(Project_Content__c projContent : otherProjContentList) {
            ZEV_APPINTAKE_Documents_Controller.OtherDocument otherDoc =
                                     new ZEV_APPINTAKE_Documents_Controller.OtherDocument(projContent.Id, projContent.Document_Title__c,
                                                                                          new Attachment(),
                                                                                          otherProjectContentIdToAttachmentRecMap.get(projContent.Id),
                                                                                          otherDocIdToStatusMap.get(projContent.Id));
            otherDocumentList.add(otherDoc);
        }

        if(otherDocumentList.size() == 0) {
            //addDocumentInOtherDocumentList();
        }

        try {
            if(!project.Concept_Paper__c) { // If Concept paper field on project is not defined
                projContentIdToConditionallyRequiredMap = ZEV_APPINTAKE_PaperWorkRecord_Service.checkForConditionallyRequired(projectContent);

                // Iterate over Project Content records, set their field
                for(Project_Content__c projContent : projectContent) {
                    if(projContentIdToConditionallyRequiredMap.containsKey(projContent.Id)) {
                        projContent.Document_Criteria_Met__c = projContentIdToConditionallyRequiredMap.get(projContent.Id);
                    }
                }
                if(projectContent.size() > 0) {
                    // Update Project Content record
                    update projectContent;
                }

                // Get Project Content record by projectId and set projectContent varaible
                projectContent = ZEV_APPINTAKE_PaperWorkRecord_Service.getProjectContentList(projectId);
            }
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())); // Add error message to apex page, if exception occured
        }
    }

    /*
    * Method Name: addDocumentInOtherDocumentList
    * Description: add document in document list
    * @param:  N/A
    * @return: PageReference
    */
    public PageReference addDocumentInOtherDocumentList() {
        otherDocumentList.add(new ZEV_APPINTAKE_Documents_Controller.OtherDocument(null, '', new Attachment(), new Attachment(), ''));
        return null;
    }

    /*
    * Method Name: removeDocumentFromList
    * Description: remove document from document list
    * @param:  N/A
    * @return: PageReference
    */
    public PageReference removeDocumentFromList() {
        ZEV_APPINTAKE_Documents_Controller.OtherDocument otherDoc = otherDocumentList.remove(rowNumber); // Remove row from otherDocumentList
        if(otherDoc.documentId != null) {
            Project_Content__c projectContent = new Project_Content__c(Id = otherDoc.documentId); // Get project content record by id
            delete projectContent; // Delete project content record
        }
        return null;
    }

    // Class property
    public Map<String, String> projContentIdToDocStatusMap{get; set;}


    /*
    * Method Name: getDocApprovalStatus
    * Description: get document approval status
    * @param:  List<Project_Content__c> projectContentList
    * @return: void
    */
    public void getDocApprovalStatus(List<Project_Content__c> projectContentList) {
        projContentIdToDocStatusMap = ZEV_APPINTAKE_PaperWorkRecord_Service.getDocApprovalStatus(projectContent);
    }

    // Class properties
    public String projectContentId {get; set;}
    public String projectContentName {get; set;}
    public List<Project_Document__c> attachmentHistory {get; set;}
    public Boolean hasError {get; set;}

    /*
    * Method Name: getAttachmentHistory
    * Description: get attachment history
    * @param:  N/A
    * @return: void
    */
    public void getAttachmentHistory() {
        attachmentHistory = ZEV_APPINTAKE_PaperWorkRecord_Service.getAttachmentHistory(projectContentId);
    }

    /*
    * Method Name: validateAndNext
    * Description: Validate and move to next document
    * @param:  N/A
    * @return: PageReference
    */
    public Pagereference validateAndNext() {
        hasError = false; // Set boolean variable to check if error exist or not

        if((checkForDueDate() || isRollingSolicitationLockDown) && !isExceptionalAccessProvided) {
            isDueDatePassed = true;
            getProjectContentList(); // Get Project Content List
            currentPage = 'PROPOSAL_CORE_Documents_Page'; // Set current page name
            return next(); // return next page
        }

        // Save documents
        ZEV_APPINTAKE_PaperWorkRecord_Service.saveDocuments(projContentIdToNewAttachMap, projectContent, projectId);
        saveOtherDocuments();

        // Get Project Content List
        getProjectContentList();

        // Iterate over Project Content record
        for(Project_Content__c projContentRec : projectContent) {
            if(!project.Concept_Paper__c) { // If Concept Paper field on project record is not defined
                if((projContentRec.Mandatory_by_default__c && projContentIdToConditionallyRequiredMap != null || (projContentIdToConditionallyRequiredMap.containsKey(projContentRec.Id) && projContentIdToConditionallyRequiredMap.get(projContentRec.Id)))
                   && (projContentRec.Documents__r.size() == 0)) {
                       hasError = true; // Set has error to true to show that error exists
                   }
            } else {
                if(projContentRec.Documents__r.size() == 0) { // If documents for project Content Rec are not available
                    hasError = true; // Set has error to true to show that error exists
                }
            }
        }

        //12/5/2018 Sean McMullan - check for page errors due to blank documents
        if(ApexPages.hasMessages()){
            hasError = true;
        }


        PageReference returnPage;

        if(hasError) { // If error exists then return null
            return null;
        } else { // If error doesn't exist then set current page and return move to next page
            currentPage = 'PROPOSAL_CORE_Documents_Page';
            return next();
        }
    }

    /*
    * Method Name: saveProjectContentList
    * Description: save project content
    * @param:  N/A
    * @return: PageReference
    */
    public PageReference saveProjectContentList() {
        isSavedFunctionCalled = false; // Set boolean variable to check if Saved Function Called or not
        hasError = false; // Set boolean variable to check if error exist or not
        if((checkForDueDate() || isRollingSolicitationLockDown) && !isExceptionalAccessProvided) {
            isDueDatePassed = true;
            getProjectContentList(); // Get Project Content List
            return null;
        }

        // Iterate over attachments and set isSavedFunctionCalled flag
        for(Attachment attechRec : projContentIdToNewAttachMap.values()) {
            if(attechRec.Body != null && attechRec.Id == null) {
                isSavedFunctionCalled = true; // Set isSavedFunctionCalled to true to show that Saved Function is called
                break;
            }
        }

        // Iterate over document list and set isSavedFunctionCalled flag
        for(ZEV_APPINTAKE_Documents_Controller.OtherDocument otherDoc : otherDocumentList) {
            if(otherDoc.attach.Body != null && otherDoc.attach.Id == null) {
                isSavedFunctionCalled = true; // Set isSavedFunctionCalled to true to show that Saved Function is called
                break;
            }
        }

        // Save documents
        ZEV_APPINTAKE_PaperWorkRecord_Service.saveDocuments(projContentIdToNewAttachMap, projectContent, projectId);
        saveOtherDocuments();

        // For Refreshing List
        PageReference ReturnPage = new PageReference('/apex/PROPOSAL_CORE_Documents_Page?ProjectId=' +projectId);
        //ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    /*
    * Method Name: saveOtherDocuments
    * Description: save documents
    * @param:  N/A
    * @return: PageReference
    */

    public PageReference saveOtherDocuments() {
        // Save documents
        ZEV_APPINTAKE_PaperWorkRecord_Service.saveOtherDocuments(otherDocumentList, projectId);
        return null;
    }
} //EOF