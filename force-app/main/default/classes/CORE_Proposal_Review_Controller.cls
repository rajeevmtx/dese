/*
*   Class Name: CORE_Proposal_Review_Controller
*   Description: Class for CORE_Proposal_Review_Page S-00354
*
*/

public with sharing class CORE_Proposal_Review_Controller {

    // CONSTANT Declaration
    public static final String const_underreview = 'Under Review';
    public static final string CONST_OPEN = 'Open';
    public static final string CONST_CLOSED = 'Closed';
    public static final String STATUS_SUBMITTED = 'Submitted';
    public static final String CONTRACT_OFFICE_MANAGER = 'Contract Office Manager';
    public static final String CONCEPT_PAPER_THRESHOLD = 'Concept Paper Threshold';
    public static final String PROPOSAL_THRESHOLD = 'Proposal Threshold';
    private static final Set<String> VALID_STATUS = new Set<String>{'Submitted','Pending Review','Under Review','Awarded','Not Awarded'};
    public static final string PROGRAM_STAFF_PROFILE_NAME = 'Program Staff';


    // GLOBAL VARIABELS
    public list<proposalWrapper> liproposalWrapper{Get;set;}
    public string selectedPrograVersionVal{get;set;}
    public double sumtotalNysedra{Get;set;}
    public double sumtotalcostShare{Get;set;}
    public double sumtotalcost{Get;set;}
    public double sumremainingcost{Get;set;}
    public boolean isSuccessfullySaved {get;set;}
    public boolean isfinlizeScoreNeeded {get;set;}
    public boolean isProjectReviewInfoSaved {get;set;}
    public Proposal_Score__c proposalScoring{get;set;}
    public List<SelectOption> scoringMembers {get;set;}
    public String selectedScoringMember {get;set;}
    Map<Id, Proposal_Score__c> userToScoreMap {get;set;}
    public Map<Id, List<ProposalScoreMatrixWrapper>> proposalScoreMatrixMap {get;set;}
    public Map<Id, String> solicitationGrpMap {get;set;}
    public Map<Id, List<Solicitation_Group_Member__c>> grpToGrpMemberMap {get;set;}
    public Id systemAdminId {get;set;}
    public Boolean allowResultUpdate {get;set;}
    public Boolean allowUpdate {get;set;}
    public Boolean allowGrpCreation {get;set;}
    public Boolean isMatrixUpdated {get;set;}
    public List<Solicitation_Review_Team__c> reviewTeam {get;set;}
    public project__c proj {get;set;}
    map<id,proposalWrapper> mapWrapper = new Map<id,proposalWrapper>();
    public string selectedProgramVersion{Get;set;}
    public map<string,boolean> mapfundingexist{get;set;}
    public Solicitation_Group__c solicitationGrp{get;set;}
    public map<String,List<Solicitation_Funding__c>> mapoflifunnding{get;set;}
    public List<SolicitationGroup> solicitationGroupList {get; set;}
    public Map<Id, List<Solicitation_Group__c>> solicitationRoundIdToGroupListMap {get; set;}
    public String currentOpenSolicitationRoundId {get;set;}
    public Program_Version__c currentSolicitation {get; set;}
    public Boolean isExport {get; set;}

    public Boolean isProgramStaff {get; set;}
    public Boolean isSystemAdmin {get; set;}
    public Boolean isSolicitationManager {get; set;}
    public Boolean isProgramManager {get; set;}
    public Boolean isContractOfficeManager {get; set;}
    public Boolean isProjectCoordinator {get; set;}
    public Boolean isScoringCommiteeMember {get; set;}
    public Boolean allowProposalUpdation {get;set;}

    public Map<String, decimal> fundToTotalAmountMap{get;set;}
    public Map<String, String> fundToTotalAmountMap_containsCheck{get;set;}
    public List<SelectOption> projManagerUserOptionList { get; set; }
    public Integer selectedIndex {get; set;}
    public String sortFieldName {get; set;}
    public String prevSortFieldName {get; set;}
    public Boolean isAsc {get; set;}
    public Boolean isSortingChanged {get; set;}

    public Map<Id, String> greenlightValuesSnapshot {get;set;}
    public Boolean greenlightValueChanged {get;set;}
    public List<SelectOption> categoryFilterList {get; set;}
    public String selectedCategory {get; set;}

    // Start of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending
    public String previewEmailBody {get; set;}
    public String previewEmailSubject {get; set;}
    // END of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending

    public List<SelectOption> statusList{get{

           List<SelectOption> options = new List<SelectOption>();
           options.add(new SelectOption('', 'None'));
           options.add(new SelectOption('Submitted', 'Submitted'));
           options.add(new SelectOption('Pending Review', 'Pending Review'));
           options.add(new SelectOption('Under Review', 'Under Review'));
           options.add(new SelectOption('Awarded', 'Awarded'));
           options.add(new SelectOption('Not Awarded', 'Not Awarded'));
           options.add(new SelectOption('Non-Responsive', 'Non-Responsive'));
           options.add(new SelectOption('Ineligible', 'Ineligible'));
           return options;
      }
      set;
    }

    // I-03056 - 'none' value fix
    // I-03007 - Unable to move proposal to the next step while changing the status on filter and the status on the Proposal at the same time
    public List<SelectOption> statusFilterList{get{

           List<SelectOption> options = new List<SelectOption>();
           options.add(new SelectOption('Submitted', 'Submitted'));
           options.add(new SelectOption('Pending Review', 'Pending Review'));
           options.add(new SelectOption('Under Review', 'Under Review'));
           options.add(new SelectOption('Awarded', 'Awarded'));
           options.add(new SelectOption('Not Awarded', 'Not Awarded'));
           options.add(new SelectOption('Non-Responsive', 'Non-Responsive'));
           options.add(new SelectOption('Ineligible', 'Ineligible'));
           return options;
      }
      set;
    }


   /*
    * Method Name: fetchProjManagerUserOptionList
    * Description: Method to get program staff users
                   T-02548  - Add progressive search to project manager lookup on proposal review page
    * @param: None
    * @return: List<SelectOption> -- projManagerUserOptionList
    */
    public List<SelectOption> fetchProjManagerUserOptionList (){
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('', 'None'));

      for(User obj : [SELECT  Id, Name
                      FROM    User
                      WHERE   ContactId = null
                      //AND     Profile.Name = :PROGRAM_STAFF_PROFILE_NAME
                      ORDER BY Name ASC]) {
        options.add(new SelectOption(obj.Id, obj.Name));
      }

      return options;

    }


    public List<SelectOption> solicitationRoundList{get{

           List<SelectOption> options = new List<SelectOption>();
           //options.add(new SelectOption('', '--None--'));  // Support for multi round

           for(Solicitation_Round__c round : [SELECT Name, Id FROM Solicitation_Round__c
                                              WHERE Solicitation__c =: selectedProgramVersion
                                              ORDER BY Name]){
               options.add(new SelectOption(round.Id, round.Name));
           }

           return options;
      }
      set;
    }

    public static string dataDownload{
        get{
            if(dataDownload==null){
                //dataDownload = 'PROPOSER NUMBER,RANK,   PROJECT NAME, SOLICITATION ROUND,   STATUS, PROPOSER,   PROPOSED NYSERDA COST,  PROPOSED COST SHARE,    PROPOSED TOTAL COST,    RECOMMENDED NYSERDA FUNDING,    PROJECT PM, PROJECT TYPE';
                dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,RANK,PROPOSER NAME,PROPOSAL TITLE,OBJECTIVE / SCOPE,IMPACTS / BENEFITS,PROPOSAL STRENGTHS,PROPOSAL WEAKNESSES,'
                                + 'RISKS,REQUESTED FUNDING $,RECOMMENDED FUNDING $,CONTINGENCIES / RECOMMENDATIONS,RECOMMENDATION,RECOUPMENT,ACCEPTS T&C,'
                                + 'FUND,AMOUNT,PROJECT,ACTIVITY,ACCOUNT';
            }
            return dataDownload;
        }
    }
    public string fedexCSVfilename{
        get{
            return 'Download Proposal review '+system.today().format()+'.csv';

        }
        set;

    }
    private map<string,string> mapprojectContractLine;
    public boolean isConceptPaper {get; set;}
    public String updateStatusTo {get; set;}
    public String thresholdTypeLabel {get;set;}
    public Decimal thresholdValue {get;set;}

    public CORE_Proposal_Review_Controller() {

        isSuccessfullySaved = false;
        isConceptPaper = false;
        isMatrixUpdated = false;
        allowGrpCreation = false;
        allowUpdate = false;
        isProjectReviewInfoSaved = false;
        updateStatusTo = '';
        selectedScoringMember = null;
        isExport = false;

        isProgramStaff = false;
        isSystemAdmin = false;
        isSolicitationManager = false;
        isProgramManager = false;
        isContractOfficeManager = false;
        isProjectCoordinator = false;
        isScoringCommiteeMember = false;
        allowProposalUpdation = false;
        isAsc = true;
        isSortingChanged = false;

        hasErrorWithRecommendedFundingEmpty = false;

        fundToTotalAmountMap_containsCheck = new Map<String, String>();
        mapfundingexist = new map<string,boolean>();

        greenlightValueChanged = false;
        greenlightValuesSnapshot = new Map<Id, String>();

        projManagerUserOptionList = new List<SelectOption>();
        projManagerUserOptionList = fetchProjManagerUserOptionList(); // T-02548

        proj = new Project__c(status__c = const_underreview);
        // URL PARAMETERS
        if(Apexpages.currentPage().getParameters().get('status')!=null){
            proj.status__c = core_helper.doEscapeSingleQuotes(Apexpages.currentPage().getParameters().get('status'));
        } else {
            proj.status__c = STATUS_SUBMITTED;
        }
        if(Apexpages.currentPage().getParameters().get('solicitationID')!=null){
            selectedProgramVersion =     Apexpages.currentPage().getParameters().get('solicitationID');
        }
        if(Apexpages.currentPage().getParameters().get('round')!=null){
            proj.Solicitation_Round__c = Apexpages.currentPage().getParameters().get('round');
        }
        if(Apexpages.currentPage().getParameters().get('isExport') == 'true') {
            isExport = true;
        }

        list<SelectOption> temp= liprogramversion;
        System.debug('==>selectedProgramVersion ==.> '+selectedProgramVersion);
        // Data Download
        if(mapoflifunnding != null && mapoflifunnding.containsKey(selectedProgramVersion) &&
           mapoflifunnding.get(selectedProgramVersion) != null){
            for(Solicitation_Funding__c var : mapoflifunnding.get(selectedProgramVersion)){
                //dataDownload+=','+ (var.name != null ? var.name : '');
            }
        }

        dataDownload +='\n';
        checkForConceptPaperAndStatusDefaultValues();
        populateSolicitationGroupList();
        if(isExport) {
            isConceptPaper = (Apexpages.currentPage().getParameters().get('isConceptPaper') != null)
                                    ? Boolean.valueOf(Apexpages.currentPage().getParameters().get('isConceptPaper')) : false;
        }
        startRetrieval();
        checkForUser();
        allowProposalUpdation = (isSystemAdmin || isSolicitationManager || isProgramManager || isContractOfficeManager || isProjectCoordinator);
        reviewTeamMemberList = new List<SelectOption>();
        hasErrorWhileDeletingMember = false;
        hasErrorWhileDeletingGroup = false;
        hasNoMemberToAddInGroup = false;

        if(isConceptPaper && currentSolicitation != null){
          thresholdTypeLabel = CONCEPT_PAPER_THRESHOLD;
          thresholdValue = currentSolicitation.Concept_Paper_Pass_Score__c;
        }else if(!isConceptPaper && currentSolicitation != null){
          thresholdTypeLabel = PROPOSAL_THRESHOLD;
          thresholdValue = currentSolicitation.Proposal_Threshold__c;
        }else{
          thresholdTypeLabel = '';
          thresholdValue = 0.00;
        }
    }

    public List<Program_Version__c> solicitationList {get; set;}

   /*
    * Method Name: checkForConceptPaperAndStatusDefaultValues
    * Description: Method to check concept paper and status default values
    * @param: None
    * @return: void
    */

    private void checkForConceptPaperAndStatusDefaultValues() {
        solicitationList = [SELECT  Concept_Paper__c, Current_Proposal_Review_Status__c, Current_Concept_Paper_Review_Status__c, Score_Type__c,
                                        Service_Disabled_Veteran_Owned_Business__c, MWBE__c,
                                        Concept_Paper_Pass_Score__c, Proposal_Threshold__c, Name, Solicitation_Number__c,
                                        (SELECT Name FROM Proposal_Categories__r),
                                        (SELECT Id, Concept_Paper_Due_Date__c
                                         FROM   Solicitation__r
                                         WHERE  Status__c = 'Open' OR Status__c = 'Closed'
                                         ORDER BY Concept_Paper_Due_Date__c limit 1)
                            FROM  Program_Version__c
                            WHERE Id =: selectedProgramVersion];
        if(solicitationList.size() > 0) {
            if(solicitationList[0].Concept_Paper__c) {
                if(solicitationList[0].Solicitation__r.size() > 0) {
                    DateTime dueDateOnRound = solicitationList[0].Solicitation__r[0].Concept_Paper_Due_Date__c;
                    Decimal daysMargin = CORE_Constants_Setting__c.getOrgDefaults().Concept_Paper_Review_Timeline__c;
                    daysMargin = (daysMargin == null) ? 0 : daysMargin;
                    if(dueDateOnRound != null && dueDateOnRound.addDays((Integer)daysMargin) >= system.now() && !isExport) {
                        isConceptPaper = true;
                    }
                }
                if(solicitationList[0].Current_Concept_Paper_Review_Status__c != null && !isExport) {
                    proj.Status__c = solicitationList[0].Current_Concept_Paper_Review_Status__c;
                }
            } else {
                if(solicitationList[0].Current_Proposal_Review_Status__c != null && !isExport) {
                    proj.Status__c = solicitationList[0].Current_Proposal_Review_Status__c;
                }
            }

            if(solicitationList[0].Solicitation__r.size() > 0) {
                currentOpenSolicitationRoundId = solicitationList[0].Solicitation__r[0].Id;
            }
            currentSolicitation = solicitationList[0];
            populateCategoryFilterList(currentSolicitation);
        }
    }

     /*
      * Method Name: populateSolicitationGroupList
      * Description: Method to populate solicitation group list
      * @param: None
      * @return: void
      */

    public void populateSolicitationGroupList() {
        String query = 'SELECT Solicitation_Round__c, Total_Members__c, Name, ';
        query += '(select Solicitation_Review_Team__c, Solicitation_Review_Team__r.Member__r.Name, Solicitation_Review_Team__r.Is_External_User__c, Is_Solicitation_Manager__c ';
        query += 'from Solicitation_Group_Members__r order by CreatedDate ASC) ';
        query += 'from Solicitation_Group__c where Solicitation_Round__r.Solicitation__c =: selectedProgramVersion ';

        if(String.isNotBlank(proj.Solicitation_Round__c)) {
            query += 'AND Solicitation_Round__c = \'' + proj.Solicitation_Round__c + '\'';
        }
        //query += 'AND Solicitation_Round__r.Status__c = \'Open\'';
        query += ' Order by Name ASC';
        List<Solicitation_Group__c> groupList = Database.query(query);

        solicitationGroupList = new List<SolicitationGroup>();
        solicitationRoundIdToGroupListMap = new Map<Id, List<Solicitation_Group__c>>();
        for(Solicitation_Group__c solicitationGroupRec : groupList) {
            solicitationGroupList.add(new SolicitationGroup(solicitationGroupRec));
            if(!solicitationRoundIdToGroupListMap.containsKey(solicitationGroupRec.Solicitation_Round__c)) {
                solicitationRoundIdToGroupListMap.put(solicitationGroupRec.Solicitation_Round__c, new List<Solicitation_Group__c>{});
            }
            solicitationRoundIdToGroupListMap.get(solicitationGroupRec.Solicitation_Round__c).add(solicitationGroupRec);
        }
        hasErrorWhileDeletingMember = false;
        hasErrorWhileDeletingGroup = false;
        hasNoMemberToAddInGroup = false;
    }

  /*
   * Method Name: populateCategoryFilterList
   * Description: Method to populate Proposal Category option List
   * @param: Program_Version__c solicitationRec - Current Solicitation Record with Proposal Category as children
   * @return:
  */
  private void populateCategoryFilterList(Program_Version__c solicitationRec) {
    categoryFilterList = new List<SelectOption>();
    categoryFilterList.add(new SelectOption('', 'All'));
    for(Proposal_Category__c proposalCategoryRec : solicitationRec.Proposal_Categories__r) {
      categoryFilterList.add(new SelectOption(proposalCategoryRec.Name, proposalCategoryRec.Name));
    }
  }

    public String selectedGroupId {get; set;}
    public String editedGroupName {get; set;}
    public List<SelectOption> reviewTeamMemberList {get; set;}
    public String selectedReviewTeamId {get; set;}
    public String selectedGroupMemberId {get; set;}
    public Boolean hasErrorWhileDeletingMember {get; set;}
    public Boolean hasErrorWhileDeletingGroup {get; set;}
    public Boolean hasNoMemberToAddInGroup {get; set;}

      /*
      * Method Name: deleteSolicitationGroup
      * Description: Method to delete Solicitation Group
      * @param: None
      * @return: PageReference
      */

    public PageReference deleteSolicitationGroup() {
        hasErrorWhileDeletingMember = false;
        hasNoMemberToAddInGroup = false;
        if(String.isNotBlank(selectedGroupId)) {
            if(!checkForScoring(selectedGroupId, true)) {
                Solicitation_Group__c groupToDel = new Solicitation_Group__c(Id = selectedGroupId);
                delete groupToDel;
                populateSolicitationGroupList();
            } else {
                hasErrorWhileDeletingGroup = true;
            }
        }
        return null;
    }

      /*
      * Method Name: deleteSolicitationGroupMember
      * Description: Method to delete Solicitation Group Member
      * @param: None
      * @return: PageReference
      */

    public PageReference deleteSolicitationGroupMember() {
        hasErrorWhileDeletingGroup = false;
        hasNoMemberToAddInGroup = false;
        if(String.isNotBlank(selectedGroupMemberId)) {
            if(!checkForScoring(selectedGroupMemberId, false)) {
                Solicitation_Group_Member__c groupMemberToDel = new Solicitation_Group_Member__c(Id = selectedGroupMemberId);
                delete groupMemberToDel;
                populateSolicitationGroupList();
            } else {
                hasErrorWhileDeletingMember = true;
            }
        }
        return null;
    }

      /*
      * Method Name: checkForScoring
      * Description: Method to check for scoring
      * @param: String selectedObjId, Boolean isGroup
      * @return: Boolean
      */

    private Boolean checkForScoring(String selectedObjId, Boolean isGroup) {
        Boolean isScoringPresent = false;
        List<Solicitation_Group_Member__c> groupMemberList = new List<Solicitation_Group_Member__c>();
        if(!isGroup) {
            groupMemberList = [select Solicitation_Group__c, Solicitation_Review_Team__c from Solicitation_Group_Member__c
                                                                        where Id =: selectedObjId];
        } else {
            groupMemberList = [select Solicitation_Group__c, Solicitation_Review_Team__c from Solicitation_Group_Member__c
                                                                        where Solicitation_Group__c =: selectedObjId];
        }

        Set<Id> teamReviewMemberIdSet = new Set<Id>();
        String solicitationGroupId;
        for(Solicitation_Group_Member__c groupMemberRec : groupMemberList) {
            teamReviewMemberIdSet.add(groupMemberRec.Solicitation_Review_Team__c);
            solicitationGroupId = groupMemberRec.Solicitation_Group__c;
        }


        List<Proposal_Score__c> proposalScoreList = [select Id from Proposal_Score__c where Proposal__r.Solicitation_Group__c =: solicitationGroupId
                                                                                AND Scoring_Committee_Member__c IN: teamReviewMemberIdSet];

        if(proposalScoreList.size() > 0) {
            isScoringPresent = true;
        }
        return isScoringPresent;
    }

      /*
      * Method Name: getGroupMemberList
      * Description: Method to get list of group members
      * @param: None
      * @return: PageReference
      */

    public PageReference getGroupMemberList() {
        List<Solicitation_Review_Team__c> reviewTeamList = [select Member__c, Member__r.Name, Member__r.Email from Solicitation_Review_Team__c
                                                                    where Scoring_Committee__c = true
                                                                    AND Id Not IN (select Solicitation_Review_Team__c from Solicitation_Group_Member__c
                                                                            where Solicitation_Group__c =: selectedGroupId)
                                                                    AND Solicitation__c =: selectedProgramVersion
                                                                    AND Member__c != null ];

        reviewTeamMemberList = new List<SelectOption>();
        for(Solicitation_Review_Team__c reviewTeam : reviewTeamList) {
            reviewTeamMemberList.add(new SelectOption(reviewTeam.Id, reviewTeam.Member__r.Name + ' (' + reviewTeam.Member__r.Email + ')' ));
        }
        hasErrorWhileDeletingMember = false;
        hasErrorWhileDeletingGroup = false;
        hasNoMemberToAddInGroup = (reviewTeamMemberList.size() == 0);
        return null;
    }

     /*
      * Method Name: resetGroupMemberList
      * Description: Method to reset the list of group members
      * @param: None
      * @return: PageReference
      */

    public PageReference resetGroupMemberList() {
        reviewTeamMemberList = new List<SelectOption>();
        hasErrorWhileDeletingMember = false;
        hasErrorWhileDeletingGroup = false;
        hasNoMemberToAddInGroup = false;
        return null;
    }

      /*
      * Method Name: addNewMemberToGroup
      * Description: Method to add new member to group
      * @param: None
      * @return: PageReference
      */

    public PageReference addNewMemberToGroup() {
        Solicitation_Group_Member__c groupMemberToInsert = new Solicitation_Group_Member__c();
        groupMemberToInsert.Solicitation_Group__c = selectedGroupId;
        groupMemberToInsert.Solicitation_Review_Team__c = selectedReviewTeamId;
        insert groupMemberToInsert;
        populateSolicitationGroupList();
        resetGroupMemberList();
        return null;
    }

     /*
      * Method Name: saveGroupRec
      * Description: Method to save group record
      * @param: None
      * @return: PageReference
      */

    public PageReference saveGroupRec() {
        Solicitation_Group__c groupRec = new Solicitation_Group__c(Id = selectedGroupId);
        groupRec.Name = editedGroupName;
        update groupRec;
        populateSolicitationGroupList();
        return null;
    }

     /*
      * Method Name: checkForUser
      * Description: Method checking for user profile
      * @param: None
      * @return: void
      */

    private void checkForUser() {
        List<Profile> profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Program Staff'];
        String programStaffId;
        for(Profile profileRec : profileList) {
            if(profileRec.Name == 'System Administrator') {
                systemAdminId = profileRec.Id;
            } else if(profileRec.Name == 'Program Staff') {
                programStaffId = profileRec.Id;
            }
        }

        // Admin User
        if(UserInfo.getProfileId() == systemAdminId) {
            isSystemAdmin = isSolicitationManager = true;
            isProgramManager = true;
            return;
        }

        // Solicitation Manager and Program Manager
        List<Program_Version__c> solicitationList = [ SELECT  Solicitation_Manager__c, Program_Manager__c, Score_Type__c,
                                                              Default_Project_Coordinator__c
                                                      FROM    Program_Version__c
                                                      WHERE   Id =: selectedProgramVersion];
        if(solicitationList.size() > 0) {
            if(UserInfo.getUserId() == solicitationList[0].Solicitation_Manager__c) {
                isSolicitationManager = true;
                return;
            }
            if(UserInfo.getUserId() == solicitationList[0].Program_Manager__c) {
                isProgramManager = true;
                return;
            }
        }

        // Contract Office Manager
        List<GroupMember> groupMemberList = [select Id, UserOrGroupId from GroupMember where Group.Name =: CONTRACT_OFFICE_MANAGER];
        for(GroupMember groupMemberRec : groupMemberList) {
            if(UserInfo.getUserId() == groupMemberRec.UserOrGroupId) {
                isContractOfficeManager = true;
                return;
            }
        }

        // Project Coordinator
        if(solicitationList.size() > 0) {
            if(UserInfo.getUserId() == solicitationList[0].Default_Project_Coordinator__c) {
                isProjectCoordinator = true;
                return;
            }
        }

        // Scoring Commiteee Member
        if(solicitationList.size() > 0 && solicitationList[0].Score_Type__c == 'Batch Rank') {
            Set<Id> assignedGroupIdSet = new Set<Id>();
            for(proposalWrapper proposalWrapperObj : liproposalWrapper) {
                assignedGroupIdSet.add(proposalWrapperObj.pro.Solicitation_Group__c);
            }
            assignedGroupIdSet.remove(null);

            List<Solicitation_Group_Member__c> solicitationGroupMemberList = [select Id from Solicitation_Group_Member__c
                                                                                    where Solicitation_Group__c IN: assignedGroupIdSet
                                                                                    AND Solicitation_Review_Team__r.Member__c =: UserInfo.getUserId() ];
            if(solicitationGroupMemberList.size() > 0) {
                isScoringCommiteeMember = true;
                return;
            }
        } else {
            List<Solicitation_Review_Team__c> reviewTeamMemberList = [select Id from Solicitation_Review_Team__c
                                                                         where Solicitation__c =: selectedProgramVersion AND Scoring_Committee__c = true
                                                                           AND Member__c =: UserInfo.getUserId()];
            if(reviewTeamMemberList.size() > 0) {
                isScoringCommiteeMember = true;
                return;
            }
        }

        // Program Staff
        if(UserInfo.getProfileId() == programStaffId) {
            isProgramStaff = true;
            return;
        }

    }

    public list<SelectOption> liprogramversion {
        get{
            if(liprogramversion==null){
                liprogramversion = new list<SelectOption>();
                list<SelectOption> templiprogramversion = new list<SelectOption>();
                mapoflifunnding = new map<String,List<Solicitation_Funding__c>>();
                mapfundingexist = new map<string,boolean>();
                for(Program_Version__c varloop: [select id,name,
                                                 (select id,name,Account_Number__c,Activity_ID__c,
                                                  Solicitation__r.name, Amount__c,
                                                  project_id__c,Department__c,Market_Focus__c,Solicitation__c
                                                  from Solicitations_Fundings__r)
                                                 from Program_Version__c
                                                 where (status__c = :CONST_OPEN OR status__c = :CONST_CLOSED)
                                                 AND Id =: selectedProgramVersion]){
                                                     for(Solicitation_Funding__c fundloop: varloop.Solicitations_Fundings__r){
                                                         if(mapoflifunnding.get(String.valueOf(fundloop.Solicitation__c).substring(0,15))==null)
                                                             mapoflifunnding.put(String.valueOf(fundloop.Solicitation__c).substring(0,15),new list<Solicitation_Funding__c>{fundloop});
                                                         else
                                                             mapoflifunnding.get(String.valueOf(fundloop.Solicitation__c).substring(0,15)).add(fundloop);
                                                     }
                                                     mapfundingexist.put(String.valueOf(varloop.id).substring(0,15),varloop.Solicitations_Fundings__r.size()!=0);

                                                     // AG 06/10/2017 - I-03001 FIX - Changing Proposal to Award Review Page Error
                                                     mapfundingexist.put(String.valueOf(varloop.id),varloop.Solicitations_Fundings__r.size()!=0); // 18 version also
                                                     for(String strVersionOfSolicitation : mapoflifunnding.keySet()) {
                                                       Id idVersionOfSolicitation = strVersionOfSolicitation;
                                                       mapoflifunnding.put(idVersionOfSolicitation, mapoflifunnding.get(strVersionOfSolicitation));
                                                     }
                                                     // EndOf: AG 06/10/2017 - I-03001 FIX - Changing Proposal to Award Review Page Error

                                                     if(Varloop.id == selectedProgramVersion){
                                                         selectedPrograVersionVal = varloop.name;
                                                         continue;
                                                     }
                                                     templiprogramversion.add(new SelectOption(varloop.id,varloop.name));
                                                 }

                if(selectedProgramVersion!=null && selectedPrograVersionVal != null){
                    liprogramversion.add(new SelectOption(selectedProgramVersion ,selectedPrograVersionVal));
                }

                liprogramversion.addall(templiprogramversion);
            }
            return liprogramversion;
        }
        set;
    }

    map<string,string> maplinkFunding{Get;set;}
    public Boolean hasError {get; set;}
    public Boolean hasErrorWithProjectManagerEmpty {get; set;}
    public Boolean hasErrorWithRecommendedFundingEmpty {get; set;}

     /*
      * Method Name: saveRecords
      * Description: Method to Save Reocrds in the Database
      * @param: None
      * @return: void
      */

    public void saveRecords() {
        isSuccessfullySaved = false;
        hasError = false;
        hasErrorWithProjectManagerEmpty = false;
        hasErrorWithRecommendedFundingEmpty = false;
        Savepoint sp = Database.setSavepoint();

        System.debug(' >>> updateStatusTo value = ' + updateStatusTo);
        System.debug(' >>> proj.Solicitation_Round__c value = ' + proj.Solicitation_Round__c);


        // Validation for - 1) Sum of Fund line distribution amount and NYSERDA funding Amount should match
        //                  2) Required Project Manager if RECOMMENDATION = "Fund-Award"
        for(proposalWrapper proposalWrapperObj : liproposalWrapper) {
            Decimal subtotal = 0;

            // AG 06/13/2017 - FIX - I-03012 - Contracts team should not be able to set the Greenlight Approval to Fund-Award until the Recommended Funding Amount is populated
            if(proposalWrapperObj.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_FUND_AWARD && proposalWrapperObj.pro.Recommended_NYSERDA_Funding__c == null) {
                hasErrorWithRecommendedFundingEmpty = true;
                return;
            }
            // AG 06/13/2017 - FIX - I-03012 - Contracts team should not be able to set the Greenlight Approval to Fund-Award until the Recommended Funding Amount is populated
			/*
            if(proposalWrapperObj.proFund.size() > 1) {
                for(Project_Funding__c fundRec : proposalWrapperObj.proFund) {
                    if(proposalWrapperObj.projectFundIdToIsSelectedMap.containsKey(fundRec.Fund__c) && proposalWrapperObj.projectFundIdToIsSelectedMap.get(fundRec.Fund__c)) {
                        subtotal += (fundRec.Distribution_Amount__c != null) ? fundRec.Distribution_Amount__c : 0;
                    }
                }
                Decimal totalAmount = (proposalWrapperObj.pro.Recommended_NYSERDA_Funding__c != null) ? proposalWrapperObj.pro.Recommended_NYSERDA_Funding__c : 0;
                if(subtotal != totalAmount) {
                    hasError = true;
                    return;
                }
            }
			*/
            if(proposalWrapperObj.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_FUND_AWARD && proposalWrapperObj.rolemanager.User__c == null) {
                hasErrorWithProjectManagerEmpty = true;
                return;
            }
        }


        try{
            list<project_role__c> liRolemanagerToupsert = new List<Project_Role__c>();
            list<project__c> listToupdate = new list<project__c>();
            list<Project_Funding__c> lisFundingUpdate= new list<Project_Funding__c>();
            list<Project_Contract__c> lisContractUpdate= new list<Project_Contract__c>();
            list<Project_Contract_Line__c> lisContractLineUpdate= new list<Project_Contract_Line__c>();
            list<Project_Funding__c> proFuntobecreated = new list<Project_Funding__c>();
            list<Project_Role__c> lisProjectRole = new list<Project_Role__c>();
            Map<id,Project_Contract__c> procontracttobecreated = new Map<id,Project_Contract__c>();
            Map<id,Project_Contract_Line__c> procontractLinetobecreated = new Map<id,Project_Contract_Line__c>();
            list<Project_Funding__c> proFuntobedeleted = new list<Project_Funding__c>();
            Map<Id, User> userMap = new Map<Id, User>();
            Set<Id> userIds = new Set<Id>();
            Project_Funding__c profunding;
            Project_Contract__c proContract;
            Project_Contract_Line__c procontractline;
            list<sobject> liSobject = new list<sobject>();
            List<Id> projectFundIdList = new List<Id>();
            List<Id> projectIdList = new List<Id>();
            List<Project_Role__c> projectManagerListToDel = new List<Project_Role__c>();

            proposalWrapper temp;
            //Insert project manager
            for(ProposalWrapper projectObj : liproposalWrapper) {
                temp = mapWrapper.get(projectObj.pro.Id);
                if(projectObj.rolemanager.User__c != null) {
                    userIds.add(projectObj.rolemanager.User__c);
                    liRolemanagerToupsert.add(projectObj.rolemanager);
                } else if(projectObj.rolemanager.Id != null) {
                    projectManagerListToDel.add(projectObj.rolemanager);
                }
            }

            if(userIds.size() > 0) {
                userMap = new Map<Id, User>([SELECT Id, ContactId, Contact.Account.Supplier_ID__c, Buyer_ID__c
                                               FROM User
                                              WHERE Id IN : userIds]);
            }

            // Inserting project contract
            for(proposalWrapper varloop:liproposalWrapper){
                temp = mapWrapper.get(varloop.pro.id);
                System.debug('temp==> '+varloop.rolemanager);
                System.debug('temp==> '+varloop.roleContractor);
                System.debug('temp==> '+temp);
                if(temp!=null && temp.proContract.id==null && temp.solfunding != null) {
                    for(Solicitation_Funding__c var : temp.solfunding){
                        System.debug('var==> '+var);
                        System.debug('temp.checkSelected.get(var.id)==> '+temp.checkSelected.get(var.id));
                        System.debug('temp.oldcheckSelected.get(var.id)==> '+temp.oldcheckSelected.get(var.id));
                        System.debug('temp.oldcheckSelected.get(var.id)==> '+temp.oldcheckSelected.get(var.id));
                        if(temp.checkSelected.get(var.id) != temp.oldcheckSelected.get(var.id)){
                            if(temp.checkSelected.get(var.id)){
                                Project_Contract__c tempProjectContract = new Project_Contract__c();
                                system.debug('========='+temp.roleManager.User__c);
                                system.debug('========='+userMap);
                                //Add buyer Id from manage role
                                if(temp.roleManager != null && temp.roleManager.User__c != null && userMap.get(temp.roleManager.User__c).Buyer_Id__c != null) {
                                    tempProjectContract.Buyer_ID__c = userMap.get(temp.roleManager.User__c).Buyer_Id__c;
                                } else if(temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c != null) {
                                    tempProjectContract.Buyer_ID__c = temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c;
                                }
                                system.debug('========='+temp.roleContractor.Contact__c);
                                system.debug('========='+temp.roleContractor.Contact__r.Account.Supplier_ID__c);
                                system.debug('========='+temp.roleContractor.Account__c);
                                system.debug('========='+temp.roleContractor.Account__r.Supplier_ID__c);
                                //Add Supplier Id from contractor
                                if(temp.roleContractor != null && temp.roleContractor.Account__c != null) {
                                    system.debug('=========1'+temp.roleContractor.Account__c);
                                    tempProjectContract.Supplier_ID__c = temp.roleContractor.Account__r.Supplier_ID__c;
                                }
                                tempProjectContract.Header_Description__c = temp.pro.Name;
                                tempProjectContract.Synopsis_Description__c = temp.pro.Name;
                                tempProjectContract.Agreement_Code__c = 'B';
                                tempProjectContract.Anticipated_Term_Over_A_Year__c = 'Y';
                                tempProjectContract.Procurement_Contract__c = 'Y';
                                tempProjectContract.Application_Recevived__c = 'Y';
                                tempProjectContract.Application_Date__c = temp.Pro.Submitted_Date__c;
                                tempProjectContract.project__c = temp.pro.id;
                                tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
                                // create elements
                                procontracttobecreated.put(varloop.pro.id, tempProjectContract);
                                break;
                            }

                        }

                    }
                }
            }

            if(!procontracttobecreated.isEmpty()){
                system.debug('-----------1'+procontracttobecreated);
                insert procontracttobecreated.values();
            }

            // Insertin Project contract
            for(proposalWrapper varloop:liproposalWrapper){
                temp = mapWrapper.get(varloop.pro.id);
                System.debug('temp==> '+temp);
                if(temp!=null && temp.solfunding != null){
                    for(Solicitation_Funding__c var : temp.solfunding){
                        System.debug('var==> '+var);
                        if(temp.checkSelected.get(var.id) != temp.oldcheckSelected.get(var.id)){
                            if(temp.checkSelected.get(var.id)){
                                // create elements
                                if(temp.proContract.id == null){
                                    System.debug('procontracttobecreated .get(temp.pro.id) == >'+procontracttobecreated.get(temp.pro.id));
                                    temp.proContract = procontracttobecreated.get(temp.pro.id);
                                }
                            }

                        }

                    }
                }
            }
            // INsert project contract line

            for(proposalWrapper varloop:liproposalWrapper){
                temp = mapWrapper.get(varloop.pro.id);
                System.debug('temp==> '+temp);
                if(temp!=null && temp.proContractline.id==null && temp.proContract.id!=null && temp.solfunding != null){
                    for(Solicitation_Funding__c var : temp.solfunding){
                        System.debug('var==> '+var);
                        if(temp.checkSelected.get(var.id) != temp.oldcheckSelected.get(var.id)){
                            if(temp.checkSelected.get(var.id)){
                                Project_Contract_Line__c tempProjectContractLine = new Project_Contract_Line__c();
                                tempProjectContractLine.Procurement_Method__c = 'SOLI';
                                tempProjectContractLine.Category__c = temp.pro.Program_Version__r.Category__c;
                                tempProjectContractLine.Project__c = temp.pro.id;
                                if(temp.roleManager != null && temp.roleManager.User__c != null && userMap.get(temp.roleManager.User__c).Buyer_Id__c != null) {
                                    tempProjectContractLine.Buyer__c = userMap.get(temp.roleManager.User__c).Buyer_Id__c;
                                } else if(temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c != null) {
                                    tempProjectContractLine.Buyer__c = temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c;
                                }
                                tempProjectContractLine.Line_Description__c = temp.pro.name;
                                tempProjectContractLine.Round_Number__c = temp.pro.Solicitation_Round__r.Name;
                                tempProjectContractLine.Project_Contract__c = temp.proContract.id;
                                tempProjectContractLine.Requisition_ID__c = '';
                                // create elements
                                procontractLinetobecreated.put(varloop.pro.id, tempProjectContractLine );
                                break;
                            }

                        }

                    }

                }
            }

            if(!procontractLinetobecreated.isEmpty()) {
                system.debug('-----------2'+procontractLinetobecreated);
                insert procontractLinetobecreated.values();
            }

            for(proposalWrapper varloop:liproposalWrapper) {
                temp = mapWrapper.get(varloop.pro.id);
                System.debug('temp==> '+temp);
                if(temp!=null && temp.solfunding != null) {
                    for(Solicitation_Funding__c var : temp.solfunding) {
                        System.debug('var==> '+var);
                        if(temp.checkSelected.get(var.id) != temp.oldcheckSelected.get(var.id)) {
                            if(temp.checkSelected.get(var.id)) {
                                // create elements
                                if(temp.proContractline.id == null) {
                                    System.debug('procontractLinetobecreated.get(temp.pro.id) == >'+procontractLinetobecreated.get(temp.pro.id));
                                    temp.proContractline = procontractLinetobecreated.get(temp.pro.id);
                                    break;
                                }
                            }

                        }

                    }
                }
            }

            // Check For Contract Line -
            List<Id> projectIds = new List<Id>();
            for(proposalWrapper varloop:liproposalWrapper){
                temp = mapWrapper.get(varloop.pro.id);
                if(temp != null && temp.proFund != null) {
                  for(Project_Funding__c fundingRec : temp.proFund) {
                      if(temp.projectFundIdToIsSelectedMap.containsKey(fundingRec.Fund__c) && temp.projectFundIdToIsSelectedMap.get(fundingRec.Fund__c)) {
                          if(fundingRec.Project_Contract__c == null || fundingRec.Project_Contract_Line__c == null) {
                              projectIds.add(varloop.pro.id);
                          }
                      }
                  }
                }

            }

            system.debug('-----------2'+projectIds);
            if(projectIds.size() > 0) {
                createContractAndContractLineRecords(projectIds);
            }

            //GS
            Map<String, String> categoryNameToCategoryProjectTypeMap = new Map<String, String>();
            Map<String, boolean> propCategoryToRecoupmentMap = new Map<String, boolean>();
            for(Proposal_Category__c propCategory : [Select Id, Name, Recoupment__c, Solicitation__c,Project_Type__c
                                                           from Proposal_Category__c where Solicitation__c =: selectedProgramVersion]){
                propCategoryToRecoupmentMap.put(propCategory.Name, propCategory.Recoupment__c);
                categoryNameToCategoryProjectTypeMap.put(propCategory.Name, propCategory.Project_Type__c);
            }
            //GS

            Set<Id> projectIdWhichHaveFundsSet = new Set<Id>();

            //Set<Id> projectIdsForProjectDocUpdate = new Set<Id>();

            for(proposalWrapper varloop:liproposalWrapper){


                if(varloop.pro != null && varloop.pro.Status__c == Project_Helper.PROJECT_STATUS_UNDER_REVIEW) {

                    if(varloop.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_FUND_AWARD){
                        varloop.pro.Status__c = Project_Helper.PROJECT_STATUS_AWARDED;

                        Map<String,Schema.RecordTypeInfo> recordTypeNameMap_Project = Schema.SObjectType.Project__c.getRecordTypeInfosByName();

                        //Update proposal record type based on selected proposal category
                        if(String.isNotBlank(varloop.pro.Proposed_Proposal_Category__c) &&
                            categoryNameToCategoryProjectTypeMap.containsKey(varloop.pro.Proposed_Proposal_Category__c)) {

                            String selectedProjectType = categoryNameToCategoryProjectTypeMap.get(varloop.pro.Proposed_Proposal_Category__c);
                            Id selectedRecordTypeId = null;

                            // AG 06/12/2017 - I-03004 FIX - Green Light Approval - Object Reference Error
                            if(recordTypeNameMap_Project.containsKey(selectedProjectType)) {
                              selectedRecordTypeId = recordTypeNameMap_Project.get(selectedProjectType).getRecordTypeId();
                            }
                            // AG 06/12/2017 - I-03004 FIX - Green Light Approval - Object Reference Error
                            if(selectedRecordTypeId != null) {
                                varloop.pro.RecordTypeId = selectedRecordTypeId;
                                //projectIdsForProjectDocUpdate.add(varloop.pro.Id);
                            }

                        }

                        if(temp.roleContractor != null) {
                            lisProjectRole.add(new project_Role__c(Id=temp.roleContractor.Id, Role__c=ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE, Primary_Customer_Contact__c = true));
                        }

                        //GS
                        if(propCategoryToRecoupmentMap != null && propCategoryToRecoupmentMap.containsKey(varloop.pro.Proposed_Proposal_Category__c) &&
                                propCategoryToRecoupmentMap.get(varloop.pro.Proposed_Proposal_Category__c)){
                            varloop.pro.Recoupment_Contract_Terms__c = 'Yes';
                        }
                        //GS
                    }else if(varloop.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_FUNDABLE ||
                             varloop.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_DO_NOT_FUND){
                        varloop.pro.Status__c = Project_Helper.PROJECT_STATUS_NOT_AWARDED;
                    }else if(varloop.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_ACCEPTED ||
                             varloop.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_NOT_ACCEPTED) {

                       if(varloop.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_ACCEPTED) {
                         varloop.pro.Concept_Paper_Result__c = 'Pass';  // Override on Approval
                         varloop.pro.Finalize_Result__c = true;  // Override on Approval
                         varloop.pro.Finalize_Score_Date__c = Datetime.now();
                       }
                       varloop.pro.Status__c = Project_Helper.PROJECT_STATUS_CLOSED;
                    }
                }

                listToupdate.add(varloop.pro);
                temp = mapWrapper.get(varloop.pro.id);
                System.debug('temp==> '+temp);
                if(temp!=null){

                    if(temp.roleContractor != null && temp.roleContractor.Account__c != null) {
                        temp.proContract.Supplier_ID__c = temp.roleContractor.Account__r.Supplier_ID__c;
                    }

                    if(temp.roleManager != null && temp.roleManager.User__c != null && userMap.get(temp.roleManager.User__c).Buyer_Id__c != null) {
                        temp.proContract.Buyer_ID__c = userMap.get(temp.roleManager.User__c).Buyer_Id__c;
                    } else if(temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c != null) {
                        temp.proContract.Buyer_ID__c = temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c;
                    }

                    if(temp.roleManager != null && temp.roleManager.User__c != null && userMap.get(temp.roleManager.User__c).Buyer_Id__c != null) {
                        temp.proContractline.Buyer__c = userMap.get(temp.roleManager.User__c).Buyer_Id__c;
                    } else if(temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c != null) {
                        temp.proContractline.Buyer__c = temp.pro.Program_Version__r.Solicitation_Manager__r.Buyer_Id__c;
                    }

                    if(temp.pro.Recoupment_Contract_Terms__c == 'Yes') {
                        temp.proContract.Status__c = ProjectContract_Helper.STATUS_ONHOLD;
                    }

                    system.debug('-----------2'+temp.proContract);
                    system.debug('-----------2'+temp.proContractline);
                    Integer fundingLineCount = 1;
                    for(Project_Funding__c fundingRec : temp.proFund) {
                        if(temp.projectFundIdToIsSelectedMap.containsKey(fundingRec.Fund__c) && temp.projectFundIdToIsSelectedMap.get(fundingRec.Fund__c)) {

                          System.debug('>>> fundingRec === ' + fundingRec);

                            if(fundingRec.Project_Contract__c == null) {
                                fundingRec.Project_Contract__c = temp.proContract.Id;
                            }
                            if(fundingRec.Project_Contract_Line__c == null) {
                                fundingRec.Project_Contract_Line__c = temp.proContractLine.Id;
                            }
                            lisFundingUpdate.add(fundingRec);
                            if(fundingRec.Id != null) {
                                projectFundIdList.add(fundingRec.Id);
                            }

                            if(fundingLineCount > 1) {
                                temp.proContract.Status__c = ProjectContract_Helper.STATUS_ONHOLD;
                            }

                            projectIdWhichHaveFundsSet.add(temp.pro.Id);
                            fundingLineCount++;
                        }

                        projectIdList.add(temp.pro.Id);
                    }

                    if(temp.proContract.project__c != null) {
                        lisContractUpdate.add(temp.proContract);
                        lisContractLineUpdate.add(temp.proContractline);
                    }

                    if(temp.proFund.size() == 0) {
                        projectIdList.add(temp.pro.Id);
                    }
                }
            }

            system.debug('-----------4'+lisContractUpdate);
            system.debug('-----------4'+lisContractUpdate);


            if(liproposalWrapper.size() > 0 && solicitationList != null && solicitationList.size() > 0 && VALID_STATUS.contains(liproposalWrapper[0].pro.Status__c)) {
                if(solicitationList[0].Concept_Paper__c) {
                    solicitationList[0].Current_Concept_Paper_Review_Status__c = liproposalWrapper[0].pro.Status__c;
                } else {
                    solicitationList[0].Current_Proposal_Review_Status__c = liproposalWrapper[0].pro.Status__c;
                }
            }

            if(!listToupdate.isEmpty()) {

                Boolean underReviewOrPendingReviewScenario = false;
                // Scroll the list
                for(Project__c objProjectToCheck : listToupdate) {
                  if(Project_Helper.PROJECT_STATUS_PENDING_REVIEW.equalsIgnoreCase(objProjectToCheck.Status__c) ||
                     Project_Helper.PROJECT_STATUS_UNDER_REVIEW.equalsIgnoreCase(objProjectToCheck.Status__c)) {

                    underReviewOrPendingReviewScenario = true;
                    break;
                  }
                }

                // Chunks I-03201
                if((  Project_Helper.PROJECT_STATUS_PENDING_REVIEW.equalsIgnoreCase(updateStatusTo) ||
                      Project_Helper.PROJECT_STATUS_UNDER_REVIEW.equalsIgnoreCase(updateStatusTo)
                    )
                    && proj.Solicitation_Round__c != null && underReviewOrPendingReviewScenario) {

                  List<Solicitation_Round__c> lstRoundToUpdate = [SELECT  Id, Notify_Review_Team_Concept_Paper__c, Notify_Review_Team_Proposal__c,
                                                                          Notify_Solicitation_Manager_Proposal__c, Notify_Solicitation_Mgr_Concept_Paper__c
                                                                  FROM    Solicitation_Round__c
                                                                  WHERE   Id = :proj.Solicitation_Round__c];
                  Solicitation_Round__c objRound = null;
                  if(lstRoundToUpdate.size() > 0) {
                    objRound = lstRoundToUpdate[0];
                    if(Project_Helper.PROJECT_STATUS_PENDING_REVIEW.equalsIgnoreCase(updateStatusTo)) {
                      // Solicitation Manager
                      if(isConceptPaper) {
                        objRound.Notify_Solicitation_Mgr_Concept_Paper__c = false;
                      } else {
                        objRound.Notify_Solicitation_Manager_Proposal__c = false;
                      }
                    } else if(Project_Helper.PROJECT_STATUS_UNDER_REVIEW.equalsIgnoreCase(updateStatusTo)) {
                      // Review Team
                      if(isConceptPaper) {
                        objRound.Notify_Review_Team_Concept_Paper__c = false;
                      } else {
                        objRound.Notify_Review_Team_Proposal__c = false;
                      }
                    }
                    update lstRoundToUpdate; // I-03201 - RESET flags for notifications
                  }
                }
                update listToupdate;
            }

            if(projectIdList.size() > 0) {
                List<Project_Funding__c> projectFundingList = [select Id from Project_Funding__c where Id NOT IN: projectFundIdList AND Project__c IN: projectIdList];
                if(projectFundingList.size() > 0) {
                    delete projectFundingList;
                }

                // Delete Contract and Contract Lines
                List<Project__c> proList = [select Id, (select Id from Project_Contracts__r)
                                                        from Project__c where Id IN: projectIdList AND Id Not IN: projectIdWhichHaveFundsSet];
                List<Project_Contract__c> projContractToDelList = new List<Sobject>();
                for(Project__c pro : proList) {
                    if(pro.Project_Contracts__r.size() > 0) {
                        projContractToDelList.addAll(pro.Project_Contracts__r);
                    }
                }
                if(projContractToDelList.size() > 0) {
                    delete projContractToDelList;
                }
            }

            if(lisProjectRole.size() > 0) {
                //update lisProjectRole; // Moved to Project trigger
            }

            if(!proFuntobedeleted.isempty())
                delete proFuntobedeleted;

            if(!liRolemanagerToupsert.isEmpty())
                upsert liRolemanagerToupsert;

            if(projectManagerListToDel.size() > 0) {
                delete projectManagerListToDel;
            }

            if(lisContractUpdate.size() > 0) {
                upsert lisContractUpdate;
            }

            if(lisContractLineUpdate.size() > 0) {
                upsert lisContractLineUpdate;
            }

            if(!lisFundingUpdate.isempty())
                upsert lisFundingUpdate;

            if(solicitationList.size() > 0) {
                update solicitationList;
            }

            startRetrieval();
            isSuccessfullySaved = true;
            updateStatusTo = '';

        }catch(exception e){
            startRetrieval();
            System.debug(e.getmessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            Database.rollback(sp);
            ApexPages.addMessages(e);

        }
    }

     /*
      * Method Name: insertFunds
      * Description: Method to insert funds
      * @param: None
      * @return: void
      */

    public void insertFunds() {

        greenlightValueChanged = false;
        // T-02656 - Identify the change against the snapshot of recommendation values
        if(greenlightValuesSnapshot != null && greenlightValuesSnapshot.size() > 0) {

          for(ProposalWrapper proposalWrapperObj : liproposalwrapper) {
            if(proposalWrapperObj.pro != null && proposalWrapperObj.pro.Id != null) {

              if(String.isNotBlank(proposalWrapperObj.pro.Recommendation__c)) {
                // Value is changed from value1 to value2
                greenlightValueChanged = !proposalWrapperObj.pro.Recommendation__c.equalsIgnoreCase(greenlightValuesSnapshot.get(proposalWrapperObj.pro.Id));
              } else {
                // Value is changed to blank from a value defined
                greenlightValueChanged = String.isNotBlank(greenlightValuesSnapshot.get(proposalWrapperObj.pro.Id));
              }
              if(greenlightValueChanged) {
                break;
              }
            }
          }
        }
        // T-02656 - Identify the change against the snapshot of recommendation values


        List<Project_Funding__c> projectFundListToInsert = new List<Project_Funding__c>();
        List<Project_Funding__c> fundLineListToDelete = new List<Project_Funding__c>();
        //system.assert(false, liproposalWrapper + '\n\n' + selectedIndex );
        proposalWrapper proposalWrapperObj = liproposalWrapper.get(selectedIndex - 1);

        Schema.DescribeFieldResult fundFieldDesc = Project_Funding__c.Fund__c.getDescribe();
        Integer lengthOfField = fundFieldDesc.getLength();

        if(proposalWrapperObj != null && proposalWrapperObj.solfunding != null && proposalWrapperObj.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_FUND_AWARD) {
            for(Solicitation_Funding__c soliciationFundingRec : proposalWrapperObj.solfunding) {
                Project_Funding__c profunding = new Project_Funding__c();

                profunding.Project_Contract__c = proposalWrapperObj.proContract.Id;
                profunding.Project__c = proposalWrapperObj.pro.Id;
                profunding.Project_Contract_Line__c = proposalWrapperObj.proContractline.Id;
                profunding.Account_Number__c = soliciationFundingRec.Account_Number__c;
                profunding.Activity_ID__c = soliciationFundingRec.Activity_ID__c;
                profunding.Department__c = soliciationFundingRec.Department__c;
                profunding.Project_ID__c = soliciationFundingRec.Project_ID__c;
                profunding.Market_Focus__c = soliciationFundingRec.Market_Focus__c;

                // If Funding source name is more than the characters allowed on project incentive funding source, then truncate to allowed limit
                if(soliciationFundingRec.Name != null) { // AG 06/12/2017 - I-03004 FIX - Green Light Approval - Object Reference Error
                 profunding.Fund__c = (soliciationFundingRec.Name.length() > lengthOfField ? soliciationFundingRec.Name.subString(0,lengthOfField) : soliciationFundingRec.Name);
                }

                profunding.Solicitation_External_Id__c = selectedProgramVersion;
                if(proposalWrapperObj.solfunding.size() > 1) {
                    profunding.Distribution_Amount__c = null;
                } else {
                    profunding.Distribution_Amount__c = proposalWrapperObj.pro.Recommended_NYSERDA_Funding__c;
                }
                projectFundListToInsert.add(profunding);
            }
            if(projectFundListToInsert.size() > 0) {
                //insert projectFundListToInsert;
            }
        } else if(proposalWrapperObj != null && (proposalWrapperObj.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_FUNDABLE
                                                    || proposalWrapperObj.pro.Recommendation__c == Project_Helper.PROJECT_RECOMMANDATION_DO_NOT_FUND)) {

            /*List<Project_Funding__c> projectFundingList = [select Id from Project_Funding__c where Project__c =: proposalWrapperObj.pro.Id];
            if(projectFundingList.size() > 0) {
                delete projectFundingList;
            }*/

            proposalWrapperObj.proFund = new List<Project_Funding__c>();
            proposalWrapperObj.projectFundIdToIsSelectedMap = new Map<String, Boolean>();
        }
        liproposalWrapper = mapWrapper.values();

        // Refresh Data
        /*List<Project_Funding__c> fundingLines = [select Project_Contract__c, Project_Contract_line__r.Project_Contract__r.Project__c, Project_ID__c,
                                            Solicitation_External_Id__c, Activity_ID__c, Account_Number__c, Department__c, Fund__c, Distribution_Amount__c
                                            from Project_Funding__c
                                            where Project_Contract_line__r.Project_Contract__r.Project__c =: proposalWrapperObj.pro.Id];*/
        proposalWrapper temp;
        for(Project_Funding__c fundLineRec : projectFundListToInsert) {
            temp = mapWrapper.get(fundLineRec.Project__c);
            if(temp != null) {
                Temp.checkSelected.put(fundLineRec.Solicitation_External_Id__c,true);
                Temp.oldremainigFields.put(fundLineRec.Solicitation_External_Id__c,fundLineRec);
                Temp.remainigFields.put(fundLineRec.Solicitation_External_Id__c,new Project_funding__c(id=fundLineRec.id,Distribution_Amount__c = fundLineRec.Distribution_Amount__c));
                Temp.oldcheckSelected.put(fundLineRec.Solicitation_External_Id__c,true);
                temp.proFund.add(fundLineRec);
                temp.fundToAmountMap.put(fundLineRec.Fund__c, fundLineRec.Distribution_Amount__c);
                temp.availableFunds += ';'+fundLineRec.Fund__c;
                if(fundLineRec.Solicitation_External_Id__c != null) {
                    temp.projectFundIdToIsSelectedMap.put(fundLineRec.Fund__c, true);
                } else {
                    temp.projectFundIdToIsSelectedMap.put(fundLineRec.Fund__c, false);
                }
            }
        }
        if(projectFundListToInsert.size() == 0) {
            temp = mapWrapper.get(proposalWrapperObj.pro.Id);
            temp.proFund = new List<Project_Funding__c>();
            temp.fundToAmountMap = new Map<String, decimal>();
            temp.availableFunds = '';
            temp.projectFundIdToIsSelectedMap = new Map<String, Boolean>();
        }
        liproposalWrapper = mapWrapper.values();
    }

     /*
      * Method Name: startRetrieval
      * Description: Method to start retrieval
      * @param: None
      * @return: void
      */

    public void startRetrieval() {
        isfinlizeScoreNeeded = false;
        String status = proj.status__c;
        String Solicitationround = proj.Solicitation_Round__c;

        liproposalWrapper = new list<proposalWrapper> ();
        mapprojectContractLine = new Map<String,string>();
        proposalWrapper temp;

        String query  = 'select name,rank__c,Submitted_Date__c,Solicitation_Round__c,Solicitation_Round__r.name,Total_Project_Cost_Estimated__c  ,Primary_Contractor_First_Name_Hidden__c,';
               query  += ' Concept_Paper__c, Proposal__c, Solicitation_Round__r.Concept_Paper_Finalize_Score__c, Solicitation_Round__r.Proposal_Finalize_Score__c, ';
               query  += 'Primary_Contractor_Last_Name_Hidden__c,Proposed_Proposal_Category__c, Proposed_NYSERDA_Cost__c,Budget_Type__c,Project_Manager_First_Name_Hidden__c,Proposal_Number__c,';
               query  += 'Program_Version__r.Procurement_Method__c,Finalize_Result__c,Program_Version__r.Category__c,Program_Version__r.Header_Description__c,Program_Version__r.Buyer_ID__c,';
               query  += 'Program_Version__r.Agreement_Code__c,Program_Version__r.Anticipated_Term_Over_A_Year__c,Program_Version__r.Procurement_Contract__c, Scoring_Committee_Recommendation__c,';
               query  += 'Project_Manager_Last_Name_Hidden__c,Recommended_NYSERDA_Funding__c,Propsoed_Cost_Share__c,Total_Project_Cost__c,status__c,Strength_Weakness__c, Team_Recommendation__c,';
               query  += 'Proposal_Rank__c, Description__c, Impacts_Benefits__c,Recoupment_Contract_Terms__c, Proposal_Strengths__c, Proposal_Weaknesses__c, Proposal_Risks__c,Solicitation_Group__c,';
               query  += 'Contingencies_Recommendations__c, Program_Version__r.Solicitation_Manager__r.Buyer_Id__c ,Synopsis__c,Additional_Information_for_Award_Letter__c, Recommendation__c, Recoupment__c, Exceptions_to_T_C__c, Solicitation_Group__r.Name, ';
               query  += 'Concept_Paper_Result__c, Proposal_Result__c, Finalize_Score_Date__c, ';
               query  += '(SELECT Display_Label__c, Proposal_Question_Answer__c from Project_Contents__r where RecordType.DeveloperName = \'Proposal\' AND Type__c = \'Proposal Checklist Questions\' ) ';

        query+= ' from project__c ';
        boolean whereAdded = false;
        if(!String.isEmpty(proj.status__c)){
            whereAdded = true;
            query+= ' where status__C = : status ';
        }
        if(isConceptPaper != null){
            if(whereAdded){
                query+= ' and Concept_Paper__c = ' + isConceptPaper + ' ';
            }else{
                query+= ' where Concept_Paper__c = ' + isConceptPaper + ' ';
                whereAdded = true;
            }
        }
        if(!String.isEmpty(selectedProgramVersion)){
            if(whereAdded){
                query+= ' and Program_Version__c = :selectedProgramVersion ';
            }else{
                query+= ' where Program_Version__c = :selectedProgramVersion ';
                whereAdded = true;
            }
        }

        if(!String.isEmpty(Solicitationround)){
            if(whereAdded){
                query+= ' and Solicitation_Round__c = :Solicitationround ';
            }else{
                query+= ' where Solicitation_Round__c = :Solicitationround ';
                whereAdded = true;
            }
        }

        if(String.isNotBlank(selectedCategory)) {
          query += (((whereAdded) ? ' AND' : ' WHERE') + ' Proposed_Proposal_Category__c = :selectedCategory ');
        }

        if(String.isBlank(sortFieldName)) {
          sortFieldName = 'Proposed_Proposal_Category__c';
        }
        query += ' ORDER BY ' + sortFieldName;

        if(isSortingChanged && prevSortFieldName == sortFieldName) {
          isAsc = !isAsc;
        } else if(prevSortFieldName != sortFieldName){
          isAsc = true;
        }
        query += ((isAsc) ? ' ASC' : ' DESC') + ' NULLS LAST';
        prevSortFieldName = sortFieldName;
        isSortingChanged = false;

        sumtotalNysedra=0;
        sumtotalcostShare=0;
        sumtotalcost =0;
        sumremainingcost=0;
        system.debug('the query -----'+query);
        List<Project__c> projectList = (list<project__c>)Database.query(query);

        //system.assert(false, projectList);
        system.debug('the list ----'+projectList);
        List<boolean> temBoolean = new List<boolean>();
        //if(projectList.size() == 0) {
            mapWrapper = new Map<id,proposalWrapper>();
        //}
        for(project__c pro : projectList){
            temp = new proposalWrapper();
            if(selectedProgramVersion!=null){
                Id programversionId = selectedProgramVersion;
                temp.solfunding = mapoflifunnding.get(selectedProgramVersion.subString(0,15));
                temp.checkSelected = new map<id,boolean>();
                temp.remainigFields = new map<id,project_funding__c>();
                temp.oldremainigFields = new map<id,project_funding__c>();
                temp.oldcheckSelected = new map<id,boolean>();
                temp.projectFundIdToIsSelectedMap = new Map<String, Boolean>();
                if(temp.solfunding != null) {
                    for(Solicitation_Funding__c varloop: temp.solfunding){
                        temp.checkSelected.put(varloop.id,false);
                        temp.oldcheckSelected.put(varloop.id,false);
                        temp.remainigFields.put(varloop.id,new project_funding__c());
                        temp.oldremainigFields.put(varloop.id,new project_funding__c());
                    }
                }

            }
            temp.proContract = new Project_Contract__c();
            temp.proContractLine = new Project_Contract_Line__c();
            temp.proFund = new list<Project_Funding__c>();
            temp.fundToAmountMap = new Map<String, decimal>();
            temp.availableFunds = '';
            sumtotalNysedra+= pro.Proposed_NYSERDA_Cost__c == null ? 0: pro.Proposed_NYSERDA_Cost__c;
            sumtotalcostShare+= pro.Propsoed_Cost_Share__c == null ? 0: pro.Propsoed_Cost_Share__c;
            sumtotalcost += pro.Total_Project_Cost_Estimated__c  == null ? 0: pro.Total_Project_Cost_Estimated__c   ;
            sumremainingcost+= pro.Recommended_NYSERDA_Funding__c == null ? 0:  pro.Recommended_NYSERDA_Funding__c;

            temp.pro = pro;

            // Populate Is Confidential flag - related to I-02818 - Added by TK
            temp.isConfidential = false;
            if(pro.Project_Contents__r.size() > 0) {
              for(Project_Content__c objProContent : pro.Project_Contents__r) {
                if(objProContent.Display_Label__c == Label.Solicitation_Confidential_Question && objProContent.Proposal_Question_Answer__c == 'Yes') {
                  temp.isConfidential = true;
                  break;
                }
              }
            }

            // Add Solicitation Group
            temp.eligibleGroupList = new List<SelectOption>();
            temp.eligibleGroupList.add(new SelectOption('', '- None -'));
            if(solicitationRoundIdToGroupListMap.containsKey(pro.Solicitation_Round__c)) {
                for(Solicitation_Group__c groupRec : solicitationRoundIdToGroupListMap.get(pro.Solicitation_Round__c)) {
                    if(groupRec.Total_Members__c >= 2) {
                        temp.eligibleGroupList.add(new SelectOption(groupRec.Id, groupRec.Name));
                    }
                }
            }

            if(!pro.Finalize_Result__c && pro.Status__c == 'Under Review') {
                isfinlizeScoreNeeded = true;
            }

            System.debug(pro.Primary_Contractor_First_Name_Hidden__c);
            mapWrapper.put(pro.id,temp);
        }

        system.debug('mapWrapper  \n\n\n' + mapWrapper);

        Set<String> validRoles = new Set<String>{ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE,ProjectRole_Helper.PROJECT_MANAGER_ROLE};

        for(Project_Role__c varloop: [select Project__c, User__c, User__r.Name, firstname__c,
                                             lastname__c,Role__c,Primary_Customer_Contact__c,
                                             User__r.Buyer_Id__c, Contact__c, Account__c,
                                             Contact__r.Account.Supplier_ID__c,Account__r.Supplier_ID__c,
                                             Account_Name_Hidden__c
                                      from   Project_Role__c
                                      where  project__c in : mapWrapper.keySet()]){
                                          temp = mapWrapper.get(varloop.project__c);
                                          if(temp!=null){
                                              System.debug('debug==> '+ varloop);
                                              if(varloop.role__c == ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE || varloop.role__c == ProjectRole_Helper.PROJECT_PROPOSER_ROLE){
                                                  temp.roleContractor = varloop;
                                              }else if(varloop.role__c == ProjectRole_Helper.PROJECT_MANAGER_ROLE){
                                                  temp.roleManager = varloop;
                                              }
                                          }
                                      }


        if(selectedProgramVersion !=null){
            Set<id> retrivalforProjectfunding = new set<id>();
            for(Project_Contract__c varloop:[select id,project__c,(select id from Supplier_Contract_POs__r )
                                             from Project_Contract__c
                                             where project__c in : mapWrapper.keySet() ]){
                                                 temp = mapWrapper.get(varloop.project__c);
                                                 if(temp!=null){
                                                     temp.proContract = varloop;
                                                     if(varloop.Supplier_Contract_POs__r.size() > 0){
                                                         temp.proContractLine =   varloop.Supplier_Contract_POs__r[0];
                                                         retrivalforProjectfunding.add(temp.proContractLine.id);
                                                     }
                                                 }
                                                 system.debug('temp.proContract==>'+temp.proContract);
                                                 system.debug('temp.proContractLine==>'+temp.proContractLine);
                                             }
            maplinkFunding = new map<String,string>();
            set<id> solSet = new set<id>();
            System.debug('retrivalforProjectfunding==>'+retrivalforProjectfunding);
            //system.assert(false, retrivalforProjectfunding);
            for(Project_Funding__c varloop:[select id, Project_Contract__c,Project_Contract_line__r.Project_Contract__r.project__c, Project_ID__c,
                                            Solicitation_External_Id__c,Activity_ID__c,Account_Number__c,Department__c,fund__c,Distribution_Amount__c
                                            from Project_Funding__c
                                            where Project_Contract_line__c in : retrivalforProjectfunding ]){
                                                //System.debug('varloop==>'+varloop);
                                                maplinkFunding.put(varloop.Solicitation_External_Id__c,varloop.id);
                                                temp = mapWrapper.get(varloop.Project_Contract_line__r.Project_Contract__r.project__c);
                                                if(temp!=null){
                                                    integer i = 0;
                                                    //System.debug('Temp.checkSelected==>'+Temp.checkSelected);
                                                    //System.debug('Temp.checkSelected.get(varloop.Solicitation_External_Id__c)==>'+Temp.checkSelected.get(varloop.Solicitation_External_Id__c));
                                                    //if(Temp.checkSelected.get(varloop.Solicitation_External_Id__c)==null)
                                                        //continue;
                                                    Temp.checkSelected.put(varloop.Solicitation_External_Id__c,true);
                                                    Temp.oldremainigFields.put(varloop.Solicitation_External_Id__c,varloop);
                                                    Temp.remainigFields.put(varloop.Solicitation_External_Id__c,new Project_funding__c(id=varloop.id,Distribution_Amount__c = varloop.Distribution_Amount__c));
                                                    Temp.oldcheckSelected.put(varloop.Solicitation_External_Id__c,true);
                                                    if(varloop.Solicitation_External_Id__c != null) {
                                                        Temp.projectFundIdToIsSelectedMap.put(varloop.Fund__c, true);
                                                    } else {
                                                        Temp.projectFundIdToIsSelectedMap.put(varloop.Fund__c, false);
                                                    }

                                                    temp.proFund.add(varloop);
                                                    temp.fundToAmountMap.put(varloop.Fund__c, (varloop.Distribution_Amount__c != null) ? varloop.Distribution_Amount__c : 0);
                                                    //system.debug('temp fundToAmountMap '+temp.fundToAmountMap);
                                                    temp.availableFunds += ';'+varloop.Fund__c;
                                                }
                                            }

            if(mapoflifunnding.containsKey(selectedProgramVersion)) {
                for(Solicitation_Funding__c solicitationFundingRec : mapoflifunnding.get(selectedProgramVersion)) {
                	//system.debug(' solicitationFundingRec Name ===>> '+solicitationFundingRec.Name);
                    if(temp != null && solicitationFundingRec.Name != null && temp.fundToAmountMap.size() > 0 && !temp.fundToAmountMap.containsKey(solicitationFundingRec.Name)) {
                        temp.fundToAmountMap.put(solicitationFundingRec.Name, 0);
                        temp.availableFunds += ';'+solicitationFundingRec.Name;
                    }
                }
            }

        }

        liproposalWrapper = mapWrapper.values();
        //system.assert(false, liproposalWrapper[0].proFund);

        // Set Total Fund Amount Value
        fundToTotalAmountMap = new Map<String, decimal>();
        fundToTotalAmountMap_containsCheck =  new Map<String, String>();
        for(ProposalWrapper projectObj : liproposalwrapper){
          fundToTotalAmountMap_containsCheck.put(projectObj.pro.Id, '');
            for(String fundName : projectObj.fundToAmountMap.keyset()) {
              fundToTotalAmountMap_containsCheck.put(projectObj.pro.Id, fundToTotalAmountMap_containsCheck.get(projectObj.pro.Id) + fundName + ';');

                if(!fundToTotalAmountMap.containsKey(fundName)) {
                    fundToTotalAmountMap.put(fundName, 0);
                }
                Decimal previousFundAmount = fundToTotalAmountMap.get(fundName);
                fundToTotalAmountMap.put(fundName,  previousFundAmount +
                                                    (projectObj.fundToAmountMap.get(fundName) != null ? projectObj.fundToAmountMap.get(fundName) : 0)
                                         );

            }
        }
        //system.assert(false, fundToTotalAmountMap);

        // Check for Project Manager
        for(ProposalWrapper projectObj : liproposalwrapper){
            if(projectObj.roleManager == null){
                projectObj.roleManager = new Project_Role__c(Project__c = projectObj.pro.Id, Role__c = ProjectRole_Helper.PROJECT_MANAGER_ROLE, Primary_Customer_Contact__c = true);
            }
        }


        // T-02656 - Snapshot the recommendation values
        greenlightValueChanged = false;
        greenlightValuesSnapshot = new Map<Id, String>();
        for(ProposalWrapper proposalWrapperObj : liproposalwrapper) {
          if(proposalWrapperObj.pro != null && proposalWrapperObj.pro.Id != null) {
            greenlightValuesSnapshot.put(proposalWrapperObj.pro.Id, proposalWrapperObj.pro.Recommendation__c);
          }
        }
        // T-02656 - Snapshot the recommendation values

        if(isExport) {
            checkForUser();
            setDownloadData();
        }

        /*integer i = 1;
        for(proposalWrapper projectObj : liproposalwrapper){
            if(projectObj.roleManager==null){
                projectObj.roleManager = new Project_Role__c(project__c = projectObj.pro.id, role__c= ProjectRole_Helper.PROJECT_MANAGER_ROLE);
            }

            // Data Download feature
            /*dataDownload +=i+','+ (varloop.pro.rank__c != null ? varloop.pro.rank__c : '') +',' + (varloop.pro.name != null ? varloop.pro.name : '') +','
                + (varloop.pro.Solicitation_Round__r.name != null ? varloop.pro.Solicitation_Round__r.name : '') +','
                + (varloop.pro.Status__c != null ? varloop.pro.Status__c : '') +',' + (varloop.roleContractor != null && varloop.roleContractor.firstname__c != null ? varloop.roleContractor.firstname__c : '') +' '+
                  (varloop.roleContractor != null && varloop.roleContractor.lastname__c != null ? varloop.roleContractor.lastname__c : '')+','
                + (varloop.pro.Proposed_NYSERDA_Cost__c != null ? varloop.pro.Proposed_NYSERDA_Cost__c : 0) +',' +
                  (varloop.pro.Propsoed_Cost_Share__c != null ? varloop.pro.Propsoed_Cost_Share__c : 0) +','
                + (varloop.pro.Total_Project_Cost_Estimated__c   != null ? varloop.pro.Total_Project_Cost_Estimated__c   : 0) +','
                + (varloop.pro.Recommended_NYSERDA_Funding__c != null ? varloop.pro.Recommended_NYSERDA_Funding__c : 0) +',' +
                (varloop.rolemanager != null && varloop.rolemanager.firstname__c != null ? varloop.rolemanager.firstname__c : '') +' '+
                (varloop.rolemanager != null && varloop.rolemanager.lastname__c != null ? varloop.rolemanager.lastname__c : '');

            dataDownload +=',';

             if(varloop.solfunding != null){
                for(Solicitation_Funding__c funding : varloop.solfunding){
                    if(varloop.checkselected.get(funding.Id) && varloop.remainigFields != null &&
                       varloop.remainigFields.containsKey(funding.Id) &&
                       varloop.remainigFields.get(funding.Id) != null &&
                       varloop.remainigFields.get(funding.Id).Distribution_Amount__c != null){
                        dataDownload +=',' + varloop.remainigFields.get(funding.Id).Distribution_Amount__c;
                    }else{
                        dataDownload +=',';
                    }
                }
            }*/
            /*dataDownload += i + ',';
            Integer counter = 0;
            for(Integer j = 0; j < (projectFieldList_Download.size() + 1) ; j++) {
                if(j == 2) {
                    dataDownload += ((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + ',';
                } else {
                    dataDownload += (projectObj.pro.get(projectFieldList_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_Download[counter])).replaceAll('<[/a-zAZ0-9]*>','') : '') + ',';
                    counter++;
                }
            }
            Integer totalFundLines = 0;
            for(Project_Funding__c fundLine : projectObj.proFund) {
                for(Integer j = 0; j < fundingFieldList_Download.size() ; j++) {
                    dataDownload += (fundLine.get(fundingFieldList_Download[j]) != null ? fundLine.get(fundingFieldList_Download[j]) : '') + ',';
                }
                if((totalFundLines + 1) < projectObj.proFund.size()) {
                    dataDownload += '\n,,,,,,,,,,,,,,,,';
                }
                totalFundLines++;
            }
            dataDownload += '\n';
            i++;
        }*/

    }

     /*
      * Method Name: setDownloadData
      * Description: Method to set download data
      * @param: None
      * @return: void
      */

    private void setDownloadData() {
        dataDownload = '';
        if(Proj.Status__c == 'Under Review') {
            if(!isConceptPaper) {
                if(isSolicitationManager || isProgramManager || isProjectCoordinator) {
                    dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,RANK,PROPOSER NAME,PROPOSAL TITLE,CONFIDENTIAL,OBJECTIVE / SCOPE,IMPACTS / BENEFITS,PROPOSAL STRENGTHS,PROPOSAL WEAKNESSES,'
                                    + 'RISKS,REQUESTED FUNDING $,RECOMMENDED FUNDING $,CONTINGENCIES / RECOMMENDATIONS,SYNOPSIS,ADDITIONAL INFORMATION FOR AWARD LETTER,SCORING COMMITTEE RECOMMENDATION,RECOMMENDATION,RECOUPMENT,ACCEPTS T&C,'
                                    + 'PROJECT MANAGER,FUND,AMOUNT,PROJECT,ACTIVITY,ACCOUNT';
                } else if(isContractOfficeManager) {
                    dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,RANK,PROPOSER NAME,PROPOSAL TITLE,CONFIDENTIAL,'
                                    + 'REQUESTED FUNDING $,RECOMMENDED FUNDING $,SCORING COMMITTEE RECOMMENDATION,RECOMMENDATION,RECOUPMENT,ACCEPTS T&C,'
                                    + 'PROJECT MANAGER,FUND,AMOUNT,PROJECT,ACTIVITY,ACCOUNT';
                } else if(isScoringCommiteeMember || isProgramStaff) {
                    dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,PROPOSER NAME,PROPOSAL TITLE,CONFIDENTIAL,OBJECTIVE / SCOPE,IMPACTS / BENEFITS,PROPOSAL STRENGTHS,PROPOSAL WEAKNESSES,'
                                    + 'RISKS,REQUESTED FUNDING $,CONTINGENCIES / RECOMMENDATIONS,SYNOPSIS,ADDITIONAL INFORMATION FOR AWARD LETTER,'
                                    + 'PROJECT MANAGER';
                }
            } else {
                if(isSolicitationManager || isProgramManager || isProjectCoordinator) {
                    dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,RANK,PROPOSER NAME,PROPOSAL TITLE,OBJECTIVE / SCOPE,IMPACTS / BENEFITS,PROPOSAL STRENGTHS,PROPOSAL WEAKNESSES,'
                                    + 'REQUESTED FUNDING $,CONTINGENCIES / RECOMMENDATIONS,SYNOPSIS,ADDITIONAL INFORMATION FOR AWARD LETTER,SCORING COMMITTEE RECOMMENDATION,RECOMMENDATION';
                } else if(isContractOfficeManager) {
                    dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,RANK,PROPOSER NAME,PROPOSAL TITLE,'
                                    + 'REQUESTED FUNDING $,SCORING COMMITTEE RECOMMENDATION,RECOMMENDATION';
                } else if(isScoringCommiteeMember || isProgramStaff) {
                    dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,PROPOSER NAME,PROPOSAL TITLE,OBJECTIVE / SCOPE,IMPACTS / BENEFITS,PROPOSAL STRENGTHS,PROPOSAL WEAKNESSES,'
                                    + 'REQUESTED FUNDING $,CONTINGENCIES / RECOMMENDATIONS,SYNOPSIS,ADDITIONAL INFORMATION FOR AWARD LETTER';
                }
            }
        } else if(Proj.Status__c == 'Submitted' || Proj.Status__c == 'Pending Review') {
            dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,PROPOSER NAME,PROPOSAL TITLE,STATUS,SOLICITATION ROUND,PROPOSED NYSERDA COST,PROPOSED COST SHARE,'
                                + 'PROPOSED TOTAL COST';

        } else if(Proj.Status__c == 'Awarded') {
            dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,RANK,PROJECT NAME,SOLICITATION ROUND,STATUS,PROPOSER,PROPOSED NYSERDA COST,PROPOSED COST SHARE,'
                                + 'PROPOSED TOTAL COST,RECOMMENDED NYSERDA FUNDING,PROJECT PM,';

            if(mapoflifunnding.containsKey(selectedProgramVersion) && mapfundingexist.containsKey(selectedProgramVersion) && mapfundingexist.get(selectedProgramVersion)) {
                for(Solicitation_Funding__c fundLineRec : mapoflifunnding.get(selectedProgramVersion)) {
                    dataDownload += fundLineRec.Name + ',';
                }
            }
        } else {
            dataDownload = 'PROPOSER NUMBER,PROPOSED CATEGORY,RANK,PROJECT NAME,SOLICITATION ROUND,STATUS,PROPOSER,PROPOSED NYSERDA COST,PROPOSED COST SHARE,'
                                + 'PROPOSED TOTAL COST,RECOMMENDED NYSERDA FUNDING,PROJECT PM,PROJECT TYPE,STRENGTH AND WEAKNESS';
        }

        dataDownload +='\n';
        // TK/AG: I-03073 - Excel Export from proposal review page issue
        Integer i = 1;
        for(proposalWrapper projectObj : liproposalwrapper){
            if(projectObj.roleManager == null){
                projectObj.roleManager = new Project_Role__c(project__c = projectObj.pro.id, role__c= ProjectRole_Helper.PROJECT_MANAGER_ROLE, Primary_Customer_Contact__c = true);
            }
            dataDownload += '"'+((projectObj.pro.Proposal_Number__c != null) ? String.valueOf(projectObj.pro.Proposal_Number__c) : '')+ '",';

            if(Proj.Status__c == 'Under Review') {  // I-03193: Rich Text Area field special char handling by unescapeHtml4
                if(!isConceptPaper) {
                    if(isSolicitationManager || isProgramManager || isProjectCoordinator) {
                        Integer counter = 0;
                        for(Integer j = 0; j < (projectFieldList_UnderReview_Download.size() + 3) ; j++) {
                            if(j == 2) {
                                dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                            } else if(j == 4) {
                                dataDownload += '"'+projectObj.isConfidential + '",';
                            } else if(j == 19) {
                                dataDownload += '"'+((projectObj.roleManager.User__r.Name != null) ? projectObj.roleManager.User__r.Name : '') + '",';
                            } else {
                                dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                                counter++;
                            }
                        }
                        Integer totalFundLines = 0;
                        for(Project_Funding__c fundLine : projectObj.proFund) {
                            for(Integer j = 0; j < fundingFieldList_Download.size() ; j++) {
                                dataDownload += '"'+(fundLine.get(fundingFieldList_Download[j]) != null ? fundLine.get(fundingFieldList_Download[j]) : '') + '",';
                            }
                            if((totalFundLines + 1) < projectObj.proFund.size()) {
                                dataDownload += '\n,,,,,,,,,,,,,,,,,,,,,';
                            }
                            totalFundLines++;
                        }
                    }

                    else if(isContractOfficeManager) {
                        Integer counter = 0;
                        for(Integer j = 0; j < (projectFieldList_UnderReview_Download.size() + 3) ; j++) {
                            if(j == 5 || j == 6 || j == 7 || j == 8 || j == 9 || j == 12 || j == 13 || j == 14) {
                                counter++;
                                continue;
                            } else if(j == 2) {
                                dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                            } else if(j == 4) {
                                dataDownload += '"'+projectObj.isConfidential + '",';
                            } else if(j == 19) {
                                dataDownload += '"'+((projectObj.roleManager.User__r.Name != null) ? projectObj.roleManager.User__r.Name : '') + '",';
                            } else {
                                dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                                counter++;
                            }
                        }
                        Integer totalFundLines = 0;
                        for(Project_Funding__c fundLine : projectObj.proFund) {
                            for(Integer j = 0; j < fundingFieldList_Download.size() ; j++) {
                                dataDownload += '"'+(fundLine.get(fundingFieldList_Download[j]) != null ? fundLine.get(fundingFieldList_Download[j]) : '') + '",';
                            }
                            if((totalFundLines + 1) < projectObj.proFund.size()) {
                                dataDownload += '\n,,,,,,,,,,,,,';
                            }
                            totalFundLines++;
                        }
                    }

                    else if(isScoringCommiteeMember || isProgramStaff) {
                        Integer counter = 0;
                        for(Integer j = 0; j < (projectFieldList_UnderReview_Download.size() + 3) ; j++) {
                            if(j == 1 || j == 11 || j == 15 || j == 16  || j == 17 || j == 18) {
                                counter++;
                                continue;
                            } else if(j == 2) {
                                dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                            } else if(j == 4) {
                                dataDownload += '"'+projectObj.isConfidential + '",';
                            } else if(j == 19) {
                                dataDownload += '"'+((projectObj.roleManager.User__r.Name != null) ? projectObj.roleManager.User__r.Name : '') + '",';
                            } else {
                                dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                                counter++;
                            }
                        }
                    }
                } else {
                    if(isSolicitationManager || isProgramManager || isProjectCoordinator) {
                        Integer counter = 0;
                        for(Integer j = 0; j < (projectFieldList_UnderReview_Download.size() + 2) ; j++) {
                            if(j == 2) {
                                dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                            } else if(j == 18 || projectFieldList_UnderReview_Download[counter] == 'Proposal_Risks__c' || projectFieldList_UnderReview_Download[counter] == 'Recommended_NYSERDA_Funding__c'
                                        || projectFieldList_UnderReview_Download[counter] == 'Recoupment__c' || projectFieldList_UnderReview_Download[counter] == 'Exceptions_to_T_C__c') {
                                counter++;
                                continue;
                            } else {
                                dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).
                                        replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                                counter++;
                            }
                        }
                    }

                    else if(isContractOfficeManager) {
                        Integer counter = 0;
                        for(Integer j = 0; j < (projectFieldList_UnderReview_Download.size() + 2) ; j++) {
                            if(j == 4 || j == 5 || j == 6 || j == 7 || j == 8 || j == 10 || j == 11 || j == 12 || j == 13 ) {
                                counter++;
                                continue;
                            } else if(j == 2) {
                                dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                            } else if(j == 18) {
                                dataDownload += '"'+((projectObj.roleManager.User__r.Name != null) ? projectObj.roleManager.User__r.Name : '') + '",';
                            } else {
                                dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                                counter++;
                            }
                        }
                    }

                    else if(isScoringCommiteeMember || isProgramStaff) {
                        Integer counter = 0;
                        for(Integer j = 0; j < (projectFieldList_UnderReview_Download.size() + 1) ; j++) {
                            if(j == 1 || j == 10 || j == 14 || j == 15 || j == 16  || j == 17 || projectFieldList_UnderReview_Download[counter] == 'Proposal_Risks__c') {
                                counter++;
                                continue;
                            } else if(j == 2) {
                                dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                            } else {
                                dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                                counter++;
                            }
                        }
                    }
                }
            }
            else if(Proj.Status__c == 'Submitted' || Proj.Status__c == 'Pending Review') {
                Integer counter = 0;
                for(Integer j = 0; j < (projectFieldList_Submitted_PendingReview_Download.size() + 3) ; j++) {
                    if(j == 1) {
                        dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                    } else if(j == 4) {
                        dataDownload += '"'+(projectObj.pro.Solicitation_Round__r.Name != null ? projectObj.pro.Solicitation_Round__r.Name : '') + '",';
                    } else if(j == 8) {
                        dataDownload += '"'+(projectObj.pro.Solicitation_Group__r.Name != null ? projectObj.pro.Solicitation_Group__r.Name : '') + '",';
                    } else {
                        dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                        counter++;
                    }
                }
            }

            else if(Proj.Status__c == 'Awarded') {
                Integer counter = 0;
                for(Integer j = 0; j < (projectFieldList_Download.size() + 2) ; j++) {
                    if(j == 3) {
                        dataDownload += '"'+(projectObj.pro.Solicitation_Round__r.Name != null ? projectObj.pro.Solicitation_Round__r.Name : '') + '",';
                    } else if(j == 5) {
                        dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                    } else if(j == 10) {
                        dataDownload += '"'+((projectObj.roleManager.User__r.Name != null) ? projectObj.roleManager.User__r.Name : '') + '",';
                    } else {
                        dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                        counter++;
                    }
                }

                if(mapfundingexist.containsKey(selectedProgramVersion) && mapfundingexist.get(selectedProgramVersion) && mapoflifunnding.containsKey(selectedProgramVersion)) {
                    for(Solicitation_Funding__c soliFundRec : mapoflifunnding.get(selectedProgramVersion)) {
                        if(projectObj.availableFunds.contains(soliFundRec.Name) && projectObj.fundToAmountMap.get(soliFundRec.Name) != null) {
                            dataDownload += '"'+String.valueOf(projectObj.fundToAmountMap.get(soliFundRec.Name)) + '",';
                        } else {
                            dataDownload += ',';
                        }
                    }
                }
            }

            else {
                Integer counter = 0;
                for(Integer j = 0; j < (projectFieldList_Download.size() + 3) ; j++) {
                    if(j == 3) {
                        dataDownload += '"'+(projectObj.pro.Solicitation_Round__r.Name != null ? projectObj.pro.Solicitation_Round__r.Name : '') + '",';
                    } else if(j == 5) {
                        dataDownload += '"'+((projectObj.roleContractor.Account_Name_Hidden__c != null) ? projectObj.roleContractor.Account_Name_Hidden__c : '') + '",';
                    } else if(j == 10) {
                        dataDownload += '"'+((projectObj.roleManager.User__r.Name != null) ? projectObj.roleManager.User__r.Name : '') + '",';
                    } else if(j == 11) {
                        dataDownload += ',';
                    } else {
                        dataDownload += '"'+(projectObj.pro.get(projectFieldList_UnderReview_Download[counter]) != null ? String.valueOf(projectObj.pro.get(projectFieldList_UnderReview_Download[counter])).replaceAll('\\s',' ').replaceAll('<[^>]+>',' ').replaceAll('<br>', '').replaceAll('[^\\x00-\\x7F]', '').unescapeHtml4() : '') + '",';
                        counter++;
                    }
                }
            }
            dataDownload += '\n';
            i++;
        }
        if(Proj.Status__c == 'Under Review') {
            if(!isConceptPaper) {
                if(isSolicitationManager || isProgramManager || isProjectCoordinator) {
                    dataDownload += ',,,,,,,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) ;
                } else if(isContractOfficeManager) {
                    dataDownload += ',,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) ;
                } else if(isScoringCommiteeMember || isProgramStaff) {
                    dataDownload += ',,,,,,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) ;
                }
            } else {
                if(isSolicitationManager || isProgramManager || isProjectCoordinator) {
                    dataDownload += ',,,,,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) ;
                } else if(isContractOfficeManager) {
                    dataDownload += ',,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) ;
                } else if(isScoringCommiteeMember || isProgramStaff) {
                    dataDownload += ',,,,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) ;
                }
            }

        } else if(Proj.Status__c == 'Submitted' || Proj.Status__c == 'Pending Review') {
            dataDownload += ',,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) +','+ (sumtotalcostShare != null ? sumtotalcostShare : 0) +
                                    ','+ (sumtotalcost != null ? sumtotalcost : 0);

        } else if(Proj.Status__c == 'Awarded'){
            dataDownload += ',,,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) +','+ (sumtotalcostShare != null ? sumtotalcostShare : 0) +
                                    ','+ (sumtotalcost != null ? sumtotalcost : 0) + ',' + (sumremainingcost != null ? sumremainingcost : 0) + ',,' ;

            if(mapfundingexist.containsKey(selectedProgramVersion) && mapfundingexist.get(selectedProgramVersion) && mapoflifunnding.containsKey(selectedProgramVersion)) {
                for(Solicitation_Funding__c soliFundRec : mapoflifunnding.get(selectedProgramVersion)) {
                    if(fundToTotalAmountMap.containsKey(soliFundRec.Name) && fundToTotalAmountMap.get(soliFundRec.Name) != null) {
                        dataDownload += '"'+String.valueOf(fundToTotalAmountMap.get(soliFundRec.Name)) + '",';
                    } else {
                        dataDownload += ',';
                    }
                }
            }
        }
        else {
            dataDownload += ',,,,,,,'+ (sumtotalNysedra != null ? sumtotalNysedra : 0) +','+ (sumtotalcostShare != null ? sumtotalcostShare : 0) +
                                    ','+ (sumtotalcost != null ? sumtotalcost : 0) + ',' + (sumremainingcost != null ? sumremainingcost : 0);
        }
        //system.assert(false, dataDownload);
    }


    private List<String> projectFieldList_Download = new List<String>{'Proposed_Proposal_Category__c',
                                                                        'Rank__c',
                                                                        'Name',
                                                                        'Status__c',
                                                                        'Proposed_NYSERDA_Cost__c',
                                                                        'Propsoed_Cost_Share__c',
                                                                        'Total_Project_Cost_Estimated__c',
                                                                        'Recommended_NYSERDA_Funding__c',
                                                                        'Strength_Weakness__c'
                                                                    };

    private List<String> projectFieldList_Submitted_PendingReview_Download = new List<String>{'Proposed_Proposal_Category__c',
                                                                            'Name',
                                                                            'Status__c',
                                                                            'Proposed_NYSERDA_Cost__c',
                                                                            'Propsoed_Cost_Share__c',
                                                                            'Total_Project_Cost_Estimated__c'
                                                                    };


    private List<String> projectFieldList_UnderReview_Download = new List<String>{'Proposed_Proposal_Category__c',
                                                                        'Rank__c',
                                                                        'Name',
                                                                        'Description__c',
                                                                        'Impacts_Benefits__c',
                                                                        'Proposal_Strengths__c',
                                                                        'Proposal_Weaknesses__c',
                                                                        'Proposal_Risks__c',
                                                                        'Proposed_NYSERDA_Cost__c',
                                                                        'Recommended_NYSERDA_Funding__c',
                                                                        'Contingencies_Recommendations__c',
                                                                        'Synopsis__c',
                                                                        'Additional_Information_for_Award_Letter__c',
                                                                        'Scoring_Committee_Recommendation__c',
                                                                        'Recommendation__c',
                                                                        'Recoupment__c',
                                                                        'Exceptions_to_T_C__c'
                                                                    };

    private List<String> fundingFieldList_Download = new List<String>{'Fund__c',
                                                                        'Distribution_Amount__c',
                                                                        'Project_ID__c',
                                                                        'Activity_ID__c',
                                                                        'Account_Number__c'
                                                                    };

      /*
      * Method Name: createContractAndContractLineRecords
      * Description: Method to create contract and contract line records
      * @param: None
      * @return: void
      */

    private void createContractAndContractLineRecords(List<Id> projectIdList) {
        List<Project__c> projectList = [select Program_Version__r.Buyer_ID__c, Program_Version__r.Header_Description__c,
                                               Program_Version__r.Agreement_Code__c, Program_Version__r.Anticipated_Term_Over_A_Year__c,
                                               Program_Version__r.Procurement_Contract__c, Program_Version__r.Procurement_Method__c,
                                               Program_Version__r.Category__c, Name, Submitted_Date__c, Solicitation_Round__r.Name
                                          from Project__c
                                         where Id IN: projectIdList];
        if(projectList.size() == 0) {
            return;
        }

        ProjectContractCreation_Service.projectContractsMap = new Map<Integer, Project_Contract__c>();
        ProjectContractCreation_Service.projectContractLinesMap = new Map<Integer, Project_Contract_Line__c>();
        ProjectContractCreation_Service.contractlineToContractMapping = new Map<Integer, Integer>();
        ProjectContractCreation_Service.projectUniqueId = 1;
        ProjectContractCreation_Service.projectLineUniqueId = 1;

        Map<Integer, Id> projectUniqueIdToProjectIdMap = new Map<Integer, Id>();
        Integer projectUniqueId = 1;
        for(Project__c pro : projectList) {
            ProjectContractCreation_Service.createContracDataForCTProjects(pro);
            projectUniqueIdToProjectIdMap.put(projectUniqueId, pro.Id);
            projectUniqueId++;
        }

        Map<Integer, Project_Contract__c> projectContractsMap = ProjectContractCreation_Service.projectContractsMap;
        Map<Integer, Project_Contract_Line__c> projectContractLinesMap = ProjectContractCreation_Service.projectContractLinesMap;
        if(projectContractsMap.values().size() > 0) {
            insert projectContractsMap.values();

            for(Integer i = 1; i <= projectContractLinesMap.size(); i++) {
                if(projectContractLinesMap.containsKey(i)) {
                    projectContractLinesMap.get(i).Project_Contract__c = projectContractsMap.containsKey(i) ? projectContractsMap.get(i).Id : null;
                }
            }
            if(projectContractLinesMap.values().size() > 0) {
                insert projectContractLinesMap.values();
            }
        }

        for(Integer i : projectUniqueIdToProjectIdMap.keySet()) {
            proposalWrapper temp = mapWrapper.get(projectUniqueIdToProjectIdMap.get(i));
            if(projectContractsMap.containsKey(i)) {
                temp.proContract = projectContractsMap.get(i);
            }
            if(projectContractLinesMap.containsKey(i)) {
                temp.proContractLine = projectContractLinesMap.get(i);
            }
        }
    }

     /*
      * Method Name: backToSolicitation
      * Description: Method to get back to the solicitation
      * @param: None
      * @return: pageReference
      */

    public pageReference backToSolicitation() {
        pageReference page = new pageReference('/'+Apexpages.currentPage().getParameters().get('solicitationID'));
        page.setRedirect(true);
        return page;
    }



    public class proposalWrapper {

        public List<Solicitation_Funding__c> solfunding{Get;set;}
        public Project_Contract__c proContract{get;set;}
        public Project_Contract_Line__c proContractLine{get;set;}
        public list<Project_Funding__c> proFund{get;set;}
        public Map<String, decimal> fundToAmountMap{get;set;}
        public map<id,boolean> checkSelected{Get;set;}
        public Map<String, Boolean> projectFundIdToIsSelectedMap{get;set;}
        public map<id,Project_Funding__c> remainigFields{Get;set;}
        public map<id,Project_Funding__c> oldremainigFields{Get;set;}
        public map<id,boolean> oldcheckSelected{Get;set;}
        public project__c pro{get;set;}
        public Project_Role__c roleContractor{get;set;}
        public Project_Role__c roleManager{get;set;}
        public Boolean isSelected {get; set;}
        public List<SelectOption> eligibleGroupList {get; set;}
        public String availableFunds{get;set;}
        public Boolean isConfidential{get;set;}

        public proposalWrapper(){
            isSelected = false;

            solfunding = new List<Solicitation_Funding__c>(); // I-02745
            proFund = new list<Project_Funding__c> ();
            checkSelected = new map<id,boolean> ();
            remainigFields = new map<id,Project_Funding__c>();
            oldremainigFields = new map<id,Project_Funding__c>();
            oldcheckSelected = new map<id,boolean> ();
            eligibleGroupList = new List<SelectOption> ();

        }
    }


    public String rowNumber{get;set;}
    public Boolean hasAlreadyScoreGiven {get; set;}

     /*
      * Method Name: fetchCurrentProject
      * Description: Method to fetch current project
      * @param: None
      * @return: void
      */

    public void fetchCurrentProject() {
        allowUpdate = true;
        // Start of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending
        previewEmailBody = previewEmailSubject = null;
        // End of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending
        proj = liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro;
    }

   /*
    * Method Name: fetchCurrentProjectForPreview
    * Description: Method to fetch current project for preview modal window
    * @param: None
    * @return: void
    */
    public Project__c objProj {get; set;} // T-02835
    public void fetchCurrentProjectForPreview() {
        // Start of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending
        previewEmailBody = previewEmailSubject = null;
        // End of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending

      Project__c objTemp = liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro;
        objProj = new Project__c( Id = objTemp.Id,
                                  Proposal__c = objTemp.Proposal__c,
                                  Recommendation__c = objTemp.Recommendation__c,
                                  RecordTypeId = objTemp.RecordTypeId);
        if(String.isNotBlank(objProj.Recommendation__c)) {
          fetchNotification();
        }
    }

     /*
      * Method Name: saveStrengthWeakness
      * Description: Method to save strength weakness
      * @param: None
      * @return: void
      */

    public void saveStrengthWeakness() {
        update proj;
        startRetrieval();
    }

     /*
      * Method Name: allowSolicitationGroupCreation
      * Description: Method to allow solicitation group creation
      * @param: None
      * @return: pageReference
      */

    public pageReference allowSolicitationGroupCreation() {
        allowGrpCreation = true;
        solicitationGrp = new Solicitation_Group__c();
        solicitationGrp.Solicitation_Round__c = String.isNotBlank(proj.Solicitation_Round__c) ? proj.Solicitation_Round__c : currentOpenSolicitationRoundId;
        return null;
    }

     /*
      * Method Name: cancelGroupCreation
      * Description: Method to cancel group creation
      * @param: None
      * @return: pageReference
      */

    public pageReference cancelGroupCreation() {
        allowGrpCreation = false;
        return null;
    }

     /*
      * Method Name: saveSolicitationGroup
      * Description: Method to save solicitation group
      * @param: None
      * @return: pageReference
      */

    public pageReference saveSolicitationGroup() {
        allowGrpCreation = true;
        try {
            insert solicitationGrp;
            allowGrpCreation = false;
            populateSolicitationGroupList();
        } catch(DMLException e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

     /*
      * Method Name: saveProjectReviewInformation
      * Description: Method to save project review information
      * @param: None
      * @return: void
      */

    public void saveProjectReviewInformation() {
        isProjectReviewInfoSaved = false;
        try{
            update proj;
            isProjectReviewInfoSaved = true;
        } catch(DMLException e) {
            ApexPages.addMessages(e);
        }
        startRetrieval();
    }

     /*
      * Method Name: fetchProposalScoring
      * Description: Method to fetch Proposal Scoring
      * @param: None
      * @return: void
      */
  public String selectedProposerName {get; set;}
  public String selectedProposerNumber {get; set;}
    public void fetchProposalScoring() {
        proj = liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro;
        selectedProposerName = liproposalWrapper[(integer.valueOf(rowNumber))-1].roleContractor.Account_Name_Hidden__c;
        selectedProposerNumber = (proj.Proposal_Number__c != null) ? String.valueOf(proj.Proposal_Number__c) : '';
        scoringMembers = new list<SelectOption>();
        selectedScoringMember = null;
        userToScoreMap = new Map<Id, Proposal_Score__c>();
        proposalScoring = null;
        hasAlreadyScoreGiven = false;

        //allowResultUpdate = (!proj.Finalize_Result__c) ? true : false;

        //  I-03033
        allowResultUpdate = (!proj.Finalize_Result__c &&
                             (proj.Concept_Paper__c ? !proj.Solicitation_Round__r.Concept_Paper_Finalize_Score__c : !proj.Solicitation_Round__r.Proposal_Finalize_Score__c));

        List<Proposal_Score__c> proposalScoringList = [SELECT Score__c,Strengths__c,Recuse__c,
                                                              Weaknesses__c,Proposal__r.name,
                                                              Proposal__c, Scoring_Committee_Member__r.Member__r.name,
                                                              Scoring_Committee_Member__r.Scoring_Committee__c,
                                                              Scoring_Committee_Member__r.Member__c,
                                                              Scoring_Committee_Member__c
                                                         FROM Proposal_Score__c
                                                        WHERE Proposal__c =:liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro.ID];

        if(proposalScoringList.size() > 0) {
            for(Proposal_Score__c scoreRecord : proposalScoringList) {
                if(scoreRecord.Scoring_Committee_Member__r.Member__c == userInfo.getUserid()) {
                    proposalScoring = scoreRecord;
                    break;
                } else {
                    userToScoreMap.put(scoreRecord.Scoring_Committee_Member__c, scoreRecord);
                }
            }
            if(proposalScoring == null) {
                proposalScoring = identifyScore();
            }

        } else {
            proposalScoring = identifyScore();
        }

        if(proposalScoring != null && proposalScoring.Score__c != null && !isProgramStaff) {
            hasAlreadyScoreGiven = true;
        }
    }

    private Proposal_Score__c identifyScore() {
        Proposal_Score__c score;
        List<Solicitation_Review_Team__c> teamList = CORE_Proposal_Review_Service.getReviewTeamMembers(selectedProgramVersion);

        if(currentSolicitation.Score_Type__c == Solicitation_Helper.BATCH_RANK_SCORE_TYPE || liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro.Solicitation_Group__c != null) {

          List<Solicitation_Group_Member__c> groupMemberList = CORE_Proposal_Review_Service.getReviewTeamGroupMembers(liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro.Solicitation_Group__c);

          for(Solicitation_Group_Member__c team : groupMemberList) {
              if(team.Solicitation_Review_Team__r.Member__c == userInfo.getUserId()) {
                  score = new Proposal_Score__c(Scoring_Committee_Member__c = team.Solicitation_Review_Team__c, Proposal__c = liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro.ID);
                  scoringMembers.clear();
                  break;
              }
              scoringMembers.add(new SelectOption(team.Solicitation_Review_Team__c, team.Solicitation_Review_Team__r.Member__r.Name));
          }
        } else {
          for(Solicitation_Review_Team__c team : teamList) {
                if(team.Member__c == userInfo.getUserId()) {
                    score = new Proposal_Score__c(Scoring_Committee_Member__c = team.Id, Proposal__c = liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro.ID);
                    scoringMembers.clear();
                    break;
                }
                scoringMembers.add(new SelectOption(team.Id, team.Member__r.Name));
          }
        }

        if(score == null && teamList.size() > 0) {
            selectedScoringMember = teamList[0].Id;
            score = userToScoreMap.containsKey(teamList[0].Id)
                              ? userToScoreMap.get(teamList[0].Id)
                              : new Proposal_Score__c(Scoring_Committee_Member__c = teamList[0].Id, Proposal__c = liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro.ID);
        }
        return score;
    }

     /*
      * Method Name: cancelProposalScore
      * Description: Method to cancel Proposal Score
      * @param: None
      * @return: pageReference
      */

    public pageReference cancelProposalScore() {
      proposalScoring = null;
      return null;
    }

     /*
      * Method Name: fetchSelectedScorer
      * Description: Method to fetch Selected Scorer
      * @param: None
      * @return: void
      */

    public void fetchSelectedScorer() {

        //allowResultUpdate = (!proj.Finalize_Result__c || UserInfo.getProfileId() == systemAdminId) ? true : false;


        //  I-03033
        allowResultUpdate = (
                              (UserInfo.getProfileId() == systemAdminId)
                            ||
                              ( !proj.Finalize_Result__c &&
                                (proj.Concept_Paper__c ? !proj.Solicitation_Round__r.Concept_Paper_Finalize_Score__c : !proj.Solicitation_Round__r.Proposal_Finalize_Score__c))
                            );

        if(userToScoreMap.containsKey(selectedScoringMember)) {
            proposalScoring = userToScoreMap.get(selectedScoringMember);
        } else {
            proposalScoring = new Proposal_Score__c(Scoring_Committee_Member__c = selectedScoringMember, Proposal__c = liproposalWrapper[(integer.valueOf(rowNumber))-1].Pro.ID);
        }
    }

     /*
      * Method Name: saveProposalScoring
      * Description: Method to save Proposal Scoring
      * @param: None
      * @return: void
      */

    public void saveProposalScoring() {
        try{
            upsert proposalScoring;
        } catch(DMLexception e) {
            ApexPages.addMessages(e);
        }
        startRetrieval();
    }

     /*
      * Method Name: finalizeFinalScore
      * Description: Method to finalize Final Score
      * @param: None
      * @return: void
      */

    public void finalizeFinalScore() {
        List<Project__c> projectToBeUpdated = new List<Project__c>();
        set<Id> solicitationRoundIds = new Set<Id>();

        for(ProposalWrapper wrapper : liproposalWrapper) {
            if(!wrapper.Pro.Finalize_Result__c) {
                projectToBeUpdated.add(new Project__c(Id=wrapper.Pro.Id, Recalculate_Score__c = true));
            }
            solicitationRoundIds.add(wrapper.Pro.Solicitation_Round__c);
        }

        if(projectToBeUpdated.size() > 0) {
            update projectToBeUpdated;
        }

        if(solicitationRoundIds.size() > 0) {
            updateSolicitationRound(solicitationRoundIds);
        }

        startRetrieval();
    }

     /*
      * Method Name: updateSolicitationRound
      * Description: Method to update solicitation round
      * @param: set<ID> solicitationRoundIds
      * @return:static void
      */

    private static void updateSolicitationRound(set<ID> solicitationRoundIds) {

        Integer conceptFlag;            //compare the total concept paper
        Integer proposalFlag;           //compare the total proposal paper
        Integer conceptFinalFlag;
        Integer proposalFinalFlag;
        Integer flag;

        List<Solicitation_Round__c> validSolicitationRound = new List<Solicitation_Round__c>();

        List<Solicitation_Round__c> solicitationRoundList = new  List<Solicitation_Round__c>([SELECT Concept_Paper_Finalize_Score__c,Concept_Paper_Finalize_Score_Date__c,
                                                                                              Proposal_Finalize_Score__c,Proposal_Finalize_Score_Date__c,
                                                                                             (SELECT Finalize_Result__c,Concept_Paper__c,Proposal__c,Recalculate_Score__c
                                                                                              FROM Projects__r WHERE status__c =: Project_Helper.PROJECT_STATUS_UNDER_REVIEW)
                                                                                              FROM Solicitation_Round__c
                                                                                              WHERE ID IN : solicitationRoundIds]);
        for(Solicitation_Round__c solRound : solicitationRoundList) {
            conceptFlag=0;
            proposalFlag=0;
            flag = 0;
            conceptFinalFlag=0;
            proposalFinalFlag=0;

            if(solRound.Projects__r != null) {
                for(project__c project : solRound.Projects__r) {
                    flag++;
                    if(project.Finalize_Result__c && project.Concept_Paper__c) {      //if both the concept paper and finalize result will be true
                        conceptFinalFlag++;
                        conceptFlag++;
                    }
                    else if(!project.Finalize_Result__c && project.Concept_Paper__c){   //if the finalize result will be false and concept paper is true
                        conceptFlag++;
                    }
                    else if(project.Finalize_Result__c && project.Proposal__c) {        //if both the proposal paper and finalize result will be true
                        proposalFinalFlag++;
                        proposalFlag++;
                    }
                    else if(!project.Finalize_Result__c && project.Proposal__c) {       //if the finalize result will be false and Proposal paper is true
                        proposalFlag++;
                    }
                }


                System.debug(flag + '------' + conceptFinalFlag + '------' +  conceptFlag  + '------' + solRound.Concept_Paper_Finalize_Score__c
                                  + '------' + proposalFinalFlag + '------' + proposalFlag + '------' + solRound.Proposal_Finalize_Score__c );

                if(flag > 0 && conceptFinalFlag == conceptFlag && conceptFinalFlag > 0 && !solRound.Concept_Paper_Finalize_Score__c) {       // solicitation round will be updated if all the concept paper checks the finalize result
                    solRound.Concept_Paper_Finalize_Score__c = true;
                    solRound.Concept_Paper_Finalize_Score_Date__c = system.now();
                    validSolicitationRound.add(solRound);
                }

                if(flag > 0 && proposalFinalFlag == proposalFlag && proposalFinalFlag > 0 && !solRound.Proposal_Finalize_Score__c) {   // solicitation round will be updated if all the proposal paper checks the finalize result
                    solRound.Proposal_Finalize_Score__c = true;
                    solRound.Proposal_Finalize_Score_Date__c = system.now();
                    validSolicitationRound.add(solRound);
                }
            }
        }

        if(validSolicitationRound.size() > 0) {
            update validSolicitationRound;
        }

    }

     /*
      * Method Name: fetchProposalMatrix
      * Description: Method to fetch Proposal Matrix
      * @param: None
      * @return:pageReference
      */

    public pageReference fetchProposalMatrix() {
        proposalScoreMatrixMap = new Map<Id, List<ProposalScoreMatrixWrapper>>();
        solicitationGrpMap = new Map<Id, String>();
        Set<Id> validProjectIds = new Set<Id>();
        List<ProposalScoreWrapper> scoreList;
        grpToGrpMemberMap = new Map<Id, List<Solicitation_Group_Member__c>>();
        Set<Id> unquieReviewTeamSet = new Set<Id>();

        for(ProposalWrapper wrapper : liproposalWrapper) {
            validProjectIds.add(wrapper.Pro.Id);
        }

        for(Solicitation_Group__c grp : [SELECT Id, Solicitation_Round__c, Name,
                                                (SELECT Id, Solicitation_Group__c, Solicitation_Review_Team__c,
                                                        Solicitation_Review_Team__r.Member__r.Name
                                                   FROM Solicitation_Group_Members__r)
                                            FROM Solicitation_Group__c
                                           WHERE Solicitation_Round__r.Solicitation__c =:selectedProgramVersion]) {
            if(!grpToGrpMemberMap.containsKey(grp.Id)) {
                grpToGrpMemberMap.put(grp.Id, grp.Solicitation_Group_Members__r);
            }
        }

        reviewTeam = [SELECT Id, Member__c, Member__r.Name,
                             Scoring_Committee__c, Solicitation__c
                        From Solicitation_Review_Team__c
                       WHERE Solicitation__c =: selectedProgramVersion
                         AND Scoring_Committee__c = true
                         AND Member__c != null];

        for(Project__c project  : [Select Id, Name,Solicitation_Group__c, Solicitation_Group__r.Name,
                                          Proposal_Average_Score__c, Concept_Paper_Result__c,Proposal_Result__c,
                                          Finalize_Result__c, Proposal__c, Concept_Paper__c, Proposal_Number__c,
                                          Solicitation_Round__c, Solicitation_Round__r.Concept_Paper_Finalize_Score__c,
                                          Solicitation_Round__r.Proposal_Finalize_Score__c,
                                         (Select Id, Score__c, Proposal__c, Recuse__c, Scoring_Committee_Member__c,
                                                 Scoring_Committee_Member__r.Member__r.name
                                          From   Proposal_Scores__r)
                                   From Project__c
                                  Where Id IN: validProjectIds]) {
            scoreList = new List<ProposalScoreWrapper>();
            unquieReviewTeamSet.clear();

            if(project.Solicitation_Group__c != null) {
                solicitationGrpMap.put(project.Solicitation_Group__c, project.Solicitation_Group__r.Name);
            }

            if(currentSolicitation.Score_Type__c == Solicitation_Helper.BATCH_RANK_SCORE_TYPE) {
                if(project.Solicitation_Group__c != null && !proposalScoreMatrixMap.containsKey(project.Solicitation_Group__c)) {
                    proposalScoreMatrixMap.put(project.Solicitation_Group__c, new List<ProposalScoreMatrixWrapper>());
                }

                if(grpToGrpMemberMap.containsKey(project.Solicitation_Group__c)) {
                    for(Solicitation_Group_Member__c grpMember: grpToGrpMemberMap.get(project.Solicitation_Group__c)) {
                        scoreList.add(new ProposalScoreWrapper(grpMember.Solicitation_Review_Team__r.Member__r.Name, 0, false, grpMember.Solicitation_Review_Team__c, null));
                    }
                }

            } else {
                proposalScoreMatrixMap.put(project.Id, new List<ProposalScoreMatrixWrapper>());

                for(Solicitation_Review_Team__c team : reviewTeam) {
                    scoreList.add(new ProposalScoreWrapper(team.Member__r.Name, 0, false, team.Id, null));
                }
            }

            for(Proposal_Score__c score : project.Proposal_Scores__r) {
                for(ProposalScoreWrapper wrapper : scoreList) {
                    if(wrapper.scorerMemberId == score.Scoring_Committee_Member__c) {
                        wrapper.score = Integer.valueOf(score.Score__c);
                        wrapper.recuse = score.Recuse__c;
                        wrapper.proposalScoreId = score.Id;
                    }
                }
            }

            if(proposalScoreMatrixMap.containsKey(project.Solicitation_Group__c)) {
                proposalScoreMatrixMap.get(project.Solicitation_Group__c).add(new ProposalScoreMatrixWrapper(project, scoreList));
            } else if(proposalScoreMatrixMap.containsKey(project.Id)) {
                proposalScoreMatrixMap.get(project.Id).add(new ProposalScoreMatrixWrapper(project, scoreList));
            }
        }
        return null;
    }

     /*
      * Method Name: saveProposalMatrix
      * Description: Method to save Proposal Matrix
      * @param: None
      * @return:pageReference
      */

    public pageReference saveProposalMatrix() {

        isMatrixUpdated = false;
        List<Proposal_Score__c> proposalScoreList = new List<Proposal_Score__c>();
        for(List<ProposalScoreMatrixWrapper> wrapperList : proposalScoreMatrixMap.values()) {
            for(ProposalScoreMatrixWrapper wrapper : wrapperList) {
                for(ProposalScoreWrapper scoreWrapper : wrapper.scoreList) {
                    if(String.isNotBlank(scoreWrapper.proposalScoreId)) {
                        proposalScoreList.add(new Proposal_Score__c(Id=scoreWrapper.proposalScoreId, Score__c=scoreWrapper.score));
                    }
                }
            }
        }

        try {
            upsert proposalScoreList;
            isMatrixUpdated = true;
        } catch(DMLException e) {
            ApexPages.addMessages(e);
        }
        startRetrieval();
        fetchProposalMatrix(); // I-03005 FIX - Score Matrix Issue: Changing the score does not show the updated version
        return null;
    }



    // Start of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending

    private Map<String, String> recommendationToEmailTemplateDeveloperNameMap = new Map<String, String>{
                                                                  'Accepted'=> 'Solicitation_Concept_Paper_Recommendation_Accepted_Notification',
                                                                  'Not Accepted'=> 'Solicitation_Concept_Paper_Recommendation_Not_Accepted_Notification',
                                                                  'Fund-Award MWBE'=> 'Solicitation_Proposal_Awarded_Funding_MWBE_only_Notification',
                                                                  'Fund-Award Standard'=> 'Solicitation_Proposal_Awarded_Funding_Standard_Notification',
                                                                  'Not Awarded Funding Contingent'=> 'Solicitation_Proposal_Not_Awarded_Funding_Contingent_Notification',
                                                                  'Not Awarded Funding'=> 'Solicitation_Proposal_Not_Awarded_Funding_Notification'
                                                                  };
    /*
     * Method Name: fetchNotification
     * Description: Method to preview Email Template/ notifications
     * @param: None
     * @return:void
     */
    public void fetchNotification() {
      previewEmailBody = previewEmailSubject = null;
      String templateDeveloperName = fetchTemplateName();
      List<EmailTemplate> emailTempList = [select Id, TemplateType from EmailTemplate where DeveloperName =: templateDeveloperName];
      if(emailTempList.size() > 0) {
        Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(emailTempList[0].Id, null, objProj.Id); // Object Must have 'Allow Activities' ON.
        for(EmailTemplate template : emailTempList){
          if(template.TemplateType=='text') {
              previewEmailBody = newEmail.PlainTextBody.replaceAll('\r\n','<br/>').replaceAll('\n','<br/>');
              previewEmailSubject = newEmail.Subject;
          }
          else{
            previewEmailBody = newEmail.htmlBody;
            previewEmailSubject = newEmail.Subject;
          }
        }
      }
    }

   /*
    * Method Name: fetchTemplateName
    * Description: Method to fetch Recommendation__c from project
    * @param: None
    * @return: String
    */
    private String fetchTemplateName() {
      String templateDeveloperName;
      templateDeveloperName = (recommendationToEmailTemplateDeveloperNameMap.containsKey(objProj.Recommendation__c)) ?
                              recommendationToEmailTemplateDeveloperNameMap.get(objProj.Recommendation__c) : '';

      if(String.isBlank(templateDeveloperName) && objProj.Proposal__c) {

        if(objProj.Recommendation__c == 'Fund-Award') {
          if(currentSolicitation.MWBE__c && !currentSolicitation.Service_Disabled_Veteran_Owned_Business__c) {
            templateDeveloperName = recommendationToEmailTemplateDeveloperNameMap.get('Fund-Award MWBE');
          } else {
            templateDeveloperName = recommendationToEmailTemplateDeveloperNameMap.get('Fund-Award Standard');
          }
        } else if(objProj.Recommendation__c == 'Fundable') {
          templateDeveloperName = recommendationToEmailTemplateDeveloperNameMap.get('Not Awarded Funding Contingent');
        } else if(objProj.Recommendation__c == 'Do Not Fund') {
          templateDeveloperName = recommendationToEmailTemplateDeveloperNameMap.get('Not Awarded Funding');
        }

      }
      return templateDeveloperName;
    }

    // END of change: T-02835 POC: Program staff wants to preview award/not award // accepted/not-accepted notifications before sending

     /*
      * Method Name: exportResults
      * Description: Method to export results
      * @param: None
      * @return:pageReference
      */

    public pageReference exportResults() {

        // AG 08/16: I-03195 fix
        if(isConceptPaper && currentSolicitation != null){
          thresholdTypeLabel = CONCEPT_PAPER_THRESHOLD;
          thresholdValue = currentSolicitation.Concept_Paper_Pass_Score__c;
        }else if(!isConceptPaper && currentSolicitation != null){
          thresholdTypeLabel = PROPOSAL_THRESHOLD;
          thresholdValue = currentSolicitation.Proposal_Threshold__c;
        }else{
          thresholdTypeLabel = '';
          thresholdValue = 0.00;
        }
        // AG 08/16: I-03195 fix

        Pagereference pr;
        if(currentSolicitation != null && currentSolicitation.Score_Type__c == 'Batch Rank') {
            pr = new Pagereference('/apex/CORE_Proposal_BatchRankScoreMatrix_Page?isExport=true&isConceptPaper=' + isConceptPaper);
        } else {
            pr = new Pagereference('/apex/CORE_Proposal_SumRankScoreMatrix_Page?isExport=true&isConceptPaper=' + isConceptPaper);
        }

        pr.setRedirect(false);
        return pr;
    }

    public String xlsHeader{
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public class ProposalScoreMatrixWrapper {
        public Project__c project {get;set;}
        public List<ProposalScoreWrapper> scoreList{get;set;}

        public ProposalScoreMatrixWrapper(Project__c project, List<ProposalScoreWrapper> scoreList) {
            this.project = project;
            this.scoreList = scoreList;
        }
    }

    public class ProposalScoreWrapper {
        public String scorerName {get;set;}
        public Integer score {get;set;}
        public Boolean recuse {get;set;}
        public String scorerMemberId {get;set;}
        public String proposalScoreId {get;set;}
        public String excelScoreVal {
          get{
            if(this.recuse){
              String temp = 'R';
              return temp;
            }
              else{
                String temp = String.valueof(this.score);
                return temp;
              }
          }
          set;
        }

        public ProposalScoreWrapper(String scorerName, Integer score, Boolean recuse, String scorerMemberId, String proposalScoreId) {
            this.scorerName = scorerName;
            this.score = score;
            this.recuse = recuse;
            this.scorerMemberId = scorerMemberId;
            this.proposalScoreId = proposalScoreId;
        }
    }


    public class SolicitationGroup {
        public String groupName {get; set;}
        public String Id {get; set;}
        public Integer totalMembers {get; set;}
        public List<SolicitationGroupMember> groupMemberList {get; set;}

        public SolicitationGroup(Solicitation_Group__c solicitationGroupRec) {
            this.groupName = solicitationGroupRec.Name;
            this.totalMembers = Integer.valueOf(solicitationGroupRec.Total_Members__c);
            this.Id = solicitationGroupRec.Id;
            this.groupMemberList = new List<SolicitationGroupMember>();
            for(Solicitation_Group_Member__c groupMemberRec : solicitationGroupRec.Solicitation_Group_Members__r) {
                this.groupMemberList.add(new SolicitationGroupMember(groupMemberRec));
            }
        }
    }

    public class SolicitationGroupMember {
        public String memberName {get; set;}
        public Boolean isExternal {get; set;}
        public String Id {get; set;}
        public Boolean isSolicitationManager {get; set;}

        public SolicitationGroupMember(Solicitation_Group_Member__c groupMemberRec) {
            this.memberName = (groupMemberRec.Solicitation_Review_Team__r.Member__r.Name != null) ? groupMemberRec.Solicitation_Review_Team__r.Member__r.Name : null;
            this.isExternal = (groupMemberRec.Solicitation_Review_Team__r.Is_External_User__c != null) ? groupMemberRec.Solicitation_Review_Team__r.Is_External_User__c : false;
            this.Id = groupMemberRec.Id;
            this.isSolicitationManager = groupMemberRec.Is_Solicitation_Manager__c;
        }
    }
}