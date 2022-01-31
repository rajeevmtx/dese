/*
* Class Name: CORE_Helper
* Description: Helper class for core functionality
* Author/Date:  
*
*
*/
global without sharing class CORE_Helper {

    public static final String COST_NAME_INTEGRATION_USER = 'Integration User';

    public static final Set<String> PROGRAM_PARTNERSHIP_RESCTRICTED_STATUS_SET = new Set<String> {'Suspended', 'Terminated'};

    public static final String TYPE_CON_APP = 'Contractor Application';

    public static final String SUB_TYPE_CON_APP = 'Signed Application';

    public static final String DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Document';

    public static final String DOCUMENTS_PROJECT_RECORD_TYPE_NAME = 'Documents';

    public static final String PAYEE_TEMPLATE_TYPE = 'Payee Application';

    public static final String DOCUMENT_STATUS_SUBMITTED = 'Submitted';

    public static final String TYPE_PROJECT_APP = 'Project Application';

    public static final String RPU_OPEN_STATUS = 'Open';   //RPU Status

    public static final String SOLICITATION_ROUND_OPEN_STATUS = 'Open';   //Solicitation Round Status

    private static CORE_Constants_Setting__c objConstantsSetting = CORE_Constants_Setting__c.getInstance();
    public static Integer NEIS_TRANSACTION_OBJ_DELETE_NUMBEROFDAYS_OLD = 0;
    public static Integer CONST_ATTACHMENT_DOCUMENT_OBJ_DELETE_NUMBEROFDAYS_OLD = 0;
    static {
      NEIS_TRANSACTION_OBJ_DELETE_NUMBEROFDAYS_OLD = Integer.valueOf((objConstantsSetting != null && objConstantsSetting.NEIS_Transaction_Obj_Delete_OfDays_Old__c != null)? objConstantsSetting.NEIS_Transaction_Obj_Delete_OfDays_Old__c : 0);
      CONST_ATTACHMENT_DOCUMENT_OBJ_DELETE_NUMBEROFDAYS_OLD = Integer.valueOf((objConstantsSetting != null && objConstantsSetting.Doc_of_Attachment_Util_Del_OfDays_Old__c != null)? objConstantsSetting.Doc_of_Attachment_Util_Del_OfDays_Old__c : 0);
    }

    public static final Id CORE_NYSERDA_ORG_WIDE_EMAIL_ADD_RECORD_ID = CORE_Constants_Setting__c.getOrgDefaults().CORE_NYSERDA_OrgWideEmailAdd_Record_ID__c;

    /*
    * Method Name: setOrgWideEmailAddress_CORE 
    * Description: List version of Org Wide email setter 
    * @param: newEmailList as List<Messaging.SingleEmailMessage>
    * @return: List<Messaging.SingleEmailMessage>
    */
    public static List<Messaging.SingleEmailMessage> setOrgWideEmailAddress_CORE(List<Messaging.SingleEmailMessage> newEmailList) {
      if(newEmailList != null && newEmailList.size() > 0 &&
          CORE_NYSERDA_ORG_WIDE_EMAIL_ADD_RECORD_ID != null && isValidSalesforceId(CORE_NYSERDA_ORG_WIDE_EMAIL_ADD_RECORD_ID)) {
        for(Messaging.SingleEmailMessage newEmail : newEmailList) {
          newEmail = setOrgWideEmailAddress_CORE(newEmail);
        }
      }
      return newEmailList;
    }

    /*
    * Method Name: setOrgWideEmailAddress_CORE
    * Description: Object version of Org Wide email setter
    * @param: newEmail as Messaging.SingleEmailMessage
    * @return: Messaging.SingleEmailMessage
    */
    public static Messaging.SingleEmailMessage setOrgWideEmailAddress_CORE(Messaging.SingleEmailMessage newEmail) {
      if(CORE_NYSERDA_ORG_WIDE_EMAIL_ADD_RECORD_ID != null && newEmail != null && isValidSalesforceId(CORE_NYSERDA_ORG_WIDE_EMAIL_ADD_RECORD_ID)) {
        newEmail.setOrgWideEmailAddressId(CORE_NYSERDA_ORG_WIDE_EMAIL_ADD_RECORD_ID);
      }
      return newEmail;
    }


    /*
    * Method Name: fetchFieldsFromFieldSet
    * Description: Preparing Dynamic list of field
    * @param: objectApiName as String
    * @param: fieldSetName as String
    * @return: List<String>
    */
    public static List<String> fetchFieldsFromFieldSet(String objectApiName, String fieldSetName) {
        List<Schema.FieldSetMember> lstFieldSetMembers = new List<Schema.FieldSetMember>();
        List<String> fieldNames_list = new List<String>();
        try {
            if(String.isNotBlank(objectApiName) && String.isNotBlank(fieldSetName)){
              lstFieldSetMembers = Schema.getGlobalDescribe().get(objectApiName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
              for(Schema.FieldSetMember fieldSetMember : lstFieldSetMembers) {
                  fieldNames_list.add(fieldSetMember.getFieldPath());
              }
            }
        } catch(Exception ex) {
          //fieldNames_list  = new List<String>{'Name','Id'};
          System.debug('>>> Exception: ' + ex);
        }
        return fieldNames_list;
      }

    /*
    * Method Name: doEscapeSingleQuotes
    * Description: Utility method to escape single quote
    * @param: strIN as String
    * @return: String
    */
    public static String doEscapeSingleQuotes(String strIN) {
       String strOUT = null;
       if(String.isNotBlank(strIN) && strIN != 'null') {
         strOUT = String.escapeSingleQuotes(strIN);
       }
       return strOUT;
     }

    /*
    * Method Name: isValidSalesforceId
    * Description: Utility method to validate Salesforce ID
    * @param: idINPUT
    * @return: Boolean
    */
    public static Boolean isValidSalesforceId(String idINPUT) {
       Boolean result = false;
       if(String.isNotBlank(idINPUT) && idINPUT != 'null') {
         // First, instantiate a new Pattern object "MyPattern"
         Pattern MyPattern = Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}');
         // Then instantiate a new Matcher object "MyMatcher"
         Matcher MyMatcher = MyPattern.matcher(idINPUT);
         // Verify the match
         result = MyMatcher.matches();
       }
       return result;
     }

    // rahuls91221: T-01059
    /*
    * Method Name: createContact
    * Description: Create dummy Contact record for sending email message as we need to set Contact Id - this would be rolled back!!
    * @param
    * @return: Contact
    */
    public static Contact createContact() {
        Integer randomInteger = Integer.valueOf(Math.random()*100000);
        Contact dummyContact = createContactTest(
            'dummy' + randomInteger,
            'dummy' + randomInteger,
            null,
            'test' + randomInteger + '@test.com');
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.SaveResult sr = Database.insert(dummyContact, dml);
        return dummyContact;
     }

  /*
    * Method Name: getCoreProjectRecordType
    * Description: Method to return the project repord type
    * @param: programId as String
    * @return: Id
    */
    public static Id getCoreProjectRecordType(String programId){
        String recordTypeName;

        for(Program__c program : [SELECT Application_Type__c FROM Program__c WHERE Id =: programId]){
            recordTypeName = program.Application_Type__c;
        }

        RecordType coreProjectRecordType = Utility_RecordType_Helper.getRecordType('Project__c', recordTypeName);
        return coreProjectRecordType.Id;
     }
     
     /*
    * Name: createContactTest
    * Desc: Create the record of Contact object
    * @param: firstName - String - Contact First Name
    * @return: Contact - Record of Contact Object
    */
    public static Contact createContactTest(String firstName, String lastName, Id accId,string Email) {
        Contact testContact = new Contact();
        testContact.firstName = firstName;
        testContact.lastName = lastName;
        testContact.AccountId = accId;
        testContact.Email = Email;
        testContact.Address_Validation_Status__c = 'Not Validated';
        testContact.MailingCity = 'Test City'; 
        testContact.MailingStreet = 'Test Street';
        testContact.MailingState = 'Test State';
        testContact.MailingPostalCode = '123456';
        return testContact;
    }
}