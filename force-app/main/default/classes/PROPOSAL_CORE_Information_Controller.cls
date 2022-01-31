/*
* Class Name: PROPOSAL_CORE_Information_Controller
* Description: Controller to handle the functionalities of  PROPOSAL_CORE_Information_Page
* Author/Date: Harshit Jain   1/11/2017
*
* Date         New/Modified     Author             Description
* 5/2/2017     Modified         Harshit Jain       T-02333
* 5/19/2017    Modified         Harshit Jain        Lockdown porposal updation for rolling solictation after submission
*/

public with sharing class PROPOSAL_CORE_Information_Controller extends ProposalBase_Controller {

    public Boolean isNextClicked {get; set;}
    public List<Project_Content__c> checklistQuestionList {get; set;}
    public List<Project_Content__c> disclosureQuestionList {get; set;}
    public List<Project_Content__c> contentQuestionList {get; set;}
    public String checklistResponseList {get; set;}
    public String disclosureResponseList {get; set;}
    public String contentResponseList {get; set;}
    public List<SelectOption> categoryOptionList {get; private set;}

    public Map<String, String> checklistSequenceToResponseMap;
    public Map<String, String> disclosureSequenceToResponseMap;
    public Map<String, String> contentSequenceToResponseMap;
    public String checklistSequenceToResponseMapJSON {get; set;}
    public String disclosureSequenceToResponseMapJSON {get; set;}
    public String contentSequenceToResponseMapJSON {get; set;}

    public PROPOSAL_CORE_Information_Controller() {
        init();
        populateCategoryPicklist();
    }

    public List<SelectOption> getdynamiclist() {
        List<SelectOption> options = new List<SelectOption>();
         options.add(new SelectOption('','Select One'));
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        return options;
    }
    
    /*
    * Method Name: init
    * Description: intialize the variables with data needs to be displayed on page
    * @param:  none
    * @return: void
    */

    private void init() {
        project = new Project__c();
        checklistQuestionList = new List<Project_Content__c>();
        disclosureQuestionList = new List<Project_Content__c>();
        contentQuestionList = new List<Project_Content__c>();

        checklistSequenceToResponseMap = new Map<String, String>();
        disclosureSequenceToResponseMap = new Map<String, String>();
        contentSequenceToResponseMap = new Map<String, String>();

        Map<String, String> checklistSequenceToProposalAnswerMap = new Map<String, String>();
        Map<String, String> disclosureSequenceToProposalAnswerMap = new Map<String, String>();
        Map<String, String> contentSequenceToProposalAnswerMap = new Map<String, String>();

        Id proposalRecordTypeId = Utility_RecordType_Helper.getRecordType('Project_Content__c', Proposal_Helper.PROPOSAL_PROJECT_CONTENT_RECORD_TYPE_DEVELOPER_NAME).Id;
        List<Project__c> projectList = [select Description__c, Proposed_Proposal_Category__c, Concept_Paper__c, Program_Version__c, RecordType.Name, RecordTypeId,
                                            Solicitation_Round__r.Concept_Paper_Due_Date__c, Solicitation_Round__r.Due_Date__c, Company_Information__c, Name,
                                            Application_Number__c,Program_Version__r.NY_Green_Bank_RFP__c,Program_Version__r.End_User_Types__c, Program_Version__r.Regions__c,
                                            Program_Version__r.Energy_System_Classification__c, Program_Version__r.Energy_System_Classification_Default__c,
                                            Program_Version__r.Primary_Supporting_Technologies__c, Program_Version__r.Primary_Supporting_Technology_Default__c,
                                            Program_Version__r.Size_of_Project_s__c, Program_Version__r.Panel_Manufacturer__c, Program_Version__r.Inverter_Manufacturer__c,
                                            End_User_Type__c,Regions__c,
                                            (Select Display_Label__c, Type__c, Proposal_Question_Answer__c, Sequence__c, Explanation_Required_On__c, Active__c,
                                                Description__c, Question_Type__c, Date_Value__c, Help_Text__c  from Project_Contents__r
                                                where recordTypeId =: proposalRecordTypeId Order by Sequence__c)
                                            FROM Project__c WHERE Id =: CORE_Helper.doEscapeSingleQuotes(projectId)];

        if(projectList.size() > 0) {
            project = projectList[0];

           /* if(project.Program_Version__r.NY_Green_Bank_RFP__c) {
                if(String.isBlank(project.Energy_System_Classification__c) && String.isNotBlank(project.Energy_System_Classification__c)) {
                    project.Energy_System_Classification__c = project.Program_Version__r.Energy_System_Classification_Default__c;
                }
                if(String.isBlank(project.Primary_Supporting_Technology__c) && String.isNotBlank(project.Program_Version__r.Primary_Supporting_Technology_Default__c)) {
                    project.Primary_Supporting_Technology__c = project.Program_Version__r.Primary_Supporting_Technology_Default__c;
                }
            } */

            for(Project_Content__c question : project.Project_Contents__r) {
                String sequenceStr = (question.Sequence__c != null) ? String.valueOf(question.Sequence__c) : '';
                if(question.Type__c == 'Proposal Checklist Questions') {
                    checklistQuestionList.add(question);
                    checklistSequenceToResponseMap.put(sequenceStr, question.Explanation_Required_On__c);
                    checklistSequenceToProposalAnswerMap.put(sequenceStr, question.Proposal_Question_Answer__c);
                } else if(question.Type__c == 'Proposal Disclosure Questions'){
                    disclosureQuestionList.add(question);
                    disclosureSequenceToResponseMap.put(sequenceStr, question.Explanation_Required_On__c);
                    disclosureSequenceToProposalAnswerMap.put(sequenceStr, question.Proposal_Question_Answer__c);
                } else if(question.Type__c == 'Proposal Content Questions'){
                    contentQuestionList.add(question);
                    contentSequenceToResponseMap.put(sequenceStr, question.Explanation_Required_On__c);
                    contentSequenceToProposalAnswerMap.put(sequenceStr, question.Proposal_Question_Answer__c);
                }
            }
        }
        checklistSequenceToResponseMapJSON = JSON.serialize(checklistSequenceToResponseMap);
        disclosureSequenceToResponseMapJSON = JSON.serialize(disclosureSequenceToResponseMap);
        contentSequenceToResponseMapJSON = JSON.serialize(contentSequenceToResponseMap);

        checklistResponseList = JSON.serialize(checklistSequenceToProposalAnswerMap);
        disclosureResponseList = JSON.serialize(disclosureSequenceToProposalAnswerMap);
        contentResponseList = JSON.serialize(contentSequenceToProposalAnswerMap);
    }

    Map<String, String> categoryNameToCategoryProjectTypeMap = new Map<String, String>();
    private void populateCategoryPicklist() {
        categoryOptionList = new List<SelectOption>();
        if(project.Program_Version__c != null) {
            categoryOptionList.add(new SelectOption('', '-- None --'));
            List<Proposal_Category__c> categoryList = [select Name, Project_Type__c from Proposal_Category__c where Solicitation__c =: project.Program_Version__c
                                                            Order by Name ASC];
            for(Proposal_Category__c categoryRec : categoryList) {
                categoryOptionList.add(new SelectOption(categoryRec.Name, categoryRec.Name));
                categoryNameToCategoryProjectTypeMap.put(categoryRec.Name, categoryRec.Project_Type__c);
            }
        }
    }

    /*
    * Method Name: saveProposalInfo
    * Description: Update Proposal Info
    * @param:  none
    * @return: PageReference
    */
    public PageReference saveProposalInfo() {
        isDueDatePassed = checkForDueDate();

        if((isDueDatePassed || isRollingSolicitationLockDown) && !isExceptionalAccessProvided) {
            init();
        } else {
	        	if(project.Id != null) {
		            update project;
		        }
            Map<String, String> checklistQuestionSequenceNumberToResponseMap = new Map<String, String>();
            Map<String, String> disclosureQuestionSequenceNumberToResponseMap = new Map<String, String>();
            Map<String, String> contentQuestionSequenceNumberToResponseMap = new Map<String, String>();
            checklistQuestionSequenceNumberToResponseMap = (Map<String, String>)JSON.deserialize(checklistResponseList, Map<String, String>.class);
            disclosureQuestionSequenceNumberToResponseMap = (Map<String, String>)JSON.deserialize(disclosureResponseList, Map<String, String>.class);
            contentQuestionSequenceNumberToResponseMap = (Map<String, String>)JSON.deserialize(contentResponseList, Map<String, String>.class);

            for(Project_Content__c checklistQuestion : checklistQuestionList) {
                if(checklistQuestionSequenceNumberToResponseMap.containsKey(String.valueOf(checklistQuestion.Sequence__c))) {
                    checklistQuestion.Proposal_Question_Answer__c = checklistQuestionSequenceNumberToResponseMap.get(String.valueOf(checklistQuestion.Sequence__c));
                }
            }

            for(Project_Content__c disclosureQuestion : disclosureQuestionList) {
                if(disclosureQuestionSequenceNumberToResponseMap.containsKey(String.valueOf(disclosureQuestion.Sequence__c))) {
                    disclosureQuestion.Proposal_Question_Answer__c = disclosureQuestionSequenceNumberToResponseMap.get(String.valueOf(disclosureQuestion.Sequence__c));
                }
            }

            for(Project_Content__c contentQuestion : contentQuestionList) {
                if(contentQuestionSequenceNumberToResponseMap.containsKey(String.valueOf(contentQuestion.Sequence__c))) {
                    contentQuestion.Proposal_Question_Answer__c = contentQuestionSequenceNumberToResponseMap.get(String.valueOf(contentQuestion.Sequence__c));
                }
            }

            // Add logic to reset Answer according to response selected for Disclosure Questions.
            if(disclosureQuestionList.size() == 8) {
                if(disclosureQuestionList[0].Proposal_Question_Answer__c == 'No') {
                    disclosureQuestionList[0].Description__c = null;
                    disclosureQuestionList[1].Proposal_Question_Answer__c = null;
                    disclosureQuestionList[2].Proposal_Question_Answer__c = null;
                    disclosureQuestionList[3].Description__c = null;
                    disclosureQuestionList[4].Description__c = null;
                }
                if(disclosureQuestionList[5].Proposal_Question_Answer__c == 'No') {
                    disclosureQuestionList[5].Description__c = null;
                }
                if(disclosureQuestionList[0].Proposal_Question_Answer__c == 'Yes' || disclosureQuestionList[5].Proposal_Question_Answer__c == 'No') {
                    disclosureQuestionList[6].Description__c = null;
                    disclosureQuestionList[7].Description__c = null;
                }
            }

            if(checklistQuestionList.size() > 0) {
                update checklistQuestionList;
            }

            if(disclosureQuestionList.size() > 0) {
                update disclosureQuestionList;
            }

            if(contentQuestionList.size() > 0) {
                update contentQuestionList;
            }
        }

        PageReference pg;
        if(isNextClicked) {
            pg = next();
        } else {
            pg = null;
        }
        return pg;
    }
}