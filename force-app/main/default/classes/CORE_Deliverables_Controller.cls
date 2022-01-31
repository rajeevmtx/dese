/*
* Class Name: CORE_Deliverables_Controller 
* Description: S-00354 Controller class designed for handle the functionality of CORE_Deliverables_Page
* Author/Date:  Gaurav Sinha   July 9, 2016
*
* Date         New/Modified      Author             Description
* 05/21/2017   Modified          Ghanshyam          Commenting
* 10/12/2017   Modified          Harshit 			T-03378: Allow external contractor to review deliverables 
*/
public with sharing class CORE_Deliverables_Controller {
	//properties to be used on CORE_Deliverables_Page
	public string selectedphase{get;set;}
	public string richText{get;set;}
    public string selectedRecord{get;set;}
    public string selectedProjectTaskId{get;set;}
    public string selectedObject{get;set;}
    public boolean isSolicitationEnabledTaskLimit{get; set;}
    public boolean isSolicitationEnabledQuantity{get; set;}
    public boolean isTaskLimitEnabled{get; set;}
    public boolean createDeliverableRecord{get; set;}
    public boolean externalReviewer {get;set;}
    
    //property to check if the deliverable type is milestone or not
    public boolean isMilestone{
        get{
            if(isMilestone==null){
                if(project.budget_type__c==CORE_Deliverables_Helper.CONST_TM )
                    isMilestone = false;
                else
                    isMilestone = true;
            }
            return isMilestone;
        }
        set;
        
    }
    
    public Map<String, List<Project_Document__c>> mapOfChildParent{get;set;}
    public map<String,TaskWrapper> maptaskWrapper{get;set;}
    public map<String,String> mapDeliverableToAttachment {get;set;}
    public map<String,List<Project_Document__c>> mapDeliverableToDocument {get;set;}
    public list<TaskWrapper> litaskwrapper{get;set;}
    public Project_Milestones__c projectMilesParent{get;set;}
    public Project_Milestones__c newProjectMilestones{get;set;}
    public Project_Deliverables__c newProjectDeliverables{get;set;}
    public Project_Deliverables__c oldProjectDeliverables{get;set;}
    map<id,Project_Milestones__c> mapEditParentMileStone = new map<id,Project_Milestones__c>();
    map<id,Project_Milestones__c> mapEditchildMileStone = new map<id,Project_Milestones__c>();
    map<id,Project_Deliverables__c> mapEditdeliverables = new map<id,Project_Deliverables__c>();
    
    public Boolean isInnovation {get; set;}
    
    //property to get project's Id
    public id projectid {
        get{
            if(projectid==null){
                projectid = apexpages.currentPage().getParameters().get('id');
            }
            return projectid;
        }
        private set;
    }
    
    //property to get project details
    public project__c project{
        get{
            if(project==null){
                project = [select Name, RecordTypeId, Budget_Type__c, Status__c, 
                		   Program_Version__r.Enable_Milestone_Quantity__c, 
                		   Program_Version__r.Enable_Task_Limit__c from Project__c where id=:projectid];

            }
            return project;
        }
        private set;
    }
    
    //property to get task's Id
    public Id taskId {
        get{
            if(taskId==null){
                taskId = apexpages.currentPage().getParameters().get('taskId');
            }
            return taskId;
        }
        private set;
    }
    
    //property to check if the current logged in user is contractor or not
    public boolean contractor{
        Get{
        return userinfo.getUserType()!=CORE_Deliverables_Helper.USER_TYPE_STANDARD ;
    }
    set;}
    
    //property to check if current user has access to make updates for the selected project or not
    // current user must be listed as project manager for the selected project to update milestones and task deliverables
    public boolean profileAccess{
        Get{
            if(profileAccess==null){
                if(!contractor){

                    integer count = [select count() 
                                        from project_role__c 
                                        where project__c = :projectid 
                                        and   project__R.status__c !=: CORE_Deliverables_Helper.PROJECT_Closed  
                                        and  role__c =: CORE_Deliverables_Helper.PROJECT_PM 
                                        and User__c =: userinfo.getUserId()];
                    System.debug('==>'+count);
                    if(count !=0){
                        profileAccess = true;
                    }
                    else{
                        profileAccess = false;
                    }
                        System.debug('==>profileAccess'+profileAccess);
                }else{

                    User currnetUser = [select id,contactid, Contact.AccountId from user where id=:userinfo.getUserId()];
                  /*  if(currnetUser.contactid != null){
                        integer count = 0;
                        if(project.recordtypeid == CHP_Helper.CHPProjectRecordType.id){
                            Set<string> const_Status = new set<String>{CORE_Deliverables_Helper.STATUS_Installed,CORE_Deliverables_Helper.PROJECT_APPROVED};
                            count = [select count() 
                                        from project_role__c 
                                        where project__c = :projectid 
                                        and  project__R.status__c  =: const_Status
                                        and role__c =: CORE_Deliverables_Helper.PROJECT_Contractor 
                                        and contact__c =: currnetUser.contactid];
                        }else{
                            for(project_role__c role:  [select Contact__r.AccountId 
			                                              from project_role__c 
			                                             where project__c = :projectid 
			                                               and  project__R.status__c  =: CORE_Deliverables_Helper.PROJECT_APPROVED
			                                               and role__c =: ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE]) {
			                	if(role.Contact__r.AccountId == currnetUser.Contact.AccountId) {
			                		count = 1;
			                		break;
			                	}                               
                            }
                            
                             for(project_role__c role:  [select Contact__r.AccountId 
			                                              from project_role__c 
			                                             where project__c = :projectid
			                                             and role__c =: ProjectRole_Helper.PROJECT_EXTERNAL_IMPLEMENTATION_CONTRACTOR_ROLE]) {
			                	if(role.Contact__r.AccountId == currnetUser.Contact.AccountId) {
			                		externalReviewer = true;
			                	}                               
                            }
							                                            
                        } 
                        if(count !=0){
                            profileAccess = true;
                        }
                        else{
                            profileAccess = false;
                        }                        
                    }else{
                        profileAccess = false;
                    } */
                }
            }
            return profileAccess;
        }
    
        private set;
        
    }
    
    //property to populate the phase dropdown
    public list<selectOption> soPhase{
        Get{
            soPhase = new List<SelectOption>();
            soPhase.add(new SelectOption('','NONE'));
            Set<string> setPhase = new Set<String>();
            for(Project_Milestones__c varloop : [ select phase__c from Project_Milestones__c
                                         where  Is_Active__c=true
                                         and   RecordTypeId = : CORE_Deliverables_Helper.ParentMilestone.id
                                         and project__C = : projectid
                                         and phase__c !=null]){
                    if(!setPhase.contains(varloop.phase__c)){                                 
                        setPhase.add(varloop.phase__c);
                        soPhase.add(new SelectOption(varloop.phase__c,varloop.phase__c));
                    }
             }
             return soPhase;
        }
    	private set;
    }
    
    //property to check if selected project's record type is Onsite_Power_Combined_Heat_and_Power or not
   /* public boolean isCHP{
        get{
            if(isCHP==null){
                isCHP = CHP_Helper.CHPProjectRecordType.id == project.recordtypeid;
            }
            return isCHP;
        }
        set;
    } */
    
    //property to check if selected project's record type is new construction or not
   /* public boolean isNC{
        get{
            if(isNC == null){
            	RecordType ncRecType = NC_Helper.NewConstructionRecordType;
                isNC = ncRecType == null ? false : ncRecType.id == project.recordtypeid;
            }
            return isNC;
        }
        set;
    } */
    
    //Constructor
    public CORE_Deliverables_Controller(){
        SelectedPhase = '';
        isSolicitationEnabledTaskLimit = false;
        isSolicitationEnabledQuantity = false;
        externalReviewer = false;
        isTaskLimitEnabled = false;
        mapDeliverableToAttachment = new map<String,String>();
        mapDeliverableToDocument = new map<String,List<Project_Document__c>>();
        //litask = new List<Task>();
        retrieveData();
    }
    
    /*
    * Method Name: retrieveData
    * Description: Method to fetch All records from the Project Task.
    * @param: N/A
    * @return: void
    */
    public void retrieveData(){
        recordExist = new Map<String,boolean>();
        mapEditParentMileStone = new map<id,Project_Milestones__c>();
        mapEditchildMileStone = new map<id,Project_Milestones__c>();
        mapEditdeliverables = new map<id,Project_Deliverables__c>();
        maptaskWrapper = new map<string,TaskWrapper>();
        Map<id,Project_Task__c> mapProjeTaskId = new Map<id,Project_Task__c>();
        taskwrapper tempVar;
         
        if(Clean_Transportation_Helper.INNOVATION_PROJECT_RECORD_TYPE_ID_SET.contains(project.RecordTypeId)) {
        	isInnovation = true;
        } else {
        	isInnovation = false;
        }
        
        if(project != null && project.Program_Version__r.Enable_Task_Limit__c != null){
        	isSolicitationEnabledTaskLimit = project.Program_Version__r.Enable_Task_Limit__c;
        }
        
        if(project != null && project.Program_Version__r.Enable_Milestone_Quantity__c != null){
        	isSolicitationEnabledQuantity = project.Program_Version__r.Enable_Milestone_Quantity__c;
        }
        
        // Retrieve the Project task
        if(String.isBlank(SelectedPhase)){
            for(Project_Milestones__c varLoop:[SELECT Stage_Gate_Status_Note__c,Hybrid_Budget__c,Stage_Gate_Status_Date__c,Stage_Gate_Status__c,Stage_Gate__c,Not_to_Exceed_Amount__c,
                                               task_name__c,Deliverables__c,Cost_Share__c, Billed_To_Date__c, Id,Incentive_Amount__c,Is_Active__c,start_Date__c,end_Date__c,sequence__c,project__r.budget_type__c,
                                            		  Milestone_Name__c,Name,Parent__c,Project_Task__c,Project__c,RecordTypeId,Status__c,Total_Cost__c ,Description__c,phase__c,
                                                      Enable_Task_Limit__c, Quantity__c,NYSERDA_Cost__c,
                                                      (SELECT task_name__c,Sequence__c , Deliverables__c,Cost_Share__c, Billed_To_Date__c, Id,Incentive_Amount__c,Is_Active__c,start_Date__c,end_Date__c,
                                            		          Milestone_Name__c,Name,Parent__c,Parent__r.Enable_Task_Limit__c, Parent__r.Incentive_Amount__c,Project_Task__c,Project__c,RecordTypeId,Status__c,Total_Cost__c, Quantity__c
                                            		     FROM Child_Project_Milestones__r
                                                        where Is_Active__c=true
                                                          and RecordTypeId = : CORE_Deliverables_Helper.ChildMilestone.id
                                                        order by sequence__c),
                                                      (SELECT Waiting_for_External_Response__c,Waiting_for_External_Response_Date__c,
                                                                Deliverable_name__c,Conditionally_Required__c,Fuel_Type__c,Id,Mandatory_by_Default__c,Measure_Components__c,start_Date__c,end_Date__c,
		                                            	      Name,Notes__c,Project_Milestone__c,Project_Task__c,Project__c,Savings__c,Sequence__c,Status__c,
		                                            	      Sub_Type__c,Type__c,Validation_Logic__c,Validation_Notes__c, External_Review_Required__c
		                                            	 FROM Project_Deliverables1__r 
		                                            	order by Sequence__c asc)
		                                         from Project_Milestones__c
		                                        where Is_Active__c=true
		                                          and RecordTypeId = : CORE_Deliverables_Helper.ParentMilestone.id
		                                          and project__C = : projectid
		                                        order by phase__c, Sequence__c asc]) {
                
                tempVar = new TaskWrapper();
                mapEditParentMileStone.put(varloop.id,varloop);
                for(Project_Milestones__c varLoopChild : varLoop.Child_Project_Milestones__r){
                    if(varLoopChild.task_name__c==null)
                        varLoopChild.task_name__c = varLoopChild.name;
                        
                    mapEditchildMileStone.put(varLoopChild.id,varLoopChild);
                }
                for(Project_Deliverables__c varLoopChild : varLoop.Project_Deliverables1__r){
                    if(varLoopChild.Deliverable_name__c==null)
                        varLoopChild.Deliverable_name__c = varLoopChild.name;
                        
                    mapEditdeliverables.put(varLoopChild.id,varLoopChild);
                    mapDeliverableToAttachment.put(varLoopChild.id, 'NA');
                    recordExist.put(varLoopChild.id,false);
                }                
                if(varLoop.task_name__c==null)
                    varLoop.task_name__c = varLoop.name;
                tempvar.parentMiles = varLoop;
                tempvar.projectDeliver = varLoop.Project_Deliverables1__r;
                tempvar.projectMiles = varLoop.Child_Project_Milestones__r;
                tempvar.parentMiles.Incentive_Amount__c = tempvar.parentMiles.Incentive_Amount__c == null ? 0 : tempvar.parentMiles.Incentive_Amount__c;
                tempvar.parentMiles.Total_Cost__c = tempvar.parentMiles.Total_Cost__c == null ? 0 : tempvar.parentMiles.Total_Cost__c;
                tempvar.parentMiles.Cost_Share__c = tempvar.parentMiles.Cost_Share__c == null ? 0 : tempvar.parentMiles.Cost_Share__c;
                tempvar.parentMiles.Billed_To_Date__c = tempvar.parentMiles.Billed_To_Date__c == null ? 0 : tempvar.parentMiles.Billed_To_Date__c;
                tempvar.parentMiles.Hybrid_Budget__c = varLoop.Hybrid_Budget__c;
                
                // CHP: For Contractor - Remove "Project Management" milestone - Task T-01662
                if(!(varLoop.task_name__c == CORE_Deliverables_Helper.PROJECT_MANAGEMENT_MILESTONE && contractor)) {
                	maptaskWrapper.put(varLoop.id,tempvar);
                }
             }
             fetchDeliverableDocuments();
        }else{
            for(Project_Milestones__c varLoop:[SELECT Stage_Gate_Status_Note__c,Stage_Gate_Status_Date__c,Stage_Gate_Status__c,Stage_Gate__c,Not_to_Exceed_Amount__c,
                                               task_name__c,Deliverables__c,Cost_Share__c, Billed_To_Date__c, Id,Incentive_Amount__c,Is_Active__c,start_Date__c,end_Date__c,sequence__c,
                                            		  Milestone_Name__c,Name,Parent__c,Parent__r.Enable_Task_Limit__c,Parent__r.Incentive_Amount__c,Project_Task__c,Project__c,RecordTypeId,Status__c,Total_Cost__c ,Description__c,phase__c,
                                                      Enable_Task_Limit__c, Quantity__c,NYSERDA_Cost__c,
                                                      (SELECT task_name__c,Sequence__c ,Deliverables__c,Cost_Share__c, Billed_To_Date__c, Id,Incentive_Amount__c,Is_Active__c,start_Date__c,end_Date__c,
                                            				  Quantity__c,Milestone_Name__c,Name,Parent__c,Project_Task__c,Project__c,RecordTypeId,Status__c,Total_Cost__c FROM Child_Project_Milestones__r
                                                        where Is_Active__c=true
                                                          and RecordTypeId = : CORE_Deliverables_Helper.ChildMilestone.id),
                                                      (SELECT Waiting_for_External_Response_Date__c,Waiting_for_External_Response__c,
                                                                Deliverable_name__c,Conditionally_Required__c,Fuel_Type__c,Id,Mandatory_by_Default__c,start_Date__c,end_Date__c,Measure_Components__c,
					                                          Name,Notes__c,Project_Milestone__c,Project_Task__c,Project__c,Savings__c,Sequence__c,Status__c,
					                                          Sub_Type__c,Type__c,Validation_Logic__c,Validation_Notes__c, External_Review_Required__c
					                                     FROM Project_Deliverables1__r 
					                                    order by Sequence__c asc)
                                                 from Project_Milestones__c
                                                where Is_Active__c=true
		                                          and RecordTypeId = : CORE_Deliverables_Helper.ParentMilestone.id
		                                          and project__C = : projectid
		                                          and Phase__c =: SelectedPhase
                                             order by phase__c, Sequence__c asc]){
                tempVar = new TaskWrapper();
                mapEditParentMileStone.put(varloop.id,varloop);
                for(Project_Milestones__c varLoopChild : varLoop.Child_Project_Milestones__r){
                    if(varLoopChild.task_name__c==null)
                        varLoopChild.task_name__c = varLoopChild.name;
                        
                    mapEditchildMileStone.put(varLoopChild.id,varLoopChild);
                }
                for(Project_Deliverables__c varLoopChild : varLoop.Project_Deliverables1__r){
                    if(varLoopChild.Deliverable_name__c==null)
                        varLoopChild.Deliverable_name__c = varLoopChild.name;
                        
                    mapEditdeliverables.put(varLoopChild.id,varLoopChild);
                    mapDeliverableToAttachment.put(varLoopChild.id, 'NA');
                    recordExist.put(varLoopChild.id,false);
                }                   
                if(varLoop.task_name__c==null)
                    varLoop.task_name__c = varLoop.name;
                    
                tempvar.parentMiles = varLoop;
                tempvar.projectDeliver = varLoop.Project_Deliverables1__r;
                tempvar.projectMiles = varLoop.Child_Project_Milestones__r;
                tempvar.parentMiles.Incentive_Amount__c = tempvar.parentMiles.Incentive_Amount__c == null ? 0 : tempvar.parentMiles.Incentive_Amount__c;
                tempvar.parentMiles.Total_Cost__c = tempvar.parentMiles.Total_Cost__c == null ? 0 : tempvar.parentMiles.Total_Cost__c;
                tempvar.parentMiles.Cost_Share__c = tempvar.parentMiles.Cost_Share__c == null ? 0 : tempvar.parentMiles.Cost_Share__c;    
                tempvar.parentMiles.Billed_To_Date__c = tempvar.parentMiles.Billed_To_Date__c == null ? 0 : tempvar.parentMiles.Billed_To_Date__c;             
                
                // CHP: For Contractor - Remove "Project Management" milestone - Task T-01662
                if(!(varLoop.task_name__c == CORE_Deliverables_Helper.PROJECT_MANAGEMENT_MILESTONE && contractor)) {
                	maptaskWrapper.put(varLoop.id,tempvar);
                }
             }
             fetchDeliverableDocuments();      
        }
        litaskwrapper = maptaskWrapper.values();
        
        for(TaskWrapper tw : litaskwrapper) {
    		Boolean isNotApproveDeliverableExists = false;
    		for(Project_Deliverables__c projectDeliverableRec : tw.projectDeliver) {
    			if(projectDeliverableRec.Status__c != 'Approved') {
    				isNotApproveDeliverableExists = true;
    			}
    		}
    		tw.isAllDeliverablesApproved = !isNotApproveDeliverableExists;
    	}  
    }
    
    public map<string,boolean> recordExist{Get;set;}
    
    /*
    * Method Name: fetchDeliverableDocuments
    * Description: Method to fetch deliverable's documents
    * @param: N/A
    * @return: void
    */
    private void fetchDeliverableDocuments() {
        mapDeliverableToDocument = new map<String,List<Project_Document__c>>();
        mapOfChildParent = new Map<String, List<Project_Document__c>>();
    	for(Project_Document__c document : [Select  Version__c, Project_Deliverables__c, createddate,Parent_Project_Document__c ,
    	                                           (Select Id,name,createdDate From Attachments) 
    	                                      From Project_Document__c
    	                                     Where Project_Deliverables__c IN: mapEditdeliverables.keySet()
    	                                     order by createddate Desc]) {
            if(document.Parent_Project_Document__c==null){
                if(recordExist.get(document.Project_Deliverables__c)!=null){
                    recordExist.put(document.Project_Deliverables__c,true);
                }
                if(mapOfChildParent.get(document.id)==null){
                    mapOfChildParent.put(document.Id, new List<Project_Document__c>{document});
                }else{
                    mapOfChildParent.get(document.Id).add(document);
                }
                
    			if(mapDeliverableToDocument.get(document.Project_Deliverables__c)==null)
                    mapDeliverableToDocument.put(document.Project_Deliverables__c,new list<Project_Document__c>{document});
                else
                    mapDeliverableToDocument.get(document.Project_Deliverables__c).add(document);
                    
            }else{
                if(mapOfChildParent.get(document.Parent_Project_Document__c)==null){
                    mapOfChildParent.put(document.Parent_Project_Document__c, new List<Project_Document__c>{document});
                }else{
                    mapOfChildParent.get(document.Parent_Project_Document__c).add(document);
                }
            }
            
            //Ashish Sharma: Commented on 11 Oct, 2017 because nothing is being done in this piece of code
    		/*if(mapDeliverableToAttachment.containsKey(document.Project_Deliverables__c) && mapDeliverableToAttachment.get(document.Project_Deliverables__c) == 'NA' 
    		   && document.Version__c != null && document.Attachments.size() > 0) {
    		//	mapDeliverableToAttachment.put(document.Project_Deliverables__c, document.Attachments[0].Id);
    			if(document.Parent_Project_Document__c==null){

    			}
    		}*/
    	}
    }
    
    /*
    * Method Name: editeNewObject
    * Description: Method to intialize collections/variable for editing deliverables
    * @param: N/A
    * @return: void
    */
    public void editeNewObject(){
       richText= '';
       isTaskLimitEnabled = false;
       createDeliverableRecord = false;
       
        if(selectedObject=='projectMilesParent'){
            projectMilesParent = mapEditParentMileStone.get(selectedRecord);
            richText = projectMilesParent.description__c;
            system.debug('--------'+projectMilesParent);
        }
        else if(selectedObject=='projectMilesChild'){
            newProjectMilestones = mapEditchildMileStone.get(selectedRecord);
            isTaskLimitEnabled = newProjectMilestones.Parent__r.Enable_Task_Limit__c;
            //richText = newProjectMilestones.description__c;
        }else if(selectedObject=='projectDelivery' || selectedObject=='projectDeliveryExternalReview'){
            newProjectDeliverables = mapEditdeliverables.get(selectedRecord);
            oldProjectDeliverables = new Project_Deliverables__c(status__c= newProjectDeliverables.Status__c);
            /*
             * Changes moved to deliverabel document page
            if(taskInformation == 'true'){
                litask= new list<task>();
                for(task varloop: [select id,subject,activitydate,createddate, status,type,priority,Description,createdby.name 
                                    from task 
                                    where whatid =: selectedRecord
                                    order by activitydate desc]){
                    litask.add(varLoop);
                }
                
            }    */        
        }
        /*else if(selectedObject == 'projectMilesParentDesc'){
            projectMilesParent = mapEditParentMileStone.get(selectedRecord);

        }
*/
    }
    
    /*
    * Method Name: deleteObject
    * Description: Method to delete the selected deliverable
    * @param: N/A
    * @return: void
    */
    public void deleteObject(){
        if(selectedObject=='projectMilesParent')
            delete new Project_Milestones__c(id=selectedRecord);
        else if(selectedObject=='projectMilesChild'){
            delete new Project_Milestones__c(id=selectedRecord);
        }else if(selectedObject=='projectDelivery'){
            delete new Project_Deliverables__c(id=selectedRecord);
        }
        retrieveData();
    }     
    
    /*
    * Method Name: initializeNewObject
    * Description: Method to intialize collections for creating new deliverables
    * @param: N/A
    * @return: void
    */
    public void initializeNewObject(){
        richText = '';
        isTaskLimitEnabled = false;
        Project_Milestones__c parent;
        
        createDeliverableRecord = false;
        
        if(selectedObject=='projectMilesParent')
            projectMilesParent = new Project_Milestones__c(project__c = projectid,
            											   RecordTypeId=CORE_Deliverables_Helper.ParentMilestone.id,
            											   Is_Active__c=true);
        else if(selectedObject=='projectMilesChild'){
            parent = mapEditParentMileStone.get(selectedProjectTaskId);
            isTaskLimitEnabled = parent.Enable_Task_Limit__c;
            newProjectMilestones = new Project_Milestones__c(status__c = CORE_Deliverables_Helper.STATUS_SCHEDULED,
                                                            project__c = projectid,
                                                            start_Date__c = parent.Start_Date__c,
                                                            End_Date__c = parent.End_Date__c,
                                                            parent__c=selectedProjectTaskId,
                                                            RecordTypeId=CORE_Deliverables_Helper.ChildMilestone.id,
                                                            Is_Active__c=true);
        }else if(selectedObject=='projectDelivery'){
            oldProjectDeliverables = null;
            parent = mapEditParentMileStone.get(selectedProjectTaskId);
            newProjectDeliverables = new Project_Deliverables__c(status__c = CORE_Deliverables_Helper.STATUS_SCHEDULED,
                                                                project__c = projectid,
                                                                start_Date__c = parent.Start_Date__c,
                                                                End_Date__c = parent.End_Date__c,
                                                                Project_Milestone__c=selectedProjectTaskId);
        }
    }
    
    /*
    * Method Name: updateDeliverable
    * Description: method to update the deliverables
    * @param: N/A
    * @return: void
    */
    public void updateDeliverable(){
        List<Project_Deliverables__c> liproDel = new list<Project_Deliverables__c>();
        if(selectedProjectTaskId!=null){
            for(Project_Deliverables__c varloop : [select id,status__c from Project_Deliverables__c 
                                                   where project_milestone__c =:selectedProjectTaskId
                                                  	 and project__c =: projectid]){
                 varloop.status__C = CORE_Deliverables_Helper.PROJECT_APPROVED;
                 liproDel.add(varloop);                                      
            }
        }
        update liproDel;
        retrieveData();
    }
    
    /*
    * Method Name: insertObject
    * Description: Method to save the deliverables
    * @param: N/A
    * @return: Pagereference
    */
    public Pagereference insertObject(){
        //check if current user have rights to save deliverable or not, if not return null
        if(!profileAccess)
            return null;
        
        //logic to save deliverables only for parent milestones 
        if(selectedObject=='projectMilesParent'){
            projectMilesParent.description__c = richtext;
            
            //crop the task name if the length is more than 79 characters
            projectMilesParent.name = projectMilesParent.task_name__c.length() > 79 ?projectMilesParent.task_name__c.substring(0,79):projectMilesParent.task_name__c;
			
			//reset currency fields if budget type is T&M and hybrid
            if(project.budget_type__c == CORE_Deliverables_Helper.CONST_TM && projectMilesParent.Hybrid_Budget__c && projectMilesParent.Id != null){
            	projectMilesParent.Incentive_Amount__c = null;
            	projectMilesParent.Cost_Share__c = null;
            	projectMilesParent.Total_Cost__c = null;
            }
			
			//logic to process milestone type deliverables
            if(projectMilesParent.Id <> null && isMilestone){
            	Decimal incentiveAmount = 0;
                Decimal costShare = 0;
                
                for(Project_Milestones__c tempMileStone : [SELECT Id, Total_Cost__c, Incentive_Amount__c, 
                                                           Cost_Share__c, Quantity__c, Parent__r.Enable_Task_Limit__c 
                                                           FROM Project_Milestones__c
                                                           WHERE Parent__c =: projectMilesParent.Id]){
                    costShare += (tempMileStone.Cost_Share__c != null) ? tempMileStone.Cost_Share__c : 0;
                    
                    if(!isSolicitationEnabledQuantity){
	                    incentiveAmount += (tempMileStone.Incentive_Amount__c != null) ? tempMileStone.Incentive_Amount__c : 0;
                    }else{
                    	if(tempMileStone.Quantity__c != null &&
			               tempMileStone.Quantity__c != 'No Limit' &&
			               tempMileStone.Incentive_Amount__c != null &&
			               (!tempMileStone.Parent__r.Enable_Task_Limit__c)){
			               	
			               	incentiveAmount += Integer.valueOf(tempMileStone.Quantity__c) * tempMileStone.Incentive_Amount__c;
			            }
                    }
                }
                
                if(projectMilesParent.Enable_Task_Limit__c){
                	incentiveAmount = projectMilesParent.NYSERDA_Cost__c;
                }
                
                projectMilesParent.Total_Cost__c = (incentiveAmount + costShare);
	            projectMilesParent.Incentive_Amount__c = incentiveAmount;
	            projectMilesParent.Cost_Share__c = costShare;
            }

            upsert projectMilesParent;
            
            if(project.budget_type__c == CORE_Deliverables_Helper.CONST_TM && !projectMilesParent.Hybrid_Budget__c && projectMilesParent.Id != null){
            	List<Project_Milestones__c> toDeleteMilestone = new List<Project_Milestones__c>();
            	
            	for(Project_Milestones__c milestone : [SELECT ID FROM Project_Milestones__c WHERE Parent__c =: projectMilesParent.Id]){
            		toDeleteMilestone.add(milestone);
            	}
            	
            	if(toDeleteMilestone.size() > 0){
            		delete toDeleteMilestone;
            	}
            }
        }
        
        //logic to process child milestones
        else if(selectedObject=='projectMilesChild'){
        	if(newProjectMilestones.Id == null && createDeliverableRecord){
        		Project_Deliverables__c tempProjectDeliverable = new Project_Deliverables__c();
        		tempProjectDeliverable.Deliverable_Name__c = newProjectMilestones.Task_Name__c;
        		tempProjectDeliverable.Start_Date__c = newProjectMilestones.Start_Date__c;
        		tempProjectDeliverable.End_Date__c = newProjectMilestones.End_Date__c;
        		tempProjectDeliverable.Status__c = CORE_Deliverables_Helper.STATUS_SCHEDULED;
                tempProjectDeliverable.Project__c = projectid;
                tempProjectDeliverable.Project_Milestone__c = selectedProjectTaskId;
                
                Integer tempSequence = 1;
                
                for(Project_Deliverables__c tempDeliverable : [SELECT Sequence__c FROM Project_Deliverables__c
                											   WHERE Project__c =: projectid
                											   AND Project_Milestone__c =: selectedProjectTaskId
                											   AND Sequence__c != null
                											   ORDER BY Sequence__c DESC LIMIT 1]){
                	
                	tempSequence += Integer.valueOf(tempDeliverable.Sequence__c);
                }
                
                tempProjectDeliverable.Sequence__c = String.valueOf(tempSequence);
                
        		insert tempProjectDeliverable;
        	}
        	
            newProjectMilestones.description__c = richtext;
            
            //crop the task name if the length is more than 79 characters
            newProjectMilestones.name = newProjectMilestones.task_name__c.length() > 79 ?newProjectMilestones.task_name__c.substring(0,79):newProjectMilestones.task_name__c;
            
            if(isSolicitationEnabledQuantity && 
               newProjectMilestones.Quantity__c != null &&
               newProjectMilestones.Quantity__c != 'No Limit' &&
               newProjectMilestones.Incentive_Amount__c != null){
            	
            	newProjectMilestones.Total_NYSERDA_Payment__c = Integer.valueOf(newProjectMilestones.Quantity__c) *
            													newProjectMilestones.Incentive_Amount__c;
            
            	newProjectMilestones.Total_Cost__c = newProjectMilestones.Total_NYSERDA_Payment__c + (newProjectMilestones.Cost_Share__c != null ? newProjectMilestones.Cost_Share__c : 0);
            }
            
            upsert newProjectMilestones;
            
            if(newProjectMilestones.Parent__c != null){
                Decimal incentiveAmount = 0;
                Decimal costShare = 0;
                
                for(Project_Milestones__c tempMileStone : [SELECT Id, Total_Cost__c, Incentive_Amount__c, 
                                                           Cost_Share__c, Quantity__c, Parent__r.Enable_Task_Limit__c 
                                                           FROM Project_Milestones__c
                                                           WHERE Parent__c =: newProjectMilestones.Parent__c]){
                    costShare += (tempMileStone.Cost_Share__c != null) ? tempMileStone.Cost_Share__c : 0;
                    
                    if(!isSolicitationEnabledQuantity){
	                    incentiveAmount += (tempMileStone.Incentive_Amount__c != null) ? tempMileStone.Incentive_Amount__c : 0;
                    }else{
                    	if(tempMileStone.Quantity__c != null &&
			               tempMileStone.Quantity__c != 'No Limit' &&
			               tempMileStone.Incentive_Amount__c != null){
			               	
			               	incentiveAmount += Integer.valueOf(tempMileStone.Quantity__c) * tempMileStone.Incentive_Amount__c;
			            }
                    } 
                }
                
                update new Project_Milestones__c(Id = newProjectMilestones.Parent__c,
                                                 Total_Cost__c = (incentiveAmount + costShare),
                                                 Incentive_Amount__c = incentiveAmount,
                                                 Cost_Share__c = costShare);
            }
        }
        //logic to process project deliverable
        else if(selectedObject=='projectDelivery'){
    
            if(newProjectDeliverables.Status__c == CORE_Deliverables_Helper.CONST_REJECTED &&  (  oldProjectDeliverables == null || oldProjectDeliverables.status__c != CORE_Deliverables_Helper.CONST_REJECTED ) ){ 
                newProjectDeliverables.Waiting_for_External_Response__c = true;
                newProjectDeliverables.Waiting_for_External_Response_Date__c = system.today();
            }

            newProjectDeliverables.name = newProjectDeliverables.Deliverable_name__c.length() >79 ? newProjectDeliverables.Deliverable_name__c.substring(0,79):newProjectDeliverables.Deliverable_name__c;
            upsert newProjectDeliverables;
            
        }
        
        retrieveData();
        
        Pagereference pg = new Pagereference('/apex/CORE_Deliverables_Page?id=' + projectId);
        pg.setRedirect(true);
        return pg;
    }    
    
    /*
    * Method Name: insertFeedback
    * Description: project deliverable external feedback
    * @param: N/A
    * @return: Pagereference
    */
    public Pagereference insertFeedback(){
    	update newProjectDeliverables;
    	Pagereference pg = new Pagereference('/apex/CORE_Deliverables_Page?id=' + projectId);
        pg.setRedirect(true);
        return pg;
    }
	
	//wrapper class that contains task's detail and sort the result on the basis of sequence
    public class TaskWrapper implements Comparable{
        public Project_Milestones__c parentMiles{Get;set;}
        public list<Project_Milestones__c> projectMiles{Get;set;}
        public list<Project_Deliverables__c> projectDeliver{get;set;}
        public Boolean isAllDeliverablesApproved {get; set;}
        
        public TaskWrapper(){
            
        }
        public Integer compareTo(Object compareTo) {
            Project_Milestones__c cmparetoparentMiles =  (Project_Milestones__c)compareTo;
            if(parentMiles.Sequence__c == cmparetoparentMiles.Sequence__c) return 0;
            else if(parentMiles.Sequence__c > cmparetoparentMiles.Sequence__c) return -1;
            return 1;
        }

    }
}