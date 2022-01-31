/*
* 	Class Name: ProjectMilestones_Helper
* 	Description: Helper class dealing with Project_Deliverables__c records
*
*  Author/Date: George Acker/May 15, 2016
*  Date         New/Modified      Author             Description
*  10/04/2017   Modified          Kalpna Bindal      (T-03342, T-03343, creation of default milestone and deliverables)
*/
public with sharing class ProjectMilestones_Helper {

    public static String PARENT_MILESTONE_RECORDTYPE = 'Project_Milestones';
    public static String CHILD_MILESTONE_RECORDTYPE = 'Child_Project_Milestone';
    public static String MILESTONE_TYPE_NYSERDA_INCENTIVE = 'NYSERDA Incentive';
    public static String MILESTONE_SUB_TYPE_BATTERY_STORAGE = 'Battery Storage Incentive';
    public static String MILESTONE_SUB_TYPE_ENERGY_EFFICIENCY = 'Energy Efficiency Incentive';
    public static String MILESTONE_SUB_TYPE_AFFORDABLE_SOLAR_INCENTIVE = 'Affordable Solar Incentive';
    public static String MILESTONE_SUB_TYPE_BASE_INCENTIVE = 'Base Incentive';
    public static final String COMMERCIAL_RTEM_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Commercial_Real_Time_Energy_Management';
    public static String STAGE_GATE_PENDING_STATUS = 'Pending';
    public static final String STATUS_APPROVED = 'Approved';
    public static RecordType RTEMRecordType
    {
        get
        {
            if (RTEMRecordType == null)
                RTEMRecordType = Utility_RecordType_Helper.getRecordType('Project__c', COMMERCIAL_RTEM_PROJECT_RECORD_TYPE_DEVELOPER_NAME);
            return RTEMRecordType;
        }
        set;
    }

    public static String MILESTONE_SUB_TYPE_YEAR_3 = 'Year 3';


    public static RecordType ParentMilestoneRecordType
    {
        get
        {
            if (ParentMilestoneRecordType == null)
                ParentMilestoneRecordType = Utility_RecordType_Helper.getRecordType('Project_Milestones__c',PARENT_MILESTONE_RECORDTYPE);
            return ParentMilestoneRecordType;
        }
        set;
    }

    public static RecordType ChildMilestoneRecordType
    {
        get
        {
            if (ChildMilestoneRecordType == null)
                ChildMilestoneRecordType = Utility_RecordType_Helper.getRecordType('Project_Milestones__c',CHILD_MILESTONE_RECORDTYPE);
            return ChildMilestoneRecordType;
        }
        set;
    }

    /*
	* Method Name: defaultMilestonesOnInsert
	* Description: Static method calling to expose milestone on insert operation
	* @param: Project__c[] records
	* @return void
	*/
    public static void defaultMilestonesOnInsert(Project__c[] records)
    {
        Set<Id> programVersions = new Set<Id>();
        for (Project__c project :records)
        {
            programVersions.add(project.program_version__c);
        }

        Id[] acceptableChildRecordTypes = new ID[]{ProgramContent_Helper.MilestoneRecordType.Id,ProgramContent_Helper.DeliverableRecordType.Id};
        Map<Id,Program_Content__c[]> milestoneTemplateMap = new Map<Id,Program_Content__c[]>();
        for (Program_Content__c milestoneTemplate :[SELECT object_name__c,type__c,sub_type__c,Program_Version__c,sequence__c, project_type__c,
                                                    (SELECT object_name__c,type__c,sub_type__c,sequence__c,recordTypeId,
                                                        mandatory_by_default__c,conditionally_required__c,validation_logic__c, project_type__c,
                                                        validation_notes__c
                                                        FROM Program_Contents__r WHERE RecordTypeId IN :acceptableChildRecordTypes)
                                                    FROM Program_Content__c
                                                    WHERE parent__c = null AND RecordTypeId = :ProgramContent_Helper.MilestoneRecordType.Id
                                                    AND Program_Version__c IN :programVersions order by name ASC, object_name__c ASC])
        {
            if (!milestoneTemplateMap.containsKey(milestoneTemplate.program_version__c))
                milestoneTemplateMap.put(milestoneTemplate.program_version__c,new Program_Content__c[]{});
            milestoneTemplateMap.get(milestoneTemplate.program_version__c).add(milestoneTemplate);
        }

        Utility_MapChain contentToMilestoneMap = new Utility_MapChain();
        Project_Milestones__c[] milestonesToInsert = new Project_Milestones__c[]{};
        for (Project__c project :records)
        {
            if (milestoneTemplateMap.containsKey(project.program_version__c))
            {
                for (Program_Content__c milestoneTemplate :milestoneTemplateMap.get(project.program_version__c))
                {
                	if(project.Project_Type__c == milestoneTemplate.Project_Type__c) // copying the milestone and deliverables on behalf of the project type. T-03342, T-03343
                	{
	                    Project_Milestones__c milestone = new Project_Milestones__c();
	                    milestone.project__c = project.Id;
	                  /*  if(project.recordTypeId == RTEMRecordType.Id)
	                    	milestone.name = 'Project - ' + milestoneTemplate.object_name__c;
	                    else */
	                    milestone.name = milestoneTemplate.object_name__c;
	                    milestone.type__c = milestoneTemplate.type__c;
	                    milestone.sub_type__c = milestoneTemplate.sub_type__c;
	                    milestone.recordTypeId = ParentMilestoneRecordType.Id;
	                    milestone.is_active__c = true;
	                    // Addition of new Field Mapping sequence
	                    // Gaurav Sinha 15 August 2016
	                    milestone.Sequence__c = String.valueOf(milestoneTemplate.Sequence__c);
	                    milestonesToInsert.add(milestone);
	                    contentToMilestoneMap.putData(new Id[]{project.Id,milestoneTemplate.Id},milestone);
                	}
                }
            }
        }

        if (milestonesToInsert.size() > 0)
            insert milestonesToInsert;

        Project_Milestones__c[] childMilestonesToInsert = new Project_Milestones__c[]{};
        Project_Deliverables__c[] deliverablesToInsert = new Project_Deliverables__c[]{};
        for (Project__c project :records)
        {
            if (milestoneTemplateMap.containsKey(project.program_version__c))
            {
                for (Program_Content__c parentMilestoneTemplate :milestoneTemplateMap.get(project.program_version__c))
                {
                    for(Program_Content__c templateRec :parentMilestoneTemplate.Program_Contents__r)
                    {
                    	if(templateRec.Project_Type__c == project.Project_Type__c) // copying the milestone and deliverables on behalf of the project type. T-03342, T-03343
                    	{
	                        if(templateRec.recordTypeId == ProgramContent_Helper.MilestoneRecordType.Id)
	                        {
	                            Project_Milestones__c milestone = new Project_Milestones__c();
	                            milestone.project__c = project.Id;
	                            milestone.name = templateRec.object_name__c;
	                            milestone.type__c = templateRec.type__c;
	                            milestone.sub_type__c = templateRec.sub_type__c;
	                            milestone.recordTypeId = ChildMilestoneRecordType.Id;
	                            milestone.is_active__c = true;
	                            milestone.Status__c = ProjectDeliverables_Helper.STATUS_SCHEDULED;
	                            milestone.Cost_Share__c = 0;
	                            milestone.Sequence__c = String.valueOf(templateRec.Sequence__c);
	                            milestone.parent__c = ((Project_Milestones__c) contentToMilestoneMap.getData(new Id[]{project.Id,parentMilestoneTemplate.Id})).Id;
	                            childMilestonesToInsert.add(milestone);
	                        }
	                        else if(templateRec.recordTypeId == ProgramContent_Helper.DeliverableRecordType.Id)
	                        {
	                            Project_deliverables__c deliverable = new Project_deliverables__c();
	                            deliverable.Project__c = project.Id;
	                            deliverable.Name = (String.isNotBlank(templateRec.object_name__c) && templateRec.object_name__c.length() > 80) ? templateRec.object_name__c.substring(0, 79) : templateRec.object_name__c;
	                            deliverable.type__c = templateRec.type__c;
	                            deliverable.sub_type__c = templateRec.sub_type__c;
	                            deliverable.Mandatory_by_Default__c = templateRec.Mandatory_by_Default__c;
	                            if (templateRec.Mandatory_by_Default__c)
	                                deliverable.status__c = ProjectDeliverables_Helper.STATUS_SCHEDULED;
	                            deliverable.Conditionally_Required__c = templateRec.Conditionally_Required__c;
	                            deliverable.Sequence__c = String.valueOf(templateRec.Sequence__c);
	                            deliverable.Validation_Logic__c = templateRec.Validation_Logic__c;
	                            deliverable.Validation_Notes__c = templateRec.Validation_Notes__c;
	                            deliverable.Project_Milestone__c = ((Project_Milestones__c) contentToMilestoneMap.getData(new Id[]{project.Id,parentMilestoneTemplate.Id})).Id;
	                            deliverablesToInsert.add(deliverable);
	                        }
                    	}
                    }
                }
            }
        }

        if (childMilestonesToInsert.size() > 0)
            insert childMilestonesToInsert;

        if (deliverablesToInsert.size() > 0)
            insert deliverablesToInsert;
    }

    /*
	* Method Name: defaultMilestonesOnDeliverableInsert
	* Description: Milestone on deliverable insert operation
	* @param: Project__c[] records
	* @return void
	*/
    public static void defaultMilestonesOnDeliverableInsert(Project__c[] records)
    {
        Set<Id> programVersions = new Set<Id>();
        for (Project__c project :records)
        {
            programVersions.add(project.program_version__c);
        }

        Id[] acceptableChildRecordTypes = new ID[]{ProgramContent_Helper.MilestoneRecordType.Id,ProgramContent_Helper.DeliverableRecordType.Id};
        Map<Id,Program_Content__c[]> milestoneTemplateMap = new Map<Id,Program_Content__c[]>();
        for (Program_Content__c milestoneTemplate :[SELECT object_name__c,type__c,sub_type__c,Program_Version__c,sequence__c,
                                                    (SELECT object_name__c,type__c,sub_type__c,sequence__c,recordTypeId,
                                                        mandatory_by_default__c,conditionally_required__c,validation_logic__c,
                                                        validation_notes__c
                                                        FROM Program_Contents__r WHERE RecordTypeId IN :acceptableChildRecordTypes)
                                                    FROM Program_Content__c
                                                    WHERE parent__c = null AND RecordTypeId = :ProgramContent_Helper.MilestoneRecordType.Id
                                                    AND Program_Version__c IN :programVersions order by name ASC, object_name__c ASC])
        {
            if (!milestoneTemplateMap.containsKey(milestoneTemplate.program_version__c))
                milestoneTemplateMap.put(milestoneTemplate.program_version__c,new Program_Content__c[]{});
            milestoneTemplateMap.get(milestoneTemplate.program_version__c).add(milestoneTemplate);
        }
        Map<Id,Map<String, Project_Milestones__c>> projectMilestoneMap = new Map<Id,Map<String, Project_Milestones__c>> ();
        ID  milestoneRecordtypeId = ParentMilestoneRecordType.Id;
        for(Project_Milestones__c milestone : [Select Id, Name,Parent__c,Project__c,Sub_Type__c,Type__c from Project_Milestones__c where project__c IN:records and RecordtypeId = :milestoneRecordtypeId ]){
        	if(projectMilestoneMap.containsKey(milestone.Project__c)){
        		projectMilestoneMap.get(milestone.Project__c).put(milestone.Name,milestone);
        	}else{
        		 Map<String, Project_Milestones__c> milestoneMap = new Map<String, Project_Milestones__c>();
        		 milestoneMap.put(milestone.Name,milestone);
        		projectMilestoneMap.put(milestone.Project__c,milestoneMap );
        	}
        }

        Utility_MapChain contentToMilestoneMap = new Utility_MapChain();
        Project_Milestones__c[] milestonesToInsert = new Project_Milestones__c[]{};
        for (Project__c project :records){
            Map<String, Project_Milestones__c> milestoneMap = projectMilestoneMap.get(project.id);
            if (milestoneTemplateMap.containsKey(project.program_version__c))            {
                for (Program_Content__c milestoneTemplate :milestoneTemplateMap.get(project.program_version__c)) {
                    Project_Milestones__c milestone = milestoneMap.get(milestoneTemplate.object_name__c);
                    contentToMilestoneMap.putData(new Id[]{project.Id,milestoneTemplate.Id},milestone);
                }
            }
        }


        Project_Deliverables__c[] deliverablesToInsert = new Project_Deliverables__c[]{};
        for (Project__c project :records)
        {
            if (milestoneTemplateMap.containsKey(project.program_version__c))
            {
                for (Program_Content__c parentMilestoneTemplate :milestoneTemplateMap.get(project.program_version__c))
                {
                    for(Program_Content__c templateRec :parentMilestoneTemplate.Program_Contents__r)
                    {
                    	 if(templateRec.recordTypeId == ProgramContent_Helper.DeliverableRecordType.Id)
                        {
                            Project_deliverables__c deliverable = new Project_deliverables__c();
                            deliverable.Project__c = project.Id;
                            deliverable.Name = templateRec.object_name__c;
                            deliverable.type__c = templateRec.type__c;
                            deliverable.sub_type__c = templateRec.sub_type__c;
                            deliverable.Mandatory_by_Default__c = templateRec.Mandatory_by_Default__c;
                            if (templateRec.Mandatory_by_Default__c)
                                deliverable.status__c = ProjectDeliverables_Helper.STATUS_SCHEDULED;
                            deliverable.Conditionally_Required__c = templateRec.Conditionally_Required__c;
                            deliverable.Sequence__c = String.valueOf(templateRec.Sequence__c);
                            deliverable.Validation_Logic__c = templateRec.Validation_Logic__c;
                            deliverable.Validation_Notes__c = templateRec.Validation_Notes__c;
                            deliverable.Project_Milestone__c = ((Project_Milestones__c) contentToMilestoneMap.getData(new Id[]{project.Id,parentMilestoneTemplate.Id})).Id;
                            deliverablesToInsert.add(deliverable);
                        }
                    }
                }
            }
        }

        if (deliverablesToInsert.size() > 0)
            insert deliverablesToInsert;
    }
}