/*
*   Class Name: ProposalScore_TriggerHandler
*   Description: Class used as helper for ProposalScore trigger
*

*/

public with sharing class ProposalScore_TriggerHandler {
  //Variable to be used as part of task T-02849
  public static final String LINE_BREAK = '';

   /*
   * Method Name: afterInsertUpdate
   * Description: calling To update concept paper and proposal score records
   * @param: list<Proposal_Score__c> newList
   * @param: Map<Id, Proposal_Score__c> oldMap
   * @return: void
   */
    public static void afterInsertUpdate(list<Proposal_Score__c> newList,
                                         Map<Id, Proposal_Score__c> oldMap) {
        
        //update concept paper result on the basis of project
        updateConceptPaperResult(newList);
        
        //update the strength and weakness on parent project from proposal score records
        rollupStrengthsWeaknessesToProject(newList, oldMap);
    }

    /*
  * Method Name: rollupStrengthsWeaknessesToProject
  * Description: To update project with Strengths and Weaknesses
  * @param: List<Proposal_Score__c> newList
  * @param: Map<Id, Proposal_Score__c> oldMap
  * @return: void
  */
    public static void rollupStrengthsWeaknessesToProject(List<Proposal_Score__c> newList ,
                                                          Map<Id, Proposal_Score__c> oldMap){
    
    //Map collections to store the strengths and weaknesses projectwise 
        Map<Id, List<String>> projectIdStrengthsMap = new Map<Id, List<String>>();
        Map<Id, List<String>> projectIdWeaknessesMap = new Map<Id, List<String>>();
    
    //populte projectIdStrengthsMap and projectIdWeaknessesMap with strength and weakness for respective projects
        for(Proposal_Score__c proposalScore : newList){

            if(proposalScore.Strengths__c != null &&
               ((oldMap == null)
               || (oldMap != null && proposalScore.Strengths__c !=
                   oldMap.get(proposalScore.Id).Strengths__c))){

                if(!projectIdStrengthsMap.containsKey(proposalScore.Proposal__c)){
                    projectIdStrengthsMap.put(proposalScore.Proposal__c, new List<String>());
                }

                projectIdStrengthsMap.get(proposalScore.Proposal__c).add(proposalScore.Strengths__c);
            }

            if(proposalScore.Weaknesses__c != null &&
               ((oldMap == null)
               || (oldMap != null && proposalScore.Weaknesses__c !=
                   oldMap.get(proposalScore.Id).Weaknesses__c))){

                if(!projectIdWeaknessesMap.containsKey(proposalScore.Proposal__c)){
                    projectIdWeaknessesMap.put(proposalScore.Proposal__c, new List<String>());
                }

                projectIdWeaknessesMap.get(proposalScore.Proposal__c).add(proposalScore.Weaknesses__c);
            }
        }
    
    //list to update the project strength and weakness fields
        List<Project__c> projectsToUpdate = new List<Project__c>();

    //logic to update/append strength and weakness for each project
        for(Project__c project : [SELECT Id, Proposal_Strengths__c, Proposal_Weaknesses__c
                                  FROM Project__c WHERE Id IN : projectIdStrengthsMap.keySet()
                                  OR Id IN : projectIdWeaknessesMap.keySet()]){

            if(projectIdStrengthsMap.containsKey(project.Id)
               && projectIdStrengthsMap.get(project.Id) != null){

                for(String strength : projectIdStrengthsMap.get(project.Id)){
                    if(project.Proposal_Strengths__c != null){
                        project.Proposal_Strengths__c += strength; // ' <br/>' + strength;
                    }else{
                        project.Proposal_Strengths__c = strength;
                    }
          
          //Crop the Strength if too large
                    if(project.Proposal_Strengths__c.length() > 131072){
                        project.Proposal_Strengths__c.subString(0, 131071);
                    }
                }
            }

            if(projectIdWeaknessesMap.containsKey(project.Id)
               && projectIdWeaknessesMap.get(project.Id) != null){

                for(String weakness : projectIdWeaknessesMap.get(project.Id)){
                    if(project.Proposal_Weaknesses__c != null){
                        project.Proposal_Weaknesses__c += weakness;
                    }else{
                        project.Proposal_Weaknesses__c = weakness;
                    }
          
          //Crop the Weakness if too large
                    if(project.Proposal_Weaknesses__c.length() > 131072){
                        project.Proposal_Weaknesses__c.subString(0, 131071);
                    }
                }
            }

            projectsToUpdate.add(project);
        }
    
    //update projects' strengths and weaknesses
        if(projectsToUpdate.size() > 0){
            update projectsToUpdate;
        }
    }

    // To be invoked from Project Trigger
    public static Set<Id> projectIds_ProcessedForResult = new Set<Id>(); // Recursion Safe

   /*
    * Method Name: updateConceptPaperResultFromProject
    * Description: To update concept paper result from project
    * @param: list<Project__c> newList
    * @param: Map<Id,Project__c> oldMap
    * @return: void
   */
    public static void updateConceptPaperResultFromProject(list<Project__c> newList , Map<Id,Project__c> oldMap) {
    //Populate a set of project Ids for which Recalculate_Score__c is checked
        set<Id> proposalIds =new Set<Id>();
        for(Project__c project : newList) {
            if(!projectIds_ProcessedForResult.contains(project.Id) &&
                    ((Trigger.isInsert && project.Recalculate_Score__c ) ||
                    (Trigger.isUpdate && project.Recalculate_Score__c && !(oldMap.get(project.Id).Recalculate_Score__c)))
                ) {
                projectIds_ProcessedForResult.add(project.Id);
                proposalIds.add(project.Id);
            }
        }

        if(proposalIds.size()>0) {
          //calculate average result for all proposals/projects for which Recalculate_Score__c is checked
            calculateAverageResult(proposalIds);
        }
    }

   /*
    * Method Name: updateConceptPaperResult
    * Description: To update concept paper result
    * @param: list<Proposal_Score__c> newList
    * @return: void
   */
    public static void updateConceptPaperResult(list<Proposal_Score__c> newList) {
        Set<Id> proposalIds = new Set<Id>();

        for(Proposal_Score__c proposalScore : newList) {
            proposalIds.add(proposalScore.Proposal__c);
        }

        if(proposalIds.size()>0) {
          //calculate average result for all proposals/projects those Id is in proposalIds
            calculateAverageResult(proposalIds);
        }

    }

   /*
    * Method Name: calculateAverageResult
    * Description: Calculate average result on the basis of proposalIds
    * @param: Set<Id> proposalIds
    * @return: void
   */
   public static void calculateAverageResult(Set<Id> proposalIds){
        //variable to be used in average result calculation
        Integer totalProposal;
        Integer passScore;
        Decimal totalScore;
        Integer totalRecuse;

        List<Project__c> proposalUpdateList = new List<Project__c>();
        Map<Id, Map<Id,Solicitation_Review_Team__c>> solicitationWiseScoringComitteeMap = new Map<Id, Map<Id,Solicitation_Review_Team__c>>();
        set<Id> solicitationIds =new Set<Id>();
    
    //Fetch all projects and proposal scores on the basis of proposalIds set
        List<Project__c> projectList = new List<Project__c> ([SELECT Concept_Paper_Result__c, program_Version__c, Total_Committee_Members__c,
                                                                     Recalculate_Score__c,Total_Group_Members__c, Concept_Paper__c,
                                                                     program_Version__r.Concept_Paper_Pass_Score__c,
                                                                     program_Version__r.Proposal_Threshold__c,Proposal__c,
                                                                     program_Version__r.Score_Type__c,Solicitation_Round__c,
                                                                     (SELECT Score__c,CreatedById,Recuse__c from Proposal_Scores__r )
                                                              FROM Project__c 
                                                              WHERE Id IN: proposalIds]);


        // get solicitation IDs
        for(Project__c project : projectList) {
            solicitationIds.add(project.program_Version__c);
            system.debug('line 62----'+project.program_Version__c);
        }
    
    //logic to calculate average score
        for(Project__c project : projectList) {

          totalProposal = 0;
          passScore = 0;
          totalScore = 0;
          totalRecuse = 0;
          Decimal averageMajority;
          Decimal averageScore ;
      
      
          for(Proposal_Score__c proposalScore : project.Proposal_Scores__r) {
              if(!proposalScore.Recuse__c) {
                if((project.Concept_Paper__c && (proposalScore.Score__c >= project.program_Version__r.Concept_Paper_Pass_Score__c))
                      || (project.Proposal__c && (proposalScore.Score__c >= project.program_Version__r.Proposal_Threshold__c)) ) {
                      PassScore++;
                      totalProposal++;
                      totalScore += proposalScore.Score__c;
                  } else {
                      totalProposal++;
                      totalScore += proposalScore.Score__c;
                  }
              } else {
                totalRecuse++;
              }
           }


           if(totalScore != 0){
             averageMajority = ((passScore * 100) / totalProposal); // 75
             averageScore = totalScore / totalProposal; // 82.5
           }

        if((project.Recalculate_Score__c
            || ((project.program_Version__r.Score_Type__c == Solicitation_Helper.SUM_OF_RANK_SCORE_TYPE || String.isBlank(project.program_Version__r.Score_Type__c)) && totalProposal >= (project.Total_Committee_Members__c - totalRecuse))
            || (project.program_Version__r.Score_Type__c == Solicitation_Helper.BATCH_RANK_SCORE_TYPE && totalProposal >= (project.Total_Group_Members__c - totalRecuse)))
            && totalProposal != 0) {

                    // T-02026: If the concept paper average score is exactly equal to the concept paper pass score, the concept paper result should be PASS.
                    if((project.Concept_Paper__c && (averageScore >= project.program_Version__r.Concept_Paper_Pass_Score__c))
                        || (project.Proposal__c && (averageScore >= project.program_Version__r.Proposal_Threshold__c))) {

                            if(averageMajority >= 50) {
                              if(project.Proposal__c) {
                                project.Proposal_Result__c = Project_Helper.CONCEPT_RESULT_PASS;
                              } else if(project.Concept_Paper__c) {
                                project.Concept_Paper_Result__c = Project_Helper.CONCEPT_RESULT_PASS;
                              }
                                project.Proposal_Average_Score__c = averageScore;
                                proposalUpdateList.add(project);
                            } else if(averageMajority < 50){
                              if(project.Proposal__c) {
                                project.Proposal_Result__c = Project_Helper.CONCEPT_RESULT_FAIL;
                              } else if(project.Concept_Paper__c) {
                                project.Concept_Paper_Result__c = Project_Helper.CONCEPT_RESULT_FAIL;
                              }
                                project.Proposal_Average_Score__c = averageScore;
                                proposalUpdateList.add(project);
                            }
                        }

                    else {
                          if(project.Proposal__c) {
                                project.Proposal_Result__c = Project_Helper.CONCEPT_RESULT_FAIL;
                              } else if(project.Concept_Paper__c) {
                                project.Concept_Paper_Result__c = Project_Helper.CONCEPT_RESULT_FAIL;
                              }
                                project.Proposal_Average_Score__c = averageScore;
                                proposalUpdateList.add(project);

                         }


                    // T-03151
                    if(project.Recalculate_Score__c) {
                        project.Finalize_Result__c = true;
                        project.Finalize_Score_Date__c = system.now();
                    }
                    // T-03151

                    // Commented by TK - 09/07/2017 - T-03151
                    /*
                    if(((project.program_Version__r.Score_Type__c == Solicitation_Helper.SUM_OF_RANK_SCORE_TYPE
                         || String.isBlank(project.program_Version__r.Score_Type__c))
                         && totalProposal == (project.Total_Committee_Members__c - totalRecuse)) || project.Recalculate_Score__c) {
                        project.Finalize_Result__c = true;
                        project.Finalize_Score_Date__c = system.now();
                    }

                    if((project.program_Version__r.Score_Type__c == Solicitation_Helper.BATCH_RANK_SCORE_TYPE
                        && totalProposal == (project.Total_Group_Members__c - totalRecuse)) || project.Recalculate_Score__c) {
                        project.Finalize_Result__c = true;
                        project.Finalize_Score_Date__c = system.now();
                    }
                    */
             } else {
                project.Proposal_Average_Score__c = averageScore;
                proposalUpdateList.add(project);
             }
       }

       if(proposalUpdateList.size() > 0){
           update proposalUpdateList;
       }
    }
}