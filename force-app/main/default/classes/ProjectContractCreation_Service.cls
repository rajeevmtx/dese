/*
* Name: Lead_TriggerHandler
* Author/Date: Harshit Jain ,  4/17/2016
* Description: service class for project contract creation
*/

public without sharing class ProjectContractCreation_Service { 

    public static Map<Integer, Project_Contract__c> projectContractsMap;
    public static Map<Integer, Project_Contract_Line__c> projectContractLinesMap;
    static Map<Integer, Project_Funding__c> projectFundingsMap;
    public static Map<Integer, Integer> contractlineToContractMapping;
    static Map<Integer, Integer> FundingToContractlineMapping;
    static Map<Id, User> userMap;
    static Map<String, Contract_Line_Funding_Mapping__c> resLineFundingMapping;
    static List<Contract_Line_Funding_Mapping__c> commLineFundingMappingList;
    static Map<String, Program_Partnership__c> expeditedContractorUnquieMappingMap;

    public static Integer projectUniqueId;
    public static Integer projectLineUniqueId; 
    static Integer projectFundingUniqueId;

    static Project_Contract__c tempProjectContract;
    static Project_Contract_Line__c tempProjectContractLine;
    static Project_Funding__c tempProjectContractFunding;

    //static Decimal projectReviewLimit = CORE_Constants_Setting__c.getOrgDefaults().NY_Sun_Residential_Project_Review_Limit__c;

    private static final String NY_SUN_RESIDENTIAL_TYPE = 'NY_Sun_Residential';
    private static final String NY_SUN_COMMERCIAL_TYPE = 'NY_Sun_Commercial';
    private static final String RTEM_TYPE = 'Commercial_Real_Time_Energy_Management';
    private static final String GSHP_TYPE_SMALL = 'GSHP_Small_System';
    private static final String GSHP_TYPE_LARGE = 'GSHP_Large_System';
    private static final String NEW_CONSTRUCTION = 'New_Construction';
    private static final String LSR_TYPE_PROJECT = 'Large_Scale_Renewables';
    private static final String NY_SUN_RESIDENTIAL_RECEIVED_STATUS = 'Received';
    private static final String EUC_VALUE_CON_ED = 'Consolidated Edison';
    private static final Integer SYSTEM_SIZE_THRESHOLD = 1300;
    private static final String IPEC_FUND_TYPE = 'IPEC';
    private static final String CEF_FUND_TYPE = 'CEF';



    public static Map<Id, Project__c> projectReviewMap = new Map<Id, Project__c>();
  /*
    * Method Name: generateProjectContracts
    * Description:  This method create a project contract,lines and funding record.
    * @param: Map<Id, Project__c> newMap - new Map of project records
    * @param: Map<Id, Project__c> oldMap - old map of project records
    * @return: void
    */

    public static void generateProjectContracts(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {

      projectReviewMap = newMap;
        projectContractsMap = new Map<Integer, Project_Contract__c>();
      projectContractLinesMap = new Map<Integer, Project_Contract_Line__c>();
      projectFundingsMap = new Map<Integer, Project_Funding__c>();
      contractlineToContractMapping = new Map<Integer, Integer> ();
      FundingToContractlineMapping = New Map<Integer, Integer>();
      resLineFundingMapping = new  Map<String, Contract_Line_Funding_Mapping__c>();
      commLineFundingMappingList = new  List<Contract_Line_Funding_Mapping__c>();
      expeditedContractorUnquieMappingMap = new  Map<String, Program_Partnership__c>();

        projectUniqueId = 1;
        projectLineUniqueId = 1;
        projectFundingUniqueId = 1;

        Set<Id> projectIds = new Set<Id>();

        Set<Id> ownerIDs = new Set<Id>();

        //projectReviewLimit = (projectReviewLimit == null) ? 0 : projectReviewLimit;

        for(Project__c project : newMap.values()) {

            if(project.Status__c == Project_Helper.PROJECT_STATUS_SUBMITTED
               && project.Status__c != oldMap.get(project.Id).Status__c && project.Program_Version__c != null) {
                    projectIds.add(project.Id);
                    ownerIDs.add(project.ownerId);
                }
        }

        //fetch supplier details
        if (ownerIDs.size() > 0) {
          userMap = new Map<Id, User>([SELECT Id, ContactId, Contact.Account.Supplier_ID__c, Buyer_ID__c
                                     FROM User
                                    WHERE Id IN : ownerIDs]);


          //Fetch Contract Line Funding Mapping
          for(Contract_Line_Funding_Mapping__c lineToFundMapping : [Select Id, Activity__c, Activity_IDs__c, Customer_Sector__c,
                                                                            Electric_Utility_Company__c, Fund__c, Number_of_Lines__c,
                                                                            Program_Type__c, Project__c, NYISO_Zones__c
                                                                       From Contract_Line_Funding_Mapping__c
                                                                      LIMIT 5000]) {
              if(lineToFundMapping.Program_Type__c == NY_SUN_RESIDENTIAL_TYPE) {
                  resLineFundingMapping.put(lineToFundMapping.Electric_Utility_Company__c + '~' + lineToFundMapping.Customer_Sector__c, lineToFundMapping);
              } else if(lineToFundMapping.Program_Type__c == NY_SUN_COMMERCIAL_TYPE) {
                  commLineFundingMappingList.add(lineToFundMapping);
              }
          }

          //fetch expedited contractor details for NYSUN
          for(Program_Partnership__c partnership : [Select Account__c, Program__c, Default_Primary_Contact__c, Status__c,
                                   Review_Count_Expedited__c, Applications_Received_Expedited__c
                                From Program_Partnership__c
                                 Where Expedited__c = true
                                   And Program__r.Application_Type__c =: NYSUN_Helper.RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME]) {
            //expeditedContractorUnquieMappingMap.put(partnership.Program__c + '~' + partnership.Account__c + '~' +partnership.Default_Primary_Contact__c, partnership);
            expeditedContractorUnquieMappingMap.put(partnership.Program__c + '~' + partnership.Account__c, partnership);
          }  

          for(Project__c project : [Select Id, OwnerId, Program_Version__c, Total_Active_Milestone_Incentives__c,Bid_Price__c,Bid_Quantity__c,Contract_Duration__c,
                                           RecordType.DeveloperName, Total_NYSERDA_Incentive_Amount__c,Proposal__c,Concept_Paper__c,
                                           Total_System_Size__c, Program_Version__r.Round_Number__c, Program_Version__r.Requisition_ID__c,
                                           Program_Version__r.Buyer_ID__c, Program_Version__r.Procurement_Method__c,
                                           Program_Version__r.Header_Description__c, Program_Version__r.Agreement_Code__c,  
                                           Program_Version__r.Anticipated_Term_Over_A_Year__c, Program_Version__r.Procurement_Contract__c,
                                           Program_Version__r.Category__c, Program_Version__r.Account_Number__c, Program_Version__r.Department__c,
                                           Program_Version__r.Program__r.Program_Family__c, Program_Version__r.Program__r.Application_Type__c,
                                           Program_Version__r.Program__r.Name, Name, Program_Version__r.System_Cap__c, Program_Version__r.System_NYSERDA_Incentive__c,
                                           Program_Version__r.Service_Year_1_Cap__c, Program_Version__r.Service_Year_2_Cap__c,
                                           Program_Version__r.Service_Year_3_Cap__c,
                                           Program_Version__r.Service_Year_4_Cap__c, Program_Version__r.Service_Year_5_Cap__c,
                                           Program_Version__r.Program__c,
                                           Program_Version__r.Service_Year_1_Incentive__c, Program_Version__r.Service_Year_2_Incentive__c,
                                           Program_Version__r.Service_Year_3_Incentive__c,
                                           Program_Version__r.Service_Year_4_Incentive__c, Program_Version__r.Service_Year_5_Incentive__c,
                                           Program_Version__r.System_Cap_B__c, Program_Version__r.System_NYSERDA_Incentive_B__c,
                                           Program_Version__r.Service_Year_1_Cap_B__c, Program_Version__r.Service_Year_2_Cap_B__c,
                                           Program_Version__r.Service_Year_3_Cap_B__c,
                                           Program_Version__r.Service_Year_4_Cap_B__c, Program_Version__r.Service_Year_5_Cap_B__c,
                                           Program_Version__r.Service_Year_1_Incentive_B__c, Program_Version__r.Service_Year_2_Incentive_B__c,
                                           Program_Version__r.Service_Year_3_Incentive_B__c,
                                           Program_Version__r.Service_Year_4_Incentive_B__c, Program_Version__r.Service_Year_5_Incentive_B__c,
                                           Program_Version__r.Market_Focus__c,Program_Version__r.NEIS_Project_Id__c,Program_Version__r.Fund__c,
                                           Program_Version__r.Activity_ID__c,E_Contractor_Under_Review__c,
                                           Submitted_Date__c, Payment_Assignment__c,Total_NYSERDA_Incentive_Amount_Scale2__c,
                                           (Select Id, Address_1__c, Address_2__c, City__c, County__c, Utility_Company__c, Affordable_Solar__c,
                                                   System_already_Installed__c,
                                                   Utility_Sector__c, Zip__c, State__c, NYPA__c,NYISO_Zone__c, Services_Contract_Length_Years__c,
                                                   Annual_Services_Costs__c, Total_System_installation_costs__c, Estimated_NYSERDA_Incentives__c,
                                                   Year_1_Amount__c, Year_2_Amount__c, Year_3_Amount__c, Year_4_Amount__c, Year_5_Amount__c, Incentive_Level__c
                                            From   Project_Site__r),
                                           (SELECT Sub_Type__c, Status__c, Project__c, Parent__c, Incentive_Amount__c
                                             From Project_Milestones__r
                                            WHERE parent__c != NULL),
                                           (SELECT id, Primary_Customer_Contact__c, Contact__r.Account.Supplier_ID__c,
                                                   Account__r.Supplier_ID__c, Role__c, Contact__c, Account__c, Contact__r.AccountId,
                                                   Role_Supplier_ID__c
                                             From  Project_Roles__r
                                             WHERE (Role__c = : ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE OR Role__c = :NYSUN_Helper.PROJECT_ROLE_PAYEE)
                                             AND   Primary_Customer_Contact__c = true),
                                            (SELECT ID From Project_Contracts__r)
                                     From Project__c
                                    Where Id IN: projectIds]) {
            if(project.Project_Contracts__r.size() == 0) {
                if(project.RecordType.DeveloperName == NY_SUN_RESIDENTIAL_TYPE && project.Project_Site__r.Size() > 0) {
                    // Added condition - I-01207 - Create contract only if incentive amount greater then zero else set status to received
                    if(project.Total_NYSERDA_Incentive_Amount__c > 0) {
                        createContracDataForNYSUNResProjects(project);
                    } else {
                        newMap.get(project.Id).Status__c = NY_SUN_RESIDENTIAL_RECEIVED_STATUS;
                    }
                } else if(project.RecordType.DeveloperName == NY_SUN_COMMERCIAL_TYPE && project.Project_Site__r.Size() > 0) {
                    createContracDataForNYSUNCommProjects(project);
                } else if(project.RecordType.DeveloperName == RTEM_TYPE && project.Project_Site__r.Size() > 0) {
                    createContracDataForRTEMProjects(project);// GS-RTEM_REMOVE
                }/* else if(project.RecordType.DeveloperName == CHP_Helper.CHP_PROJECT_RECORD_TYPE_DEVELOPER_NAME && project.Project_Site__r.Size() > 0) {
                    prepareMapOfSolicitationFunding(project);
                    createContracDataForCHPProjects(project, newMap);
                } else if(project.RecordType.DeveloperName == CTenant_Helper.CTenant_PROJECT_RECORD_TYPE_DEVELOPER_NAME && project.Project_Site__r.Size() > 0) {
                    createContracDataForCTenantProjects(project);
                }*/else if(project.RecordType.DeveloperName == GSHP_TYPE_LARGE && project.Project_Site__r.Size() > 0) {
                    createContracDataForGSHPProjects(project);
                }
                else if(project.RecordType.DeveloperName == LSR_TYPE_PROJECT && project.Project_Site__r.Size() > 0) {
                    createContracDataForLSRProjects(project);
                }
                /*else if(!project.Concept_Paper__c && !project.Proposal__c && project.RecordType.DeveloperName != GSHP_TYPE_SMALL &&
                        project.RecordType.DeveloperName != NEW_CONSTRUCTION) {
                    createContracData(project);
                }*/
            }
          }
          //Insert contract records
          if(projectContractsMap.size() > 0){
              insert projectContractsMap.values();
          }

          //Insert contract lines
          if(projectContractLinesMap.size() > 0){
              for(Integer lineUniqueId : projectContractLinesMap.keySet()) {

                  if(contractlineToContractMapping.containsKey(lineUniqueId) &&
                     projectContractsMap.containsKey(contractlineToContractMapping.get(lineUniqueId))) {

                      projectContractLinesMap.get(lineUniqueId).Project_Contract__c =
                      projectContractsMap.get(contractlineToContractMapping.get(lineUniqueId)).Id;

                  }
              }
              insert projectContractLinesMap.values();
          }

          //Insert contract fundings
          if(projectFundingsMap.size() > 0) {
              for(Integer fundingUniqueId : projectFundingsMap.keySet()) {

                  if(FundingToContractlineMapping.containsKey(fundingUniqueId) &&
                     projectContractLinesMap.containsKey(FundingToContractlineMapping.get(fundingUniqueId))) {

                      projectFundingsMap.get(fundingUniqueId).Project_Contract_Line__c =
                      projectContractLinesMap.get(FundingToContractlineMapping.get(fundingUniqueId)).Id;
                      projectFundingsMap.get(fundingUniqueId).Project_Contract__c =
                      projectContractLinesMap.get(FundingToContractlineMapping.get(fundingUniqueId)).Project_Contract__c;

                  }
              }
              insert projectFundingsMap.values();
          }

        }


    }


  /*
    * Method Name: createContracDataForNYSUNResProjects
    * Description:  This method create a project contract,lines and funding record for NY SUN Residential projects
    * @param: Project__c project
    * @return: void
    */

    public static void createContracDataForNYSUNResProjects(Project__c project) {
        String mapKey;
        Decimal iCurrentReceivedCount = 0, iReviewCount = 0, affordableAmount=0, baseAmount=0;
        Boolean isReviewRequired = false;
        tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();
        String primaryContractorKey = '';

        if(project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c) && objRole.Contact__c != null) {
               primaryContractorKey = project.Program_Version__r.Program__c + '~' + objRole.Contact__r.AccountId;
            }
          }
        }

        /* // NO Need of this because we are reading E_Contractor_Under_Review__c
        //Identify 1 out of every 10 submissions by E Contractors
        if(expeditedContractorUnquieMappingMap.containsKey(primaryContractorKey)) {
          iReviewCount = expeditedContractorUnquieMappingMap.get(primaryContractorKey).Review_Count_Expedited__c;
          iCurrentReceivedCount = expeditedContractorUnquieMappingMap.get(primaryContractorKey).Applications_Received_Expedited__c + 1;
          if(iCurrentReceivedCount > 10 && iReviewCount < projectReviewLimit && Math.mod(Integer.valueOf(iCurrentReceivedCount), 10) == 1) {
            isReviewRequired = true;
          }
        }
        */

        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }

        Project__c projectInContext = new Project__c();
        if(projectReviewMap != null && projectReviewMap.containsKey(project.Id)) {
          projectInContext = projectReviewMap.get(project.Id);
        }

        //prepare contract record
        tempProjectContract.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Application_Date__c = (project.Submitted_Date__c == null ? DateTime.now() : project.Submitted_Date__c);
        tempProjectContract.Project__c = project.Id;
        if(expeditedContractorUnquieMappingMap.containsKey(primaryContractorKey)) {
          if(project.Project_Site__r.size() > 0 &&
             ((project.E_Contractor_Under_Review__c || projectInContext.E_Contractor_Under_Review__c)
             || isReviewRequired
             || project.Project_Site__r[0].Utility_Sector__c == NYSUN_HELPER.NON_RESIDENTIAL_UTILITY_SECTOR
             || project.Project_Site__r[0].Affordable_Solar__c || project.Project_Site__r[0].NYPA__c
             || expeditedContractorUnquieMappingMap.get(primaryContractorKey).Status__c == ProgramPartnership_Helper.STATUS_PROVISIONAL
             || expeditedContractorUnquieMappingMap.get(primaryContractorKey).Status__c == ProgramPartnership_Helper.STATUS_PROBATION)) {
            tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
          } else { 
            tempProjectContract.Status__c = ProjectContract_Helper.STATUS_APPROVED;
          }
        } else {
          tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
        }
        projectContractsMap.put(projectUniqueId, tempProjectContract);

        //prepare contract line record
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Buyer__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContractLine.Line_Description__c = project.Program_Version__r.Header_Description__c;
        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping

        //identify incentive amount from milestone
        for(Project_Milestones__c milestone : project.Project_Milestones__r) {
            if(project.RecordType.developerName == NYSUN_Helper.RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME) {
                if(milestone.Sub_Type__c == NYSUN_Helper.BASE_INCENTIVE_SUB_TYPE) {
                    baseAmount += (milestone.Incentive_Amount__c != null ?
                        milestone.Incentive_Amount__c : 0);
                } else if(milestone.Sub_Type__c == NYSUN_Helper.AFFORDABLE_SOLAR_INCENTIVE_SUB_TYPE) {
                    affordableAmount += (milestone.Incentive_Amount__c != null ?
                        milestone.Incentive_Amount__c : 0);
                }
            }
        }


        String utilityCompanyKey = (project.Project_Site__r[0].NYPA__c) ? project.Project_Site__r[0].Utility_Company__c + ' - NYPA' : project.Project_Site__r[0].Utility_Company__c;
        mapKey = (project.Project_Site__r[0].Affordable_Solar__c) ? utilityCompanyKey + '~Affordable Solar Residential' : utilityCompanyKey + '~' +project.Project_Site__r[0].Utility_Sector__c;

        if(String.isNotBlank(project.Project_Site__r[0].Utility_Company__c) && String.isNotBlank(project.Project_Site__r[0].Utility_Sector__c) &&
            resLineFundingMapping.containsKey(mapKey)) {
            Contract_Line_Funding_Mapping__c mappingRecord = resLineFundingMapping.get(mapKey);
            List<String> activityIds = mappingRecord.Activity_IDs__c.split('/');
            List<String> projectIds = mappingRecord.Project__c.split('/');

            for(Integer line=0; line<mappingRecord.Number_of_Lines__c; line++) {

                tempProjectContractFunding = new Project_Funding__c();

                //prepare contract funding record
                tempProjectContractFunding.Account_Number__c = project.Program_Version__r.Account_Number__c;
                tempProjectContractFunding.Department__c = project.Program_Version__r.Department__c;
                //tempProjectContractFunding.Distribution_Amount__c = Math.round(activityIds.get(line).contains('LMI') ? affordableAmount : baseAmount); // I-01998
                tempProjectContractFunding.Distribution_Amount__c = (activityIds.get(line).contains('LMI') ? affordableAmount : baseAmount).round(System.RoundingMode.HALF_UP); // I-01998
                tempProjectContractFunding.Fund__c = mappingRecord.Fund__c;
                tempProjectContractFunding.Project_ID__c = (projectIds.size() == mappingRecord.Number_of_Lines__c) ? projectIds.get(line) : projectIds.get(0);
                tempProjectContractFunding.Activity_ID__c = activityIds.get(line);
                tempProjectContractFunding.Project_Site__c = project.Project_Site__r[0].Id;
                tempProjectContractFunding.Project__c = project.Id;
                projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
                FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);

                projectFundingUniqueId++;
            }
        }
        projectLineUniqueId++;
        projectUniqueId++;
    }

  /*
    * Method Name: createContracDataForNYSUNCommProjects
    * Description:  This method create a project contract,lines and funding record for NY SUN Commercial projects
    * @param: Project__c project
    * @return: void
    */

    public static void createContracDataForNYSUNCommProjects(project__c project) {
        tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();
        String supplierIdContractor = '', supplierIdPayee = '';


        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {

            if(objRole.Primary_Customer_Contact__c && NYSUN_Helper.PROJECT_ROLE_PAYEE.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }

            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c)) {
              supplierIdContractor = objRole.Role_Supplier_ID__c;
            }
          }
        }

        //prepare contract record
        tempProjectContract.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;

        tempProjectContract.Agreement_Code__c = (project.Payment_Assignment__c)?
                                                    ProjectContract_Helper.AGREEMENT_CODE_A :
                                                    project.Program_Version__r.Agreement_Code__c;

        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;

        tempProjectContract.Procurement_Contract__c = ProjectContract_Helper.PROCUREMENT_CONTRACT_N;

        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Application_Date__c = (project.Submitted_Date__c == null ? DateTime.now() : project.Submitted_Date__c);
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
        projectContractsMap.put(projectUniqueId, tempProjectContract);

        //prepare contract line record
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Category__c = ProjectContract_Helper.CATEGORY_PGRM;
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Buyer__c = project.Program_Version__r.Buyer_ID__c;

        tempProjectContractLine.Line_Description__c = (project.Payment_Assignment__c)?
                                                          ProjectContract_Helper.prepareLineDescription(supplierIdContractor) :
                                                          project.Program_Version__r.Header_Description__c;

        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping

        String utilityCompanyKey = (project.Project_Site__r[0].NYPA__c) ? project.Project_Site__r[0].Utility_Company__c + ' - NYPA' : project.Project_Site__r[0].Utility_Company__c;
        if(String.isNotBlank(utilityCompanyKey)) {
            //Identify mapping record
            Contract_Line_Funding_Mapping__c mappingRecord;
            for(Contract_Line_Funding_Mapping__c mappingRec : commLineFundingMappingList) {
                if(utilityCompanyKey.contains('NYPA') && mappingRec.Electric_Utility_Company__c == utilityCompanyKey) {
                    mappingRecord = mappingRec;
                    break;
                } else if(mappingRec.Electric_Utility_Company__c == utilityCompanyKey
                          && String.isNotBlank(project.Project_Site__r[0].NYISO_Zone__c) && mappingRec.NYISO_Zones__c.containsIgnoreCase(project.Project_Site__r[0].NYISO_Zone__c)) {
                    mappingRecord = mappingRec;
                    break;
                }
            }

            //create contract records
            if(mappingRecord != null) {
                for(Integer line=0; line<mappingRecord.Number_of_Lines__c; line++) {

                    tempProjectContractFunding = new Project_Funding__c();

                    //prepare contract funding record
                    tempProjectContractFunding.Account_Number__c = project.Program_Version__r.Account_Number__c;
                    tempProjectContractFunding.Department__c = project.Program_Version__r.Department__c;
                    tempProjectContractFunding.Distribution_Amount__c = project.Total_Active_Milestone_Incentives__c;
                    tempProjectContractFunding.Fund__c = mappingRecord.Fund__c;
                    tempProjectContractFunding.Project_ID__c = mappingRecord.Project__c;
                    tempProjectContractFunding.Activity_ID__c = mappingRecord.Activity__c;
                    tempProjectContractFunding.Project_Site__c = project.Project_Site__r[0].Id;
                    tempProjectContractFunding.Project__c = project.Id;
                    projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
                    FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);

                    projectFundingUniqueId++;
                }
            }

        }
        projectLineUniqueId++;
        projectUniqueId++;
    }

  /*
    * Method Name: createContracDataForRTEMProjects
    * Description:   This method create a project contract,lines and funding record for RTEM projects
    * @param: Project__c project
    * @return: void
    */

    ///* GS-RTEM_REMOVE
    public static void createContracDataForRTEMProjects(project__c project) {
      tempProjectContract = new Project_Contract__c();

        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }

        //prepare contract record
        tempProjectContract.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContract.Header_Description__c = project.Program_Version__r.Program__r.Name;
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Application_Date__c = DateTime.now();
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
        tempProjectContract.Synopsis_Description__c = project.Name;
        tempProjectContract.Contract_ID__c = 'NEXT';
        projectContractsMap.put(projectUniqueId, tempProjectContract);
    /*
    Decimal systemCapValue = project.Program_Version__r.System_Cap__c;
    Decimal[] capValueArr = new List<Decimal> { project.Program_Version__r.Service_Year_1_Cap__c,
                          project.Program_Version__r.Service_Year_2_Cap__c,
                          project.Program_Version__r.Service_Year_3_Cap__c,
                          project.Program_Version__r.Service_Year_4_Cap__c,
                          project.Program_Version__r.Service_Year_5_Cap__c
                        };

    Decimal systemIncentiveValue = project.Program_Version__r.System_NYSERDA_Incentive__c / 100;
    Decimal[] incentiveValueArr = new List<Decimal> { project.Program_Version__r.Service_Year_1_Incentive__c / 100,
                          project.Program_Version__r.Service_Year_2_Incentive__c / 100,
                          project.Program_Version__r.Service_Year_3_Incentive__c / 100,
                          project.Program_Version__r.Service_Year_4_Incentive__c / 100,
                          project.Program_Version__r.Service_Year_5_Incentive__c / 100
                        };
    */
    Integer contractLineNumber = 1;
        for(Project_Site__c site : project.Project_Site__r) {
          Decimal systemCapValue;
          List<Decimal> capValueArr;
          Decimal systemIncentiveValue;
          List<Decimal> incentiveValueArr;

          if(site.Incentive_Level__c == 'Option A'){
            systemCapValue = project.Program_Version__r.System_Cap__c;
        capValueArr = new List<Decimal> { project.Program_Version__r.Service_Year_1_Cap__c,
                              project.Program_Version__r.Service_Year_2_Cap__c,
                              project.Program_Version__r.Service_Year_3_Cap__c,
                              project.Program_Version__r.Service_Year_4_Cap__c,
                              project.Program_Version__r.Service_Year_5_Cap__c
                            };

        systemIncentiveValue = project.Program_Version__r.System_NYSERDA_Incentive__c / 100;
        incentiveValueArr = new List<Decimal> { project.Program_Version__r.Service_Year_1_Incentive__c / 100,
                              project.Program_Version__r.Service_Year_2_Incentive__c / 100,
                              project.Program_Version__r.Service_Year_3_Incentive__c / 100,
                              project.Program_Version__r.Service_Year_4_Incentive__c / 100,
                              project.Program_Version__r.Service_Year_5_Incentive__c / 100
                            };

          }else if(site.Incentive_Level__c == 'Option B'){
            systemCapValue = project.Program_Version__r.System_Cap_B__c;
        capValueArr = new List<Decimal> { project.Program_Version__r.Service_Year_1_Cap_B__c,
                              project.Program_Version__r.Service_Year_2_Cap_B__c,
                              project.Program_Version__r.Service_Year_3_Cap_B__c,
                              project.Program_Version__r.Service_Year_4_Cap_B__c,
                              project.Program_Version__r.Service_Year_5_Cap_B__c
                            };

        systemIncentiveValue = project.Program_Version__r.System_NYSERDA_Incentive_B__c / 100;
        incentiveValueArr = new List<Decimal> { project.Program_Version__r.Service_Year_1_Incentive_B__c / 100,
                              project.Program_Version__r.Service_Year_2_Incentive_B__c / 100,
                              project.Program_Version__r.Service_Year_3_Incentive_B__c / 100,
                              project.Program_Version__r.Service_Year_4_Incentive_B__c / 100,
                              project.Program_Version__r.Service_Year_5_Incentive_B__c / 100
                            };
          }

          List<Decimal> serviceCostArr = new List<Decimal> { (site.Year_1_Amount__c == null) ? 0 : site.Year_1_Amount__c,
                              (site.Year_2_Amount__c == null) ? 0 : site.Year_2_Amount__c,
                              (site.Year_3_Amount__c == null) ? 0 : site.Year_3_Amount__c,
                              (site.Year_4_Amount__c == null) ? 0 : site.Year_4_Amount__c,
                              (site.Year_5_Amount__c == null) ? 0 : site.Year_5_Amount__c
                            };

          // Contract length for the site
          Integer contractLength = (site.Services_Contract_Length_Years__c != null ? Integer.valueOf(site.Services_Contract_Length_Years__c) : 0);
          //Decimal serviceCost = (site.Annual_Services_Costs__c != null ? site.Annual_Services_Costs__c : 0.0);
          Decimal systemInstallationCost = (site.Total_System_installation_costs__c != null ? site.Total_System_installation_costs__c : 0.0);

          // Devide amount into three funding records
          Decimal[] disAmountArr = new List<Decimal>{0,0,0};

          //Amount for first funding record
          if((systemIncentiveValue * systemInstallationCost) > systemCapValue)
        disAmountArr[0] = systemCapValue;
      else
        disAmountArr[0] = (systemIncentiveValue * systemInstallationCost);

          // disAmountArr[1] : amount for second funding record
          // disAmountArr[2] : amount for third funding record
          for(Integer counter=0; counter<5; counter++){
            if(counter < contractLength){
              if((incentiveValueArr[counter] * serviceCostArr[counter]) > capValueArr[counter])
                disAmountArr[1] = disAmountArr[1] + capValueArr[counter];
              else
                disAmountArr[1] = disAmountArr[1] + (incentiveValueArr[counter] * serviceCostArr[counter]);
            }
            else
              disAmountArr[2] = disAmountArr[2] + capValueArr[counter];
          }

          //Create three records of contract funding
          for(Integer lineNum = 0; lineNum < 3; lineNum++){

            //prepare contract line record
            tempProjectContractLine = new Project_Contract_Line__c();
            tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
            tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
            tempProjectContractLine.Project__c = project.Id;
            tempProjectContractLine.Round_Number__c = project.Program_Version__r.Round_Number__c;
            tempProjectContractLine.Requisition_ID__c = project.Program_Version__r.Requisition_ID__c;
            //tempProjectContractLine.Buyer__c = project.Program_Version__r.Buyer_ID__c;
            tempProjectContractLine.Line_Description__c = project.Program_Version__r.Program__r.Name;
                tempProjectContractLine.NEIS_Contract_Line_Number__c = ''+contractLineNumber;
            if(lineNum != 2 || contractLength != 5){
              if(lineNum != 0 || site.System_already_Installed__c != 'Yes'){
                projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
                contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId);
              }
            }

            //prepare contract funding record
                tempProjectContractFunding = new Project_Funding__c();
                tempProjectContractFunding.Account_Number__c = project.Program_Version__r.Account_Number__c;
                tempProjectContractFunding.Department__c = project.Program_Version__r.Department__c;
                tempProjectContractFunding.Distribution_Amount__c = disAmountArr[lineNum];
                tempProjectContractFunding.Fund__c = project.Program_Version__r.Fund__c;
                tempProjectContractFunding.Project_ID__c = project.Program_Version__r.NEIS_Project_Id__c;
                tempProjectContractFunding.Activity_ID__c = project.Program_Version__r.Activity_ID__c;
                tempProjectContractFunding.Market_Focus__c = project.Program_Version__r.Market_Focus__c;
                tempProjectContractFunding.Project_Site__c = site.Id;
                tempProjectContractFunding.Project__c = project.Id;
                tempProjectContractFunding.NEIS_Contract_Funding_Line_Number__c = ''+1;

                if(lineNum != 2 || contractLength != 5){
                  if(lineNum != 0 || site.System_already_Installed__c != 'Yes'){
                    projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
                    FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);
                    projectLineUniqueId++;
                    projectFundingUniqueId++;
                        contractLineNumber++;
                  }
                }
            }
        }

        projectUniqueId++;
    }
    //*/

    /*
    * Method Name: createContracDataForCTenantProjects
    * Description:   This method create a project contract,lines and funding record for CTenant projects
    * @param: Project__c project
    * @return: void
    */

    public static void createContracDataForCTenantProjects(project__c project) {
      tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();

        //prepare contract record
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Application_Date__c = DateTime.now();
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContract.Contract_ID__c = 'NEXT';
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
        tempProjectContract.Project__c = project.Id;
        //tempProjectContract.Supplier_ID__c = '';
        tempProjectContract.Synopsis_Description__c = project.Name;
    projectContractsMap.put(projectUniqueId, tempProjectContract);

        //prepare contract line record
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Round_Number__c = project.Program_Version__r.Round_Number__c;
        tempProjectContractLine.Requisition_ID__c = project.Program_Version__r.Requisition_ID__c;
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Buyer__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContractLine.Line_Description__c = project.Program_Version__r.Header_Description__c;
        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping

        //prepare contract Funding record
        for(Project_Site__c site : project.Project_Site__r) {
          tempProjectContractFunding = new Project_Funding__c();
            tempProjectContractFunding.Account_Number__c = project.Program_Version__r.Account_Number__c;
            tempProjectContractFunding.Department__c = project.Program_Version__r.Department__c;
            tempProjectContractFunding.Distribution_Amount__c = site.Estimated_NYSERDA_Incentives__c;
            tempProjectContractFunding.Fund__c = project.Program_Version__r.Fund__c;
            tempProjectContractFunding.Project_ID__c = project.Program_Version__r.NEIS_Project_Id__c;
            tempProjectContractFunding.Activity_ID__c = project.Program_Version__r.Activity_ID__c;
            tempProjectContractFunding.Market_Focus__c = project.Program_Version__r.Market_Focus__c;
            tempProjectContractFunding.Project_Site__c = site.Id;
            tempProjectContractFunding.Project__c = project.Id;
            projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
        FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);
        projectFundingUniqueId++;
        }

        projectUniqueId++;
        projectLineUniqueId++;
    }


  /*
    * Method Name: prepareMapOfSolicitationFunding
    * Description:   This method prepare the map of SolicitationFunding records
    * @param: Project__c project
    * @return: void
    */


    static map<String,Solicitation_Funding__c> fundTypeToSolicitationFundingMap;
    private static void prepareMapOfSolicitationFunding(Project__c project){
      fundTypeToSolicitationFundingMap = new map<String,Solicitation_Funding__c>();
      list<Solicitation_Funding__c> sfList = [SELECT Id, Name, Account_Number__c, Activity_ID__c, Department__c, Market_Focus__c, Project_ID__c, Solicitation__c
                           FROM Solicitation_Funding__c
                           WHERE Solicitation__c =: project.Program_Version__r.Id];

      for(Solicitation_Funding__c sfObj : sfList){
        if(!fundTypeToSolicitationFundingMap.containsKey(sfObj.Name))
          fundTypeToSolicitationFundingMap.put(sfObj.Name, sfObj);
      }
    }


  /*
    * Method Name: createContracDataForCHPProjects
    * Description:   This method create a project contract,lines and funding record for CHP
    * @param: Project__c project
    * @param: Map<Id, Project__c> newMap : new map of project records
    * @return: void
    */

    public static void createContracDataForCHPProjects(Project__c project, Map<Id, Project__c> newMap){

      tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();

        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }

        //prepare contract record
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Application_Date__c = DateTime.now();
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
        projectContractsMap.put(projectUniqueId, tempProjectContract);

        //prepare contract line record
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Buyer__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContractLine.Line_Description__c = project.Program_Version__r.Header_Description__c;
        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping

        if(project.Project_Site__r != null && project.Project_Site__r.size() > 0) {
            if(fundTypeToSolicitationFundingMap != null && fundTypeToSolicitationFundingMap.get(CEF_FUND_TYPE) != null){
            Solicitation_Funding__c sfObj = fundTypeToSolicitationFundingMap.get(CEF_FUND_TYPE);
              tempProjectContractFunding = new Project_Funding__c();
                  //prepare contract funding record
                  tempProjectContractFunding.Account_Number__c = sfObj.Account_Number__c;
                  tempProjectContractFunding.Department__c = sfObj.Department__c;
                  tempProjectContractFunding.Distribution_Amount__c = project.Total_Active_Milestone_Incentives__c;
                  tempProjectContractFunding.Size__c = project.Total_System_Size__c;
                  tempProjectContractFunding.Fund__c = sfObj.Name;
                  tempProjectContractFunding.Project_ID__c = sfObj.Project_ID__c;
                  tempProjectContractFunding.Activity_ID__c = sfObj.Activity_ID__c;
                  tempProjectContractFunding.Market_Focus__c = sfObj.Market_Focus__c;
                  tempProjectContractFunding.Project_Site__c = project.Project_Site__r[0].Id;
                  tempProjectContractFunding.Project__c = project.Id;
                  projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
                  FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);

                  //roll up project fields from funding
                  //ProjectFunding_TriggerHandler.rollupProjectFields(sfObj.Name, newMap.get(project.Id), project.Total_Active_Milestone_Incentives__c, project.Total_System_Size__c);
                  projectFundingUniqueId++;
          }
 
        }
        projectLineUniqueId++; 
        projectUniqueId++;

    }

    /*
    * Method Name: createContracDataForGSHPProjects
    * Description:  This method create a project contract,lines and funding record for GSHP Projects
    * @param: Project__c project
    * @return: void
    */

    public static void createContracDataForGSHPProjects(Project__c project){
      tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();

        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }

        //prepare contract record
        tempProjectContract.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Contract_ID__c = 'NEXT';
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;
        tempProjectContract.Application_Date__c = DateTime.now();
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Synopsis_Description__c = project.Name;

        //prepare contract line record
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Round_Number__c = project.Program_Version__r.Round_Number__c;
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Status__c = 'Open';
        tempProjectContractLine.Buyer__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContractLine.Line_Description__c = project.Program_Version__r.Header_Description__c;

        //prepare contract Funding record

          tempProjectContractFunding = new Project_Funding__c();
            tempProjectContractFunding.Account_Number__c = project.Program_Version__r.Account_Number__c;
            tempProjectContractFunding.Distribution_Amount__c = project.Total_NYSERDA_Incentive_Amount_Scale2__c;
            tempProjectContractFunding.Fund__c = project.Program_Version__r.Fund__c;
            tempProjectContractFunding.Department__c = project.Program_Version__r.Department__c;
            tempProjectContractFunding.Project_ID__c = project.Program_Version__r.NEIS_Project_Id__c;
            tempProjectContractFunding.Activity_ID__c = project.Program_Version__r.Activity_ID__c;
            tempProjectContractFunding.Market_Focus__c = project.Program_Version__r.Market_Focus__c;
            tempProjectContractFunding.Project__c = project.Id;
            tempProjectContractFunding.Distribution_Pct__c = '100';
            projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
        FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);

         projectContractsMap.put(projectUniqueId, tempProjectContract);
        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping
        projectUniqueId++;
        projectLineUniqueId++;


    }

    /*
    * Method Name: createContracDataForCTProjects
    * Description: This method create a project contract,lines and funding record for CT Projects
    * @param: Project__c project
    * @return: void
    */

    public static void createContracDataForCTProjects(Project__c project) {
        tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();

        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }

        //prepare contract record
        tempProjectContract.Header_Description__c = project.Name;
        tempProjectContract.Synopsis_Description__c = project.Name;
        tempProjectContract.Agreement_Code__c = 'B';
        tempProjectContract.Anticipated_Term_Over_A_Year__c = 'Y';
        tempProjectContract.Procurement_Contract__c = 'Y';
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Application_Date__c = project.Submitted_Date__c;
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Supplier_ID__c = '';
        tempProjectContract.Buyer_ID__c = '';
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;

        //prepare contract line record
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Procurement_Method__c = 'SOLI';
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Round_Number__c = project.Solicitation_Round__r.Name;
        tempProjectContractLine.Line_Description__c = project.Name;
        tempProjectContractLine.Requisition_ID__c = '';
        tempProjectContractLine.Buyer__c = '';

        projectContractsMap.put(projectUniqueId, tempProjectContract);
        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping
        projectUniqueId++;
        projectLineUniqueId++;
    }


     /*
    * Method Name: createContractDataForNewConstructionProjects
    * Description:   This method create a project contract,lines and funding record for New Construction projects
    * @param: Project__c project
    * @return: void
    */

 /*   public static void createContractDataForNewConstructionProjects(project__c project) {
      tempProjectContract = new Project_Contract__c();


        //prepare contract record
        tempProjectContract.Contract_ID__c = NC_Helper.PROJECT_CONTRACT_CONTRACTOR_ID;
        tempProjectContract.Status__c = NC_Helper.PROJECT_CONTRACT_STATUS;
        tempProjectContract.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(NC_Helper.PAYEE_ROLE.equalsIgnoreCase(objRole.Role__c)) {//objRole.Primary_Customer_Contact__c) // I-03574
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Synopsis_Description__c = project.Name;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Application_Recevived__c = NC_Helper.PROJECT_CONTRACT_APPLICATION_RECEIVED;
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Application_Date__c = project.Submitted_Date__c;
        //projectContractsMap.put(projectUniqueId, tempProjectContract);
        insert tempProjectContract;


        //prepare contract line record
        tempProjectContractLine = new Project_Contract_Line__c();
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Requisition_ID__c = project.Program_Version__r.Requisition_Id__c;
        //tempProjectContractLine.Round_Number__c = 'No Round';
        tempProjectContractLine.Buyer__c = NC_Helper.PROJECT_CONTRACTOR_LINE_BUYER;
        tempProjectContractLine.Line_Description__c = NC_Helper.PROJECT_CONTRACTOR_LINE_LINE_DESCRIPTION;
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Project_Contract__c = tempProjectContract.Id;
        //projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        //contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping
        insert tempProjectContractLine;

        List<Project_Site__c> lstProjectSite = [SELECT Id, Address_1__c, Address_2__c, City__c, State__c, Zip__c
                                                FROM Project_Site__c
                                                WHERE Project__c =: project.Id
                                                ORDER BY CreatedDate
                                                LIMIT 1];


        Project_Site__c projSite;
        for(Project_Site__c site: lstProjectSite)
        {
            projSite = site;
        }
        //prepare contract Funding record
        tempProjectContractFunding = new Project_Funding__c();
        tempProjectContractFunding.Project__c = project.Id;
        tempProjectContractFunding.Account_Number__c = project.Program_Version__r.Account_Number__c;
        tempProjectContractFunding.Department__c = project.Program_Version__r.Department__c;
        tempProjectContractFunding.Fund__c = project.Program_Version__r.Fund__c;
        tempProjectContractFunding.Project_ID__c = project.Program_Version__r.NEIS_Project_Id__c;
        tempProjectContractFunding.Activity_ID__c = project.Program_Version__r.Activity_ID__c;
        tempProjectContractFunding.Distribution_Pct__c = NC_Helper.PROJECT_CONTRACT_FUNDING_DISTRIBUTION_PCT;
        tempProjectContractFunding.Distribution_Amount__c = NC_Helper.PROJECT_CONTRACT_FUNDING_DISTRIBUTION_AMOUNT;
        tempProjectContractFunding.Market_Focus__c = project.Program_Version__r.Market_Focus__c;
        tempProjectContractFunding.Project_Contract_Line__c = tempProjectContractLine.Id;
        tempProjectContractFunding.Project_Contract__c = tempProjectContract.Id;
        if(projSite != null)
        {
            tempProjectContractFunding.Project_Site__c = projSite.Id;
        }
        insert tempProjectContractFunding;
        //projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
        //FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);

    }

 
*/

  /*
    * Method Name: createContracData
    * Description: This method create a project contract,lines and funding record
    * @param: Project__c project
    * @return: void
    */

    public static void createContracData(Project__c project) {
        tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();

        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }

        //prepare contract record
        tempProjectContract.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Application_Date__c = DateTime.now();
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;

        //prepare contract line record
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Buyer__c = project.Program_Version__r.Buyer_ID__c;
        tempProjectContractLine.Line_Description__c = project.Program_Version__r.Header_Description__c;

        projectContractsMap.put(projectUniqueId, tempProjectContract);
        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping
        projectUniqueId++;
        projectLineUniqueId++;
    }
        /*
    * Method Name: createContracDataForLSRProjects
    * Description: This method create a project contract,lines and funding record for LSR Projects
    * @param: Project__c project
    * @return: void
    */

    public static void createContracDataForLSRProjects(Project__c project) {
        tempProjectContract = new Project_Contract__c();
        tempProjectContractLine = new Project_Contract_Line__c();

        string proposerRole = 'Proposer';

        if(project.Project_Roles__r != null && project.Project_Roles__r.size() > 0) {
          for(Project_Role__c objRole : project.Project_Roles__r) {
            if(objRole.Primary_Customer_Contact__c && proposerRole.equalsIgnoreCase(objRole.Role__c)) {
              tempProjectContract.Supplier_ID__c = objRole.Role_Supplier_ID__c;
            }
          }
        }

        // get the buyer id of the owner
        User buyer;
        String buyerID;
        System.debug('project.OwnerId***'+project.OwnerId);
        System.debug('userMap******'+userMap);
        if(project.OwnerId!= null && !userMap.isEmpty() && userMap.containsKey(project.OwnerId)){
            buyer = userMap.get(project.OwnerId);
            buyerID = buyer.Buyer_ID__c;
            if(String.isEmpty(buyerID)){
                // if the record owner doesn't have a Buyer ID on their User account then default to the Solicitaion buyer
                buyerID = project.Program_Version__r.Buyer_Id__c;
            }

            //prepare contract record
            tempProjectContract.Buyer_ID__c = buyerID;
        }
        tempProjectContract.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContract.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContract.Anticipated_Term_Over_A_Year__c = project.Program_Version__r.Anticipated_Term_Over_A_Year__c;
        tempProjectContract.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContract.Application_Recevived__c = 'Y';
        tempProjectContract.Application_Date__c = DateTime.now();
        tempProjectContract.Project__c = project.Id;
        tempProjectContract.Status__c = ProjectContract_Helper.STATUS_OPEN;

        //prepare contract line record
        tempProjectContractLine.Procurement_Method__c = project.Program_Version__r.Procurement_Method__c;
        tempProjectContractLine.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractLine.Project__c = project.Id;
        tempProjectContractLine.Buyer__c = buyerID;
        tempProjectContractLine.Line_Description__c = project.Program_Version__r.Header_Description__c;

        //prepare contract Funding record

        tempProjectContractFunding = new Project_Funding__c();
        tempProjectContractFunding.Account_Number__c = project.Program_Version__r.Account_Number__c;
        tempProjectContractFunding.Distribution_Amount__c = (project.Bid_Price__c!=null?project.Bid_Price__c:0) * (project.Bid_Quantity__c !=null?project.Bid_Quantity__c :0)* (project.Contract_Duration__c!=null?project.Contract_Duration__c:0);
        tempProjectContractFunding.Fund__c = project.Program_Version__r.Fund__c;
        tempProjectContractFunding.Department__c = project.Program_Version__r.Department__c;
        tempProjectContractFunding.Project_ID__c = project.Program_Version__r.NEIS_Project_Id__c;
        tempProjectContractFunding.Activity_ID__c = project.Program_Version__r.Activity_ID__c;
        tempProjectContractFunding.Market_Focus__c = project.Program_Version__r.Market_Focus__c;
        tempProjectContractFunding.Project__c = project.Id;
        tempProjectContractFunding.Distribution_Pct__c = '100';

        /*
        tempProjectContractFunding.Header_Description__c = project.Program_Version__r.Header_Description__c;
        tempProjectContractFunding.Agreement_Code__c = project.Program_Version__r.Agreement_Code__c;
        tempProjectContractFunding.Procurement_Contract__c = project.Program_Version__r.Procurement_Contract__c;
        tempProjectContractFunding.Category__c = project.Program_Version__r.Category__c;
        tempProjectContractFunding.Buyer_ID__c = project.Program_Version__r.Buyer_ID__c;
        */
        projectFundingsMap.put(projectFundingUniqueId, tempProjectContractFunding);
        FundingToContractlineMapping.put(projectFundingUniqueId, projectLineUniqueId);

        projectContractsMap.put(projectUniqueId, tempProjectContract);
        projectContractLinesMap.put(projectLineUniqueId, tempProjectContractLine);
        contractlineToContractMapping.put(projectLineUniqueId, projectUniqueId); //Project line to contract record mapping
        projectUniqueId++;
        projectLineUniqueId++;
    }
}