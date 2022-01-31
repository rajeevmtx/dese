/*
* Class Name: CORE_Deliverables_Helper
* Description: Helper class for Zero Emission Vehicles
* Author/Date:  Gaurav Sinha   06/10/2016
*
* Date         New/Modified      Author             Description
* 05/21/2017   Modified          Ghanshyam          Commenting
*
*/
public class CORE_Deliverables_Helper
{
    public static final String PARENT_MILESTONE_RECORD_TYPE_DEVELOPER_NAME = 'Project_Milestones';
    public static final String CHILD_MILESTONE_RECORD_TYPE_DEVELOPER_NAME = 'Child_Project_Milestone';
    public static final String USER_TYPE_STANDARD = 'Standard';
    public static final String PROJECT_PM = 'Project Manager';
    public static final String PROJECT_Contractor = 'Contractor';
    public static final String PROJECT_Closed = 'Closed';
    public static final String Budget_DRAFT = 'Draft';
    public static final String PROJECT_APPROVED = 'Approved';
    public static final String PROJECT_AWARDED = 'Awarded';
    Public static final string CONST_STATUS_Pending_Approval = 'Pending Approval';
    public static final String PROJECT_Unsubmitted = 'Unsubmitted';
    public static final String CONST_BUDGET_STATUS_CANCELLED = 'Cancelled';
    public static final String CONST_TM = 'T&M';
    public static final String CONST_MILESTONE = 'Milestone';
    public static final String CONST_APPROVEDACTIVE = 'Approved & Active';
    public static final String CONST_REJECTED = 'Rejected';
    public static final String STATUS_SCHEDULED = 'Scheduled';
    public static final String STATUS_Installed = 'Installed/Operational';
    public static final string CONST_SUBMITTED = 'Submitted';
    public static final string PROJECT_MANAGEMENT_MILESTONE = 'Project Management';

    public static RecordType ParentMilestone
    {
        get
        {
            if (ParentMilestone == null)
                ParentMilestone = Utility_RecordType_Helper.getRecordType('Project_Milestones__c',PARENT_MILESTONE_RECORD_TYPE_DEVELOPER_NAME);
            return ParentMilestone;
        }
        set;
    }

    public static RecordType ChildMilestone
    {
        get
        {
            if (ChildMilestone == null)
                ChildMilestone = Utility_RecordType_Helper.getRecordType('Project_Milestones__c',CHILD_MILESTONE_RECORD_TYPE_DEVELOPER_NAME);
            return ChildMilestone;
        }
        set;
    }


}