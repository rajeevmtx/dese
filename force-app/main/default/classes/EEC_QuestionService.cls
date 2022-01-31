public class EEC_QuestionService {

    public enum Section {
        BackgroundInformation,
        TrainingInformation
    }


    public static List<EEC_Question> getLicensingSectionQuestionsForProvider(Section section, String providerType) {
        if (!sectionProviderQuestions.containsKey(section) || !sectionProviderQuestions.get(section).containsKey(providerType)) {
            return new List<EEC_Question>();
        }

        return sectionProviderQuestions.get(section).get(providerType);
    }

    private static List<SelectOption> getCities() {
        SelectOption[] cities = new SelectOption[] { };

        cities.add(new SelectOption('', ''));

        for (City__c c : [SELECT Id, Name, State__c FROM City__c where State__c = 'MA' AND ISDeleted = false ORDER BY Name]) {
            cities.add(new SelectOption(c.Id, c.Name + ' (' + c.State__c + ')'));
        }

        return cities;
    }

    public static List<SelectOption> getPicklistValues(SObjectField field) {
        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', '') };

        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)  {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }

    public static List<SelectOption> getRecordTypes(SObjectType t) {
        return getRecordTypes(t, new Set<String>());
    }

    public static List<SelectOption> getRecordTypes(SObjectType t, Set<String> withoutContains) {
        List<Schema.RecordTypeInfo> types = t.getDescribe().getRecordTypeInfos();

        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', '') };

        for(Schema.RecordTypeInfo rt : types) {
            if (!containsContains(withoutContains, rt.getName()) && rt.getName() != 'Master' ) {
                options.add(new SelectOption(rt.getRecordTypeId(), rt.getName()));
            }
        }

        return options;
    }

    public static Boolean containsContains(Set<String> stringSet, String v) {
        for(String s : stringSet) {
            if (v.contains(s)) {
                return true;
            }
        }

        return false;
    }

    /**
    * Summary Section Questions
    */
    public static List<EEC_Question> complaintSummaryProvider = new List<EEC_Question>{
            new EEC_SimpleQuestion('Account.Name', 'Provider Name')
                    .addCondition('Unlicensed_Provider_Name', NULL),
            new EEC_SimpleQuestion('Unlicensed_Provider_Name', 'Provider Name')
                    .addCondition('AccountId', NULL),
            new EEC_SimpleQuestion('Account.Provider_Address_1__c', 'Street Address')
                    .addCondition('Unlicensed_Provider_Street', NULL),
            new EEC_SimpleQuestion('Unlicensed_Provider_Street', 'Street Address')
                    .addCondition('AccountId', NULL),
            new EEC_SimpleQuestion('Account.Provider_City__r.Name', 'City')
                    .addCondition('Unlicensed_Provider_Street', NULL),
            new EEC_SimpleQuestion('Unlicensed_Provider_City_Text', 'City')
                    .addCondition('AccountId', NULL)
    };

    /**
    * Reporter Information Questions
    */
   

    public static List<EEC_Question> complaintReporterAddressQuestion = new List<EEC_Question>{
            new EEC_SimpleQuestion('Contact.MailingStreet', 'Street')
                    .maxLength(255)
                    .isRequired(false),

            new EEC_SimpleQuestion('Contact.MailingCity', 'City')
                    .maxLength(40)
                    .isRequired(false),

            new EEC_SimpleQuestion('Contact.MailingState', 'State')
                    .maxLength(20)
                    .isRequired(false),

            new EEC_SimpleQuestion('Contact.MailingPostalCode', 'Zip')
                    .maxLength(20)
                    .isRequired(false)
    };

    public static List<EEC_Question> complaintReporterContactQuestion = new List<EEC_Question>{
            new EEC_PicklistQuestion('Preferred_Contact_Method', 'Prefered Contact Method')
                    
                    .setRerender('questionRefreshSection'),

            new EEC_SimpleQuestion('Contact.HomePhone', 'Home Phone Number')
                    .maxLength(40)
                    .isRequired(false),

            new EEC_SimpleQuestion('Contact.MobilePhone', 'Mobile Phone Number')
                    .maxLength(40)
                    .isRequired(false),

            new EEC_SimpleQuestion('Contact.Phone', 'Work Phone Number')
                    .maxLength(40)
                    .isRequired(false),

            new EEC_PicklistQuestion('Best_Phone_Number_to_use', 'Best Phone Number to use')
                    .addCondition('Preferred_Contact_Method', 'Phone'),

            new EEC_PicklistQuestion('Best_time_to_contact', 'What is the best time to reach you?')
                    .addCondition('Preferred_Contact_Method', 'Phone'),

            new EEC_EmailQuestion('Contact.Email', 'Email')
                    .maxLength(80)
                    .addCondition('Preferred_Contact_Method', 'Email'),

            new EEC_EmailQuestion('Contact.Email', 'Email')
                    .maxLength(80)
                    .addCondition('Preferred_Contact_Method', 'Phone')
                    .isRequired(false),

            new EEC_EmailQuestion('Contact.Email', 'Email')
                    .maxLength(80)
                    .addCondition('Preferred_Contact_Method', NULL)
                    .isRequired(false)
            /**
                @TODO: Support a not condition
            **/
    };

    /**
    * Complaint Information Questions
    */
    public static List<EEC_Question> complaintInformationOtherQuestions = new List<EEC_Question> {
            new EEC_SimpleQuestion('Description', 'Additional Comments / Description')
                    .isTextArea(true)
                    .maxLength(32000)
    };

    public static List<EEC_Question> complaintSharedProvider = new List<EEC_Question> {
            new EEC_PicklistQuestion('Shared_with_Provider', 'Was this information shared with someone at the program?')
                    .setRerender('questionRefreshSection'),

            new EEC_SimpleQuestion('Who_Shared_with_Provider', 'Who did you share the information with (name)?')
                    .maxLength(80)
                    .addCondition('Shared_with_Provider', 'Yes'),

            new EEC_DateQuestion('When_Shared_with_Provider', 'When was the information shared (date or estimated date)?')
                    .addCondition('Shared_with_Provider', 'Yes'),

            new EEC_SimpleQuestion('If_yes_what_happened', 'What happened as a result of you communicating your concerns to the program?')
                    .isTextArea(true)
                    .addCondition('Shared_with_Provider', 'Yes'),

            new EEC_SimpleQuestion('If_not_why_not', 'Why not?')
                    .isTextArea(true)
                    .addCondition('Shared_with_Provider', 'No')
    };


    public static List<EEC_Question> complaintFilling = new List<EEC_Question> {
            new EEC_PicklistQuestion('Filed_with_DCF', 'Was a report filed with the Massachusetts Department of Children and Families (DCF)(51A)?')
                    .setRerender('questionRefreshSection'),

            new EEC_SimpleQuestion('DCF_Filer', 'By whom?')
                    .maxLength(80)
                    .addCondition('Filed_with_DCF', 'Yes'),

            new EEC_EmptyQuestion()
                    .isRequired(false),

            new EEC_DateQuestion('DCF_File_Submission_Date', 'When was it reported?')
                    .addCondition('Filed_with_DCF', 'Yes')
    };

    public static List<EEC_Question> complaintInfoDescrQuestions = new List<EEC_Question> {
            new EEC_SimpleQuestion('Subject', 'Summary / Type of Case')
                    .maxLength(255),

            new EEC_SimpleQuestion('Nature_of_complaint', 'What is the nature of your complaint?  What happened?')
                    .isTextArea(true),

            new EEC_DateTimeQuestion('Date_Event_Occured', 'Time_Event_Occured', 'When did this occur?')
                    .setRerender('questionRefreshSection'),

            new EEC_SimpleQuestion('Event_Location', 'Where did this occur?  Inside the program or outside? Which room, building etc.')
                    .isTextArea(true)
                    .maxLength(255),

            new EEC_SimpleQuestion('Reason_Issue_Known', 'How do you know about this situation?')
                    .isTextArea(true)
    };


    private static Id getRecordTypeId(Schema.DescribeSObjectResult t, String recordType){
        return t.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
    }

   

    /**
    * Complaint Provider Information
    */
    public static List<EEC_Question> unlicensedComplaintQuestions = new List<EEC_Question> {
            new EEC_SimpleQuestion('Unlicensed_Provider_Name', 'Provider Name')
                    .maxLength(100),

            new EEC_SimpleQuestion('Unlicensed_Provider_Street', 'Street Address')
                    .maxLength(100),

            new EEC_PicklistQuestion('Unlicensed_Provider_City', 'City')
                    .setOptions(getCities()),

            new EEC_ValueQuestion('MA', 'State'),

            new EEC_SimpleQuestion('Unlicensed_Provider_Zip_Code', 'Zip Code')
                    .maxLength(10),

            new EEC_SimpleQuestion('Unlicensed_Provider_Phone', 'Phone Number')
                    .maxLength(40)
                    .isRequired(false),

            new EEC_EmailQuestion('Unlicensed_Provider_Email', 'Email address')
                    .maxLength(80)
                    .isRequired(false)
    };

    public static List<EEC_Question> providerSearchQuestions = new List<EEC_Question> {
            new EEC_SimpleQuestion('providerName', 'Provider Name')
                    .isRequired(false),

            new EEC_PicklistQuestion('providerType', 'Provider Type')
                    .setOptions(getRecordTypes(Account.SObjectType, new Set<String>{ 'Umbrella', 'Unlicensed Provider'}))
                    .isRequired(false),

            new EEC_SimpleQuestion('firstName', 'Contact First Name')
                    .isRequired(false),

            new EEC_SimpleQuestion('lastName', 'Contact Last Name')
                    .isRequired(false),

            new EEC_SimpleQuestion('address', 'Street Address')
                    .isRequired(false),

            new EEC_PicklistQuestion('city', 'City')
                    .setOptions(getCities())
                    .isRequired(false)
    };


    /**
    * Provider Licesnsing Background
    */
    private static List<EEC_Question> backgroundFCCAssistantQuestions = new List<EEC_Question> {

            new EEC_LicensingElaborationQuestion('Within the past three (3) years has any child care child in your care suffered serious illness or injury, been hospitalized, or needed emergency medical treatment as a result of something that happened while in family child care?',
                    'Child_Emergency_Injury_Last_3_Years__c',
                    'Please explain',
                    'Child_Emerg_Injury_Last_3_Years_Descrip__c',
                    new List<String>{ 'FCC_Assistant_New_License' }),

            new EEC_LicensingElaborationQuestion('Have you ever been found to have abused or neglected a child in any state?',
                    'Abused_or_neglected_a_child__c',
                    'Please explain',
                    'Abused_or_neglected_a_child_Description__c'),

            new EEC_LicensingElaborationQuestion('Have you ever been arrested or charged with any crime in any state?',
                    'Charged_or_Arrested_for_Crime__c',
                    'Please list the date, the state, and the nature of those charges.',
                    'Charges_Description__c'),

            new EEC_LicensingElaborationQuestion('Have you ever had any dealings with any child protection or child welfare agency in any state?',
                    'Dealings_with_Child_Prot_Child_Welfar__c',
                    'Please describe the nature of those dealings, whether there were any findings that you abused or neglected a child, and when these dealings occurred',
                    'Dealing_with_Child_Prot_Welfar_Descri__c'),

            new EEC_LicensingElaborationQuestion('Have you ever been classified or ordered to register as a Sex Offender (any level) in any state?',
                    'Registering_as_Sex_Offender__c',
                    'Please describe the nature of the incident(s) that required that the classification or registration occur and date that the classification or registration occurred.',
                    'Sex_Offender_Nature_of_Incident__c'),

            new EEC_LicensingElaborationQuestion('Have you ever had a restraining order issued against you or requested a restraining order for protection?',
                    'Restraining_Order_Issued__c',
                    'Please explain',
                    'Restraining_Order_Description__c'),

            new EEC_LicensingElaborationQuestion('Do you use alcoholic beverages, narcotics or other drugs to an extent or in a manner that impairs your ability to care for children properly?',
                    'Use_of_Alcoholic_Bev_Narcotics_Drugs__c',
                    'Please explain',
                    'Alcoholic_Bev_Narcotics_Drugs_Desc__c')
    };

    private static List<EEC_Question> backgroundFCCProviderQuestions = new List<EEC_Question> {

            new EEC_LicensingElaborationQuestion('Within the past three (3) years has any child care child in your care suffered serious illness or injury, been hospitalized, or needed emergency medical treatment as a result of something that happened while in family child care?',
                    'Child_Emergency_Injury_Last_3_Years__c',
                    'Please explain',
                    'Child_Emerg_Injury_Last_3_Years_Descrip__c',
                    new List<String>{ 'FCC_New_License' }),

            new EEC_LicensingElaborationQuestion('Have you or any member of your household or any person regularly on the premises ever been arrested or charged with any crime in any state?',
                    'Charged_or_Arrested_for_Crime__c',
                    'Please list the date(s), the state(s), and the nature of the charges.',
                    'Charges_Description__c'),

            new EEC_LicensingElaborationQuestion('Have you, a household member, or any person regularly on the premises ever had any dealings with any child protection or child welfare agency (such as the Department of Children and Families previously Department of Social Services)?',
                    'Dealings_with_Child_Prot_Child_Welfar__c',
                    'Please describe the nature of those dealings, whether there were any findings that you abused or neglected a child, and when these dealings occurred',
                    'Dealing_with_Child_Prot_Welfar_Descri__c'),

            new EEC_LicensingElaborationQuestion('Have you or any member of your household or any person regularly on the premises ever been classified or ordered to register as a Sex Offender (any level) in any state?',
                    'Registering_as_Sex_Offender__c',
                    'Please describe the nature of the incident(s) that required that the classification or registration occur and date that the classification or registration occurred.',
                    'Sex_Offender_Nature_of_Incident__c'),

            new EEC_LicensingElaborationQuestion('Have you or any other person living in or regularly on the premises of the family child care home, ever had a restraining order issued against you/them or requested a restraining order for protection?',
                    'Restraining_Order_Issued__c',
                    'Please explain.',
                    'Restraining_Order_Description__c'),

            new EEC_LicensingElaborationQuestion('Do you use alcoholic beverages, narcotics or other drugs in a manner or to an extent that might impact your ability to care for children?',
                    'Use_of_Alcoholic_Bev_Narcotics_Drugs__c',
                    'Please explain.',
                    'Alcoholic_Bev_Narcotics_Drugs_Desc__c'),

            new EEC_LicensingElaborationQuestion('Have you or any member of your household, or any person regularly on the premises ever been found to have abused or neglected a child in any state?',
                    'Abused_or_neglected_a_child__c',
                    'Please describe the date, state and nature of those findings:',
                    'Abused_or_neglected_a_child_Description__c')

    };


    private static List<EEC_Question> backgroundInformalChildCareQuestions = new List<EEC_Question> {

            new EEC_LicensingElaborationQuestion('Within the past three (3) years has any child care child in your care suffered serious illness or injury, been hospitalized, or needed emergency medical treatment as a result of something that happened while in family child care?',
                    'Child_Emergency_Injury_Last_3_Years__c',
                    'Please explain',
                    'Child_Emerg_Injury_Last_3_Years_Descrip__c',
                    new List<String>{ 'FCC_New_License' }),

            new EEC_LicensingElaborationQuestion('Have you ever been arrested or charged with any crime in any state?',
                    'Charged_or_Arrested_for_Crime__c',
                    'Please list the date(s), the state(s), and the nature of the charges.',
                    'Charges_Description__c'),

            new EEC_LicensingElaborationQuestion('Have you ever had any dealings with any child protection or child welfare agency (such as the Department of Children and Families previously Department of Social Services)?',
                    'Dealings_with_Child_Prot_Child_Welfar__c',
                    'Please describe the nature of those dealings, whether there were any findings that you abused or neglected a child, and when these dealings occurred',
                    'Dealing_with_Child_Prot_Welfar_Descri__c'),

            new EEC_LicensingElaborationQuestion('Have you ever been classified or ordered to register as a Sex Offender (any level) in any state?',
                    'Registering_as_Sex_Offender__c',
                    'Please describe the nature of the incident(s) that required that the classification or registration occur and date that the classification or registration occurred.',
                    'Sex_Offender_Nature_of_Incident__c'),

            new EEC_LicensingElaborationQuestion('Have you ever had a restraining order issued against you or requested a restraining order for protection?',
                    'Restraining_Order_Issued__c',
                    'Please explain.',
                    'Restraining_Order_Description__c'),

            new EEC_LicensingElaborationQuestion('Do you use alcoholic beverages, narcotics or other drugs in a manner or to an extent that might impact your ability to care for children?',
                    'Use_of_Alcoholic_Bev_Narcotics_Drugs__c',
                    'Please explain.',
                    'Alcoholic_Bev_Narcotics_Drugs_Desc__c'),

            new EEC_LicensingElaborationQuestion('Have you ever been found to have abused or neglected a child in any state?',
                    'Abused_or_neglected_a_child__c',
                    'Please describe the date, state and nature of those findings:',
                    'Abused_or_neglected_a_child_Description__c')

    };


    public static Map<Section, Map<String, List<EEC_Question>>> sectionProviderQuestions = new Map<Section, Map<String, List<EEC_Question>>> {
            Section.BackgroundInformation => new Map<String, List<EEC_Question>> {
                    'Family Child Care' => backgroundFCCProviderQuestions,
                    'FCC Assistant' => backgroundFCCAssistantQuestions,
                    'Informal Child Care' => backgroundInformalChildCareQuestions
            }
    };
}