/*
* Class Name:  ProjectContract_TriggerHandler
* Description: Handler class for ProjectDeliverable_Trigger to manage operations for Trigger
*
*/

public without sharing class ProjectDeliverable_TriggerHandler {

  /*
  * Method Name: afterInsertUpdate
  * Description: Method to call the processing after Insert Update
  * @return:  void
  * @param:  List<Project_Deliverables__c> newDeliverables : list of Project Deliverables
  * @param:  Map<Id,Project_Deliverables__c> oldMapDeliverables : map of Project Deliverables
  */
  public static final String RTEM_PROJECT_MANAGER_ROLE = 'Project Manager';

  public static void afterInsertUpdate(List<Project_Deliverables__c> newDeliverableList, Map<Id,Project_Deliverables__c> oldMapDeliverables) {
    Solicitation_Notification_Service.sendFinalProposalDeliverableSubmissionAlertToPM(newDeliverableList,oldMapDeliverables); // T-02229
    Solicitation_Notification_Service.sendFinalProposalDeliverableApprovalButIncompleteMemoAlertToPM(newDeliverableList,oldMapDeliverables); // T-02229
    sendDeliverableApprovedNotification(newDeliverableList,oldMapDeliverables); // S-00799  Deliverable approved notification to contractors
    sendDeliverableExternalReviewNotification(newDeliverableList,oldMapDeliverables); // Deliverable External Review Notification to External Implementation Contractor
  }



  /*
  * Method Name: afterInsert
  * Description: Method to call the processing after Insert
  * @return:  void
  * @param:  List<Project_Deliverables__c> newDeliverables : list of Project Deliverables
  */

  public static void afterInsert(List<Project_Deliverables__c> newDeliverables){
    createReviewTasksForPMOnDeliverables_Insert(newDeliverables); //T-00812
  }


    /*
  * Method Name: beforeInsert
  * Description: Method to call the processing before Insert :  Original [ Case #: 00008959 ]
  * @return:  void
  * @param:  List<Project_Deliverables__c> newDeliverables : list of Project Deliverables
  */

  public static void beforeInsert(List<Project_Deliverables__c> newDeliverables){
    insertContractorEmailToProjectDeliverables(newDeliverables);
  }


    /*
    * Method Name: insertContractorEmailToProjectDeliverables
    * Description: Inserts Contractor Email ID to the Custom Field which is used to send the email notification to the shared service group and Contractor. BY Kannan 08/04/2017
    * @return:  void
    * @param : List<Project_Deliverables__c> newDeliverables
    */
    public static void insertContractorEmailToProjectDeliverables(List<Project_Deliverables__c> newDeliverables) {
         Set<Id> settOfProjectIds = new Set<Id>();

         for(Project_Deliverables__c deliverable : newDeliverables){
            settOfProjectIds.add(deliverable.Project__c);
        }


          Map<Id, Project__c> projectEntries = new Map<Id, Project__c>(
              [select id,Primary_Contractor_Email_Hidden__c from Project__c where id in :settOfProjectIds]);

          for (Project_Deliverables__c deliverable : newDeliverables) {
              Project__c project = projectEntries.get(deliverable.Project__c);

              if (project != null) {
                  deliverable.Contractor_Email__c =project.Primary_Contractor_Email_Hidden__c  ;
              }
           }
    }

  /*
  * Method Name: createReviewTasksForPMOnDeliverables_Insert
  * Description: create Review Tasks For PM On Deliverables_Insert
  *        Update: 05/10/2016 - Ajay (T-00812) - i) Add recordType Filter, ii) code cleanup
  * @return:  void
  * @param:  List<Project_Deliverables__c> newDeliverables : list of Project Deliverables
  */


    private static void createReviewTasksForPMOnDeliverables_Insert(List<Project_Deliverables__c> newDeliverables) {
        Set<Id> settOfProjectIds = new Set<Id>();
        for(Project_Deliverables__c deliverable : newDeliverables){
            settOfProjectIds.add(deliverable.Project__c);
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


        }
    }


  /*
  * Method Name: getMapOfProjectWithRole
  * Description: return a map of project with its given role name record
  * @return:  void
  * @param : ListOfRoleNames : list of names of role for which you want the map to Project
    * @param : listOfProjectId : Set of project ids to get role Id
    * @return : Map<strin,Id> : project Id + 'role'-> role record
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
    * Method Name: sendDeliverableExternalReviewNotification
    * Description: Send Deliverable External Review Notification to External Implementation Contractor
    * @param : List<Project_Deliverables__c> newDeliverableList
    * @param : Map<Id,Project_Deliverables__c> oldMapDeliverables
    * @return : void
    */
  public static void sendDeliverableExternalReviewNotification(List<Project_Deliverables__c> newList, Map<Id, Project_Deliverables__c> oldMap) {
    Set<Id> projectIdSet = new Set<Id>();
    for(Project_Deliverables__c deliverableRec : newList) {
      if(Trigger.isInsert && deliverableRec.External_Review_Required__c ||
          (Trigger.isUpdate && deliverableRec.External_Review_Required__c && !oldMap.get(deliverableRec.Id).External_Review_Required__c)) {
        projectIdSet.add(deliverableRec.Project__c);
      }
    }
    projectIdSet.remove(null);
    if(projectIdSet.size() == 0) {
      return;
    }

    List<Project__c> projectList = [SELECT Id, (SELECT Email__c, FirstName__c, LastName__c, Project__r.Application_Number__c FROM Project_Roles__r
                           WHERE Role__c =: ProjectRole_Helper.PROJECT_EXTERNAL_IMPLEMENTATION_CONTRACTOR_ROLE)
                      FROM Project__c WHERE Id IN: projectIdSet];
    Map<Id, List<Project_Role__c>> projectIdToProjectRoleListMap = new Map<Id, List<Project_Role__c>>();
    for(Project__c projectRec : projectList) {
      for(Project_Role__c projectRoleRec : projectRec.Project_Roles__r) {
        if(!projectIdToProjectRoleListMap.containsKey(projectRec.Id)) {
          projectIdToProjectRoleListMap.put(projectRec.Id, new List<Project_Role__c>{});
        }
        projectIdToProjectRoleListMap.get(projectRec.Id).add(projectRoleRec);
      }
    }

    List<EmailTemplate> emailTemplateList = [SELECT Name, DeveloperName FROM EmailTemplate
                                                            WHERE DeveloperName = 'Core_Deliverable_External_Review'];
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Task> taskList = new List<Task>();
    if(emailTemplateList.size() > 0) {
      for(Id projectId : projectIdToProjectRoleListMap.keySet()) {
        for(Project_Role__c projectRoleRec : projectIdToProjectRoleListMap.get(projectId)) {
          String templateBody = '';
                Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id, null, projectId);
                templateBody = newEmail.plainTextBody;
                if(templateBody.contains('<FirstName>')) {
                    templateBody = templateBody.replace('<FirstName>', projectRoleRec.FirstName__c);
                }
                if(templateBody.contains('<LastName>')) {
                    templateBody = templateBody.replace('<LastName>', projectRoleRec.LastName__c);
                }
                if(templateBody.contains('<ProjectID>')) {
                    templateBody = templateBody.replace('<ProjectID>', projectId);
                }
                newEmail.plainTextBody = templateBody;

                if(String.isNotBlank(newEmail.subject) && newEmail.subject.contains('<ApplicationNumber>')) {
                    newEmail.subject = newEmail.subject.replace('<ApplicationNumber>', projectRoleRec.Project__r.Application_Number__c);
                }

                Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                mailToBeSent.setSubject(newEmail.subject);
                mailToBeSent.setHtmlBody(newEmail.htmlBody);
                    mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                    mailToBeSent.setToAddresses(new List<String>{projectRoleRec.Email__c});
                    emailList.add(mailToBeSent);
                    //taskList.add(CORE_EmailNotificationUtil.createActivityHistory(mailToBeSent, projectId));
        }
      }

      if(emailList.size() > 0) {
              emailList = CORE_Helper.setOrgWideEmailAddress_CORE(emailList);
                Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailList, false);
                System.debug('>>> emailResults = '+ emailResults);
            }
            if(taskList.size() > 0) {
                insert taskList;
            }
    }
  }


    /*
    * Method Name: sendDeliverableApprovedNotification
    * Description: Send deliverable approved notification. S-00799
    * @return:  void
    * @param : List<Project_Deliverables__c> newDeliverableList
    * @param : Map<Id,Project_Deliverables__c> oldMapDeliverables
    * @return : void
    */
    public static void sendDeliverableApprovedNotification(List<Project_Deliverables__c> newDeliverableList, Map<Id,Project_Deliverables__c> oldMapDeliverables) {

      Project_Deliverables__c objDeliverableTemp = null;
      Set<Id> projectIds = new Set<Id>();
      Map<Id, Project_Deliverables__c> eligibleDeliverables = new Map<Id,Project_Deliverables__c>();
      Map<Id, List<String>> projIdtoRoleEmailMap = new Map<Id, List<String>>();
      List<Project_Deliverables__c> approvedDeliverables = new List<Project_Deliverables__c>();
      List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
      List<Task> taskList = new List<Task>();

      for(Project_Deliverables__c objDeliverable : newDeliverableList) {

        if(ProjectDeliverables_Helper.STATUS_APPROVED.equalsIgnoreCase(objDeliverable.Status__c)
           && objDeliverable.Project_Milestone__c != null
           && objDeliverable.Project__c != null
           && (Trigger.isInsert || (!Trigger.isInsert && oldMapDeliverables != null &&
                                     oldMapDeliverables.get(objDeliverable.Id) != null &&
                                     oldMapDeliverables.get(objDeliverable.Id).Status__c != objDeliverable.Status__c))
           ) {

            approvedDeliverables.add(objDeliverable);
        }

      }

      if(approvedDeliverables.size() > 0) {
          eligibleDeliverables = new Map<Id,Project_Deliverables__c>([SELECT  Id, Project_Milestone__r.name, Project_Milestone__c, Project__c,
                                                                              Project__r.Contractor_to_Create_Invoices__c,
                                                                              (SELECT Id, Name, version__c,Project_Deliverables__r.Project__c
                                                                               FROM   Project_Documents__r ORDER BY CreatedDate DESC LIMIT 1)
                                                                      FROM    Project_Deliverables__c
                                                                      WHERE   Id IN :approvedDeliverables
                                                                      AND     Project__r.RecordTypeId IN :Clean_Transportation_Helper.INNOVATION_PROJECT_RECORD_TYPE_ID_SET
                                                                      AND     Project__r.Turn_off_contractors_notifications__c = false]);


          if(eligibleDeliverables.size() > 0) {

            for(Project_Deliverables__c obj : eligibleDeliverables.values()) {
              projectIds.add(obj.Project__c);
            }

            List<EmailTemplate> emailTemplateList = [SELECT Name, Id, DeveloperName
                                                       FROM EmailTemplate
                                                      WHERE DeveloperName = 'Clean_Transportation_Deliverable_Approved'];

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

              for(Id deliverableId : eligibleDeliverables.keySet()) {

                objDeliverableTemp = eligibleDeliverables.get(deliverableId);

                for(Project_Document__c document : objDeliverableTemp.Project_Documents__r) {

                  if(projIdtoRoleEmailMap.containsKey(objDeliverableTemp.Project__c)) {
                    String templateBody = '';
                    Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id, null, objDeliverableTemp.Project__c); // Object Must have 'Allow Activities' ON.
                    Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                        mailToBeSent.setSubject(newEmail.subject);
                        templateBody = newEmail.plainTextBody;
                        if(templateBody.contains('[TaskName]')) {
                          templateBody = templateBody.replace('[TaskName]', objDeliverableTemp.Project_Milestone__r.name);
                        }

                        if(templateBody.contains('[FileName]')) {
                          templateBody = templateBody.replace('[FileName]',document.Name);
                        }

                        if(templateBody.contains('[Version]')) {
                          templateBody = templateBody.replace('[Version]',((document.version__c == 1) ? 'New Version' : 'Updated Version'));
                        }
                        if(templateBody.contains('[taskId]')) {
                          templateBody = templateBody.replace('[taskId]',objDeliverableTemp.Project_Milestone__c);
                        }

                        newEmail.plainTextBody = templateBody;
                        mailToBeSent.setHtmlBody(newEmail.htmlBody);
                        mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                        mailToBeSent.setToAddresses(projIdtoRoleEmailMap.get(objDeliverableTemp.Project__c));
                        emailList.add(mailToBeSent);
                        //taskList.add(CORE_EmailNotificationUtil.createActivityHistory(mailToBeSent,objDeliverableTemp.Project__c));
                  }
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