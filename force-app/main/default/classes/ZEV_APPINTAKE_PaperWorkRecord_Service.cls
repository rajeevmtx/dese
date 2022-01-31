/*
* 	Class Name: ZEV_APPINTAKE_PaperWorkRecord_Service
* 	Description: Service class to handle operations on Project Contents, Attachments and Documents
*
* 	Author/Date: Gaurav Sinha/June 14, 2016
*
* Date         New/Modified      Author             Description
* 12/5/2018     Modified		Sean McMullan	    Case 00024964 - Warn user if they upload a zero byte file.
*/
public with sharing class ZEV_APPINTAKE_PaperWorkRecord_Service {

    public class zeroByteException extends Exception{}

	/*
	* Method Name: getProjectContentList
	* Description: get List of Project Content Records and their child Documents.
	* @param: String projectId
	* @return: List<Project_Content__c>
	*/
    public static List<Project_Content__c> getProjectContentList(String projectId) {
    	// Fetch Project content records and their child Documents from database by matching criteria
        List<Project_Content__c> projectContentList = [select Id, Name, Document_Title__c, Mandatory_by_default__c, Conditionally_Required__c, Validation_Logic__c, Concept_Paper__c,
                                                            (select Id, Status__c from Documents__r Order by Version__c DESC), Document_Criteria_Met__c
                                                            from Project_Content__c
                                                            Where Project__c =: CORE_Helper.doEscapeSingleQuotes(projectId)
                                                            AND RecordType.DeveloperName = :ZEV_Helper.DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME
                                                            AND (Mandatory_by_default__c = true OR Conditionally_Required__c = true)
                                                            order By Sequence__c ASC];

        return projectContentList;

    }

    /*
	* Method Name: getOtherProjectContentList
	* Description: get List of Project Content Records and their child Documents.
	* @param: String projectId
	* @return: List<Project_Content__c>
	*/
    public static List<Project_Content__c> getOtherProjectContentList(String projectId) {
    	// Fetch Project content records and their child Documents from database by matching criteria
        List<Project_Content__c> projectContentList = [select Id, Name, Document_Title__c, Concept_Paper__c, CreatedById, Hide_From_External_Reviewer__c,
                                                            (select Id, Status__c from Documents__r Order by Version__c DESC)
                                                            from Project_Content__c
                                                            Where Project__c =: CORE_Helper.doEscapeSingleQuotes(projectId)
                                                            AND RecordType.DeveloperName = :ZEV_Helper.DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME
                                                            AND (Mandatory_by_default__c = false AND Conditionally_Required__c = false) order By Sequence__c ASC];

        return projectContentList;

    }

    /*
	* Method Name: getAttachmentList
	* Description: get project Content Id to attachment map
	* @param: List<Project_Content__c> projectContentList
	* @return: Map<String, Attachment>
	*/
    public static Map<String, Attachment> getAttachmentList(List<Project_Content__c> projectContentList) {
    	// Fetch Project_Document records and their child attachments from database by matching criteria
        List<Project_Document__c> documentList = [ select Id, Name, Project_Content__c, (select Id, Name from attachments)
                                                        from Project_Document__c
                                                        Where Project_Content__c IN: projectContentList Order by Version__c DESC nulls last
                                        ];

		// Instance creation
        List<Attachment> attachmentList = new List<Attachment>();
        Map<String, Attachment> projContentIdToAttachmentRecMap = new Map<String, Attachment>();

		// Iterate over Project Document records  and create project Content Id to attachment map
        for(Project_Document__c doc : documentList) {
            if(!projContentIdToAttachmentRecMap.containsKey(doc.Project_Content__c)) {
                Attachment att = (doc.attachments.size() > 0) ? doc.attachments[0] : new Attachment();
                projContentIdToAttachmentRecMap.put(doc.Project_Content__c, att);
            }
        }

		// Iterate over Project Content records  and create project Content Id to attachment map
        for(Project_Content__c projContent : projectContentList) {
            if(!projContentIdToAttachmentRecMap.containsKey(projContent.Id)) {
                projContentIdToAttachmentRecMap.put(projContent.Id, new Attachment());
            }
        }

        return projContentIdToAttachmentRecMap;
    }

    /*
	* Method Name: getDocApprovalStatus
	* Description: get project Content Id to Document Status map
	* @param: List<Project_Content__c> projectContentList
	* @return: Map<String, String>
	*/
    public static Map<String, String> getDocApprovalStatus(List<Project_Content__c> projectContentList) {
    	// Fetch Project_Document records from database by matching criteria
        List<Project_Document__c> documentList = [ select Id, Status__c, Project_Content__r.Document_Title__c, Project_Content__c
                                                        from Project_Document__c
                                                        Where Project_Content__c IN: projectContentList Order by Version__c DESC nulls last
                                        ];

		// Instance creation
        Map<String, String> projContentIdToDocStatusMap = new Map<String, String>();

		// Iterate over Project Document records  and create project Content Id to Document Status map
        for(Project_Document__c doc : documentList) {
            if(!projContentIdToDocStatusMap.containsKey(doc.Project_Content__c) && doc.Status__c != null) {
                projContentIdToDocStatusMap.put(doc.Project_Content__c, doc.Status__c);
            } else if(!projContentIdToDocStatusMap.containsKey(doc.Project_Content__c) && doc.Status__c == null) {
                projContentIdToDocStatusMap.put(doc.Project_Content__c, '');
            }
        }

		// Iterate over Project Content records  and create project Content Id to Document Status map
        for(Project_Content__c projContent : projectContentList) {
            if(!projContentIdToDocStatusMap.containsKey(projContent.Id)) {
                projContentIdToDocStatusMap.put(projContent.Id, '');
            }
        }
        //system.assert(false, projContentIdToDocStatusMap);
        return projContentIdToDocStatusMap;
    }

    /*
	* Method Name: saveDocuments
	* Description: Insert documents
	* 			   Insert attachments on document
	* @param: Map<String, Attachment> projContentIdToNewAttachMap
	* @param: List<Project_Content__c> projectContentList
	* @param: String projectId
	* @return: void
	*/
    public static void saveDocuments(Map<String, Attachment> projContentIdToNewAttachMap,
                                        List<Project_Content__c> projectContentList, String projectId) {

		// Fetch Project Content records and their child Documents from database by matching criteria
        List<Project_Content__c> projList = [select Id, Document_Title__c, Type__c, Sub_Type__c,
                                             (select Version__c, Project__c, Project_Content__c, Name from Documents__r)
                                                        from Project_Content__c where Id IN: projectContentList];

		// Instance creation
        List<Project_Document__c> documentListToInsert = new List<Project_Document__c>();
        List<Attachment> attachmentListToInsert = new List<Attachment>();

		// Iterate over Project Content records and add items to documentListToInsert & attachmentListToInsert list collections
        for(Project_Content__c projContentRec : projList) {
            if(projContentIdToNewAttachMap.containsKey(projContentRec.Id)) {
                if(projContentIdToNewAttachMap.get(projContentRec.Id).body != null) {
                	// Set variables
                    Integer totalDocuments = projContentRec.Documents__r.size();

                    // Create Project Document record and set its fields
                    Project_Document__c doc = new Project_Document__c();
                    doc.Version__c = totalDocuments + 1;
                    doc.Project__c = projectId;
                    doc.Project_Content__c = projContentRec.Id;

                    // If content title is more than 80 chars then truncate to avoid 80 char limit of standard field Name
                    if(projContentRec.Document_Title__c != null) {
                      doc.Name = (projContentRec.Document_Title__c.length()>80 ? projContentRec.Document_Title__c.subString(0,80) : projContentRec.Document_Title__c);
                    }

                    doc.Status__c = 'Submitted';
                    documentListToInsert.add(doc); // Add document to list

					// Create Attachment record and set its fields
                    Attachment attach = new Attachment();
                    attach.Body = projContentIdToNewAttachMap.get(projContentRec.Id).body;
                    attach.Name = projContentIdToNewAttachMap.get(projContentRec.Id).Name;
                    attachmentListToInsert.add(attach); // Add attachment to list
                }
            }
        }

		// Insert documents if available in list
        if(documentListToInsert.size() > 0) {
            insert documentListToInsert;
        }

		// Set parent id on attachemtn and Insert attachment on document if available in list
        if(attachmentListToInsert.size() > 0) {
            for(Integer i = 0; i < documentListToInsert.size(); i++) {
                attachmentListToInsert[i].ParentId = documentListToInsert[i].Id;
            }
            insert attachmentListToInsert;

            // 12/5/2018 Sean McMullan : check for 0 byte file here. There have been a few cases where people thought they were uploading a full file but an empty file was uploaded.

			Set<String> attachIds = new Set<String>();
            for(Integer d = 0; d < attachmentListToInsert.size(); d++) {
                  attachIds.add(attachmentListToInsert[d].Id);
             }

            List<Attachment> attachAfter = [select BodyLength from Attachment where id IN : attachIds];
            for(Integer a = 0; a < attachAfter.size(); a++) {
                System.debug('Attachment Size After (2):' + attachAfter[a].BodyLength);
                // if the attached file is 0 bytes then warn the user
                if(attachAfter[a].BodyLength == 0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'A blank file was uploaded. If it was not your intention to upload a blank file, please re-upload your file and verify that we have your complete file by clicking the link under the Recent Uploaded Document column below.');
					ApexPages.addMessage(myMsg);
                }

            }
        }
    }

    /*
	* Method Name: saveOtherDocuments
	* Description: Insert or update project content records
	*			   Insert project documents
	* 			   Insert attachments on project document
	* @param: List<ZEV_APPINTAKE_Documents_Controller.OtherDocument> otherDocumentsList
	* @param: String projectId
	* @return: void
	*/
    public static void saveOtherDocuments(List<ZEV_APPINTAKE_Documents_Controller.OtherDocument> otherDocumentsList, String projectId) {
    	// Instance creation
        List<Project_Content__c> projContentList = new List<Project_Content__c>();

        // Get and set document Record Type Id
        String documentRecTypeId = Utility_RecordType_Helper.getRecordType('Project_Content__c', 'Documents').Id;

        // Iterate over other Documents List, create project Content record from document record and add that to projContentList list
        for(ZEV_APPINTAKE_Documents_Controller.OtherDocument otherDoc : otherDocumentsList) {
            if(!String.isBlank(otherDoc.documentName)) {
            	// Create Project content record and set its fields
                Project_Content__c projContent = new Project_Content__c();
                projContent.Id = otherDoc.documentId;
                projContent.Document_Title__c = otherDoc.documentName;
                projContent.RecordTypeId = documentRecTypeId;
                if(String.isBlank(otherDoc.documentId)) {
                    projContent.Project__c = projectId;
                }
                projContentList.add(projContent); // Add project content record to list
            }
        }

		// Insert or update project content records if available in list
        if(projContentList.size() > 0) {
            upsert projContentList;
        }

		// Fetch Project Content records and their child Documents from database and create Poject content id to project content record map
        Map<Id, Project_Content__c> projectContentMap = new Map<Id, Project_Content__c>([select Id, Document_Title__c, (select Version__c, Project__c, Project_Content__c, Name from Documents__r)
                                                            from Project_Content__c where Id IN: projContentList]);

		// Instance creation
        List<Attachment> attachmentListToInsert = new List<Attachment>();
        List<Project_Document__c> documentListToInsert = new List<Project_Document__c>();

		// Iterate over other Documents List, Create Project Document and Attachment record and add them to list
        for(Integer i = 0; i < otherDocumentsList.size(); i++) {
            if(otherDocumentsList[i].attach.body != null && projectContentMap.containskey(projContentList[i].Id)) {
            	// Get total number  of Documents on prject content record
                Integer totalDocuments = projectContentMap.get(projContentList[i].Id).Documents__r.size();

                // Create project document record and set its fields
                Project_Document__c doc = new Project_Document__c();
                doc.Version__c = totalDocuments + 1;
                doc.Project__c = projectId;
                doc.Project_Content__c = projContentList[i].Id;

                // If content title is more than 80 chars then truncate to avoid 80 char limit of standard field Name
                if(projContentList[i].Document_Title__c != null) {
                  doc.Name = (projContentList[i].Document_Title__c.length()>80 ? projContentList[i].Document_Title__c.subString(0,80) : projContentList[i].Document_Title__c);
                }
                doc.Status__c = 'Submitted';
                documentListToInsert.add(doc); // Add project document to list

				// Create Attachment record and set its fields
                Attachment attach = new Attachment();
                attach.Body = otherDocumentsList[i].attach.body;
                attach.Name = otherDocumentsList[i].attach.Name;
                attachmentListToInsert.add(attach); // Add attachment to list
            }
        }

		// Insert project documents if available in list
        if(documentListToInsert.size() > 0) {
            insert documentListToInsert;
        }

		// Insert attachments on project document if available in list
        if(attachmentListToInsert.size() > 0) {
            for(Integer i = 0; i < documentListToInsert.size(); i++) {
                attachmentListToInsert[i].ParentId = documentListToInsert[i].Id;
            }
            insert attachmentListToInsert;
        }
    }

    /*
	* Method Name: getAttachmentHistory
	* Description: get attachment list on project Content's documents.
	* @param: String projectContentId
	* @return: List<Project_Document__c>
	*/
    public static List<Project_Document__c> getAttachmentHistory(String projectContentId) {
        List<Project_Document__c> attachmentHistory = new List<Project_Document__c>();

        // Fetch Project Document records and their child attachments from database by matching criteria
        List<Project_Document__c> documentList = [select Id, Version__c, CreatedDate, CreatedBy.Name, (select Name from Attachments) from Project_Document__c where Project_Content__c =: CORE_Helper.doEscapeSingleQuotes(projectContentId) Order by Version__c DESC];

        // iterate over Project Document records and add them to attachmentHistory list
        for(Project_Document__c doc : documentList) {
            if(doc.Attachments.size() > 0 ) {
                attachmentHistory.add(doc);
            }
        }
        return attachmentHistory;
    }

    /*
	* Method Name: checkForConditionallyRequired
	* Description: get project content on conditionally .
	* @param: List<Project_Content__c> projectContentList
	* @return: Map<String, Boolean>
	*/
    public static Map<String, Boolean> checkForConditionallyRequired(List<Project_Content__c> projectContentList) {
    	// Get fields set for SOQL query to fetch project content records
        Set<String> fieldsToQuery = getFieldsToQuery(projectContentList);

        // Get project Contents
        List<Project_Content__c> projectContentsWithAllFields = getProjectContentsWithAllFields(fieldsToQuery, projectContentList);

		// Iterate over project Contents and Create project content id to boolean value(for required) map
        Map<String, Boolean> projContentIdToRequiredMap = new Map<String, Boolean>();
        for(Project_Content__c projContentRec : projectContentsWithAllFields) {
            projContentIdToRequiredMap.put(projContentRec.Id, FormulaInterpretUtility.checkForRequried(projContentRec));
        }
        return projContentIdToRequiredMap;
    }

    /*
	* Method Name: getProjectContentsWithAllFields
	* Description: get project content records with all fields .
	* @param: Set<String> fieldsToQuery
	* @param: List<Project_Content__c> projectContentList
	* @return: List<Project_Content__c>
	*/
    private static List<Project_Content__c> getProjectContentsWithAllFields(Set<String> fieldsToQuery, List<Project_Content__c> projectContentList) {
    	// Preapre SOQL qery string to fetch Project Content records from database by matching criteria
        String query = ' SELECT Validation_Logic__c, Conditionally_Required__c, Document_Title__c, ';
        for(String fieldsName : fieldsToQuery) {
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Project_Content__c Where Id IN : projectContentList' ;

        // Execute above query and fetch Project Content records from database
        List<Project_Content__c> projectContentsWithAllFields = Database.query(query);
        return projectContentsWithAllFields;
    }

    /*
	* Method Name: getFieldsToQuery
	* Description: get fields set for SOQL query on project content records.
	* @param: List<Project_Content__c> projectContentList
	* @return: Set<String>
	*/
    private static Set<String> getFieldsToQuery(List<Project_Content__c> projectContentList) {
        Set<String> fieldsToQuery = new Set<String>();

        // Iterate over Project Content records
        for(Project_Content__c projContentRec : projectContentList) {
            if(projContentRec.Conditionally_Required__c) { // If project content record is Conditionally Required
            	// Create fields set for SOQL query on project content records
                List<String> validationLogicList = projContentRec.Validation_Logic__c.split(' AND ');
                for(String validationStr : validationLogicList) {
                    Map<String, String> stringLiteralToFormulaValueMap = FormulaInterpretUtility.parseFormula(validationStr);
                    if(stringLiteralToFormulaValueMap.containsKey('FieldName')) {
                        String fieldAPIName = stringLiteralToFormulaValueMap.get('FieldName');
                        if(fieldAPIName != null && !fieldAPIName.contains('{') && !fieldAPIName.contains('}')) {
                            fieldsToQuery.add(stringLiteralToFormulaValueMap.get('FieldName'));
                        }
                    }
                }
            }
        }
        return fieldsToQuery;
    }
} //EOF