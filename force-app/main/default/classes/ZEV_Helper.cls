//
// Helper class for Zero Emission Vehicles
//
// June 10, 2016     George Acker     original

public class ZEV_Helper
{
    public static final String ZEV_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Zero_Emission_Vehicles';
    public static final String ZEV_VEHICLE_STATUS = 'Approved';
    public static final String PROJECT_CONTRACTOR_ROLE = 'Contractor';
    public static final String DOCUMENTS_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Documents';
    public static final String SUB_TYPE_CON_APP = 'Signed Application';
    public static final String TYPE_PROJECT_APP = 'Project Application';
    public static final String PROJECT_ROLE_CUSTOMER = 'Customer';
    public static final String PROGRAM_Zero_Emission_Vehicles = 'Zero_Emission_Vehicles';
    public static final string CONST_PROJ_VEHICLE_Unsubmitted = 'Unsubmitted';
    public static final String CONST_ACTIVE = 'Active';
    public static final string CONST_PROJ_VEHICLE_Submitted = 'Submitted';
    public static final set<String> SET_CONST_PROJECT_VEHICLE_STATUS = new Set<String>{'Approved','Submitted','Pending Approval','Unsubmitted'};

    public static final Set<String> SET_OF_ZEV_APPLICATION_TYPE_FOR_PROG_RELATIONSHIPS = new Set<String>{PROGRAM_Zero_Emission_Vehicles};
    public static final String ZEV_CONTRACTOR_PERMISSION_SET_API_NAME = 'Innovation_ZEV_Contractor_Permissions';

    public static final Set<String> SET_OF_COI_VALIDATION_PROJ_STATUSES = new Set<String>{Project_Helper.PROJECT_STATUS_PENDINGAPPROVAL, Project_Helper.PROJECT_STATUS_APPROVED};

    public static RecordType ZeroEmissionVehiclesProjectRecordType
    {
        get
        {
            if (ZeroEmissionVehiclesProjectRecordType == null)
                ZeroEmissionVehiclesProjectRecordType = Utility_RecordType_Helper.getRecordType('Project__c',ZEV_PROJECT_RECORD_TYPE_DEVELOPER_NAME);
            return ZeroEmissionVehiclesProjectRecordType;
        }
        set;
    }
}