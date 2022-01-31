/*
* Class Name:  ProjectMilestones_TriggerHandler
* Description: Handler class for ProjectMilestones_Trigger to manage operations for Trigger
* Author/Date:  Ajay Gautam ,04/06/2017 
* Date          New/Modified          Author            Description
* 05/31/2017    Modified              Ajay Gautam       S-00799  Milestone approved notification to contractors
*/

public class ProjectMilestones_TriggerHandler {
	
	/*
	* Name : afterInsert
	* Description : method to process functionalities on after insert
	* @param : Project_Milestones__c[] newList
	* @return : void
	*/
    public static void afterInsert(Project_Milestones__c[] newList)
    {
        createReviewTasksForPMOnMilestones_Insert(newList); //T-00812
        rollUpIncentives(newList,null);
        sendMilestoneApprovedNotification(newList,null); // S-00799  Milestone approved notification to contractors
    }
	
	/*
	* Name : afterUpdate
	* Description : method to process functionalities on after update
	* @param : Project_Milestones__c[] newList
	* @param : Map<Id,Project_Milestones__c> oldMap
	* @return : void
	*/
	
    public static void afterUpdate(Project_Milestones__c[] newList, Map<Id,Project_Milestones__c> oldMap)
    {
        rollUpIncentives(newList,oldMap);
        sendMilestoneApprovedNotification(newList,oldMap); // S-00799  Milestone approved notification to contractors
    }
	/*
	* Name : afterDelete
	* Description : method to process functionalities on after delete
	* @param : Project_Milestones__c[] oldList
	* @return : void
	*/
	
    public static void afterDelete(Project_Milestones__c[] oldList)
    {
        rollUpIncentives(oldList,null);
    }
	
	/*
	* Name : afterUndelete
	* Description : method to process functionalities on after Undelete
	* @param : Project_Milestones__c[] newList
	* @return : void
	*/
	
    public static void afterUndelete(Project_Milestones__c[] newList)
    {
        rollUpIncentives(newList,null);
    }
	
	/*
	* Name : rollUpIncentives
	* Description : Method to roll Up Incentives
	* @param : Project_Milestones__c[] records
	* @param : Map<Id,Project_Milestones__c> oldMap
	* @return : void
	*/
	
    public static void rollUpIncentives(Project_Milestones__c[] records, Map<Id,Project_Milestones__c> oldMap)
    {
        Utility_RollUp_Helper.rollUpNumerics(records,oldMap,'Project_Milestones__c',new String[]{'Incentive_Amount__c', 'Total_Cost__c', 'Cost_Share__c', 'Total_NYSERDA_Payment__c', 'Billed_To_Date__c', 'Billed_To_Date_Cost_Share__c'},'parent__c');
    }
	
	/*
	* Name : createReviewTasksForPMOnMilestones_Insert
	* Description : create Review Tasks For Project Manager On Milestones - Ajay (T-00812) - i) Add recordType Filter
	* @param : List<Project_Milestones__c> newMilestones
	* @return : void
	*/

    private static void createReviewTasksForPMOnMilestones_Insert(List<Project_Milestones__c> newMilestones) {
        Set<Id> settOfProjectIds = new Set<Id>();
        for(Project_Milestones__c milestones : newMilestones){
            settOfProjectIds.add(milestones.Project__c);
        }
        if(settOfProjectIds != null && settOfProjectIds.size()>0) {

          Id rtemProjectRecordTypeId = null;
          Set<Id> projectIds_RTEM_ONLY = new Set<Id>();
          RecordType rcdType_RTEM = Utility_RecordType_Helper.getRecordType('Project__c','Commercial_Real_Time_Energy_Management');
          if(rcdType_RTEM != null) {
            rtemProjectRecordTypeId = rcdType_RTEM.Id;
          }
          if(rtemProjectRecordTypeId != null) {
              for(Project__c objProj : [SELECT  Id
                                        FROM    Project__c
                                        WHERE   Id IN :settOfProjectIds
                                        AND     RecordTypeId = :rtemProjectRecordTypeId]) {
                 projectIds_RTEM_ONLY.add(objProj.id);
              }
          }
          if(projectIds_RTEM_ONLY.size() > 0) {
            createReviewTask(newMilestones, projectIds_RTEM_ONLY);
          }
        }
    }
	
	/*
	* Name : createReviewTask
	* Description : create task for project to review . Cannot be done through workflow
	* @param : List<Project_Milestones__c> newMilestones
	* @param : Set<Id> listOfProjectIds
	* @return : void
	*/
    
    private static void createReviewTask(List<Project_Milestones__c> newMilestones, Set<Id> listOfProjectIds){

        Map<String,Project_Role__c> mapProjectToRoleContactId =  getMapOfProjectWithRole(listOfProjectIds,new List<String>{ProjectRole_Helper.PROJECT_MANAGER_ROLE});
        List<Task> listOfTaskToInsert = new List<Task>();
        for(Project_Milestones__c milestones : newMilestones){
            if(mapProjectToRoleContactId != null && mapProjectToRoleContactId.containsKey(milestones.Project__c+ProjectRole_Helper.PROJECT_MANAGER_ROLE)  && mapProjectToRoleContactId.get(milestones.Project__c+ProjectRole_Helper.PROJECT_MANAGER_ROLE).contact__c !=  null){
                Task reviewTask = new Task();
                reviewTask.WhatId = milestones.id;
                reviewTask.whoId = mapProjectToRoleContactId.get(milestones.Project__c+ProjectRole_Helper.PROJECT_MANAGER_ROLE).contact__c;
                reviewTask.Subject = 'Review Deliverable: '+ milestones.Name;
              //  reviewTask.Type = Label.Real_Time_Energy_Management_Project_Deli_Submission_ProjMgr_Task_Type; //'Review';
              //  reviewTask.priority= Label.Real_Time_Energy_Management_Project_Deli_Submission_ProjMagr_Task_Priority;
              //  reviewTask.status = Label.Real_Time_Energy_Management_Project_Deli_Submission_ProjMgr_Task_Status;// 'Not Started';
              //  reviewTask.description = Label.Real_Time_Energy_Management_Project_Deliv_Submission_ProjMgr_Task_Description;
                listOfTaskToInsert.add(reviewTask);
            }
        }
        if(listOfTaskToInsert.size()>0) {
            insert listOfTaskToInsert;
        }
    }

	/*
	* Name : getMapOfProjectWithRole
	* Description : return a map of project with its given role name record
	* @param : List<String> ListOfRoleNames
	* @param : Set<Id> listOfProjectId
	* @return : Map<String,Project_Role__c>
	*/
	
    public static Map<String,Project_Role__c> getMapOfProjectWithRole(Set<Id> listOfProjectId,List<String> ListOfRoleNames){
        Map<String,Project_Role__c> mapProjectToRoleId = new Map<String,Project_Role__c>();
        if(listOfProjectId != null && listOfProjectId.size()>0 && ListOfRoleNames != null && ListOfRoleNames.size()>0){
            for(Project__c project : [select id,(select id,Contact__c,Role__c,Email__c from Project_Roles__r where Role__c IN : ListOfRoleNames) from Project__c where Id IN : listOfProjectId]){
                if(project.Project_Roles__r != null && project.Project_Roles__r.size()>0){
                    for(Project_Role__c role : project.Project_Roles__r){
                        mapProjectToRoleId.put(project.Id+role.Role__c,role);
                    }
                }
            }
        }
        return mapProjectToRoleId;
    }


    /*
    * Method Name: sendMilestoneApprovedNotification
    * Description: Send milestone approved notification. S-00799/I-02972
    * @param : List<Project_Milestones__c> newMilestoneList
    * @param : Map<Id,Project_Milestones__c> oldMapMilestones
    * @return : void
    */
    public static void sendMilestoneApprovedNotification(List<Project_Milestones__c> newMilestoneList, Map<Id,Project_Milestones__c> oldMapMilestones) {

      Project_Milestones__c objMilestoneTemp = null;
      Set<Id> projectIds = new Set<Id>();
      Map<Id, Project_Milestones__c> eligibleMilestones = new Map<Id,Project_Milestones__c>();
      Map<Id, List<String>> projIdtoRoleEmailMap = new Map<Id, List<String>>();
      List<Project_Milestones__c> approvedMilestones = new List<Project_Milestones__c>();
      List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
      List<Task> taskList = new List<Task>();

      for(Project_Milestones__c objMilestone : newMilestoneList) {

        if(ProjectMilestones_Helper.STATUS_APPROVED.equalsIgnoreCase(objMilestone.Status__c)
           && objMilestone.Parent__c != null
           && objMilestone.Project__c != null
           && objMilestone.RecordTypeId == CORE_Deliverables_Helper.ChildMilestone.id
           && (Trigger.isInsert || (!Trigger.isInsert && oldMapMilestones != null &&
                                     oldMapMilestones.get(objMilestone.Id) != null &&
                                     oldMapMilestones.get(objMilestone.Id).Status__c != objMilestone.Status__c))
           ) {

            approvedMilestones.add(objMilestone);
        }

      }

      if(approvedMilestones.size() > 0) {
          eligibleMilestones = new Map<Id,Project_Milestones__c>([    SELECT  Id, Name, Parent__c,
                                                                              Project__r.Contractor_to_Create_Invoices__c
                                                                      FROM    Project_Milestones__c
                                                                      WHERE   Id IN :approvedMilestones
                                                                   // AND     Project__r.RecordTypeId IN :Clean_Transportation_Helper.INNOVATION_PROJECT_RECORD_TYPE_ID_SET
                                                                      AND     Project__r.Turn_off_contractors_notifications__c = false
                                                                      AND     Project__r.Budget_Type__c = :CORE_Deliverables_Helper.CONST_MILESTONE]);


          if(eligibleMilestones.size() > 0) {

            for(Project_Milestones__c obj : eligibleMilestones.values()) {
              projectIds.add(obj.Project__c);
            }

            List<EmailTemplate> emailTemplateList = [SELECT Name, Id, DeveloperName
                                                       FROM EmailTemplate
                                                      WHERE DeveloperName = 'Core_Project_Milestone_Approved_Notification'];

            for(Project_Role__c role : [SELECT Id, Email__c, project__c
                                          FROM Project_Role__c
                                         WHERE Role__c IN: new Set<String>{ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE}
                                           AND project__c IN: projectIds]) {
              if(!projIdtoRoleEmailMap.containsKey(role.project__c)) {
                projIdtoRoleEmailMap.put(role.project__c, new List<String>());
              }
              projIdtoRoleEmailMap.get(role.project__c).add(role.Email__c);
            }


            if(emailTemplateList.size() > 0) {

              for(Id milestoneId : eligibleMilestones.keySet()) {

                objMilestoneTemp = eligibleMilestones.get(milestoneId);

                if(projIdtoRoleEmailMap.containsKey(objMilestoneTemp.Project__c)) {
                  String templateBody = '';
                  Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id, null, objMilestoneTemp.Id); // Object Must have 'Allow Activities' ON.
                  Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                      mailToBeSent.setSubject(newEmail.subject);
                      templateBody = newEmail.plainTextBody;

                      if(templateBody.contains('[ConditionalTextContractorToCreateInvoices]')) {
                        if(objMilestoneTemp.Project__r.Contractor_to_Create_Invoices__c) {
                          templateBody = templateBody.replace('[ConditionalTextContractorToCreateInvoices]', '\n\n' + System.Label.CORE_Contractor_to_Create_Invoice_for_Milestone_Proj_Msg);
                        } else {
                          templateBody = templateBody.replace('[ConditionalTextContractorToCreateInvoices]', '');
                        }
                      }

                      newEmail.plainTextBody = templateBody;
                      mailToBeSent.setHtmlBody(newEmail.htmlBody);
                      mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                      mailToBeSent.setToAddresses(projIdtoRoleEmailMap.get(objMilestoneTemp.Project__c));
                      emailList.add(mailToBeSent);
                   // taskList.add(CORE_EmailNotificationUtil.createActivityHistory(mailToBeSent,objMilestoneTemp.Project__c));
                }
              }
            }
            if(emailList.size()>0) {
              emailList = CORE_Helper.setOrgWideEmailAddress_CORE(emailList);
              Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailList,false);
              System.debug('>>> emailResults = '+ emailResults);
            }
            if(taskList.size() > 0) {
              insert taskList;
            }
          }
      }

    }



}