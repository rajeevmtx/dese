/*
*   Class Name: Solicitation_TriggerHandler
*   Description: Solicitation_TriggerHandler
*
*   Author/Date: Harshit Jain/ 02/09/2017
*
*   06/13/2017   Modified          Ajay Gautam        I-03009 FIX - Every Time the Solicitation Manager OR Program Manager Or Coordinator Field is edited,
                                                                    all proposals and project records associated to the Solicitation should be shared with new User
*/
public with sharing class Solicitation_TriggerHandler {

  /*
  * Method Name: beforeInsert
  * Description: Invoke from Solicitation_Trigger
  * @param: List<Program_Version__c> newList
  * @param: Map<Id, Program_Version__c> oldMap
  * @return: void
  */
    public static void beforeInsert(List<Program_Version__c> newList, Map<Id, Program_Version__c> oldMap) {
        if(Trigger.isInsert && Trigger.isBefore) {
          setDefaultSolicitationValues(newList);
          Solicitation_ChangeMod_Service.lockDownSolicitationRecords_ALLOW_OnInsert((List<Program_Version__c>)Trigger.new, null); // I-02707
        }
    }


  /*
  * Method Name: afterInsertUpdate
  * Description: Invoke from Solicitation_Trigger
  * @param: List<Program_Version__c> newList
  * @param: Map<Id, Program_Version__c> oldMap
  * @return: void
  */
    public static void afterInsertUpdate(Map<Id, Program_Version__c> newMap, Map<Id, Program_Version__c> oldMap) {
        copyProposalQuestions(newMap, oldMap);
        if(Trigger.isUpdate) {
          Solicitation_ChangeMod_Service.lockDownSolicitationRecords((List<Program_Version__c>)Trigger.new, (Map<Id, Program_Version__c>) Trigger.oldMap); // T-02179
          checkProgramTemplate(newMap,oldMap);
          shareProjectsIfSolicitationMgmtFieldsChanged((List<Program_Version__c>)Trigger.new, (Map<Id, Program_Version__c>) Trigger.oldMap); // I-03009
        }

        if(Trigger.isInsert) {
            copyProgramTemplates(newMap);
            copyDueDiligenceQuestions(newMap);
        } 
        if(Trigger.isInsert && Trigger.isAfter) {
          Solicitation_ChangeMod_Service.lockDownSolicitationRecords_RESET_OnInsert((List<Program_Version__c>)Trigger.new, null); // I-02707
        }
        Solicitation_Notification_Service.manageSolicitationAnnoucementNotifications_ReviewTeam((List<Program_Version__c>)Trigger.new, (Map<Id, Program_Version__c>) Trigger.oldMap); // S-00724
        Solicitation_Notification_Service.manageSolicitationScoringUnderReviewNotifications_ReviewTeam((List<Program_Version__c>)Trigger.new, (Map<Id, Program_Version__c>) Trigger.oldMap); // S-00724
        Solicitation_Notification_Service.manageSolicitationScoringReminderNotifications_ReviewTeam((List<Program_Version__c>)Trigger.new, (Map<Id, Program_Version__c>) Trigger.oldMap); // S-00724
    }

  /*
  * Method Name: setDefaultSolicitationValues
  * Description: I-02744: Set Solicitation Default values
  * @param: List<Program_Version__c> newList
  * @return: void
  */
    private static void setDefaultSolicitationValues(List<Program_Version__c> newList) {

      Id solicitationRecordTypeId = (
                                      Utility_RecordType_Helper.getRecordType('Program_Version__c', Solicitation_Helper.SOLICITATION_RECORDTYPE_DEVELOPERNAME) != null ?
                                      Utility_RecordType_Helper.getRecordType('Program_Version__c', Solicitation_Helper.SOLICITATION_RECORDTYPE_DEVELOPERNAME).Id :
                                      null
                                    );

      for(Program_Version__c objSolicitation : newList) {
        if(
            (solicitationRecordTypeId != null && objSolicitation.RecordTypeId == solicitationRecordTypeId ) &&
            ( Solicitation_Helper.SOLICITATION_TYPE_DUE_DATE.equalsIgnoreCase(objSolicitation.Solicitation_Type__c)  ||
              Solicitation_Helper.SOLICITATION_TYPE_ROLLING.equalsIgnoreCase(objSolicitation.Solicitation_Type__c)
            ) ) {

      if(String.isBlank(objSolicitation.Certification_Statement_for_Applicant__c)) {
        objSolicitation.Certification_Statement_for_Applicant__c = Label.CORE_Default_Solicitation_AttestationStatement;
      } 
        }
      }
    }

    /*
    * Method Name: I-03009 - shareProjectsIfSolicitationMgmtFieldsChanged
    * Description: Every Time the Solicitation Manager OR Program Manager OR Default Project Coordinator Field is edited,
                   all proposals and project records associated to the Solicitation should be shared with new User
    * @param: Map<Id,Program_Version__c> newMap
    * @param: Map<Id,Program_Version__c> oldMap
    * @return: void
    */
      public static void shareProjectsIfSolicitationMgmtFieldsChanged(List<Program_Version__c> newList, Map<Id, Program_Version__c> oldMap) {

          Id solicitationRecordTypeId = (
                                      Utility_RecordType_Helper.getRecordType('Program_Version__c', Solicitation_Helper.SOLICITATION_RECORDTYPE_DEVELOPERNAME) != null ?
                                      Utility_RecordType_Helper.getRecordType('Program_Version__c', Solicitation_Helper.SOLICITATION_RECORDTYPE_DEVELOPERNAME).Id :
                                      null
                                    );

          Set<Id> solicitationIds = new Set<Id>();

          for(Program_Version__c objSolicitation : newList) {
            if(
                   (solicitationRecordTypeId != null && objSolicitation.RecordTypeId == solicitationRecordTypeId )
                && (  Solicitation_Helper.SOLICITATION_TYPE_DUE_DATE.equalsIgnoreCase(objSolicitation.Solicitation_Type__c)  ||
                      Solicitation_Helper.SOLICITATION_TYPE_ROLLING.equalsIgnoreCase(objSolicitation.Solicitation_Type__c)
                   )
                && oldMap != null && oldMap.containsKey(objSolicitation.Id)
                && (
                   objSolicitation.Solicitation_Manager__c != oldMap.get(objSolicitation.Id).Solicitation_Manager__c ||
                   objSolicitation.Default_Project_Coordinator__c != oldMap.get(objSolicitation.Id).Default_Project_Coordinator__c ||
                   objSolicitation.Program_Manager__c != oldMap.get(objSolicitation.Id).Program_Manager__c
                   )
                ) {
                   solicitationIds.add(objSolicitation.Id);
            }
          }

          if(solicitationIds.size() > 0) {

            List<Project__c> applicableProjects = [SELECT  Program_Version__c, Id, Status__c
                                                   FROM    Project__c
                                                   WHERE   Program_Version__c IN :solicitationIds
                                                   AND     Status__c IN :Solicitation_Helper.SOLICITATION_MGMT_PENDING_REVIEW_AND_AFTER_STATUSES
                                                   AND     (Concept_Paper__c = true OR Proposal__c = true)];
            if(applicableProjects.size() > 0) {
              ProjectSharing_Helper.shareWithSolicitationManager_UtilOps(applicableProjects);
            }

          }

      }


  /*
  * Method Name: checkProgramTemplate
  * Description: check is there any program template in solicitation Record
  * @param: Map<Id,Program_Version__c> newMap
  * @param: Map<Id,Program_Version__c> oldMap
  * @return: void
  */
    public static void checkProgramTemplate(Map<Id,Program_Version__c> newMap, Map<Id, Program_Version__c> oldMap) {

        Map<Id,Program_Version__c> validSolicitationMaps = new Map<Id,Program_Version__c> ();
        for(Program_Version__c version : [SELECT id,Solicitation_Type__c,program__c,
                                                    (SELECT id FROM Program_Templates__r)
                                          FROM Program_Version__c where Id IN: newMap.keySet()] ) {

            if(version.Program_Templates__r.size() == 0 && !validSolicitationMaps.containsKey(version.Id) &&
                (newMap.get(version.Id).Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_DUE_DATE ||
                 newMap.get(version.Id).Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_ROLLING ) &&
                 newMap.get(version.Id).Solicitation_Type__c != oldMap.get(version.Id).Solicitation_Type__c ) {

                validSolicitationMaps.put(version.id,version);
            }
        }

        if(validSolicitationMaps.size() > 0){
            copyProgramTemplates(validSolicitationMaps);
        }

    }

  /*
  * Method Name: copyProposalQuestions
  * Description: Copy proposal questions
  * @param: Map<Id,Program_Version__c> newMap
  * @param: Map<Id,Program_Version__c> oldMap
  * @return: void
  */
    public static void copyProposalQuestions(Map<Id, Program_Version__c> newMap, Map<Id, Program_Version__c> oldMap){

        Set<Id> solicitationIds = new Set<Id>();
        Set<Id> validSolicitationIds = new Set<Id>();
        List<Program_Version__c> solicitationList = new List<Program_Version__c>();

        for(Program_Version__c version : newMap.values()) {
            if(!version.isClone()
                && (version.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_DUE_DATE
                    || version.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_ROLLING)
                && (oldMap == null || (oldMap != null && oldMap.get(version.Id).Solicitation_Type__c != version.Solicitation_Type__c))) {
                solicitationIds.add(version.Id);
            }
        }

        if(solicitationIds.size() > 0) {
            solicitationList = [SELECT ID,Name,
                                       (SELECT  Name
                                          FROM Program_Contents__r
                                         WHERE RecordTypeId =: Utility_RecordType_Helper.getRecordType('Program_Content__c',ProgramContent_Helper.PROPOSAL_RECORDTYPE).Id)
                                  FROM Program_Version__c
                                 WHERE ID IN: solicitationIds];

            for(Program_Version__c solicitation : solicitationList) {
                if(solicitation.Program_Contents__r.size() == 0) {
                    validSolicitationIds.add(solicitation.ID);
                }
            }

            if(validSolicitationIds.size() > 0) {
                Utility_CopyProposalQuestions.copyProposalQuesToProgramContent(validSolicitationIds);
            }
        } 
    }

  /*
  * Method Name: copyDueDiligenceQuestions
  * Description: Copy Due Diligence Questions on Solicitation I-02657: Added by TK
  * @param: Map<Id,Program_Version__c> newMap
  * @return: void
  */
    public static void copyDueDiligenceQuestions(Map<Id, Program_Version__c> newMap) {
        List<Program_Version__c> validSolicitationList = new List<Program_Version__c>();
        for(Program_Version__c solicitationRec : newMap.values()) {
            if(solicitationRec.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_DUE_DATE ||
                solicitationRec.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_ROLLING) {
                validSolicitationList.add(solicitationRec);
            }
        }
        if(validSolicitationList.size() == 0) {
            return;
        }

        List<Program_Content__c> programContentList = new List<Program_Content__c>();
        Id dueDiligenceRecordTypeId = Utility_RecordType_Helper.getRecordType('Program_Content__c', ProgramContent_Helper.DUE_DILIGENCE_RECORD_TYPE_DEVELOPER_NAME).Id;
        Program_Content__c programContent;

        List<Due_Diligence_Question__mdt> dueDiligenceQuestionLst = [SELECT Active__c, Display_Label__c, Sequence__c FROM Due_Diligence_Question__mdt];
        for(Program_Version__c solicitationRec : validSolicitationList) {
            for(Due_Diligence_Question__mdt dueDeligenceRec : dueDiligenceQuestionLst) {
                programContent = new Program_Content__c();
                programContent.recordTypeId = dueDiligenceRecordTypeId;
                programContent.Program_Version__c = solicitationRec.Id;
                programContent.Active__c =  dueDeligenceRec.Active__c;
                programContent.Display_Label__c = dueDeligenceRec.Display_Label__c;
                programContent.Sequence__c = dueDeligenceRec.Sequence__c;
                programContentList.add(programContent);
            }
        }

        if(programContentList.size() > 0) {
            insert programContentList;
        }
    }

  /*
  * Method Name: copyProgramTemplates
  * Description: Copy one program template from Program__c to Solicitation
  * @param: Map<Id,Program_Version__c> newMap
  * @return: void
  */
    public static void copyProgramTemplates(Map<Id, Program_Version__c> newMap) {

        List<Program_Template__c> programTemplateListToInsert = new List<Program_Template__c>();
        List<Program_Template_Page__c> programTemplatePageListToInsert = new List<Program_Template_Page__c>();
        Map<Id, List<Program_Template_Page__c>> solicitationIdToTemplatePageMap = new Map<Id, List<Program_Template_Page__c>>();
        Map<Id, List<Id>> programIdTosolicitationRecIdsMap = new Map<Id, List<Id>>();

        for(Program_Version__c solicitation :newMap.values()) {

            if((solicitation.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_DUE_DATE ||
                            solicitation.Solicitation_Type__c == Solicitation_Helper.SOLICITATION_TYPE_ROLLING) ) {

                if(!programIdTosolicitationRecIdsMap.containsKey(solicitation.program__c)) {
                    programIdTosolicitationRecIdsMap.put(solicitation.program__c, new List<Id>());
                }
               programIdTosolicitationRecIdsMap.get(solicitation.program__c).add(solicitation.Id);
            }
        }

        for(Program_Template__c progTemplateRec : [SELECT  Name, Program__c, Template_Type__c, Status__c, Description__c,
                                                                Migration_ID__c, Solicitation__c,
                                                                (SELECT Name, Program_Template__c, Page_Type__c, Page_Name__c,
                                                                        Sequence__c,Migration_ID__c,
                                                                        Page_Description__c
                                                                   FROM Program_Template_Pages__r)
                                                        From Program_Template__c
                                                        WHERE Solicitation__c = null
                                                        AND Template_Type__c =: WizardTemplate_Helper.TEMPLATETYPE_PROPOSAL
                                                        AND Program__c IN : programIdTosolicitationRecIdsMap.keySet()]) {
            for(Id programVersionId : programIdTosolicitationRecIdsMap.get(progTemplateRec.Program__c)) {
                if(!solicitationIdToTemplatePageMap.containskey(programVersionId)) {
                    Program_Template__c newProgramTemplate = progTemplateRec.clone(false,true);
                    newProgramTemplate.Solicitation__c = programVersionId;
                    programTemplateListToInsert.add(newProgramTemplate);      // Insert Program Template
                    //Create program Template Pages To Map
                    for(Program_Template_Page__c programTempPageRec : progTemplateRec.Program_Template_Pages__r) {
                        if(!solicitationIdToTemplatePageMap.containsKey(programVersionId)) {
                            solicitationIdToTemplatePageMap.put(programVersionId, new List<Program_Template_Page__c>());
                        }
                        solicitationIdToTemplatePageMap.get(programVersionId).add(programTempPageRec.clone(false,true));
                    }
                }
            }
        }
 
        if(programTemplateListToInsert.size() > 0) {
            insert programTemplateListToInsert;
        }
 
        //Insert Program Template Page
        for(Program_Template__c programTemplate : programTemplateListToInsert) {
            if(solicitationIdToTemplatePageMap.containsKey(programTemplate.Solicitation__c)) {
                for(Program_Template_Page__c templatePage: solicitationIdToTemplatePageMap.get(programTemplate.Solicitation__c)) {
                    templatePage.Program_Template__c = programTemplate.Id;
                    programTemplatePageListToInsert.add(templatePage);
                }
            } 
        }

        if(programTemplatePageListToInsert.size() > 0) {
            insert programTemplatePageListToInsert;
        }
    }
}