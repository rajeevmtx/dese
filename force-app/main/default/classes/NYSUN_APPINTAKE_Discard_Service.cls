/*
*   Class Name: NYSUN_APPINTAKE_Discard_Service
*   Description: Discard service of NYSUN_AppIntake
*
*                                                             
*/
public without sharing class NYSUN_APPINTAKE_Discard_Service {
  
  /*
  * Method Name: discardChanges
  * Description: Delete the documents__c and project_templates__c associated with project on the basis of projectId
  * @param: String projectId
  * @return: boolean                                                       
  */
    public static Boolean discardChanges(String projectId){
        List<Project__c> projects = [Select Id, (Select Id FROM Documents__r),(Select id FROM Project_Templates__r) FROM Project__c WHERE ID =:projectId];
        List<SObject> sObjList = new List<SObject>();
        sObjList.addAll((List<sobject>)projects);
        
        for(Project__c project : projects){
            if(!project.Documents__r.isEmpty()){
                sObjList.addAll((List<sobject>)project.Documents__r);
            }
            
            if(!project.Project_Templates__r.isEmpty()){
                sObjList.addAll((List<sobject>)project.Project_Templates__r);
            }
        }
        
        if(sObjList.size() > 0){
            Database.delete(sObjList);
        }
        return true;
    }
    
    /*
  * Method Name: discardChangeMode
  * Description: Delete the document__c and Wizard_Template__c associated with case on the basis of caseId
  * @param: String caseId
  * @return: boolean                                                       
  */
    public static Boolean discardChangeMode(String caseId){
        List<Case> caseList = [Select Id, (Select Id FROM Project_Documents__r), (Select Id FROM Wizard_Templates__r) FROM Case WHERE Id =:caseId];
        List<SObject> sObjList = new List<SObject>();
        sObjList.addAll((List<sobject>)caseList);
        
        for(Case caseRec : caseList){
            if(!caseRec.Project_Documents__r.isEmpty()){
                sObjList.addAll((List<sobject>)caseRec.Project_Documents__r);
            }
            
            if(!caseRec.Wizard_Templates__r.isEmpty()){
                sObjList.addAll((List<sobject>)caseRec.Wizard_Templates__r);
            }
        }
        
        if(sObjList.size() > 0){
            Database.delete(sObjList);
        }
        return true;
    }
}