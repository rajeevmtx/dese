/*
* 	Class Name: ProgramContent_Helper
* 	Description: Helper class dealing with Program_Content__c records
*
* 	Author/Date: George Acker/ 05/21/2016
*  
*                                                             
*/
public with sharing class ProgramContent_Helper {

    public static String MILESTONE_RECORDTYPE = 'Project_Milestones';
    public static String DELIVERABLE_RECORDTYPE = 'Project_Deliverables';
    public static String YEARLY_REPORT_DELIVERABLE_TYPE = 'Yearly Report Deliverable';
    public static String YEARLY_PERFORMANCE_PAYMENT_TYPE = 'Yearly Performance Payment';
    public static String NYSERDA_SYSTEM_INSTALLATION_SUBTYPE = 'NYSERDA System Installation';
    public static String SYSTEM_INSTALLATION_INCENTIVE_SUBTYPE = 'System Installation Incentive';
    public static String ACTIONITEM_RECORDTYPE = 'Action_Item';
    public static String DOCUMENT_RECORDTYPE = 'Document';
    public static String PROPOSAL_RECORDTYPE = 'Proposal';
    public static final String SUB_TYPE_REQUEST_EXTENSION_DOCUMENT = 'Request Extension Document';
    public static final String SUB_TYPE_CESIR_REQUEST_EXTENSION_DOCUMENT = 'CESIR Extension Request Document';
    public static final String DUE_DILIGENCE_RECORD_TYPE_DEVELOPER_NAME = 'Due_Diligence';

    public static final String TYPE_SCORING_RUBRIC = 'Scoring Rubric';

    public static final Set<String> SET_OF_EXTENSION_SUB_TYPES = new Set<String>{SUB_TYPE_REQUEST_EXTENSION_DOCUMENT,SUB_TYPE_CESIR_REQUEST_EXTENSION_DOCUMENT};


    public static RecordType MilestoneRecordType
    {
        get
        {
            if (MilestoneRecordType == null)
                MilestoneRecordType = Utility_RecordType_Helper.getRecordType('Program_Content__c',MILESTONE_RECORDTYPE);
            return MilestoneRecordType;
        }
        set;
    }

    public static RecordType DeliverableRecordType
    {
        get
        {
            if (DeliverableRecordType == null)
                DeliverableRecordType = Utility_RecordType_Helper.getRecordType('Program_Content__c',DELIVERABLE_RECORDTYPE);
            return DeliverableRecordType;
        }
        set;
    }

    public static RecordType ActionItemRecordType
    {
        get
        {
            if (ActionItemRecordType == null)
                ActionItemRecordType = Utility_RecordType_Helper.getRecordType('Program_Content__c',ACTIONITEM_RECORDTYPE);
            return ActionItemRecordType;
        }
        set;
    }

    public static RecordType DocumentRecordType
    {
        get
        {
            if (DocumentRecordType == null)
                DocumentRecordType = Utility_RecordType_Helper.getRecordType('Program_Content__c',DOCUMENT_RECORDTYPE);
            return DocumentRecordType;
        }
        set;
    }
    
   
}