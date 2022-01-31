public without sharing class EEC_TransactionWizardController implements EEC_AssistantInterface, EEC_VarianceInterface, EEC_ContactRoleInterface {
    private static final Integer SAVE_AND_NEXT = 1;
    private static final Integer SAVE_AND_PREVIOUS = 2;
    private static final Integer SAVE_AND_RETURN = 3;
    private static final Integer MODE_REVIEW = 4;
    private static final Integer SAVE_AND_RETURN_TO_SAME_PAGE = 5;
    // AWS Variables
    private AWSKeys credentials                                         { get; set; }
    private String AWSCredentialName = 'eec';
    public String accessKey                                             { get; set; }
    public String bucketItemAccess                                      { get; set; }
    public String bucketName                                            { get; set; }
    public String portalUrl                                             { get; set; }
    public boolean hasFCCCapacityIncreased                              { get; set; }
    public String buttonLabel                                           { get; set; }
    public List<Transaction_Contact__c> transactionContactList          { get; set; }
    public Account provider                                             { get; set; }
    public LEAD_Configuration__c leadConfiguration                      { get; set; }
    public String licenseInstructionMessage                             { get; set; }
    public Licensing_Transaction__c licenseTransation                   { get; set; }
    public String licenseRecordTypeName                                 { get; set; }
    public String licenseRecordTypeLabel                                { get; set; }
    public String formattedLicenseRecordTypeLabel                       { get; set; }
    public List<Household_Member__c> ihmList                            { get; set; }
    public List<Employment_History__c> ehList                           { get; set; }
    public List<Room__c> roomList                                       { get; set; }
    public List<ContactRoleWrapperclass> contactRoleList                { get; set; }
    public List<ContactRoleWrapperclass> contactAdminRoleList           { get; set; }
    public List<ContactRoleWrapperclass> contactReviewerList            { get; set; }
    public List<Contact_Role__c> removeRoleList                         { get; set; }
    public list<Variance_on_Regulation__c> varianceList                 { get; set; }
    public list<Variance_on_Regulation__c> listofVariance               { get; set; }
    public ContactRoleWrapperclass adminHead                            { get; set; }
    public ContactRoleWrapperclass existingDirector                     { get; set; }
    public ContactRoleWrapperclass existingBoardChair                   { get; set; }
    public ContactRoleWrapperclass boardchair                           { get; set; }
    public ContactRoleWrapperclass pboardchair                          { get; set; }
    public ContactRoleWrapperclass designateboard                       { get; set; }
    public ContactRoleWrapperclass administrativehead                   { get; set; }
    public ContactRoleWrapperclass ownerContactRole                     { get; set; }
    public List<Training_Experience__c> teList                          { get; set; }
    public Integer rowNum                                               { get; set; }
    public boolean isSaveOnly                                           { get; set; }
    public Contact cntct                                                { get; set; }
    public List<String> selectedHestElems                               { get; set; }
    public String selectedHestStr                                       { get; set; }
    public String selectedWaterStr                                      { get; set; }
    public String providerRecordType                                    { get; set; }
    public String saveAndReturnLabel                                    { get; set; }
    public String submissionDisclaimer                                  { get; set; }
    public String licensingTransactionSubmissionDisclaimer              { get; set; }
    public String licensingTrainingInstructions                         { get; set; }
    public List<String> gsaRecordTypeMap                                { get; set; }
    Public List<String> cbcRecordTypeMap                                { get; set; }
    Public List<String> privateSchoolRecordTypeMap                      { get; set; }
    Public List<String> publicSchoolRecordTypeMap                       { get; set; }
    Public List<String> otherEligibleProvidersRecordTypeMap             { get; set; }
    Public List<String> summerCampRecordTypeMap                         { get; set; }
    Public List<String> informalCareRecordTypeMap                       { get; set; }
    public List<Additional_Information__c> licensesheld                 { get; set; }
    public List<Additional_Information__c> licensesinprogress           { get; set; }
    public List<Additional_Information__c> criminalaction               { get; set; }
    public List<Additional_Information__c> investigation                { get; set; }
    public String programLicensedAgency                                 { get; set; }
    public String physicalRestraint                                     { get; set; }
    // public String extendedDays { get; set; }
    public String programContacted                                      { get; set; }
    public string selectedContact                                       { get; set; }
    public string selectedBoardContact                                  { get; set; }
    public string sumOfCapacities                                       { get; set; }
    public string selectedUmbrellaId                                    { get; set; }
    public Account umbrella                                             { get; set; }
    public Boolean referralAgency                                       { get; set; }
    public Boolean interCountries                                       { get; set; }
    public Boolean otherCount                                           { get; set; }
    public Boolean dcfSpecial                                           { get; set; }
    public Boolean characterRadio                                       { get; set; }
    //public string designatedboardchecked { get; set; }
    // public string DropinService { get; set; }
    //public string EveningsService { get; set; }
    //public string SummerCampService { get; set; }
    //public string CafeteriaUsed { get; set; }
    //public string GymFacility { get; set; }
    public string Constructedpost                                        { get; set; }
    public string DetailedInspection                                     { get; set; }
    // public string Poolavailable { get; set; }
    //public string Offsiteoutdoor { get; set; }
    //public string Transportationprovided { get; set; }
    // public string PortalAccess { get; set; }
    public string designatedboardcheckedrp                                  { get; set; }
    public string physicalrestraints                                        { get; set; }
    public string GroupType                                                 { get; set; }
    public String smallGroup                                                { get; set; }
    public String largeGroup                                                { get; set; }
    public String programcontracted                                         { get; set; }
    // public String ExistingFiduciary { get; set; }
    public string previousStreet1                                           { get; set; }
    public string previousStreet2                                           { get; set; }
    public string previousCity                                              { get; set; }
    public string previousState                                                 { get; set; }
    public string previousZipCode                                           { get; set; }
    public string selectedOwnerShip                                         { get; set; }
    //VariancesList
    public List<EEC_VarianceListCtrl.VarianceInfoWrap> varianceInfoWrappers { get; set; }
    //Placement Agency page
    public List<Additional_Information__c> heldLicense                      { get; set; }
    public Additional_Information__c oldHeldLicense;
    public Transaction_Contact__c transactionContact                        { get; set; }
    public Additional_Information__c oldCriminalAct;
    public Additional_Information__c oldFedralAct;
    public Additional_Information__c oldRelatedAct;
    public List<Licensing_Transaction__c> nonCancelledTransaction;
    public List<Additional_Information__c> relatedLicense                   { get; set; }
    public List<Additional_Information__c> criminalAct                      { get; set; }
    public List<Additional_Information__c> federalInv                       { get; set; }
    public Boolean minMaxAgeError { get; set; } //As there is calculation involving several fields, it was hard to implement on the front end. Qamar
    //public Boolean provideExtendedDaysError { get; set; } //pasrley validation does not work as expected for radio boxes. Qamar
    //public Boolean provideExtendedDaysError2 { get; set; }
    public Boolean IsAssistantUpgradeToCertified { get; set; }
    // public Boolean provideHalfADayError { get; set; }
    public Boolean isSubmitted { get; set; }
    //public Boolean saveCheckFlag { get; set; }
   
    Map<String, String> recordTypeMap = new Map<String, String>{
            EEC_Constants.LT_APP_NEW_APPLICATION => EEC_Constants.LT_FCC_NEW_LICENSE,
            EEC_Constants.LT_APP_APPLY_FOR_RENEWAL => EEC_Constants.LT_FCC_RENEWAL,
            EEC_Constants.LT_APP_APPLY_FOR_UPGRADE => EEC_Constants.LT_FCC_LICENSE_UPGRADE,
            EEC_Constants.LT_APP_APPLY_FOR_CHANGE_OF_ADDRESS => EEC_Constants.LT_CHANGE_OF_ADDRESS,
            EEC_Constants.LT_APP_APPLY_FOR_CHANGE_OF_PROVIDER_NAME => EEC_Constants.LT_FCC_CHANGE_OF_NAME,
            EEC_Constants.LT_APP_APPLY_FOR_RENEWAL_AS_ASSISTANT => EEC_Constants.LT_FCC_ASSISTANT_RENEWAL,
            EEC_Constants.LT_APP_CHANGE_OF_LICENSED_ROOM => EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL,
            EEC_Constants.LT_APP_CHANGE_OF_HOUSEHOLD_MEMBER_INDIVISUALS_REGULARLY => EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD,
            EEC_Constants.LT_APP_REQUEST_RE_ISSUANCE_OF_LICENSE => EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT,
            EEC_Constants.LT_APP_RE_ACTIVATE_LICENSE_CERTIFICATE => EEC_Constants.LT_FCC_RE_ACTIVE,
            EEC_Constants.LT_APP_INACTIVE_LICENSE_CERTIFICATE => EEC_Constants.LT_FCC_INACTIVATE,
            EEC_Constants.LT_APP_INTEND_TO_CLOSE_PROGRAM => EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION,
            EEC_Constants.LT_APP_FCC_DOWNGRADE_CAPACITY => EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY,
            EEC_Constants.LT_APP_REQUEST_VARIANCE_ON_REGULATIONS => EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST,
            EEC_Constants.LT_APP_BACKGROUND_RECORD_CHECK => EEC_Constants.LT_BACKGROUND_RECORD_CHECK,
            EEC_Constants.LT_APP_EEC_FCC_MODIFICATION => EEC_Constants.LT_EEC_FCC_MODIFICATION
    };
    Map<String, String> gsaRecordType = new Map<String, String>{
            EEC_Constants.LT_APP_NEW_APPLICATION => EEC_Constants.LT_GSA_NEW_LICENSE + ','+ EEC_Constants.LT_PLACEMENT_NEW_LICENSE + ','+ EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE,
            EEC_Constants.LT_APP_APPLY_FOR_RENEWAL => EEC_Constants.LT_GSA_RENEWAL + ','+ EEC_Constants.LT_PLACEMENT_RENEWAL + ','+ EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL,
            EEC_Constants.LT_APP_APPLY_FOR_LICENSE_CHANGE => EEC_Constants.LT_GSA_LICENSE_CHANGE + ','+ EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE + ','+ EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE,
            EEC_Constants.LT_APP_APPLY_FOR_MOVE => EEC_Constants.LT_GSA_MOVE + ','+ EEC_Constants.LT_PLACEMENT_MOVE + ','+  EEC_Constants.LT_RESIDENTIAL_MOVE,
            EEC_Constants.LT_APP_APPLY_FOR_TEMPORARY_MOVE => EEC_Constants.LT_GSA_TEMPORARY_MOVE,
            EEC_Constants.LT_APP_REPORT_CHANGE_IN_PROVIDER_NAME => EEC_Constants.LT_CHANGE_OF_PROVIDER_NAME,
            EEC_Constants.LT_APP_DESIGNATION_OF_ADMINISTRATIVE_AUTHORITY => EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY,
            EEC_Constants.LT_APP_REPORT_CHANGE_IN_OWNERSHIP_ADMINISTRATIVE_DESIGNEE => EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY,
            EEC_Constants.LT_APP_REQUEST_RE_ISSUANCE_OF_LICENSE => EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT,
            EEC_Constants.LT_APP_INTEND_TO_CLOSE_PROGRAM => EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION,
            EEC_Constants.LT_APP_REQUEST_VARIANCE_ON_REGULATIONS => EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST,
            EEC_Constants.LT_APP_BACKGROUND_RECORD_CHECK => EEC_Constants.LT_BACKGROUND_RECORD_CHECK,
            EEC_Constants.LT_APP_EEC_GSA_MODIFICATION => EEC_Constants.LT_EEC_GSA_MODIFICATION,
            EEC_Constants.LT_APP_EEC_RP_MODIFICATION => EEC_Constants.LT_EEC_RP_MODIFICATION,
            EEC_Constants.LABEL_LT_APP_EEC_LICENSEE_MANAGEMENT => EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME
            //EEC_Constants.LT_APP_CONTACT_MANAGEMENT => EEC_Constants.LT_CONTACT_MANAGEMENT
    };
    Map<String, String> cbcRecordType = new Map<String, String>{
            EEC_Constants.LT_APP_CBC_NEW_FUNDING_APPLICATION => EEC_Constants.LT_CBC_NEW_LICENSE_APPLICATION
    };
    Map<String, String> privateSchoolRecordType = new Map<String, String>{
            EEC_Constants.LABEL_LT_PRIVATE_SCHOOL_NEW_FUNDING_APPLICATION => EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION,
            EEC_Constants.LABEL_LT_CLOSED_FUNDED_PROGRAM => EEC_Constants.LT_CLOSE_FUNDED_API_NAME
    };
    Map<String, String> publicSchoolRecordType = new Map<String, String>{
            EEC_Constants.LABEL_LT_PUBLIC_SCHOOL_NEW_FUNDING_APPLICATION => EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION,
            EEC_Constants.LABEL_LT_CLOSED_FUNDED_PROGRAM => EEC_Constants.LT_CLOSE_FUNDED_API_NAME
    };
    Map<String, String> otherEligibleProvidersRecordType = new Map<String, String>{
            EEC_Constants.LABEL_LT_OTHER_ELIGIBLE_PROVIDERS_NEW_FUNDING_APPLICATION => EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION,
            EEC_Constants.LABEL_LT_CLOSED_FUNDED_PROGRAM => EEC_Constants.LT_CLOSE_FUNDED_API_NAME
    };
/*
    Map<String, String> summerCampRecordType = new Map<String, String>{
            EEC_Constants.LT_APP_SUMMER_CAMP_NEW_FUNDING_APPLICATION => EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION
    };
*/
    /*Map<String, String> informalCareRecordType = new Map<String, String>{
        EEC_Constants.LT_APP_INFORMAL_CAMP_NEW_FUNDING_APPLICATION => EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION,
        EEC_Constants.LABEL_LT_CLOSED_INFORMAL_CHILD_CARE_PROGRAM => EEC_Constants.LT_CLOSE_INFORMAL_CHILD_CARE_API_NAME
    }; */ 
    Map<String, String> assistantRecordTypeMap = new Map<String, String>{
            EEC_Constants.LT_APP_APPLY_TO_UPGRADE_DOWNGRADE_CAPACITY => EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE,
            EEC_Constants.LT_APP_APPLY_TO_BECOME_CERTIFIED_ASSISTANT => EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT,
            EEC_Constants.LT_APP_NEW_APPLICATION => EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE,
            EEC_Constants.LT_APP_APPLY_FOR_RENEWAL => EEC_Constants.LT_FCC_ASSISTANT_RENEWAL,
            EEC_Constants.LT_APP_APPLY_TO_CHANGE_IN_ASSISTANT_NAME => EEC_Constants.LT_FCC_CHANGE_OF_NAME,
            EEC_Constants.LT_APP_APPLY_TO_BE_LICENSED_FCC_PROVIDER => EEC_Constants.LT_FCC_NEW_LICENSE,
            EEC_Constants.LT_APP_REQUEST_RE_ISSUANCE_OF_LICENSE => EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT,
            EEC_Constants.LT_APP_RE_ACTIVATE_LICENSE_CERTIFICATE => EEC_Constants.LT_FCC_RE_ACTIVE,
            EEC_Constants.LT_APP_INACTIVE_LICENSE_CERTIFICATE => EEC_Constants.LT_FCC_INACTIVATE,
            EEC_Constants.LT_APP_INTEND_TO_CLOSE_PROGRAM => EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION,
            EEC_Constants.LT_APP_REQUEST_VARIANCE_ON_REGULATIONS => EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST,
            EEC_Constants.LT_APP_BACKGROUND_RECORD_CHECK => EEC_Constants.LT_BACKGROUND_RECORD_CHECK,
            EEC_Constants.LT_APP_APPLY_FOR_CHANGE_OF_ADDRESS => EEC_Constants.LT_FCC_ASSISTANT_CHANGE_OF_ADDRESS
    };
    List<Household_Member__c> removeHMList                              { get; set; }
    List<Employment_History__c> removeEHList                            { get; set; }
    List<Room__c> removeRoomList                                        { get; set; }
    List<Training_Experience__c> removeTeList                           { get; set; }
    List<S3_File__c> transactionAttachments                             { get; set; }
    public Map<String, Map<String, String>> transactionAttachmentsMap   { get; set; }
    public Map<Id, String> transactionAttachmentsUrlMap                 { get; set; }
    public String fileToDelete                                          { get; set; }
    public User loggedUser                                              { get; set; }
    public Contact loggedUserContact                                    { get; set; }
    public boolean loggedCertifiedContact                               { get; set; }
    public string applicationDisplayName                                { get; set; }
    Boolean initHH = false;
    Boolean initLS = false;
    Boolean initIndoor = false;
    @testVisible Boolean initTraining = false;
    // Household Member Table Variables
    public String MembersJson                                           { get; set; }
    public String MembersToDeleteJson                                   { get; set; }
    public String ihmListJson                                           { get; set; }
    // Attachment variables.
    public List<S3_File__c> attachments                                 { get; set; }
    public List<S3_File__c> additionalTrainingAttachments               { get; set; }
    public String indoorAttachmentsJson                                 { get; set; }
    public String attachmentsJson                                       { get; set; }
    public String trainingAttachmentsJson                               { get; set; }
    public String transCertCheckboxFieldname                            { get; set; }
    public String memberId                                              { get; set; }
    // Attachment edit variables.
    public String fileToEditId                                          { get; set; }
    public String fileToEditDescription                                 { get; set; }
    public Boolean renderAttachLib                                      { get; set; }
    public Transaction_Document__c transDoc                             { get; set; }
    public String docId                                                 { get; set; }
    public String docName                                               { get; set; }
    public Boolean isFccAssistant                                       { get; set; }
    Public String ltId                                                  { get; set; }
    public String umbrellaName                                          { get; set; }
    public String cityName                                              { get; set; }
    public String errorMessage                                          { get; set; }
    public List<Account> queryResults                                   { get; set; }
    public boolean isNewUmbrella                                        { get; set; }
    public List<SelectOption> listCity                                  { get; set; }
    public string newCityName                                           { get; set; }
    public string selectedStateName                                     { get; set; }
    public string transactionDocumentId                                 { get; set; }
    public string transactionDocumentComment                            { get; set; }
    public List<selectOption> listLicenseRequested                      { get; set; }
    public List<Contact> listContact                                    { get; set; }
    public string previousPageName                                      { get; set; }
    public String highestStepReached                                    { get; set; }
    public String attestation                                           { get; set; }
    public boolean isInternalUser                                       { get; set; }
    //Umbrella contact Id for ownershipadmin page
    public Id umbrellaContactId                                         { get; set; }
    public List<TransactionDocumenWrapper> listAdditionalDocument       { get; set; }
    List<Transaction_Document__c> listTransactionDocument               { get; set; }
    
    public class TransactionDocumenWrapper {
        public Transaction_Document__c transctionDocument               { get; set; }
        public string mandatory                                         { get; set; }
        public string s3FileId                                          { get; set; }
        public string s3FileName                                        { get; set; }
        public boolean displayUmbrella                                  { get; set; }
        public boolean displayProvider                                  { get; set; }
        public List<String> listOfS3Files                               { get; set; }
        public string transactionDocumentName                           { get; set; }
    }
    public EEC_TransactionWizardController() {
        //try {
        ltId = ApexPages.currentPage().getParameters().get('ltId');
        memberId = ApexPages.currentPage().getParameters().get('member');
        docId = ApexPages.currentPage().getParameters().get('docId');
        docName = ApexPages.currentPage().getParameters().get('docName');
        listCity = new List<SelectOption>();
        transactionContact = new Transaction_Contact__c();
        transDoc = new Transaction_Document__c();
        leadConfiguration = new LEAD_Configuration__c();
        attestation = '';
        selectedOwnerShip = '';
        isSaveOnly = false;
        isSubmitted = false;
        isInternalUser = false;
        if (docName != null) {
            renderAttachLib = true;
        }
        String accountId = '';
        if (String.isNotBlank(memberId)) {
            accountId = memberId;
        } else {
            List<Account> tempAccount = [Select Id,OwnerID From Account Where ID in (Select Accountid From User Where id = :Userinfo.getUserId()) Limit 1];
            if (tempAccount != null && tempAccount.size() == 1) {
                accountId = tempAccount.get(0).Id;
            }
        }
        provider = new Account();
        if (accountId == '')
            accountId = ApexPages.currentPage().getParameters().get('accountId');
        provider = [
                SELECT Id,name,ownerid, License_Type__c,Provider_city_text__c, State__c, is_FCC__c, Recordtype.DeveloperName,  License_Status__c, First_Issue_Date__c, Renewal_date__c, Provider_Status__c,
                        Accept_Referral__c,Account_books_Responsible__c,Records_Responsible__c, Personnel_Records_Responsible__c,Children_s_Records_Responsible__c,
                        Staff_Schedules_Responsible__c,Kindergarten_Responsible__c,School_Age_Responsible__c,Services_for_Children_w_Disability_Resp__c,Daily_Activities_Responsible__c,Equipment_Responsible__c,
                        Indoor_Square_Footage__c,Number_of_toilets__c,Number_of_sinks__c,Lead_Paint_Compliance__c,Detailed_Inspection__c,Building_Inspection_Max_Capacity__c,Building_inspection_expiration_Date__c,Building_Codes__c,Health_Inspection_Expiration_Date__c,
                        MinAgeServed__c,MaxAgeServed__c,Awake_Ratio__c,Asleep_Ratio__c,Ratio_Comment__c,Use_Physical_Restraints__c,Referral_Agency__c,
                        Gender__c,Well_Water_Test_date__c,Capacity_Small_Group__c,Infant_birth_15_mo__c,Infant_Toddler_birth_33_mo__c,Toddler_15_mo_33_mo__c,Toddler_Preschool_15_mo_K__c,Preschool_33_mo_K__c,Preschool_SA_33_mo_8_yr__c,Kindergarten__c,School_Age_5_yr_14_yr__c,Multi_Age_Group_birth_14_yr__c,
                        School_Year_To__c,School_Year_From__c, Camp_Permit_Issue_Date__c,Camp_Permit_Number__c,Summer_Camp_Permit__c,Staff_Development_Responsible__c,Staff_Training_Responsible__c,Staff_Orientation_Responsible__c,Staff_Supervision_Responsible__c,Parent_Involvement_Responsible__c,Social_Services_Responsible__c,Infant_Toddler_Program_Responsible__c,
                        Certified_As__c, Allow_New_Application_as_Provider__c, Allow_Renewal_as_Assistant__c, Can_Communicate_in_English__c, PPM_Meeting_Attended_Date__c, capacity__c,Outdoor_Square_footage__c,Pool_roof_inspection_date__c,Other_Approved_Additional_Space__c,ShippingPostalCode, Phone, Unlisted_Phone_Number__c, Alternate_Phone__c, Fax, Provider_Email__c,//Name_of_the_Person_to_Contact__c,
                        Characteristics_of_children_served_pickl__c,International_Adoption_Countries__c,Other_Countries__c,Other_Referral_Agency__c,No_Adoptive_Placements__c,Number_of_Foster_Homes__c,No_Birth_Mothers_Receiving_Services__c,No_Birth_Mothers_Making_Adoption_Plan__c,Number_of_Waiting_Families__c,No_Families_Rec_Home_Stdy_Serv_Only__c,
                        Recving_search_and_or_reunion_services__c,No_Indiv_Rec_Search_and_or_Reunion_Serv__c,Number_of_Reunions_Facilitated__c,Number_of_Child_Assessments__c,Number_of_Home_Study_Services__c,No_of_Families_Rec_Case_Mgmt_Services__c,No_Families_Receiving_Info_and_Referral__c,Number_of_Children_Placed_in_Care__c,ShippingStreet, ShippingCity, ShippingState,
                        Extended_Day_Provided__c,Provider_Address_1__c, Provider_Address_2__c, Provider_City__c, Provider_City__r.Name, Provider_Zip_Code__c, Live_at_this_address__c,Language__c, Preferred_Language__c, Race__c, Is_GSA__c, Is_R_P__c,Is_Placement__c, Is_Residential__c, (SELECT Id, Status__c,New_Name__c,RecordType.DeveloperName,Date_Name_Change_is_Effective__c FROM Licensing_Transactions__r order BY CreatedDate DESC),
                        Full_School_Year__c, Full_Day_Program_Available_On__c, Full_Day_Program_Available_From__c, Half_Day_Morning_Program_Available_On__c, Half_Day_Morning_Program_Available_From__c, Half_Day_Afternoon_Program_Available_On__c, Half_Day_Afternoon_Program_Avail_From__c, Evenings_Service_Provided__c, Has_Camp_Capacity__c, Total_Staff__c, Full_Day_Program_Available_To__c, Half_Day_Morning_Program_Available_To__c,
                        Half_Day_Afternoon_Program_Available_To__c, Extended_Day_Available_On__c, Drop_In_Service_Provided__c, Summer_Camp_Services_Provided__c, Cafeteria_Approved__c, Gym_Approved__c
                       ,Licensor_Full_Name__c, Licensor_Phone__c, Region__r.Phone__c,Type_of_Ownership__c,Umbrella_Members__c,Regulatory_Status__c,Closed_Date__c,Funded_Status__c,Funded_Provider_Status__c
                FROM Account
                WHERE Id = :accountId
        ];
        listContact = [select Id, Name from Contact where AccountId = :accountId];
        system.debug('ltId<<'+ltId);
        if (String.isNotBlank(ltId)) {
            getLicenseTrans(ltId);
        } else { 
            providerRecordType = provider.RecordType.Name;
            licenseTransation = new Licensing_Transaction__c();
        }
        List<Contact> conList = new List<Contact>();
        if (provider.Is_GSA__c || provider.Is_R_P__c) {
            conList = [select FirstName, LastName, BirthDate, Email, MobilePhone, PQ_Expiration_Date__c,Prof_Qualification_Reg_Number__c, (Select id,Role__c from Contact_Roles__r where Role__c like 'Main Contact%') from Contact where AccountId = :provider.Id];
        } else {
            conList = [
                    select FirstName, LastName, BirthDate, Email, MobilePhone, PQ_Expiration_Date__c,Prof_Qualification_Reg_Number__c
                    from Contact
                    where AccountId = :provider.Id and Role__c like 'Main Contact%'
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
        }
        if (conList != null && conList.size() > 0) {
            cntct = conList.get(0);
        } else {
            conList = [
                    select FirstName, LastName, BirthDate, Email, MobilePhone, PQ_Expiration_Date__c,Prof_Qualification_Reg_Number__c
                    from Contact
                    where AccountId = :provider.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
            if (conList != null && conList.size() > 0) {
                cntct = conList.get(0);
            }
        }
        if(String.isNotBlank(providerRecordType)) {
            leadConfiguration = [SELECT Visit_Narrative_Summary_Default__c, SystemModstamp, Portal_Transaction_Introduction__c,
                                    Number_of_days_for_Investigation_Visit__c, No_of_Days_Prior_Corr_Action_Deadline__c, No_of_Days_For_Investigation_Due_Date__c, Name,
                                    Large_Group_Instruction__c, Investigation__c, Investig_Non_comp_Default_if_Any__c, Follow_up_Visit_Estimated_Deadline__c,Attestation_Text__c,
                                    Transaction_Submission_Disclaimer__c, Transaction_Attachments_New__c, Transaction_Attachments_Renewal__c, Transaction_Attachments_Upgrade__c
                                FROM LEAD_Configuration__c
                                WHERE Name = :providerRecordType];
            attestation = leadConfiguration.Attestation_Text__c;
        }
        if (String.isNotBlank(ltId)) {
            for (Licensing_Transaction__c lt : [
                    SELECT Transaction_Configuration__r.EEC_Licensing_Transaction_Instructions__c,
                            Transaction_Configuration__r.FCC_Licensing_Transaction_Instructions__c,
                            Transaction_Configuration__r.GSA_Licensing_Transaction_Instructions__c,
                            Transaction_Configuration__r.R_P_Licensing_Transaction_Instructions__c,
                            Transaction_Configuration__r.Transaction_Submission_Disclaimer__c
                    FROM Licensing_Transaction__c
                    WHERE Id = :ltId]) {
                if ((provider.Is_FCC__c || providerRecordType == EEC_Constants.PRO_FCC_ASSISTANT) && String.isNotBlank(lt.Transaction_Configuration__r.FCC_Licensing_Transaction_Instructions__c)) {
                    licenseInstructionMessage = lt.Transaction_Configuration__r.FCC_Licensing_Transaction_Instructions__c;
                } else if (provider.Is_GSA__c && String.isNotBlank(lt.Transaction_Configuration__r.GSA_Licensing_Transaction_Instructions__c)) {
                    licenseInstructionMessage = lt.Transaction_Configuration__r.GSA_Licensing_Transaction_Instructions__c;
                } else if (provider.Is_R_P__c && String.isNotBlank(lt.Transaction_Configuration__r.R_P_Licensing_Transaction_Instructions__c)) {
                    licenseInstructionMessage = lt.Transaction_Configuration__r.R_P_Licensing_Transaction_Instructions__c;
                } else {
                    licenseInstructionMessage = lt.Transaction_Configuration__r.EEC_Licensing_Transaction_Instructions__c;
                }
                submissionDisclaimer = lt.Transaction_Configuration__r.Transaction_Submission_Disclaimer__c;
            }
            //Avoid null pointer error in replace function
            String licensorFullname;
            String regionPhone ;
            String licensorPhone;
            if (provider.Licensor_Full_Name__c != null) {
                licensorFullname = provider.Licensor_Full_Name__c;
            } else {
                licensorFullname = '';
            }
            if (provider.Region__r.Phone__c != null) {
                regionPhone = provider.Region__r.Phone__c;
            } else {
                regionPhone = '';
            }
            if (provider.Licensor_Phone__c != null) {
                licensorPhone = provider.Licensor_Phone__c;
            } else {
                licensorPhone = '';
            }
            /* if(String.isBlank(licensorFullname)) {
            licensorFullname    =   '';
            }
            if(String.isBlank(regionPhone)) {
            regionPhone =   '';
            }
            if(String.isBlank(licensorPhone)) {
                licensorPhone   =   '';
            }*/
            if (licenseInstructionMessage != null) {
                licenseInstructionMessage = licenseInstructionMessage.replace('#Provider.Licensor.First Name# #Provider.Licensor.Last Name#', licensorFullname)
                        .replace('#Provider.Licensor.Phone Number#', licensorPhone)
                        .replace('#Provider.Region.Phone#', regionPhone);
            }
        }
        loggedUser = [select Id, Name, contactId, UserType from User where Id = :UserInfo.getUserId()];
        loggedCertifiedContact = false;
        if (loggedUser.ContactId == null) {
            isInternalUser = true;
        }
        if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
            varianceList = new list<Variance_on_Regulation__c>();
            for (Variance_on_Regulation__c variance : [
                    Select Source_Transaction__c, Source_Transaction__r.Status__c, Provider__c, Name, Id
                    From Variance_on_Regulation__c
                    where Source_Transaction__c = :ltId]) {
                varianceList.add(variance);
            }
        }
        //Placement Agency Page licenseHeld
        nonCancelledTransaction = new List<Licensing_Transaction__c>();
        for (Licensing_Transaction__c nonCancelled : [Select Id,Status__c,Provider__c From Licensing_Transaction__c where Status__c != :EEC_Constants.LT_CANCELLED AND Provider__c = :provider.Id]) {
            nonCancelledTransaction.add(nonCancelled) ;
        }
        List<Id> licenseTranId = new List<Id>();
        //populate contact details
        if (cntct != null) {
            licenseTransation.Prior_First_Name__c = cntct.Firstname;
            licenseTransation.Prior_Last_Name__c = cntct.Lastname;
        }
        if (nonCancelledTransaction.size() > 0) {
            for (Licensing_Transaction__c ltHeld : nonCancelledTransaction) {
                licenseTranId.add(ltHeld.Id);
            }
        }
        Id addInfoId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('Other Licenses Held').getRecordTypeId();
        oldHeldLicense = new Additional_Information__c();
        heldLicense = new List<Additional_Information__c>();
        try {
            if (licenseTranId.size() != 0) {
                oldHeldLicense = [select Id,Name_of_Licensee__c,Provider__c,Type_of_License__c,State_Country_Issuing_the_License__c,License_Number__c,Licensing_Transaction__c,RecordTypeID From Additional_Information__c where Licensing_Transaction__c IN:licenseTranId AND RecordTypeID = :addInfoId Order BY lastModifiedDate DESC];
            }
        } catch (exception e) {
            oldHeldLicense = null;
        }
        if (licenseTransation.Out_of_state_childcare_related_licenses1__c == 'Yes') {
            checkHeld();
        }
        //placement agency multipicklist
        if (licenseTransation.Characteristics_of_children_served__c != null) {
            characterRadio = true;
        } else {
            characterRadio = false;
        }
        if (licenseTransation.Building_Codes_c__c == null) {
            bldgCheck = false;
        } else {
            bldgCheck = true;
        }
       
        //Placement Agency RelatedLicense
        relatedLicense = new List<Additional_Information__c>();
        Id addRelatedId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('Other License Applications').getRecordTypeId();
        try {
            if (licenseTranId.size() != 0) {
                oldRelatedAct = [select Id,Name_of_Applicant__c,State_Country_of_Applicant__c,Name_of_Licensing_Authority__c,Address_of_Licensing_authority__c,Phone_No_of_Licensing_Authority__c,Status_of_Application__c,RecordTypeID From Additional_Information__c where Licensing_Transaction__c IN:licenseTranId AND RecordTypeID = :addRelatedId Order BY lastModifiedDate DESC];
            }
        } catch (exception e) {
            oldRelatedAct = null;
        }
        if (licenseTransation.Out_of_state_license_appl_in_process1__c == 'Yes') {
            checkRelated();
        }
        //Placement Agency Page Criminal Act
        Id addCriminId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('Admin/civil/criminal action detail').getRecordTypeId();
        oldCriminalAct = new Additional_Information__c();
        criminalAct = new List<Additional_Information__c>();
        try {
            if (licenseTranId.size() != 0) {
                oldCriminalAct = [select Id,Name_Admin_civil_criminal_action__c, Provider__c,Nature_of_Proceedings__c,Caption__c,Docket_Number__c,Name_of_court_or_administrative_body__c, Address_of_court__c, Disposition__c,RecordTypeID From Additional_Information__c where Licensing_Transaction__c IN:licenseTranId AND RecordTypeID = :addCriminId Order BY lastModifiedDate DESC];
            }
        } catch (exception e) {
            oldCriminalAct = null;
        }
        if (licenseTransation.Admin_Civil_criminal_action_last_5_yrs1__c == 'Yes') {
            checkCriminal();
        }
        //Placement Agency Page FederalInvestigation
        federalInv = new List<Additional_Information__c>();
        oldFedralAct = new Additional_Information__c();
        Id addFedId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('State/federal investigation detail').getRecordTypeId();
        try {
            if (licenseTranId.size() != 0) {
                oldFedralAct = [select Id,Name_of_Person_Agency_Investigated__c,State_and_or_Federal_Agency__c,Nature_of_Investigation__c,RecordTypeID From Additional_Information__c where Licensing_Transaction__c IN:licenseTranId AND RecordTypeID = :addFedId Order BY lastModifiedDate DESC];
            }
        } catch (exception e) {
            oldFedralAct = null;
        }
        if (licenseTransation.State_Federal_investigation_last_5_yrs1__c == 'Yes') {
            checkFederal();
        }
        if (licenseTransation.Program_licensed_or_approved_by_agency__c) {
            programLicensedAgency = 'Yes';
        } else if (!licenseTransation.Program_licensed_or_approved_by_agency__c) {
            programLicensedAgency = 'No';
        }
        if (licenseTransation.Is_your_program_contracted__c) {
            programContacted = 'Yes';
        } else if (!licenseTransation.Is_your_program_contracted__c) {
            programContacted = 'No';
        }
        /*Loading Default values for the record at the time of creation */
        smallGroup = EEC_Constants.LT_GROUP_TYPE_SMALL_GROUP;
        largeGroup = EEC_Constants.LT_GROUP_TYPE_LARGE_GROUP;
        if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE) {
            if (licenseTransation.Camp_Permit_Issue_Date__c == null) {
                licenseTransation.Camp_Permit_Issue_Date__c = provider.Camp_Permit_Issue_Date__c;
            }
            if (licenseTransation.Camp_Permit_Number__c == null) {
                licenseTransation.Camp_Permit_Number__c = provider.Camp_Permit_Number__c;
            }
        }
        /*Loading Default values for record types other than New License*/
        if (LicenseRecordTypeName != EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE) {
            
            if (licenseTransation.Characteristics_of_children_served__c == '' || licenseTransation.Characteristics_of_children_served__c == null) {
                licenseTransation.Characteristics_of_children_served__c = provider.Characteristics_of_children_served_pickl__c;
            }
            if (licenseTransation.Gender_of_children_served__c == '' || licenseTransation.Gender_of_children_served__c == null) {
                licenseTransation.Gender_of_children_served__c = provider.Gender__c;
            }
            if (licenseTransation.Minimum_age_of_children_served__c == '' || licenseTransation.Minimum_age_of_children_served__c == null) {
                licenseTransation.Minimum_age_of_children_served__c = provider.MinAgeServed__c;
            }
            if (licenseTransation.Maximum_age_of_children_served__c == '' || licenseTransation.Maximum_age_of_children_served__c == null) {
                licenseTransation.Maximum_age_of_children_served__c = provider.MaxAgeServed__c;
            }
            if (licenseTransation.Awake_Staff_to_child_ratio__c == '' || licenseTransation.Awake_Staff_to_child_ratio__c == null) {
                licenseTransation.Awake_Staff_to_child_ratio__c = provider.Awake_Ratio__c;
            }
            if (licenseTransation.Asleep_Staff_to_child_ratio__c == '' || licenseTransation.Asleep_Staff_to_child_ratio__c == null) {
                licenseTransation.Asleep_Staff_to_child_ratio__c = provider.Asleep_Ratio__c;
            }
            if (licenseTransation.Ratio_comments__c == '' || licenseTransation.Ratio_comments__c == null) {
                licenseTransation.Ratio_comments__c = provider.Ratio_Comment__c;
            }
           
           
            if (licenseTransation.Other_Referral_Agency__c == '' || licenseTransation.Other_Referral_Agency__c == null) {
                licenseTransation.Other_Referral_Agency__c = provider.Other_Referral_Agency__c;
            }
        }
        /*Loading Default values for GSA record types other than New License*/
        if (LicenseRecordTypeName != EEC_Constants.LT_GSA_NEW_LICENSE) {
            if (licenseTransation.Operation_Type__c == '' || licenseTransation.Operation_Type__c == null) {
                licenseTransation.Operation_Type__c = provider.Full_School_Year__c;
            }
            
            if (licenseTransation.Operation_End_Month__c == '' || licenseTransation.Operation_End_Month__c == null) {
                licenseTransation.Operation_End_Month__c = provider.School_Year_To__c;
            }
           /* if (licenseTransation.Drop_in_Service1__c == null) {
                licenseTransation.Drop_in_Service1__c = String.ValueOf(provider.Drop_In_Service_Provided__c == true ? 'Yes' : 'No');
            }
            if (licenseTransation.Evenings_Service1__c == null) {
                licenseTransation.Evenings_Service1__c = String.ValueOf(provider.Evenings_Service_Provided__c == true ? 'Yes' : 'No');
            }
            if (licenseTransation.Summer_Camp_Service1__c == null) {
                licenseTransation.Summer_Camp_Service1__c = String.ValueOf(provider.Summer_Camp_Services_Provided__c == true ? 'Yes' : 'No');
            }
           
            if (licenseTransation.Gym_Facility_Used_During_Program_Hours1__c == null) {
                licenseTransation.Gym_Facility_Used_During_Program_Hours1__c = String.ValueOf(provider.Gym_Approved__c == true ? 'Yes' : 'No');
            }*/
        } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE) {
            if (licenseTransation.Operation_Type__c == null) {
                licenseTransation.Provide_Extended_Days1__c = null;
                licenseTransation.Drop_in_Service1__c = null;
              //  licenseTransation.Evenings_Service1__c = null;
                licenseTransation.Summer_Camp_Service1__c = null;
                licenseTransation.Gym_Facility_Used_During_Program_Hours1__c = null;
               // licenseTransation.Evenings_Service1__c = null;
               // licenseTransation.Everbeen_involved_in_legal_action__c = null;
            }
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
            
        }
        credentials = new AWSKeys(AWSCredentialName);
        accessKey = credentials.key;
        AWS_Config__c aws = AWS_Config__c.getInstance();
        bucketName = aws.S3_Bucket_Name__c;
        bucketItemAccess = aws.S3_Access_Control_Level__c;
        // Get the page url for form submit.
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); // it will return: < https://cs14.salesforce.com >
        String PageURL = ApexPages.currentPage().getUrl(); // it will return: < /apex/myVFpage?id=906F00000008w9wIAA >
        portalUrl = baseURL + PageURL;
        generateAttachmentMappings();
        refreshAttachmentsList();
        retrieveAddtionalTrainingAttachmentsList();
        isFccAssistant = false;
        if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
            isFccAssistant = true;
            saveAndReturnLabel = 'Save and Return to Assistant';
        } else {
            saveAndReturnLabel = 'Save and Return to Program';
        }
        if (licenseTransation.Last_Reached_Step__c != null && !isFccAssistant && licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC) && licenseRecordTypeLabel.equalsIgnoreCase('FCC Assistant Renewal')) {
            isFccAssistant = true;
            try {
                submissionDisclaimer = (String) [Select Transaction_Submission_Disclaimer__c from LEAD_Configuration__c where Name = :EEC_Constants.LEAD_CONFIG_FCC_ASSISTANT].Transaction_Submission_Disclaimer__c;
            }
            catch (Exception e) {
            }
        }
        if (licenseTransation.Last_Reached_Step__c != null && isFccAssistant && licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT) && licenseRecordTypeLabel.equalsIgnoreCase(EEC_Constants.LT_FCC_NEW_LICENSE)) {
            isFccAssistant = false;
            try {
                submissionDisclaimer = (String) [Select Transaction_Submission_Disclaimer__c from LEAD_Configuration__c where Name = :EEC_Constants.LEAD_CONFIG_FCC].Transaction_Submission_Disclaimer__c;
            }
            catch (Exception e) {
            }
        }
        if (provider.Use_Physical_Restraints__c) {
            physicalRestraint = 'Yes';
        } else {
            physicalRestraint = 'No';
        }
        sumOfCapacities = '' + licenseTransation.Total_License_Capacity_Requested__c;
        selectedBoardContact = '--Select--';
        selectedContact = '--Select--';
        minAge = '' + licenseTransation.Minimum_Age_Limit_Requested_Years__c;
        minMon = '' + licenseTransation.Minimum_Age_Limit_Requested_Months__c;
        maxAge = '' + licenseTransation.Maximum_Age_Limit_Requested_Years__c;
        maxMon = '' + licenseTransation.Maximum_Age_Limit_Requested_Months__c;
        if (provider.MinAgeServed__c != null) {
            minAgeRes = '' + provider.MinAgeServed__c;
        } else {
            minAgeRes = '';
        }
        if (provider.MaxAgeServed__c != null) {
            maxAgeRes = '' + provider.MaxAgeServed__c;
        } else {
            maxAgeRes = '';
        }
        
        if (String.isNotBlank(ltId)) {
            checkLicenseStatus();
            getLeadConfigurationData();
            getLicensingAdditionalAttachments();
            populateTransactionContact();
            getDesignativeofAdminData();
            getAllDocuments();
            getAdditionalInformationdata();
            getTransactionContactData();
            checkExistingRenewalApplication();
           
        }
        //  } catch (Exception e) {
        //  }
    }
    public void getVarianceList() {
        listofVariance = new List<Variance_on_Regulation__c>();
        if (String.isNotBlank(ltId)) {
            for (Variance_on_Regulation__c variance : [
                    Select Source_Transaction__c, Source_Transaction__r.Status__c, Provider__c, Name, Id
                    From Variance_on_Regulation__c
                    where Source_Transaction__c = :ltId
            ]) {
                listofVariance.add(variance);
            }
        }
        if (listofVariance.size() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You need to add atleast one variance in order to complete this application.'));
            //return false;
        }
    }
    public Integer noOfRenewalApplications { get; set; }
    private void checkExistingRenewalApplication() {
        noOfRenewalApplications = 0;
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        for (Licensing_Transaction__c lt : [
                SELECT Id,RecordType.DeveloperName,Status__c,Status_Reason__c
                FROM Licensing_Transaction__c
                WHERE Id = :ltId
                AND RecordType.DeveloperName = :EEC_Constants.LT_FCC_ASSISTANT_RENEWAL
                AND Status__c = :EEC_Constants.LT_CLOSED
                AND Status_Reason__c = :EEC_Constants.LT_STATUS_REASON_LICENSE_ISSUED
        ]) {
            noOfRenewalApplications++;
        }
    }
    private void checkLicenseStatus() {
        if (licenseTransation.Status__c == EEC_Constants.LT_SUBMITTED) {
            isSubmitted = true;
        }
        if (licenseTransation.Status__c == EEC_Constants.LT_CLOSED) {
            isSubmitted = true;
        }
        if (licenseTransation.Status__c == EEC_Constants.LT_UNDER_REVIEW) {
            isSubmitted = true;
        }
    }
    public void getTransactionContactData() {
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        List<Transaction_Contact__c> transContList = new List<Transaction_Contact__c>();
        if (String.isNotBlank(ltId)) {
            for (Transaction_Contact__c transaContact : [
                    SELECT Id,First_Name__c,Last_Name__c,Role__c,Date_of_Birth__c
                    FROM Transaction_Contact__c
                    WHERE Licensing_Transaction__c = :ltId AND (Role__c = :EEC_Constants.TC_ROLE_LICENSEE OR Role__c = :EEC_Constants.TC_ROLE_ASSISTANT)
            ]) {
                transContList.add(transaContact);
            }
            if (transContList.size() > 0) {
                transactionContact = transContList[0];
            }
        }
    }
    public void getLicensingAdditionalAttachments() {
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        listAdditionalDocument = new List<TransactionDocumenWrapper>();
        if (String.isNotBlank(ltId)) {
            List<Document__c> listDocuments = [
                    select Id, Document_Name__c, Approved_for_Future_Usage__c, Document_Type__c, Document_Type__r.Name,
                            Document_Type__r.Description__c, Attachment_Status__c, Notes__c,Valid_From__c,Valid_To__c,Provider__c,
                            Contact_Role__c, (select Id,Filename__c from S3_Files__r)
                    from
                            Document__c
                    where Provider__c = :licenseTransation.Provider__c
                    and Current__c = true
            ];
            listTransactionDocument = [
                    select Id, Name,Transaction_Document_Name__c,Comments__c,Document__c,Document_Type__c,
                            Document_Type__r.Individual_Document__c,
                            Document_Type__r.Name,
                            Document_Type__r.Description__c,
                            Document__r.Contact_Role__c,Document_Level__c,
                            Document__r.Valid_From__c,
                            Document__r.Contact_Role__r.Contact__r.FirstName,Document__r.Contact_Role__r.Contact__r.LastName,
                            Document__r.Contact_Role__r.Contact__r.Role__c,
                            Document__r.Contact_Role__r.Role__c,
                            Document__r.Document_Name__c,
                            Document__r.Provider__r.Umbrella_Members__c,
                            Document_Type__r.Required_For_Transaction_Type__c,
                            Document_Type__r.Optional_for_Transactio_Type__c,
                            Document_Type__r.Allow_Send_by_Mail_for_Transaction_Types__c,
                            Last_Status_Date__c,Licensing_Transaction__c,Mode__c,Note_For_Revision__c,Status__c,Transaction_Notes__c,
                            Variance_on_Regulation__r.Associated_Regulation__r.Regulation_Number__c,
                            Variance_on_Regulation__c, Sent_by_mail__c, Send_by_Mail_Allowed__c
                    from Transaction_Document__c
                    where Licensing_Transaction__c = :ltId
            ];
            TransactionDocumenWrapper transactionDocumenWrapperObj;
            for (Transaction_Document__c transactionDocument : listTransactionDocument) {
                if (transactionDocument.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_ADDITIONAL) {
                    for (Document__c document : listDocuments) {
                        if (document.Id == transactionDocument.Document__c) {
                            transactionDocumenWrapperObj = new TransactionDocumenWrapper();
                            transactionDocumenWrapperObj.transctionDocument = transactionDocument;
                            List<S3_File__c> listFiles = document.S3_Files__r;
                            if (listFiles.size() > 0) {
                                for (S3_File__c s3File : listFiles) {
                                    transactionDocumenWrapperObj.transctionDocument = transactionDocument;
                                    transactionDocumenWrapperObj.transactionDocumentName = transactionDocument.Transaction_Document_Name__c;
                                    transactionDocumenWrapperObj.s3FileName = s3File.Filename__c;
                                    transactionDocumenWrapperObj.s3FileId = s3File.Id;
                                    listAdditionalDocument.add(transactionDocumenWrapperObj);
                                }
                            } else {
                                listAdditionalDocument.add(transactionDocumenWrapperObj);
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    public void getAdditionalInformationdata() {
        heldLicense = new List<Additional_Information__c>();
        relatedLicense = new List<Additional_Information__c>();
        criminalAct = new List<Additional_Information__c>();
        federalInv = new List<Additional_Information__c>();
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        if (String.isNotBlank(ltId)) {
            for (Additional_Information__c addInfoObj : [
                    SELECT id,RecordType.DeveloperName,Address_of_court__c,Address_of_Licensing_authority__c,
                            Caption__c,Disposition__c,Docket_Number__c,License_Number__c,Licensing_Transaction__c,
                            Name_Admin_civil_criminal_action__c,Name_of_Applicant__c,Name_of_court_or_administrative_body__c,
                            Name_of_Licensee__c,Name_of_Licensing_Authority__c,Name_of_Person_Agency_Investigated__c,Nature_of_Investigation__c,
                            Nature_of_Proceedings__c,Phone_No_of_Licensing_Authority__c,Provider__c,State_Country_Issuing_the_License__c,
                            State_Country_of_Applicant__c,State_and_or_Federal_Agency__c,Status_of_Application__c,Type_of_License__c
                    FROM Additional_Information__c
                    WHERE Licensing_Transaction__c = :ltId
            ]) {
                if (addInfoObj.RecordType.DeveloperName == EEC_Constants.AI_ADMIN_CIVIL_CRIMINAL_ACTION_DETAIL) {
                    criminalAct.add(addInfoObj);
                }
                if (addInfoObj.RecordType.DeveloperName == EEC_Constants.AI_OTHER_LICENSE_APPLICATIONS) {
                    relatedLicense.add(addInfoObj);
                }
                if (addInfoObj.RecordType.DeveloperName == EEC_Constants.AI_OTHER_LICENSES_HELD) {
                    heldLicense.add(addInfoObj);
                }
                if (addInfoObj.RecordType.DeveloperName == EEC_Constants.AI_STATE_FEDERAL_INVESTIGATION_DETAIL) {
                    federalInv.add(addInfoObj);
                }
            }
        }
    }
    public List<SelectOption> options { get; set; }
    public Boolean schoolAgeNotApplicable;
    public String schoolAgeNotApplicableNotes;
    public Boolean kinderGartenNotApplicable;
    public String kinderGartenNotApplicableNotes;
    public Boolean earlyEducationApplicable;
    public String earlyEducationApplicableNotes;
    public List<TransactionContactWrapper> transactionContactWrapperList { get; set; }
    Map<String, String> mapOfTC;
    Map<String, String> mapOfTCName;
    public void getDesignativeofAdminData() {
        options = new List<SelectOption>();
        transactionContactWrapperList = new List<TransactionContactWrapper>();
        options.add(new SelectOption('', '--None--'));
        String contactName;
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        mapOfTC = new Map<String, String>();
        mapOfTCName = new Map<String, String>();
        for (Transaction_Contact__c transObj : [
                SELECT Id,Infant_Toddler_Program__c,Social_Services__c,Parent_Involvement__c,First_Name__c,Last_Name__c,
                        Staff_Supervision__c,Staff_Orientation__c,Staff_Training__c,Staff_Development__c,
                        Equipment__c,Daily_Activities__c,Services_for_children_with_disabilities__c,School_Age__c,Kindergarten__c,
                        Early_childhood_education_program__c,Staff_Schedules__c,Financial_Documentation__c,Children_s_Records__c,
                        Personnel_Records__c,Records__c,Account_books__c,Licensing_Transaction__c,Licensing_Transaction__r.School_Age_Not_Applicable__c,
                        Licensing_Transaction__r.School_Age_Not_Applicable_Notes__c,Licensing_Transaction__r.Early_childhood_education_program_N_A__c,
                        Licensing_Transaction__r.Kindergarten_Not_Applicable_Notes__c,Licensing_Transaction__r.Early_childhood_edu_program_N_A_Notes__c,
                        Licensing_Transaction__r.Kindergarten_Not_Applicable__c
                FROM Transaction_Contact__c
                WHERE Licensing_Transaction__c = :ltId
        ]) {
            contactName = transObj.First_Name__c + ' ' + transObj.Last_Name__c;
            options.add(new SelectOption(transObj.id, contactName));
            if (transObj.Account_books__c) {
                mapOfTC.put('Account_books__c', transObj.id);
                mapOfTCName.put('Account_books__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Records__c) {
                mapOfTC.put('Records__c', transObj.id);
                mapOfTCName.put('Records__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Personnel_Records__c) {
                mapOfTC.put('Personnel_Records__c', transObj.id);
                mapOfTCName.put('Personnel_Records__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Children_s_Records__c) {
                mapOfTC.put('Children_s_Records__c', transObj.id);
                mapOfTCName.put('Children_s_Records__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Financial_Documentation__c) {
                mapOfTC.put('Financial_Documentation__c', transObj.id);
                mapOfTCName.put('Financial_Documentation__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Staff_Schedules__c) {
                mapOfTC.put('Staff_Schedules__c', transObj.id);
                mapOfTCName.put('Staff_Schedules__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Early_childhood_education_program__c) {
                mapOfTC.put('Early_childhood_education_program__c', transObj.id);
                mapOfTCName.put('Early_childhood_education_program__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
                earlyEducationApplicable = transObj.Licensing_Transaction__r.Early_childhood_education_program_N_A__c;
                earlyEducationApplicableNotes = transObj.Licensing_Transaction__r.Early_childhood_edu_program_N_A_Notes__c;
            } else {
                earlyEducationApplicable = transObj.Licensing_Transaction__r.Early_childhood_education_program_N_A__c;
                earlyEducationApplicableNotes = transObj.Licensing_Transaction__r.Early_childhood_edu_program_N_A_Notes__c;
            }
            if (transObj.Equipment__c) {
                mapOfTC.put('Equipment__c', transObj.id);
                mapOfTCName.put('Equipment__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Daily_Activities__c) {
                mapOfTC.put('Daily_Activities__c', transObj.id);
                mapOfTCName.put('Daily_Activities__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Services_for_children_with_disabilities__c) {
                mapOfTC.put('Services_for_children_with_disabilities__c', transObj.id);
                mapOfTCName.put('Services_for_children_with_disabilities__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.School_Age__c) {
                mapOfTC.put('School_Age__c', transObj.id);
                mapOfTCName.put('School_Age__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
                schoolAgeNotApplicable = transObj.Licensing_Transaction__r.School_Age_Not_Applicable__c;
                schoolAgeNotApplicableNotes = transObj.Licensing_Transaction__r.School_Age_Not_Applicable_Notes__c;
            } else {
                schoolAgeNotApplicable = transObj.Licensing_Transaction__r.School_Age_Not_Applicable__c;
                schoolAgeNotApplicableNotes = transObj.Licensing_Transaction__r.School_Age_Not_Applicable_Notes__c;
            }
            if (transObj.Kindergarten__c) {
                mapOfTC.put('Kindergarten__c', transObj.id);
                mapOfTCName.put('Kindergarten__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
                kinderGartenNotApplicable = transObj.Licensing_Transaction__r.Kindergarten_Not_Applicable__c;
                kinderGartenNotApplicableNotes = transObj.Licensing_Transaction__r.Kindergarten_Not_Applicable_Notes__c;
            } else {
                kinderGartenNotApplicable = transObj.Licensing_Transaction__r.Kindergarten_Not_Applicable__c;
                kinderGartenNotApplicableNotes = transObj.Licensing_Transaction__r.Kindergarten_Not_Applicable_Notes__c;
            }
            if (transObj.Staff_Supervision__c) {
                mapOfTC.put('Staff_Supervision__c', transObj.id);
                mapOfTCName.put('Staff_Supervision__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Staff_Orientation__c) {
                mapOfTC.put('Staff_Orientation__c', transObj.id);
                mapOfTCName.put('Staff_Orientation__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Staff_Training__c) {
                mapOfTC.put('Staff_Training__c', transObj.id);
                mapOfTCName.put('Staff_Training__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Staff_Development__c) {
                mapOfTC.put('Staff_Development__c', transObj.id);
                mapOfTCName.put('Staff_Development__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Infant_Toddler_Program__c) {
                mapOfTC.put('Infant_Toddler_Program__c', transObj.id);
                mapOfTCName.put('Infant_Toddler_Program__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Social_Services__c) {
                mapOfTC.put('Social_Services__c', transObj.id);
                mapOfTCName.put('Social_Services__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
            if (transObj.Parent_Involvement__c) {
                mapOfTC.put('Parent_Involvement__c', transObj.id);
                mapOfTCName.put('Parent_Involvement__c', transObj.First_Name__c + ' ' + transObj.Last_Name__c);
            }
        }
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Account_books__c')) ? mapOfTCName.get('Account_books__c') : '', (mapOfTC.containsKey('Account_books__c')) ? mapOfTC.get('Account_books__c') : '', 'Account/books', 'Account_books__c', false, false, '', 'Business Management/Record Keeping', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Records__c')) ? mapOfTCName.get('Records__c') : '', (mapOfTC.containsKey('Records__c')) ? mapOfTC.get('Records__c') : '', 'Records', 'Records__c', false, false, '', 'Business Management/Record Keeping', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Personnel_Records__c')) ? mapOfTCName.get('Personnel_Records__c') : '', (mapOfTC.containsKey('Personnel_Records__c')) ? mapOfTC.get('Personnel_Records__c') : '', 'Personnel Records', 'Personnel_Records__c', false, false, '', 'Business Management/Record Keeping', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Children_s_Records__c')) ? mapOfTCName.get('Children_s_Records__c') : '', (mapOfTC.containsKey('Children_s_Records__c')) ? mapOfTC.get('Children_s_Records__c') : '', 'Children\'s Records', 'Children_s_Records__c', false, false, '', 'Business Management/Record Keeping', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Financial_Documentation__c')) ? mapOfTCName.get('Financial_Documentation__c') : '', (mapOfTC.containsKey('Financial_Documentation__c')) ? mapOfTC.get('Financial_Documentation__c') : '', 'Financial Documentation', 'Financial_Documentation__c', false, false, '', 'Business Management/Record Keeping', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Staff_Schedules__c')) ? mapOfTCName.get('Staff_Schedules__c') : '', (mapOfTC.containsKey('Staff_Schedules__c')) ? mapOfTC.get('Staff_Schedules__c') : '', 'Staff Schedules', 'Staff_Schedules__c', false, false, '', 'Business Management/Record Keeping', false, '', false, ''));
        TransactionContactWrapper objTemp1 = new TransactionContactWrapper((mapOfTCName.containsKey('Kindergarten__c')) ? mapOfTCName.get('Kindergarten__c') : '', (mapOfTC.containsKey('Kindergarten__c')) ? mapOfTC.get('Kindergarten__c') : '', 'Kindergarten', 'Kindergarten__c', true, false, '', 'Development and Maintenance of Programs', kinderGartenNotApplicable, kinderGartenNotApplicableNotes, false, '');
        objTemp1.showCheckboxAndNotes = true;
        transactionContactWrapperList.add(objTemp1);
        TransactionContactWrapper objTemp2 = new TransactionContactWrapper((mapOfTCName.containsKey('Early_childhood_education_program__c')) ? mapOfTCName.get('Early_childhood_education_program__c') : '', (mapOfTC.containsKey('Early_childhood_education_program__c')) ? mapOfTC.get('Early_childhood_education_program__c') : '', 'Early childhood education program', 'Early_childhood_education_program__c', true, false, '', 'Development and Maintenance of Programs', false, '', earlyEducationApplicable, earlyEducationApplicableNotes);
        objTemp2.showCheckboxAndNotes = true;
        transactionContactWrapperList.add(objTemp2);
        TransactionContactWrapper objTemp = new TransactionContactWrapper((mapOfTCName.containsKey('School_Age__c')) ? mapOfTCName.get('School_Age__c') : '', (mapOfTC.containsKey('School_Age__c')) ? mapOfTC.get('School_Age__c') : '', 'School Age', 'School_Age__c', true, schoolAgeNotApplicable, schoolAgeNotApplicableNotes, 'Development and Maintenance of Programs', false, '', false, '');
        objTemp.showCheckboxAndNotes = true;
        transactionContactWrapperList.add(objTemp);
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Services_for_children_with_disabilities__c')) ? mapOfTCName.get('Services_for_children_with_disabilities__c') : '', (mapOfTC.containsKey('Services_for_children_with_disabilities__c')) ? mapOfTC.get('Services_for_children_with_disabilities__c') : '', 'Services for children with disabilities', 'Services_for_children_with_disabilities__c', false, false, '', 'Development and Maintenance of Programs', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Daily_Activities__c')) ? mapOfTCName.get('Daily_Activities__c') : '', (mapOfTC.containsKey('Daily_Activities__c')) ? mapOfTC.get('Daily_Activities__c') : '', 'Daily Activities', 'Daily_Activities__c', false, false, '', 'Development and Maintenance of Programs', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Equipment__c')) ? mapOfTCName.get('Equipment__c') : '', (mapOfTC.containsKey('Equipment__c')) ? mapOfTC.get('Equipment__c') : '', 'Equipment', 'Equipment__c', false, false, '', 'Development and Maintenance of Programs', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Staff_Development__c')) ? mapOfTCName.get('Staff_Development__c') : '', (mapOfTC.containsKey('Staff_Development__c')) ? mapOfTC.get('Staff_Development__c') : '', 'Staff Development', 'Staff_Development__c', false, false, '', 'Other Responsibilities', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Staff_Training__c')) ? mapOfTCName.get('Staff_Training__c') : '', (mapOfTC.containsKey('Staff_Training__c')) ? mapOfTC.get('Staff_Training__c') : '', 'Staff Training', 'Staff_Training__c', false, false, '', 'Other Responsibilities', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Staff_Orientation__c')) ? mapOfTCName.get('Staff_Orientation__c') : '', (mapOfTC.containsKey('Staff_Orientation__c')) ? mapOfTC.get('Staff_Orientation__c') : '', 'Staff Orientation', 'Staff_Orientation__c', false, false, '', 'Other Responsibilities', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Staff_Supervision__c')) ? mapOfTCName.get('Staff_Supervision__c') : '', (mapOfTC.containsKey('Staff_Supervision__c')) ? mapOfTC.get('Staff_Supervision__c') : '', 'Staff Supervision', 'Staff_Supervision__c', false, false, '', 'Other Responsibilities', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Parent_Involvement__c')) ? mapOfTCName.get('Parent_Involvement__c') : '', (mapOfTC.containsKey('Parent_Involvement__c')) ? mapOfTC.get('Parent_Involvement__c') : '', 'Parent Involvement', 'Parent_Involvement__c', false, false, '', 'Other Responsibilities', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Social_Services__c')) ? mapOfTCName.get('Social_Services__c') : '', (mapOfTC.containsKey('Social_Services__c')) ? mapOfTC.get('Social_Services__c') : '', 'Social Services', 'Social_Services__c', false, false, '', 'Other Responsibilities', false, '', false, ''));
        transactionContactWrapperList.add(new TransactionContactWrapper((mapOfTCName.containsKey('Infant_Toddler_Program__c')) ? mapOfTCName.get('Infant_Toddler_Program__c') : '', (mapOfTC.containsKey('Infant_Toddler_Program__c')) ? mapOfTC.get('Infant_Toddler_Program__c') : '', 'Infant/Toddler Program', 'Infant_Toddler_Program__c', false, false, '', 'Other Responsibilities', false, '', false, ''));
    }
    public class TransactionContactWrapper {
        public String selectedValue                 { get; set; }
        public String selectedContactName           { get; set; }
        public String LabelName                     { get; set; }
        public String APIName                       { get; set; }
        public boolean showCheckboxAndNotes         { get; set; }
        public boolean notApplicable                { get; set; }
        public boolean KindergartennotApplicable    { get; set; }
        public string KindergartenNotes             { get; set; }
        public boolean EarlyEducationnotApplicable  { get; set; }
        public String EarlyEducationNotes           { get; set; }
        public String schoolAgeNotes                { get; set; }
        public String ownershipType                 { get; set; }
        public TransactionContactWrapper(String selectedContactName, String selectedValue, String LabelName, String APIName, Boolean showCheckboxAndNotes, Boolean notApplicable, String schoolAgeNotes, String ownershipType, Boolean KindergartennotApplicable, String KindergartenNotes, Boolean EarlyEducationnotApplicable, String EarlyEducationNotes) {
            this.selectedContactName = selectedContactName;
            this.schoolAgeNotes = schoolAgeNotes;
            this.notApplicable = notApplicable;
            this.KindergartennotApplicable = KindergartennotApplicable;
            this.KindergartenNotes = KindergartenNotes;
            this.EarlyEducationnotApplicable = EarlyEducationnotApplicable;
            this.EarlyEducationNotes = EarlyEducationNotes;
            this.selectedValue = selectedValue;
            this.LabelName = LabelName;
            this.APIName = APIName;
            this.ownershipType = ownershipType;
        }
    }
    public class TransactionDocumentWrapper {
        public Transaction_Document__c document { get; set; }
        //public List<String> fileLinks{get; set;}
        public S3_File__c[] fileAttachments     { get; set; }
        public TransactionDocumentWrapper() {
            document = new Transaction_Document__c();
            //fileLinks = new List<String>();
            fileAttachments = new S3_File__c[]{
            };
        }
    }
    public List<TransactionDocumentWrapper> transactionDocuments         { get; set; }
    public List<TransactionDocumentWrapper> optionalTransactionDocuments { get; set; }
    public Id attachmentId                                               { get; set; }
    private void getAllDocuments() {
        try {
            String ltId = ApexPages.currentPage().getParameters().get('ltId');
            transactionDocuments = new List<TransactionDocumentWrapper>();
            optionalTransactionDocuments = new List<TransactionDocumentWrapper>();
            Set<Id> documentIds = new Set<Id>();
            List<Transaction_Document__c> documents = new List<Transaction_Document__c>();
            for (Transaction_Document__c doc : [
                    SELECT Id, Name, Document__c, Status__c, Document_Type__c, Document_Type__r.Name,
                            Note_For_Revision__c, Mode__c, Transaction_Document_Name__c
                    FROM Transaction_Document__c
                    WHERE Licensing_Transaction__c = :ltId
                    AND Document__c != null AND (Is_Consent_Document__c = false and Is_Tax_Statement_Document__c = false)
                    ORDER BY Is_Required__c DESC, Mode__c
            ]) {
                documentIds.add(doc.Document__c);
                documents.add(doc);
            }
            Map<Id, List<String>> documentFileLinksMap = new Map<Id, List<String>>();
            Map<Id, S3_File__c[]> documentAttachmentMap = new Map<Id, S3_File__c[]>();
            AWSKeys creds = new AWSKeys('eec');
            for (S3_File__c file : [
                    SELECT Id, Document__c, Bucket__c, Prefix__c, Filename__c
                    FROM S3_File__c
                    WHERE Document__c IN :documentIds
            ]) {
                /*if(!documentFileLinksMap.containsKey(file.Document__c)){
                    documentFileLinksMap.put(file.Document__c, new List<String>());
                }*/
                if (!documentAttachmentMap.containsKey(file.Document__c)) {
                    documentAttachmentMap.put(file.Document__c, new S3_File__c[]{
                    });
                }
                /*String filename = (!String.isBlank(file.Prefix__c) ? file.Prefix__c + '/' + file.Filename__c : file.Filename__c);
                String url = EEC_S3ComponentCtrl.generateTempS3Url(file.Bucket__c, EncodingUtil.urlEncode(filename, 'UTF-8'), creds);
                documentFileLinksMap.get(file.Document__c).add(url);*/
                documentAttachmentMap.get(file.Document__c).add(file);
            }
            for (Transaction_Document__c doc : documents) {
                TransactionDocumentWrapper temp = new TransactionDocumentWrapper();
                temp.document = doc;
                //temp.fileLinks = documentFileLinksMap.get(doc.Document__c);
                temp.fileAttachments = documentAttachmentMap.get(doc.Document__c);
                if (doc.Mode__c == EEC_Constants.TRANSACTION_DOCUMENT_MODE_ADDITIONAL) {
                    optionalTransactionDocuments.add(temp);
                } else {
                    transactionDocuments.add(temp);
                }
            }
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
        }
    }
    public String generateS3Link() {
        return generateS3Link(attachmentId);
    }
    public String generateS3Link(String fileId) {
        String filename = '';
        S3_File__c file = [Select Id, Filename__c, Prefix__c, Bucket__c From S3_File__c Where Id = :fileId];
        // Get the AWS credentials based on a config value.
        // TODO: Config the name of the aws key.
        AWSKeys creds = new AWSKeys('eec');
        if (!String.isBlank(file.Prefix__c)) {
            filename += file.Prefix__c + '/';
        }
        filename += file.Filename__c;
        return EEC_S3ComponentCtrl.generateTempS3Url(file.Bucket__c, EncodingUtil.urlEncode(filename, 'UTF-8'), creds);
    }
    public List<Transaction_Document__c> transDocList = new List<Transaction_Document__c>();
    public List<Transaction_Document__c> transDocToBeDeleted = new List<Transaction_Document__c>();
    public List<Document__c> docTobeDeleted = new List<Document__c>();
    public void createDocumentRecord(string documentName, boolean isRequired) {
        Date moduLe2NotApplicableDate = date.newinstance(2010, 8, 1);
        Document__c docObj = new Document__c();
        docObj.Document_Name__c = documentName;
        if (documentName == 'FCC Orientation, Module II' && licenseTransation.Provider__r.First_Issue_Date__c <= moduLe2NotApplicableDate) {
            docObj.Not_Applicable__c = true;
        }
        docObj.Provider__c = licenseTransation.Provider__c;
        docObj.Valid_From__c = DateTime.now();
        docObj.Attachment_Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_ATTACHMENT_NO_ATTACHMENT;
        insert docObj;
        Transaction_Document__c transDocObj = new Transaction_Document__c();
        if (isRequired) {
            transDocObj.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_REQUIRED;
            transDocObj.Submit_Transaction_Only_If_Uploaded__c = true;
        } else {
            transDocObj.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_OPTIONAL;
        }
        transDocObj.Transaction_Document_Name__c = documentName;
        transDocObj.Licensing_Transaction__c = licenseTransation.id;
        transDocObj.Last_Status_Date__c = Date.Today();
        transDocObj.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
        transDocObj.Document__c = docObj.id;
        transDocList.add(transDocObj);
    }
    public void createDocumentRecordWithDocumentType(string documentName) {
        List<Document__c> documentTobeInserted = new List<Document__c>();
        for (Document_Type__c docType : [
                SELECT Id,Name,LEAD_Configuration__c,Responsible_Party__c
                FROM Document_Type__c
                WHERE Name Like:documentName
                AND LEAD_Configuration__r.Name = :providerRecordType
                Limit 1
        ]) {
            Document__c docObj = new Document__c();
            docObj.Document_Type__c = docType.Id;
            docObj.Document_Name__c = documentName;
            docObj.LEAD_Configuration__c = docType.LEAD_Configuration__c;
            docObj.Responsible_Party__c = docType.Responsible_Party__c;
            docObj.Status__c = EEC_Constants.DOCUMENT_RESPONSIBLE_PARTY_UNSUBMITTED;
            docObj.Provider__c = licenseTransation.Provider__c;
            docObj.Valid_From__c = DateTime.now();
            docObj.Attachment_Status__c = EEC_Constants.DOCUMENT_NO_ATTACHMENT;
            documentTobeInserted.add(docObj);
        }
        if (documentTobeInserted.size() > 0) {
            insert documentTobeInserted;
        }
        /*
            Transaction_Document__c transDocObj= new Transaction_Document__c();
            if(isRequired){
                transDocObj.Mode__c = 'Required';
                transDocObj.Submit_Transaction_Only_If_Uploaded__c = true;
            }else{
                transDocObj.Mode__c = 'Optional';
            }
            transDocObj.Transaction_Document_Name__c = documentName;
            transDocObj.Licensing_Transaction__c = licenseTransation.id;
            transDocObj.Last_Status_Date__c = Date.Today();
            transDocObj.Status__c =EEC_Constants.DOCUMENT_RESPONSIBLE_PARTY_UNSUBMITTED;
            transDocObj.Document__c = docObj.id;
            transDocList.add(transDocObj); */
    }
    public void deleteLibraryDocumentRecord(string documentName) {
        List<Document__c> libraryDocToBeDeleted = new List<Document__c>();
        for (Document__c doc : [SELECT id,Name,Document_Name__c FROM Document__c WHERE Document_Name__c = :documentName]) {
            libraryDocToBeDeleted.add(doc);
        }
        if (libraryDocToBeDeleted.size() > 0) {
            delete libraryDocToBeDeleted;
        }
    }
    public void deleteDocumentRecord(string documentName) {
        set<id> docIds = new set<Id>();
        for (Transaction_Document__c delTransDoc : [
                SELECT id,Transaction_Document_Name__c,Document__c
                FROM Transaction_Document__c
                WHERE Transaction_Document_Name__c = :documentName
                AND Licensing_Transaction__c = :licenseTransation.id
        ]) {
            transDocToBeDeleted.add(delTransDoc);
            docIds.add(delTransDoc.Document__c);
        }
        for (Document__c doc : [SELECT id,Name FROM Document__c WHERE id IN :docIds]) {
            docTobeDeleted.add(doc);
        }
        if (docTobeDeleted.size() > 0) {
            delete docTobeDeleted;
        }
        if (transDocToBeDeleted.size() > 0) {
            delete transDocToBeDeleted;
        }
    }
    public void createTrainingTransactionDocuments() {
        Set<String> existingDocuments = new Set<String>();
        Set<String> existingLibraryDocuments = new Set<String>();
        for (Transaction_Document__c transactionDocument : [
                Select Id, Transaction_Document_Name__c
                From Transaction_Document__c
                Where Licensing_Transaction__c = :licenseTransation.id
        ]) {
            existingDocuments.add(transactionDocument.Transaction_Document_Name__c);
        }
        for (Document__c document : [
                Select Id, Document_Name__c
                From Document__c
                Where Provider__c = :licenseTransation.Provider__c
        ]) {
            existingLibraryDocuments.add(document.Document_Name__c);
        }
        
        
        if (licenseTransation.Took_Transportation_Training__c == 'Yes' && !existingDocuments.contains('Transportation Safety Training: Look Before You Lock')) {
            createDocumentRecord('Transportation Safety Training: Look Before You Lock', true);
        } else if (licenseTransation.Took_Transportation_Training__c == 'No' && !existingDocuments.contains('Transportation Safety Training: Look Before You Lock')) {
            createDocumentRecord('Transportation Safety Training: Look Before You Lock', false);
        }
        if (licenseTransation.Took_SIDS_Training__c == 'Yes' && !existingDocuments.contains('Reducing the Risk of SIDS in Child Care')) {
            createDocumentRecord('Reducing the Risk of SIDS in Child Care', true);
        } else if (licenseTransation.Took_SIDS_Training__c == 'No' && !existingDocuments.contains('Reducing the Risk of SIDS in Child Care')) {
            createDocumentRecord('Reducing the Risk of SIDS in Child Care', false);
        }
        
        if (licenseTransation.Took_USDA_Nutrition_Training__c == 'Yes' && !existingDocuments.contains('Nutrition and Choking')) {
            createDocumentRecord('Nutrition and Choking', true);
        } else if (licenseTransation.Took_USDA_Nutrition_Training__c == 'No' && !existingDocuments.contains('Nutrition and Choking')) {
            createDocumentRecord('Nutrition and Choking', false);
        }
        
        if (licenseTransation.Took_FCC_Orientation_Module_1__c == 'Yes' && !existingDocuments.contains('FCC Orientation, Module 1')) {
            createDocumentRecord('FCC Orientation, Module 1', true);
        } else if (licenseTransation.Took_FCC_Orientation_Module_1__c == 'No' && !existingDocuments.contains('FCC Orientation, Module 1')) {
            createDocumentRecord('FCC Orientation, Module 1', false);
        }
        if (licenseTransation.Took_Upgrading_Capacity_Training__c == 'Yes' && !existingDocuments.contains('Upgrade Capacity Training and Quiz')) {
            createDocumentRecord('Upgrade Capacity Training and Quiz', true);
        } else if (licenseTransation.Took_Upgrading_Capacity_Training__c == 'No' && !existingDocuments.contains('Upgrade Capacity Training and Quiz')) {
            createDocumentRecord('Upgrade Capacity Training and Quiz', false);
        }
        if (licenseTransation.CPR_Certified__c == 'Yes' && !existingDocuments.contains('CPR')) {
            createDocumentRecord('CPR', true);
        } else if (licenseTransation.CPR_Certified__c == 'No' && !existingDocuments.contains('CPR')) {
            createDocumentRecord('CPR', false); 
        }
        if (licenseTransation.First_Aid_Certified__c == 'Yes' && !existingDocuments.contains('First Aid')) {
            createDocumentRecord('First Aid', true);
        } else if (licenseTransation.First_Aid_Certified__c == 'No' && !existingDocuments.contains('First Aid')) {
            createDocumentRecord('First Aid', false);
        }
        // Informal care 
        if (licenseTransation.Parental_Consent_forms__c == 'Yes' && !existingDocuments.contains('Parental Consent forms')) {
            createDocumentRecord('Parental Consent forms', true);
        } else if (licenseTransation.Parental_Consent_forms__c == 'No' && !existingDocuments.contains('Parental Consent forms')) {
            createDocumentRecord('Parental Consent forms', false);
        }
        
        if (licenseTransation.Drinking_Water_Source__c == 'Private Water Supply' && !existingDocuments.contains('Private Water Supply Evidence') && (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL)) {
            createDocumentRecord('Private Water Supply Evidence', true);
        } else if (licenseTransation.Drinking_Water_Source__c != 'Private Water Supply' && !existingDocuments.contains('Private Water Supply Evidence')) {
            deleteDocumentRecord('Private Water Supply Evidence');
        }
        if (licenseTransation.Added_A_Coal_Pellet_Wood_Burning_Stove__c == 'Yes' && !existingDocuments.contains('Evidence of stove equipment used child care')) {
            createDocumentRecord('Evidence of stove equipment used child care', true);
        } else if (licenseTransation.Drinking_Water_Source__c == 'No' && !existingDocuments.contains('Evidence of stove equipment used child care')) {
            createDocumentRecord('Evidence of stove equipment used child care', false);
        }
        if ((LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL) && !existingDocuments.contains('Medical Letter')) {
            createDocumentRecord('Medical Letter', false);
        }
        if (licenseTransation.Lead_Paint_Compliance__c == 'Yes' && !existingLibraryDocuments.contains('Occupancy Permit')) {
            createDocumentRecordWithDocumentType('Occupancy Permit');
        }
        if (licenseTransation.Transportation_provided1__c == 'Yes' && !existingLibraryDocuments.contains('Transportation Document')) {
            createDocumentRecordWithDocumentType('Transportation Document');
        }
        if (licenseTransation.Transportation__c == 'Program Owned' && !existingLibraryDocuments.contains('Transportation Supplement Form')) {
            createDocumentRecordWithDocumentType('Transportation Supplement Form');
        }
        if (licenseTransation.Transportation__c == 'Program Owned' && !existingLibraryDocuments.contains('Evidence of Insurance')) {
            createDocumentRecordWithDocumentType('Evidence of Insurance');
        }
        if (licenseTransation.Transportation__c == 'Subcontract' && !existingLibraryDocuments.contains('Transportation Contract Agreement')) {
            createDocumentRecordWithDocumentType('Transportation Contract Agreement');
        }
        if (licenseTransation.Lead_Paint_Constructed_before_1978__c == 'Yes' && !existingLibraryDocuments.contains('Detailed lead paint inspection')) {
            createDocumentRecordWithDocumentType('Detailed lead paint inspection');
        }
       
        if (licenseTransation.Are_you_switching_small_to_large_group__c == 'Yes' && !existingLibraryDocuments.contains('Healthcare Policy')) {
            createDocumentRecordWithDocumentType('Healthcare Policy');
        } else if (licenseTransation.Are_you_switching_small_to_large_group__c == 'No' && existingLibraryDocuments.contains('Healthcare Policy')) {
            //deleteLibraryDocumentRecord('Healthcare Policy');
        }
        if (licenseTransation.Are_you_switching_small_to_large_group__c == 'Yes' && !existingLibraryDocuments.contains('Healthcare consultant agreement')) {
            createDocumentRecordWithDocumentType('Healthcare consultant agreement');
        } else if (licenseTransation.Are_you_switching_small_to_large_group__c == 'No' && existingLibraryDocuments.contains('Healthcare consultant agreement')) {
            //deleteLibraryDocumentRecord('Healthcare consultant agreement');
        }
        if (licenseTransation.Are_you_switching_small_to_large_group__c == 'Yes' && !existingLibraryDocuments.contains('Plan for Transitioning Children')) {
            createDocumentRecordWithDocumentType('Plan for Transitioning Children');
        } else if (licenseTransation.Are_you_switching_small_to_large_group__c == 'No' && existingLibraryDocuments.contains('Plan for Transitioning Children')) {
            //deleteLibraryDocumentRecord('Plan for Transitioning Children');
        }
        
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME && !existingDocuments.contains('Proof of name change (Ex: Marriage license, Government issued Id')) {
            createDocumentRecord('Proof of name change (Ex: Marriage license, Government issued Id', true);
        }
        if (transDocList.size() > 0) {
            insert transDocList;
        }
    }
    public void delAttachment() {
        string docId = apexpages.currentpage().getparameters().get('index');
        string tranDocId = apexpages.currentpage().getparameters().get('tranDocId');
        system.debug('docId<<'+docId);
        S3_File__c s3File = [select Id from S3_File__c where Id = :docId];
         system.debug('s3File<<'+s3File);
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        delete s3File;
        Transaction_Document__c transactionDocument = [
                select Id,
                        Document__c, Document__r.Id, Status__c
                from Transaction_Document__c
                where Id = :tranDocId
        ];
        List<S3_File__c> listS3File = [select Id from S3_File__c where Document__c = :transactionDocument.Document__r.Id];
        if (listS3File.size() == 0) {
            transactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
        } else {
            transactionDocument.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_SUBMITTED;
        }
        update transactionDocument;
        getLicensingAdditionalAttachments();
    }
    public void getLeadConfigurationData() {
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        if (String.isNotBlank(ltId) && String.isNotBlank(LicenseRecordTypeLabel)) {
            leadConfiguration = [
                    SELECT Visit_Narrative_Summary_Default__c,Application_Display_Name__c,SystemModstamp, Portal_Transaction_Introduction__c,Attestation_Text__c,
                            Number_of_days_for_Investigation_Visit__c, No_of_Days_Prior_Corr_Action_Deadline__c, No_of_Days_For_Investigation_Due_Date__c, Name,
                            Large_Group_Instruction__c, Investigation__c, Investig_Non_comp_Default_if_Any__c, Follow_up_Visit_Estimated_Deadline__c
                            , Transaction_Submission_Disclaimer__c,Training_Instructions__c,Transaction_Attachments_New__c, Transaction_Attachments_Renewal__c, Transaction_Attachments_Upgrade__c
                    FROM LEAD_Configuration__c
                    WHERE Name = :LicenseRecordTypeLabel
            ];
            licensingTransactionSubmissionDisclaimer = leadConfiguration.Transaction_Submission_Disclaimer__c;
            licensingTrainingInstructions = leadConfiguration.Training_Instructions__c;
            applicationDisplayName = leadConfiguration.Application_Display_Name__c;
            if(LicenseRecordTypeLabel == EEC_Constants.LABEL_LT_CLOSED_FUNDED_PROGRAM){
                 attestation = leadConfiguration.Attestation_Text__c;
            }
        }
        if (String.isNotBlank(ltId)) {
            if (licenseTransation.License_Requested__c == EEC_Constants.LT_LICENSE_REQUESTED_CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT_6
                    || licenseTransation.License_Requested__c == EEC_Constants.LT_LICENSE_REQUESTED_CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT_8
                    || licenseTransation.License_Requested__c == EEC_Constants.LT_LICENSE_REQUESTED_CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT_10) {
                loggedCertifiedContact = true;
            }
        }
    }
    public void doGetCity() {
        List<City__c> listCities = [select Id, Name from City__c where State__c = :licenseTransation.NewUmbrella_State__c order by Name];
        listCity = new List<SelectOption>();
        listCity.add(new SelectOption('--Select--', '--Select--'));
        for (City__c city : listCities) {
            listCity.add(new SelectOption(city.Name, city.Name));
        }
    }
    public PageReference query() {
        try {
            queryResults = new List<Account>();
            errorMessage = '';
            if (String.isBlank(umbrellaName) && String.isBlank(cityName)) {
                errorMessage = 'Enter at least one criteria before you start your search';
                return null;
            }
            if (!String.isBlank(umbrellaName)) {
                umbrellaName = '\'%' + umbrellaName + '%\'';
            }
            if (!String.isBlank(cityName)) {
                cityName = '\'%' + cityName + '%\'';
            }
            queryResults = EEC_ContactRoleUtil.getUmbrellaList(umbrellaName, cityName);
            if (queryResults.size() == 0) {
                errorMessage = 'Based on these criteria, no Umbrella were found. Please review your search criteria.';
            }
        } catch (Exception e) {
            errorMessage = 'An error has occured attempting to get your results. Please try again.';
        }
        return null;
    }
    public PageReference addUmbrella() {
        try {
            licenseTransation.NewUmbrella_City__c = newCityName;
            //licenseTransation = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransation);
            //delete existing umbrellaContact first to avoid multiple umbrella contact creation for same transaction
            if (umbrellaContactId != null) {
                delete [Select Id from Contact Where Id = :umbrellaContactId];
            }
            //create a new contact and contact role and set umbrella created flag to true on licensing transaction
            Contact contact = new Contact();
            contact.FirstName = licenseTransation.NewUmbrella_Director_First_Name__c;
            contact.LastName = licenseTransation.NewUmbrella_Director_Last_Name__c;
            contact.Title = licenseTransation.NewUmbrella_Director_Title__c;
            contact.Email = licenseTransation.NewUmbrella_Director_Email__c;
            contact.Phone = licenseTransation.NewUmbrella_Director_Phone__c;
            contact.AccountId = licenseTransation.Provider__c;
            insert contact;
            if (contact.Id != null) {
                umbrellaContactId = contact.Id;
                Contact_Role__c contactrole = new Contact_Role__c();
                contactrole.Role__c = EEC_Constants.CONTACT_ROLE_DIRECTOR;
                contactrole.contact__c = contact.ID;
                contactrole.Provider__c = contact.AccountID;
                insert contactrole;
                licenseTransation.Is_Umbrella_Contact_Created__c = true;
            }
        } catch (Exception e) {
            errorMessage = 'An error has occured attempting to save new umbrella. Please try again later.';
        }
        return null;
    }
    public void AddLicenseHeld() {
        Id addInfoId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('Other Licenses Held').getRecordTypeId();
        try {
            if (oldHeldLicense != null && oldHeldLicense.id != null) {
                heldLicense.add(new Additional_Information__c(recordTypeId = addInfoId, Name_of_Licensee__c = oldHeldLicense.Name_of_Licensee__c, Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, Type_of_License__c = oldHeldLicense.Type_of_License__c, State_Country_Issuing_the_License__c = oldHeldLicense.State_Country_Issuing_the_License__c, License_Number__c = oldHeldLicense.License_Number__c));
            } else {
                heldLicense.add(new Additional_Information__c(recordTypeId = addInfoId, Name_of_Licensee__c = '', Type_of_License__c = '', Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, State_Country_Issuing_the_License__c = '', License_Number__c = ''));
            }
            if (heldLicense.size() != 0) {
                disableHeld = false;
            }
        } catch (exception e) {
        }
    }
    public boolean disableHeld { get; set; }
    public void DeleteLicenseHeld() {
        if (heldLicense.size() != 0) {
            heldLicense.remove(heldLicense.size() - 1);
        }
        if (heldLicense.size() == 0) {
            disableHeld = true;
        }
    }
    public void checkHeld() {
        heldLicense.clear();
        if (licenseTransation.Out_of_state_childcare_related_licenses1__c == 'Yes') {
            AddLicenseHeld();
        }
    }
    public void AddCriminalAct() {
        Id addCriminId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('Admin/civil/criminal action detail').getRecordTypeId();
        try {
            if (oldCriminalAct != null && oldCriminalAct.id != null) {
                criminalAct.add(new Additional_Information__c(recordTypeId = addCriminId, Name_Admin_civil_criminal_action__c = oldCriminalAct.Name_Admin_civil_criminal_action__c, Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, Nature_of_Proceedings__c = oldCriminalAct.Nature_of_Proceedings__c, Caption__c = oldCriminalAct.Caption__c, Docket_Number__c = oldCriminalAct.Docket_Number__c, Name_of_court_or_administrative_body__c = oldCriminalAct.Name_of_court_or_administrative_body__c, Address_of_court__c = oldCriminalAct.Address_of_court__c, Disposition__c = oldCriminalAct.Disposition__c));
            } else {
                criminalAct.add(new Additional_Information__c(recordTypeId = addCriminId, Name_Admin_civil_criminal_action__c = '', Nature_of_Proceedings__c = '', Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, Caption__c = '', Docket_Number__c = '', Name_of_court_or_administrative_body__c = '', Address_of_court__c = '', Disposition__c = ''));
            }
            if (criminalAct.size() != 0) {
                disableCriminal = false;
            }
        } catch (exception e) {
        }
    }
    public boolean disableCriminal { get; set; }
    public void DeleteCriminalHeld() {
        if (criminalAct.size() != 0) {
            criminalAct.remove(criminalAct.size() - 1);
        }
        if (criminalAct.size() == 0) {
            disableCriminal = true;
        }
    }
    public void checkCriminal() {
        criminalAct.clear();
        if (licenseTransation.Admin_Civil_criminal_action_last_5_yrs1__c == 'Yes') {
            AddCriminalAct();
        }
    }
    public boolean disableFederal { get; set; }
    public void AddFederalInv() {
        Id addFedId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('State/federal investigation detail').getRecordTypeId();
        try {
            if (oldFedralAct != null && oldFedralAct.id != null) {
                federalInv.add(new Additional_Information__c(recordTypeId = addFedId, Name_of_Person_Agency_Investigated__c = oldFedralAct.Name_of_Person_Agency_Investigated__c, Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, State_and_or_Federal_Agency__c = oldFedralAct.State_and_or_Federal_Agency__c, Nature_of_Investigation__c = oldFedralAct.Nature_of_Investigation__c));
            } else {
                federalInv.add(new Additional_Information__c(recordTypeId = addFedId, Name_of_Person_Agency_Investigated__c = '', Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, State_and_or_Federal_Agency__c = '', Nature_of_Investigation__c = ''));
            }
            if (federalInv.size() != 0) {
                disableFederal = false;
            }
        } catch (exception e) {
        }
        /*
        federalInv.add(new Additional_Information__c(recordTypeId = addFedId, Name_of_Person_Agency_Investigated__c = '',Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, State_and_or_Federal_Agency__c = '', Nature_of_Investigation__c = ''));
        if (federalInv.size()!=0) {
            disableFederal = false;
        }*/
    }
    public void DeleteFederalInv() {
        if (federalInv.size() != 0) {
            federalInv.remove(federalInv.size() - 1);
        }
        if (federalInv.size() == 0) {
            disableFederal = true;
        }
    }
    public void checkFederal() {
        federalInv.clear();
        if (licenseTransation.State_Federal_investigation_last_5_yrs1__c == 'Yes') {
            AddFederalInv();
        }
    }
    public boolean disableRelated { get; set; }
    public void AddRelatedLicense() {
        Id addRelatedId = Schema.SObjectType.Additional_Information__c.getRecordTypeInfosByName().get('Other License Applications').getRecordTypeId();
        try {
            if (oldRelatedAct != null && oldRelatedAct.id != null) {
                relatedLicense.add(new Additional_Information__c(recordTypeId = addRelatedId, Name_of_Applicant__c = oldRelatedAct.Name_of_Applicant__c, Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, State_Country_of_Applicant__c = oldRelatedAct.State_Country_of_Applicant__c, Name_of_Licensing_Authority__c = oldRelatedAct.Name_of_Licensing_Authority__c, Address_of_Licensing_authority__c = oldRelatedAct.Address_of_Licensing_authority__c, Phone_No_of_Licensing_Authority__c = oldRelatedAct.Phone_No_of_Licensing_Authority__c, Status_of_Application__c = oldRelatedAct.Status_of_Application__c));
            } else {
                relatedLicense.add(new Additional_Information__c(recordTypeId = addRelatedId, Name_of_Applicant__c = '', Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, State_Country_of_Applicant__c = '', Name_of_Licensing_Authority__c = '', Address_of_Licensing_authority__c = '', Phone_No_of_Licensing_Authority__c = '', Status_of_Application__c = ''));
            }
            if (relatedLicense.size() != 0) {
                disableRelated = false;
            }
        } catch (exception e) {
        }
        /*relatedLicense.add(new Additional_Information__c(recordTypeId = addRelatedId,Name_of_Applicant__c = '',Licensing_Transaction__c = licenseTransation.Id, Provider__c = provider.id, State_Country_of_Applicant__c = '',Name_of_Licensing_Authority__c = '',Address_of_Licensing_authority__c = '', Phone_No_of_Licensing_Authority__c = '',Status_of_Application__c = ''));
        if (relatedLicense.size()!=0) {
            disableRelated = false;
        }*/
    }
    public void DeleteRelatedLicense() {
        if (relatedLicense.size() != 0) {
            relatedLicense.remove(relatedLicense.size() - 1);
        }
        if (relatedLicense.size() == 0) {
            disableRelated = true;
        }
    }
    public void checkRelated() {
        relatedLicense.clear();
        if (licenseTransation.Out_of_state_license_appl_in_process1__c == 'Yes') {
            AddRelatedLicense();
        }
    }
    public void sumCapacity() {
        sumOfCapacities = '' + (
                (licenseTransation.Infant_Capacity__c == null ? 0 : licenseTransation.Infant_Capacity__c) +
                        (licenseTransation.Infant_Toddler_Capacity__c == null ? 0 : licenseTransation.Infant_Toddler_Capacity__c) +
                        (licenseTransation.Toddler_Capacity__c == null ? 0 : licenseTransation.Toddler_Capacity__c) +
                        (licenseTransation.Toddler_Preschool_Capacity__c == null ? 0 : licenseTransation.Toddler_Preschool_Capacity__c) +
                        (licenseTransation.Preschool_Capacity__c == null ? 0 : licenseTransation.Preschool_Capacity__c) +
                        (licenseTransation.Preschool_SA_Capacity__c == null ? 0 : licenseTransation.Preschool_SA_Capacity__c) +
                        (licenseTransation.Kindergarten_Capacity__c == null ? 0 : licenseTransation.Kindergarten_Capacity__c) +
                        (licenseTransation.School_Age_Capacity__c == null ? 0 : licenseTransation.School_Age_Capacity__c) +
                        (licenseTransation.Multi_Age_Group_Capacity__c == null ? 0 : licenseTransation.Multi_Age_Group_Capacity__c)+
                        (licenseTransation.Kindergarten_School_Age__c == null ? 0 : licenseTransation.Kindergarten_School_Age__c));
    }
    public String getRecordTypeJson() {
        return JSON.serialize(recordTypeMap);
    }
    public List<String> getButtonList() {
        List<String> ibwList = new List<String> ();
        Boolean hasNewLicense = false;
        Boolean hasRenewal = false;
        Boolean hasLicenseUpgrade = false;
        Boolean hasChangeOfAddress = false;
        Boolean hasChangeOfRoom = false;
        Boolean hasChangeOfHousehold = false;
        Boolean hasReActivate = false;
        Boolean hasRequestReIssuance = false;
        Boolean hasInActivate = false;
        Boolean hasClosePrior = false;
        Boolean hasAssistantRenewal = false;
        Boolean hasAssistantUpgrade = false;
        Boolean hasAppliedToBecomeCertified = false;
        Boolean hasAssistantNew = false;
        Boolean hasGSANewLicense = false;
        Boolean hasGSARenewal = false;
        Boolean hasGSAMove = false;
        Boolean hasGSATempMove = false;
        Boolean hasGSALicenseChange = false;
        Boolean hasGSAChangeOfAdmin = false;
        Boolean hasResidentialNewLicense = false;
        Boolean hasResidentialRenewal = false;
        Boolean hasResidentialMove = false;
        Boolean hasResidentialLicenseChange = false;
        Boolean hasPlacementNewLicense = false;
        Boolean hasPlacementRenewal = false;
        Boolean hasPlacementMove = false;
        Boolean hasPlacementLicenseChange = false;
        Boolean hasChangeOfProviderName = false;
        Boolean hasRPChangeOfAdmin = false;
        Boolean hasLicenseDowngrade = false;
        Boolean hasVarianceRegulation = false;
        Boolean hasAssistantChangeOfAddress = false;
        Boolean hasEECFCCModification = false;
        Boolean hasEECGSAModification = false;
        Boolean hasEECRPModification = false;
        Boolean hasBrc = false;
        Boolean hasPublicSchool = false;
        Boolean hasPrivateSchool = false;
        Boolean hasOtherEligibleSchool = false;
        Boolean hasContactManagement = false;
        Boolean hasCloseFundedProgram = false;
        Boolean hasLicenseeManagement = false;
        Boolean hasCloseInformalCareProgram = false;
        Boolean hasInformalCareNewProgram = false;
        String ltRecordTypeName;
        if (provider.Licensing_Transactions__r != null) {
            List<Licensing_Transaction__c> lstTrans = [
                    SELECT Ownership_Type__c,Id,New_Name__c,RecordType.DeveloperName, Status__c,Date_Name_Change_is_Effective__c
                    FROM Licensing_Transaction__c
                    WHERE Provider__c = :provider.Id
            ];
            for (Licensing_Transaction__c lt : lstTrans) {
                ltRecordTypeName = lt.RecordType.DeveloperName;
                if (ltRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE && isStatusClosed(lt.Status__c)) {
                    hasNewLicense = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_RENEWAL && isStatusClosed(lt.Status__c)) {
                    hasRenewal = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE && isStatusClosed(lt.Status__c)) {
                    hasLicenseUpgrade = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS && isStatusClosed(lt.Status__c)) {
                    hasChangeOfAddress = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL && isStatusClosed(lt.Status__c)) {
                    hasChangeOfRoom = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD && isStatusClosed(lt.Status__c)) {
                    hasChangeOfHousehold = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE && isStatusClosed(lt.Status__c)) {
                    hasReActivate = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE && isStatusClosed(lt.Status__c)) {
                    hasInActivate = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION && isStatusClosed(lt.Status__c)) {
                    hasClosePrior = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_RENEWAL && isStatusClosed(lt.Status__c)) {
                    hasAssistantRenewal = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE && isStatusClosed(lt.Status__c)) {
                    hasAssistantUpgrade = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT && isStatusClosed(lt.Status__c)) {
                    hasAppliedToBecomeCertified = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE && isStatusClosed(lt.Status__c)) {
                    hasAssistantNew = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_CHANGE_OF_ADDRESS && isStatusClosed(lt.Status__c)) {
                    hasAssistantChangeOfAddress = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT && isStatusClosed(lt.Status__c)) {
                    hasRequestReIssuance = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE && isStatusClosed(lt.Status__c)) {
                    hasGSANewLicense = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_GSA_MOVE && isStatusClosed(lt.Status__c)) {
                    hasGSAMove = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE && isStatusClosed(lt.Status__c)) {
                    hasGSATempMove = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_GSA_RENEWAL && isStatusClosed(lt.Status__c)) {
                    hasGSARenewal = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE && isStatusClosed(lt.Status__c)) {
                    hasGSALicenseChange = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY && lt.Status__c == EEC_Constants.LT_UNSUBMITTED) {
                    hasGSAChangeOfAdmin = true;
                } else if ((ltRecordTypeName == EEC_Constants.LT_CHANGE_OF_PROVIDER_NAME || ltRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME) && isStatusClosed(lt.Status__c)) {
                    hasChangeOfProviderName = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE && isStatusClosed(lt.Status__c)) {
                    hasResidentialNewLicense = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE && isStatusClosed(lt.Status__c)) {
                    hasResidentialMove = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL && isStatusClosed(lt.Status__c)) {
                    hasResidentialRenewal = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE && isStatusClosed(lt.Status__c)) {
                    hasResidentialLicenseChange = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE && isStatusClosed(lt.Status__c)) {
                    hasPlacementNewLicense = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE && isStatusClosed(lt.Status__c)) {
                    hasPlacementMove = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL && isStatusClosed(lt.Status__c)) {
                    hasPlacementRenewal = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE && isStatusClosed(lt.Status__c)) {
                    hasPlacementLicenseChange = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY && lt.Status__c == EEC_Constants.LT_UNSUBMITTED) {
                    hasRPChangeOfAdmin = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY && isStatusClosed(lt.Status__c)) {
                    hasLicenseDowngrade = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST && lt.Status__c == EEC_Constants.LT_UNSUBMITTED) {
                    hasVarianceRegulation = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK && isStatusClosed(lt.Status__c)) {
                    hasBrc = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_EEC_FCC_MODIFICATION && isStatusClosed(lt.Status__c)) {
                    hasEECFCCModification = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_EEC_GSA_MODIFICATION&& isStatusClosed(lt.Status__c)) {
                    hasEECGSAModification = true;
                } else if (ltRecordTypeName == EEC_Constants.LT_EEC_RP_MODIFICATION && isStatusClosed(lt.Status__c)) {
                    hasEECRPModification = true;
                }  else if (ltRecordTypeName == EEC_Constants.LT_Contact_Management && isStatusClosed(lt.Status__c)) {
                    hasContactManagement = true;
                } else if(ltRecordTypeName == EEC_Constants.LT_CLOSE_FUNDED_API_NAME && isStatusClosed(lt.Status__c)){
                    hasCloseFundedProgram = true;
                } else if(ltRecordTypeName == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME && isStatusClosed(lt.Status__c)){
                    hasLicenseeManagement = true;
                } else if(ltRecordTypeName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION && isStatusClosed(lt.Status__c)){
                    hasPublicSchool = true;
                } else if(ltRecordTypeName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION && isStatusClosed(lt.Status__c)){
                    hasPrivateSchool = true;
                } else if(ltRecordTypeName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION && isStatusClosed(lt.Status__c)){
                    hasOtherEligibleSchool = true;
                } else if(ltRecordTypeName == EEC_Constants.LT_CLOSE_INFORMAL_CHILD_CARE_API_NAME && isStatusClosed(lt.Status__c)){
                    hasCloseInformalCareProgram = true;
                } else if(ltRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION && isStatusClosed(lt.Status__c)){
                    hasInformalCareNewProgram = true;
                }
            }
        } 
        /*
        cbcRecordTypeMap = new List<String>();
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_EXEMPT_CBC_CARE) {
            if (provider.Funded_Status__c == EEC_Constants.PRO_NOT_FUNDED_STATUS) {
                cbcRecordTypeMap.add(EEC_Constants.LT_APP_CBC_NEW_FUNDING_APPLICATION);
            }
        }
        */
        privateSchoolRecordTypeMap = new List<String>();
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_PRIVATE_SCHOOL) {
            if (provider.Funded_Status__c == EEC_Constants.PRO_NOT_FUNDED_STATUS && !hasPrivateSchool) {
                privateSchoolRecordTypeMap.add(EEC_Constants.LABEL_LT_PRIVATE_SCHOOL_NEW_FUNDING_APPLICATION);
            }
             if( (provider.Funded_Provider_Status__c != EEC_Constants.PRO_STATUS_CLOSED) && !hasCloseFundedProgram){
                privateSchoolRecordTypeMap.add(EEC_Constants.LABEL_LT_CLOSED_FUNDED_PROGRAM);
            }
        }
        publicSchoolRecordTypeMap = new List<String>();
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_PUBLIC_SCHOOL) {
            if (provider.Funded_Status__c == EEC_Constants.PRO_NOT_FUNDED_STATUS && !hasPublicSchool) {
                publicSchoolRecordTypeMap.add(EEC_Constants.LABEL_LT_PUBLIC_SCHOOL_NEW_FUNDING_APPLICATION);
            }
            if( (provider.Funded_Provider_Status__c != EEC_Constants.PRO_STATUS_CLOSED) && !hasCloseFundedProgram){
                publicSchoolRecordTypeMap.add(EEC_Constants.LABEL_LT_CLOSED_FUNDED_PROGRAM);
            }
        }
        otherEligibleProvidersRecordTypeMap = new List<String>();
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER) {
            if (provider.Funded_Status__c == EEC_Constants.PRO_NOT_FUNDED_STATUS && !hasOtherEligibleSchool) {
                otherEligibleProvidersRecordTypeMap.add(EEC_Constants.LABEL_LT_OTHER_ELIGIBLE_PROVIDERS_NEW_FUNDING_APPLICATION);
            }
            if( (provider.Funded_Provider_Status__c != EEC_Constants.PRO_STATUS_CLOSED) && !hasCloseFundedProgram){
                otherEligibleProvidersRecordTypeMap.add(EEC_Constants.LABEL_LT_CLOSED_FUNDED_PROGRAM);
            }
        }
        summerCampRecordTypeMap = new List<String>();
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_SUMMER_CAMP) {
            if (provider.Funded_Status__c == EEC_Constants.PRO_NOT_FUNDED_STATUS) {
                summerCampRecordTypeMap.add(EEC_Constants.LT_APP_SUMMER_CAMP_NEW_FUNDING_APPLICATION);
            }
            if (provider.Funded_Status__c == EEC_Constants.PRO_NOT_FUNDED_STATUS) {
            }
        }
        informalCareRecordTypeMap = new List<String>();
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
            if (provider.Funded_Status__c == EEC_Constants.PRO_NOT_FUNDED_STATUS && !hasInformalCareNewProgram) {
              //  informalCareRecordTypeMap.add(EEC_Constants.LT_APP_INFORMAL_CAMP_NEW_FUNDING_APPLICATION);
            }
             if( (provider.Funded_Provider_Status__c != EEC_Constants.PRO_STATUS_CLOSED) && !hasCloseInformalCareProgram){
              //  informalCareRecordTypeMap.add(EEC_Constants.LABEL_LT_CLOSED_INFORMAL_CHILD_CARE_PROGRAM);
            }
        }
        gsaRecordTypeMap = new List<String>();
        if (provider.Is_GSA__c || provider.Is_R_P__c) {
            if (provider.License_Status__c != EEC_Constants.PRO_LICENSED && !hasGSANewLicense && !hasResidentialNewLicense && !hasPlacementNewLicense) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_NEW_APPLICATION);
            }
            if ((provider.Renewal_date__c != null && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.License_Type__c != null && ((provider.Renewal_date__c.addDays(-120) <= Date.Today() && provider.Renewal_date__c.addDays(120) >= Date.Today()) || provider.Provider_Status__c == 'Expired')) && !hasGSARenewal && !hasPlacementRenewal && !hasResidentialRenewal) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_RENEWAL);
            }
            /* else if(provider.Renewal_date__c != null && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.License_Type__c != null && (provider.Renewal_date__c.addDays(120) > Date.Today()) && !hasGSARenewal && !hasPlacementRenewal && !hasResidentialRenewal){
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_RENEWAL);
            } */
            /* 365  if(provider.Renewal_date__c != null && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.License_Type__c != null  && (provider.Renewal_date__c.addDays(120) >= Date.Today() || provider.Renewal_date__c.addDays(-120) <= Date.Today()) && !hasGSARenewal && !hasPlacementRenewal && !hasResidentialRenewal){
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_RENEWAL);
            }*/
            /* if(provider.Renewal_date__c != null && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.License_Type__c != null  && (provider.Renewal_date__c.addDays(150) >= Date.Today() && provider.Renewal_date__c.addDays(-150) <= Date.Today()) && !hasGSARenewal && !hasPlacementRenewal && !hasResidentialRenewal){
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_RENEWAL);
            } */
            if (provider.Is_R_P__c && provider.Is_Placement__c && provider.License_Type__c != null && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasPlacementRenewal && !hasPlacementLicenseChange && !hasPlacementMove) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_LICENSE_CHANGE);
            } else if (provider.Is_R_P__c && provider.Is_Residential__c && provider.License_Type__c != null && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && !hasResidentialRenewal && !hasResidentialMove && !hasResidentialLicenseChange) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_LICENSE_CHANGE);
            } else if (provider.Is_GSA__c && provider.License_Type__c != null && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasGSALicenseChange) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_LICENSE_CHANGE);
            }
            if (provider.License_Type__c != null && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasGSARenewal && !hasGSAMove && !hasGSATempMove && !hasGSALicenseChange && !hasPlacementRenewal && !hasPlacementMove && !hasPlacementLicenseChange && !hasResidentialRenewal && !hasResidentialLicenseChange && !hasResidentialMove) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_MOVE);
            }
            if (provider.Is_GSA__c && provider.License_Type__c != null && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasGSAMove && !hasGSATempMove) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_APPLY_FOR_TEMPORARY_MOVE);
            }
            if (provider.Is_GSA__c && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && !hasGSAChangeOfAdmin && !hasGSAMove && !hasGSALicenseChange) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_DESIGNATION_OF_ADMINISTRATIVE_AUTHORITY);
            }
            if (provider.Is_R_P__c && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && !hasRPChangeOfAdmin && !hasResidentialMove && !hasResidentialLicenseChange && !hasPlacementMove && !hasPlacementLicenseChange) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_REPORT_CHANGE_IN_OWNERSHIP_ADMINISTRATIVE_DESIGNEE);
            }
            if (provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && !hasChangeOfProviderName) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_REPORT_CHANGE_IN_PROVIDER_NAME);
            }
            if (provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Provider_Status__c != EEC_Constants.PROVIDER_STATUS_INACTIVE && !hasRequestReIssuance) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_REQUEST_RE_ISSUANCE_OF_LICENSE);
            }
            if (provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasClosePrior) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_INTEND_TO_CLOSE_PROGRAM);
            }
            if (provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasBrc && isInternalUser) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_BACKGROUND_RECORD_CHECK);
            }
            if (provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasEECGSAModification && isInternalUser && (provider.Recordtype.DeveloperName == EEC_Constants.PRO_LARGE_GROUP || provider.Recordtype.DeveloperName == EEC_Constants.PRO_SMALL_GROUP)) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_EEC_GSA_MODIFICATION);
            }
            if (provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasEECRPModification && isInternalUser && provider.Recordtype.DeveloperName == EEC_Constants.PRO_GROUP_CARE) {
                gsaRecordTypeMap.add(EEC_Constants.LT_APP_EEC_RP_MODIFICATION);
            }
            if (provider.License_Status__c == EEC_Constants.PRO_LICENSED && (provider.Recordtype.DeveloperName == EEC_Constants.PRO_LARGE_GROUP || provider.Recordtype.DeveloperName == EEC_Constants.PRO_SMALL_GROUP) && !hasLicenseeManagement) {
                gsaRecordTypeMap.add(EEC_Constants.LABEL_LT_APP_EEC_LICENSEE_MANAGEMENT);
            }
            gsaRecordTypeMap.add('Cancel');
        }
        /*Only if Provider.Record_Type = "Family Child Care" and (First Issue Date is NULL OR Expiration Date + 150 days <= Today) and
        there is no other New License Transaction "Non Submitted", "Submitted" or "Under Review" (=> not Cancelled)*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c != EEC_Constants.PRO_LICENSED && ((provider.Closed_Date__c != null && provider.Closed_Date__c < Date.Today().addDays(-180)) || provider.Closed_Date__c == null) && !hasNewLicense) {
            ibwList.add(EEC_Constants.LT_APP_NEW_APPLICATION);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and (Today - 150 days <= Expiration Date <= Today + 150 days) and
        there is no other Renewal License Transaction with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && (((provider.renewal_date__c != null && provider.License_Status__c == EEC_Constants.PRO_LICENSED && (provider.Renewal_date__c.addDays(-120) <= Date.Today() && provider.Renewal_date__c.addDays(120) >= Date.Today())) || (provider.License_Status__c != EEC_Constants.PRO_LICENSED && provider.Closed_Date__c != null && provider.Closed_Date__c < Date.Today() && provider.Closed_Date__c > Date.Today().addDays(-180))) || provider.Provider_Status__c == 'Expired') && !hasRenewal) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_FOR_RENEWAL);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        there is no other Renewal License Transaction / License Upgrade Transaction with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Capacity__c != null && (provider.Capacity__c.contains('6') || provider.Capacity__c.contains('8')) && (!hasRenewal && !hasLicenseUpgrade)) {
            ibwList.add('Apply for an Upgrade');
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        there is no other Renewal License Transaction / License Upgrade / Change of Address Transaction with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c == EEC_Constants.PRO_LICENSED && (!hasLicenseUpgrade && !hasChangeOfAddress)) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_FOR_CHANGE_OF_ADDRESS);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasAssistantChangeOfAddress) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_FOR_CHANGE_OF_ADDRESS);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        there is no other Renewal License Transaction / License Upgrade / Change of Address Transaction with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled) */
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c == EEC_Constants.PRO_LICENSED && (!hasRenewal && !hasLicenseUpgrade && !hasChangeOfAddress && !hasChangeOfRoom)) {
            ibwList.add(EEC_Constants.LT_APP_CHANGE_OF_LICENSED_ROOM);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        there is no other Renewal License Transaction / License Upgrade / Change in Household with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c == EEC_Constants.PRO_LICENSED && (!hasRenewal && !hasLicenseUpgrade && !hasChangeOfHousehold)) {
            ibwList.add(EEC_Constants.LT_APP_CHANGE_OF_HOUSEHOLD_MEMBER_INDIVISUALS_REGULARLY);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed*/
        if ((provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC || isFccAssistant) && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasRequestReIssuance) {
            ibwList.add(EEC_Constants.LT_APP_REQUEST_RE_ISSUANCE_OF_LICENSE);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        Provider Status = Inactive  and there is no other Re-Activate License transactions with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)*/
        if ((provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC || isFccAssistant) && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Regulatory_Status__c == EEC_Constants.PROVIDER_REGULATORY_STATUS_INACTIVE && !hasReActivate) {
            ibwList.add(EEC_Constants.LT_APP_RE_ACTIVATE_LICENSE_CERTIFICATE);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        there is no other De-Activate License transactions with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)  */
        if ((provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC || isFccAssistant) && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Regulatory_Status__c != EEC_Constants.PROVIDER_REGULATORY_STATUS_INACTIVE && !hasInActivate) {
            ibwList.add(EEC_Constants.LT_APP_INACTIVE_LICENSE_CERTIFICATE);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        there is no other Close Prior Expiration transactions with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasClosePrior) {
            ibwList.add(EEC_Constants.LT_APP_INTEND_TO_CLOSE_PROGRAM);
        }
        /*Only if Provider.Record_Type = "Family Child Care" and License Status = Licensed, and
        there is no other FCC Change of Name transactions with status "Non Submitted" or "Submitted" or "Under Review" (=> not Cancelled)*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasChangeOfProviderName) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_FOR_CHANGE_OF_PROVIDER_NAME);
        }
        if ((provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC || provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasBrc && isInternalUser) {
            ibwList.add(EEC_Constants.LT_APP_BACKGROUND_RECORD_CHECK);
        }
        if ((provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC) && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasEECRPModification && isInternalUser) {
            ibwList.add(EEC_Constants.LT_APP_EEC_FCC_MODIFICATION);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasChangeOfProviderName) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_TO_CHANGE_IN_ASSISTANT_NAME);
        }
        /*----- FCC Assistant ------*/
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && provider.License_Status__c != EEC_Constants.PRO_LICENSED && ((provider.Closed_Date__c != null && provider.Closed_Date__c < Date.Today().addDays(-180)) || provider.Closed_Date__c == null) && !hasAssistantNew) {
            ibwList.add(EEC_Constants.LT_APP_NEW_APPLICATION);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasClosePrior) {
            ibwList.add(EEC_Constants.LT_APP_INTEND_TO_CLOSE_PROGRAM);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && (((provider.renewal_date__c != null && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.renewal_date__c >= Date.Today().addDays(-120)) || (provider.License_Status__c != EEC_Constants.PRO_LICENSED && provider.Closed_Date__c != null && provider.Closed_Date__c < Date.Today() && provider.Closed_Date__c > Date.Today().addDays(-180))) || provider.Provider_Status__c == 'Expired') && !hasAssistantRenewal) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_FOR_RENEWAL);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && provider.Allow_New_Application_as_Provider__c && !hasNewLicense) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_TO_BE_LICENSED_FCC_PROVIDER);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && provider.Certified_As__c.contains(EEC_Constants.CERTIFIED_FAMILY_CHILD_CARE_ASSISTANT) && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasAssistantUpgrade && !hasAssistantRenewal) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_TO_UPGRADE_DOWNGRADE_CAPACITY);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT && provider.Certified_As__c == EEC_Constants.CERIFIED_REGULAR_ASSISTANT && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasAppliedToBecomeCertified && !hasAssistantRenewal) {
            ibwList.add(EEC_Constants.LT_APP_APPLY_TO_BECOME_CERTIFIED_ASSISTANT);
        }
        if (provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && provider.License_Status__c == EEC_Constants.PRO_LICENSED && provider.Capacity__c != null && (provider.Capacity__c.contains('7') || provider.Capacity__c.contains('8') || provider.Capacity__c.contains('9') || provider.Capacity__c.contains('10')) && !hasAssistantUpgrade && !hasAssistantRenewal && !hasLicenseDowngrade) {
            ibwList.add(EEC_Constants.LT_APP_FCC_DOWNGRADE_CAPACITY);
        }
        if ((provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC || provider.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT || provider.Is_GSA__c == true || provider.Is_R_P__c == true) && provider.License_Status__c == EEC_Constants.PRO_LICENSED && !hasVarianceRegulation) {
            ibwList.add(EEC_Constants.LT_APP_REQUEST_VARIANCE_ON_REGULATIONS);
        }
        ibwList.add('Cancel');
        system.debug('ibwList ' + ibwList);
        return ibwList;
    }
    public void clearAttachLib() {
        transDoc = new Transaction_Document__c();
        docName = '';
        docId = '';
        renderAttachLib = false;
    }
    public void setDocNameId(String docName, String docId) {
        this.docName = docName;
        this.docId = docId;
    }
    public void addDocument() {
        if (docName != '' && docId != '') {
            transDoc.Document__c = Id.valueof(docId);
            transDoc.Licensing_Transaction__c = Id.valueof(ApexPages.currentPage().getParameters().get('ltId'));
            transDoc.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_ADDITIONAL;
            Boolean apprForUs = Boolean.valueof(ApexPages.currentPage().getParameters().get('apprForUs'));
            if (apprForUs) {
                transDoc.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_REVIEWED;
            } else {
                transDoc.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_NEW_ATTACHEMT;
            }
            insert transDoc;
        }
    }
    //No longer using IFF framework. Qamar
    /*public PageReference callIntakeForms() {
        licenseRecordTypeLabel = ApexPages.currentPage().getParameters().get('buttonLabel');
        if (licenseRecordTypeLabel == 'cancel') {
            PageReference pPage = page.EEC_PortalProviderPage;
            return pPage;
        }
        Intake__c[] intakeForm = [SELECT Id,Name, FormVersion__c FROM Intake__c WHERE
                                  FormVersion__r.Form__r.Name =: gsaRecordType.get(licenseRecordTypeLabel)
                                  AND FormVersion__r.Status__c = 'Published'];
        if(intakeForm.size() > 0){
            PageReference pPage = new PageReference('/iffIntakePage?#/intake/' + intakeForm[0].Id);
            pPage.setRedirect(true);
            return pPage;
        }
        else
            return null;
    }*/
    public void populateUmbrellaInformationFornewLicense() {
        if (provider.Umbrella_Members__c != null) {
            for (Account umbrellaAccount : [
                    SELECT id,Name,Provider_Address_1__c,Business_Name__c,Provider_City__c, Provider_Address_2__c,
                            State__c,Phone,Provider_Zip_Code__c,Fax,Alternate_Phone__c,Provider_Email__c,Provider_City__r.Name, (SELECT id,FirstName,LastName,Email,Phone FROM Contacts WHERE Role__c = :EEC_Constants.CONTACT_LICENSEE)
                    FROM Account
                    WHERE Id = :provider.Umbrella_Members__c
            ]) {
                for (Contact con : umbrellaAccount.Contacts) {
                    if (con.FirstName != null) {
                        licenseTransation.NewUmbrella_Director_First_Name__c = con.FirstName;
                    }
                    if (con.LastName != null) {
                        licenseTransation.NewUmbrella_Director_Last_Name__c = con.LastName;
                    }
                    if (con.Email != null) {
                        licenseTransation.NewUmbrella_Director_Email__c = con.Email;
                    }
                    if (con.Phone != null) {
                        licenseTransation.NewUmbrella_Director_Phone__c = con.Phone;
                    }
                }
                licenseTransation.New_Umbrella_Name__c = umbrellaAccount.Name;
                if (umbrellaAccount.Business_Name__c != null) {
                    licenseTransation.New_Umbrella_Business_Name__c = umbrellaAccount.Business_Name__c;
                }
                if (umbrellaAccount.Provider_Address_1__c != null) {
                    licenseTransation.NewUmbrella_Street_Address_1__c = umbrellaAccount.Provider_Address_1__c;
                }
                if (umbrellaAccount.Provider_Address_2__c != null) {
                    licenseTransation.NewUmbrella_Street_Address_2__c = umbrellaAccount.Provider_Address_2__c;
                }
                if (umbrellaAccount.Provider_Address_2__c != null) {
                    licenseTransation.NewUmbrella_Street_Address_2__c = umbrellaAccount.Provider_Address_2__c;
                }
                if (umbrellaAccount.Provider_City__c != null) {
                    licenseTransation.NewUmbrella_City__c = umbrellaAccount.Provider_City__r.Name;
                }
                if (umbrellaAccount.State__c != null) {
                    licenseTransation.NewUmbrella_State__c = umbrellaAccount.State__c;
                }
                if (umbrellaAccount.Phone != null) {
                    licenseTransation.NewUmbrella_Phone__c = umbrellaAccount.Phone;
                }
                if (umbrellaAccount.Provider_Zip_Code__c != null) {
                    licenseTransation.NewUmbrella_Zip_Code__c = umbrellaAccount.Provider_Zip_Code__c;
                }
                
                if (umbrellaAccount.Alternate_Phone__c != null) {
                    licenseTransation.NewUmbrella_Alternate_Phone__c = umbrellaAccount.Alternate_Phone__c;
                }
                if (umbrellaAccount.Provider_Email__c != null) {
                    licenseTransation.NewUmbrella_Email__c = umbrellaAccount.Provider_Email__c;
                }
            }
        }
    }
    public PageReference callTransaction() {
        licenseRecordTypeLabel = buttonLabel;
        if (licenseRecordTypeLabel == 'cancel') {
          //  PageReference pPage = page.EEC_PortalProviderPage;
           // return pPage;
        }
        if (provider.RecordType.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
            LicenseRecordTypeName = assistantRecordTypeMap.get(licenseRecordTypeLabel);
        } else if (provider.Is_GSA__c || provider.Is_R_P__c) {
            if (licenseRecordTypeLabel == EEC_Constants.LT_APP_NEW_APPLICATION
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
                licenseTransation.License_Type__c = EEC_Constants.PRO_FIRST_PROVISIONAL;
                if (provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP) {
                    
                } else {
                  
                }
            } else if ((licenseRecordTypeLabel == EEC_Constants.LT_APP_NEW_APPLICATION
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_ADOPTION_AGENCY))) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[1];
                licenseTransation.License_Type__c = EEC_Constants.PRO_FIRST_PROVISIONAL;
            } else if ((licenseRecordTypeLabel == EEC_Constants.LT_APP_NEW_APPLICATION
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_GROUP_CARE
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER))) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[2];
                licenseTransation.License_Type__c = EEC_Constants.PRO_FIRST_PROVISIONAL;
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_RENEWAL
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
                licenseTransation.Renewal_Type__c = EEC_Constants.LT_APP_PROVISIONAL_TO_REGULAR;
                licenseTransation.License_Type__c = EEC_Constants.PRO_REGULAR;
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_RENEWAL
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_ADOPTION_AGENCY)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[1];
                licenseTransation.Renewal_Type__c = EEC_Constants.LT_APP_PROVISIONAL_TO_REGULAR;
                licenseTransation.License_Type__c = EEC_Constants.PRO_REGULAR;
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_RENEWAL
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_GROUP_CARE
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[2];
                licenseTransation.Renewal_Type__c = EEC_Constants.LT_APP_PROVISIONAL_TO_REGULAR;
                licenseTransation.License_Type__c = EEC_Constants.PRO_REGULAR;
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_RENEWAL
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
                licenseTransation.Renewal_Type__c = EEC_Constants.LT_RENEWAL_TYPE_RENEWAL;
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_RENEWAL
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_ADOPTION_AGENCY)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[1];
                licenseTransation.Renewal_Type__c = EEC_Constants.LT_RENEWAL_TYPE_RENEWAL;
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_RENEWAL
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_GROUP_CARE
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[2];
                licenseTransation.Renewal_Type__c = EEC_Constants.LT_RENEWAL_TYPE_RENEWAL;
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_MOVE
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_TEMPORARY_MOVE
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_MOVE
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_ADOPTION_AGENCY)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[1];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_MOVE
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_GROUP_CARE
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER)) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[2];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_LICENSE_CHANGE && provider.Is_Residential__c && provider.Is_R_P__c) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[2];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_LICENSE_CHANGE && provider.Is_Placement__c && provider.Is_R_P__c) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[1];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_APPLY_FOR_LICENSE_CHANGE) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_BACKGROUND_RECORD_CHECK) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_EEC_GSA_MODIFICATION
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP
                    || provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP) && !provider.Is_R_P__c) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
            } else if (licenseRecordTypeLabel == EEC_Constants.LT_APP_EEC_RP_MODIFICATION
                    && (provider.RecordType.DeveloperName == EEC_Constants.PRO_GROUP_CARE) && provider.Is_R_P__c) {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel).split(',')[0];
            } else {
                LicenseRecordTypeName = gsaRecordType.get(licenseRecordTypeLabel);
            }
        } else if (provider.RecordType.DeveloperName == EEC_Constants.PRO_EXEMPT_CBC_CARE) {
            LicenseRecordTypeName = cbcRecordType.get(licenseRecordTypeLabel);
        }else if (provider.RecordType.DeveloperName == EEC_Constants.PRO_PRIVATE_SCHOOL) {
            LicenseRecordTypeName = privateSchoolRecordType.get(licenseRecordTypeLabel);
        }else if (provider.RecordType.DeveloperName == EEC_Constants.PRO_PUBLIC_SCHOOL) {
            LicenseRecordTypeName = publicSchoolRecordType.get(licenseRecordTypeLabel);
        }else if (provider.RecordType.DeveloperName == EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER) {
            LicenseRecordTypeName = otherEligibleProvidersRecordType.get(licenseRecordTypeLabel);
        } /*else if (provider.RecordType.DeveloperName == EEC_Constants.PRO_SUMMER_CAMP) {
            LicenseRecordTypeName = summerCampRecordType.get(licenseRecordTypeLabel);
        } */ else if (provider.RecordType.DeveloperName == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
         //  LicenseRecordTypeName = informalCareRecordType.get(licenseRecordTypeLabel);
        } else {
            LicenseRecordTypeName = recordTypeMap.get(licenseRecordTypeLabel);
        }
        if (String.isblank(licenseTransation.Provider__c)) {
            licenseTransation.Provider__c = provider.Id;
        }
       // system.assert(false,EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + LicenseRecordTypeName).Id);
       // system.assert(false,privateSchoolRecordType);
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INSTRUCTION;
        licenseTransation.Status__c = EEC_Constants.LT_UNSUBMITTED;
        //check added by LD to fix the FLOW error
        if (LicenseRecordTypeName != null) {
            licenseTransation.RecordTypeId = EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + LicenseRecordTypeName).Id;
        }
        If (licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_NEW_LICENSE).Id) {
            licenseTransation.License_Requested__c = '6';
        }
        if (licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE).Id) {
            licenseTransation.Ownership_Type__c = provider.Type_of_Ownership__c;
        }
        if ((licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_RENEWAL).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_GSA_RENEWAL).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_ASSISTANT_RENEWAL).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_PLACEMENT_RENEWAL).Id)
                && provider.Renewal_date__c != null) {
            Date expitrationDate = provider.Renewal_date__c;
            expitrationDate = expitrationDate.addDays(1);
            licenseTransation.License_Issue_Date__c = expitrationDate;
        }
        Integer numberOfDaysLeft;
        if ((provider.Renewal_date__c != null && licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_RENEWAL).Id)) {
            numberOfDaysLeft = Date.Today().daysBetween(provider.Renewal_date__c);
            if (numberOfDaysLeft <= 30) {
                licenseTransation.Delayed_renewal_Application__c = true;
            }
        }
        if (provider.License_Status__c == EEC_Constants.PRO_NOT_LICENSED && provider.Provider_Status__c == EEC_Constants.PRO_CLOSED
                && (licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_GSA_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_PLACEMENT_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE).Id)) {
            licenseTransation.Reopen__c = true;
        }
        if (licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_GSA_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_PLACEMENT_NEW_LICENSE).Id
                 || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION).Id ) {
            populateUmbrellaInformationFornewLicense();
        }
        if (isInternalUser) {
            licenseTransation.Created_by_EEC__c = true;
        }
        upsert licenseTransation;
        string ltRecordTypeLabel;
        list<Account> providerStatusChange = new list<Account>();
        for (Licensing_Transaction__c trans : [
                SELECT id,Provider__r.Renewal_date__c,CreatedDate,Delayed_renewal_Application__c
                FROM Licensing_Transaction__c
                WHERE id = :licenseTransation.id
        ]) {
            ltRecordTypeLabel = trans.RecordType.Name;
        }
        for (Account accStatus : [
                SELECT id,Provider_Status__c,Closed_Status_Reason__c
                FROM Account
                WHERE id = :licenseTransation.provider__c
        ]) {
            if ((accStatus.Provider_Status__c == EEC_Constants.PRO_CLOSED || accStatus.Provider_Status__c == EEC_Constants.PRO_STATUS_APPLICATION_WITHDRAWN_CLOSED) && accStatus.Closed_Status_Reason__c == EEC_Constants.PRO_STATUS_NEW_APPLICATION_IN_PROGRESS) {
                accStatus.Provider_Status__c = EEC_Constants.PRO_STATUS_NEW_APPLICATION_IN_PROGRESS;
                accStatus.Closed_Status_Reason__c = '';
                providerStatusChange.add(accStatus);
            }
        }
        if (providerStatusChange != null) {
            update providerStatusChange;
        }
        If (licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_LICENSE_UPGRADE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_CHANGE_OF_ADDRESS).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_RENEWAL).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE).Id
                || licenseTransation.RecordTypeId == EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + EEC_Constants.LT_FCC_ASSISTANT_RENEWAL).Id) {
        }
        createTaxCertificationTransactionDocument(ltRecordTypeLabel);
        PageReference pPage;
        /*if(licenseRecordTypeLabel == EEC_Constants.LT_APP_REQUEST_VARIANCE_ON_REGULATIONS){
            pPage = Page.EEC_TechnicalAssistance;
        }
        else{*/
        pPage = Page.EEC_TransactionInstructions;
        //}
        pPage.getParameters().put('ltId', licenseTransation.Id);
        if (String.isNotBlank(memberId))
            pPage.getParameters().put('member', memberId);
        pPage.setRedirect(true);
        return pPage;
    }
    /*
    Method   : createTransactionDocumentAndDocument
    @Param   : None
    @purpose : create Transaction Documnets for Licensee
    */
    public List<Transaction_Document__c> transDocListToInsert = new List<Transaction_Document__c>();
    public void createTransactionDocumentAndDocument() {
        Set<String> existingDocuments = new Set<String>();
        for (Transaction_Document__c transactionDocument : [
                Select Id, Transaction_Document_Name__c
                From Transaction_Document__c
                Where Licensing_Transaction__c = :licenseTransation.id
        ]) {
            existingDocuments.add(transactionDocument.Transaction_Document_Name__c);
        }
        if (licenseTransation.Provider__c != null) {
            if (!existingDocuments.contains('Notarize Consent Form - ' + provider.Name)) {
                createDocumentRecordForProvider('Notarize Consent Form - ' + provider.Name);
            }
            if (transDocListToInsert.size() > 0) {
                insert transDocListToInsert;
            }
        }
    }
    public void createTaxCertificationTransactionDocument(String recordTypelabel) {
        transDocListToInsert.clear();
        Set<String> existingDocuments = new Set<String>();
        List<Lead_Configuration__c> leadList = new List<Lead_Configuration__c>();
        if (String.isNotBlank(LicenseRecordTypeLabel)) {
            for (Lead_Configuration__c lead : [Select id,Tax_Certification_Statement_Needed__c,Name FROM Lead_Configuration__c Where Name = :recordTypelabel]) {
                leadList.add(lead);
            }
            for (Transaction_Document__c transactionDocument : [
                    Select Id, Transaction_Document_Name__c
                    From Transaction_Document__c
                    Where Licensing_Transaction__c = :licenseTransation.id
            ]) {
                existingDocuments.add(transactionDocument.Transaction_Document_Name__c);
            }
            if (licenseTransation.Provider__c != null && leadList.size() > 0 ) {
                if (leadList[0].Tax_Certification_Statement_Needed__c == true && !existingDocuments.contains('Tax Certification Statement')) {
                    createDocumentRecordForProvider('Tax Certification Statement');
                }
                if (transDocListToInsert.size() > 0) {
                    insert transDocListToInsert;
                }
            }
        }
    }
    public void createDocumentRecordForProvider(string documentName) {
        Document__c docObj = new Document__c();
        docObj.Provider__c = licenseTransation.Provider__c;
        docObj.Valid_From__c = DateTime.now();
        docObj.Attachment_Status__c = EEC_Constants.DOCUMENT_NO_ATTACHMENT;
        insert docObj;
        Transaction_Document__c transDocObj = new Transaction_Document__c();
        transDocObj.Mode__c = EEC_Constants.TRANSACTION_DOCUMENT_MODE_REQUIRED;
        transDocObj.Transaction_Document_Name__c = documentName;
        if (transDocObj.Transaction_Document_Name__c == 'Tax Certification Statement') {
            transDocObj.Is_Tax_Statement_Document__c = true;
        } else {
            transDocObj.Is_Consent_Document__c = true;
        }
        transDocObj.Licensing_Transaction__c = licenseTransation.id;
        transDocObj.Last_Status_Date__c = Date.Today();
        transDocObj.Status__c = EEC_Constants.TRANSACTION_DOCUMENT_STATUS_UNSUBMITTED;
        transDocObj.Document__c = docObj.id;
        transDocListToInsert.add(transDocObj);
    }
    
    public Pagereference previousInstruction() {
        return Page.EEC_TransactionIntroduction;
    }
    Public void addMemberIDPageParameter(PageReference pPage, Boolean encrypt) {
        if (String.isNotBlank(memberId)) {
            pPage.getParameters().put('member', memberId);
        }
    }
    public Pagereference submitInstruction() {
        if (licenseTransation.Provider__c == null) {
            licenseTransation.Provider__c = provider.Id;
        }
       
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            //check added by LD to fix the FLOW error
            if (loggedUser != null) {
                licenseTransation.Submitter__c = Userinfo.getUserId();
            }
            licenseTransation.Status__c = EEC_Constants.LT_SUBMITTED;
        }
        //check added by LD to fix the FLOW error
        if (LicenseRecordTypeName != null) {
            licenseTransation.RecordTypeId = EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + LicenseRecordTypeName).Id;
        }
        upsert licenseTransation;
        PageReference pPage;
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY) {
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
               // pPage = page.EEC_ViewTransaction;
               // pPage.getParameters().put('ltId', licenseTransation.Id);
            }
        } else {
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                pPage = page.EEC_PortalProviderPage;
            }
        }
        if (pPage != null) {
            addMemberIDPageParameter(pPage, false);
        }
        return null;
    }
    public Pagereference nextInstruction() {
        if (String.isblank(licenseTransation.Provider__c)) {
            licenseTransation.Provider__c = provider.Id;
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_PROVIDER_NAME
                || LicenseRecordTypeName == EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION
                || LicenseRecordTypeName == EEC_Constants.LT_CLOSE_INFORMAL_CHILD_CARE_API_NAME
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE
                || LicenseRecordTypeName == EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK 
                   || LicenseRecordTypeName == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME) {
            if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC)) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT)) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
            } else {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OWNERSHIP_ADMINISTRATOR_INFO;
            }
        } else if(LicenseRecordTypeName == EEC_Constants.LT_CLOSE_FUNDED_API_NAME) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CLOSE_FUNDING_INFO;
        } else {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
        }
        licenseTransation.Status__c = EEC_Constants.LT_UNSUBMITTED;
        licenseTransation.RecordTypeId = EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.' + LicenseRecordTypeName).Id;
        if (!isSubmitted) {
            if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME && (transactionContact.Role__c == EEC_Constants.TC_ROLE_LICENSEE || transactionContact.Role__c == EEC_Constants.TC_ROLE_ASSISTANT)) {
                update transactionContact;
            }
            upsert licenseTransation;
            createTrainingTransactionDocuments();
        }
        licenseTransation = [
                SELECT Ownership_Type__c, Provider__r.License_Type__c, Id, name, Date_Taken_Intro_EEC_in_MA_orientation__c, IsProviderUpgrade__c, IsAssistantUpgradeToCertified__c, Last_Reached_Step__c, RecordTypeId, Provider__c,
                        License_Requested__c, New_Street_Address_1__c, New_Street_Address_2__c,Previous_Street_Address_1__c,Previous_Street_Address_2__c,Previous_City__c,Previous_Zip_Code__c, Previous_City__r.Name, Previous_State__c,
                        Provide_Extended_Days1__c,Extended_Days_Available_Option_2__c,Extended_Days_Available__c,Gym_Facility_Used_During_Program_Hours1__c,Drop_in_Service1__c,Drop_in_Service_Description__c,Gym_Facility_Used_in_Program_Hours_Desc__c,Cafeteria_Used_During_Program_Hours_Desc__c,Summer_Camp_Service_Description__c,Evenings_Service_Description__c,Summer_Camp_Service1__c,
                        Start_Time_Afternoon_program__c,End_Time_Afternoon_program__c,Available_Days_Afternoon_program__c,Available_Days_Full_day_program__c,Start_Time_Morning_program__c,End_Time_Morning_program__c,Available_Days_Morning_program__c,Start_Time_Full_day_program__c,End_Time_Full_day_program__c,New_City__c,New_Name__c,New_City__r.Name, New_Zip_Code__c, Live_at_New_Address__c, Moving_Date__c, Date_Care_Resumes__c, New_Address_Phone_Number__c,
                        Completed_30_hours_of_Training__c,Plan_for_training_completion__c,Plan_for_diverse_learners_training__c,Address_diverse_learners_hours__c,Evening_Overnight_Weekend_Care__c, Children_Home_Schooled__c, Children_Home_Schooled_Description__c,Date_Name_Change_is_Effective__c,
                        ProgramLicensedOrApproved__c,ProgramContracted__c,Infant_Capacity__c,Operation_Type__c,Small_Group_Capacity__c,Infant_Toddler_Capacity__c,Toddler_Capacity__c,Toddler_Preschool_Capacity__c,Preschool_Capacity__c,Preschool_SA_Capacity__c,
                        Kindergarten_Capacity__c,School_Age_Capacity__c,Multi_Age_Group_Capacity__c,Kindergarten_School_Age__c,Total_License_Capacity_Requested__c,Minimum_Age_Limit_Requested_Years__c,Provider__r.Type_of_Ownership__c,
                        Minimum_Age_Limit_Requested_Months__c,Maximum_Age_Limit_Requested_Months__c,Maximum_Age_Limit_Requested_Years__c,Existing_Fiduciary_Admin_relationships1__c,
                        Becoming_Foster_Care_Provider__c,
                        Business_Operated_Out_of_Own_Home__c, Bus_Operated_Out_of_Own_Home_Descrip__c,
                        Previous_Involvement_with_EEC_for_Unlice__c,Daily_Routine_and_Activities__c,Previous_Involvement_with_EEC__c, Previous_Application_Certif_with_EEC__c, Prev_App_Certif_with_EEC_Descrip__c, Prev_App_Certif_with_Another_State__c,
                        Prev_App_Certif_with_Another_State_Desc__c, Certificate_of_License_Revoked_Suspend__c, Certificate_or_License_Surrendered__c, Revocation_Suspension_Surrender_Reas__c,Surrendered_Certificate_License__c,
                        Is_this_an_indoor_pool__c,Are_you_adding_space__c,Do_you_have_a_pool__c,Pool_Inspection_Date__c,Child_Emergency_Injury_Last_3_Years__c, Child_Emerg_Injury_Last_3_Years_Descrip__c, Charged_or_Arrested_for_Crime__c, Charges_Description__c, Dealings_with_Child_Prot_Child_Welfar__c,
                        Dealing_with_Child_Prot_Welfar_Descri__c, Registering_as_Sex_Offender__c, Sex_Offender_Nature_of_Incident__c, Restraining_Order_Issued__c,
                        Experience_Caring_for_Children_QUalifica__c,Alcoholic_Bev_Narcotics_Drugs_Desc__c, Abused_or_neglected_a_child__c, Abused_or_neglected_a_child_Description__c, Caring_for_your_own_children_Years__c, Caring_for_your_own_children_Months__c, Caring_for_your_own_children_Hrs_Week__c, Caring_Other_People_Children_End_Date__c, Caring_Other_People_Children_Start_Date__c,  Submitter__r.Name, Assigned_User_Email__c,
                        New_Umbrella_Name__c,providerRecordTypeDeveloperName__c,
                        Provider__r.Capacity__c,Mailing_City__c,
                        New_Umbrella_Business_Name__c,Mailing_State__c,
                        NewUmbrella_Place_of_Incorporation__c,Mailing_Street__c,
                        NewUmbrella_Date_of_Incorporation__c,Mailing_Zip__c,Do_you_live_at_this_address__c,
                        NewUmbrella_Street_Address_1__c,
                        NewUmbrella_Street_Address_2__c,
                        NewUmbrella_State__c,
                        NewUmbrella_City__c,
                        NewUmbrella_Zip_Code__c,
                        NewUmbrella_Phone__c,
                        NewUmbrella_Alternate_Phone__c,
                        NewUmbrella_Email__c,
                        NewUmbrella_Director_First_Name__c,
                        NewUmbrella_Director_Last_Name__c,
                        NewUmbrella_Director_Title__c,
                        NewUmbrella_Director_Phone__c,
                        NewUmbrella_Director_Email__c,
                        Transaction_Configuration__r.EEC_Licensing_Transaction_Instructions__c,
                        Do_you_hold_any_other_EEC_licenses__c,
                        Challenges_in_Compliance_Requirement_Oth__c,Challenges_in_BRC_requirements__c,
                        Certificate_of_Eligibility_for_Funding__c,
                     
                        Types_of_support_most_help__c,Challenges_in_Compliance_Requirements__c,
                       Challenges_in_BRC_requirement_Other_Reas__c,
                        Challenges_in_Certificate_of_Eligibility__c
                from Licensing_Transaction__c
                where Id = :licenseTransation.Id
        ];
        PageReference pPage;
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY) {
            if ((LicenseRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE) && licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT)) {
                pPage = Page.EEC_ReviewSummarySubmissionAssistant;
            } else {
                pPage = Page.EEC_ReviewSummarySubmission;
            }
        } else if (LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK 
                    || LicenseRecordTypeName == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME) {
            if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC)) {
                pPage = Page.EEC_HouseHoldMembers;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT)) {
                pPage = Page.EEC_TransactionProvider;
            } else {
                pPage = Page.EEC_ownershipadministratorinfo;
            }
        } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME) {
            pPage = Page.EEC_LicensingAttachment;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_PROVIDER_NAME || LicenseRecordTypeName == EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION || LicenseRecordTypeName == EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT) {
            if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_LARGE_GROUP) || licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_SMALL_GROUP)) {
                pPage = Page.EEC_GSAReviewSummary;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_ADOPTION_AGENCY) || licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FOSTER_CARE_AGENCY) || licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_TEMPORARY_SHELTER) || licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_GROUP_CARE)) {
                pPage = Page.EEC_RP_ReviewSummary;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC)) {
                pPage = Page.EEC_ReviewSummarySubmission;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT)) {
                pPage = Page.EEC_ReviewSummarySubmissionAssistant;
            }
        }else if (LicenseRecordTypeName == EEC_Constants.LT_CLOSE_INFORMAL_CHILD_CARE_API_NAME){
                pPage = Page.EEC_CBCReviewSummary;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_CLOSE_FUNDED_API_NAME){
                pPage = Page.EEC_IntentToCloseFundingProgram;
        } else {
            pPage = Page.EEC_TransactionProvider;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        if (String.isNotBlank(memberId))
            pPage.getParameters().put('member', memberId);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference closeAndreturnToHome() {
        if (!isInternalUser) {
            PageReference pPage = Page.EEC_PortalLandingPage;
            //pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } else {
            PageReference pPage = new PageReference('/' + licenseTransation.Id);
            return pPage;
        }
    }
    public Pagereference saveAndNextTransactionProvider() {
        hasFCCCapacityIncreased = false;
        ihmList = new List<Household_Member__c> ();
        removeHMList = new List<Household_Member__c> ();
        Set<Id> recordTypeIdSet = new Set<Id> ();
        if (isFccAssistant) {
           if (LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE || licenseTransation.IsAssistantUpgradeToCertified__c) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT) {
                licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT) && LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_CHANGE_OF_ADDRESS) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK && licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT)) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
            }  else {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
            }
        } else {
            if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS ||
                    LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
                //licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
            } else {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
            }
        }
       /* if (LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
            provider.Electronic_Communication__c = true;
        } */
        if (LicenseRecordTypeName == EEC_Constants.LT_CHILD_CARE_LICENSING_EXEMPTION) {
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
            provider.Electronic_Communication__c = true;
        }
        //R&P and GSA
        if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                 || LicenseRecordTypeName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION )) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OWNERSHIP_ADMINISTRATOR_INFO;
            provider.Electronic_Communication__c = true;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE || LicenseRecordTypeName == EEC_Constants.LT_EEC_GSA_MODIFICATION) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
            provider.Electronic_Communication__c = true;
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE) {
            licenseTransation.Previous_City__c = provider.Provider_City__c;
            licenseTransation.Previous_State__c = provider.State__c;
            licenseTransation.Previous_Street_Address_1__c = provider.Provider_Address_1__c;
            licenseTransation.Previous_Street_Address_2__c = provider.Provider_Address_2__c;
            licenseTransation.Previous_Zip_Code__c = provider.Provider_Zip_Code__c;
        }
        if ((LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL)) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OWNERSHIP_ADMINISTRATOR_INFO;
            provider.Electronic_Communication__c = true;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_EEC_RP_MODIFICATION) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_RESIDENTIAL_PROGRAM_DETAILS;
            provider.Electronic_Communication__c = true;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_PLACEMENT_AGENCY_ADDITIONAL_INFO;
            provider.Electronic_Communication__c = true;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
        }
        if (licenseTransation.Last_Reached_Step__c != null && !isFccAssistant && licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT) && licenseRecordTypeLabel.equalsIgnoreCase(EEC_Constants.LT_FCC_NEW_LICENSE)) {
            provider.State__c = 'MA';
        }
        if (String.isBlank(previousStreet1) != String.isBlank(Provider.Provider_Address_1__c) ||
                String.isBlank(previousStreet2) != String.isBlank(Provider.Provider_Address_2__c) ||
                String.isBlank(previousCity) != String.isBlank(Provider.Provider_City__c) ||
                String.isBlank(previousState) != String.isBlank(Provider.State__c) ||
                String.isBlank(previousZipCode) != String.isBlank(Provider.Provider_Zip_Code__c)) {
            licenseTransation.Previous_Street_Address_1__c = previousStreet1;
            licenseTransation.Previous_Street_Address_2__c = previousStreet2;
            licenseTransation.Previous_City__c = previousCity;
            licenseTransation.Previous_State__c = previousState;
            licenseTransation.Previous_Zip_Code__c = previousZipCode;
            licenseTransation.New_Street_Address_1__c = Provider.Provider_Address_1__c;
            licenseTransation.New_Street_Address_2__c = Provider.Provider_Address_2__c;
            licenseTransation.New_City__c = Provider.Provider_City__c;
            licenseTransation.New_State__c = Provider.State__c;
            licenseTransation.New_Zip_Code__c = Provider.Provider_Zip_Code__c;
        }
        /*if(licenseTransation.Do_you_live_at_this_address__c){
            if(Provider.Provider_Address_2__c != null){
                licenseTransation.Mailing_Street__c = Provider.Provider_Address_1__c+', '+ Provider.Provider_Address_2__c;
            }else{
                licenseTransation.Mailing_Street__c = Provider.Provider_Address_1__c;
            }
            licenseTransation.Mailing_City__c = Provider.Provider_City__r.Name;
            licenseTransation.Mailing_State__c = Provider.State__c;
            licenseTransation.Mailing_Zip__c = Provider.Provider_Zip_Code__c;
        }*/
        if (isSaveOnly) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
        }
        if (!isSubmitted) {
            //update provider;
            update licenseTransation;
            update provider;
            if (transactionContact != null && (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE)) {
                update transactionContact;
            }
           
        }
        if (licenseTransation.License_Requested__c > provider.Capacity__c) {
            hasFCCCapacityIncreased = true;
        }
        recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.FCC_New_License').Id);
        recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.FCC_Renewal').Id);
        recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.Change_of_Address').Id);
        recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.FCC_License_Upgrade').Id);
        recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.FCC_Change_of_Household').Id);
        licenseTransation = [
                SELECT Ownership_Type__c,Provider__r.Ownerid, Provider__r.License_Type__c,
                        Date_Taken_Intro_EEC_in_MA_orientation__c, Id, name, IsProviderUpgrade__c, IsAssistantUpgradeToCertified__c,
                        Last_Reached_Step__c, Drinking_Water_Source__c, Exits_Descriptions__c, RecordTypeId, Provider__c, Technical_Assistance__c, Caring_For_Children_Not_Related__c,
                        Completed_30_hours_of_Training__c,Plan_for_training_completion__c,Plan_for_diverse_learners_training__c,Address_diverse_learners_hours__c,
                        Evening_Overnight_Weekend_Care__c, Children_Home_Schooled__c, Children_Home_Schooled_Description__c, New_Street_Address_1__c,Previous_Street_Address_1__c,
                        Previous_Street_Address_2__c,Previous_City__c,Previous_Zip_Code__c, Previous_City__r.Name, Previous_State__c,Date_Name_Change_is_Effective__c,
                        New_Street_Address_2__c,New_Name__c, New_City__c,New_City__r.Name, New_Zip_Code__c, Live_at_New_Address__c, Moving_Date__c, Date_Care_Resumes__c, New_Address_Phone_Number__c,
                        Infant_Capacity__c,Infant_Toddler_Capacity__c,Toddler_Capacity__c,Toddler_Preschool_Capacity__c,Preschool_Capacity__c,Preschool_SA_Capacity__c,
                        Kindergarten_Capacity__c,School_Age_Capacity__c,Multi_Age_Group_Capacity__c,Kindergarten_School_Age__c,Total_License_Capacity_Requested__c,Minimum_Age_Limit_Requested_Years__c,
                        Minimum_Age_Limit_Requested_Months__c,Maximum_Age_Limit_Requested_Months__c,Maximum_Age_Limit_Requested_Years__c,Provider__r.Type_of_Ownership__c,
                        ProgramContracted__c,ProgramLicensedOrApproved__c,Provider__r.Capacity__c,Summer_Camp_Permit__c,transactionRecordTypeDeveloperName__c,providerRecordTypeDeveloperName__c,
                        Transaction_Configuration__r.EEC_Licensing_Transaction_Instructions__c,Do_you_live_at_this_address__c,Mailing_Street__c,
                        Becoming_Foster_Care_Provider__c, License_Requested__c, Business_Operated_Out_of_Own_Home__c,
                        Abused_or_neglected_a_child__c, Abused_or_neglected_a_child_Description__c,Mailing_State__c,Mailing_City__c,Mailing_Zip__c,
                        Bus_Operated_Out_of_Own_Home_Descrip__c, Alcoholic_Bev_Narcotics_Drugs_Desc__c,
                        Caring_for_your_own_children_Years__c, Caring_for_your_own_children_Months__c, Caring_for_your_own_children_Hrs_Week__c,
                        Caring_Other_People_Children_End_Date__c, Caring_Other_People_Children_Start_Date__c,
                        
                        Submitter__r.Name, Assigned_User_Email__c,
                   
                        Challenges_in_Compliance_Requirement_Oth__c,Challenges_in_BRC_requirements__c,
                        Certificate_of_Eligibility_for_Funding__c,
                       
                        Types_of_support_most_help__c,Challenges_in_Compliance_Requirements__c
                        ,Challenges_in_BRC_requirement_Other_Reas__c,
                        Challenges_in_Certificate_of_Eligibility__c
                from Licensing_Transaction__c
                where Id = :licenseTransation.Id
        ];
        if (isFccAssistant) {
            PageReference pPage;
            if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT || licenseTransation.IsAssistantUpgradeToCertified__c) {
                pPage = Page.EEC_AssistantInvolvementExperience;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_RENEWAL) {
                pPage = Page.eec_transaction_dailyranda;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT) && LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_CHANGE_OF_ADDRESS) {
                pPage = Page.eec_reviewsummarysubmissionassistant;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK && licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC_ASSISTANT)) {
                pPage = Page.EEC_ReviewSummarySubmissionAssistant;
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
            } else if(LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST){
                pPage = Page.EEC_TechnicalAssistance;
            } else {
                pPage = Page.EEC_BackgroundInformation;
            }
            if (isSaveOnly) {
                pPage = Page.EEC_TransactionProvider;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            //pPage.getParameters().put('ltId', licenseTransation.Provider__r.id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        }
        List<Household_Member__c> tempHMList = [
                select relationship_to_Provider__c, Provider__c, Occupation__c, Name, Licensing_Transactions__c, Last_Name__c, Id, Number_of_Hours_Home_During_Child_Care__c,
                        First_Name__c, Email_Address__c, Date_of_Birth__c, Current__c, Current_School_Grade__c, CreatedDate
                from Household_Member__c
                where Licensing_Transactions__c = :licenseTransation.Id
        ];
        system.debug('tempHMList<<'+tempHMList);
        PageReference pPage;
        if (licenseTransation.providerRecordTypeDeveloperName__c.equalsIgnoreCase(EEC_Constants.PRO_FCC) && (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS ||
                LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD)) {
            if (tempHMList == null || tempHMList.size() == 0) {
                List<Household_Member__c> thmList = [
                        select Id, Licensing_Transactions__c
                        from Household_Member__c
                        where Provider__c = :provider.Id and
                        (licensing_transactions__R.Status__c != :EEC_Constants.LT_CANCELLED and licensing_transactions__R.Status_Reason__c != :EEC_Constants.LT_CLOSED_EEC_APPLICATION_INCOMPLETE_DENIED ) and
                        licensing_transactions__r.RecordTypeId in :recordTypeIdSet
                        order by Licensing_Transactions__r.CreatedDate desc
                ];
                if (thmList != null && thmList.size() > 0) {
                    Household_Member__c thm = thmList.get(0);
                    List<Household_Member__c> hmList = [
                            select Relationship_to_Provider__c, Provider__c, Occupation__c, Name, Licensing_Transactions__c, Last_Name__c, Id, Number_of_Hours_Home_During_Child_Care__c,
                                    First_Name__c, Email_Address__c, Date_of_Birth__c, Current__c, Current_School_Grade__c, CreatedDate
                            From Household_Member__c
                            where Licensing_Transactions__c = :thm.Licensing_Transactions__c
                    ];
                    Household_Member__c iHm;
                    for (Household_Member__c hm : hmList) {
                        iHm = new Household_Member__c();
                        iHm.Relationship_to_Provider__c = hm.Relationship_to_Provider__c;
                        iHm.Provider__c = hm.provider__c;
                        iHm.Occupation__c = hm.Occupation__c;
                        iHm.Licensing_Transactions__c = licenseTransation.Id;
                        iHm.Last_Name__c = hm.Last_Name__c;
                        iHm.First_Name__c = hm.First_Name__c;
                        iHm.Email_Address__c = hm.Email_Address__c;
                        iHm.Date_of_Birth__c = hm.Date_of_Birth__c;
                        iHm.Current__c = hm.Current__c;
                        iHm.Current_School_Grade__c = hm.Current_School_Grade__c;
                        iHm.Number_of_Hours_Home_During_Child_Care__c = hm.Number_of_Hours_Home_During_Child_Care__c;
                        ihmList.add(iHm);
                    }
                    if (!isSubmitted) {
                        insert ihmList;
                    }
                }
            } else {
                ihmList = tempHMList;
            }
            ihmListJson = JSON.serialize(ihmList);
            pPage = Page.EEC_HouseholdMembers;
        }
        //For GSA and R&P, redirect it to Ownership / Administrator Info page
        else if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE)
                || (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION )) {
            pPage = Page.EEC_OwnershipAdministratorInfo;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE) {
            pPage = Page.EEC_LicensingAttachment;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE || LicenseRecordTypeName == EEC_Constants.LT_EEC_GSA_MODIFICATION) {
            pPage = Page.EEC_CapacityInformation;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_EEC_RP_MODIFICATION) {
            pPage = Page.EEC_ResidentialProgramDetail;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE) {
            pPage = Page.EEC_PlacementAgency;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) {
            pPage = Page.EEC_TechnicalAssistance;
        }/* else if (LicenseRecordTypeName == EEC_Constants.LT_CHILD_CARE_LICENSING_EXEMPTION 
            || LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
            pPage = Page.EEC_InvolvementExperience;
        } */else {
            if (!initIndoor) {
                initializeIndoor();
            }
            pPage = Page.EEC_IndoorSpacePage;
        } 
        if (isSaveOnly) {
            pPage = Page.EEC_TransactionProvider;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference rerenderPanel() {
        return null;
    }
    public Pagereference saveAndPreviousTransactionProvider() {
        if (isFccAssistant) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INSTRUCTION;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS ||
                LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
        } else if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_EEC_GSA_MODIFICATION
                || LicenseRecordTypeName == EEC_Constants.LT_EEC_RP_MODIFICATION
                || LicenseRecordTypeName == EEC_Constants.LT_EEC_FCC_MODIFICATION
                || LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK
                || LicenseRecordTypeName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION )) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
            provider.Electronic_Communication__c = true;
        }
        if (String.isBlank(previousStreet1) != String.isBlank(Provider.Provider_Address_1__c) ||
                String.isBlank(previousStreet2) != String.isBlank(Provider.Provider_Address_2__c) ||
                String.isBlank(previousCity) != String.isBlank(Provider.Provider_City__c) ||
                String.isBlank(previousState) != String.isBlank(Provider.State__c) ||
                String.isBlank(previousZipCode) != String.isBlank(Provider.Provider_Zip_Code__c)) {
            licenseTransation.Previous_Street_Address_1__c = previousStreet1;
            licenseTransation.Previous_Street_Address_2__c = previousStreet2;
            licenseTransation.Previous_City__c = previousCity;
            licenseTransation.Previous_State__c = previousState;
            licenseTransation.Previous_Zip_Code__c = previousZipCode;
            licenseTransation.New_Street_Address_1__c = Provider.Provider_Address_1__c;
            licenseTransation.New_Street_Address_2__c = Provider.Provider_Address_2__c;
            licenseTransation.New_City__c = Provider.Provider_City__c;
            licenseTransation.New_State__c = Provider.State__c;
            licenseTransation.New_Zip_Code__c = Provider.Provider_Zip_Code__c;
        }
        if (cntct != null) {
        }
        PageReference pPage;
        if (string.IsNotBlank(previousPageName)) {
            if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R_P_Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            }else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER|| licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_PUBLIC_SCHOOL|| licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_PRIVATE_SCHOOL){
               pPage = EEC_Util.lastCBCStepMap.get(previousPageName);
            }else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SUMMER_CAMP){
            //    pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
            }else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE){
                pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
            }
        } else {
            pPage = Page.EEC_TransactionInstructions;
        }
        system.debug('pPage<<<'+pPage);
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference saveAndReturnTransactionProvider() {
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS ||
                LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
        } else if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE)) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO;
            provider.Electronic_Communication__c = true;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT) {
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
        } else {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
        }
        if (String.isBlank(previousStreet1) != String.isBlank(Provider.Provider_Address_1__c) ||
                String.isBlank(previousStreet2) != String.isBlank(Provider.Provider_Address_2__c) ||
                String.isBlank(previousCity) != String.isBlank(Provider.Provider_City__c) ||
                String.isBlank(previousState) != String.isBlank(Provider.State__c) ||
                String.isBlank(previousZipCode) != String.isBlank(Provider.Provider_Zip_Code__c)) {
            licenseTransation.Previous_Street_Address_1__c = previousStreet1;
            licenseTransation.Previous_Street_Address_2__c = previousStreet2;
            licenseTransation.Previous_City__c = previousCity;
            licenseTransation.Previous_State__c = previousState;
            licenseTransation.Previous_Zip_Code__c = previousZipCode;
            licenseTransation.New_Street_Address_1__c = Provider.Provider_Address_1__c;
            licenseTransation.New_Street_Address_2__c = Provider.Provider_Address_2__c;
            licenseTransation.New_City__c = Provider.Provider_City__c;
            licenseTransation.New_State__c = Provider.State__c;
            licenseTransation.New_Zip_Code__c = Provider.Provider_Zip_Code__c;
        }
        if (!isSubmitted) {
            update licenseTransation;
            update provider;
            if (cntct != null) {
                update cntct;
            }
        }
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public void AddRow() {
        ihmList.add(new Household_Member__c());
    }
    public void delRow() {
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        Household_Member__c tHM = ihmList.get(rowNum);
        if (String.isNotBlank(tHM.Id)) {
            removeHMList.add(ihmList.get(rowNum));
        }
        ihmList.remove(rowNum);
    }
    public void AddRowLS() {
    }
    public void delRowLS() {
    }
    public void AddRowEH() {
        if (ehList == null) {
            ehList = new List<Employment_History__c> ();
        }
        ehList.add(new Employment_History__c());
    }
    public void delRowEH() {
        if (removeEHList == null) {
            removeEHList = new List<Employment_History__c> ();
        }
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        Employment_History__c tEH = ehList.get(rowNum);
        if (String.isNotBlank(tEH.Id)) {
            removeEHList.add(ehList.get(rowNum));
        }
        ehList.remove(rowNum);
    }
    public void AddRowRoom() {
        if (roomList == null) {
            roomList = new List<Room__c> ();
        }
        roomList.add(new Room__c());
    }
    public void delRowRoom() {
        if (removeRoomList == null) {
            removeRoomList = new List<Room__c> ();
        }
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        Room__c rm = roomList.get(rowNum);
        if (String.isNotBlank(rm.Id)) {
            removeRoomList.add(roomList.get(rowNum));
        }
        roomList.remove(rowNum);
    }
    public void delRowTE() {
        if (removeTEList == null) {
            removeTEList = new List<Training_Experience__c> ();
        }
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        Training_Experience__c rm = teList.get(rowNum);
        if (String.isNotBlank(rm.Id)) {
            removeTEList.add(teList.get(rowNum));
        }
        teList.remove(rowNum);
    }
    public void AddRowTE() {
        if (teList == null) {
            teList = new List<Training_Experience__c> ();
        }
        teList.add(new Training_Experience__c());
    }
    public Pagereference CancelTransaction() {
        Licensing_Transaction__c lt = new Licensing_Transaction__c(id = licenseTransation.id);
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            lt.Status__c = EEC_Constants.LT_CANCELLED;
            lt.Status_Reason__c = 'Applicant withdrew';
            lt.Reason_Closed_Cancelled__c = 'Cancelled by portal user';
            if (!isSubmitted) {
                update lt;
            }
            PageReference pPage = page.EEC_PortalLandingPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            lt.Status__c = EEC_Constants.LT_CANCELLED;
            lt.Status_Reason__c = 'Lack of Response';
            lt.Reason_Closed_Cancelled__c = 'Cancelled by EEC user';
            if (!isSubmitted) {
                update lt;
            }
            return new PageReference('/' + licenseTransation.id);
        }
    }
    public Pagereference SaveAndNextHH() {
        try {
            saveHH();
            initHH = true;
            if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE) {
                rowNum = 0;
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO;
                if (!isSubmitted) {
                    update licenseTransation;
                }
                if (!initLS) {
                    initializeLS();
                }
                PageReference pPage = Page.EEC_LicenseStatusCapacityInfo;
                if (isSaveOnly) {
                    pPage = Page.EEC_HouseholdMembers;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
                if (!isSubmitted) {
                    update licenseTransation;
                }
                if (!initIndoor) {
                    initializeIndoor();
                }
                PageReference pPage = Page.EEC_IndoorSpacePage;
                if (isSaveOnly) {
                    pPage = Page.EEC_HouseholdMembers;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                if (!isSubmitted) {
                    update licenseTransation;
                }
                PageReference pPage = Page.EEC_TechnicalAssistance;
                if (isSaveOnly) {
                    pPage = Page.EEC_HouseholdMembers;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            }
            PageReference pPage = page.EEC_PortalProviderPage;
            if (isSaveOnly) {
                pPage = Page.EEC_HouseholdMembers;
            }
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndPreviousHH() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            } else {
                pPage = Page.EEC_TransactionProvider;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndReturnHH() {
        try {
            saveHH();
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
            if (!isSubmitted) {
                update licenseTransation;
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    private void saveHH() {
        if (ihmList != null && ihmList.size() > 0) {
            for (Household_Member__c thm : ihmList) {
                if (thm.Id == null) {
                    thm.Current__c = false;
                    thm.Provider__c = provider.Id;
                    thm.Licensing_Transactions__c = licenseTransation.Id;
                }
            }
            if (!isSubmitted) {
                upsert ihmList;
            }
            ihmListJson = JSON.serialize(ihmList);
        }
        if (removeHMList != null && removeHMList.size() > 0 && !isSubmitted) {
            delete removeHMList;
        }
    }
    public Pagereference SaveAndNextTA() {
        try {
            PageReference pPage;
            if (isFccAssistant) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                pPage = Page.EEC_LicensingAttachment;
                if (isSaveOnly) {
                    pPage = Page.eec_technicalassistance;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
            } else {
                if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
                    if (!initLS) {
                        initializeLS();
                    }
                    refreshAttachmentsList();
                    pPage = Page.EEC_LicensingAttachment;
                    if (isSaveOnly) {
                        pPage = Page.eec_technicalassistance;
                        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    }
                } else if (LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
                    pPage = Page.EEC_ReviewSummarySubmission;
                    if (isSaveOnly) {
                        pPage = Page.eec_technicalassistance;
                        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    }
                } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
                    pPage = Page.EEC_LicensingAttachment;
                    if (isSaveOnly) {
                        pPage = Page.eec_technicalassistance;
                        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
                    }
                }
            }
            //GSA - Added by LD - >>> - LEAD-3830
            if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY
                    || (LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST && (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP))
            )) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
                if (!initLS) {
                    initializeLS();
                }
                pPage = Page.EEC_LicensingAttachment;
                if (isSaveOnly) {
                    pPage = Page.eec_technicalassistance;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
            }
            //R&P - Added by LD - >>> - LEAD-3830
            if ((LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                    || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE)
                    || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE
                    || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
                if (!initLS) {
                    initializeLS();
                }
                pPage = Page.EEC_LicensingAttachment;
                if (isSaveOnly) {
                    pPage = Page.eec_technicalassistance;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
            }
            //Variances to Update - LEAD-3830
            if (LicenseRecordTypeName.contains('Placement') || LicenseRecordTypeName.contains('Residential') || LicenseRecordTypeName.contains('GSA')
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE
                    || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL
                    || LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST
                    ) {
                List<Variance_on_Regulation__c> variancesToUpsert = new List<Variance_on_Regulation__c> ();
                if (varianceInfoWrappers != null && varianceInfoWrappers.size() > 0) {
                    for (EEC_VarianceListCtrl.VarianceInfoWrap wrapper : varianceInfoWrappers) {
                        variancesToUpsert.add(wrapper.varianceReg);
                    }
                    upsert variancesToUpsert;
                }
            }
            if (!isSubmitted) {
                update licenseTransation;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndPreviousTA() {
        try {
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
                if (isFccAssistant) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
                if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                } else if (LicenseRecordTypeName.contains('GSA') == false && LicenseRecordTypeName.contains('Residential') == false && LicenseRecordTypeName.contains('Placement') == false) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
                if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL)
                        ) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                } else if (licenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
                if ((LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                        || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                        || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                        || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                        || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                        || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE)) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
                if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
            } else {
                if (isFccAssistant) {
                    pPage = Page.EEC_AssistantInvolvementExperience;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
                if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
                    pPage = Page.EEC_HouseholdMembers;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                } else if (LicenseRecordTypeName.contains('GSA') == false && LicenseRecordTypeName.contains('Residential') == false && LicenseRecordTypeName.contains('Placement') == false) {
                    pPage = Page.EEC_IndoorSpacePage;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                }
                //GSA -- Added by LD --->>>--- LEAD-3830
                if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL)
                        ) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    pPage = Page.EEC_IndoorSpacegsaPage;
                } else if (licenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    pPage = Page.EEC_DesignationOfAdministrative;
                }
                //R&P -- Added by LD --->>>--- LEAD-3830
                if ((LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                        || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                        || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                        || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                        || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                        || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE)) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    pPage = Page.EEC_IndoorSpacePage;
                }
                if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    pPage = Page.EEC_ResidentialProgramDetail;
                }
                if (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    pPage = Page.EEC_PlacementAgency;
                }
                if (licenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
                    pPage = Page.EEC_TransactionProvider;
                }
            }
            //Variances to Update - LEAD-3830
            if (LicenseRecordTypeName.contains('Placement') || LicenseRecordTypeName.contains('Residential') || LicenseRecordTypeName.contains('GSA')
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE
                    || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL
                    || LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST
                    ) {
                List<Variance_on_Regulation__c> variancesToUpsert = new List<Variance_on_Regulation__c> ();
                if (varianceInfoWrappers != null && varianceInfoWrappers.size() > 0) {
                    for (EEC_VarianceListCtrl.VarianceInfoWrap wrapper : varianceInfoWrappers) {
                        variancesToUpsert.add(wrapper.varianceReg);
                    }
                }
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndReturnTA() {
        try {
            if (LicenseRecordTypeName.contains('FCC')) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
            } else {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_VARIANCE_DETAILS;
            }
            //Variances to Update - LEAD-3830
            if (LicenseRecordTypeName.contains('Placement') || LicenseRecordTypeName.contains('Residential') || LicenseRecordTypeName.contains('GSA')
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE
                    || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL
                    || LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST
                    ) {
                List<Variance_on_Regulation__c> variancesToUpsert = new List<Variance_on_Regulation__c> ();
                if (varianceInfoWrappers != null && varianceInfoWrappers.size() > 0) {
                    for (EEC_VarianceListCtrl.VarianceInfoWrap wrapper : varianceInfoWrappers) {
                        variancesToUpsert.add(wrapper.varianceReg);
                    }
                    if (!isSubmitted) {
                        upsert variancesToUpsert;
                    }
                }
            }
            if (!isSubmitted) {
                update licenseTransation;
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndNextLS() {
        try {
            if (LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO;
                if (!isSubmitted) {
                    update licenseTransation;
                }
                PageReference pPage = Page.EEC_BackgroundInformation;
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else {
                licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                if (!isSubmitted) {
                    update licenseTransation;
                }
                PageReference pPage = Page.EEC_InvolvementExperience;
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndPreviousLS() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO;
            update licenseTransation;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            } else {
                pPage = Page.EEC_HouseholdMembers;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndReturnLS() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO;
            if (!isSubmitted) {
                update licenseTransation;
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference showLSDesc() {
        return null;
    }
    public Pagereference setLicensedAgency() {
        if (programLicensedAgency == 'Yes') {
            licenseTransation.Program_licensed_or_approved_by_agency__c = true;
        } else {
            licenseTransation.Program_licensed_or_approved_by_agency__c = false;
        }
        if (programContacted == 'Yes') {
            licenseTransation.Is_your_program_contracted__c = true;
        } else {
            licenseTransation.Is_your_program_contracted__c = false;
        }
        return null;
    }
    public Pagereference showAddAssistanceDesc() {
        return null;
    }
    public Pagereference showCBDesc() {
        selectedHestStr = '';
        if (selectedHestElems != null) {
            for (String tstr : selectedHestElems) {
                selectedHestStr = selectedHestStr + tStr + ',';
            }
        } else {
            selectedHestElems = new List<String> ();
        }
        // Re-map the mappings to remove the attachment.
        generateAttachmentMappings();
        refreshAttachmentsList();
        return null;
    }
    public PageReference showWaterUpload() {
        if (String.isBlank(selectedWaterStr)) {
            selectedWaterStr = '';
        } else {
            selectedWaterStr = selectedWaterStr.equalsIgnoreCase('Town Water Supply') ? 'Private Water Supply' : 'Town Water Supply';
        }
        // Re-map the mappings to remove the attachment.
        generateAttachmentMappings();
        refreshAttachmentsList();
        return null;
    }
    public Pagereference SaveAndNextEH() {
        try {
            PageReference pPage;
            if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_RENEWAL
                    || (LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT
                    && licenseTransation.IsAssistantUpgradeToCertified__c)) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
                pPage = Page.EEC_Transaction_DailyRandA;
                if (isSaveOnly) {
                    pPage = Page.eec_involvementexperience;
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                    if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_RENEWAL) {
                        pPage = Page.eec_assistantinvolvementexperience;
                    }
                }
            }/* else if (LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                  if (isSaveOnly) {
                    pPage = Page.eec_involvementexperience;
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                }else{
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                    pPage = Page.EEC_TrainingInformation;
                }
            } */else if (LicenseRecordTypeName == EEC_Constants.LT_CHILD_CARE_LICENSING_EXEMPTION) {
                licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                pPage = Page.EEC_householdmembers;
            } else {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO;
                pPage = Page.EEC_BackgroundInformation;
                if (isSaveOnly) {
                    pPage = Page.eec_involvementexperience;
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                    if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_RENEWAL) {
                        pPage = Page.eec_assistantinvolvementexperience;
                    }
                }
            }
            if (!isSubmitted) {
                update licenseTransation;
                saveEH();
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndPreviousEH() {
        try {
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) { 
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            }/*else if (licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                    pPage = Page.eec_transactionprovider;
                }*/
            else {
                if (isFccAssistant) {
                    pPage = Page.EEC_TransactionProvider;
                } else {
                    pPage = Page.EEC_LicenseStatusCapacityInfo;
                }
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndReturnEH() {
        try {
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
            if (!isSubmitted) {
                update licenseTransation;
                saveEH();
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndNextBI() {
        try {
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_TRAINING_INFO;
            PageReference pPage = Page.EEC_TrainingInformation;
            if (isSaveOnly) {
                pPage = Page.eec_backgroundinformation;
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO;
            }
            if (!isSubmitted) {
                update licenseTransation;
            }
            if (!initTraining) {
                initializeTraining();
            }
            generateAttachmentMappings();
            retrieveAddtionalTrainingAttachmentsList();
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndPreviousBI() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO;
            //update licenseTransation;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            } else {
                pPage = determineBIPreviousPage();
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    private PageReference determineBIPreviousPage() {
        if (isFccAssistant) {
            if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_RENEWAL
                    || (LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT)) {
                return Page.EEC_Transaction_DailyRandA;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE) {
                return Page.eec_transactionprovider;
            } else {
                return Page.EEC_AssistantInvolvementExperience;
            }
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE) {
            return Page.eec_licensestatuscapacityinfo; //return Page.EEC_Transaction_AssistantInfo;
        } else {
            return Page.EEC_InvolvementExperience;
        }
    }
    public Pagereference SaveAndReturnBI() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO;
            if (!isSubmitted) {
                update licenseTransation;
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndNextRoom() {
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
        PageReference pPage = Page.EEC_ReviewSummarySubmission;
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            pPage = Page.EEC_LicensingAttachment;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
            pPage = Page.EEC_TechnicalAssistance;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_EEC_FCC_MODIFICATION) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUMMARY_AND_SUBMISSION;
            pPage = Page.EEC_ReviewSummarySubmission;
        }
        if (isSaveOnly) {
            pPage = Page.eec_indoorspacepage;
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
        }
        if (!isSubmitted) {
            saveRoom();
            createTrainingTransactionDocuments();
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference SaveAndPreviousRoom() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            } else {
                if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL || LicenseRecordTypeName == EEC_Constants.LT_EEC_FCC_MODIFICATION) {
                    pPage = Page.EEC_TransactionProvider;
                } else if (LicenseRecordTypeName == EEC_Constants.LT_EEC_FCC_MODIFICATION) {
                    pPage = Page.eec_indoorspacepage;
                } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                    generateAttachmentMappings();
                    retrieveAddtionalTrainingAttachmentsList();
                    pPage = Page.EEC_TrainingInformation;
                } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                        || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE) {
                    generateAttachmentMappings();
                    retrieveAddtionalTrainingAttachmentsList();
                    pPage = Page.EEC_OperationDetailInfo;
                } else {
                    pPage = Page.EEC_HouseholdMembers;
                }
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndReturnRoom() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
            if (!isSubmitted) {
                saveRoom();
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage =page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndNextTE() {
        try {
            PageReference pPage;
            if (isFccAssistant) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
                pPage = Page.EEC_LicensingAttachment;
                if (isSaveOnly) {
                    pPage = Page.eec_traininginformation;
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_TRAINING_INFO;
                }
            }/* else if (LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
                pPage = Page.EEC_LicensingAttachment;
            }*/ else {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
                pPage = Page.EEC_IndoorSpacePage;
                if (isSaveOnly) {
                    pPage = Page.eec_traininginformation;
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_TRAINING_INFO;
                }
            }
            if (!isSubmitted) {
                saveTE();
                createTrainingTransactionDocuments();
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, true);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndPreviousTE() {
        try {
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_TRAINING_INFO;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            }/*else if (licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                    pPage = Page.eec_involvementexperience;
                }*/
            else {
                pPage = Page.EEC_BackgroundInformation;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndReturnTE() {
        try {
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_TRAINING_INFO;
            if (!isSubmitted) {
                saveTE();
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage =page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                pPage.setRedirect(true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public PageReference SaveAndNextAttachment() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            if (!isSubmitted) {
                licenseTransation = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransation);
            }
            try {
                refreshAttachmentsList();
                if (renderAttachLib) {
                    addDocument();
                }
            } catch (Exception e) {
            }
            if (LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_NEW_LICENSE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_RENEWAL ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_MOVE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_MOVE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
                PageReference pPage = Page.EEC_RP_ReviewSummary;
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (LicenseRecordTypeLabel == EEC_Constants.LT_GSA_NEW_LICENSE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_GSA_RENEWAL ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_GSA_LICENSE_CHANGE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_GSA_MOVE
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE ||
                    LicenseRecordTypeLabel == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
                PageReference pPage = Page.EEC_GSAReviewSummary;
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else {
                PageReference pPage = Page.EEC_ReviewSummarySubmission;
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public PageReference SaveAndPreviousAttachment() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            try {
                refreshAttachmentsList();
                if (renderAttachLib) {
                    addDocument();
                }
            } catch (Exception e) {
            }
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                    if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL) {
                        pPage = Page.eec_indoorspacepage;
                    }
                } else if (LicenseRecordTypeLabel == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
                    pPage = Page.EEC_OwnershipAdministratorInfo;
                } else if (LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                        || LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                        || LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE) {
                    pPage = Page.EEC_ResidentialProgramDetail;
                } else if (LicenseRecordTypeLabel == EEC_Constants.LT_RESIDENTIAL_MOVE) {
                    pPage = Page.EEC_TransactionProvider;
                } else if (LicenseRecordTypeLabel == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                        || LicenseRecordTypeLabel == EEC_Constants.LT_GSA_MOVE
                        || LicenseRecordTypeLabel == EEC_Constants.LT_GSA_LICENSE_CHANGE
                        || LicenseRecordTypeLabel == EEC_Constants.LT_GSA_RENEWAL
                        || LicenseRecordTypeLabel == EEC_Constants.LT_GSA_NEW_LICENSE) {
                    pPage = Page.eec_indoorspacegsapage;
                } else if (LicenseRecordTypeLabel == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
                    pPage = Page.EEC_DesignationOfAdministrative;
                } else if (LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                        || LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_RENEWAL
                        || LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE
                        || LicenseRecordTypeLabel == EEC_Constants.LT_PLACEMENT_MOVE) {
                    pPage = Page.EEC_PlacementAgency;
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
                else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE ) {
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            } else {
                pPage = Page.EEC_TechnicalAssistance;
                if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL) {
                    pPage = Page.eec_indoorspacepage;
                }
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public PageReference SaveAndReturnAttachment() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            licenseTransation = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransation);
            try {
                refreshAttachmentsList();
                if (renderAttachLib) {
                    addDocument();
                }
            } catch (Exception e) {
            }
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                pPage.setRedirect(true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference previousRS() {
        try {
            // Update the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
            //update licenseTransation;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            } else {
                if (isFccAssistant) {
                    If (LicenseRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE) {
                        pPage = Page.EEC_TransactionInstructions;
                    } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME) {
                        pPage = Page.EEC_LicensingAttachment;
                    } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_CHANGE_OF_ADDRESS) {
                        pPage = Page.EEC_transactionprovider;
                    } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_ASSISTANT_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT) {
                        pPage = Page.EEC_LicensingAttachment;
                    } else if (LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK 
                                || LicenseRecordTypeName == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME) {
                        pPage = Page.EEC_TransactionProvider;
                    }else if (LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST ) {
                        pPage = Page.EEC_LicensingAttachment;
                    } else {
                        pPage = Page.EEC_TrainingInformation;
                    }
                } else {
                    // If New, Renewal, or Upgrade then back to attachments. Else go to TA.
                    if (LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION || LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
                        refreshAttachmentsList();
                        pPage = Page.EEC_LicensingAttachment;
                    } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE
                            || LicenseRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE
                            || LicenseRecordTypeName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY
                            || LicenseRecordTypeName == EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT
                            || LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_PROVIDER_NAME
                            || LicenseRecordTypeName == EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION) {
                        pPage = Page.eec_transactioninstructions;
                    } else if (LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_ADDRESS || LicenseRecordTypeName == EEC_Constants.LT_EEC_FCC_MODIFICATION) {
                        pPage = Page.eec_indoorspacepage;
                    } else if (LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK || LicenseRecordTypeName == EEC_Constants.LT_CONTACT_MANAGEMENT) {
                        if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                            pPage = Page.EEC_HouseHoldMembers;
                        } else {
                            pPage = Page.EEC_ownershipadministratorinfo;
                        }
                    } else {
                        pPage = Page.eec_technicalassistance;
                    }
                }
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    private void populateTransactionContact() {
        transactionContactList = new List<Transaction_Contact__c>();
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        if (String.isNotBlank(ltId)) {
            for (Transaction_Contact__c transContact : [
                    SELECT Id,First_Name__c,Last_Name__c,Contact__c,Licensing_Transaction__c,Middle_Initial__c,
                            Email__c,Start_Date__c,Status__c,End_Date__c,Role__c,Schedule_Administrative_Hours__c,
                            Schedule_Teaching_Hours__c,Date_of_Birth__c,BRC_Role__c,Do_You_Need_a_BRC_Form__c
                    FROM Transaction_Contact__c
                    WHERE Licensing_Transaction__c = :ltId
            ]) {
                transactionContactList.add(transContact);
            }
        }
    }
   @testvisible private void updateTransactionContactRecords(Id licensetransactionId) {
        Set<Id> transConIds = new Set<Id>();
        Boolean hasBrcContact = false ;
        List<Transaction_Contact__c > tansContact = new list<Transaction_Contact__c >();
        List<Transaction_Due_Diligence__c> dueDilToBeUpdated = new List<Transaction_Due_Diligence__c>();
        for (Transaction_Contact__c transCon : [SELECT id,Role__c,BRC_Required__c,Licensing_Transaction__c,Contact__c,
                                                    Status__c,BRC_Role__c, Date_of_Birth__c, BRC_Expiration_Date__c,BRC_Renewal_Date__c,
                                                    Licensing_Transaction__r.RecordType.DeveloperName,
                                                    Licensing_Transaction__r.Provider__r.RecordType.DeveloperName,Do_You_Need_a_BRC_Form__c
                                                FROM Transaction_Contact__c
                                                WHERE Licensing_Transaction__c = :licensetransactionId
                                                AND Role__c != :EEC_Constants.TC_ROLE_OTHER_CONTACT]) {
            Integer age;
            Date next90DaysDate = Date.today().addDays(90);
            if (transCon.Date_of_Birth__c != null) {
                Integer days = transCon.Date_of_Birth__c.daysBetween(Date.Today());
                age = Integer.valueOf(days / 365);
            }
            if (transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT
                    && (transCon.BRC_Expiration_Date__c == null || transCon.BRC_Expiration_Date__c <= next90DaysDate )) {
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            } else if (transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE && transCon.Role__c == EEC_Constants.TC_ROLE_LICENSEE
                    && transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_FCC
                    && transCon.Licensing_Transaction__r.RecordType.DeveloperName != EEC_Constants.LT_BACKGROUND_RECORD_CHECK
                    && (transCon.BRC_Expiration_Date__c == null || transCon.BRC_Expiration_Date__c <= next90DaysDate )) {
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            } else if (transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE && (transCon.Role__c == EEC_Constants.TC_ROLE_REGULARLY_ON_PREMISE
                    || transCon.Role__c == EEC_Constants.TC_ROLE_HOUSEHOLD_MEMBER) && age >= 15
                    && transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_FCC
                    && transCon.Licensing_Transaction__r.RecordType.DeveloperName != EEC_Constants.LT_BACKGROUND_RECORD_CHECK
                    && (transCon.BRC_Expiration_Date__c == null || transCon.BRC_Expiration_Date__c <= next90DaysDate )) {
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            } else if (transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE && (transCon.BRC_Role__c == EEC_Constants.TC_BRC_ROLE_LICENSEE)
                    && transCon.Licensing_Transaction__r.RecordType.DeveloperName != EEC_Constants.LT_BACKGROUND_RECORD_CHECK
                    && (transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP
                    || transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP )
                    && (transCon.BRC_Renewal_Date__c == null || transCon.BRC_Renewal_Date__c <= next90DaysDate )) {
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            } else if(transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE && transCon.Do_You_Need_a_BRC_Form__c == 'Yes'
                    && transCon.Licensing_Transaction__r.RecordType.DeveloperName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK
                    && (transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_LARGE_GROUP
                    || transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP )){
                transCon.BRC_Renewal_Date__c = transCon.BRC_Renewal_Date__c != null ? null : transCon.BRC_Renewal_Date__c;
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            } else if (transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE && (transCon.Role__c == 'Designated Administrator')) {
                // && (transCon.BRC_Expiration_Date__c == null || transCon.BRC_Expiration_Date__c <= next90DaysDate )
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            } else if (transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE && (transCon.BRC_Role__c == EEC_Constants.TC_BRC_ROLE_LICENSEE
                    || transCon.BRC_Role__c == EEC_Constants.TC_BRC_ROLE_PROGRAM_ADMINISTRATOR)
                    && transCon.Licensing_Transaction__r.RecordType.DeveloperName != EEC_Constants.LT_BACKGROUND_RECORD_CHECK
                    && (transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName != EEC_Constants.PRO_LARGE_GROUP
                    && transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName != EEC_Constants.PRO_SMALL_GROUP )
                    && (transCon.BRC_Expiration_Date__c == null || transCon.BRC_Expiration_Date__c <= next90DaysDate )) {
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            } else if(transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE && transCon.Do_You_Need_a_BRC_Form__c == 'Yes'
                    && transCon.Licensing_Transaction__r.RecordType.DeveloperName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK
                    && (transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName != EEC_Constants.PRO_LARGE_GROUP
                    && transCon.Licensing_Transaction__r.Provider__r.RecordType.DeveloperName != EEC_Constants.PRO_SMALL_GROUP )){
                transCon.BRC_Expiration_Date__c = transCon.BRC_Expiration_Date__c != null ? null : transCon.BRC_Expiration_Date__c;
                transCon.BRC_Required__c = true;
                tansContact.add(transCon);
            }
            transConIds.add(transCon.id);
        }
        if (tansContact.size() > 0) {
            update tansContact;
        }
        if (transConIds.size() > 0) {
            for (Transaction_Contact__c transCon : [SELECT id,Role__c,BRC_Required__c,Licensing_Transaction__c,Contact__c,Status__c,
                                                        Licensing_Transaction__r.RecordType.DeveloperName,BRC_Consent_Status__c
                                                    FROM Transaction_Contact__c
                                                    WHERE Id IN :transConIds]) {
                if (transCon.BRC_Consent_Status__c != null && !hasBrcContact) {
                    hasBrcContact = true;
                }
            }
        }
        if (!hasBrcContact) {
            for (Transaction_Due_Diligence__c tranDueDil : [SELECT Name,Status__c,Completion_Date__c,
                                                                Unique_API_Name__c,Licensing_Transaction__c,Id,Licensing_Transaction__r.RecordType.DeveloperName
                                                            FROM Transaction_Due_Diligence__c
                                                            WHERE Licensing_Transaction__c = :licensetransactionId
                                                            AND Unique_API_Name__c = :EEC_DueDiligenceHepler.brcInformationCheckList
                                                            AND Licensing_Transaction__r.RecordType.DeveloperName != :EEC_Constants.LT_CONTACT_MANAGEMENT]) {
                tranDueDil.Status__c = 'Completed';
                tranDueDil.Completion_Date__c = DateTime.now();
                dueDilToBeUpdated.add(tranDueDil);
            }
        }
        if (dueDilToBeUpdated.size() > 0) {
            update dueDilToBeUpdated;
        }
    }
    /* private void updateTransactionDocumentRecord(Id licensetransactionId){
        set<id> docIds = new set<id>();
        List<Transaction_Document__c> transactionDocumentToBeUpdated = new List<Transaction_Document__c>();
        for(Transaction_Document__c transDoc:[SELECT id,Is_License_Submitted__c,Document__c
                                                FROM Transaction_Document__c
                                                WHERE  Is_Consent_Document__c = true or Is_Tax_Statement_Document__c= true]){
            transDoc.Is_Consent_Document__c = false;
            transDoc.Is_Tax_Statement_Document__c = false;
            docIds.add(transDoc.Document__c);
            transactionDocumentToBeUpdated.add(transDoc);
        }
        if(transactionDocumentToBeUpdated.size()>0){
            update transactionDocumentToBeUpdated;
        }
    } */
    public boolean checkMandatoryDocuments() {
        List<Transaction_Document__c> listTransactionDocument = [
                SELECT ID, Document__c, Document_Type__r.Name,Document_Type__r.Optional_for_Transactio_Type__c,
                        Mode__c,Transaction_Document_Name__c
                FROM Transaction_Document__c
                WHERE
                Licensing_Transaction__c = :licenseTransation.id
                AND Submit_Transaction_Only_If_Uploaded__c = true
                AND Document__r.Attachment_Status__c = :EEC_Constants.DOCUMENT_NO_ATTACHMENT
                AND Mode__c = 'Required'
        ];
        /* if(listTransactionDocument <> null && listTransactionDocument.size() > 0)
        {
            String errMsg='';
            for(Transaction_Document__c transactionDocument : listTransactionDocument)
            {
              if(transactionDocument.Mode__c == 'Required'){
                errMsg = errMsg + ', ' + transactionDocument.Transaction_Document_Name__c;
              }
            }
            if(errMsg.removeStart(', ').length() > 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The following mandatory document(s) have not been uploaded:' + errMsg.removeStart(', ') + '. Please, go back to the Attachment section and upload these document.'));
                return false;
            }
        }*/
        return true;
    }
    public Pagereference submitRS() {
        if (licenseTransation.RecordType.DeveloperName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) {
            getVarianceList();
        } else {
            listofVariance = new List<Variance_on_Regulation__c>();
        }
        if (/*checkMandatoryDocuments()*/(listofVariance.size() > 0 && licenseTransation.RecordType.DeveloperName == EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) || licenseTransation.RecordType.DeveloperName != EEC_Constants.LT_VARIAMCE_ON_REGULATION_REQUEST) {
            licenseTransation.Submitter__c = Userinfo.getUserId();
            licenseTransation.Status__c = EEC_Constants.LT_SUBMITTED;
            licenseTransation.Submission_Date__c = Date.today();
            licenseTransation.Source__c = 'Provider Portal';
            for (Transaction_Due_Diligence__c transDueDilObj : [SELECT Id,Associated_Status__c,Sequence__c,Associated_Status_Reason__c,
                                                                Status__c,Unique_API_Name__c,Licensing_Transaction__r.Status__c,Licensing_Transaction__r.Status_Reason__c
                                                            FROM Transaction_Due_Diligence__c
                                                            WHERE Licensing_Transaction__c = :licenseTransation.id
                                                            AND Status__c != 'Completed'
                                                            ORDER BY Sequence__c NULLS LAST
                                                            LIMIT 1]) {
                if (transDueDilObj.Associated_Status__c != transDueDilObj.Licensing_Transaction__r.Status__c
                        || transDueDilObj.Associated_Status_Reason__c != transDueDilObj.Licensing_Transaction__r.Status_Reason__c) {
                    licenseTransation.Status_Reason__c = transDueDilObj.Associated_Status_Reason__c;
                    licenseTransation.Status__c = transDueDilObj.Associated_Status__c;
                }
            }
            update licenseTransation;
            if(licenseTransation.RecordType.DeveloperName != 'Licensee_Management') {
                updateTransactionContactRecords(licenseTransation.id);
            }
            createAndInsertAttachment(licenseTransation.id);
            return null;
        } else {
            return null;
        }
    }
    public PageReference returnToHomePage() {
        if (!isInternalUser) {
            PageReference pPage = page.EEC_PortalLandingPage;
            addMemberIDPageParameter(pPage, true);
            pPage.setRedirect(true);
            return pPage;
        } else {
            PageReference pPage = new PageReference('/' + licenseTransation.Id);
            return pPage;
        }
    }
    public PageReference returnToProvider() {
        PageReference pPage = page.EEC_PortalProviderPage;
        addMemberIDPageParameter(pPage, true);
        pPage.setRedirect(true);
        return pPage;
    }
    /*@future(callout=true)
    public static void createAndInsertAttachment(Id Ltid) {
        string username = userinfo.getname();
        string Cdate = system.today().format();
        PageReference pagePdf = new PageReference('/apex/EEC_TransactionSubmissionPDF');
        pagePdf.getParameters().put('Id', Ltid);
        list<Licensing_Transaction__c> lt = new list<Licensing_Transaction__c>([select id,name,recordtype.name from Licensing_Transaction__c where id =: Ltid]);
        string Lttype = lt[0].recordtype.name;
        Blob pdfPageBlob;
        if(!test.isRunningTest())
            pdfPageBlob = pagePdf.getContent();
        else
            pdfPageBlob=Blob.valueOf('Unit Test');
        Attachment a = new Attachment();
        a.Body = pdfPageBlob;
        a.ParentID = Ltid;
        a.Name = 'Transaction Submitted'+' - '+Lttype+'-'+Cdate+'-'+username+'.pdf';
        a.Description = 'Report Submitted';
        insert a;
    }*/
    @future(callout=true)
    public static void createAndInsertAttachment(Id Ltid) {
        PageReference pagePdf;
        string username = userinfo.getname();
        string Cdate = system.today().format();
        Licensing_Transaction__c lt = [select id,name,Provider__c, Provider__r.RecordType.DeveloperName from Licensing_Transaction__c where id = :Ltid];
        string Lttype = lt.RecordType.Name;
        String LtName = lt.Name;
        String provType = lt.Provider__r.RecordType.DeveloperName;
        if (provType == EEC_Constants.PRO_FCC) {
            pagePdf = new PageReference('/apex/EEC_ReviewSummarySubmissionPDF');
            pagePdf.getParameters().put('ltId', Ltid);
            pagePdf.getParameters().put('member', lt.Provider__c);
        } else if (provType == EEC_Constants.PRO_FCC_ASSISTANT) {
            pagePdf = new PageReference('/apex/EEC_ReviewSummarySubmissionAssistantPDF');
            pagePdf.getParameters().put('ltId', Ltid);
            pagePdf.getParameters().put('member', lt.Provider__c);
        } else if (provType == 'Large_Group' || provType == 'Small_Group') {
            pagePdf = new PageReference('/apex/eec_gsareviewsummaryPDF');
            pagePdf.getParameters().put('ltId', Ltid);
            pagePdf.getParameters().put('member', lt.Provider__c);
        } else if (provType == EEC_Constants.PRO_ADOPTION_AGENCY || provType == 'Foster_Care_Agency' || provType == 'Group_Care' || provType == 'Temporary_Shelter') {
            pagePdf = new PageReference('/apex/EEC_RP_ReviewSummaryPDF');
            pagePdf.getParameters().put('ltId', Ltid);
            pagePdf.getParameters().put('member', lt.Provider__c);
        }else if(provType ==EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER || provType == EEC_Constants.PRO_PRIVATE_SCHOOL || provType == EEC_Constants.PRO_PUBLIC_SCHOOL ){
            pagePdf = new PageReference('/apex/EEC_CBCReviewSummaryPDF');
            pagePdf.getParameters().put('ltId', Ltid);
            pagePdf.getParameters().put('member', lt.Provider__c);
        }/*else if(provType ==EEC_Constants.PRO_SUMMER_CAMP){
            pagePdf = new PageReference('/apex/EEC_SMReviewSummaryPDF');
            pagePdf.getParameters().put('ltId', Ltid);
            pagePdf.getParameters().put('member', lt.Provider__c);
        }*/ else if(provType ==EEC_Constants.PRO_INFORMAL_CHILD_CARE){
            pagePdf = new PageReference('/apex/EEC_ICCReviewSummarypdf');
            pagePdf.getParameters().put('ltId', Ltid);
            pagePdf.getParameters().put('member', lt.Provider__c);
        } 
        Blob pdfPageBlob;
        if (!test.isRunningTest()) {
            try {
                pdfPageBlob = pagePdf.getContentAsPDF();
            } catch (Exception ex) {
            }
        } else {
            pdfPageBlob = Blob.valueOf('Unit Test');
        }
        Attachment a = new Attachment();
        a.Body = pdfPageBlob;
        a.ParentID = Ltid;
        a.Name = Lttype + '-' + LtName + '.pdf';
        a.Description = 'Report Submitted';
        insert a;
    }
    public Pagereference SaveAndReturnRS() {
        licenseTransation.Last_Reached_Step__c = (isFccAssistant ? 'Assistant Review Summary and Submission' : EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION);
        update licenseTransation;
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            pPage.setRedirect(true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
   @TestVisible private void saveLS() {
    }
   @TestVisible private void saveEH() {
        if (ehList != null) {
            for (Employment_History__c eh : ehList) {
                if (loggedUser.contactId != null) {
                    eh.Contact__c = loggedUser.contactId;
                } else {
                    if (listContact.size() > 0)
                        eh.Contact__c = listContact[0].Id;
                }
                if (eh.Licensing_Transaction__c == null && licenseTransation.Id != null)
                    eh.Licensing_Transaction__c = licenseTransation.Id;
            }
            if (!isSubmitted) {
                upsert ehList;
            }
        }
        if (removeEHList != null && removeEHList.size() > 0 && !isSubmitted) {
            delete removeEHList;
        }
    }
  @TestVisible  private void saveGSARoom() {
        RecordType rType = [select Id from RecordType where DeveloperName = 'Room_GSA' and SobjectType = 'Room__c'];
        if (roomList != null) {
            for (Room__c rm : roomList) {
                rm.Current__c = true;
                if (rm.Id == null) {
                    rm.Source_Transaction__c = licenseTransation.Id;
                    rm.RecordTypeId = rType.Id;
                    rm.Provider_No__c = provider.Id;
                }
            }
            if (!isSubmitted) {
                upsert roomList;
            }
        }
        if (removeRoomList != null && removeRoomList.size() > 0 && !isSubmitted) {
            delete removeRoomList;
        }
    }
  @TestVisible  private void saveRoom() {
        String selectedHest = '';
        Boolean Start = true;
      system.debug('selectedHestElems<<'+selectedHestElems);
        if (!selectedHestElems.isEmpty()) {
            for (String Str : selectedHestElems) {
                if (Start) {
                    selectedHest = Str;
                    Start = false;
                } else {
                    selectedHest = selectedHest + ';' + Str;
                }
            }
        }
        licenseTransation.Heating_Elements__c = selectedHest;
        if (!isSubmitted) {
            update licenseTransation;
        }
        if (LicenseRecordTypeName != EEC_Constants.LT_FCC_RENEWAL) {
            RecordType rType = [select Id from RecordType where DeveloperName = 'Room_FCC' and SobjectType = 'Room__c'];
            if (roomList != null) {
                for (Room__c rm : roomList) {
                    rm.Current__c = true;
                    if (rm.Id == null) {
                        rm.Source_Transaction__c = licenseTransation.Id;
                        rm.RecordTypeId = rType.Id;
                        rm.Provider_No__c = provider.Id;
                    }
                }
                if (!isSubmitted) {
                    upsert roomList;
                }
            }
            if (removeRoomList != null && removeRoomList.size() > 0 && !isSubmitted) {
                delete removeRoomList;
            }
        }
    }
   @TestVisible private void saveTE() {
        if (!isSubmitted) {
            update licenseTransation;
        }
        if (teList != null) {
            for (Training_Experience__c tfa : teList) {
                if (tfa.Id == null) {
                    if (loggedUser.contactId != null) {
                        tfa.Contact__c = loggedUser.contactId;
                    } else {
                        tfa.Contact__c = cntct.Id;
                    }
                }
                tfa.Licensing_Transactions__c = licenseTransation.Id;
            }
            if (!isSubmitted) {
                upsert teList;
            }
        }
        if (removeTEList != null && removeTEList.size() > 0) {
            delete removeTEList;
        }
    }
    public Boolean getIsTransactionEditiable() {
        return(licenseTransation.Status__c == EEC_Constants.LT_UNSUBMITTED);
    }
   @TestVisible private Boolean isStatusClosed(String status) {
        return(status == 'Submitted' || status == 'Unsubmitted' || status == 'Under Review');
    }
   @TestVisible private void initializeLS() {
        initLS = true;
        Set<Id> recordTypeIdSet = new Set<Id> ();
        if (LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE) {
            recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.FCC_New_License').Id);
            recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.FCC_Renewal').Id);
            recordTypeIdSet.add(EEC_RecordTypeUtil.findByName('Licensing_Transaction__c.FCC_License_Upgrade').Id);
            List<Licensing_Transaction__c> tltList = [
                    select Ownership_Type__c, Provider__r.License_Type__c, Date_Taken_Intro_EEC_in_MA_orientation__c, Id, Caring_For_Children_Not_Related__c,
                            Evening_Overnight_Weekend_Care__c, Children_Home_Schooled__c,Completed_30_hours_of_Training__c,Plan_for_training_completion__c,Plan_for_diverse_learners_training__c,Address_diverse_learners_hours__c,
                            Children_Home_Schooled_Description__c,
                            Business_Operated_Out_of_Own_Home__c, Bus_Operated_Out_of_Own_Home_Descrip__c,
                            Becoming_Foster_Care_Provider__c,
                            Previous_Involvement_with_EEC_for_Unlice__c,Daily_Routine_and_Activities__c,Drop_in_Service_Description__c,Gym_Facility_Used_in_Program_Hours_Desc__c,Cafeteria_Used_During_Program_Hours_Desc__c,Summer_Camp_Service_Description__c,Evenings_Service_Description__c,Previous_Involvement_with_EEC__c,New_Name__c, Previous_Application_Certif_with_EEC__c, Prev_App_Certif_with_EEC_Descrip__c, Prev_App_Certif_with_Another_State__c,
                            Prev_App_Certif_with_Another_State_Desc__c, Abused_or_neglected_a_child__c, Abused_or_neglected_a_child_Description__c, Certificate_of_License_Revoked_Suspend__c, Certificate_or_License_Surrendered__c, Revocation_Suspension_Surrender_Reas__c,Surrendered_Certificate_License__c,Date_Name_Change_is_Effective__c,
                            Experience_Caring_for_Children_QUalifica__c, Child_Emergency_Injury_Last_3_Years__c, Child_Emerg_Injury_Last_3_Years_Descrip__c, Charged_or_Arrested_for_Crime__c,
                            Charges_Description__c, Dealings_with_Child_Prot_Child_Welfar__c, Dealing_with_Child_Prot_Welfar_Descri__c, Registering_as_Sex_Offender__c, Sex_Offender_Nature_of_Incident__c,
                            Restraining_Order_Issued__c, Alcoholic_Bev_Narcotics_Drugs_Desc__c, Caring_for_your_own_children_Years__c, Caring_for_your_own_children_Months__c, Caring_for_your_own_children_Hrs_Week__c, Caring_Other_People_Children_End_Date__c, Caring_Other_People_Children_Start_Date__c, Submitter__r.Name, Assigned_User_Email__c
                    from Licensing_Transaction__c
                    where provider__c = :provider.Id and Id != :licenseTransation.Id and (Status__c != :EEC_Constants.LT_CANCELLED and Status_Reason__c != :EEC_Constants.LT_CLOSED_EEC_APPLICATION_INCOMPLETE_DENIED)
                    order by createddate desc
                    limit 1
            ];
            if (tltList != null && tltList.size() > 0) {
                Licensing_Transaction__c lt = tltList.get(0);
                licenseTransation.Caring_For_Children_Not_Related__c = lt.Caring_For_Children_Not_Related__c;
                licenseTransation.Evening_Overnight_Weekend_Care__c = lt.Evening_Overnight_Weekend_Care__c;
                licenseTransation.Children_Home_Schooled__c = lt.Children_Home_Schooled__c;
                licenseTransation.Children_Home_Schooled_Description__c = lt.Children_Home_Schooled_Description__c;
                //censeTransation.Approved_Foster_Care_Provider__c = lt.Approved_Foster_Care_Provider__c;
              //  licenseTransation.Approved_Foster_Care_Provider_Descrip__c = lt.Approved_Foster_Care_Provider_Descrip__c;
                licenseTransation.Becoming_Foster_Care_Provider__c = lt.Becoming_Foster_Care_Provider__c;
                //licenseTransation.Becoming_Foster_Care_Provider_Descrip__c = lt.Becoming_Foster_Care_Provider_Descrip__c;
                licenseTransation.Business_Operated_Out_of_Own_Home__c = lt.Business_Operated_Out_of_Own_Home__c;
                licenseTransation.Bus_Operated_Out_of_Own_Home_Descrip__c = lt.Bus_Operated_Out_of_Own_Home_Descrip__c;
             //   licenseTransation.Use_Family_Child_Care_System__c = lt.Use_Family_Child_Care_System__c;
               // licenseTransation.Use_Family_Child_Care_System_Descrip__c = lt.Use_Family_Child_Care_System_Descrip__c;
                //licenseTransation.Working_With_Assistant__c = lt.Working_With_Assistant__c;
            }
        }
    }
    private void initializeIndoor() {
        selectedHestElems = new List<String> ();
        initIndoor = true;
        List<Licensing_Transaction__c> tltList = [
                select Id, Ownership_Type__c, Exits_Descriptions__c, Heating_Elements__c,
                        Need_Assist_to_Barricade_Heating_Units__c, Drinking_Water_Source__c,New_Name__c, Caring_for_your_own_children_Years__c, Caring_for_your_own_children_Months__c, Caring_for_your_own_children_Hrs_Week__c, Caring_Other_People_Children_End_Date__c, Caring_Other_People_Children_Start_Date__c,  Submitter__r.Name, Assigned_User_Email__c
                from Licensing_Transaction__c
                where provider__c = :provider.Id and Id != :licenseTransation.Id and (Status__c != :EEC_Constants.LT_CANCELLED and Status_Reason__c != :EEC_Constants.LT_CLOSED_EEC_APPLICATION_INCOMPLETE_DENIED) and
                RecordType.DeveloperName in(:EEC_Constants.LT_FCC_NEW_LICENSE, :EEC_Constants.LT_FCC_LICENSE_UPGRADE , :EEC_Constants.LT_FCC_RENEWAL, :EEC_Constants.LT_FCC_CHANGE_ROOM_FLOOR_LEVEL, :EEC_Constants.LT_CHANGE_OF_ADDRESS)
                order by createddate desc
                limit 1
        ];
        Licensing_Transaction__c lt;
        roomList = new List<Room__c> ();
        if (tltList != null && tltList.size() > 0 && LicenseRecordTypeName != EEC_Constants.LT_FCC_NEW_LICENSE) {
            lt = tltList.get(0);
            //licenseTransation.FCC_Residence_Description__c = lt.FCC_Residence_Description__c;
            //licenseTransation.At_Least_2_Exits__c = lt.At_Least_2_Exits__c;
            licenseTransation.Exits_Descriptions__c = lt.Exits_Descriptions__c;
            licenseTransation.Heating_Elements__c = lt.Heating_Elements__c;
            licenseTransation.Need_Assist_to_Barricade_Heating_Units__c = lt.Need_Assist_to_Barricade_Heating_Units__c;
            licenseTransation.Drinking_Water_Source__c = lt.Drinking_Water_Source__c;
          //  licenseTransation.Outdoor_Space_Changed__c = lt.Outdoor_Space_Changed__c;
           // licenseTransation.Outdoor_Space_Changes_Description__c = lt.Outdoor_Space_Changes_Description__c;
            if (String.isNotEmpty(lt.Heating_Elements__c)) {
                selectedHestElems = lt.Heating_Elements__c.split(';');
            }
            Room__c tRoom;
            if (lt.Rooms__r != null && lt.Rooms__R.size() > 0) {
                for (Room__c rm : lt.Rooms__r) {
                    tRoom = new Room__c();
                    tRoom.Name = rm.Name;
                    tRoom.Use__c = rm.Use__c;
                    tRoom.Dimension_Length_feet__c = rm.Dimension_Length_feet__c;
                    tRoom.Dimension_Width_feet__c = rm.Dimension_Width_feet__c;
                    tRoom.Floor_Level__c = rm.Floor_Level__c;
                    tRoom.Source_Transaction__c = licenseTransation.Id;
                    roomList.add(tRoom);
                }
                if (!isSubmitted) {
                    insert roomList;
                }
            }
        }
    }
    public void initializeTraining() {
        initTraining = true;
        List<Licensing_Transaction__c> tltList = [
                select Id, Date_Taken_Intro_EEC_in_MA_orientation__c, RecordType.DeveloperName,
                        Date_Med_Administration_Training_Taken__c, Took_Transportation_Training__c,New_Name__c,
                        Date_Transportation_Training_Taken__c, Took_SIDS_Training__c, Date_Last_SIDS_Training_Taken__c, Took_USDA_Nutrition_Training__c,
                        Date_USDA_Nutrition_Training_Taken__c, Took_Upgrading_Capacity_Training__c, Date_Upgrading_Capacity_Training_Taken__c,
                        Date_FCC_Orientation_Taken__c, CPR_Certified__c, CPR_Certification_Issue_Date__c, First_Aid_Certified__c,Parental_Consent_forms__c,
                        First_Aid_Certification_Issue_Date__c, Took_FCC_Orientation_Module_1__c, Date_FCC_Orientation_Mod_1_Taken__c, (select Id, Name, Topic__c, Number_of_Training_Hours__c, Date_of_the_Training__c from Training_Experience__r)
                from
                        Licensing_Transaction__c
                where provider__c = :provider.Id and Id != :licenseTransation.Id and (Status__c != :EEC_Constants.LT_CANCELLED and Status_Reason__c != :EEC_Constants.LT_CLOSED_EEC_APPLICATION_INCOMPLETE_DENIED) and
                RecordType.DeveloperName in( :EEC_Constants.LT_FCC_NEW_LICENSE, :EEC_Constants.LT_FCC_LICENSE_UPGRADE)
                order by createddate desc
                limit 1
        ];
        Licensing_Transaction__c lt;
        Licensing_Transaction__c rlt;
        teList = new List<Training_Experience__c> ();
        if (tltList != null && tltList.size() > 0) {
            lt = tltList.get(0);
            //licenseTransation.Belong_to_Food_Program__c = lt.Belong_to_Food_Program__c;
           // licenseTransation.Which_Food_Program__c = lt.Which_Food_Program__c;
            //licenseTransation.Took_Medication_Administration_Training__c = lt.Took_Medication_Administration_Training__c;
            licenseTransation.Date_Med_Administration_Training_Taken__c = lt.Date_Med_Administration_Training_Taken__c;
            licenseTransation.Took_Transportation_Training__c = lt.Took_Transportation_Training__c;
            licenseTransation.Date_Transportation_Training_Taken__c = lt.Date_Transportation_Training_Taken__c;
            licenseTransation.Took_USDA_Nutrition_Training__c = lt.Took_USDA_Nutrition_Training__c;
            licenseTransation.Date_USDA_Nutrition_Training_Taken__c = lt.Date_USDA_Nutrition_Training_Taken__c;
            licenseTransation.Took_Upgrading_Capacity_Training__c = lt.Took_Upgrading_Capacity_Training__c;
            licenseTransation.Date_Upgrading_Capacity_Training_Taken__c = lt.Date_Upgrading_Capacity_Training_Taken__c;
           // licenseTransation.Took_FCC_Orientation__c = lt.Took_FCC_Orientation__c;
            licenseTransation.Date_FCC_Orientation_Taken__c = lt.Date_FCC_Orientation_Taken__c;
            licenseTransation.Took_FCC_Orientation_Module_1__c = lt.Took_FCC_Orientation_Module_1__c;
            licenseTransation.Date_FCC_Orientation_Mod_1_Taken__c = lt.Date_FCC_Orientation_Mod_1_Taken__c;
            for (Licensing_Transaction__c lt1 : tltList) {
                if (lt.RecordType.DeveloperName == EEC_Constants.LT_FCC_RENEWAL) {
                    rlt = lt1;
                    Training_Experience__c te;
                    if (rlt.Training_Experience__r != null && rlt.Training_Experience__r.size() > 0) {
                        for (Training_Experience__c rm : lt.Training_Experience__r) {
                            te = new Training_Experience__c();
                            te.Topic__c = rm.Topic__c;
                            te.Date_of_the_Training__c = rm.Date_of_the_Training__c;
                            te.Number_of_Training_Hours__c = rm.Number_of_Training_Hours__c;
                            te.Licensing_Transactions__c = licenseTransation.Id;
                            if (loggedUser.contactId != null) {
                                te.Contact__c = loggedUser.contactId;
                            }
                            teList.add(te);
                        }
                        if (!isSubmitted) {
                            insert teList;
                        }
                    }
                    break;
                }
            }
        }
    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('Yes', 'Yes'));
        options.add(new SelectOption('No', 'No'));
        return options;
    }
    public List<SelectOption> getSupply() {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('Private Water Supply', 'Private Water Supply'));
        options.add(new SelectOption('Town Water Supply', 'Town Water Supply'));
        return options;
    }
    public List<SelectOption> getGrps() {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption(EEC_Constants.LT_GROUP_TYPE_SMALL_GROUP, EEC_Constants.LT_GROUP_TYPE_SMALL_GROUP));
        options.add(new SelectOption(EEC_Constants.LT_GROUP_TYPE_LARGE_GROUP, EEC_Constants.LT_GROUP_TYPE_LARGE_GROUP));
        return options;
    }
/**
*Operation Period - Full Day Program
* @author Rohit
*/
    public List<SelectOption> weekDays {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry f : Licensing_Transaction__c.Available_Days_Full_day_program__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
        }
        set;
    }
    public String[] selectedDay {
        get {
            String[] selected = new List<String>();
            List<SelectOption> sos = this.weekDays;
            for (SelectOption s : sos) {
                if (this.licenseTransation.Available_Days_Full_day_program__c != null && this.licenseTransation.Available_Days_Full_day_program__c.contains(s.getValue()))
                    selected.add(s.getValue());
            }
            return selected;
        }
        public set {
            String selectedCheckBox = '';
            for (String s : value) {
                if (selectedCheckBox == '')
                    selectedCheckBox += s; else selectedCheckBox += ';' + s;
            }
            licenseTransation.Available_Days_Full_day_program__c = selectedCheckBox;
            if (selectedCheckBox != null || selectedCheckBox != '') {
                isSelectedDay = true;
            } else {
                isSelectedDay = false;
            }
        }
    }
    public Boolean isSelectedDay { get; set; }
    public void opsFullDay() {
        isSelectedDay = true;
    }
/**
*Operation Period - Half Day Morning Program
* @author Rohit
*/
    public List<SelectOption> weekHalfDays {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry f : Licensing_Transaction__c.Available_Days_Morning_program__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
        }
        set;
    }
    public String[] selectedHalfDay {
        get {
            String[] selected = new List<String>();
            List<SelectOption> sos = this.weekHalfDays;
            for (SelectOption s : sos) {
                if (this.licenseTransation.Available_Days_Morning_program__c != null && this.licenseTransation.Available_Days_Morning_program__c.contains(s.getValue()))
                    selected.add(s.getValue());
            }
            return selected;
        }
        public set {
            String selectedHalfCheckBox = '';
            for (String s : value) {
                if (selectedHalfCheckBox == '')
                    selectedHalfCheckBox += s; else selectedHalfCheckBox += ';' + s;
            }
            licenseTransation.Available_Days_Morning_program__c = selectedHalfCheckBox;
            if (selectedHalfCheckBox != null || selectedHalfCheckBox != '') {
                isSelectedHalfDay = true;
            } else {
                isSelectedHalfDay = false;
            }
        }
    }
    public Boolean isSelectedHalfDay { get; set; }
    /**
*Operation Period - Half Day Afternoon Program
* @author Rohit
*/
    public List<SelectOption> weekHalfAfterDays {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry f : Licensing_Transaction__c.Available_Days_Afternoon_program__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
        }
        set;
    }
    public String[] selectedHalfAfterDay {
        get {
            String[] selected = new List<String>();
            List<SelectOption> sos = this.weekHalfAfterDays;
            for (SelectOption s : sos) {
                if (this.licenseTransation.Available_Days_Afternoon_program__c != null && this.licenseTransation.Available_Days_Afternoon_program__c.contains(s.getValue()))
                    selected.add(s.getValue());
            }
            return selected;
        }
        public set {
            String selectedHalfAfterCheckBox = '';
            for (String s : value) {
                if (selectedHalfAfterCheckBox == '')
                    selectedHalfAfterCheckBox += s; else selectedHalfAfterCheckBox += ';' + s;
            }
            licenseTransation.Available_Days_Afternoon_program__c = selectedHalfAfterCheckBox;
            if (selectedHalfAfterCheckBox != null || selectedHalfAfterCheckBox != '') {
                isSelectedHalfAfterDay = true;
            } else {
                isSelectedHalfAfterDay = false;
            }
        }
    }
    public Boolean isSelectedHalfAfterDay { get; set; }
    /**
    *Operation Period - Extended Days
    * @author Rohit
    */
    public List<SelectOption> weekExtendDays {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry f : Licensing_Transaction__c.Extended_Days_Available__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
        }
        set;
    }
    public List<SelectOption> weekExtendDays1 {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry f : Licensing_Transaction__c.Extended_Days_Available_Option_2__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
        }
        set;
    }
    public List<String> getFCCEducatorList {
        get {
            List<String> fccEducator = new List<String>();
            for (Account acc : [
                    Select Id, Name, Provider_Address_1__c, Provider_City__r.Name,
                            State__c,Provider_Zip_Code__c
                    From Account
                    Where recordType.developerName = :EEC_Constants.PRO_FCC
                    AND License_Status__c = :EEC_Constants.PRO_LICENSED
                    LIMIT 10000
            ]) {
                fccEducator.add(acc.Name + '-' + acc.Provider_Address_1__c + ',' + acc.Provider_City__r.Name + ',' + acc.State__c + ',' + acc.Provider_Zip_Code__c);
            }
            return fccEducator;
        }
        set;
    }
    public Boolean isSelectedExtendDay { get; set; }
    public Boolean isSelectedExtendDay1 { get; set; }
    public String[] selectedExtendDay {
        get {
            String[] selected = new List<String>();
            List<SelectOption> sos = this.weekExtendDays;
            for (SelectOption s : sos) {
                if (this.licenseTransation.Extended_Days_Available__c != null && this.licenseTransation.Extended_Days_Available__c.contains(s.getValue()))
                    selected.add(s.getValue());
            }
            return selected;
        }
        public set {
            String selectedExtendedDaysCheckBox = '';
            for (String s : value) {
                if (selectedExtendedDaysCheckBox == '')
                    selectedExtendedDaysCheckBox += s; else selectedExtendedDaysCheckBox += ';' + s;
            }
            licenseTransation.Extended_Days_Available__c = selectedExtendedDaysCheckBox;
            if (selectedExtendedDaysCheckBox != null || selectedExtendedDaysCheckBox != '') {
                isSelectedExtendDay = true;
            } else {
                isSelectedExtendDay = false;
            }
        }
    }
    public String[] selectedExtendDay1 {
        get {
            String[] selected = new List<String>();
            List<SelectOption> sos = this.weekExtendDays1;
            for (SelectOption s : sos) {
                if (this.licenseTransation.Extended_Days_Available_Option_2__c != null && this.licenseTransation.Extended_Days_Available_Option_2__c.contains(s.getValue()))
                    selected.add(s.getValue());
            }
            return selected;
        }
        public set {
            String selectedExtendedDaysCheckBox = '';
            for (String s : value) {
                if (selectedExtendedDaysCheckBox == '')
                    selectedExtendedDaysCheckBox += s; else selectedExtendedDaysCheckBox += ';' + s;
            }
            licenseTransation.Extended_Days_Available_Option_2__c = selectedExtendedDaysCheckBox;
            if (selectedExtendedDaysCheckBox != null || selectedExtendedDaysCheckBox != '') {
                isSelectedExtendDay1 = true;
            } else {
                isSelectedExtendDay1 = false;
            }
        }
    }
    public List<SelectOption> getHeatingElements() {
        List<SelectOption> hElements = new List<SelectOption> ();
        Schema.DescribeFieldResult fieldResult = Licensing_Transaction__c.Heating_Elements__c.getDescribe();
        list<schema.picklistentry> values = fieldResult.getPickListValues();
        for (Schema.PicklistEntry a : values) {
            hElements.add(new SelectOption(a.getValue(), a.getLabel()));
        }
        return hElements;
    }
    public void getLicenseTrans(String ltId) {
        selectedHestElems = new List<String> ();
        List<Licensing_Transaction__c> ltList = [
                Select Reopen__c,Created_by_EEC__c,Commute_to_offsite_play_location__c,l.Recving_search_and_or_reunion_service1__c,Are_you_switching_small_to_large_group__c, Provider__r.Licensor_Full_Name__c, Provider__r.Licensor_Phone__c, 
                        Gender_of_children_served__c,Minimum_age_of_children_served__c,Requested_capacity__c,Awake_Staff_to_child_ratio__c, Awake_Staff_to_child_ratio_Staff__c, Awake_Staff_to_child_ratio_Child__c, Asleep_Staff_to_child_ratio__c,
                        Overnight_Staff_to_child_ratio_Staff__c,Ratio_comments__c,Maximum_age_of_children_served__c,Characteristics_of_children_served__c, Provider__r.Is_Residential__c,Ownership_Type__c,Provider__r.Summer_Camp_Permit__c,Provider__r.Provider_Address_2__c,
                        Provider__r.Provider_City__c,Provider__r.Provider_Zip_Code__c,Provider__r.State__c,Provider__r.ShippingStreet,Provider__r.ShippingCity,Provider__r.ShippingPostalCode,Provider__r.ShippingState,Provider__r.Phone, Provider__r.Alternate_Phone__c,Provider__r.Fax,Provider__r.Provider_Email__c,Provider__r.Capacity__c,Provider__r.Ownerid,
                        Provider__r.Name, Provider__r.License_Type__c, Date_Taken_Intro_EEC_in_MA_orientation__c, IsProviderUpgrade__c, IsAssistantUpgradeToCertified__c,Provider__r.Financial_Documentation_Responsible__c,
                        l.Transportation_Training_Cert__c, l.Training_Review__c,l.Accounts_Responsible__c,l.Records_Responsible__c,l.Personnel_Records_Responsible__c,l.Children_Records_Responsible__c,l.Financial_Documentation_Responsible__c,l.Staff_Schedule_Responsible__c,l.ECE_program_Responsible__c,l.Kindergarten_Responsible__c,l.School_age_Responsible__c,
                        l.Services_4_Disable_children_Responsible__c,l.Daily_activities_Responsible__c,l.Equipment_Responsible__c,l.Staff_Development_Responsible__c,l.Staff_Training_Responsible__c,l.Staff_Orientation_Responsible__c,l.Staff_Supervision_Responsible__c,l.Parent_Involvement_Responsible__c,l.Social_Services_Responsible__c,l.Infant_Toddler_Program_Responsible__c,l.Indoor_Square_Footage__c,
                        l.Number_of_toilets_c__c,l.Number_of_sinks__c,l.Lead_Paint_Compliance__c,l.Lead_Paint_Constructed_before_1978__c,l.Lead_Paint_Detailed_Inspection__c,l.Building_Inspection_Max_Capacity__c,l.Building_inspection_expiration_Date__c,l.Building_Codes_c__c,l.Health_Inspection_Expiration_Date__c,
                        l.Camp_Permit_Number__c,l.Camp_Permit_Issue_Date__c,l.Summer_Camp_Permit__c, l.Took_Upgrading_Capacity_Training__c, l.Took_USDA_Nutrition_Training__c,l.New_Name__c, l.New_City__c,l.New_City__r.Name,l.Previous_State__c, l.Took_Transportation_Training__c, l.Took_SIDS_Training__c, l.New_State__c,l.To_Process_Flag__c,
                        l.Technical_Assistance__c, l.Tax_Certification_Status__c, l.Submission_Date__c, l.Name, l.Tax_Certification_Statement_Request_Date__c, l.Tax_Cert_Statement_Signed_Date__c, l.Submitter__c, l.Submitter_Email_Address__c,Outdoor_Square_footage__c,
                        Is_this_an_indoor_pool__c,Do_you_have_a_pool__c,Pool_Inspection_Date__c,Transportation_provided1__c,Transportation__c,Are_you_adding_space__c,Offsite_outdoor_play_location1__c,Pool_roof_inspection_date__c,Other_Approved_Additional_Space__c,Operation_End_Month__c,
                        l.Stove_Meets_Requirements_Evidence__c, l.Status__c, l.Source__c, l.Sex_Offender_Nature_of_Incident__c, l.SIDS_Training_Cert__c, l.Revocation_Suspension_Surrender_Reas__c,l.Surrendered_Certificate_License__c, l.Restraining_Order_Issued__c, l.Restraining_Order_Description__c, l.Registering_as_Sex_Offender__c,l.RecordTypeId, l.Alcoholic_Bev_Narcotics_Drugs_Desc__c,
                        l.Reason_for_Request__c,l.Drop_in_Service_Description__c,l.Gym_Facility_Used_in_Program_Hours_Desc__c,l.Cafeteria_Used_During_Program_Hours_Desc__c,l.Summer_Camp_Service_Description__c,l.Evenings_Service_Description__c,l.Previous_Involvement_with_EEC_for_Unlice__c,l.Previous_Involvement_with_EEC__c,
                        l.Previous_Application_Certif_with_EEC__c, l.Prev_App_Certif_with_EEC_Descrip__c, l.Prev_App_Certif_with_Another_State__c,Other_Referral_Agency__c,International_adoption_countries__c,Other_countries__c,Number_of_Adoptive_Placements__c,Number_of_Foster_Homes__c,Number_of_birth_mothers_recving_services__c,Birth_mothers_making_adoption_plans__c,Number_of_Waiting_Families__c,
                        Families_recving_home_study_services__c,Recving_search_and_or_reunion_services__c,DCF_Nb_Children_Placed_In_Care__c,l.Prev_App_Certif_with_Another_State_Desc__c,l.Address_of_admin_for_funding_source__c,l.Name_of_contract_administrator__c,Number_of_Home_Study_Services__c,Families_recving_case_mgmt_services__c,Families_recving_information_referral__c,
                        l.Is_your_program_contracted__c, l.Observations_Comments__c, l.No_Condition_Flag__c,Provider__r.Camp_Permit_Issue_Date__c,Provider__r.Camp_Permit_Number__c,
                        l.Number_of_Open_Foster_Homes__c,l.Number_of_children_placed_in_care__c,l.New_Zip_Code__c, l.New_Street_Address_2__c, l.New_Street_Address_1__c, l.New_Address_Phone_Number__c, l.Need_Assist_to_Barricade_Heating_Units__c, l.Moving_Date__c, l.Missing_Elements_For_Finalizing__c, l.Medication_Administration_Training_Cert__c,Number_recving_Search_reunion_services__c,
                        l.Start_Time_Afternoon_program__c,l.End_Time_Afternoon_program__c,l.Available_Days_Afternoon_program__c,provider__r.Umbrella_Members__r.Name,provider__r.Umbrella_Members__r.Provider_Address_1__c,provider__r.Umbrella_Members__r.Provider_City__c,provider__r.Umbrella_Members__r.Provider_Zip_Code__c,provider__r.Umbrella_Members__r.State__c,provider__r.Provider_City__r.Name,
                        l.Live_at_New_Address__c,l.Available_Days_Full_day_program__c,l.Start_Time_Morning_program__c,l.End_Time_Morning_program__c,l.Available_Days_Morning_program__c,l.Start_Time_Full_day_program__c,l.End_Time_Full_day_program__c, l.Licensee_BRC_Consent_Status__c, l.Licensee_BRC_Consent_Signed_Date__c, l.Licensee_BRC_Consent_Request_Date__c, Submitter__r.FirstName, Submitter__r.LastName,
                        l.ProgramLicensedOrApproved__c,l.Current_Provider_Capacity__c,l.ProgramContracted__c,Out_of_state_childcare_related_licenses1__c,Out_of_state_license_appl_in_process1__c,Admin_Civil_criminal_action_last_5_yrs1__c,State_Federal_investigation_last_5_yrs1__c,Number_of_Reunions_Facilitated__c,Number_of_Child_Assessments__c,
                        l.License_Type__c,l.Operation_Type__c,l.Small_Group_Capacity__c, l.License_Requested__c, l.License_Issue_Date__c, l.Program_licensed_or_approved_by_agency__c, l.Last_Reached_Step__c, l.Indoor_Outdoor_Space_Review__c, l.Id, l.Heating_Elements__c, l.Floors_Description__c, l.First_Aid_Certified__c, l.First_Aid_Certification_Issue_Date__c,
                        l.FCC_Orientation_Module_II_Evidence__c, FCC_Orientation_Module_I_Evidence__c, l.Experience_Caring_for_Children_QUalifica__c,l.Previous_Street_Address_1__c,l.Previous_Street_Address_2__c,l.Previous_City__c,l.Previous_City__r.Name,l.Previous_Zip_Code__c,
                        l.Infant_Capacity__c,l.Infant_Toddler_Capacity__c,l.Toddler_Capacity__c,l.Toddler_Preschool_Capacity__c,l.Preschool_Capacity__c,l.Preschool_SA_Capacity__c,Assigned_To__r.FirstName, Assigned_To__r.LastName, Assigned_To__r.Phone, Assigned_To__r.Email,
                        l.Kindergarten_Capacity__c,l.School_Age_Capacity__c,l.Multi_Age_Group_Capacity__c,l.Kindergarten_School_Age__c,l.Total_License_Capacity_Requested__c,l.Minimum_Age_Limit_Requested_Years__c, l.Submitter__r.Name, l.Assigned_User_Email__c,
                        l.Provide_Extended_Days1__c,l.Extended_Days_Available__c,l.Extended_Days_Available_Option_2__c,l.Gym_Facility_Used_During_Program_Hours1__c,l.Drop_in_Service1__c,
                        l.Minimum_Age_Limit_Requested_Months__c,l.Maximum_Age_Limit_Requested_Months__c,l.Maximum_Age_Limit_Requested_Years__c,l.Caring_for_your_own_children_Years__c, l.Caring_for_your_own_children_Months__c, l.Caring_for_your_own_children_Hrs_Week__c, l.Caring_Other_People_Children_End_Date__c, l.Caring_Other_People_Children_Start_Date__c,
                        l.Exits_Descriptions__c, l.Evening_Overnight_Weekend_Care__c, l.Drinking_Water_Source__c, l.Document_Information_Missing__c, l.Document_Info_Missing_Initial_Date__c, l.Dealings_with_Child_Prot_Child_Welfar__c, l.Dealing_with_Child_Prot_Welfar_Descri__c,
                        l.Date_Upgrading_Capacity_Training_Taken__c, l.Date_USDA_Nutrition_Training_Taken__c, l.Date_Transportation_Training_Taken__c, l.Date_Med_Administration_Training_Taken__c,l.Completed_30_hours_of_Training__c,l.Plan_for_training_completion__c,l.Plan_for_diverse_learners_training__c,l.Address_diverse_learners_hours__c,
                        l.Date_Last_SIDS_Training_Taken__c, l.Date_FCC_Orientation_Taken__c, l.Date_Closed__c, l.Date_Care_Resumes__c, l.Date_Activity_Ends__c, l.Daily_Routine_and_Activities__c, l.Condition_Added__c, l.Children_Home_Schooled__c, l.Children_Home_Schooled_Description__c, l.Child_Emergency_Injury_Last_3_Years__c,
                        l.Child_Emerg_Injury_Last_3_Years_Descrip__c, l.Charges_Description__c, l.Charged_or_Arrested_for_Crime__c, l.Certificate_or_License_Surrendered__c, l.Certificate_of_License_Revoked_Suspend__c, l.Caring_For_Children_Not_Related__c, l.Capacity__c, l.CPR_Certified__c, l.CPR_Certification_Issue_Date__c,
                        l.CPR_Certificate__c, l.Business_Operated_Out_of_Own_Home__c, l.Bus_Operated_Out_of_Own_Home_Descrip__c, l.Becoming_Foster_Care_Provider__c,l.Associated_Fee__c, l.Assigned_To__c, l.Approved_by_Manager__c,
                        l.Date_FCC_Orientation_Mod_1_Taken__c, l.Took_FCC_Orientation_Module_1__c, l.Abused_or_neglected_a_child__c, l.Abused_or_neglected_a_child_Description__c, 
                        Date_Name_Change_is_Effective__c,
                        Start_Time_Extended_Program__c,Start_Time_Extended_Program_Option_2__c,End_Time_Extended_Program_Option_2__c,End_Time_Extended_Program__c,
                        Provider__r.Type_of_Ownership__c,Purpose_Reason_for_the_move__c,Projected_Date_of_Return__c,How_Was_Projected_Date_Determined__c,
                        Existing_Fiduciary_Admin_relationships1__c,Provide_Half_Day_Afternoon_Program__c,Provide_Half_Day_Morning_Program__c,transactionRecordTypeDeveloperName__c,providerRecordTypeDeveloperName__c,
                        New_Umbrella_Name__c,Provide_Full_Day_Program__c,Early_childhood_education_program_N_A__c,
                        Provider_Fax_Number__c,Provider_Email__c,Provider_Alternate_Phone__c,Preferred_Language__c,Other_Non_English_Language__c,Can_Communicate_in_English__c,Race__c,
                        Prof_Qualification_Reg_Number__c,PQ_Expiration_Date__c,Provider__r.First_Issue_Date__c,
                        New_Umbrella_Business_Name__c,Increased_Capacity_Effective_Date__c,
                        NewUmbrella_Place_of_Incorporation__c,Early_childhood_edu_program_N_A_Notes__c,
                        NewUmbrella_Date_of_Incorporation__c,Kindergarten_Not_Applicable__c,School_Age_Not_Applicable__c,
                        NewUmbrella_Street_Address_1__c,Kindergarten_Not_Applicable_Notes__c,School_Age_Not_Applicable_Notes__c,Infant_Toddler_Not_Applicable__c,
                        NewUmbrella_Street_Address_2__c,Added_A_Coal_Pellet_Wood_Burning_Stove__c,Any_Indoor_Space_Changes__c,Infant_Toddler_Not_Applicable_Notes__c,
                        NewUmbrella_State__c,provider__r.Umbrella_Members__r.Provider_Address_2__c,provider__r.Umbrella_Members__r.Phone,provider__r.Umbrella_Members__r.Fax,
                        Do_you_hold_any_other_EEC_licenses__c,
                        Ever_involved_in_EEC_legal_action_Desc__c,provider__r.Umbrella_Members__r.Alternate_Phone__c,provider__r.Umbrella_Members__r.Provider_Email__c,
                        NewUmbrella_City__c,PPM_Attended_Date__c,provider__r.Umbrella_Members__r.Business_Name__c,provider__r.Umbrella_Members__r.Place_of_Incorporation__c,
                        NewUmbrella_Zip_Code__c,Mailing_City__c,Mailing_State__c,
                        NewUmbrella_Phone__c,Mailing_Street__c,Mailing_Zip__c,Do_you_live_at_this_address__c,
                        NewUmbrella_Alternate_Phone__c,Approved_to_care_subsidized_child__c,l.CCRR_Orientation_with_Date_of_Attendance__c,l.Parental_Consent_forms__c,
                        NewUmbrella_Email__c,
                        
                        NewUmbrella_Director_Last_Name__c,l.Date_Last_EEC_Essentials_Training_Taken__c,
                        NewUmbrella_Director_Phone__c,Is_Umbrella_Contact_Created__c,Approved_to_care_subsidized_child_desc__c,
                        Contact_Roles_Copied__c, Highest_Reached_Step__c,Evening_Overnight_Weekend_Care_Desc__c,Full_Names_And_Ages_of_The_Children__c,
                        Transaction_Configuration__r.EEC_Licensing_Transaction_Instructions__c,
                        Challenges_in_Compliance_Requirement_Oth__c,Challenges_in_BRC_requirements__c,
                        Certificate_of_Eligibility_for_Funding__c,
                       
                        Types_of_support_most_help__c,Challenges_in_Compliance_Requirements__c
                        ,Challenges_in_BRC_requirement_Other_Reas__c,
                        Challenges_in_Certificate_of_Eligibility__c,
                        NewUmbrella_Director_Email__c, (Select Id,Associated_Regulation__c,Associated_Regulation__r.Name,Associated_Regulation__r.Regulation_Number__c,Associated_Regulation__r.Article__c,Provider_Alternative_Method_to_Comply__c,Provider_Understanding_of_Regulation__c From Variance_on_Regulations__r)
                From Licensing_Transaction__c l
                where Id = :ltId
        ];
        //RIRH_Street_Address_2__c,RIRH_Zip_Code__c,Approved_to_care_subsidized_child__c,Approved_to_care_subsidized_child_desc__c,Name_of_Contact_Person__c,Providing_care_in_a_residence__c,What_is_the_purpose_of_your_program__c,Independent_Child_Care_Type__c,Where_will_child_care_be_occurring__c,RIRH_City__c,RIRH_State__c,RIRH_Street_Address_1__c,
        if (ltList != null && ltList.size() > 0) {
            licenseTransation = ltList.get(0);
            selectedOwnerShip = licenseTransation.Ownership_Type__c;
            //licenseRecordTypeName = licenseTransation.RecordType.DeveloperName;
            providerRecordType = licenseTransation.Provider__r.RecordType.Name;
            licenseRecordTypeLabel = licenseTransation.RecordType.Name;
            highestStepReached = licenseTransation.Highest_Reached_Step__c;
            IsAssistantUpgradeToCertified = licenseTransation.IsAssistantUpgradeToCertified__c;
            if (licenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
                formattedLicenseRecordTypeLabel = 'R&P Change of Admin Authority';
            } else {
                formattedLicenseRecordTypeLabel = licenseRecordTypeName.replaceAll('_', ' ');
            }
            listLicenseRequested = new List<selectOption>();
            listLicenseRequested.add(new SelectOption('', '--Select--'));
            if (string.isNotBlank(licenseTransation.Provider__r.Capacity__c) && licenseTransation.Provider__r.Capacity__c.contains('10')) {
                listLicenseRequested.add(new SelectOption('8', '8'));
                listLicenseRequested.add(new SelectOption('6', '6'));
            } else if (string.isNotBlank(licenseTransation.Provider__r.Capacity__c) && licenseTransation.Provider__r.Capacity__c.contains('8')) {
                //listLicenseRequested.add(new SelectOption('Up to 8 Children; 2 School Aged','Up to 8 Children; 2 School Aged'));
                listLicenseRequested.add(new SelectOption('6', '6'));
            } else {
                listLicenseRequested.add(new SelectOption('6', '6'));
            }
            doGetCity();
            selectedUmbrellaId = licenseTransation.Umbrella__c;
            provider = [
                    select Id,name,Umbrella_Members__c,Ownerid, Race__c, License_Type__c,Is_GSA__c,Is_R_P__c, is_FCC__c, Allow_Renewal_as_Assistant__c,State__c, License_Status__c, First_Issue_Date__c, Renewal_date__c, Provider_Status__c,
                            Accept_Referral__c, Account_books_Responsible__c,Records_Responsible__c,Personnel_Records_Responsible__c,Children_s_Records_Responsible__c,Financial_Documentation_Responsible__c,Staff_Schedules_Responsible__c,Kindergarten_Responsible__c,School_Age_Responsible__c,Services_for_Children_w_Disability_Resp__c,Daily_Activities_Responsible__c,Equipment_Responsible__c,
                            Indoor_Square_Footage__c,Number_of_toilets__c,Number_of_sinks__c,Lead_Paint_Compliance__c,Detailed_Inspection__c,Building_Inspection_Max_Capacity__c,Building_inspection_expiration_Date__c,Building_Codes__c,Health_Inspection_Expiration_Date__c,
                            School_Year_To__c,School_Year_From__c, Half_Day_Afternoon_Program_Available_On__c,Half_Day_Afternoon_Program_Avail_From__c,Half_Day_Afternoon_Program_Available_To__c,Half_Day_Morning_Program_Available_On__c,Half_Day_Morning_Program_Available_From__c,Half_Day_Morning_Program_Available_To__c,Full_Day_Program_Available_To__c,
                            Gender__c,Full_Day_Program_Available_From__c,Extended_Day_Available_On__c,Full_Day_Program_Available_On__c,Full_School_Year__c,Capacity_Small_Group__c,Infant_birth_15_mo__c,Infant_Toddler_birth_33_mo__c,Toddler_15_mo_33_mo__c,Toddler_Preschool_15_mo_K__c,Preschool_33_mo_K__c,Preschool_SA_33_mo_8_yr__c,Kindergarten__c,School_Age_5_yr_14_yr__c,Multi_Age_Group_birth_14_yr__c,
                            MinAgeServed__c,MaxAgeServed__c,Awake_Ratio__c,Asleep_Ratio__c,Ratio_Comment__c,Use_Physical_Restraints__c,Referral_Agency__c,
                            Characteristics_of_children_served_pickl__c,International_Adoption_Countries__c,Other_Countries__c,Other_Referral_Agency__c,No_Adoptive_Placements__c,
                            Number_of_Foster_Homes__c,No_Birth_Mothers_Receiving_Services__c,No_Birth_Mothers_Making_Adoption_Plan__c,Number_of_Waiting_Families__c,No_Families_Rec_Home_Stdy_Serv_Only__c,
                            Recving_search_and_or_reunion_services__c,No_Indiv_Rec_Search_and_or_Reunion_Serv__c,Number_of_Reunions_Facilitated__c,Number_of_Child_Assessments__c,Number_of_Home_Study_Services__c,
                            No_of_Families_Rec_Case_Mgmt_Services__c,No_Families_Receiving_Info_and_Referral__c,Number_of_Children_Placed_in_Care__c,Camp_Permit_Issue_Date__c,Camp_Permit_Number__c,Summer_Camp_Permit__c,Staff_Development_Responsible__c,Staff_Training_Responsible__c,Staff_Orientation_Responsible__c,Staff_Supervision_Responsible__c,Parent_Involvement_Responsible__c,Social_Services_Responsible__c,Infant_Toddler_Program_Responsible__c,Outdoor_Square_footage__c,Pool_roof_inspection_date__c,Offsite_outdoor_play_location__c,Other_Approved_Additional_Space__c,
                            Certified_As__c, Allow_New_Application_as_Provider__c, Can_Communicate_in_English__c, PPM_Meeting_Attended_Date__c, capacity__c,
                            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Unlisted_Phone_Number__c, Alternate_Phone__c, Fax, Provider_Email__c,//Name_of_the_Person_to_Contact__c,
                            Extended_Day_Provided__c,Provider_Address_1__c, Provider_Address_2__c, Provider_City__c, Provider_City__r.Name, Provider_Zip_Code__c, Live_at_this_address__c, Language__c, Preferred_Language__c
                            ,Drop_In_Service_Provided__c, Evenings_Service_Provided__c,Licensor_Full_Name__c,Licensor_Phone__c, Region__r.Phone__c,Summer_Camp_Services_Provided__c, Cafeteria_Approved__c, Gym_Approved__c
                    from Account
                    where Id = :licenseTransation.Provider__c
            ];
            ihmList = [Select Id, Provider__c, Licensing_Transactions__c, Current__c, First_Name__c, Last_Name__c, Date_of_Birth__c, Relationship_to_Provider__c, Occupation__c, Number_of_Hours_Home_During_Child_Care__c, Current_School_Grade__c, Email_Address__c From Household_Member__c where Licensing_Transactions__c = :licenseTransation.Id];
            ihmListJson = JSON.serialize(ihmList);
            ehList = [Select Name, Contact__c, Licensing_Transaction__c, Position__c, Start_Date__c, End_Date__c, Reason_for_Leaving__c, Employer__c, Employer_Address__c, Employer_Phone__c From Employment_History__c where Licensing_Transaction__c = :licenseTransation.Id];
            roomList = [Select Id, Current__c, Use__c, Dimension_Length_feet__c, Dimension_Width_feet__c, Dimension_Square_Feet__c, Floor_Level__c, Provider_Name__c,Provider_No__c From Room__c where Source_Transaction__c = :licenseTransation.Id];
            teList = [Select Id, Name, Contact__c, Licensing_Transactions__c, Topic__c, Date_of_the_Training__c, Number_of_Training_Hours__c From Training_Experience__c where Licensing_Transactions__c = :licenseTransation.Id];
            initHH = true;
            initLS = true;
            initIndoor = true;
            initTraining = true;
            if (String.isNotEmpty(licenseTransation.Heating_Elements__c)) {
                selectedHestElems = licenseTransation.Heating_Elements__c.split(';');
            }
        }
    }
    public void doInsertRooms() {
        if (roomList.size() == 0 && (licenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL || licenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE || licenseRecordTypeName == EEC_Constants.LT_GSA_MOVE || licenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE)) {
            List<Room__c> listRooms = [
                    Select Id, Name, Building_Name__c, Source_Transaction__c, Current__c, Use__c, Dimension_Length_feet__c, Dimension_Width_feet__c, Dimension_Square_Feet__c, Floor_Level__c, Provider_Name__c
                    From Room__c
                    where Provider_No__c = :provider.Id
                    and Current__c = true
            ];
            List<Room__c> listNewRooms = new List<Room__c>();
            for (Room__c room : listRooms) {
                Room__c newRoom = room.clone(false, false, false, false);
                newRoom.Source_Transaction__c = licenseTransation.Id;
                listNewRooms.add(newRoom);
            }
            if (listNewRooms.size() > 0)
                insert listNewRooms;
            if (listRooms.size() > 0) {
                for (Room__c room : listRooms) {
                    room.Current__c = false;
                }
                if (!isSubmitted) {
                    update listRooms;
                }
            }
        }
    }
    /**
* UpdateMembersList
*
* This function will process two JSON strings and put them into the overall Household_Member List.
* @author Darkis
* @param MembersJson String The json containing all the members currently or newly added to the table.
* @param MembersToDeleteJson String The json containing all the members that are to be deleted from the transaction.
*/
    public void UpdateMembersList() {
        try {
            List<Household_Member_Json_Wrapper> memberWrapperList;
            List<Household_Member__c> memberList = new List<Household_Member__c> ();
            if (!String.isBlank(MembersJson)) {
                memberWrapperList = (List<Household_Member_Json_Wrapper>) JSON.deserialize(MembersJson, List<Household_Member_Json_Wrapper>.class);
                for (Household_Member_Json_Wrapper memberWrapper : memberWrapperList) {
                    memberList.add(memberWrapper.convertToHouseholdMember());
                }
                ihmList = memberList;
                ihmListJson = JSON.serialize(ihmList);
            }
            if (!String.isBlank(MembersToDeleteJson)) {
                memberWrapperList = (List<Household_Member_Json_Wrapper>) JSON.deserialize(MembersToDeleteJson, List<Household_Member_Json_Wrapper>.class);
                memberList = new List<Household_Member__c> ();
                for (Household_Member_Json_Wrapper mw : memberWrapperList) {
                    memberList.add(mw.convertToHouseholdMember());
                }
                removeHMList = memberList;
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
    }
    /**
* Household_Member_Json_Wrapper
*
* This wrapper class is used to process Household Member Json strings into usable Household_Member__c objects.
* @author Darkis
*/
    public class Household_Member_Json_Wrapper {
        // Variables here
        public String Id { get; set; }
        public String First_Name { get; set; }
        public String Last_Name { get; set; }
        public String Date_of_Birth { get; set; }
        public String Relationship_to_Provider { get; set; }
        public String Occupation { get; set; }
        public String Number_of_Hours_Home_During_Child_Care { get; set; }
        public String Current_School_Grade { get; set; }
        public String Email_Address { get; set; }
        /**
* convertToHouseholdMember
*
* This function will take the processed Json and convert it into a usable Household_Member__c object for saving.
* @author Darkis
*/
        public Household_Member__c convertToHouseholdMember() {
            Household_Member__c member = new Household_Member__c(
                    First_Name__c = this.First_Name,
                    Last_Name__c = this.Last_Name,
                    Date_of_Birth__c = Date.parse(this.Date_of_Birth),
                    Relationship_to_Provider__c = this.Relationship_to_Provider,
                    Occupation__c = this.Occupation,
                    Number_of_Hours_Home_During_Child_Care__c = Decimal.valueOf(this.Number_of_Hours_Home_During_Child_Care),
                    Current_School_Grade__c = this.Current_School_Grade,
                    Email_Address__c = this.Email_Address
            );
            // If the ID is not null/empty/blank then set it for updating.
            if (String.isNotBlank(this.Id)) {
                member.Id = this.Id;
            }
            return member;
        }
    }
    /**
* processAttachmentJson
*
* This function will accept a json parameter of files decriptions to save to the transaction object.
* @author Darkis
*/
    public void processAttachmentJson(String jsonStr) {
        try {
            // List of S3Objects.
            if (!String.isBlank(jsonStr)) {
                // Convert the json into S3_Files.
                List<S3_File__c> s3FilesList = (List<S3_File__c>) JSON.deserialize(jsonStr, List<S3_File__c>.class);
                for (S3_File__c s3File : s3FilesList) {
                    s3File.Object_Id__c = licenseTransation.Id;
                    s3File.Object_Name__c = String.valueOf(licenseTransation.getSObjectType());
                }
                upsert s3FilesList;
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
    }
    /**
* saveAttachmentsFromJson
*
* This function will send both the indoor json and full attachment json string to be processed.
* @author Darkis
*/
    public void saveAttachmentsFromJson() {
        try {
            // List of S3Objects.
            if (!String.isBlank(indoorAttachmentsJson)) {
                processAttachmentJson(indoorAttachmentsJson);
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
    }
    public void saveAllAttachmentsFromJson() {
        try {
            if (!String.isBlank(attachmentsJson)) {
                processAttachmentJson(attachmentsJson);
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
    }
    public void saveTrainingAttachmentsFromJson() {
        try {
            if (!String.isBlank(trainingAttachmentsJson)) {
                processAttachmentJson(trainingAttachmentsJson);
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
    }
    /**
* renderExisitingElements
*
* These functions will verify that certain files have been mapped correctly.
* @author Darkis
*/
    public Boolean getRenderExistingHeatingAttachment() {
        return transactionAttachmentsMap.containsKey('evidence_stove_meets_requirements');
    }
    public Boolean getRenderExistingWaterAttachment() {
        return transactionAttachmentsMap.containsKey('evidence_of_well_water_test');
    }
    public Boolean getRenderExistingMedicationAttachment() {
        return transactionAttachmentsMap.containsKey('med_administration_training_evidence');
    }
    public Boolean getRenderExistingTransportationAttachment() {
        return transactionAttachmentsMap.containsKey('transportation_training_evidence');
    }
    public Boolean getRenderExistingSidsAttachment() {
        return transactionAttachmentsMap.containsKey('sids_training_evidence');
    }
    public Boolean getRenderExistingUsdaAttachment() {
        return transactionAttachmentsMap.containsKey('usda_nutrition_training_evidence');
    }
    public Boolean getRenderExistingUpgradeAttachment() {
        return transactionAttachmentsMap.containsKey('upgrade_capacity_training_evidence');
    }
    public Boolean getRenderExistingOrientationAttachment() {
        return transactionAttachmentsMap.containsKey('fcc_orientation_mod_II_training_evidence');
    }
    public Boolean getRenderExistingCprAttachment() {
        return transactionAttachmentsMap.containsKey('cpr_certification_evidence');
    }
    public Boolean getRenderExistingFirstAidAttachment() {
        return transactionAttachmentsMap.containsKey('first_aid_certification_evidence');
    }
    public Boolean getRenderExistingOrientationModuleAttachment() {
        return transactionAttachmentsMap.containsKey('fcc_orientation_module_1_evidence');
    }
    public Boolean getRenderExistingIntroEECModuleAttachment() {
        return transactionAttachmentsMap.containsKey('intro_fcc_module_evidence');
    }
    /**
* deleteAttachment
*
* This function will delete the FileMap__c and S3_File__c record for a specified file along with trigger an async function to delete the file from S3.
* @author Darkis
* @param String fileToDelete The name of the file to delete from the UI.
*/
    public PageReference deleteAttachment() {
        // Delete the S3_File reference in Sforce.
        S3_File__c file = [Select Id From S3_File__c Where Object_Id__c = :licenseTransation.Id AND Filename__c = :fileToDelete];
        delete file;
        // Invoke the future method to delete the object in S3 using the SOAP API.
        if (!Test.isRunningTest()) {
            deleteS3FileReference(bucketName, licenseTransation.Id + '/' + fileToDelete);
        }
        // Check for the transaction certification field name. If it exists then uncheck the field
        if (!String.isBlank(transCertCheckboxFieldname)) {
            licenseTransation.put(transCertCheckboxFieldname, false);
        }
        // Re-map the mappings to remove the attachment.
        generateAttachmentMappings();
        refreshAttachmentsList();
        retrieveAddtionalTrainingAttachmentsList();
        return null;
    }
    /**
    * @future
    * deleteS3FileReference
    *
    * This future function will do a SOAP callout to S3 to delete the file reference provided.
    * @author Darkis
    * @param String bucketName The name of the bucket the file resides in.
    * @param String filename The name of the file along with any prefixs necessary.
    */
    @future(callout = true)
    public static void deleteS3FileReference(String bucketName, String filename) {
        // Delete the file from S3 using the SOAP API.
        EEC_S3ComponentCtrl.deleteFile(bucketName, filename);
    }
    /** filename
    * generateMultiplePolicySignature
    *
    * This function will call the S3ComponentCtrl to generate multiple or single policy and signature combos for specified files to upload to S3.
    * @author Darkis
    * @param String bucket The name of the bucket to save to.
    * @param String acl The permission level of the file. Typically this would be 'authenticated-read' for our purposes.
    * @param String fileJson A JSON string of all the files to be uploaded from the Angular Controller.
    */
    @RemoteAction
    public static List<Map<String, String>> generateMultiplePolicySignature(String bucket, String acl, String fileJson) {
        List<Map<String, String>> returnJson = new List<Map<String, String>> ();
        List<EEC_S3ComponentCtrl.FileTypeJsonWrapper> fileTypeWrapperList = (List<EEC_S3ComponentCtrl.FileTypeJsonWrapper>) JSON.deserialize(fileJson, List<EEC_S3ComponentCtrl.FileTypeJsonWrapper>.class);
        // Loop through the files given and get all the necessary policy/sig combos.
        for (EEC_S3ComponentCtrl.FileTypeJsonWrapper wrapper : fileTypeWrapperList) {
            returnJson.add(EEC_S3ComponentCtrl.generatePolicySignature(bucket, acl, wrapper.filename, wrapper.type, null));
        }
        return returnJson;
    }
    /**
    * getRoomTableVisibility
    *
    * This function will check the room list size and inform the UI of the result.
    * @author Darkis
    */
    public Boolean getRoomTableVisibility() {
        return roomList.size() == 0 ? false : true;
    }
    /**
    * getHeatingEvidenceRequired
    *
    * This function will verify the existance of the heating evidence requirement for file uploads.
    * @author Darkis
    */
    public Boolean getHeatingEvidenceRequired() {
        if (selectedHestStr != null) {
            return selectedHestStr.contains('Coal / Pellet / Wood Burning Stove');
        }
        return false;
    }
    /**
    * getHeatingIsBarricaded
    *
    * This function will determine if the heating parameters require a 2nd question.
    * @author Darkis
    */
    public Boolean getHeatingIsBarricaded() {
        showCBDesc();
        if (String.isBlank(selectedHestStr)) {
            return false;
        }
        if (selectedHestStr != null && ((selectedHestStr == 'Baseboards,') || (selectedHestStr == 'Vents / Grates,') || (selectedHestStr == 'Baseboards,Vents / Grates,'))) {
            return false;
        }
        return true;
    }
    /**
    * getWaterIsPrivate
    *
    * This function will determine if the water selection is private or Town. If the value has not been initialized it will be here.
    * @author Darkis
    */
    public Boolean getWaterIsPrivate() {
        if (String.isBlank(selectedWaterStr) && licenseTransation.Drinking_Water_Source__c != null) {
            selectedWaterStr = licenseTransation.Drinking_Water_Source__c;
        }
        
        return false;
    }
    /**
    * Change the lookup for city into select option
    * @author Bemnet
    *
    */
    public EEC_PaginatedSelectList allCityList {
        get {
            if (allCityList == null) {
                allCityList = new EEC_PaginatedSelectList();
                allCityList.add(new SelectOption('','---None--')); // upendra
                for (City__c c : [select id, Name, State__c from City__c where isdeleted = false order by Name]) {
                    allCityList.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
                }
            }
            return allCityList;
        }
        set;
    }
    public EEC_PaginatedSelectList maCityList {
        get {
            if (maCityList == null) {
                maCityList = new EEC_PaginatedSelectList();
                maCityList.add(new SelectOption('','---None--')); // upendra
                for (City__c c : [select id, Name, State__c from City__c where State__c = 'MA' AND isdeleted = false order by Name]) {
                    maCityList.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
                }
            }
            return maCityList;
        }
        set;
    }
    public SelectOption[] getCityOptions() {
        SelectOption[] cities = new SelectOption[]{
        };
        cities.add(new SelectOption('', '--None--'));
        for (City__c c : [select id, Name, State__c from City__c where isdeleted = false order by Name]) {
            cities.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
        }
        return cities;
    }
    public SelectOption[] getMACityOptions() {
        SelectOption[] cities = new SelectOption[]{
        };
        cities.add(new SelectOption('', '--None--'));
        for (City__c c : [select id, Name, State__c from City__c where State__c = 'MA' AND isdeleted = false order by Name]) {
            cities.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
        }
        return cities;
    }
    /**
    * refreshAttachmentsList
    *
    * This function will collect all the attachments for the transaction and store them into a list for use on the attachment page.
    * @author Darkis
    */
    public List<S3_File__c> refreshAttachmentsList() {
        attachments = new List<S3_File__c> ();
        if (String.isNotBlank(licenseTransation.Id)) {
            attachments = [Select Id, Filename__c, Content_Type__c, Description__c, CreatedDate From S3_File__c Where Object_Id__c = :licenseTransation.Id];
        }
        if (attachments.size() > 0) {
            attachmentsJson = JSON.serialize(attachments);
        } else {
            attachmentsJson = '';
        }
        return attachments;
    }
    public List<S3_File__c> retrieveAddtionalTrainingAttachmentsList() {
        additionalTrainingAttachments = new List<S3_File__c> ();
        if (String.isNotBlank(licenseTransation.Id)) {
            additionalTrainingAttachments = [Select Id, Filename__c, CreatedDate From S3_File__c Where Object_Id__c = :licenseTransation.Id AND Filename__c Like 'additional_training_%'];
        }
        if (additionalTrainingAttachments.size() > 0) {
            attachmentsJson = JSON.serialize(additionalTrainingAttachments);
        } else {
            attachmentsJson = '';
        }
        return additionalTrainingAttachments;
    }
    public void generateAttachmentMappings() {
        if (String.isNotBlank(licenseTransation.Id)) {
            // Get all attachments for the transaction.
            transactionAttachments = [Select Id, CreatedDate, Filename__c, Bucket__c, Content_Type__c, Prefix__c From S3_File__c Where Object_Id__c = :licenseTransation.Id ORDER BY CreatedDate DESC];
            // Initialize the Mapping.
            transactionAttachmentsMap = new Map<String, Map<String, String>> ();
            transactionAttachmentsUrlMap = new Map<Id, String> ();
            Set<Id> transactionFileIds = new Set<Id> ();
            // Get the AWS credentials based on a config value.
            // TODO: Config the name of the aws key.
            AWSKeys creds = new AWSKeys('eec');
            // Loop through the file maps and creating a mapping based on filename.
            for (S3_File__c fileMap : transactionAttachments) {
                // Get the full filename including prefix if necessary for urls.
                String filename = (!String.isBlank(fileMap.Prefix__c) ? fileMap.Prefix__c + '/' + fileMap.Filename__c : fileMap.Filename__c);
                String[] filenameSplit = (fileMap.Filename__c).split('\\.');
                // Generate an attribute map for the page.
                Map<String, String> fileAttributeMap = new Map<String, String>{
                        'FileMap_Id' => fileMap.Id,
                        'File_Id' => fileMap.Id,
                        'Bucket__c' => fileMap.Bucket__c,
                        'Content_Type__c' => fileMap.Content_Type__c,
                        'Prefix__c' => fileMap.Prefix__c,
                        'Filename__c' => fileMap.Filename__c
                };
                transactionAttachmentsMap.put(filenameSplit[0], fileAttributeMap);
                // Map the FileMap's temp urls for use on the page.
                transactionAttachmentsUrlMap.put(fileMap.Id, EEC_S3ComponentCtrl.generateTempS3Url(fileMap.Bucket__c, filename, creds));
                // Add the file id to the ids list.
                transactionFileIds.add(fileMap.Id);
            }
            // Create a list of S3_File__c objects from the FileMap.
            indoorAttachmentsJson = JSON.serialize(transactionAttachments);
        }
    }
    /**
    * getAttachmentSpotlightText
    *
    * This function will determine the type of license record and provide the correct description text needed for attachments.
    * @author Darkis
    */
    public String getAttachmentSpotlightText() {
        String text = '';
        if (LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_FCC_NEW_LICENSE) || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_GSA_NEW_LICENSE)
                || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_PLACEMENT_NEW_LICENSE) || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE)) {
            text = leadConfiguration.Transaction_Attachments_New__c;
        } else if (LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_FCC_RENEWAL) || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_GSA_RENEWAL)
                || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_PLACEMENT_RENEWAL) || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL)) {
            text = leadConfiguration.Transaction_Attachments_Renewal__c;
        } else if (LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_FCC_LICENSE_UPGRADE) || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_GSA_LICENSE_CHANGE)
                || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE) || LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE)) {
            text = leadConfiguration.Transaction_Attachments_Upgrade__c;
        }
        return text;
    }
    /**
    * saveFileDescription
    *
    * This function will save the new description for a specified file.
    * @author Darkis
    * @param String fileToEditId The id of the file.
    * @param String fileToEditDescription The new file description entered by the client.
    */
    public void saveFileDescription() {
        if (!String.isBlank(fileToEditId)) {
            S3_File__c file = [Select Id, Description__c From S3_File__c Where Id = :fileToEditId];
            file.Description__c = fileToEditDescription;
            update file;
        }
    }
  
    /**
    * getRequestedLicenseOptions
    *    Gets the appropriate licence types based on the request and provider
    *
    * @return List<SelectOption>
    */
    public List<SelectOption> getRequestedLicenseOptions() {
        List<SelectOption> options = new List<SelectOption> ();
        Schema.DescribeFieldResult fieldResult = Licensing_Transaction__c.License_Requested__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            if ((isFccAssistant && f.getLabel().containsIgnoreCase('Assistant') && !(LicenseRecordTypeName == EEC_Constants.LT_FCC_REGULAR_ASSISTANT_TO_CERTIFIED_ASSISTANT && f.getLabel() == EEC_Constants.CERIFIED_REGULAR_ASSISTANT)) ||
                    (!isFccAssistant && !f.getLabel().containsIgnoreCase('Assistant'))) {
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }
        return options;
    }
    /**
    * DailyRandASave
    *
    * @description A one stop location for all traversal paths for the Daily Routine and Activities.
    * @authour Darkis
    * @param saveType Integer The save type attempted.
    * @return PageReference
    */
    public PageReference DailyRandASave() {
        PageReference pPage;
        Integer saveType = Integer.valueOf(ApexPages.currentPage().getParameters().get('saveType'));
        if (saveType == SAVE_AND_NEXT) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO;
            // Setup the page.
            pPage = Page.EEC_BackgroundInformation;
            pPage.getParameters().put('ltId', licenseTransation.Id);
        } else if (saveType == SAVE_AND_PREVIOUS) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
            // Setup the page.
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            } else {
                if (LicenseRecordTypeName.equalsIgnoreCase(EEC_Constants.LT_FCC_ASSISTANT_RENEWAL)) {
                    pPage = Page.EEC_TransactionProvider;
                } else {
                    pPage = page.EEC_AssistantInvolvementExperience;
                }
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
        } else if (saveType == SAVE_AND_RETURN) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
            // Setup the page.
            pPage = page.EEC_PortalProviderPage;
        } else if (saveType == SAVE_AND_RETURN_TO_SAME_PAGE) {
            pPage = page.eec_transaction_dailyranda;
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
            pPage.getParameters().put('ltId', licenseTransation.Id);
        }
        if (saveType != SAVE_AND_PREVIOUS && !isSubmitted) {
            update licenseTransation;
        }
        if (pPage != null) {
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
        }
        return pPage;
    }
    public List<EEC_Question> getBackgroundInformationQuestions() {
        /* if (isFccAssistant) {
            licenseTransation.RecordType.DeveloperName = EEC_Constants.PRO_FCC_ASSISTANT;
        } else if (licenseTransation.RecordType.DeveloperName == EEC_Constants.PRO_FCC) {
            licenseTransation.RecordType.DeveloperName = EEC_Constants.PRO_FCC;
        } else if (licenseTransation.RecordType.DeveloperName == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
            licenseTransation.RecordType.DeveloperName = EEC_Constants.PRO_INFORMAL_CHILD_CARE;
        }
        return EEC_QuestionService.getLicensingSectionQuestionsForProvider(
                EEC_QuestionService.Section.BackgroundInformation,
                licenseTransation.providerRecordTypeDeveloperName__c
        ); */
        if (isFccAssistant) {
            providerRecordType = 'FCC Assistant';
        } else if (providerRecordType == 'Family Child Care') {
            providerRecordType = 'Family Child Care';
        } else if (providerRecordType == EEC_Constants.PRO_LABEL_INFORMAL_CHILD_CARE) {
            providerRecordType = EEC_Constants.PRO_LABEL_INFORMAL_CHILD_CARE;
        }
        return EEC_QuestionService.getLicensingSectionQuestionsForProvider(
                EEC_QuestionService.Section.BackgroundInformation,
                providerRecordType
        );
    }
   
    /**
    * LicensingStatusCapacityInfoSave
    *
    * @description A one stop location for all traversal paths for the Licensing Status and Capacity.
    * @authour Darkis
    * @param saveType Integer The save type attempted.
    * @return PageReference
    */
    public PageReference LicensingStatusCapacityInfoSave() {
        PageReference pPage;
        Integer saveType = Integer.valueOf(ApexPages.currentPage().getParameters().get('saveType'));
        if (saveType == SAVE_AND_NEXT) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
            // remove cookies
            //licenseTransation.Evening_Overnight_Weekend_Care_Desc__c = EEC_Util.removeCookiesBracket(licenseTransation.Evening_Overnight_Weekend_Care_Desc__c);
            // Setup the page.
            pPage = Page.eec_involvementexperience;
            if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                if (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE) {
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                    pPage = Page.eec_involvementexperience;
                } else if (LicenseRecordTypeName == EEC_Constants.LT_FCC_LICENSE_UPGRADE || LicenseRecordTypeName == EEC_Constants.LT_FCC_RENEWAL) {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO;
                    pPage = Page.EEC_BackgroundInformation;
                }/* else if (LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                    licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP;
                    pPage = Page.eec_involvementexperience;
                } */
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
        } else if (saveType == SAVE_AND_PREVIOUS) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO;
            // Setup the page.
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
                    pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
                }
            }/* else if (LicenseRecordTypeName == EEC_Constants.LT_INFORMAL_CARE_NEW_APPLICATION) {
                pPage = Page.EEC_TransactionProvider;
            } */else {
                pPage = Page.EEC_HouseholdMembers;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
        } else if (saveType == SAVE_AND_RETURN) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO;
            // Setup the page.
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                pPage = page.EEC_PortalProviderPage;
            }
        }
        else if (saveType == SAVE_AND_RETURN_TO_SAME_PAGE) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO;
            pPage = page.EEC_LicenseStatusCapacityInfo;
            // remove cookies
            Licensing_Transaction__c updatedLicenseTransaction = EEC_Util.removeScriptElements(licenseTransation);
            licenseTransation = updatedLicenseTransaction;
            pPage.getParameters().put('ltId', licenseTransation.Id);
        }
        if (saveType != SAVE_AND_PREVIOUS && !isSubmitted) {
            update licenseTransation;
        }
        if (pPage != null) {
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
        }
        return pPage;
    }
    /**
    * getIsAssistantUpgradeOrientationProvided
    *
    * @description This function will check if the assistant has already done a transaction with renewal or upgrade.
    * @author Darkis
    * @return Boolean
    */
    public Boolean getIsAssistantUpgradeOrientationProvided() {
        String ltRecordTypeName = '';
        List<Licensing_Transaction__c> transactionList = [Select Ownership_Type__c,Id,New_Name__c, Assigned_User_Email__c From Licensing_Transaction__c Where Provider__c = :provider.Id AND Id != :licenseTransation.Id];
        if (transactionList != null && transactionList.size() > 0) {
            for (Licensing_Transaction__c lt : transactionList) {
              //  ltRecordTypeName = lt.RecordType.DeveloperName;
                
            }
        }
        return false;
    }
    /**
    * getIsAssistantReviewMode
    *
    * @description This function will check and see if the current summary page requested is the review or submit.
    * @author Darkis
    * @return Boolean
    */
    public Boolean getIsAssistantReviewMode() {
        String mode = ApexPages.currentPage().getParameters().get('mode');
        return(mode != null && Integer.valueOf(mode) == MODE_REVIEW ? true : false);
    }
    /**
    * editInstruction
    *
    * @description This function will sent the user to the correct last setup page from the view treansaction.
    * @author Darkis
    * @return Pagereference The page to send the user.
    */
    public Pagereference editInstruction() {
        PageReference pPage;
        /*if(licenseTransation.Last_Reached_Step__c == EEC_Constants.LT_LAST_REACHED_ATTACHMENTS){
            if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT){
                pPage = Page.EEC_LicenseTransactionAttachments;
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella' ){
                pPage = Page.EEC_LicensingAttachment;
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                pPage = Page.EEC_LicensingAttachment;
            }
            else{
                pPage = Page.EEC_LicensingAttachment;
            }
        }
        else if(licenseTransation.Last_Reached_Step__c == EEC_Constants.LT_LAST_REACHED_REVIEW_SUMMARY_AND_SUBMISSION){
            if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT){
                pPage = Page.EEC_ReviewSummarySubmission;
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella' ){
                pPage = Page.EEC_GSAReviewSummary;
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                pPage = Page.EEC_RP_ReviewSummary;
            }
            else{
                pPage = Page.EEC_GSAReviewSummary;
            }
        }
        else{
            pPage = EEC_Util.lastStepMap.get(licenseTransation.Last_Reached_Step__c);
        }*/
        if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
            pPage = EEC_Util.lastFCCStepMap.get(licenseTransation.Last_Reached_Step__c);
        } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
            pPage = EEC_Util.lastFCCAssitantStepMap.get(licenseTransation.Last_Reached_Step__c);
        } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
            pPage = EEC_Util.lastGSAStepMap.get(licenseTransation.Last_Reached_Step__c);
        } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
            pPage = EEC_Util.lastRPStepMap.get(licenseTransation.Last_Reached_Step__c);
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        pPage.setRedirect(true);
        return pPage;
    }
    /**
    * LicensingStatusCapacityInfoSave
    *
    * @description A one stop location for all traversal paths for the Licensing Status and Capacity.
    * @authour Darkis
    * @param saveType Integer The save type attempted.
    * @return PageReference
    */
    public PageReference AssistantInfoSave() {
        PageReference pPage;
        Integer saveType = Integer.valueOf(ApexPages.currentPage().getParameters().get('saveType'));
        if (saveType == SAVE_AND_NEXT) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE ?EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP : EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO);
            // Setup the page.
            pPage = (LicenseRecordTypeName == EEC_Constants.LT_FCC_NEW_LICENSE ? Page.EEC_InvolvementExperience : Page.EEC_BackgroundInformation);
            pPage.getParameters().put('ltId', licenseTransation.Id);
        } else if (saveType == SAVE_AND_PREVIOUS) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ASSISTANT_INFORMATION;
            // Setup the page.
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            } else {
                pPage = Page.EEC_LicenseStatusCapacityInfo;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
        } else if (saveType == SAVE_AND_RETURN) {
            // Change the last step.
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ASSISTANT_INFORMATION;
            // Setup the page.
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                pPage = page.EEC_PortalProviderPage;
            }
        }
        if (!isSubmitted) {
            update licenseTransation;
        }
        if (pPage != null) {
            addMemberIDPageParameter(pPage, true);
            pPage.setRedirect(true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    /**
    * getCtrlInstance
    *
    * This function will return an instance of this controller with interface reference.
    * @author Darkis
    * @return EEC_TransactionWizardController
    */
    public EEC_TransactionWizardController getCtrlInstance() {
        return this;
    }
    /*-----Interface Methods-----*/
    public void updateAssistantWrapperList(List<EEC_AssistantListCtrl.AssistantInfoWrap> providerAssistantWrappers) {
    }
   // public void updateContactRoleWrapperList(List<EEC_ContactRoleListCtrl.ContactRoleInfoWrap> ContactRoleInfoWrappers) {
  //  }
    public void updateVarianceWrapperList(List<EEC_VarianceListCtrl.VarianceInfoWrap> varianceInfoWrappers) {
        this.varianceInfoWrappers = varianceInfoWrappers;
    }
    public Licensing_Transaction__c getBaseLicenseTransaction() {
        return licenseTransation;
    }
    public String getBaseLicenseRecordTypeName() {
        return LicenseRecordTypeName;
    }
    /***************************************GSA*******************************/
    public List<selectOption> getContactList() {
        List<Contact> conList = [select FirstName, LastName from Contact where AccountId = :provider.Id];
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('', '--Select--'));
        options.add(new SelectOption('New Individual', 'New Individual'));
        for (Contact contact : conList) {
            options.add(new SelectOption(contact.Id, contact.FirstName + ' ' + contact.LastName));
        }
        return options;
    }
    public void doSelectUmbrella() {
        if (string.isNotBlank(selectedUmbrellaId)) {
            umbrella = EEC_ContactRoleUtil.getUmbrellaDetails(selectedUmbrellaId);
        }
    }
    public void newAdminHead() {
        if (selectedContact == 'New Individual') {
            administrativehead = new ContactRoleWrapperclass(true, true, null, null);
        } else if (String.isempty(selectedContact)) {
            administrativehead = null;
        } else {
            Contact contact = [
                    select Id, FirstName, LastName, Title, Email, Phone, MailingStreet,
                            MailingCity, MailingPostalCode, MailingState, Role__c, Holds_FCC_License__c,Accountid
                    from Contact
                    where Id = :selectedContact
            ];
            if (contact != null) {
                administrativehead = new ContactRoleWrapperclass(false, true, contact, null);
            }
        }
    }
    public void newBoardHead() {
        if (selectedBoardContact == 'New Individual') {
            designateboard = new ContactRoleWrapperclass(true, true, null, null);
        } else if (String.isempty(selectedBoardContact)) {
            designateboard = null;
        } else {
            Contact contact = [
                    select Id, FirstName, LastName, Title, Email, Phone, MailingStreet,
                            MailingCity, MailingPostalCode, MailingState, Role__c, Holds_FCC_License__c,Accountid
                    from Contact
                    where Id = :selectedBoardContact
            ];
            if (contact != null) {
                designateboard = new ContactRoleWrapperclass(false, true, contact, null);
            }
        }
    }
    //Type of Ownership
    public List<SelectOption> gettypeOfOwnership() {
        List<SelectOption> options = new List<SelectOption> ();
        if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
            options.add(new SelectOption('Doing Business As (DBA)', 'Doing Business As (DBA)'));
            options.add(new SelectOption('Non-Profit Corp.', 'Non-Profit Corp.'));
            options.add(new SelectOption('For Profit Corp.', 'For Profit Corp.'));
            options.add(new SelectOption('Partnership', 'Partnership'));
            options.add(new SelectOption('Individual', 'Individual'));
            options.add(new SelectOption('LLC', 'LLC'));
        } else if (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY ) {
            options.add(new SelectOption('Non-Profit Corp.', 'Non-Profit Corp.'));
            options.add(new SelectOption('For Profit Corp.', 'For Profit Corp.'));
            /*options.add(new SelectOption('Partnership', 'Partnership'));     I-00184 updated by Farman
            options.add(new SelectOption('Individual', 'Individual'));
            options.add(new SelectOption('Unincorporated', 'Unincorporated'));*/
        }
        // I-00184 Added this If else condition by Farman . Earlier this condition was in the second if else.
        else if (LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
            options.add(new SelectOption('Non-Profit Corp.', 'Non-Profit Corp.'));
            options.add(new SelectOption('For Profit Corp.', 'For Profit Corp.'));
            options.add(new SelectOption('Partnership', 'Partnership'));
            options.add(new SelectOption('Individual', 'Individual'));
            options.add(new SelectOption('Unincorporated', 'Unincorporated'));
        }
        return options;
    }
    public boolean userAssociatedtoUmbrella { get; set; }
    public void SetAddressAndOtherFields() {
        /*licenseTransation.Previous_Street_Address_1__c = licenseTransation.Provider__r.Provider_Address_1__c;
        licenseTransation.Previous_Street_Address_2__c = licenseTransation.Provider__r.Provider_Address_2__c;
        licenseTransation.Previous_City__c = licenseTransation.Provider__r.Provider_City__c;
        licenseTransation.Previous_State__c = licenseTransation.Provider__r.State__c;
        licenseTransation.Previous_Zip_Code__c = licenseTransation.Provider__r.Provider_Zip_Code__c;*/
        previousStreet1 = String.isBlank(Provider.Provider_Address_1__c) ? '' : Provider.Provider_Address_1__c;
        previousStreet2 = String.isBlank(Provider.Provider_Address_2__c) ? '' : Provider.Provider_Address_2__c;
        previousCity = String.isBlank(Provider.Provider_City__c) ? '' : Provider.Provider_City__c;
        previousState = String.isBlank(Provider.State__c) ? '' : Provider.State__c;
        previousZipCode = String.isBlank(Provider.Provider_Zip_Code__c) ? '' : Provider.Provider_Zip_Code__c;
    }
    public void pullContactRole() {
        if (licenseTransation.Contact_Roles_Copied__c == false &&
                (
                        LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE ||
                                LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE ||
                                LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY ||
                                LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL ||
                                LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE ||
                                LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE ||
                                LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE ||
                                LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY
                )) {
            List<Contact_Role__c> listContactRole = [
                    select Id, Name, Contact__c,
                            End_Date__c, End_Role_Licensing_Transaction__c, Portal_Access__c, Provider__c, Role__c,
                            Schedule_Administrative_Hours__c, Schedule_Teaching_Hours__c, Start_Date__c, Start_Role_Licensing_Transaction__c
                    from Contact_Role__c
                    where Provider__c = :licenseTransation.Provider__c
                    and (Role__c = 'Partner' or Role__c = :EEC_Constants.CONTACT_ROLE_PROGRAM_ADMINISTRATOR or Role__c = :EEC_Constants.CONTACT_ROLE_ADMINISTRATIVE_DESIGNEE)
                    and Current_Formula__c = true
            ];
            List<Contact_Role__c> listNewContactRole = new List<Contact_Role__c>();
            for (Contact_Role__c contactRole : listContactRole) {
                Contact_Role__c newContactRole = contactRole.clone(false, false, false, false);
                newContactRole.Start_Role_Licensing_Transaction__c = licenseTransation.Id;
                listNewContactRole.add(newContactRole);
            }
            EEC_ContactRoleUtil.upsertContactRole(listNewContactRole);
            licenseTransation.Contact_Roles_Copied__c = true;
            licenseTransation = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransation);
        }
        if (LicenseRecordTypeName != EEC_Constants.LT_GSA_NEW_LICENSE && LicenseRecordTypeName != EEC_Constants.LT_PLACEMENT_NEW_LICENSE && LicenseRecordTypeName != EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE) {
            licenseTransation.Ownership_Type__c = licenseTransation.Provider__r.Type_of_Ownership__c;
            if (licenseTransation.Provider__r.Type_of_Ownership__c == EEC_Constants.PRO_OWNERSHIP_TYPE_DOING_BUSINESS_AS_DBA) {
                licenseTransation.Ownership_Type__c =EEC_Constants.LT_OWNERSHIP_TYPE_DOING_BUSINESS_AS_DBA;
            } else if (licenseTransation.Provider__r.Type_of_Ownership__c ==EEC_Constants.PRO_OWNERSHIP_TYPE_NON_PROFIT_CORP) {
                licenseTransation.Ownership_Type__c =EEC_Constants.LT_OWNERSHIP_TYPE_NON_PROFIT_CORP;
            } else if (licenseTransation.Provider__r.Type_of_Ownership__c == EEC_Constants.PRO_OWNERSHIP_TYPE_FOR_PROFIT_CROP) {
                licenseTransation.Ownership_Type__c =EEC_Constants.LT_OWNERSHIP_TYPE_FOR_PROFIT_CROP;
            } else if (licenseTransation.Provider__r.Type_of_Ownership__c ==EEC_Constants.PRO_OWNERSHIP_TYPE_PARTERSHIP) {
                licenseTransation.Ownership_Type__c = EEC_Constants.LT_OWNERSHIP_TYPE_PARTERSHIP;
            } else if (licenseTransation.Provider__r.Type_of_Ownership__c == EEC_Constants.PRO_OWNERSHIP_TYPE_INDIVIDUAL) {
                licenseTransation.Ownership_Type__c =EEC_Constants.LT_OWNERSHIP_TYPE_INDIVIDUAL;
            }
        }
        if (contactrolelist == null) {
            contactrolelist = new list<ContactRoleWrapperclass>();
        }
        if (!Test.isRunningTest()) {
            if (Schema.SObjectType.Account.getRecordTypeInfosById().get(licenseTransation.Provider__r.RecordTypeID).getname() == 'Umbrella') {
                userAssociatedtoUmbrella = true;
                umbrella = [SELECT id,Name,Provider_Address_1__c,Provider_Address_2__c,Provider_City__c,Provider_city_text__c,Provider_Zip_Code__c,State__c FROM Account WHERE id = :licenseTransation.Provider__c];
            } else if (licenseTransation.Umbrella__c != null) {
                umbrella = [SELECT id,Name,Provider_Address_1__c,Provider_Address_2__c,Provider_City__c,Provider_city_text__c,Provider_Zip_Code__c,State__c FROM Account WHERE id = :licenseTransation.Umbrella__c];
            }
        } else {
            if (licenseTransation.Umbrella__c != null)
                umbrella = [SELECT id,Name,Provider_Address_1__c,Provider_Address_2__c,Provider_City__c,Provider_city_text__c,Provider_Zip_Code__c,State__c FROM Account WHERE id = :licenseTransation.Umbrella__c];
        }
        if (contactAdminRoleList == null) {
            contactAdminRoleList = new List<ContactRoleWrapperclass>();
        }
        if (contactReviewerList == null) {
            contactReviewerList = new List<ContactRoleWrapperclass>();
        }
        List<Contact_Role__c> tempcontactrole = new List<Contact_Role__c>();
        String query = 'SELECT id, Name,Current_Formula__c,Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingPostalCode,Contact__r.MailingState,Contact__r.Phone,Contact__r.Email,Contact__r.Holds_FCC_License__c,End_Date__c,End_Role_Licensing_Transaction__c,Portal_Access__c,Provider__c,Role__c,Schedule_Administrative_Hours__c,Schedule_Teaching_Hours__c,Start_Date__c,Start_Role_Licensing_Transaction__c,Contact__r.Title,Contact__r.Role__c FROM Contact_Role__c ';
        query = query + 'WHERE Provider__c=\'' + licenseTransation.Provider__c + '\' ORDER BY Start_Date__c ASC NULLS FIRST';
        tempcontactrole = Database.query(query);
        for (Contact_Role__c contactrecord : tempcontactrole) {
            if ((contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PARTNER && contactrecord.Current_Formula__c == true && LicenseRecordTypeName != EEC_Constants.LT_GSA_NEW_LICENSE) || (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PARTNER && (contactrecord.Start_Role_Licensing_Transaction__c == licenseTransation.id || contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id))) {
                ContactRoleWrapperclass wrapperrecord = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                contactrolelist.add(wrapperrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_ADMINISTRATIVE_DESIGNEE && (contactrecord.Start_Role_Licensing_Transaction__c == licenseTransation.id || (contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id && contactrecord.Current_Formula__c == true))) {
                ContactRoleWrapperclass wrapperrecord = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                contactAdminRoleList.add(wrapperrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_ADMINISTRATOR && (contactrecord.Start_Role_Licensing_Transaction__c == licenseTransation.id || (contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id && contactrecord.Current_Formula__c == true))) {
                ContactRoleWrapperclass wrapperrecord = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                contactReviewerList.add(wrapperrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD && contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id && contactrecord.Current_Formula__c == true) {
                adminHead = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD && contactrecord.End_Role_Licensing_Transaction__c == null && contactrecord.End_Date__c == null) {
                administrativehead = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                selectedContact = contactrecord.Contact__c;
            } else if ((contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_BOARD_CHAIR && contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id && contactrecord.Current_Formula__c == true)) {
                boardchair = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_BOARD_CHAIR && contactrecord.End_Role_Licensing_Transaction__c == null && contactrecord.End_Date__c == null) {
                designateboard = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                selectedBoardContact = contactrecord.Contact__c;
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_OWNER && (contactrecord.Start_Role_Licensing_Transaction__c == licenseTransation.id || (contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id && contactrecord.Current_Formula__c == true))) {
                ownerContactRole = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                if (contactrecord.Contact__r.Holds_FCC_License__c) {
                    ownerContactRole.holdFCCLicense = 'Yes';
                } else {
                    ownerContactRole.holdFCCLicense = 'No';
                }
            }
        }
        for (Contact_Role__c contactrecord : tempcontactrole) {
            if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD && contactrecord.Current_Formula__c == true && contactrecord.Start_Role_Licensing_Transaction__c != licenseTransation.id && contactrecord.End_Role_Licensing_Transaction__c != licenseTransation.id) {
                existingDirector = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
            if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_BOARD_CHAIR && contactrecord.Current_Formula__c == true && contactrecord.Start_Role_Licensing_Transaction__c != licenseTransation.id && contactrecord.End_Role_Licensing_Transaction__c != licenseTransation.id) {
                existingBoardChair = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
            if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_BOARD_CHAIR && contactrecord.Current_Formula__c == true && boardchair == null) {
                boardchair = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
            if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD && contactrecord.Current_Formula__c == true && adminHead == null) {
                adminHead = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
        }
        if (ownerContactRole == null) {
            ownerContactRole = new ContactRoleWrapperclass(true, true, null, null);
        }
        
    }
    public string stringvalueoflicenseApprovedByAgency { get; set; }
    public string stringValueofuseofPhysicalrestraints { get; set; }
    public void initGSA_RSubmissionPage() {
        String ltId = ApexPages.currentPage().getParameters().get('ltId');
        if (String.isNotBlank(ltId)) {
            getLicenseTrans(ltId);
        }
        licensesheld = new List<Additional_Information__c>();
        licensesinprogress = new List<Additional_Information__c>();
        criminalaction = new List<Additional_Information__c>();
        investigation = new List<Additional_Information__c>();
        if (licenseTransation.Program_licensed_or_approved_by_agency__c) {
            stringvalueoflicenseApprovedByAgency = 'Yes';
        } else {
            stringvalueoflicenseApprovedByAgency = 'No';
        }
        if (licenseTransation.Is_your_program_contracted__c) {
            programcontracted = 'Yes';
        } else {
            programcontracted = 'No';
        }
        if (contactrolelist == null) {
            contactrolelist = new list<ContactRoleWrapperclass>();
        }
        List<Contact_Role__c> tempcontactrole = new List<Contact_Role__c>();
        String query = 'SELECT id, Name,Current_Formula__c,Contact__c,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingPostalCode,Contact__r.MailingState,Contact__r.Phone,Contact__r.Email,Contact__r.Holds_FCC_License__c,End_Date__c,End_Role_Licensing_Transaction__c,Portal_Access__c,Provider__c,Role__c,Schedule_Administrative_Hours__c,Schedule_Teaching_Hours__c,Start_Date__c,Start_Role_Licensing_Transaction__c,Contact__r.Title,Contact__r.Role__c FROM Contact_Role__c ';
        query = query + 'WHERE Provider__c=\'' + licenseTransation.Provider__c + '\'';
        tempcontactrole = Database.query(query);
        for (Contact_Role__c contactrecord : tempcontactrole) {
            if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PARTNER) {
                ContactRoleWrapperclass wrapperrecord = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                contactrolelist.add(wrapperrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_OWNER && contactrecord.Current_Formula__c == true) {
                ownerContactRole = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                if (ownerContactRole.contact.Holds_FCC_License__c) {
                    GroupType = 'Yes';
                } else {
                    GroupType = 'No';
                }
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD && contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id && contactrecord.Current_Formula__c == true) {
                adminHead = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD && contactrecord.End_Role_Licensing_Transaction__c == null && contactrecord.End_Date__c == null) {
                administrativehead = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_ADMINISTRATIVE_DESIGNEE) {
                designateboard = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
                if (designateboard.contactrole.Portal_Access__c) {
                    designatedboardcheckedrp = 'Yes';
                } else {
                    designatedboardcheckedrp = 'No';
                }
            } else if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_BOARD_CHAIR && contactrecord.End_Role_Licensing_Transaction__c == null && contactrecord.End_Date__c == null) {
                boardchair = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
            if (contactrecord.End_Role_Licensing_Transaction__c == licenseTransation.id && contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_BOARD_CHAIR && contactrecord.Current_Formula__c == true) {
                pboardchair = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
        }
        for (Contact_Role__c contactrecord : tempcontactrole) {
            if (administrativehead == null && contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD && contactrecord.Current_Formula__c && contactrecord.End_Role_Licensing_Transaction__c != licenseTransation.id && contactrecord.Start_Role_Licensing_Transaction__c != licenseTransation.id) {
                administrativehead = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
            if (contactrecord.Role__c == EEC_Constants.CONTACT_ROLE_BOARD_CHAIR && contactrecord.Current_Formula__c == true && boardchair == null && contactrecord.End_Role_Licensing_Transaction__c != licenseTransation.id && contactrecord.Start_Role_Licensing_Transaction__c != licenseTransation.id) {
                boardchair = new ContactRoleWrapperclass(false, false, contactrecord.contact__r, contactrecord);
            }
        }
        List<Additional_Information__c> listAdditionalInfo = [
                Select Id,Name_of_Licensee__c
                        ,State_Country_Issuing_the_License__c
                        ,Provider__r.Type_of_Ownership__c
                        ,RecordTypeID
                        ,License_Number__c
                        ,Name_of_Applicant__c
                        ,State_Country_of_Applicant__c
                        ,Name_of_Licensing_Authority__c
                        ,Address_of_Licensing_authority__c
                        ,Phone_No_of_Licensing_Authority__c
                        ,Status_of_Application__c
                        ,Name_Admin_civil_criminal_action__c
                        ,Nature_of_Proceedings__c
                        , Caption__c
                        ,Docket_Number__c
                        ,Name_of_court_or_administrative_body__c
                        ,Address_of_court__c
                        ,Disposition__c
                        ,Name_of_Person_Agency_Investigated__c
                        ,State_and_or_Federal_Agency__c
                        ,Nature_of_Investigation__c,Type_of_License__c
                From Additional_Information__c
                where Licensing_Transaction__c = :licenseTransation.Id
        ];
        if (listAdditionalInfo != null && listAdditionalInfo.size() > 0) {
            for (Additional_Information__c additionalInfoRecord : listAdditionalInfo) {
                if (Schema.SObjectType.Additional_Information__c.getRecordTypeInfosById().get(additionalInfoRecord.recordtypeid).getname() == 'Other Licenses Held') {
                    licensesheld.add(additionalInfoRecord);
                }
                if (Schema.SObjectType.Additional_Information__c.getRecordTypeInfosById().get(additionalInfoRecord.recordtypeid).getname() == 'Other License Applications') {
                    licensesinprogress.add(additionalInfoRecord);
                }
                if (Schema.SObjectType.Additional_Information__c.getRecordTypeInfosById().get(additionalInfoRecord.recordtypeid).getname() == 'Admin/civil/criminal action detail') {
                    criminalaction.add(additionalInfoRecord);
                }
                if (Schema.SObjectType.Additional_Information__c.getRecordTypeInfosById().get(additionalInfoRecord.recordtypeid).getname() == 'State/federal investigation detail') {
                    investigation.add(additionalInfoRecord);
                }
            }
        }
        if (licenseTransation.Lead_Paint_Compliance__c == 'Yes') {
            Constructedpost = 'Yes';
        } else {
            Constructedpost = 'No';
        }
        if (licenseTransation.Lead_Paint_Detailed_Inspection__c == 'Yes') {
            DetailedInspection = 'Yes';
        } else {
            DetailedInspection = 'No';
        }
        
        if (ownerContactRole != null) {
            if (ownerContactRole.contact.Holds_FCC_License__c == true) {
                GroupType = 'Yes';
            }
        } else {
            GroupType = 'No';
        }
    }
    public void addcontactrole() {
        if (contactRoleList == null) {
            contactRoleList = new List<ContactRoleWrapperclass> ();
        }
        contactRoleList.add(new ContactRoleWrapperclass(true, true, null, null));
    }
    public void delcontactRole() {
        if (contactRoleList == null) {
            contactRoleList = new List<ContactRoleWrapperclass> ();
        }
        if (removeRoleList == null) {
            removeRoleList = new List<Contact_Role__c> ();
        }
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        ContactRoleWrapperclass rm = contactRoleList.get(rowNum);
        if (String.isNotBlank(rm.contactrole.Id)) {
            removeRoleList.add(new Contact_Role__c(id = contactRoleList.get(rowNum).contactrole.Id));
        }
        contactRoleList.remove(rowNum);
    }
    public void addadmincontactrole() {
        if (contactAdminRoleList == null) {
            contactAdminRoleList = new List<ContactRoleWrapperclass> ();
        }
        contactAdminRoleList.add(new ContactRoleWrapperclass(true, true, null, null));
    }
    public void addReviewer() {
        if (contactReviewerList == null) {
            contactReviewerList = new List<ContactRoleWrapperclass> ();
        }
        contactReviewerList.add(new ContactRoleWrapperclass(true, true, null, null));
    }
    public void deladmincontactRole() {
        if (contactAdminRoleList == null) {
            contactAdminRoleList = new List<ContactRoleWrapperclass> ();
        }
        if (removeRoleList == null) {
            removeRoleList = new List<Contact_Role__c> ();
        }
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        ContactRoleWrapperclass rm = contactAdminRoleList.get(rowNum);
        if (String.isNotBlank(rm.contactrole.Id)) {
            removeRoleList.add(new Contact_Role__c(id = contactAdminRoleList.get(rowNum).contactrole.id));
        }
        contactAdminRoleList.remove(rowNum);
    }
    public void delreviewercontactRole() {
        if (contactReviewerList == null) {
            contactReviewerList = new List<ContactRoleWrapperclass> ();
        }
        if (removeRoleList == null) {
            removeRoleList = new List<Contact_Role__c> ();
        }
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        ContactRoleWrapperclass rm = contactReviewerList.get(rowNum);
        if (String.isNotBlank(rm.contactrole.Id)) {
            removeRoleList.add(new Contact_Role__c(id = contactReviewerList.get(rowNum).contactrole.id));
        }
        contactReviewerList.remove(rowNum);
    }
    public void copyAll() {
        /*provider.Records_Responsible__c = provider.Account_books_Responsible__c;
        provider.Personnel_Records_Responsible__c = provider.Account_books_Responsible__c;
        provider.Children_s_Records_Responsible__c = provider.Account_books_Responsible__c;
        provider.Financial_Documentation_Responsible__c =provider.Account_books_Responsible__c;
        provider.Staff_Schedules_Responsible__c =provider.Account_books_Responsible__c;
        provider.Early_Childhood_Education_Program_Resp__c = provider.Account_books_Responsible__c;
        provider.Kindergarten_Responsible__c = provider.Account_books_Responsible__c;
        provider.School_Age_Responsible__c = provider.Account_books_Responsible__c;
        provider.Services_for_Children_w_Disability_Resp__c =provider.Account_books_Responsible__c;
        provider.Daily_Activities_Responsible__c =provider.Account_books_Responsible__c;
        provider.Equipment_Responsible__c =provider.Account_books_Responsible__c;
        provider.Staff_Development_Responsible__c = provider.Account_books_Responsible__c;
        provider.Staff_Training_Responsible__c =provider.Account_books_Responsible__c;
        provider.Staff_Orientation_Responsible__c =provider.Account_books_Responsible__c;
        provider.Staff_Supervision_Responsible__c = provider.Account_books_Responsible__c;
        provider.Parent_Involvement_Responsible__c = provider.Account_books_Responsible__c;
        provider.Social_Services_Responsible__c =provider.Account_books_Responsible__c;
        provider.Infant_Toddler_Program_Responsible__c =provider.Account_books_Responsible__c;*/
        licenseTransation.Records_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Personnel_Records_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Children_Records_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Financial_Documentation_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Staff_Schedule_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.ECE_program_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Kindergarten_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.School_Age_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Services_4_Disable_children_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Daily_Activities_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Equipment_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Staff_Development_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Staff_Training_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Staff_Orientation_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Staff_Supervision_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Parent_Involvement_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Social_Services_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Infant_Toddler_Program_Responsible__c = licenseTransation.Accounts_Responsible__c;
    }
    public void copyBusinessSec() {
        /*provider.Records_Responsible__c = provider.Account_books_Responsible__c;
        provider.Personnel_Records_Responsible__c = provider.Account_books_Responsible__c;
        provider.Children_s_Records_Responsible__c = provider.Account_books_Responsible__c;
        provider.Financial_Documentation_Responsible__c =provider.Account_books_Responsible__c;
        provider.Staff_Schedules_Responsible__c =provider.Account_books_Responsible__c;*/
        licenseTransation.Records_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Personnel_Records_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Children_Records_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Financial_Documentation_Responsible__c = licenseTransation.Accounts_Responsible__c;
        licenseTransation.Staff_Schedule_Responsible__c = licenseTransation.Accounts_Responsible__c;
    }
    public void copyDevelopSec() {
        /*provider.Kindergarten_Responsible__c = provider.Early_Childhood_Education_Program_Resp__c;
        provider.School_Age_Responsible__c = provider.Early_Childhood_Education_Program_Resp__c;
        provider.Services_for_Children_w_Disability_Resp__c =provider.Early_Childhood_Education_Program_Resp__c;
        provider.Daily_Activities_Responsible__c =provider.Early_Childhood_Education_Program_Resp__c;
        provider.Equipment_Responsible__c =provider.Early_Childhood_Education_Program_Resp__c;*/
        licenseTransation.Kindergarten_Responsible__c = licenseTransation.ECE_program_Responsible__c;
        licenseTransation.School_Age_Responsible__c = licenseTransation.ECE_program_Responsible__c;
        licenseTransation.Services_4_Disable_children_Responsible__c = licenseTransation.ECE_program_Responsible__c;
        licenseTransation.Daily_Activities_Responsible__c = licenseTransation.ECE_program_Responsible__c;
        licenseTransation.Equipment_Responsible__c = licenseTransation.ECE_program_Responsible__c;
    }
    public void copyOtherSec() {
        /*provider.Staff_Training_Responsible__c =provider.Staff_Development_Responsible__c;
        provider.Staff_Orientation_Responsible__c =provider.Staff_Development_Responsible__c;
        provider.Staff_Supervision_Responsible__c = provider.Staff_Development_Responsible__c;
        provider.Parent_Involvement_Responsible__c = provider.Staff_Development_Responsible__c;
        provider.Social_Services_Responsible__c =provider.Staff_Development_Responsible__c;
        provider.Infant_Toddler_Program_Responsible__c =provider.Staff_Development_Responsible__c;*/
        licenseTransation.Staff_Training_Responsible__c = licenseTransation.Staff_Development_Responsible__c;
        licenseTransation.Staff_Orientation_Responsible__c = licenseTransation.Staff_Development_Responsible__c;
        licenseTransation.Staff_Supervision_Responsible__c = licenseTransation.Staff_Development_Responsible__c;
        licenseTransation.Parent_Involvement_Responsible__c = licenseTransation.Staff_Development_Responsible__c;
        licenseTransation.Social_Services_Responsible__c = licenseTransation.Staff_Development_Responsible__c;
        licenseTransation.Infant_Toddler_Program_Responsible__c = licenseTransation.Staff_Development_Responsible__c;
    }
    public Pagereference SaveAndNextOwnership() {
        try {
            if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE) {
                PageReference pPage = Page.EEC_CapacityInformation;
                if (isSaveOnly) {
                    pPage = Page.eec_ownershipadministratorinfo;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
                PageReference pPage = Page.EEC_DesignationOfAdministrative;
                if (isSaveOnly) {
                    pPage = Page.eec_ownershipadministratorinfo;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL) {
                PageReference pPage = Page.EEC_ResidentialProgramDetail;
                if (isSaveOnly) {
                    pPage = Page.eec_ownershipadministratorinfo;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE ) {
                PageReference pPage = Page.EEC_PlacementAgency;
                if (isSaveOnly) {
                    pPage = Page.eec_ownershipadministratorinfo;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY) {
                PageReference pPage = Page.eec_licensingattachment;
                if (isSaveOnly) {
                    pPage = Page.eec_ownershipadministratorinfo;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    @TestVisible private boolean validateDates() {
        if ((licenseTransation.Ownership_Type__c == EEC_Constants.LT_OWNERSHIP_TYPE_PARTERSHIP || licenseTransation.Ownership_Type__c ==EEC_Constants.LT_OWNERSHIP_TYPE_UNINCORPORATED) && LicenseRecordTypeName != EEC_Constants.LT_GSA_LICENSE_CHANGE) {
            if (contactrolelist != null && contactrolelist.size() > 0) {
                for (ContactRoleWrapperclass contactRoleWrapper : contactrolelist) {
                    if (contactRoleWrapper.contactrole.Start_Date__c > contactRoleWrapper.contactrole.End_Date__c) {
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date should be less than end date.');
                        return false;
                    }
                }
            }
        }
        if (adminHead != null) {
            if (adminHead.contactrole.Start_Date__c > adminHead.contactrole.End_Date__c) {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date should be less than end date.');
                return false;
            }
        }
        if (boardchair != null) {
            if (boardchair.contactrole.Start_Date__c > boardchair.contactrole.End_Date__c) {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date should be less than end date.');
                return false;
            }
        }
        if (contactAdminRoleList != null && contactAdminRoleList.size() > 0) {
            for (ContactRoleWrapperclass contactRoleWrapper : contactAdminRoleList) {
                if (contactRoleWrapper.contactrole.Start_Date__c > contactRoleWrapper.contactrole.End_Date__c) {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date should be less than end date.');
                    return false;
                }
            }
        }
        if (contactReviewerList != null && contactReviewerList.size() > 0) {
            for (ContactRoleWrapperclass contactRoleWrapper : contactReviewerList) {
                if (contactRoleWrapper.contactrole.Start_Date__c > contactRoleWrapper.contactrole.End_Date__c) {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start date should be less than end date.');
                    return false;
                }
            }
        }
        return true;
    }
    @TestVisible private void Save(String direction) {
        try {
            if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY) {
                if (direction == 'Next') {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DESIGNATION_ADMIN_RESPONSIBILITY;
                }
            }
            if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                if (direction == 'Next') {
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
                }
            }
            if (direction == 'Previous' || direction == 'Return') {
                licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_OWNERSHIP_ADMINISTRATOR_INFO;
            }
            
            if (string.isNotEmpty(selectedUmbrellaId) && (licenseTransation.Ownership_Type__c == EEC_Constants.PRO_OWNERSHIP_TYPE_NON_PROFIT_CORP || licenseTransation.Ownership_Type__c == 'For Profit Corp.' || licenseTransation.Ownership_Type__c == 'LLC')) {
                licenseTransation.Umbrella__c = selectedUmbrellaId;
            }
            licenseTransation = EEC_ContactRoleUtil.updateLicensingTransaction(licenseTransation);
            List<Contact_Role__c> listInsertContactRoles = new List<Contact_Role__c>();
            List<Contact_Role__c> listUpdateContactRoles = new List<Contact_Role__c>();
            set<id> existingContactSet = new set<id>();
            list<Contact> listInsertContacts = new list<Contact>();
            list<Contact> listUpdateContacts = new list<Contact>();
            Set<Id> setContact = new Set<Id>();
            if ((licenseTransation.Ownership_Type__c == EEC_Constants.LT_OWNERSHIP_TYPE_PARTERSHIP || licenseTransation.Ownership_Type__c ==EEC_Constants.LT_OWNERSHIP_TYPE_UNINCORPORATED) && LicenseRecordTypeName != EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                for (ContactRoleWrapperclass contactRoleWrapper : contactrolelist) {
                    if (contactRoleWrapper.holdFCCLicense == 'Yes') {
                        contactRoleWrapper.contact.Holds_FCC_License__c = true;
                    } else {
                        contactRoleWrapper.contact.Holds_FCC_License__c = false;
                    }
                    if (contactRoleWrapper.isNew) {
                        contactRoleWrapper.contact.AccountId = provider.Id;
                        listInsertContacts.add(contactRoleWrapper.contact);
                    } else {
                        if (!setContact.contains(contactRoleWrapper.contact.Id)) {
                            setContact.add(contactRoleWrapper.contact.Id);
                            listUpdateContacts.add(contactRoleWrapper.contact);
                        }
                    }
                }
            }
            if (LicenseRecordTypeName != EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                for (ContactRoleWrapperclass contactRoleWrapper : contactAdminRoleList) {
                    if (contactRoleWrapper.isNew) {
                        contactRoleWrapper.contact.AccountId = provider.Id;
                        listInsertContacts.add(contactRoleWrapper.contact);
                    } else {
                        if (!setContact.contains(contactRoleWrapper.contact.Id)) {
                            setContact.add(contactRoleWrapper.contact.Id);
                            listUpdateContacts.add(contactRoleWrapper.contact);
                        }
                    }
                }
            }
            if ((licenseTransation.Ownership_Type__c == EEC_Constants.LT_OWNERSHIP_TYPE_INDIVIDUAL || licenseTransation.Ownership_Type__c == EEC_Constants.LT_OWNERSHIP_TYPE_DOING_BUSINESS_AS_DBA) && LicenseRecordTypeName != EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                if (ownerContactRole != null) {
                    if (ownerContactRole.holdFCCLicense == 'Yes') {
                        ownerContactRole.contact.Holds_FCC_License__c = true;
                    } else {
                        ownerContactRole.contact.Holds_FCC_License__c = false;
                    }
                    if (ownerContactRole.isNew) {
                        ownerContactRole.contact.AccountId = provider.Id;
                        listInsertContacts.add(ownerContactRole.contact);
                    } else {
                        if (!setContact.contains(ownerContactRole.contact.Id)) {
                            setContact.add(ownerContactRole.contact.Id);
                            listUpdateContacts.add(ownerContactRole.contact);
                        }
                    }
                }
            }
            if (adminHead != null) {
                if (!setContact.contains(adminHead.contact.Id)) {
                    setContact.add(adminHead.contact.Id);
                    listUpdateContacts.add(adminHead.contact);
                }
            }
            if (administrativehead != null && administrativehead.contact != null) {
                if (administrativehead.isNew) {
                    administrativehead.contact.AccountId = provider.Id;
                    listInsertContacts.add(administrativehead.contact);
                } else {
                    if (!setContact.contains(administrativehead.contact.Id)) {
                        setContact.add(administrativehead.contact.Id);
                        listUpdateContacts.add(administrativehead.contact);
                    }
                }
            }
            if (boardchair != null) {
                if (!setContact.contains(boardchair.contact.Id)) {
                    setContact.add(boardchair.contact.Id);
                    listUpdateContacts.add(boardchair.contact);
                }
            }
            if (designateboard != null && designateboard.contact != null) {
                if (designateboard.isNew) {
                    designateboard.contact.AccountId = provider.Id;
                    listInsertContacts.add(designateboard.contact);
                } else {
                    if (!setContact.contains(designateboard.contact.Id)) {
                        setContact.add(designateboard.contact.Id);
                        listUpdateContacts.add(designateboard.contact);
                    }
                }
            }
            for (ContactRoleWrapperclass contactRoleWrapper : contactReviewerList) {
                if (contactRoleWrapper.isNew) {
                    contactRoleWrapper.contact.AccountId = provider.Id;
                    listInsertContacts.add(contactRoleWrapper.contact);
                } else {
                    if (!setContact.contains(contactRoleWrapper.contact.Id)) {
                        setContact.add(contactRoleWrapper.contact.Id);
                        listUpdateContacts.add(contactRoleWrapper.contact);
                    }
                }
            }
            Map<integer, Id> mapInsertContacts = new Map<integer, Id>();
            if (listInsertContacts != null && listInsertContacts.size() > 0) {
                List<Id> listContactId = EEC_ContactRoleUtil.upsertContact(listInsertContacts);
                for (integer iCount = 0; iCount < listContactId.size(); iCount++) {
                    mapInsertContacts.put(iCount + 1, listContactId[iCount]);
                }
            }
            Map<integer, Id> mapUpdateContacts = new Map<integer, Id>();
            if (listUpdateContacts != null && listUpdateContacts.size() > 0) {
                List<Id> listContactId = EEC_ContactRoleUtil.updateContact(listUpdateContacts);
                for (integer iCount = 0; iCount < listContactId.size(); iCount++) {
                    mapUpdateContacts.put(iCount + 1, listContactId[iCount]);
                }
            }
            integer iInsertCount = 1;
            integer iUpdateCount = 1;
            if (licenseTransation.Ownership_Type__c == EEC_Constants.LT_OWNERSHIP_TYPE_PARTERSHIP && LicenseRecordTypeName != EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                for (ContactRoleWrapperclass contactRoleWrapper : contactrolelist) {
                    if (contactRoleWrapper.isNewRole) {
                        Contact_Role__c contactRole = contactRoleWrapper.contactrole;
                        contactRole.Contact__c = mapInsertContacts.get(iInsertCount);
                        contactRole.Provider__c = provider.Id;
                        contactRole.Start_Role_Licensing_Transaction__c = licenseTransation.id;
                        contactRole.Role__c = EEC_Constants.CONTACT_ROLE_PARTNER;
                        if (contactRole.Id == null)
                            listInsertContactRoles.add(contactRole); else
                                listUpdateContactRoles.add(contactRole);
                        iInsertCount++;
                    } else {
                        Contact_Role__c contactRole = contactRoleWrapper.contactrole;
                        contactRole.Role__c = EEC_Constants.CONTACT_ROLE_PARTNER;
                        if (contactRole.End_Role_Licensing_Transaction__c != null && contactRole.End_Date__c != null) {
                            contactRole.End_Role_Licensing_Transaction__c = licenseTransation.id;
                        }
                        if (contactRole.Id == null)
                            listInsertContactRoles.add(contactRole); else
                                listUpdateContactRoles.add(contactRole);
                        iUpdateCount++;
                    }
                }
            }
            if (LicenseRecordTypeName != EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                for (ContactRoleWrapperclass contactRoleWrapper : contactAdminRoleList) {
                    if (contactRoleWrapper.isNewRole) {
                        Contact_Role__c contactRole = contactRoleWrapper.contactrole;
                        contactRole.Contact__c = mapInsertContacts.get(iInsertCount);
                        contactRole.Provider__c = provider.Id;
                        contactRole.Start_Role_Licensing_Transaction__c = licenseTransation.id;
                        if (contactRole.End_Role_Licensing_Transaction__c != null && contactRole.End_Date__c != null) {
                            contactRole.End_Role_Licensing_Transaction__c = licenseTransation.id;
                        }
                        contactRole.Role__c = EEC_Constants.CONTACT_ROLE_ADMINISTRATIVE_DESIGNEE;
                        if (contactRole.Id == null)
                            listInsertContactRoles.add(contactRole); else
                                listUpdateContactRoles.add(contactRole);
                        iInsertCount++;
                    } else {
                        Contact_Role__c contactRole = contactRoleWrapper.contactrole;
                        contactRole.Role__c = EEC_Constants.CONTACT_ROLE_ADMINISTRATIVE_DESIGNEE;
                        if (contactRole.End_Role_Licensing_Transaction__c != null && contactRole.End_Date__c != null) {
                            contactRole.End_Role_Licensing_Transaction__c = licenseTransation.id;
                        }
                        if (contactRole.Id == null)
                            listInsertContactRoles.add(contactRole); else
                                listUpdateContactRoles.add(contactRole);
                        iUpdateCount++;
                    }
                }
            }
            if ((licenseTransation.Ownership_Type__c == EEC_Constants.LT_OWNERSHIP_TYPE_INDIVIDUAL || licenseTransation.Ownership_Type__c == 'Doing Business As (DBA)') && LicenseRecordTypeName != EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                if (ownerContactRole != null) {
                    if (ownerContactRole.isNewRole) {
                        Contact_Role__c contactRole = ownerContactRole.contactrole;
                        contactRole.Contact__c = mapInsertContacts.get(iInsertCount);
                        contactRole.Provider__c = provider.Id;
                        contactRole.Role__c = EEC_Constants.CONTACT_ROLE_OWNER;
                        contactRole.Start_Role_Licensing_Transaction__c = licenseTransation.id;
                        if (contactRole.Id == null)
                            listInsertContactRoles.add(contactRole); else
                                listUpdateContactRoles.add(contactRole);
                        iInsertCount++;
                    } else {
                        Contact_Role__c contactRole = ownerContactRole.contactrole;
                        contactRole.Role__c = EEC_Constants.CONTACT_ROLE_OWNER;
                        if (contactRole.Id == null)
                            listInsertContactRoles.add(contactRole); else
                                listUpdateContactRoles.add(contactRole);
                        iUpdateCount++;
                    }
                }
            }
            if (adminHead != null) {
                adminHead.contactrole.Role__c = EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD;
                if (adminHead.contactRole.Id == null)
                    listInsertContactRoles.add(adminHead.contactRole); else
                        listUpdateContactRoles.add(adminHead.contactRole);
                iUpdateCount++;
            }
            if (administrativehead != null && administrativehead.contactrole != null) {
                if (administrativehead.isNewRole) {
                    Contact_Role__c contactRole = administrativehead.contactrole;
                    if (administrativehead.isNewRole && !administrativehead.isNew) {
                        contactRole.Contact__c = mapUpdateContacts.get(iUpdateCount);
                        iUpdateCount++;
                    } else {
                        contactRole.Contact__c = mapInsertContacts.get(iInsertCount);
                        iInsertCount++;
                    }
                    contactRole.Provider__c = provider.Id;
                    contactRole.Role__c = EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD;
                    contactRole.Start_Role_Licensing_Transaction__c = licenseTransation.id;
                    if (contactRole.Id == null)
                        listInsertContactRoles.add(contactRole); else
                            listUpdateContactRoles.add(contactRole);
                } else {
                    Contact_Role__c contactRole = administrativehead.contactrole;
                    if (contactRole.End_Date__c != null && contactRole.End_Role_Licensing_Transaction__c != null) {
                        contactRole.End_Role_Licensing_Transaction__c = licenseTransation.id;
                    }
                    contactRole.Role__c = EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR_ADMIN_HEAD;
                    if (contactRole.Id == null)
                        listInsertContactRoles.add(contactRole); else
                            listUpdateContactRoles.add(contactRole);
                    iUpdateCount++;
                }
            }
            if (boardchair != null) {
                boardchair.contactrole.Role__c = EEC_Constants.CONTACT_ROLE_BOARD_CHAIR;
                if (boardchair.contactrole.End_Role_Licensing_Transaction__c != null && boardchair.contactrole.End_Date__c != null) {
                    boardchair.contactrole.End_Role_Licensing_Transaction__c = licenseTransation.id;
                }
                if (boardchair.contactRole.Id == null)
                    listInsertContactRoles.add(boardchair.contactRole); else
                        listUpdateContactRoles.add(boardchair.contactRole);
                iUpdateCount++;
            }
            if (designateboard != null && designateboard.contactrole != null) {
                if (designateboard.isNewRole) {
                    Contact_Role__c contactRole = designateboard.contactrole;
                    if (designateboard.isNewRole && !designateboard.isNew) {
                        contactRole.Contact__c = mapUpdateContacts.get(iUpdateCount);
                        iUpdateCount++;
                    } else {
                        contactRole.Contact__c = mapInsertContacts.get(iInsertCount);
                        iInsertCount++;
                    }
                    contactRole.Start_Role_Licensing_Transaction__c = licenseTransation.id;
                    contactRole.Provider__c = provider.Id;
                    contactRole.Role__c = EEC_Constants.CONTACT_ROLE_BOARD_CHAIR;
                    if (contactRole.Id == null)
                        listInsertContactRoles.add(contactRole); else
                            listUpdateContactRoles.add(contactRole);
                } else {
                    Contact_Role__c contactRole = designateboard.contactrole;
                    contactRole.Role__c = EEC_Constants.CONTACT_ROLE_BOARD_CHAIR;
                    if (contactRole.Id == null) {
                        listInsertContactRoles.add(contactRole);
                    } else {
                        listUpdateContactRoles.add(contactRole);
                    }
                    iUpdateCount++;
                }
            }
            for (ContactRoleWrapperclass contactRoleWrapper : contactReviewerList) {
                if (contactRoleWrapper.isNewRole) {
                    Contact_Role__c contactRole = contactRoleWrapper.contactrole;
                    contactRole.Contact__c = mapInsertContacts.get(iInsertCount);
                    contactRole.Provider__c = provider.Id;
                    contactRole.Start_Role_Licensing_Transaction__c = licenseTransation.id;
                    if (contactRole.End_Role_Licensing_Transaction__c != null && contactRole.End_Date__c != null) {
                        contactRole.End_Role_Licensing_Transaction__c = licenseTransation.id;
                    }
                    contactRole.Role__c = EEC_Constants.CONTACT_ROLE_PROGRAM_ADMINISTRATOR;
                    if (contactRole.Id == null)
                        listInsertContactRoles.add(contactRole); else
                            listUpdateContactRoles.add(contactRole);
                    iInsertCount++;
                } else {
                    Contact_Role__c contactRole = contactRoleWrapper.contactrole;
                    contactRole.Role__c = EEC_Constants.CONTACT_ROLE_PROGRAM_ADMINISTRATOR;
                    if (contactRole.End_Role_Licensing_Transaction__c != null && contactRole.End_Date__c != null) {
                        contactRole.End_Role_Licensing_Transaction__c = licenseTransation.id;
                    }
                    if (contactRole.Id == null)
                        listInsertContactRoles.add(contactRole); else
                            listUpdateContactRoles.add(contactRole);
                    iUpdateCount++;
                }
            }
            if (listInsertContactRoles != null && listInsertContactRoles.size() > 0) {
                EEC_ContactRoleUtil.insertContactRole(listInsertContactRoles);
            }
            if (listUpdateContactRoles != null && listUpdateContactRoles.size() > 0) {
                EEC_ContactRoleUtil.updateContactRole(listUpdateContactRoles);
            }
            if (removeRoleList != null && removeRoleList.size() > 0) {
                EEC_ContactRoleUtil.upsertContactRole(removeRoleList);
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
    }
    public Pagereference SaveAndReturnOwnership() {
        try {
            Save('Return');
            if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                    UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
                PageReference pPage = page.EEC_PortalProviderPage;
                addMemberIDPageParameter(pPage, true);
                pPage.setRedirect(true);
                return pPage;
            } else {
                return new PageReference('javascript:window.close()');
            }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public Pagereference SaveAndPreviousOwnership() {
        try {
            //if(validateDates()){
            // Save('Previous');
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            } else {
                pPage = Page.eec_transactionprovider;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
            // }
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public void fetchDesignationDetails() {
        if (licenseTransation.Records_Responsible__c == null || licenseTransation.Records_Responsible__c == '') {
            licenseTransation.Accounts_Responsible__c = provider.Account_books_Responsible__c;
            licenseTransation.Records_Responsible__c = provider.Records_Responsible__c;
            licenseTransation.Personnel_Records_Responsible__c = provider.Personnel_Records_Responsible__c;
            licenseTransation.Children_Records_Responsible__c = provider.Children_s_Records_Responsible__c;
            licenseTransation.Financial_Documentation_Responsible__c = provider.Financial_Documentation_Responsible__c;
            licenseTransation.ECE_program_Responsible__c = provider.Staff_Schedules_Responsible__c;
            licenseTransation.Kindergarten_Responsible__c = provider.Kindergarten_Responsible__c;
            licenseTransation.School_age_Responsible__c = provider.School_age_Responsible__c;
            licenseTransation.Services_4_Disable_children_Responsible__c = provider.Services_for_Children_w_Disability_Resp__c;
            licenseTransation.Daily_activities_Responsible__c = provider.Daily_Activities_Responsible__c;
            licenseTransation.Equipment_Responsible__c = provider.Equipment_Responsible__c;
            licenseTransation.Staff_Development_Responsible__c = provider.Staff_Development_Responsible__c;
            licenseTransation.Staff_Training_Responsible__c = provider.Staff_Training_Responsible__c;
            licenseTransation.Staff_Orientation_Responsible__c = provider.Staff_Orientation_Responsible__c;
            licenseTransation.Staff_Supervision_Responsible__c = provider.Staff_Supervision_Responsible__c;
            licenseTransation.Parent_Involvement_Responsible__c = provider.Parent_Involvement_Responsible__c;
            licenseTransation.Social_Services_Responsible__c = provider.Social_Services_Responsible__c;
            licenseTransation.Infant_Toddler_Program_Responsible__c = provider.Infant_Toddler_Program_Responsible__c;
        }
    }
    /*  public PageReference SaveAndPreviousDesign() {
       // if(LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL){
        //    update provider;
       // }
        licenseTransation.Last_Reached_Step__c = 'Designation of Admin Responsilibity';
        licenseTransation.Records_Responsible__c = provider.Records_Responsible__c;
        licenseTransation.Personnel_Records_Responsible__c = provider.Personnel_Records_Responsible__c;
        licenseTransation.Children_Records_Responsible__c = provider.Children_s_Records_Responsible__c;
        licenseTransation.Financial_Documentation_Responsible__c = provider.Financial_Documentation_Responsible__c;
        licenseTransation.ECE_program_Responsible__c = provider.Staff_Schedules_Responsible__c;
        licenseTransation.Staff_Schedule_Responsible__c = provider.Early_Childhood_Education_Program_Resp__c;
        licenseTransation.Kindergarten_Responsible__c = provider.Kindergarten_Responsible__c;
        licenseTransation.School_age_Responsible__c = provider.School_age_Responsible__c;
        licenseTransation.Services_4_Disable_children_Responsible__c = provider.Services_for_Children_w_Disability_Resp__c;
        licenseTransation.Daily_activities_Responsible__c = provider.Daily_Activities_Responsible__c;
        licenseTransation.Equipment_Responsible__c = provider.Equipment_Responsible__c;
        licenseTransation.Staff_Development_Responsible__c = provider.Staff_Development_Responsible__c;
        licenseTransation.Staff_Training_Responsible__c = provider.Staff_Training_Responsible__c;
        licenseTransation.Staff_Orientation_Responsible__c = provider.Staff_Orientation_Responsible__c;
        licenseTransation.Staff_Supervision_Responsible__c = provider.Staff_Supervision_Responsible__c;
        licenseTransation.Parent_Involvement_Responsible__c = provider.Parent_Involvement_Responsible__c;
        licenseTransation.Social_Services_Responsible__c = provider.Social_Services_Responsible__c;
        licenseTransation.Infant_Toddler_Program_Responsible__c = provider.Infant_Toddler_Program_Responsible__c;
        //update licenseTransation;
        PageReference pPage;
        if(string.IsNotBlank(previousPageName)){
            if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC){
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT){
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella' ){
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            }
        }
        else{
            if(string.IsNotBlank(previousPageName)){
                if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC){
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                }
                else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT){
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                }
                else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella' ){
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                }
                else if(licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            }
            else{
                pPage = page.EEC_OwnershipAdministratorInfo;
            }
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    */
    /*
     public PageReference SaveAndNextDesign() {
        try{
        PageReference pPage;
        if(LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE||LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE ||LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE ||LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL||LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE){
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
            pPage = page.EEC_CapacityInformation;
            if(isSaveOnly){
                pPage = page.eec_designationofadministrative;
                licenseTransation.Last_Reached_Step__c = 'Designation of Admin Responsilibity';
            }
        }else if(LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY){
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            pPage = page.EEC_LicensingAttachment;
            if(isSaveOnly){
                pPage = page.eec_designationofadministrative;
                licenseTransation.Last_Reached_Step__c = 'Designation of Admin Responsilibity';
            }
        }
        /*if(LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE){
            update provider;
        }
        /*licenseTransation.Records_Responsible__c = provider.Records_Responsible__c;
        licenseTransation.Personnel_Records_Responsible__c = provider.Personnel_Records_Responsible__c;
        licenseTransation.Children_Records_Responsible__c = provider.Children_s_Records_Responsible__c;
        licenseTransation.Financial_Documentation_Responsible__c = provider.Financial_Documentation_Responsible__c;
        licenseTransation.ECE_program_Responsible__c = provider.Staff_Schedules_Responsible__c;
        licenseTransation.Staff_Schedule_Responsible__c = provider.Early_Childhood_Education_Program_Resp__c;
        licenseTransation.Kindergarten_Responsible__c = provider.Kindergarten_Responsible__c;
        licenseTransation.School_age_Responsible__c = provider.School_age_Responsible__c;
        licenseTransation.Services_4_Disable_children_Responsible__c = provider.Services_for_Children_w_Disability_Resp__c;
        licenseTransation.Daily_activities_Responsible__c = provider.Daily_Activities_Responsible__c;
        licenseTransation.Equipment_Responsible__c = provider.Equipment_Responsible__c;
        licenseTransation.Staff_Development_Responsible__c = provider.Staff_Development_Responsible__c;
        licenseTransation.Staff_Training_Responsible__c = provider.Staff_Training_Responsible__c;
        licenseTransation.Staff_Orientation_Responsible__c = provider.Staff_Orientation_Responsible__c;
        licenseTransation.Staff_Supervision_Responsible__c = provider.Staff_Supervision_Responsible__c;
        licenseTransation.Parent_Involvement_Responsible__c = provider.Parent_Involvement_Responsible__c;
        licenseTransation.Social_Services_Responsible__c = provider.Social_Services_Responsible__c;
        licenseTransation.Infant_Toddler_Program_Responsible__c = provider.Infant_Toddler_Program_Responsible__c;
        update licenseTransation;
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
        }catch(Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }*/
    public PageReference saveAndNextPlacement() {
        try {
            if (heldLicense.size() != 0) {
                insert heldLicense;
            }
            if (relatedLicense.size() != 0) {
                insert relatedLicense;
            }
            if (federalInv.size() != 0) {
                insert federalInv;
            }
            if (criminalAct.size() != 0) {
                insert criminalAct;
            }
        } catch (exception e) {
        }
        PageReference pPage;
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
        pPage = page.EEC_LicensingAttachment;
        if (isSaveOnly) {
            pPage = page.eec_placementagency;
            licenseTransation.Last_Reached_Step__c =EEC_Constants.LT_LAST_REACHED_PLACEMENT_AGENCY_ADDITIONAL_INFO;
        }
        if (!isSubmitted) {
            update licenseTransation;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public PageReference saveAndPreviousPlacement() {
        /*try {
            if (heldLicense.size()!=0) {
                insert heldLicense;
            }
            if (relatedLicense.size()!=0) {
                insert relatedLicense;
            }
            if (federalInv.size()!=0) {
                insert federalInv;
            }
            if (criminalAct.size()!=0) {
                insert criminalAct;
            }
         }catch (exception e){
         }
        update licenseTransation;*/
        PageReference pPage;
        if (string.IsNotBlank(previousPageName)) {
            if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            }
        } else {
            if (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE) {
                pPage = page.eec_transactionprovider;
            } else {
                pPage = page.EEC_OwnershipAdministratorInfo;
            }
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference saveAndReturnPlacement() {
        try {
            if (heldLicense.size() != 0) {
                insert heldLicense;
            }
            if (relatedLicense.size() != 0) {
                insert relatedLicense;
            }
            if (federalInv.size() != 0) {
                insert federalInv;
            }
            if (criminalAct.size() != 0) {
                insert criminalAct;
            }
        } catch (exception e) {
        }
        if (!isSubmitted) {
            update licenseTransation;
        }
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public Pagereference saveAndReturnDesignation() {
        if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE)) {
            provider.Electronic_Communication__c = true;
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DESIGNATION_ADMIN_RESPONSIBILITY;
        }
        if (!isSubmitted) {
            update licenseTransation;
            update provider;
            if (cntct != null) {
                update cntct;
            }
        }
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public Pagereference SaveAndPreviousCapacity() {
        try {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OPERATION_DETAILS;
            //update provider;
            PageReference pPage;
            if (string.IsNotBlank(previousPageName)) {
                if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            } else {
                pPage = Page.EEC_CapacityInformation;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
    public PageReference SaveAndNextCapacity() {
        if (!isSubmitted) {
            if (minAge != null && minMon != null && maxAge != null && maxMon != null) {
                if (Integer.valueOf(minAge) * 12 + Integer.valueOf(minMon) > Integer.valueOf(maxAge) * 12 + Integer.valueOf(maxMon)) {
                        minMaxAgeError = true;
                    return null;
                } else {
                    minMaxAgeError = false;
                }
            }
        }
        PageReference pPage;
        if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION ) {
            licenseTransation.Last_Reached_Step__c = 'Operation details Information';
            pPage = page.EEC_OperationDetailInfo;
            if (isSaveOnly) {
                pPage = page.eec_capacityinformation;
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
            }
        } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
            pPage = page.eec_indoorspacegsapage;
            if (isSaveOnly) {
                pPage = page.eec_capacityinformation;
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
            }
        } else if (LicenseRecordTypeName == EEC_Constants.LT_EEC_GSA_MODIFICATION) {
            pPage = page.eec_gsareviewsummary;
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUMMARY_AND_SUBMISSION;
            if (isSaveOnly) {
                //I-04420 Argument cannot be null fixed
                pPage = page.eec_capacityinformation;
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
            }
        }
        if (!isSubmitted) {
            if (minAge != null) {
                licenseTransation.Minimum_Age_Limit_Requested_Years__c = Decimal.valueOf(minAge);
            }
            if (minMon != null) {
                licenseTransation.Minimum_Age_Limit_Requested_Months__c = Decimal.valueOf(minMon);
            }
            if (maxAge != null) {
                licenseTransation.Maximum_Age_Limit_Requested_Years__c = Decimal.valueOf(maxAge);
            }
            if (maxMon != null) {
                licenseTransation.Maximum_Age_Limit_Requested_Months__c = Decimal.valueOf(maxMon);
            }
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE && !isSubmitted) {
            //update provider;
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE && provider.RecordType.DeveloperName == EEC_Constants.PRO_SMALL_GROUP) {
            //licenseTransation.Small_Group_Capacity__c = provider.Capacity_Small_Group__c;
        }
        //Need to Add the Code To Trigger
        /*licenseTransation.Infant_Capacity__c = provider.Infant_birth_15_mo__c;
        licenseTransation.Infant_Toddler_Capacity__c= provider.Infant_Toddler_birth_33_mo__c;
        licenseTransation.Toddler_Capacity__c= provider.Toddler_15_mo_33_mo__c;
        licenseTransation.Toddler_Preschool_Capacity__c= provider.Toddler_Preschool_15_mo_K__c;
        licenseTransation.Preschool_Capacity__c= provider.Preschool_33_mo_K__c;
        licenseTransation.Preschool_SA_Capacity__c= provider.Preschool_SA_33_mo_8_yr__c;
        licenseTransation.Kindergarten_Capacity__c= provider.Kindergarten__c;
        licenseTransation.School_Age_Capacity__c= provider.School_Age_5_yr_14_yr__c;
        licenseTransation.Multi_Age_Group_Capacity__c= provider.Multi_Age_Group_birth_14_yr__c;
        */
        if (!isSubmitted) {
            update licenseTransation;
            createTrainingTransactionDocuments();
        }
        if (isSaveOnly) {
            pPage = page.EEC_CapacityInformation;
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public PageReference SaveAndPreviousCapac() {
        /* if(Integer.valueOf(minAge) * 12 + Integer.valueOf(minMon) > Integer.valueOf(maxAge) * 12 + Integer.valueOf(maxMon)){
            minMaxAgeError = true;
            return null;
        } else {
            minMaxAgeError = false;
        }
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
        licenseTransation.Minimum_Age_Limit_Requested_Years__c = Decimal.valueOf(minAge);
        licenseTransation.Minimum_Age_Limit_Requested_Months__c = Decimal.valueOf(minMon);
        licenseTransation.Maximum_Age_Limit_Requested_Years__c = Decimal.valueOf(maxAge);
        licenseTransation.Maximum_Age_Limit_Requested_Months__c = Decimal.valueOf(maxMon);
        */
        PageReference pPage;
        if (string.IsNotBlank(previousPageName)) {
            if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE) {
                pPage = page.EEC_TransactionProvider;
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER|| licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_PUBLIC_SCHOOL|| licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_PRIVATE_SCHOOL) {
                pPage = EEC_Util.lastCBCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SUMMER_CAMP) {
              //  pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
            }
        } else {
            if (LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                    || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                     || LicenseRecordTypeName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                    || LicenseRecordTypeName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION
                    || LicenseRecordTypeName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                    || LicenseRecordTypeName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION ) {
                pPage = page.EEC_DesignationOfAdministrative;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE || LicenseRecordTypeName == EEC_Constants.LT_EEC_GSA_MODIFICATION) {
                pPage = page.EEC_TransactionProvider;
            }
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference saveAndReturnCapacity() {
        if (Integer.valueOf(minAge) * 12 + Integer.valueOf(minMon) > Integer.valueOf(maxAge) * 12 + Integer.valueOf(maxMon)) {
            minMaxAgeError = true;
            return null;
        } else {
            minMaxAgeError = false;
        }
        if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE)) {
            provider.Electronic_Communication__c = true;
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
        }
        if (!isSubmitted) {
            update licenseTransation;
            update provider;
            if (cntct != null) {
                update cntct;
            }
        }
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public PageReference SaveAndNextOperation() {
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
        PageReference pPage = page.eec_indoorspacegsapage;
        if (isSaveOnly) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OPERATION_DETAILS_INFORMATION;
            pPage = page.eec_operationdetailinfo;
        }
        if (!isSubmitted) {
            update licenseTransation;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public PageReference SaveAndPreviousOperation() {
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OPERATION_DETAILS;
        PageReference pPage;
        if (string.IsNotBlank(previousPageName)) {
            if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER|| licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_PUBLIC_SCHOOL|| licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_PRIVATE_SCHOOL) {
                pPage = EEC_Util.lastCBCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SUMMER_CAMP) {
              //  pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
            }
        } else {
            pPage = page.eec_capacityinformation;
        }
        //update licenseTransation;
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public void udateDesignatedAdmin() {
    }
    public Pagereference saveAndReturnOperation() {
        if ((LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_PLACEMENT_MOVE
                || LicenseRecordTypeName == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY)
                || (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE)) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OPERATION_DETAILS;
        }
        if (!isSubmitted) {
            update licenseTransation;
            update provider;
            if (cntct != null) {
                update cntct;
            }
        }
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public PageReference SaveAndNextResidentialDetail() {
        PageReference pPage;
        if(licenseTransation.Awake_Staff_to_child_ratio_Staff__c == null && licenseTransation.Overnight_Staff_to_child_ratio_Staff__c == null ){
            licenseTransation.Awake_Staff_to_child_ratio_Staff__c = 1;
            licenseTransation.Overnight_Staff_to_child_ratio_Staff__c = 1;
        }
        if (LicenseRecordTypeName == EEC_Constants.LT_EEC_RP_MODIFICATION) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
            pPage = page.EEC_rp_reviewsummary;
        } else {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            pPage = page.EEC_LicensingAttachment;
        }
        if (isSaveOnly) {
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_OWNERSHIP_ADMINISTRATOR_INFO;
            pPage = page.eec_residentialprogramdetail;
        }
        if (!isSubmitted) {
            update licenseTransation;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public PageReference SaveAndPreviousResidentialDetail() {
        PageReference pPage;
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_RESIDENTIAL_PROGRAM_DETAILS;
        if (string.IsNotBlank(previousPageName)) {
            if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            }
        } else {
            if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_MOVE || LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL) {
                pPage = page.EEC_OwnershipAdministratorInfo;
            } else if (LicenseRecordTypeName == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE || LicenseRecordTypeName == EEC_Constants.LT_EEC_RP_MODIFICATION) {
                pPage = page.EEC_TransactionProvider;
            }
        }
        //update licenseTransation;
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference saveAndReturnResidentialDetail() {
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_RESIDENTIAL_PROGRAM_DETAILS;
        if (!isSubmitted) {
            update licenseTransation;
        }
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public PageReference SaveAndNextIndoorGSA() {
        try {
            if (!isSubmitted) {
                saveGSARoom();
            }
            PageReference pPage;
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            pPage = page.EEC_LicensingAttachment;
            if (isSaveOnly) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
                pPage = page.eec_indoorspacegsapage;
            }
            if (!isSubmitted) {
                update licenseTransation;
            }
            createTrainingTransactionDocuments();
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
            return null;
        }
    }
    public PageReference SaveAndPreviousIndoorGSA() {
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
        PageReference pPage;
        if (string.IsNotBlank(previousPageName)) {
            if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_EXEMPT_CBC_CARE || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_PRIVATE_SCHOOL || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_PUBLIC_SCHOOL) {
                pPage = EEC_Util.lastCBCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SUMMER_CAMP) {
              //  pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
            }
        } else if (LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE) {
            pPage = page.eec_capacityinformation;
        } else {
            pPage = page.EEC_OperationDetailInfo;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference saveAndReturnIndoorGSA() {
        if (!isSubmitted) {
            saveGSARoom();
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
            update licenseTransation;
        }
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public integer refAg { get; set; }
    public boolean refCheck { get; set; }
    public void otherReferral() {
        string str = '';
        //str = str + licenseTransation.Working_with_which_Referral_Agencies__c;
       
        if (str.contains('Other')) {
            referralAgency = true;
        } else {
            referralAgency = false;
        }
    }
    public integer valCh { get; set; }
    public void internationalCountries() {
        string str = '';
        str = str + licenseTransation.Characteristics_of_children_served__c;
        if (licenseTransation.Characteristics_of_children_served__c == null) {
            valCh = 0;
            characterRadio = false;
        } else {
            valCh = 1;
            characterRadio = true;
        }
        if (str.contains('International Adoption')) {
            interCountries = true;
        } else {
            interCountries = false;
        }
    }
    public Integer bldg { get; set; }
    public boolean bldgCheck { get; set; }
    public void bldgCode() {
        if (licenseTransation.Building_Codes_c__c == null) {
            bldg = 0;
            bldgCheck = false;
        } else {
            bldg = 1;
            bldgCheck = true;
        }
    }
    public Integer intAdoptCount { get; set; }
    public boolean intAdoptCheck { get; set; }
    public void otherCountries() {
        string str = '';
        str = str + licenseTransation.International_adoption_countries__c;
        if (licenseTransation.International_adoption_countries__c == null) {
            intAdoptCount = 0;
            intAdoptCheck = false;
        } else {
            intAdoptCount = 1;
            intAdoptCheck = true;
        }
        if (str.contains('Other(s)')) {
            otherCount = true;
        } else {
            otherCount = false;
        }
    }
    public void dcfSpecialNeeds() {
        
    }
    /*Capacity Page Min and Max years and months*/
    public string minAge { get; set; }
    public string maxAge { get; set; }
    public string minMon { get; set; }
    public string maxMon { get; set; }
    public List<SelectOption> getMinMaxYears() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption('0', '0'));
        options.add(new SelectOption('1', '1'));
        options.add(new SelectOption('2', '2'));
        options.add(new SelectOption('3', '3'));
        options.add(new SelectOption('4', '4'));
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('6', '6'));
        options.add(new SelectOption('7', '7'));
        options.add(new SelectOption('8', '8'));
        options.add(new SelectOption('9', '9'));
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('11', '11'));
        options.add(new SelectOption('12', '12'));
        options.add(new SelectOption('13', '13'));
        options.add(new SelectOption('14', '14'));
        return options;
    }
    public List<SelectOption> getMinMaxMonths() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption('0', '0'));
        options.add(new SelectOption('1', '1'));
        options.add(new SelectOption('2', '2'));
        options.add(new SelectOption('3', '3'));
        options.add(new SelectOption('4', '4'));
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('6', '6'));
        options.add(new SelectOption('7', '7'));
        options.add(new SelectOption('8', '8'));
        options.add(new SelectOption('9', '9'));
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('11', '11'));
        return options;
    }
    /*Minimum age and Maximum age for Residential Program Detail*/
    public string minAgeRes { get; set; }
    public string maxAgeRes { get; set; }
    public List<SelectOption> getMinMaxAge() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption('0', '0'));
        options.add(new SelectOption('1', '1'));
        options.add(new SelectOption('2', '2'));
        options.add(new SelectOption('3', '3'));
        options.add(new SelectOption('4', '4'));
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('6', '6'));
        options.add(new SelectOption('7', '7'));
        options.add(new SelectOption('8', '8'));
        options.add(new SelectOption('9', '9'));
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('11', '11'));
        options.add(new SelectOption('12', '12'));
        options.add(new SelectOption('13', '13'));
        options.add(new SelectOption('14', '14'));
        options.add(new SelectOption('15', '15'));
        options.add(new SelectOption('16', '16'));
        options.add(new SelectOption('17', '17'));
        options.add(new SelectOption('18', '18'));
        options.add(new SelectOption('19', '19'));
        options.add(new SelectOption('20', '20'));
        options.add(new SelectOption('21', '21'));
        return options;
    }
    //wrapperclass for contactrole
    public class ContactRoleWrapperclass {
        //variable list
        public boolean isNew { get; set; }
        public boolean isNewRole { get; set; }
        public Contact_Role__c contactrole { get; set; }
        public Contact contact { get; set; }
        public String holdFCCLicense { get; set; }
        public String portalAccess { get; set; }
        //constructor
        public ContactRoleWrapperclass(Boolean isNew, Boolean isNewRole, Contact contactrecord, Contact_Role__c contactrole) {
            if (contactrecord == null) {
                contactrecord = new Contact();
            }
            if (contactrole == null) {
                contactrole = new Contact_Role__c();
            }
            this.contact = contactrecord;
            this.contactrole = contactrole;
            this.isNew = isNew;
            this.isNewRole = isNewRole;
            if (contactrecord != null && contactrecord.Holds_FCC_License__c) {
                holdFCCLicense = 'Yes';
            } else {
                holdFCCLicense = 'No';
            }
            if (contactrole != null && contactrole.Portal_Access__c) {
                portalAccess = 'Yes';
            } else {
                portalAccess = 'No';
            }
        }
    }
    public void initsubmmision(String ltId) {
        List<Licensing_Transaction__c> licentraslist = [
                SELECT Id,Name,Program_licensed_or_approved_by_agency__c,
                        Accounts_Responsible__c,Is_your_program_contracted__c,Name_of_contract_administrator__c,
                        Address_of_admin_for_funding_source__c,Number_of_Open_Foster_Homes__c,Number_of_children_placed_in_care__c,
                        Provider__r.State__c,Provider__r.Provider_Zip_Code__c,Provider__r.Provider_City__c,Provider__r.Provider_Address_2__c,
                        Provider__r.Provider_Address_1__c,New_Street_Address_1__c,New_Street_Address_2__c,New_City__c,New_Zip_Code__c,
                        Moving_Date__c,Date_Care_Resumes__c,New_Address_Phone_Number__c,Provider__r.ShippingStreet,Provider__r.ShippingCity,
                        Provider__r.ShippingPostalCode,Provider__r.ShippingState,Provider__r.Phone,Provider__r.Alternate_Phone__c,
                        Provider__r.Fax,Provider__r.Provider_Email__c,//Provider__r.Name_of_the_Person_to_Contact__c,Ownership_Type__c,
                        Characteristics_of_children_served__c,
                        International_adoption_countries__c,Other_countries__c,Gender_of_children_served__c,Provider__r.Capacity__c,
                        Requested_capacity__c,Awake_Staff_to_child_ratio__c,Awake_Staff_to_child_ratio_Staff__c,Awake_Staff_to_child_ratio_Child__c,Asleep_Staff_to_child_ratio__c,Overnight_Staff_to_child_ratio_Staff__c,Ratio_comments__c,
                        Minimum_age_of_children_served__c,
                        Maximum_age_of_children_served__c,Other_Referral_Agency__c,
                        Number_of_Adoptive_Placements__c,Number_of_Foster_Homes__c,Number_of_birth_mothers_recving_services__c,
                        Birth_mothers_making_adoption_plans__c,Number_of_Waiting_Families__c,Families_recving_home_study_services__c,
                        Recving_search_and_or_reunion_services__c,Number_recving_Search_reunion_services__c,Number_of_Reunions_Facilitated__c,
                        Number_of_Child_Assessments__c,Number_of_Home_Study_Services__c,Families_recving_case_mgmt_services__c,
                        Families_recving_information_referral__c,DCF_Nb_Children_Placed_In_Care__c,
                        Technical_Assistance__c
                FROM Licensing_Transaction__c
                where Id = :ltId
        ];
    }
    public String havesiteCordinator { get; set; }
    public pagereference saveandpreviousGSASummary() {
        PageReference pPage;
        if (string.IsNotBlank(previousPageName)) {
            if (LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_PROVIDER_NAME
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME
                    || LicenseRecordTypeName == EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE
                    || LicenseRecordTypeName == EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT
                    || LicenseRecordTypeName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY) {
                pPage = EEC_Util.lastStepMapForOnePageApplication.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC) {
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella') {
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            } else if (licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY) {
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            }else if(licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER|| licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_PUBLIC_SCHOOL|| licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_PRIVATE_SCHOOL){
                pPage = EEC_Util.lastCBCStepMap.get(previousPageName);
            }else if(licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_SUMMER_CAMP){
              //  pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
            }else if(licenseTransation.providerRecordTypeDeveloperName__c ==EEC_Constants.PRO_INFORMAL_CHILD_CARE){
               pPage = EEC_Util.lastInformalCareStepMap.get(previousPageName);
            }
        } else if (LicenseRecordTypeName == EEC_Constants.LT_CHANGE_OF_PROVIDER_NAME
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_CHANGE_OF_NAME
                || LicenseRecordTypeName == EEC_Constants.LT_CLOSE_PRIOR_EXPRIRATION
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_INACTIVATE
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_RE_ACTIVE
                || LicenseRecordTypeName == EEC_Constants.LT_RE_ISSUANCE_OF_LICENSE_CERT
                || LicenseRecordTypeName == EEC_Constants.LT_FCC_DOWNGRADE_CAPACITY) {
            pPage = Page.EEC_TransactionInstructions;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_BACKGROUND_RECORD_CHECK 
        || LicenseRecordTypeName == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME) {
            pPage = Page.EEC_ownershipadministratorinfo;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_EEC_GSA_MODIFICATION) {
            pPage = Page.eec_capacityinformation;
        } else if (LicenseRecordTypeName == EEC_Constants.LT_EEC_RP_MODIFICATION) {
            pPage = Page.EEC_ResidentialProgramDetail;
        }else if(LicenseRecordTypeName == EEC_Constants.LT_CLOSE_FUNDED_API_NAME || LicenseRecordTypeName == EEC_Constants.LT_CLOSE_INFORMAL_CHILD_CARE_API_NAME){
            pPage = Page.EEC_IntentToCloseFundingProgram;     
        } else {
            pPage = Page.EEC_LicensingAttachment;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public pagereference saveandreturnTOProviderGSASummary() {
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
        update licenseTransation;
        if (UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'PowerCustomerSuccess' ||
                UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'CustomerSuccess') {
            PageReference pPage = page.EEC_PortalProviderPage;
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } else {
            return new PageReference('javascript:window.close()');
        }
    }
    public void createPaymentReceivedRecord() {
        String licenseTransactionId = ApexPages.currentPage().getParameters().get('ltId');
        if (String.isNotBlank(licenseTransactionId)) {
            List<Transaction_Due_Diligence__c> dueDiligenceList = [
                    SELECT Id,
                            Name,
                            Unique_API_Name__c,
                            Status__c
                    FROM Transaction_Due_Diligence__c
                    WHERE Licensing_Transaction__c = :licenseTransactionId
                    AND Unique_API_Name__c = 'Review_and_enter_application_fee_payment'
            ];
            List<Licensing_Transaction__c> licenseTransactionList = [
                    SELECT Id,
                            Name,
                            Associated_Fee__c,
                            Provider__r.Region__c,
                            Provider__c
                    FROM Licensing_Transaction__c
                    WHERE Id = :licenseTransactionId
            ];
            if (!licenseTransactionList.isEmpty()) {
                Payments_Received__c payment = new Payments_Received__c();
                payment.Associated_Transactions__c = licenseTransactionId;
                payment.Number__c = '123456789';
                payment.Payment_Status__c = 'Deposited';
                payment.Region__c = licenseTransactionList[0].Provider__r.Region__c;
                payment.Type_of_Payment__c = 'Credit Card';
                payment.Received_Date__c = Date.today();
                payment.Deposit_Date__c = Date.today();
                payment.Amount__c = licenseTransactionList[0].Associated_Fee__c;
                payment.Provider__c = licenseTransactionList[0].Provider__c;
                try {
                    insert payment;
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
                }
                if (!dueDiligenceList.isEmpty()) {
                    dueDiligenceList[0].Status__c = 'Completed';
                    try {
                        update dueDiligenceList;
                    } catch (Exception ex) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
                    }
                }
            }
        }
    }
    public void createTaskWithPaymentFailed() {
        String licenseTransactionId = ApexPages.currentPage().getParameters().get('ltId');
        if (String.isNotBlank(licenseTransactionId)) {
            List<User> userList = [
                    SELECT Id,
                            ContactId
                    FROM User
                    WHERE Id = :Userinfo.getUserId()
                    AND ContactId != null
            ];
            if (!userList.isEmpty()) {
              //  Id recordtypeid = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Tasks').getRecordTypeId();
                Task tsk = new Task();
                tsk.ActivityDate = Date.today();
                tsk.WhoId = userList[0].ContactId;
                tsk.WhatId = licenseTransactionId;
                tsk.Status = 'Completed';
                tsk.Subject = 'Failed Payment Attempt';
              //  tsk.RecordTypeId = recordtypeid;
                tsk.Type = 'Other';
                tsk.Description = 'Payment Transaction Id for the failed attempt. Error code provided by payment gateway. Make sure no sensitive'
                        + 'info will ever be returned in the errors so we don’t log them inadvertently';
                try {
                    insert tsk;
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));  
                }
            }
        }
    }
  }