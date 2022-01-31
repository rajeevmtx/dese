/*
* Class Name: ProjectInvoice_Helper
* Description: helper class for project invoice
* Author/Date:  George Acker ,  5/25/2016
*/

public with sharing class ProjectInvoice_Helper {


    public static final String CONST_COMPANY_NAME_TAG_EMAIL_TEMPLATE_SUBJECT = '<Company_Name>';
    public static final String CONST_SALESFORCE_INVOICE_NUMBER_TAG_EMAIL_TEMPLATE_BODY = '<salesforce_invoice_number>';

    public static String STATUS_PENDING_REVIEW = 'Pending Program Review';
    public static String STATUS_DRAFT = 'Draft';
    public static String STATUS_APPROVED = 'Approved';
    public static String STATUS_REJECTED = 'Rejected';
    public static String STATUS_PAID = 'Paid';
    public static String STATUS_COMPLETED = 'Completed';
    public static String STATUS_SUBMITTED = 'Submitted';
    public static String STATUS_SENT_TO_FINANCE = 'Sent to Finance';
	  public static String STATUS_PARTIALLY_PAID =  'Partially Paid';
    public static Decimal CAPACITY_FACTOR = 0.134;
    public static Decimal HOURS_PER_YEAR = 8760;

    public static final Set<String> SET_OF_REJECTED_INVOICE = new SET<String> {'Rejected', 'Cancelled'};

    public static final	Map<String, String> percentageMap = new Map<String, String>{'25%'=> 'twenty-five', '75%'=> 'seventy-five', '100%' => 'hundred' };

    public static final Set<String> SET_OF_REJECTED_OR_CANCEL_STATUSES = getPicklistStatusGrouping ('Project_Invoice__c', 'Status__c', 'RejectOrCancel');

    public static final Set<String> SET_OF_APPROVED_AND_AFTER_STATUSES = getPicklistStatusGrouping ('Project_Invoice__c', 'Status__c', 'Approved');

    public static final Set<String> SET_OF_SUBMITTED_AND_AFTER_STATUSES = getSubmittedStatus();

   // public static final Set<Id> SET_OF_PROJECT_RCD_TYPE_ID_FOR_PENDINGREVIEW_MILESTONE_INVOICES = new Set<Id>{Project_Helper.gshpSmallRecordTypeId}; // Case: 00009596

	/*
    * Method Name: getSubmittedStatus
    * Description:  get Submitted Status
    * @return: Set<String>
    */
    private static Set<String> getSubmittedStatus() {
    	Set<String> statusSet = new Set<String>();
    	List<CORE_Object_Picklist_Grouping__mdt> submittedPicklistGroupList = [select Object_API_Name__c, Picklist_Value__c from CORE_Object_Picklist_Grouping__mdt
    																			where Object_API_Name__c = 'Project_Invoice__c'
    																				AND Picklist_Field_API_Name__c = 'Status__c'
    																				AND Picklist_Grouping_Name__c = 'Submitted'];
    	for(CORE_Object_Picklist_Grouping__mdt submittedPicklistGroupRec : submittedPicklistGroupList) {
    		statusSet.add(submittedPicklistGroupRec.Picklist_Value__c);
    	}
    	statusSet.remove(null);
    	return statusSet;
    }

   /*
    * Method Name: getSubmittedStatus
    * Description:  get Submitted Status
    * @return: Set<String>
    * @param:  String objectApiName
    * @param:  String fieldApiName
    * @param:  String groupName
    */
    public static Set<String> getPicklistStatusGrouping(String objectApiName, String fieldApiName, String groupName) {
        Set<String> statusSet = new Set<String>();
        for(CORE_Object_Picklist_Grouping__mdt submittedPicklistGroupRec : [select Object_API_Name__c, Picklist_Value__c from CORE_Object_Picklist_Grouping__mdt
                                                                            where Object_API_Name__c =: objectApiName
                                                                            	AND Picklist_Field_API_Name__c =: fieldApiName
                                                                            	AND Picklist_Grouping_Name__c =: groupName]) {

         	if(submittedPicklistGroupRec.Picklist_Value__c !=null)
            	statusSet.add(submittedPicklistGroupRec.Picklist_Value__c);
        }
    	return statusSet;
    }
    private static final String GREATER_THAN = '&gt;';
    private static final String LESS_THAN = '&lt;';
    private static final String SLASH = '/';
    /*
    * Method Name: getTextBetweenTags
    * Description:  get Text Between Tags
    * @return: String
    * @param:  String orginalString
    * @param:  String tagName
    */
    public static String getTextBetweenTags(String orginalString, String tagName){
        String startTag = LESS_THAN+tagName+GREATER_THAN;
        String endTag =  LESS_THAN+SLASH+tagName+GREATER_THAN;
        String tagString = '';
        if(orginalString!=null){
            tagString = orginalString.subStringBetween(startTag,endTag);
        }
        return tagString;
    }

}