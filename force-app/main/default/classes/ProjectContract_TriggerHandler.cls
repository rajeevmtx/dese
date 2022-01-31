/*
* Class Name:  PProjectContract_TriggerHandler
* Description: Handler class ProjectContract_Trigger
* Author/Date: Ajay Gautam  08/07/2016 
*                                                            
*/

public without sharing class ProjectContract_TriggerHandler { // Without sharing to support Integration

    /*
	* Method Name: afterInsertUpdate
	* Description: Method to call the processing after Insert Update
	* @return:  void
	* @param:  List<Project_Contract__c> newContractList : list of Project Contract
	* @param:  Map<Id,Project_Contract__c> oldMapContract : map of Project contract
	*/

  public static void afterInsertUpdate(List<Project_Contract__c> newContractList, Map<Id,Project_Contract__c> oldMapContract) {
    updateProjectsAsReceivedForOpenApprovedContracts(newContractList,oldMapContract);
  }

    /*
	* Method Name: updateProjectsAsReceivedForOpenApprovedContracts
	* Description: update Projects As Received For Open Approved Contracts
	* @return:  void
	* @param:  List<Project_Contract__c> newContractList : list of project Contract
	* @param:  Map<Id,Project_Contract__c> oldMapContract : map of Project contract
	*/
  private static void updateProjectsAsReceivedForOpenApprovedContracts(List<Project_Contract__c> newContractList, Map<Id,Project_Contract__c> oldMapContract) {

    set<Id> projectIds = new set<Id>();
    for(Project_Contract__c objContract : newContractList){
        projectIds.add(objContract.Project__c);
    }

    map<Id,Project__c> projectIdToProjectMap = new map<Id,Project__c>([Select Id, RecordType.DeveloperName, Status__c from Project__c where Id IN: projectIds]);

    Boolean isInsert = Trigger.isInsert;
    Map<Id, Project__c> projectsToBeMarkedReceived = new Map<Id, Project__c>();
    for(Project_Contract__c objContract : newContractList) {
      if(objContract.Project__c != null && String.isNotBlank(objContract.NEIS_Contract_ID__c)
          && Project_Helper.SET_OF_PROJECT_RECORD_TYPE_DEV_NAME_WITH_RECEIVED_STATUS.contains(projectIdToProjectMap.get(objContract.Project__c).recordType.DeveloperName)
          && Project_Helper.PROJECT_STATUS_SUBMITTED.equalsIgnoreCase(projectIdToProjectMap.get(objContract.Project__c).Status__c)
          &&
          (isInsert ||
           (!isInsert &&
              (
               String.isBlank(oldMapContract.get(objContract.Id).NEIS_Contract_ID__c)
               )
            ))) {
        // Case: 00002528
        // Contract sync should update project status when project is in submitted status.
        projectsToBeMarkedReceived.put(objContract.Project__c, new Project__c(Id = objContract.Project__c, Status__c = Project_Helper.PROJECT_STATUS_RECEIVED)); // I-02008
      }
    }

    // Update NEIS_Contract_ID__c on Project from Project_Contract__c - S-00524 - TK
    for(Project_Contract__c objContract : newContractList) {
        if(objContract.Project__c != null && String.isNotBlank(objContract.NEIS_Contract_ID__c))
        {
            if(projectsToBeMarkedReceived.containsKey(objContract.Project__c)) {
                projectsToBeMarkedReceived.get(objContract.Project__c).NEIS_Contract_ID__c = objContract.NEIS_Contract_ID__c;
            } else {
                projectsToBeMarkedReceived.put(objContract.Project__c,
                        new Project__c(Id = objContract.Project__c, NEIS_Contract_ID__c = objContract.NEIS_Contract_ID__c));
            }
        }
    }

    if(projectsToBeMarkedReceived.size() > 0) {
      update projectsToBeMarkedReceived.values();
    }
  }

}