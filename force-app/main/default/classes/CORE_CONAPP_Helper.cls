/*
* Class Name: CORE_CONAPP_Helper
* Description: Helper class for contractor application
* Author/Date:  Harshit   06/26/2016
*
* Date         New/Modified      Author             Description
* 05/19/2017   Modified          Ghanshyam          Commenting
*
*/
public with sharing class CORE_CONAPP_Helper {

  public static String appliedProgramVersionId;
  public static final String  OPEN_PROGRAM_VERSION_STATUS = 'Open';
  public static final String  CONTRACTOR_APPLICATION_TYPE = 'Contractor Application';
  public static final String  CONAPP_NYSUN_ZEV_RECORDTYPE = 'Innovation_Zero_Emission_Vehicles_Application';
  public static final String  CONAPP_CT_RECORDTYPE = 'Innovation_Clean_Transportation_Application';
  public static final String  CONAPP_NYSUN_RECORDTYPE = 'NY_Sun_Application';
  public static final String  CONAPP_PS_RECORDTYPE = 'Pellet_Stove_Application';
  public static final String  CONAPP_RTEM_RECORDTYPE = 'Real_Time_Energy_Management_Application';
  public static final String  CONAPP_GSHP_RECORDTYPE = 'Ground_Source_Heat_Pump_Application';
  public static final String  CONAPP_NEW_CONSTRUCTION_RECORDTYPE = 'New_Construction_Program_Application';

  /*
    * Method Name: createContractorApp
    * Description: Create contractor application for applied program
    * @param: programFamily
    * @param: programName
    * @return: Contractor_Application__c
    */
  public static Contractor_Application__c createContractorApp(String programFamily, String programName) {
    String contractorAppRT;
    String appliedProgramRT;
    Boolean skipApplicationCreation = false;
    Contractor_Application__c contractorApp = new Contractor_Application__c();
    Application_Content__c applicationContent = new Application_Content__c();

    //Applied program application content record type
    appliedProgramRT = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'Applied_Program').Id;

    //Applied program contractor application record type
    if(programFamily == 'Renewable Heating and Cooling'){
            contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_PS_RECORDTYPE).Id;
            skipApplicationCreation = true;
        }else if(programFamily == 'Innovation' && programName == Program_Helper.APP_TYPE_ZEV){
            contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_NYSUN_ZEV_RECORDTYPE).Id;
        }else if(programFamily == 'Innovation' && programName == Program_Helper.APP_TYPE_CT){
            contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_CT_RECORDTYPE).Id;
        }else if(programFamily == 'Commercial' && programName == Program_Helper.APP_TYPE_RTEM){         //T-03381(Updated by RJ: 10/12/2017)
            contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_RTEM_RECORDTYPE).Id;
            skipApplicationCreation = false;
        }else if(programFamily == 'NY-Sun' && programName == Program_Helper.APP_TYPE_NYSUN_COMMERCIAL){
            contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_NYSUN_RECORDTYPE).Id;
        }else if(programFamily == 'NY-Sun' && programName == Program_Helper.APP_TYPE_NYSUN_RESIDENTIAL){
            contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_NYSUN_RECORDTYPE).Id;
            skipApplicationCreation = true;
        }else if(programFamily == 'NY-Sun' && programName == Program_Helper.APP_TYPE_NYSUN_BOTH){
            contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_NYSUN_RECORDTYPE).Id;
            appliedProgramVersionId = Program_Helper.APP_TYPE_NYSUN_BOTH;
            skipApplicationCreation = true;
        }else if(programFamily == 'Renewable Heating and Cooling' && programName == Program_Helper.APP_TYPE_SMALL_GSHP){
          contractorAppRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', CONAPP_GSHP_RECORDTYPE).Id;
        }

    //Get applied program version Id
    for(Program_Version__c pVersion : [SELECT Id
                                             FROM Program_Version__c
                                            WHERE Program__r.Application_Type__c =: programName
                                              AND Status__c =: OPEN_PROGRAM_VERSION_STATUS]) {
      appliedProgramVersionId = pVersion.Id; 
    }


    // Hotfix for RTEM T-03453
    if(programName == Program_Helper.APP_TYPE_RTEM) {
      for(Program_Version__c objProgVersion : [SELECT Id,RecordTypeId,RecordType.DeveloperName,
                                                      Solicitation_Type__c
                                              FROM    Program_Version__c
                                              WHERE   Program__r.Application_Type__c =: programName
                                              AND     Status__c =: OPEN_PROGRAM_VERSION_STATUS]) {

        if(objProgVersion.RecordType.DeveloperName == Program_Helper.APP_TYPE_RTEM &&
           (Solicitation_Helper.SOLICITATION_TYPE_OPEN_ENROLLMENT.equalsIgnoreCase(objProgVersion.Solicitation_Type__c) ||
            String.isBlank(objProgVersion.Solicitation_Type__c))) {
          appliedProgramVersionId = objProgVersion.Id;
          break;
        }
      }
    }
    // EndOf: Hotfix for RTEM T-03453



    //Populated contractor app and application content data
    contractorApp.RecordTypeId = contractorAppRT;
    contractorApp.Contractor__c = true;

    applicationContent.RecordTypeId = appliedProgramRT;
    applicationContent.Program_Version__c = CORE_Helper.isValidSalesforceId(appliedProgramVersionId) ? appliedProgramVersionId : null;

    try {
      if(appliedProgramVersionId != null && !skipApplicationCreation) {
        insert contractorApp; //Insert contractor application
        applicationContent.Contractor_Application__c = contractorApp.Id;
        insert applicationContent; //Insert applied program application content record
        createWizardTemplateData(contractorApp.Id, programName, CONTRACTOR_APPLICATION_TYPE);
        createApplicationContentData(contractorApp.Id, appliedProgramVersionId, false);
      }
    } catch(DMLException e) {}

    return contractorApp;
   }


   /**
   * Name: createWizardTemplateData
   * Param: applicationId
   * Param: applicationType
   * Param: templateType
   * Desc: Copy program template data to wizard template
   **/
   public static void createWizardTemplateData(String applicationId, String applicationType, String templateType) {

    List<Program_Template__c> programTemplateList = [SELECT Description__c, Program__c, Status__c, Template_Type__c,
                                                        (SELECT Page_Name__c, Name, Page_Type__c, Program_Template__c, Sequence__c,Page_Description__c FROM Program_Template_Pages__r)
                                                         FROM Program_Template__c
                                                         WHERE Program__r.Application_Type__c =: applicationType
                                                         AND Template_Type__c =: templateType
                                                         AND Status__c = 'Active'];


        if(programTemplateList.size() == 0) {
            return;
        }

        Program_Template__c programTemplate = programTemplateList[0];

        Wizard_Template__c wizardTemplateRec = new Wizard_Template__c();
        wizardTemplateRec.Description__c = programTemplate.Description__c;
        wizardTemplateRec.Program__c = programTemplate.Program__c;
        wizardTemplateRec.Service_Provider_Application__c = applicationId;
        wizardTemplateRec.Status__c = programTemplate.Status__c;
        wizardTemplateRec.Template_Type__c = programTemplate.Template_Type__c;
        insert wizardTemplateRec;

        List<Wizard_Template_Page__c> wizardTempPageList = new List<Wizard_Template_Page__c>();

        for(Program_Template_Page__c programTempPageRec : programTemplate.Program_Template_Pages__r) {

            Wizard_Template_Page__c wizardTempPageRec = new Wizard_Template_Page__c();
            wizardTempPageRec.Page_Name__c = programTempPageRec.Page_Name__c;
            wizardTempPageRec.Page_Type__c = programTempPageRec.Page_Type__c;
            wizardTempPageRec.Wizard_Template__c = wizardTemplateRec.Id;
            wizardTempPageRec.Sequence__c = programTempPageRec.Sequence__c;
            wizardTempPageRec.Page_Description__c = programTempPageRec.Page_Description__c;
            wizardTempPageRec.Name = programTempPageRec.Name;
            wizardTempPageRec.Status__c = 'Draft';
            wizardTempPageList.add(wizardTempPageRec);
        }

        if(wizardTempPageList.size() > 0) {
            insert wizardTempPageList;
        }
   }

   /**
   * Name: createApplicationContentData
   * Param: applicationId
   * Param: programVersionId
   * Param: isPayeeType
   * Desc: Copy program content data to application content
   **/
   public static void createApplicationContentData(String applicationId, String programVersionId, Boolean isPayeeType) {
    String documentRecTypeId = Utility_RecordType_Helper.getRecordType('Program_Content__c', 'Document').Id;
        String documentTypeId = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'Document').Id;
    List<Program_Content__c>   programContentList ;
        // Only signed document need to be attached for payee type application #T-01229
        if(isPayeeType){
            programContentList = [select Document_Title__c, Validation_Logic__c, Conditionally_Required__c, Type__c,URL__c,
                                  Sub_Type__c, Validation_Notes__c, Mandatory_by_Default__c, Description__c, Sequence__c
                                  from Program_Content__c
                                  where Program_Version__c = : CORE_Helper.doEscapeSingleQuotes(programVersionId)
                                  AND Type__c =: CORE_Helper.TYPE_CON_APP
                                  AND Sub_Type__c =: CORE_Helper.SUB_TYPE_CON_APP];
        }else{
            programContentList = [select Document_Title__c, Validation_Logic__c, Conditionally_Required__c, Type__c,URL__c,
                                  Sub_Type__c, Validation_Notes__c, Mandatory_by_Default__c, Description__c, Sequence__c
                                  from Program_Content__c
                                  where Program_Version__c = : CORE_Helper.doEscapeSingleQuotes(programVersionId)
                                  AND Type__c =: CORE_Helper.TYPE_CON_APP];
        }


        List<Application_Content__c> applicationContentList = new List<Application_Content__c>();
        for(Program_Content__c progContent : programContentList) {
            Application_Content__c appContent = new Application_Content__c();
            appContent.Document_Title__c = progContent.Document_Title__c;
            appContent.Validation_Logic__c = progContent.Validation_Logic__c;
            appContent.Conditionally_Required__c = progContent.Conditionally_Required__c;
            appContent.Validation_Notes__c = progContent.Validation_Notes__c;
            appContent.Mandatory_by_Default__c = progContent.Mandatory_by_Default__c;
            appContent.Project_Description__c = progContent.Description__c;
            appContent.Sequence__c = progContent.Sequence__c;
            appContent.Type__c = progContent.Type__c;
            appContent.URL__c = progContent.URL__c;
            appContent.Sub_Type__c = progContent.Sub_Type__c;
            appContent.Contractor_Application__c = applicationId;
            appContent.RecordTypeId = documentTypeId;
            if(appContent.Mandatory_by_Default__c == null || !appContent.Mandatory_by_Default__c)
            {
              appContent.Configured_From_Solicitation__c = true;
            }
            applicationContentList.add(appContent);
        }

        if(applicationContentList.size() > 0) {
            insert applicationContentList;
        }
   }
}