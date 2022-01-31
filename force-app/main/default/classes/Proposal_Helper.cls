/*
* Class Name: Proposal_Helper 
* Description: Helper class for Proposal classes   
* Author/Date: Tarun Khandelwal   1/22/2017 
*                                                              
*/

public with sharing class Proposal_Helper {

    public static final String PROPOSAL_PROGRAM_CONTENT_RECORD_TYPE_DEVELOPER_NAME = 'Proposal';
    public static final String PROPOSAL_PROJECT_CONTENT_RECORD_TYPE_DEVELOPER_NAME = 'Proposal';

    public static final Set<String> STATUS_FOR_EXISTING_CONCEPT_PAPER_PROJECTS = new Set<String> {
                                                                         Project_Helper.PROJECT_STATUS_UNSUBMITTED,
                                                                         Project_Helper.PROJECT_STATUS_SUBMITTED
                                                                         };
 
  public static final Set<String> STATUS_FOR_EXISTING_PROPOSAL_PROJECTS = new Set<String> {
                                                                       Project_Helper.PROJECT_STATUS_UNSUBMITTED,
                                                                       Project_Helper.PROJECT_STATUS_SUBMITTED
                                                                       };

}