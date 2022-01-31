/*
*   Class Name: CORE_CONAPP_Application_Controller
*   Description: Core Class For Contractor Application Flow
*   Author/Date: Harshit Jain/ 2/24/2016
*
*   Date            New/Modified       Author          Description
*   4/26/2017        Modified        Harshit Jain
*   10/14/2017       Modified        Kalpna Bindal     T-03393
*   11/02/2017       Modified        Ajay Gautam       I-03621 - Programs listed in the drop down list would be alphabetical.
*/

global without sharing class CORE_CONAPP_Application_Controller {

    public static String REFERENCE_TYPE_COMPANY_REFERENCE = 'Company Reference';
    private static final String CON_APP_NY_SUN_APPLICATION_RECORD_TYPE_DEV_NAME = 'NY_Sun_Application';
    private static final String CON_APP_TYPE_PAYEE = 'payee';

    public String applicationId{get; set;}

    public Contractor_Application__c serviceProviderApp{get; set;}

    public String currentPage{get; set;}

    public Boolean hasError {get; set;}

    public boolean isSubmit{get; set;}

    public boolean isURLMod{get; set;}

    public List<SelectOption> programList{get; set;}



    public List<OtherDocument> otherDocumentList {get; set;}
    public Integer rowNumber{get; set;}

    public String applicationContentName {get; set;}

  public String selectedProjectRefrenceAppContentId {get; set;}

    public String applicationContentId {get; set;}

    public String selectedProgram{get; set;}

    public String selectedProgramName{get; set;}

    public boolean isOptionASelected{get; set;}

    public boolean isOptionBSelected{get; set;}

    public List<Application_Content__c> appContents{get; set;}

    public List<Application_Content__c> priorProjectAppContents{get; set;}

    public List<Application_Content__c> appOptionBContents{get; set;}

    public List<Program_Content__c> documents{get; set;}

    public String selectedDocuments{get; set;}

    public Application_Content__c primaryContact {get;set;}

    public Application_Content__c projectRefrenceApplicationConRec {get;set;}

    public List<Application_Content__c> nysunApplicationContents{get;set;}

    public Application_Content__c authorizedSignatoryContact {get;set;}

    public Application_Content__c accountReceivableContact {get;set;}

    public Map<String, String> appContentNameToDocStatusMap{get; set;}

    public Map<String, Boolean> appContentIdToConditionallyRequiredMap{get; set;}

    public DateTime signedDate{get; set;}

    public boolean isPayeeApp {get;set;}

    public String supportedFileTypes{get{

        String supportedFileTypes = '';

        if(Documents_File_Extensions__c.getAll() != null){
            for(String fileType : Documents_File_Extensions__c.getAll().keySet()){

                if(supportedFileTypes != ''){

                    supportedFileTypes += ',';
                }

                supportedFileTypes += fileType;
            }
        }

        return supportedFileTypes;
    }}

    public String domainURL{get; set;}

    public List<SelectOption> programFamilyList{get; set;}

    public String selectedProgramFamily{get; set;}

    public String surveyLink {get; set;}

    public String envelopeId;

    public String taxIdNumber{get; set;}

    public String summaryDetail {get;set;}

    public String documentSummary {get;set;}

    public List<Application_Content__c> applicationContent {get;set;}

    public List<Project_Document__c> attachmentHistory {get; set;}

    public Map<String, Attachment> appContentNameToAttachmentRecMap{get; set;}

    public Map<String, Attachment> nysunAppContentNameToAttachmentRecMap{get; set;}

    public Map<String, Attachment> nysunAppContentNameToNewAttachMap{get; set;}

    public Map<String, Attachment> appContentNameToNewAttachMap{get; set;}

    public Map<String, Application_Content__c> appContentNameToAppContentRecMap{get; set;}

    public List<Application_Content__c> nysunnProjectContents {get;set;}

  //public List<SelectOption> staffPossessCredientials {get; set;}
  //public List<SelectOption> serviceProvided {get; set;}
  //public List<SelectOption> regionalCountiesServed {get; set;}


    // Realetd to NYSUN_APPINTAKE_Contractors_Page variables
    public String serviceRole{get; set;}
    public String systemRole{get; set;}
    public String drillerRole{get; set;}
    public List<SelectOption> serviceProviderList{get; set;}
    public String selectedServiceProvider{get; set;}
    public List<SelectOption> systemProviderList{get; set;}
    public String selectedSystemProvider{get; set;}
    public String serviceProviderLabel{get; set;}
    public String systemProviderLabel{get; set;}
    public Boolean isSurveyAlreadyTaken {get; set;}
    public String nysunCommertialProgramVersionId {get;set;}
    public String nysunResidentialProgramVersionId {get;set;}
    public String zeroEmissionVehiclesProgramVersionId {get;set;}
    public String cleanTransportationProgramVersionId {get;set;}
    public String GSHPSmallProgramVersionId {get;set;}
    public String GSHPLargeProgramVersionId {get;set;}
    private static final String PRIMARY_CONTRACTOR = 'Primary Contractor';
    public boolean isGSHPApp {get;set;}
     
    public boolean isGSHPSmallApp {get;set;}
    public boolean isRTEMApp {get;set;}
    public boolean isZEVApp {get;set;}
    public boolean isRTEMInternalUser {get;set;}
    public boolean isNysunApp {get;set;}
    public boolean isDisplayDefaultSubmissionMsg {get;set;}
    public string isInterestedInMenterProgram {get;set;}
    public string isFullStatus{get;set;}
    private string selectedProgramNameStr;

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

    /*
        rahuls91221 [24th July 2016 | I-01042]:
        - added a property to hold confirm message in references page on click of save button.
        - name is kept generic and can be used in other pages as well
    */

    public String strMessage { get; set; }

    String payeeType;
    String programFamily;
    public String programName{get;set;}
    String isSubmitedApp;

    public CORE_CONAPP_Application_Controller(){

        isPayeeApp = false;
        applicationId = ApexPages.currentPage().getParameters().get('ApplicationId');
        payeeType = ApexPages.currentPage().getParameters().get('type');
        programFamily = ApexPages.currentPage().getParameters().get('programFamily');
        programName = ApexPages.currentPage().getParameters().get('programName');
        isSubmitedApp = ApexPages.currentPage().getParameters().get('isSubmit');
        serviceProviderApp = new Contractor_Application__c();


        isSubmit = false;

        isURLMod = false;

        isOptionASelected = false;

        isOptionBSelected = false;

        isGSHPSmallApp = false;

        isSurveyAlreadyTaken = false;

        isDisplayDefaultSubmissionMsg = true;

        serviceProviderLabel = '';

        systemProviderLabel = '';

        selectedProgramName = '';

        nysunCommertialProgramVersionId = null;

        nysunResidentialProgramVersionId = null;

        zeroEmissionVehiclesProgramVersionId = null;

        cleanTransportationProgramVersionId = null;

        GSHPSmallProgramVersionId = null;

        GSHPlargeProgramVersionId = null;

        selectedDocuments = '';

        programList = new List<SelectOption>();

        documents = new List<Program_Content__c>();

        primaryContact = new Application_Content__c();

        projectRefrenceApplicationConRec = new Application_Content__c();

        authorizedSignatoryContact = new Application_Content__c();

        accountReceivableContact = new Application_Content__c();

        appContents = new List<Application_Content__c>();

        priorProjectAppContents = new List<Application_Content__c>();

        appOptionBContents = new List<Application_Content__c>();

        Set<Id> programVersions = new Set<Id>();


        String selectedDocs = '';

        domainURL = URL.getSalesforceBaseUrl().toExternalForm();
        // added Type__c for task #T-01286 to check payee type Type__c
        for(Contractor_Application__c serviceApp : [SELECT Zip_Code__c, Facility_Type__c, Offering_Financing__c, Name,
                                                          Total_Number_of_Installations_Completed__c,
                                                          Street_Address__c, State__c,
                                                          Select_Application_Option__c,
                                                          Contractor_Credentials__c, Authorized_Signature_Date__c,
                                                          Residential_Small_Commercial__c,
                                                          Phone__c, Participation_Aggrement__c,
                                                          Parent_Company__c, Number_of_Years_Professionally__c,
                                                          Number_of_Years_Designing_PV_Systems__c,
                                                          Installer_Signature_Date__c, Installer_Phone__c,
                                                          Installer_Name__c, Installer_Email__c,
                                                          Installer_Credentials__c, Installed_Capacity_kW__c,
                                                          Id, Has_Suspended_Revoked__c, RecordType.DeveloperName,
                                                          Has_Filed_Petition__c,Has_Debbared__c,Governmental_Entity_Terminated_Text__c,Non_Responsibility_Text__c,
                                                          Has_Convicted__c,Is_Proprietary__c,Proprietary_Text__c,Has_Individual__c,State_Finance_Law_Non_Responsibility__c,
                                                          Non_Responsibility__c,
                                                          Has_Governmental_Entity_Terminated__c, Formerly_PON_2112__c,
                                                          Facility__c, Experience_with_Shading_Analysis_Tools__c,
                                                          Contractor_Signature_Date__c, Contractor_Name__c,
                                                          Contractor_Email__c, Contractor_Contact__c,
                                                          Commercial_Industrial__c, City__c, Status__c,
                                                          Legal_Business_Name__c, Signatory_Contacta_Same_as_Primary__c,
                                                          Account_Receivable_Contact_as_Primary__c,
                                                          Years_in_PV_Industry__c, Total_Solar_Projects_Completed__c,
                                                          Contractor__c, Builder__c,Driller__c,
                                                          Participate_in_Other_State_SP_Other__c, Hyperlink_Project__c,Vehicle_Brand__c,
                                                          Reference_Type__c, EnvelopeId__c,
                                                          Employee_Identification_Number_EIN__c, Entity_Type__c, NYS_Minority_Owned__c,
                                                          NYS_Women_Owned__c, Exempt_Payee_Code__c, NYS_MWBE__c, NYS_Veteran_Owned__c,
                                                          Business_Name_Disregarded_Entity_Name__c, Tax_Identification_Type__c,
                                                          NABCEP_PV_Installation_Professional_Cert__c, IBEW_NECA_Training__c,
                                                          UL_PV_System_Installation_Certification__c,
                                                          Type__c,DMV_Dealer_ID__c,Staff_Possess_Credentials__c,Regional_Counties_Served__c,Services_Provided__c,
                                                          Participate_in_Other_State_Solar_Prog__c, Has_PV_Installation_Certification__c,
                                                          Loopfield_Type__c, Is_Full_Status__c, Mentorship__c,
                                                          Insurance_Cert_Exp_Date__c, IGSHPA_Cert_Exp_Date__c, CDG_Cert_Exp_Date__c,
                                                          DEC_Cert_Exp_Date__c, CVLD_Cert_Exp_Date__c,
                                                          (SELECT Program_Version__r.Id, Program_Version__r.Program__r.Name,
                                                            Program_Version__r.Document_Acknowledge_Summary__c, Program_Version__r.Summary__c,
                                                            Program_Version__r.Contractor_Label__c, Program_Version__r.Subcontractor_Label__c,
                                                            Applicant_s_Role_in_Project__c, Document_Title__c, Extension__c,
                                                            City__c, Customer_First_Name__c, Is_Greater_than_500_kW__c,
                                                            Customer_Last_Name__c, Email__c, Interconnection_Date__c,
                                                            Project_Name__c,Completed_Year__c,Dwelling_Units__c,Building_Type__c,Sq_Footage__c,
                                                            Services_Provided__c,Certification_Verification__c,Name_of_personnel_who_worked_on_project__c,Modeling_Software_Used__c,
                                                            Phone_Number__c, Program_Version__c, State__c, Street_Address__c,
                                                            System_Size_kW__c, Zip__c,RecordType.DeveloperName, Project_Description__c,
                                                            Program_Version__r.Service_Provider_Survey_ID__c,
                                                            Program_Version__r.System_Provider_Survey_ID__c, Company_Name__c,
                                                            Program_Version__r.System_Service_Provider_Survey_ID__c,URL__c,
                                                            Program_Version__r.Program__r.Application_Type__c, Title__c,Type__c
                                                           FROM Application_Contents__r order by Name),
                                                           (select Taken__c from Surveys_Taken__r)
                                                          FROM Contractor_Application__c
                                                          WHERE ID =: CORE_Helper.doEscapeSingleQuotes(applicationId)]){

            serviceProviderApp = serviceApp;
            System.debug('serviceProviderApp----------------->>>>'+serviceProviderApp.Driller__c);
              if(serviceProviderApp != null && CON_APP_NY_SUN_APPLICATION_RECORD_TYPE_DEV_NAME.equalsIgnoreCase(serviceProviderApp.RecordType.DeveloperName)
                                   && CON_APP_TYPE_PAYEE.equalsIgnoreCase(serviceProviderApp.Type__c)){
                isPayeeApp = true;
              }else{
                isPayeeApp = false;
              }

            isNysunApp = (serviceProviderApp.RecordType.DeveloperName == CON_APP_NY_SUN_APPLICATION_RECORD_TYPE_DEV_NAME) ? true : false;
            String completeURL = URL.getCurrentRequestUrl().toExternalForm();
            isGSHPApp = (serviceProviderApp.RecordType.DeveloperName == CORE_CONAPP_Helper.CONAPP_GSHP_RECORDTYPE) ? true : false;
            isZEVApp  = (serviceProviderApp.RecordType.DeveloperName == CORE_CONAPP_Helper.CONAPP_NYSUN_ZEV_RECORDTYPE) ? true : false;
            serviceProviderApp.State__c = (String.isBlank(serviceProviderApp.State__c)) ? 'New York' : serviceProviderApp.State__c;

            if(serviceApp.Surveys_Taken__r.size() > 0 && serviceApp.Surveys_Taken__r[0].Taken__c == 'true') {
                isSurveyAlreadyTaken = true;
            }   
 
            if(isZEVApp && isSubmitedApp == '1') {
                isDisplayDefaultSubmissionMsg = false;
            }
            envelopeId = serviceProviderApp.EnvelopeId__c;
            signedDate = serviceProviderApp.Authorized_Signature_Date__c;
            if(serviceApp.Status__c != 'Unsubmitted'){

                isSubmit = true;
            }

            for(Application_Content__c appContent : serviceApp.Application_Contents__r) {
                if(appContent.Program_Version__r != null &&
                   appContent.Program_Version__r.Program__r != null &&
                   appContent.Program_Version__r.Program__r.Name != null
                   && appContent.RecordType.DeveloperName == 'Applied_Program'){


                    if(appContent.Program_Version__r.Program__r.Application_Type__c == 'NY_Sun_Residential'){
                        isOptionASelected = true;
                    }

                    if(appContent.Program_Version__r.Program__r.Application_Type__c == 'NY_Sun_Commercial'){
                        isOptionBSelected = true;
                    }

                    if(appContent.Program_Version__r.Program__r.Application_Type__c == 'GSHP_Small_System') {
                        isGSHPSmallApp = true;
                    }

                    //surveyLink
                    if(serviceApp.Contractor__c && serviceApp.Builder__c) {
                        surveyLink = Site.getBaseUrl()+'/apex/TakeSurvey?id='+appContent.Program_Version__r.System_Service_Provider_Survey_ID__c+'&appId='+serviceApp.Id;
                    } else if(serviceApp.Contractor__c) {
                        surveyLink = Site.getBaseUrl()+'/apex/TakeSurvey?id='+appContent.Program_Version__r.Service_Provider_Survey_ID__c+'&appId='+serviceApp.Id;
                    }else if(serviceApp.Builder__c) {
                        surveyLink = Site.getBaseUrl()+'/apex/TakeSurvey?id='+appContent.Program_Version__r.System_Provider_Survey_ID__c+'&appId='+serviceApp.Id;
                    }

          //Same Survey for both Contractor and builder (T-03382 - Added By RJ - 23 Oct)
            if(isRTEMApp){
              surveyLink = Site.getBaseUrl()+'/apex/TakeSurvey?id='+appContent.Program_Version__r.System_Service_Provider_Survey_ID__c+'&appId='+serviceApp.Id;
            }
          // End of T-03382 - Added By RJ - 23 Oct


                    if(surveyLink != null) {
                        surveyLink += '&retPage=RTEM_CONAPP_References_Page&isSubmit=' + (isSubmit ? '1' : '0');
                    }

                    selectedProgramName += (selectedProgramName == '') ? appContent.Program_Version__r.Program__r.Name : '<br/>'+appContent.Program_Version__r.Program__r.Name;
                    summaryDetail = appContent.Program_Version__r.Summary__c;
                    documentSummary = appContent.Program_Version__r.Document_Acknowledge_Summary__c;
                    programVersions.add(appContent.Program_Version__r.Id);
                    serviceProviderLabel = appContent.Program_Version__r.Contractor_Label__c;
                    systemProviderLabel = appContent.Program_Version__r.Subcontractor_Label__c;
                }

                if(appContent.RecordType.DeveloperName == 'References' &&
                    appContent.Type__c == NYSUN_Helper.RESIDENTIAL_REFERENCE_TYPE){
                    appContents.add(appContent);
                }

                if(appContent.RecordType.DeveloperName == 'References' &&
                    appContent.Type__c == NYSUN_Helper.COMMERCIAL_REFERENCE_TYPE) {
                    appOptionBContents.add(appContent);
                }

                if(appContent.RecordType.DeveloperName == 'Contractor_Participation_Document'){

                    if(selectedDocs != ''){
                        selectedDocs += ';';
                    }

                    selectedDocs += appContent.Document_Title__c;
                }

                if(appContent.RecordType.DeveloperName == 'Contacts' && appContent.Type__c == 'Primary Contact') {
                    primaryContact = appContent;
                }

                if(appContent.RecordType.DeveloperName == 'Contacts' && appContent.Type__c == 'Account Receivable Contact') {
                    accountReceivableContact = appContent;
                }

                if(appContent.RecordType.DeveloperName == 'Contacts' && appContent.Type__c == 'Authorized Signatory Contact') {
                    authorizedSignatoryContact = appContent;
                }

            }
        }

        selectedDocuments = selectedDocs;

        Set<String> temp = new Set<String>();

        programVersions.remove(null);
        if(programVersions.size() > 0) {
            for(Program_Content__c content : [SELECT Document_Title__c, Type__c, URL__c FROM Program_Content__c
                                              WHERE Program_Version__c IN : programVersions
                                              AND RecordType.DeveloperName = 'Contractor_Participation_Document']) {
                if(!temp.contains(content.Document_Title__c)){
                    documents.add(content);
                    temp.add(content.Document_Title__c);
                }
            }
        }
        if(appContents.size() == 0){
            appContents.add(new Application_Content__c());
            appContents.add(new Application_Content__c());
            appContents.add(new Application_Content__c());
        }
        if(appOptionBContents.size() == 0){
            appOptionBContents.add(new Application_Content__c());
            appOptionBContents.add(new Application_Content__c());
            appOptionBContents.add(new Application_Content__c());
        }
    }


    public String submissionConfirmationMessage{get{

        String message = '';

        for(Application_Content__c appContent : [SELECT Program_Version__r.Contractor_App_Submission_Message__c FROM Application_Content__c
                                                 WHERE Contractor_Application__c =: CORE_Helper.doEscapeSingleQuotes(serviceProviderApp.Id)
                                                 AND RecordType.DeveloperName = 'Applied_Program']){

            if(appContent.Program_Version__r != null &&
               appContent.Program_Version__r.Contractor_App_Submission_Message__c != null){

                message = appContent.Program_Version__r.Contractor_App_Submission_Message__c;
            }
        }

        return message;
    }}

    /*
    * Method Name: saveSignedAttachment
    * Description: Save the Sigend document
    * @return Method does not return any value.
    */
    public void saveSignedAttachment(){

        String isSigned = ApexPages.currentPage().getParameters().get('event');
        if(signedDate == null && envelopeId != null && isSigned == 'signing_complete'){

            CORE_CONAPP_Docusign_Service.attachSignedDocument(serviceProviderApp.Id);
        }
    }

    public void checkSigningStatus(){
        for(Contractor_Application__c app : [SELECT Authorized_Signature_Date__c, EnvelopeId__c FROM Contractor_Application__c
                                             WHERE Id =: CORE_Helper.doEscapeSingleQuotes(serviceProviderApp.Id)]){
            signedDate = app.Authorized_Signature_Date__c;
            envelopeId = app.EnvelopeId__c;
            serviceProviderApp.Authorized_Signature_Date__c = app.Authorized_Signature_Date__c;
            serviceProviderApp.EnvelopeId__c = app.EnvelopeId__c;
        }
    }

    /*
    * Method Name: getProgramFamilyList
    * Description: Fetch all the Programs and Program Family List
    * @return a PageReference
    */
    public PageReference getProgramFamilyList(){
        Set<String> uniqueFamilies = new Set<String>();
        programFamilyList = new List<SelectOption>();
        programFamilyList.add(new SelectOption('', '--None--'));

        //bypass program selection if pragram family and program name passed in url
        if(String.isNotBlank(programFamily) && String.isNotBlank(programName)) {

          isURLMod = true;
            serviceProviderApp = CORE_CONAPP_Helper.createContractorApp(programFamily, programName);

            if(serviceProviderApp.Id == null) {
                selectedprogramFamily = programFamily;

                selectedProgram = CORE_CONAPP_Helper.appliedProgramVersionId;

                getProgramList();

            } else {
                Pagereference pg = new Pagereference('/apex/CORE_CONAPP_CompanyInformation_Page?ApplicationId=' + serviceProviderApp.Id);
                pg.setRedirect(true);
                return pg;
            }
        }

        //Filter out "Type" Program Families as they are meant for solicitations (Case 9024)
        for(Program__c prog : [Select Program_Family__c
                                 From Program__c
                                 Where Status__c = 'Active'
                                 And (Not Program_Family__c like '%Type%')
                                 And Program_Family__c != null
                                 ORDER BY Program_Family__c ASC]) {

            if(!uniqueFamilies.contains(prog.Program_Family__c)) {
                programFamilyList.add(new SelectOption(prog.Program_Family__c, prog.Program_Family__c));
                uniqueFamilies.add(prog.Program_Family__c);
            }
        }
        programFamilyList.sort(); // I-03621 - Programs listed in the drop down list would be alphabetical.
        uniqueFamilies.clear();

        if(payeeType != null && payeeType == 'payee'){

            selectedprogramFamily = 'NY-Sun';

            for(Program__c program : [SELECT Application_Type__c,
                                         (SELECT Id FROM Program_Versions__r WHERE Status__c = 'Open' limit 1)
                                      FROM Program__c
                                      WHERE Program_Family__c =: CORE_Helper.doEscapeSingleQuotes(selectedprogramFamily)
                                      AND Status__c = 'Active']) {

                for(Program_Version__c programVersion : program.Program_Versions__r) {
                    if(program.Application_Type__c == 'NY_Sun_Commercial') {
                        selectedProgram = programVersion.Id;
                    }
                }
            }

            return launchContractAppWizard();
        }

        return null;
    }


    /*
    * Method Name: getProgramList
    * Description: Create the Program List on basis of selected Program Family
    * @return - Method does not return a value
    */
    public void getProgramList() {
        Boolean isNYSUN = false;
        Boolean isGSHP = false;

        programList = new List<SelectOption>();

        serviceProviderLabel = '';
    Set<String> programFamilyNotToSearchDirectly = new Set<String>();
    programFamilyNotToSearchDirectly.add(Program_Helper.PROGRAM_FAMILY_NEW_CONSTRUCTION);

        for(Program__c program : [SELECT Id, Name, Description__c, Application_Type__c,
                                         (SELECT Id FROM Program_Versions__r WHERE Status__c =: ProgramVersion_Helper.STATUS_OPEN limit 1)
                                    FROM Program__c
                                   WHERE Program_Family__c =: CORE_Helper.doEscapeSingleQuotes(selectedprogramFamily)
                                     AND Status__c =: Program_Helper.STATUS_ACTIVE
                                     AND Program_Family__c not in : programFamilyNotToSearchDirectly
                                ORDER BY Name DESC]) {
            isNYSUN = program.Application_Type__c.contains('NY_Sun');
            for(Program_Version__c programVersion : program.Program_Versions__r) {
                programList.add(new SelectOption(programVersion.Id, program.Name));
                if(program.Application_Type__c == Program_Helper.APP_TYPE_NYSUN_COMMERCIAL) {
                    nysunCommertialProgramVersionId = programVersion.Id;
                }

                if(program.Application_Type__c == Program_Helper.APP_TYPE_NYSUN_RESIDENTIAL) {
                    nysunResidentialProgramVersionId = programVersion.Id;
                }

                if(program.Application_Type__c == Program_Helper.APP_TYPE_ZEV) {
                    zeroEmissionVehiclesProgramVersionId = programVersion.Id;
                }

                if(program.Application_Type__c == Program_Helper.APP_TYPE_CT) {
                    cleanTransportationProgramVersionId = programVersion.Id;
                }

                if(program.Application_Type__c == Program_Helper.APP_TYPE_SMALL_GSHP) {
                    GSHPSmallProgramVersionId = programVersion.Id;
                    isGSHP = true;
                }

                if(program.Application_Type__c == Program_Helper.APP_TYPE_LARGE_GSHP) {
                    GSHPLargeProgramVersionId = programVersion.Id;
                    isGSHP = true;
                }
            }
        }

        if(isNYSUN) {
            programList.add(new SelectOption('Both', 'Both'));
        }

        if(isGSHP) {
            programList.add(new SelectOption(Program_Helper.APP_TYPE_GSHP_ALL, Program_Helper.APP_TYPE_GSHP_ALL_VALUE));
        }

        if(programList.size() == 1){
            selectedProgram = programList.get(0).getValue();
        }

        if(programList.size() == 1 || isURLMod) {
            getRoles();
        }
    }


    /*
    * Method Name: getRoles
    * Description: Create the Program's Role List on Basis of selected Program
    * @return - Method does not return a value
    */
    public void getRoles() {
        String oldSelectedProgram  = '';
        serviceProviderLabel = '';
        systemProviderLabel = '';

        // retrun if user selected NY sun Commertial program
        if(selectedProgram == nysunCommertialProgramVersionId) {
            return;
        }

        //if contractor enroll for both NYSUN program
        if(selectedProgram == Program_Helper.APP_TYPE_NYSUN_BOTH) {
            oldSelectedProgram = selectedProgram;
            selectedProgram = programList.get(0).getValue();
        }

        //if contractor enroll for ALL GSHP system
        if(selectedProgram == Program_Helper.APP_TYPE_GSHP_ALL) {
            oldSelectedProgram = selectedProgram;
            selectedProgram = GSHPSmallProgramVersionId;
        }

        for(Program_Version__c programVer : [SELECT Contractor_Label__c, Subcontractor_Label__c
                                             FROM Program_Version__c WHERE Id =: CORE_Helper.doEscapeSingleQuotes(selectedProgram)]){
            serviceProviderLabel = programVer.Contractor_Label__c;
            systemProviderLabel = programVer.Subcontractor_Label__c;
        }

        if(isURLMod && oldSelectedProgram == Program_Helper.APP_TYPE_NYSUN_BOTH) {
            selectedProgram = 'Both';
        } else if(isURLMod && oldSelectedProgram == Program_Helper.APP_TYPE_GSHP_ALL) {
            selectedProgram = Program_Helper.APP_TYPE_GSHP_ALL;
        }
    }

    /*
    * Method Name: launchContractAppWizard
    * Description: Return the Pagereference to launch the application Wizard for Contractor Application
    * @return a Pagereference
    */
    public Pagereference launchContractAppWizard(){

        String appliedProgramRT;

        if(selectedprogramFamily == 'Renewable Heating and Cooling'){
            if(selectedProgram == GSHPSmallProgramVersionId || selectedProgram == GSHPLargeProgramVersionId || selectedProgram == Program_Helper.APP_TYPE_GSHP_ALL){
                appliedProgramRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', 'Ground_Source_Heat_Pump_Application').Id;
                if(selectedProgram == GSHPSmallProgramVersionId){
                    serviceRole = 'TRUE';
                    systemRole = 'TRUE';
                    isGSHPSmallApp = true;
                }
            }else{
                appliedProgramRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', 'Pellet_Stove_Application').Id;
            }
        }else if(selectedprogramFamily == 'NY-Sun'){
            appliedProgramRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', 'NY_Sun_Application').Id;
        }else if(selectedprogramFamily == 'Commercial'){
            appliedProgramRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', 'Real_Time_Energy_Management_Application').Id;
        }else if(selectedprogramFamily == 'Innovation'){
            appliedProgramRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', 'Innovation_Clean_Transportation_Application').Id;
        }else {
            for(SelectOption program : programList) {
                if(program.getValue() == selectedProgram) {
                    selectedProgramNameStr = program.getLabel();
                }
            }
            appliedProgramRT = Utility_RecordType_Helper.getRecordType('Contractor_Application__c', selectedProgramNameStr.replace(' ', '_') + '_Application').Id;
        }

        serviceProviderApp = new Contractor_Application__c(RecordTypeId = appliedProgramRT);

    //system.assert(false, serviceRole);
        if(serviceRole == 'TRUE' || selectedProgram == nysunCommertialProgramVersionId){
            serviceProviderApp.Contractor__c = true;
        }
        if(systemRole == 'TRUE' && selectedProgram != nysunCommertialProgramVersionId){
            serviceProviderApp.Builder__c = true;
        }
        if(drillerRole == 'TRUE'){
            serviceProviderApp.Driller__c = true;
        }

        if(String.isBlank(payeeType)){
            serviceProviderApp.Type__c = PRIMARY_CONTRACTOR;
        } else {
            serviceProviderApp.Type__c = payeeType;// #T-01286
        }

        insert serviceProviderApp;

        copyProgramTemplate(serviceProviderApp.Id, '');
        selectPrograms();
        copyProgramContents();

        Pagereference pg = new Pagereference('/apex/CORE_CONAPP_CompanyInformation_Page?ApplicationId=' + serviceProviderApp.Id);
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: copyProgramContents
    * Description: Copies Program Content Data to Application Content
    * @return a Pagereference
    */
    public Pagereference copyProgramContents() {
        if(selectedProgram == 'Both') {
            selectedProgram = programList.get(0).getValue();
        }

        if(selectedProgram == Program_Helper.APP_TYPE_GSHP_ALL) {
            selectedProgram = GSHPSmallProgramVersionId;
        }

        if(payeeType == 'payee') {
            CORE_CONAPP_Helper.createApplicationContentData(serviceProviderApp.Id, selectedProgram, true);
        } else {
            CORE_CONAPP_Helper.createApplicationContentData(serviceProviderApp.Id, selectedProgram, false);
        }

        return null;
    }

    /*
    * Method Name: selectPrograms
    * Description: Create a Application Content On the basis of selected Program
    * @return a Pagereference
    */
    public Pagereference selectPrograms(){
        try{
            List<Application_Content__c> appContentList = new List<Application_Content__c>();

            for(Application_Content__c appContent : [SELECT Id FROM Application_Content__c
                                                      WHERE Contractor_Application__c =: CORE_Helper.doEscapeSingleQuotes(serviceProviderApp.Id)
                                                        AND RecordType.DeveloperName = 'Applied_Program']){
                appContentList.add(appContent);
            }

            if(appContentList.size() > 0) {

                delete appContentList;

                appContentList = new List<Application_Content__c>();
            }

            String appliedProgramRT = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'Applied_Program').Id;

            if(selectedProgram == 'Both') {
                appContentList.add(new Application_Content__c(RecordTypeId = appliedProgramRT,
                                                              Program_Version__c = programList.get(0).getValue(),
                                                              Contractor_Application__c = serviceProviderApp.Id));
                appContentList.add(new Application_Content__c(RecordTypeId = appliedProgramRT,
                                                              Program_Version__c = programList.get(1).getValue(),
                                                              Contractor_Application__c = serviceProviderApp.Id));
            } else if(selectedProgram == Program_Helper.APP_TYPE_GSHP_ALL) {
                appContentList.add(new Application_Content__c(RecordTypeId = appliedProgramRT,
                                                              Program_Version__c = GSHPSmallProgramVersionId,
                                                              Contractor_Application__c = serviceProviderApp.Id));
                appContentList.add(new Application_Content__c(RecordTypeId = appliedProgramRT,
                                                              Program_Version__c = GSHPlargeProgramVersionId,
                                                              Contractor_Application__c = serviceProviderApp.Id));
            } else {
                appContentList.add(new Application_Content__c(RecordTypeId = appliedProgramRT,
                                                              Program_Version__c = selectedProgram,
                                                              Contractor_Application__c = serviceProviderApp.Id));
            }
            if(appContentList.size() > 0){
                insert appContentList;
            }
        }catch(DMLException e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
        }

        return null;
    }

    /*
    * Method Name: saveReferencesDetails
    * Description: Creates Application Content of type References and save Contractor Application.
    * @return Method does not return a value.
    */
    public void saveReferencesDetails(){
        String referenceRT = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'References').Id;

        for(Application_Content__c content : appContents){
            content.RecordTypeId = referenceRT;
            content.Type__c = NYSUN_Helper.RESIDENTIAL_REFERENCE_TYPE;
            content.Contractor_Application__c = serviceProviderApp.Id;
            content.Is_Greater_than_500_kW__c = false;
        }

        for(Application_Content__c content : appOptionBContents){
            content.RecordTypeId = referenceRT;
            content.Type__c = NYSUN_Helper.COMMERCIAL_REFERENCE_TYPE;
            content.Contractor_Application__c = serviceProviderApp.Id;
            content.Is_Greater_than_500_kW__c = true;
        }
        upsert appContents;

        if(serviceProviderApp.Reference_Type__c == REFERENCE_TYPE_COMPANY_REFERENCE) {
            upsert appOptionBContents;
        }
        upsert serviceProviderApp;
    }

    // added by Pankaj --> will be called on click on save button
    public Pagereference saveReferenceState(){
         try{

            strMessage = '';
            saveReferencesDetails();// method created by Pankaj having common code on save and next
            // rahuls91221: added to catch DML exception to display single error

            // rahuls91221 [24th July 2016 | I-01042]: Added confirmation message
            strMessage = System.Label.NYSUN_CONAPP_References_Page_SaveConfirmMessage;
        }catch(DMLException objEx){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, objEx.getDmlMessage(0)));
        }catch(Exception objEx){
            ApexPages.addMessages(objEx);
        }
        return null;
    }


    /*
    * Method Name: saveReferences
    * Description: save Contractor Application and will be called on click on next button
    * @return a Pagereference
    */
    public Pagereference saveReferences(){
        try{
            saveReferencesDetails();// method created by Pankaj having common code on save and next
            return next();
            // rahuls91221: added to catch DML exception to display single error
        }catch(DMLException objEx){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, objEx.getDmlMessage(0)));
            return null;
        }catch(Exception objEx){
            ApexPages.addMessages(objEx);
            return null;
        }
    }

    public Pagereference next(){
        return PageNavigationUtility.getNextPageURL(null, currentPage, serviceProviderApp.Id);
    }

    public Pagereference redirectToStart(){

        Pagereference pg = new Pagereference('/CORE_CONAPP_Program_Page');
        pg.setRedirect(true);

        return pg;
    }

    /*
    * Method Name: submitApplication
    * Description: submits Contractor Application
    * @return a Pagereference
    */
    public Pagereference submitApplication(){
        try{
            //---#T-01286
            if(serviceProviderApp.Type__c == 'Payee'){
                serviceProviderApp.Status__c = 'Pending Approval';
            }else if(currentPage != null) {
                serviceProviderApp.Status__c = 'Submitted';
            }
            update serviceProviderApp;

            if(currentPage == null) {
                return null;
            }

            return next();
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
            return null;
        }
    }


    public Pagereference saveApplication(){
        try{

            update serviceProviderApp;

            if(currentPage == null) {
                return null;
            }

            return next();
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
            return null;
        }
    }

    public Pagereference saveAndSignInfo(){

        saveCertificationInfo();

        return null;
    }

    /*
    * Method Name: saveCertificationInfo
    * Description: save certification Information.
    * @return a Pagereference
    */
    public Pagereference saveCertificationInfo(){
        try{
            update serviceProviderApp;

            String participantRT = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'Contractor_Participation_Document').Id;

            List<Application_Content__c> participantList = new List<Application_Content__c>();

            for(Application_Content__c appContent : [SELECT Id FROM Application_Content__c
                                                     WHERE Contractor_Application__c =: CORE_Helper.doEscapeSingleQuotes(serviceProviderApp.Id)
                                                     AND RecordType.DeveloperName = 'Contractor_Participation_Document']){

                participantList.add(appContent);
            }

            if(participantList.size() > 0){
                delete participantList;
                participantList = new List<Application_Content__c>();
            }

            if(selectedDocuments != null && selectedDocuments != ''){
                for(String selectedDoc : selectedDocuments.split(';')){
                    participantList.add(new Application_Content__c(RecordTypeId = participantRT,
                                                                   Document_Title__c = selectedDoc,
                                                                   Contractor_Application__c = serviceProviderApp.Id));
                }
            }

            if(participantList.size() > 0){
                insert participantList;
            }

            return next();
        }catch(DMLException e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));

            return null;
        }
    }


    public Pagereference save(){
        try{
            if(taxIdNumber != null)
                serviceProviderApp.Tax_Identification_Type__c = taxIdNumber;
            if(serviceProviderApp.Tax_Identification_Type__c == 'SSN') {
                serviceProviderApp.Employee_Identification_Number_EIN__c = null;
            }
            update serviceProviderApp;
            return next();
        }catch(DMLException e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));

            return null;
        }
    }

     /*
    * Method Name: submitQualifications
    * Description: Save Qualifications of Contractor Application Record
    * @return a Pagereference.
    */
    public PageReference submitQualifications()
    {
      if(serviceProviderApp != null && serviceProviderApp.Id != null)
      {
        try
        {
          update serviceProviderApp;
          return next();
        }
        catch(Exception e)
        {
          return null;
        }
      }
      return null;
    }

    /*
    * Method Name: submitContacts
    * Description: Creates Contacts for Contractor Application Record
    * @return a Pagereference.
    */
    public Pagereference submitContacts() {
        List<Application_Content__c> contactList = new List<Application_Content__c>();
        String contactRecordTypeId = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'Contacts').Id;

        primaryContact.Type__c = 'Primary Contact';
        primaryContact.Contractor_Application__c = serviceProviderApp.Id;
        primaryContact.RecordTypeId = contactRecordTypeId;
        contactList.add(primaryContact);

        if(serviceProviderApp.Signatory_Contacta_Same_as_Primary__c) {
            authorizedSignatoryContact.Customer_First_Name__c = primaryContact.Customer_First_Name__c;
            authorizedSignatoryContact.Customer_Last_Name__c = primaryContact.Customer_Last_Name__c;
            authorizedSignatoryContact.Title__c = primaryContact.Title__c;
            authorizedSignatoryContact.Email__c = primaryContact.Email__c;
            authorizedSignatoryContact.Extension__c = primaryContact.Extension__c;
            authorizedSignatoryContact.Phone_Number__c = primaryContact.Phone_Number__c;
        }
        authorizedSignatoryContact.Contractor_Application__c = serviceProviderApp.Id;
        authorizedSignatoryContact.Type__c = 'Authorized Signatory Contact';
        authorizedSignatoryContact.RecordTypeId = contactRecordTypeId;
        contactList.add(authorizedSignatoryContact);

        if(serviceProviderApp.Account_Receivable_Contact_as_Primary__c) {
            accountReceivableContact.Customer_First_Name__c = primaryContact.Customer_First_Name__c;
            accountReceivableContact.Customer_Last_Name__c = primaryContact.Customer_Last_Name__c;
            accountReceivableContact.Title__c = primaryContact.Title__c;
            accountReceivableContact.Email__c = primaryContact.Email__c;
            accountReceivableContact.Extension__c = primaryContact.Extension__c;
            accountReceivableContact.Phone_Number__c = primaryContact.Phone_Number__c;
        }
        accountReceivableContact.Contractor_Application__c = serviceProviderApp.Id;
        accountReceivableContact.Type__c = 'Account Receivable Contact';
        accountReceivableContact.RecordTypeId = contactRecordTypeId;
        contactList.add(accountReceivableContact);

        try{
            upsert contactList;

            // Populate Contractor Name
            serviceProviderApp.Contractor_Name__c = primaryContact.Customer_First_Name__c + ' ' + primaryContact.Customer_Last_Name__c;
            serviceProviderApp.Primary_Contact_Email__c = primaryContact.Email__c;
            update serviceProviderApp;

            return next();
        } catch(DMLException e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));

            return null;
        }
    }

    public Pagereference submitContractorDetails() {
        try{
            if(isInterestedInMenterProgram == 'No')
                serviceProviderApp.Mentorship__c = null;
            if(isFullStatus == 'Yes'){
                serviceProviderApp.Is_Full_Status__c = true;
            }else{
                serviceProviderApp.Is_Full_Status__c = false;
            }

            update serviceProviderApp;

            return next();
        } catch(DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
            return null;
        }
    }

    public Pagereference previous(){
        system.debug('-----'+currentPage);
        return PageNavigationUtility.getPreviousPageURL(null, currentPage, serviceProviderApp.Id);
    }

    /*
    * Method Name: copyProgramTemplate
    * Description: Copy Program Templates on basis of Program's Family.
    * @return Method does not return a value.
    */
    private void copyProgramTemplate(String applicationId, String applicationType) {

        String templateType;

        if(selectedprogramFamily == 'Renewable Heating and Cooling'){
            if(selectedProgram == GSHPSmallProgramVersionId){
                applicationType = 'GSHP_Small_System';
            }else if(selectedProgram == GSHPLargeProgramVersionId){
                applicationType = 'GSHP_Large_System';
            } else if(selectedProgram == Program_Helper.APP_TYPE_GSHP_ALL){
                applicationType = 'GSHP_Large_System';
            }else {
                applicationType = 'RHNY_Pellet_Stove';
            }
        }else if(selectedprogramFamily == 'NY-Sun'){
            if(selectedProgram == 'Both' || selectedProgram == nysunResidentialProgramVersionId){
                applicationType = 'NY_Sun_Residential';
            } else if(selectedProgram == nysunCommertialProgramVersionId){
                applicationType = 'NY_Sun_Commercial';
            }
        }else if(selectedprogramFamily == 'Commercial'){
            applicationType = 'Commercial_Real_Time_Energy_Management';
        }else if(selectedprogramFamily == 'Innovation') {
            if(selectedProgram == cleanTransportationProgramVersionId){
                applicationType = 'Clean_Transportation';
            } else if(selectedProgram == zeroEmissionVehiclesProgramVersionId){
                applicationType = 'Zero_Emission_Vehicles';
            }
        }else if(selectedprogramFamily == 'New Construction'){
            applicationType = 'New_Construction';
        } else {
            applicationType = selectedProgramNameStr.replace(' ', '_');
        }

        if(payeeType != null && payeeType == 'payee'){
            applicationType = 'NY_Sun_Commercial';
            templateType = 'Payee Application';
        } else {
            templateType = 'Contractor Application';
        }

        CORE_CONAPP_Helper.createWizardTemplateData(applicationId, applicationType, templateType);
    }

    @RemoteAction
    global static String getSiginingUrl(String appId, String domainURL,
                                        String pdfPageName, String retURLPageName){

        return CORE_CONAPP_Docusign_Service.getSiginingUrl(appId, domainURL, pdfPageName, retURLPageName);
    }

    @RemoteAction
    global static String getPayeeSiginingUrl(String appId, String domainURL,
                                             String pdfPageName, String retURLPageName){

        CORE_CONAPP_Docusign_Service.isPayee = true;

        return CORE_CONAPP_Docusign_Service.getSiginingUrl(appId, domainURL, pdfPageName, retURLPageName);
    }

    public List<String> listOfSelectedEntityType{
        get{
            listOfSelectedEntityType = new List<String>();
            if(String.isNotBlank(serviceProviderApp.Entity_Type__c)){
                for(String val : serviceProviderApp.Entity_Type__c.split(';')) {
                    listOfSelectedEntityType.add(val);
                }
            }
            return listOfSelectedEntityType;
        }

        set{
            serviceProviderApp.Entity_Type__c = '';
            for(String val : value){
                serviceProviderApp.Entity_Type__c += val + '; ';
            }
            serviceProviderApp.Entity_Type__c.removeEnd('; ');
        }
    }

      public List<String> listOfSelectedRegionalCounties{
        get{
            listOfSelectedRegionalCounties = new List<String>();
            if(String.isNotBlank(serviceProviderApp.Regional_Counties_Served__c)){
                for(String val : serviceProviderApp.Regional_Counties_Served__c.split(';')) {
                    listOfSelectedRegionalCounties.add(val);
                }
            }
            return listOfSelectedRegionalCounties;
        }

        set{
            serviceProviderApp.Regional_Counties_Served__c = '';
            for(String val : value){
                serviceProviderApp.Regional_Counties_Served__c += val + '; ';
            }
            serviceProviderApp.Regional_Counties_Served__c.removeEnd('; ');
        }
    }

    public List<String> listOfServicesProvidedInProjectWork{
            get{
                listOfServicesProvidedInProjectWork = new List<String>();
                if(String.isNotBlank(projectRefrenceApplicationConRec.Services_Provided__c)){
                    for(String val : projectRefrenceApplicationConRec.Services_Provided__c.split(';')) {
                        listOfServicesProvidedInProjectWork.add(val);
                    }
                }
                return listOfServicesProvidedInProjectWork;
            }
            set{
                projectRefrenceApplicationConRec.Services_Provided__c = '';
                for(String val : value){
                    projectRefrenceApplicationConRec.Services_Provided__c += val + '; ';
                }
                projectRefrenceApplicationConRec.Services_Provided__c.removeEnd('; ');
            }
        }
        
        public List<String> listOfSelectedCredentials{
        get{
            listOfSelectedCredentials = new List<String>();
            if(String.isNotBlank(serviceProviderApp.Staff_Possess_Credentials__c)){
                for(String val : serviceProviderApp.Staff_Possess_Credentials__c.split(';')) {
                    listOfSelectedCredentials.add(val);
                }
            }
            return listOfSelectedCredentials;
        }

        set{
            serviceProviderApp.Staff_Possess_Credentials__c = '';
            for(String val : value){
                serviceProviderApp.Staff_Possess_Credentials__c += val + '; ';
            }
            serviceProviderApp.Staff_Possess_Credentials__c.removeEnd('; ');
        }
    }

     public List<String> listOfSelectedServiceProviders{
        get{
            listOfSelectedServiceProviders = new List<String>();
            if(String.isNotBlank(serviceProviderApp.Services_Provided__c)){
                for(String val : serviceProviderApp.Services_Provided__c.split(';')) {
                    listOfSelectedServiceProviders.add(val);
                }
            }
            return listOfSelectedServiceProviders;
        }

        set{
            serviceProviderApp.Staff_Possess_Credentials__c = '';
            serviceProviderApp.Services_Provided__c = '';
            for(String val : value){
                serviceProviderApp.Services_Provided__c += val + '; ';
            }
            serviceProviderApp.Services_Provided__c.removeEnd('; ');
        }
    }

    public List<SelectOption> getEntityTypeOptions(){
        List<SelectOption> returnOptionLst = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDsc = Contractor_Application__c.Entity_Type__c.getDescribe();
        List<Schema.PickListEntry> fieldDscPickVal = fieldDsc.getPickListValues();
        // returnOptionLst.add(new SelectOption('','None'));
        for(Schema.PickListEntry obj:fieldDscPickVal){
            returnOptionLst.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return returnOptionLst;
    }


  public List<SelectOption> getstaffPossessCredientials(){
        List<SelectOption> returnOptionLst1 = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDsc = Contractor_Application__c.Staff_Possess_Credentials__c.getDescribe();
        List<Schema.PickListEntry> fieldDscPickVal = fieldDsc.getPickListValues();
        // returnOptionLst.add(new SelectOption('','None'));
        for(Schema.PickListEntry obj:fieldDscPickVal){
            returnOptionLst1.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return returnOptionLst1;
    }
    
    public List<SelectOption> getservicesProvidedInProjectWork(){
        List<SelectOption> returnOptionLst1 = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDsc = Application_Content__c.Services_Provided__c.getDescribe();
        List<Schema.PickListEntry> fieldDscPickVal = fieldDsc.getPickListValues();
        // returnOptionLst.add(new SelectOption('','None'));
        for(Schema.PickListEntry obj:fieldDscPickVal){
            returnOptionLst1.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return returnOptionLst1;
    }

    public List<SelectOption> getserviceProvided(){
        List<SelectOption> returnOptionLst1 = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDsc = Contractor_Application__c.Services_Provided__c.getDescribe();
        List<Schema.PickListEntry> fieldDscPickVal = fieldDsc.getPickListValues();
        // returnOptionLst.add(new SelectOption('','None'));
        for(Schema.PickListEntry obj:fieldDscPickVal){
            returnOptionLst1.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return returnOptionLst1;
    }


    public List<SelectOption> getregionalCountiesServed(){
        List<SelectOption> returnOptionLst1 = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDsc = Contractor_Application__c.Regional_Counties_Served__c.getDescribe();
        List<Schema.PickListEntry> fieldDscPickVal = fieldDsc.getPickListValues();
        // returnOptionLst.add(new SelectOption('','None'));
        for(Schema.PickListEntry obj:fieldDscPickVal){
            returnOptionLst1.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return returnOptionLst1;
    }

    public List<String> listOfVehicleBrand{
        get{
            listOfVehicleBrand = new List<String>();
            if(String.isNotBlank(serviceProviderApp.Vehicle_Brand__c)){
                for(String val : serviceProviderApp.Vehicle_Brand__c.split(';')) {
                    listOfVehicleBrand.add(val);
                }
            }
            return listOfVehicleBrand;
        }

        set{
            serviceProviderApp.Vehicle_Brand__c = '';
            for(String val : value){
                serviceProviderApp.Vehicle_Brand__c += val + '; ';
            }
            serviceProviderApp.Vehicle_Brand__c.removeEnd('; ');
        }
    }

    public List<SelectOption> getVehicleBrandOptions(){
        List<SelectOption> returnOptionLst = new List<SelectOption>();
        Schema.DescribeFieldResult fieldDsc = Contractor_Application__c.Vehicle_Brand__c.getDescribe();
        List<Schema.PickListEntry> fieldDscPickVal = fieldDsc.getPickListValues();
        for(Schema.PickListEntry obj:fieldDscPickVal){
            returnOptionLst.add(new SelectOption(obj.getLabel(),obj.getValue()));
        }
        return returnOptionLst;
    }

    @RemoteAction
    global static String getSignedDocument(String applicationId){

        String attachmentId;

        for(Project_Document__c proDocument : [SELECT (SELECT Id FROM Attachments
                                               ORDER BY CreatedDate DESC limit 1)
                                               FROM Project_Document__c WHERE Contractor_Application__c =: CORE_Helper.doEscapeSingleQuotes(applicationId)
                                               AND Application_Content__r.Type__c =: CORE_Helper.TYPE_CON_APP
                                               AND Application_Content__r.Sub_Type__c =: CORE_Helper.SUB_TYPE_CON_APP]){

            for(Attachment attach : proDocument.Attachments){

                attachmentId = attach.Id;
            }
        }

        return attachmentId;
    }
     

    public void getProjectContents() {
        applicationContent = RTEM_CONAPP_References_Service.getApplicationContentList(applicationId);
        appContentNameToAttachmentRecMap = RTEM_CONAPP_References_Service.getAttachmentList(applicationContent);

        appContentNameToNewAttachMap = new Map<String, Attachment>();
        appContentNameToAppContentRecMap = new Map<String, Application_Content__c>();
        for(Application_Content__c appContentRec : applicationContent) {
            appContentNameToNewAttachMap.put(appContentRec.Document_Title__c, new Attachment());
            appContentNameToAppContentRecMap.put(appContentRec.Document_Title__c, appContentRec);
        }

    }

    public Pagereference savedocs(){ 
        hasError = false; 
        try{
            //RTEM_CONAPP_References_Service.saveDocuments(appContentNameToNewAttachMap, applicationContent, applicationId);
            getProjectContents();
        } catch (DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
            return null;
        }
        return null;

    }

    public Pagereference saveAndNext() {
        savedocs();
        hasError = false;
        for(Application_Content__c projContentRec : applicationContent) {
            if(projContentRec.Mandatory_by_default__c && projContentRec.Project_Documents__r != null && (projContentRec.Project_Documents__r.size() == 0)) {
                hasError = true;
            }
        }

        if(hasError) {
            return null;
        } else {
            currentPage = 'RTEM_CONAPP_References_Page';
            return next();
        }
    }

    public Pagereference saveAndNextZEV() {
        savedocs();
        hasError = false;
        for(Application_Content__c projContentRec : applicationContent) {
            if(projContentRec.Mandatory_by_default__c && projContentRec.Project_Documents__r != null && (projContentRec.Project_Documents__r.size() == 0)) {
                hasError = true;
            }
        }

        if(hasError) {
            return null;
        } else {
        //As part of issue I-01363 commenting below statement Gaurav Sinha 8 August
        //  currentPage = 'RTEM_CONAPP_References_Page';
            currentPage = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
            return next();
        }
    }

    public void getAttachmentHistory() {
        attachmentHistory = RTEM_CONAPP_References_Service.getAttachmentHistory(applicationContentId);
    }

    /*
    * Method Name: getNYSUNProjectContentList
    * Description: fetch Project Content List specific for NYSUN
    * @return Method does not return a value.
    */ 
    public void getNYSUNProjectContentList() {
        nysunApplicationContents = NYSUN_CONAPP_PaperWorkRecord_Service.getApplicationContentList(serviceProviderApp.Id);
        nysunAppContentNameToAttachmentRecMap = NYSUN_CONAPP_PaperWorkRecord_Service.getAttachmentList(nysunApplicationContents);

        nysunAppContentNameToNewAttachMap = new Map<String, Attachment>();

        for(Application_Content__c appContentRec : nysunApplicationContents) {

            nysunAppContentNameToNewAttachMap.put(appContentRec.Id, new Attachment());
        }

        getDocApprovalStatus(nysunApplicationContents);

        // Get Other Document List
        List<Application_Content__c> otherAppContentList = NYSUN_CONAPP_PaperWorkRecord_Service.getOtherApplicationContentList(serviceProviderApp.Id);
        Map<String, Attachment> otherAppContentIdToAttachmentRecMap = NYSUN_CONAPP_PaperWorkRecord_Service.getAttachmentList(otherAppContentList);
        Map<String, String> otherDocIdToStatusMap = NYSUN_CONAPP_PaperWorkRecord_Service.getDocApprovalStatus(otherAppContentList);

        otherDocumentList = new List<OtherDocument>();
        for(Application_Content__c appContent : otherAppContentList) {
            OtherDocument otherDoc = new OtherDocument(appContent.Id, appContent.Document_Title__c,
                                                       new Attachment(),
                                                       otherAppContentIdToAttachmentRecMap.get(appContent.Id),
                                                       otherDocIdToStatusMap.get(appContent.Id), appContent.Configured_From_Solicitation__c);
            otherDocumentList.add(otherDoc);
        }  

        addDocumentInOtherDocumentList();

        try {
            appContentIdToConditionallyRequiredMap = NYSUN_CONAPP_PaperWorkRecord_Service.checkForConditionallyRequired(nysunApplicationContents);
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }

    //task #T-01286
    @RemoteAction
    global static Boolean saveSignedDocument(String signedDate,String envelopeId, String isSigned,String serviceProviderAppId ){
        if(CORE_CONAPP_Docusign_Service.isAsyncCall  == false && (signedDate == null || String.isBlank(signedDate)) && envelopeId != null && isSigned == 'signing_complete'){
            CORE_CONAPP_Docusign_Service.isAsyncCall = true;
            CORE_CONAPP_Docusign_Service.attachSignedDocument(serviceProviderAppId);

        }
        return true;
    }


    /*
    * Method Name: getNYSUNPayeeProjectContentList
    * Description: Get project content list for payee type application #T-01229
    * @return Method does not return a value.
    */
    public void getNYSUNPayeeProjectContentList() {


        nysunApplicationContents = NYSUN_CONAPP_PaperWorkRecord_Service.getSignedApplicationContentList(serviceProviderApp.Id);
        nysunAppContentNameToAttachmentRecMap = NYSUN_CONAPP_PaperWorkRecord_Service.getAttachmentList(nysunApplicationContents);

        nysunAppContentNameToNewAttachMap = new Map<String, Attachment>();
 
        for(Application_Content__c appContentRec : nysunApplicationContents) {

            nysunAppContentNameToNewAttachMap.put(appContentRec.Id, new Attachment());
        }

        getDocApprovalStatus(nysunApplicationContents);
 
    }

    public PageReference addDocumentInOtherDocumentList() {
        for(Integer i=0; i<10; i++){
            otherDocumentList.add(new OtherDocument(null, '', new Attachment(), new Attachment(), '', null));
        }
        return null;
    }

    public PageReference removeDocumentFromList() {
        OtherDocument otherDoc = otherDocumentList.get(rowNumber);
        if(otherDoc.documentId != null) {
            otherDocumentList.remove(rowNumber);
            Application_Content__c appContent = new Application_Content__c(Id = otherDoc.documentId);
            delete appContent;
        }

        return null;
    }

    public PageReference saveOtherDocumentsBeforeAddMore() {
        NYSUN_CONAPP_PaperWorkRecord_Service.saveOtherDocuments(otherDocumentList, serviceProviderApp.Id);
        getNYSUNProjectContentList();

        PageReference ReturnPage = new PageReference('/apex/NYSUN_CONAPP_Documents_Page?ApplicationId=' + serviceProviderApp.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }


    /*
  * Method Name: resetPriorProject
  * Description: Reset Refrence Application Content
  * @param:  null
  * @return: void
  */
    public void resetPriorProject() {
        String refrenceRecTypeId = Utility_RecordType_Helper.getRecordType('Application_Content__c', 'Work_Experience').Id;
        if(String.isBlank(selectedProjectRefrenceAppContentId)) {
            projectRefrenceApplicationConRec = new Application_Content__c();
            projectRefrenceApplicationConRec.Contractor_Application__c =  serviceProviderApp.Id;
          projectRefrenceApplicationConRec.RecordTypeId = refrenceRecTypeId;
        } else {
          projectRefrenceApplicationConRec = [Select Project_Name__c, Dwelling_Units__c, Sq_Footage__c, Modeling_Software_Used__c, Name_of_personnel_who_worked_on_project__c,
                              Completed_Year__c, Building_Type__c, Services_Provided__c, Certification_Verification__c, Contractor_Application__c from Application_Content__c
                              where Id =: selectedProjectRefrenceAppContentId];
        }
    }

  /*
  * Method Name: deleteProjectWork
  * Description: Delete Refrence Application Content
  * @param:  null
  * @return: PageReference
  */
    public PageReference deleteProjectWork() {
        if(String.isNotBlank(selectedProjectRefrenceAppContentId)) {
            delete new Application_Content__c(Id = selectedProjectRefrenceAppContentId);
        }
        return getPageURLByPageName('NC_CONAPP_ProjectWork_Page', serviceProviderApp.Id);
    }

   /*
  * Method Name: saveProjectRefrenceAppContent
  * Description: Method to save Project Refrence Application Content
  * @param:  null
  * @return: PageReference
  */
    public PageReference saveProjectRefrenceAppContent() {
        upsert projectRefrenceApplicationConRec;
        return getPageURLByPageName('NC_CONAPP_ProjectWork_Page', serviceProviderApp.Id);
    }

    /*
  * Method Name: getPageURLByPageName
  * Description: Method to get PageReference URL by page name
  * @param:  String pageName - Page Name
  *      String serviceProviderAppId - serviceProviderApp Id
  * @return: PageReference
  */
    private PageReference getPageURLByPageName(String pageName, String serviceProviderAppId) {
      PageReference ReturnPage = new PageReference('/apex/' + pageName + '?ApplicationId=' + serviceProviderAppId);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    public PageReference saveApplicationContentList() {
        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        saveOtherDocuments();

        getNYSUNProjectContentList();
        PageReference ReturnPage = new PageReference('/apex/NYSUN_CONAPP_Documents_Page?ApplicationId=' + serviceProviderApp.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    /*
    * Method Name: saveCoreApplicationContentList
    * Description: Save document on click on save.
    * @return a PageReference.
    */
    public PageReference saveCoreApplicationContentList() {
        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        saveOtherDocuments();

        getNYSUNProjectContentList();
        PageReference ReturnPage = new PageReference('/apex/CORE_CONAPP_Documents_Page?ApplicationId=' + serviceProviderApp.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    /*
    * Method Name: saveGSHPApplicationContentList
    * Description: Save document on click on save specific for GSHP Program
    * @return a PageReference.
    */
    //@GSHP
    public PageReference saveGSHPApplicationContentList() {
        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        saveOtherDocuments(); 

        getNYSUNProjectContentList();
        PageReference ReturnPage = new PageReference('/apex/GSHP_CONAPP_Documents_Page?ApplicationId=' + serviceProviderApp.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    /*
    * Method Name: saveNCApplicationContentList
    * Description: Save document on click on save specific for New Construction Program
    * @return a PageReference.
    */
    //@NC
    public PageReference saveNCApplicationContentList() {
        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        saveOtherDocuments();

        getNYSUNProjectContentList();
        PageReference ReturnPage = new PageReference('/apex/NC_CONAPP_Documents_Page?ApplicationId=' + serviceProviderApp.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    /*
    * Method Name: savePayeeApplicationContentList
    * Description: Save document on click on save project content list for payee type application #T-01229
    * @return a PageReference.
    */
    public PageReference savePayeeApplicationContentList() {
        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        PageReference ReturnPage = new PageReference('/apex/NYSUN_CONAPP_PAYEE_Documents_Page?ApplicationId=' + serviceProviderApp.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

 
    /*
    * Method Name: saveOtherDocuments
    * Description: Save document on click on save
    * @return a PageReference.
    */
    public PageReference saveOtherDocuments() {
        NYSUN_CONAPP_PaperWorkRecord_Service.saveOtherDocuments(otherDocumentList, serviceProviderApp.Id);
        return null;
    }

    public void getDocApprovalStatus(List<Application_Content__c> appContentList) {
        appContentNameToDocStatusMap = NYSUN_CONAPP_PaperWorkRecord_Service.getDocApprovalStatus(appContentList);
    }

    public Pagereference validateAndNext() {

        hasError = false;

        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        saveOtherDocuments();

        getNYSUNProjectContentList();

        for(Application_Content__c appContentRec : nysunApplicationContents) {
            if((appContentRec.Mandatory_by_default__c &&
                appContentIdToConditionallyRequiredMap != null ||
                (appContentIdToConditionallyRequiredMap.containsKey(appContentRec.Id) && appContentIdToConditionallyRequiredMap.get(appContentRec.Id)))
               && (appContentRec.Project_Documents__r.size() == 0)) {
                   hasError = true;
               }
        }
        PageReference returnPage;

        if(hasError) {
            return null;
        } else {
            currentPage = 'NYSUN_CONAPP_Documents_Page';
            return next();
        }
    }


    public Pagereference coreValidateAndNext() {

        hasError = false;

        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        saveOtherDocuments();

        getNYSUNProjectContentList(); 

        for(Application_Content__c appContentRec : nysunApplicationContents) {
            if((appContentRec.Mandatory_by_default__c &&
                appContentIdToConditionallyRequiredMap != null ||
                (appContentIdToConditionallyRequiredMap.containsKey(appContentRec.Id) && appContentIdToConditionallyRequiredMap.get(appContentRec.Id)))
               && (appContentRec.Project_Documents__r.size() == 0)) {
                   hasError = true;
               }
        } 
        PageReference returnPage;

        if(hasError) {
            return null;
        } else{
            currentPage = 'GSHP_CONAPP_Documents_Page';
            return next();
        }
    }

    /*
    * Method Name: validatePayeeDocumentAndNext
    * Description: Validate and Save document on click on continue button for payee type application #T-01229
    * @return a Pagereference
    */
    public Pagereference validatePayeeDocumentAndNext() {
        hasError = false;

        NYSUN_CONAPP_PaperWorkRecord_Service.saveDocuments(nysunAppContentNameToNewAttachMap, nysunApplicationContents, serviceProviderApp.Id);

        getNYSUNPayeeProjectContentList();

        for(Application_Content__c appContentRec : nysunApplicationContents) {
            if((appContentRec.Mandatory_by_default__c &&  (appContentRec.Project_Documents__r.size() == 0))) {
                   hasError = true;
               }
        }
        PageReference returnPage;

        if(hasError) {
            return null;
        } else {
            currentPage = 'NYSUN_CONAPP_PAYEE_Documents_Page';
            return next();
        }
    }

    public class OtherDocument {

        public String documentId {get; set;}
        public String documentName {get; set;}
        public Attachment attach {get; set;}
        public Attachment recentAttach {get; set;}
        public String status {get; set;}
        public Boolean isConfiguredFromSolicitation {get; set;}

        public OtherDocument(String docId, String docName, Attachment attachRec, Attachment recentAttachRec, String docStatus, Boolean configuredFromSolicitation) {
            documentId = docId;
            documentName = docName;
            attach = attachRec;
            recentAttach = recentAttachRec;
            status = docStatus;
            isConfiguredFromSolicitation = configuredFromSolicitation == null ? false : configuredFromSolicitation;
        }

        public OtherDocument(String docId, String docName, Attachment attachRec, Attachment recentAttachRec, String docStatus) {
            documentId = docId;
            documentName = docName;
            attach = attachRec;
            recentAttach = recentAttachRec;
            status = docStatus;
            this.isConfiguredFromSolicitation = false;
        }

    }
}