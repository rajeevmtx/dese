/*
*   Class Name: Clean_Transportation_Helper
*   Description: Helper class for Clean Transporation
*
*/
public with sharing class Clean_Transportation_Helper {

    public static final Set<String> SET_PurchaseOrder_PO_STATUS_FOR_INVOICE = new Set<String>{ProjectPurchaseOrder_Helper.PO_STATUS_DISPATCHED,
                                                                                              ProjectPurchaseOrder_Helper.PO_STATUS_APPROVED};

    //public static final String COMMERCIAL_CT_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Clean_Transportation';
    public static final String COMMERCIAL_BS_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Innovation_Business_Support';
    public static final String COMMERCIAL_CA_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Innovation_Capacity_Assets';
    public static final String COMMERCIAL_DE_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Innovation_Demonstration';
    public static final String COMMERCIAL_DP_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Innovation_Deployment';
    public static final String COMMERCIAL_ID_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Innovation_Information_Dissemination';
    public static final String COMMERCIAL_PD_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Innovation_Product_Development';
    public static final String COMMERCIAL_RS_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Innovation_Research_Study';
    public static final String SOLICITATION_SUBMISSION_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Solicitation_Submission';

    public static Set<Id> INNOVATION_PROJECT_RECORD_TYPE_ID_SET = new Set<Id>
    {

    											    Utility_RecordType_Helper.getRecordType('Project__c', SOLICITATION_SUBMISSION_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id
                                                /*    Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_BS_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id,
                                                    Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_CA_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id,
                                                    Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_DE_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id,
                                                    Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_DP_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id,
                                                    Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_ID_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id,
                                                    Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_PD_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id,
                                                    Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_RS_PROJECT_RECORD_TYPE_DEVELOPER_NAME).Id */
                                                };

    public static final string CONST_INVOICE_APPROVED = 'Approved';
    public static final string CONST_BUDGET_DETAIL_APPROVED = 'Approved';
    public static final string CONST_BUDGET_DETAIL_PENDING_APPROVAL = 'Pending Approval';
    public static final string CONST_BUDGET_DETAIL_DRAFT = 'Draft';
    public static final String PROJECT_CONTRACTOR_ROLE = 'Contractor';
    public static final String PROJECT_ROLE_CUSTOMER = 'Customer';
    public static final String PROJECT_STATUS_AWARDED = 'Awarded';
    public static final set<String> validRecordtypes = new set<String>{
                                                                        COMMERCIAL_BS_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                                        COMMERCIAL_CA_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                                        COMMERCIAL_DE_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                                        COMMERCIAL_DP_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                                        COMMERCIAL_ID_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                                        COMMERCIAL_PD_PROJECT_RECORD_TYPE_DEVELOPER_NAME,
                                                                        COMMERCIAL_RS_PROJECT_RECORD_TYPE_DEVELOPER_NAME};
    /*public static RecordType ctRecordType
    {
        get
        {
            if (ctRecordType == null)
                ctRecordType = Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_CT_PROJECT_RECORD_TYPE_DEVELOPER_NAME);
            return ctRecordType;
        }
        set;
    }*/

    public static RecordType getRecordType(String rname){
        return Utility_RecordType_Helper.getRecordType('Project__c', rname);
    }



    public static boolean ctRecordtypeexist(String rid){
      return (INNOVATION_PROJECT_RECORD_TYPE_ID_SET.contains(rid)); // Avoid SOQL
      /*
        Integer count = [select count()
                         from recordtype
                         where sObjectType = 'Project__c'
                         and developername in : validRecordtypes
                        and id =: rid];
        if(count ==1)
            return true;
        else
            return false;
      */
    }


}