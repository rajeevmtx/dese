/*
* Class Name:  Core_Programs_Page_Controller
* Description: Controller class for Core_Programs_Page 
* Author/Date: Das Nobel ,  2/2/2016
*                                                            
*/

public with sharing class Core_Programs_Page_Controller {
    
    public final String ERROR_MESSAGE = 'There are no programs available for your Account.';
    public final String NY_SUN_RESIDENTIAL_TYPE = 'NY_Sun_Residential';
    public final String NY_SUN_COMMERCIAL_TYPE = 'NY_Sun_Commercial';
    public final String RTEM_TYPE = 'Commercial_Real_Time_Energy_Management';
    public final String PELLET_STOVE_TYPE = 'RHNY_Pellet_Stove';
    public final String ZEV_TYPE = 'Zero_Emission_Vehicles';
    public final String CHP_TYPE = 'Onsite_Power_Combined_Heat_and_Power';
    public final String GSHP_SMALL_TYPE = 'GSHP_Small_System';
    public final String GSHP_LARGE_TYPE = 'GSHP_Large_System';
    public final String CTenant_TYPE = 'Commercial_Tenant';
    public final String NEW_CONSTRUCTION_TYPE = 'New_Construction';
    
    public static final String STATUS_PROVISIONAL = 'Provisional';
    public static final String STATUS_SUSPENDED = 'Suspended';
   public static final String STATUS_TERMINATED = 'Terminated';
  
   public static final Set<String> SET_OF_SUSPENDED_STATUSES = new Set<String>{STATUS_SUSPENDED, STATUS_TERMINATED};
  
    public Map<Id, Program__c> programMap {get; set;}
    public String programId {get; set;}
    public boolean isProgramExist{get; set;}
    public Boolean hasError{get; set;}
    public String errorMessage{get; set;}
    public String accountId, contactId; 
    public User currentUser = Utility_User_Helper.currentLoggedInUser;
    
    public static final Set<String> NY_SUN_RESIDENTIAL_SUBMITTED_STATUSES = new Set<String>{ Project_Helper.PROJECT_STATUS_SUBMITTED,
                                                                                             Project_Helper.PROJECT_STATUS_PENDINGAPPROVAL,
                                                                                             Project_Helper.PROJECT_STATUS_RECEIVED};
                                                                                             
    public Core_Programs_Page_Controller() {
        programMap = new Map<Id, Program__c>();
        isProgramExist = false;
        hasError = false;
        
        for(User user : [SELECT Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()]){
            accountId = (user.ContactId != null) ? user.Contact.AccountId : null;
            contactId = (user.ContactId != null) ? user.ContactId : null;
        }
    }
    
    /*
  * Method Name: checkForPrograms
  * Description: check For Programs
  * @return:  Pagereference
  */
    public Pagereference checkForPrograms() {
        Set<Id> programIdSet = new Set<Id>();
        for(Program_Partnership__c programPartner : [SELECT Program__c FROM Program_Partnership__c WHERE Account__c =: accountId]){
            programIdSet.add(programPartner.Program__c);
        }
        
        if(programIdSet.size() > 0) {
            programMap = new Map<Id, Program__c>([select Name, Description__c, Program_Family__c, Status__c, Statement__c,Application_Type__c,
                                                        (select Id from Program_Versions__r where Status__c = 'Open' Order by CreatedDate DESC) 
                                                        from Program__c 
                                                        Where Id IN : programIdSet
                                                        AND Status__c = 'Active' Order by CreatedDate ]);
                                                 
            if(programMap.size() == 0) {
                hasError = true;
                errorMessage = ERROR_MESSAGE;
            }                                            
        } else {
            hasError = true;
            errorMessage = ERROR_MESSAGE;
        }
        
        return null;
    }
    /*
  * Method Name: setProject
  * Description: set Project
  * @return:  Pagereference
  */
    public PageReference setProject() {
        Pagereference nextPageURL = null;
        if(underAppSubmitLimitIfApplicable() && validateSuspendedCategoryContractors()) {
            String projectId = insertProject();
            nextPageURL = PageNavigationUtility.getNextPageURL(projectId, 'Programs_Page', null);
        }
        return nextPageURL;
    }
    
    /*
  * Method Name: underAppSubmitLimitIfApplicable
  * Description: NY Sun - Residential: Provisional Contractor should be limited to 15 new applications at a time (in submitted, received, or pending approval status)
  * @return:  Boolean
  */
   
    private Boolean underAppSubmitLimitIfApplicable() {
      Boolean bResult = true;
      Program_Partnership__c objProgPartnership = null;
      if(String.isNotBlank(programId)) {
        Program__c objProgram = programMap.get(programId);
        if(objProgram != null) {
          if(NY_SUN_RESIDENTIAL_TYPE.equalsIgnoreCase(objProgram.Application_Type__c)) {
              for(Program_Partnership__c objProgPart : [SELECT  Id, Status__c
                                                        FROM    Program_Partnership__c 
                                                        WHERE   Program__c =:programId 
                                                        AND     Account__c = :accountId 
                                                        AND     Default_Primary_Contact__c = :ContactId]) {
                objProgPartnership = objProgPart;
              }
              
              if(objProgPartnership != null && STATUS_PROVISIONAL.equalsIgnoreCase(objProgPartnership.Status__c)) {
                Decimal provisionalProjectSubmitLimit = CORE_Constants_Setting__c.getOrgDefaults().NY_Sun_Residential_Prov_Proj_SubmitLimit__c;
                Integer limitVal = Integer.valueOf(provisionalProjectSubmitLimit);
                List<Project__c> lstProjects = [SELECT  Id 
                                                FROM    Project__c 
                                                WHERE   Status__c IN : NY_SUN_RESIDENTIAL_SUBMITTED_STATUSES 
                                                AND     Contractor__c = :objProgPartnership.Id
                                                AND     Program__c = :programId
                                                AND     Program_Version__c = :objProgram.Program_Versions__r[0].Id LIMIT :limitVal ];
                                                 
                if(lstProjects.size() >= limitVal) {
                  hasError = true;
                   //errorMessage = Label.NY_Sun_Residential_Provisional_Contractor_Application_Submission_Limit_Error_Msg;
                  bResult = false;       
                }                             
              }          
          }         
        }
      }
      return bResult;
    }

  /*
  * Method Name: validateSuspendedCategoryContractors
  * Description: NY Sun Residential and Commercial: Should not be able to submit applications if status of contractor is suspended.
  * @return:  Boolean
  */
     private Boolean validateSuspendedCategoryContractors() {
      Boolean bResult = true;
      Program_Partnership__c objProgPartnership = null;
      if(String.isNotBlank(programId)) {
        Program__c objProgram = programMap.get(programId);
        if(objProgram != null) {
          if(NY_SUN_RESIDENTIAL_TYPE.equalsIgnoreCase(objProgram.Application_Type__c) || NY_SUN_COMMERCIAL_TYPE.equalsIgnoreCase(objProgram.Application_Type__c)) {
              for(Program_Partnership__c objProgPart : [SELECT  Id, Status__c
                                                        FROM    Program_Partnership__c 
                                                        WHERE   Program__c =:programId 
                                                        AND     Account__c = :accountId 
                                                        AND     Default_Primary_Contact__c = :ContactId]) {
                objProgPartnership = objProgPart;
              }             
              if(objProgPartnership != null && SET_OF_SUSPENDED_STATUSES.contains(objProgPartnership.Status__c)) {
                  hasError = true;
                  //errorMessage = Label.NY_Sun_Suspended_Contractor_Error_Message_On_New_App_Message;
                  bResult = false;
              }          
          }         
        }
      }
      return bResult;
    }

    /*
  * Method Name: insertProject 
  * Description: insert Projects
  * @return:  Id
  */
    private Id insertProject() {
        String projectRecordTypeId;
        Program__c program = programMap.get(programId);
      if(program.Application_Type__c == NY_SUN_RESIDENTIAL_TYPE){
            projectRecordTypeId = NYSUN_Helper.ResidentialProjectRecordType.Id;
        } else if(program.Application_Type__c == NY_SUN_COMMERCIAL_TYPE){
            projectRecordTypeId = NYSUN_Helper.CommercialProjectRecordType.Id;
        }  /* else if(program.Application_Type__c == RTEM_TYPE){
            projectRecordTypeId = RTEM_Helper.RTEMRecordType.Id;
        } else if(program.Application_Type__c == PELLET_STOVE_TYPE){
            projectRecordTypeId = PS_Helper.PSRecordType.Id;
        } else if(program.Application_Type__c == ZEV_TYPE){
            projectRecordTypeId = ZEV_Helper.ZeroEmissionVehiclesProjectRecordType.Id;
        } else if(program.Application_Type__c == CHP_TYPE){
            projectRecordTypeId = CHP_Helper.CHPProjectRecordType.Id;
        } else if(program.Application_Type__c == GSHP_SMALL_TYPE){
            projectRecordTypeId = GSHP_Helper.GSHPSmallProjectRecordType.Id;
        } else if(program.Application_Type__c == GSHP_LARGE_TYPE){
            projectRecordTypeId = GSHP_Helper.GSHPLargeProjectRecordType.Id;
        } else if(program.Application_Type__c == CTenant_TYPE){
            projectRecordTypeId = CTenant_Helper.CTenantProjectRecordType.Id;
        } else if(program.Application_Type__c == NEW_CONSTRUCTION_TYPE){
            projectRecordTypeId = NC_Helper.NewConstructionRecordType.Id;
        }*/ else{
            projectRecordTypeId = Core_Helper.getCoreProjectRecordType(programId);
        }
        
        Project__c projectRec = new Project__c();
        String programVersionId;
        programVersionId = program.Program_Versions__r[0].Id;
        projectRec.Program_Version__c = programVersionId;
        projectRec.Name =  (program.Name.length() > 65 ? program.Name.Substring(0,65) : program.Name ) + ' ' + String.valueOf(System.Today());
        projectRec.status__c = 'Unsubmitted';
        projectRec.Statement__c = program.Statement__c;
        projectRec.RecordTypeId = projectRecordTypeId;
      
     /* if(program.Application_Type__c == NEW_CONSTRUCTION_TYPE)
      {
        projectRec.Budget_Type__c = NC_Helper.MILESTONE_BUDGET_TYPE;
        projectRec.Project_Type__c = NC_Helper.INCENTIVE_PROJECT_TYPE;
      }*/
      
        insert projectRec;
        
      /*  if(currentUser.isPortalEnabled && 
        (projectRec.RecordTypeId == GSHP_Helper.GSHPLargeProjectRecordType.Id || projectRec.RecordTypeId == GSHP_Helper.GSHPSmallProjectRecordType.Id)){
          createProjectRole(projectRec.Id);
        }*/
        return projectRec.Id;
    }
    /*
  * Method Name: createProjectRole
  * Description: create Project Role
  * @return:  void
  * @param:  Id ProjectId
  */
    public void createProjectRole(Id ProjectId){
      Project_Role__c projectRoleRec = new Project_Role__c();
      
      projectRoleRec.Role__c = ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE;
      projectRoleRec.Project__c = ProjectId;
      projectRoleRec.Account__c = currentUser.AccountId;
      projectRoleRec.Contact__c = currentUser.ContactId;
      projectRoleRec.FirstName__c = currentUser.FirstName; 
      projectRoleRec.LastName__c = currentUser.LastName;
      projectRoleRec.Primary_Customer_Contact__c = true;
      projectRoleRec.User__c = currentUser.Id;
      try{
        insert projectRoleRec;
      }
      catch(Exception e){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
      }
    } 
    
}