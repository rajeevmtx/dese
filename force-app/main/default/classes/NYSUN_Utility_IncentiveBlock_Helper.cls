/*
*   Class Name: NYSUN_Utility_IncentiveBlock_Helper
*   Description: Utility Class for NY Sun Blocks
*
*  
*                                                         
*/
public class NYSUN_Utility_IncentiveBlock_Helper
{
    public static final String UTILITY_CON_EDISON = 'Con Edison';
    public static final String UTILITY_PSEG = 'PSEG';
    public static final String UTILITY_REST_OF_STATE = 'Rest of State';
    public static final Integer MAX_PROJECTS_PER_BLOCK = 1000;
    public static Set<String> UTILITY_CON_EDISON_PICKLIST // utility values that represent Con Edison Block
    {
        get
        {
            if (UTILITY_CON_EDISON_PICKLIST == null)
            {
                UTILITY_CON_EDISON_PICKLIST = new Set<String>();
                UTILITY_CON_EDISON_PICKLIST.add('Consolidated Edison');
                UTILITY_CON_EDISON_PICKLIST.add('Consolidated Edison - NYPA');
            }
            return UTILITY_CON_EDISON_PICKLIST;
        }
        set;
    }
    public static Set<String> UTILITY_PSEG_PICKLIST // utility values that represent Long Island Block
    {
        get
        {
            if (UTILITY_PSEG_PICKLIST == null)
            {
                UTILITY_PSEG_PICKLIST = new Set<String>();
                UTILITY_PSEG_PICKLIST.add('PSEG');
                UTILITY_PSEG_PICKLIST.add('PSEG - NYPA');
            }
            return UTILITY_PSEG_PICKLIST;
        }
        set;
    }
    public static final String UTILITY_SECTOR_NONRESIDENTIAL = 'Small Nonresidential';
    public static final String UTILITY_SECTOR_NONRESIDENTIAL_INPUT = 'Non-Residential';
    public static final String UTILITY_SECTOR_RESIDENTIAL = 'Residential';
    public static final String UTILITY_SECTOR_COMMERCIAL = 'Commercial/Industrial';
    
    public static final Set<String> statusesThatCount = new Set<String>(new String[]{Project_Helper.PROJECT_STATUS_SUBMITTED,
                Project_Helper.PROJECT_STATUS_PENDINGAPPROVAL,
                Project_Helper.PROJECT_STATUS_APPROVED,
                Project_Helper.PROJECT_STATUS_RECEIVED,
                Project_Helper.PROJECT_STATUS_RISK_OF_TERMINATION,
                Project_Helper.PROJECT_STATUS_COMPLETED});
     

    private static Utility_MapChain IncentiveBlocks // current incentive blocks.  Should never have more than 8 values for NY Sun
    {
        get
        {
            if (IncentiveBlocks == null)
            { 
                IncentiveBlocks = new Utility_MapChain();
                for(Program_Incentive_Block__c block :[SELECT parent__r.planned_amount__c,parent__r.exhausted_amount__c
                                                        ,parent__r.planned_mw__c,parent__r.exhausted_mw__c
                                                        ,parent__r.max_rate__c,parent__r.min_rate__c
                                                        ,parent__r.breaking_point_kw__c,parent__r.monetary_rate__c
                                                        ,parent__r.volumetric_rate__c,parent__r.utility__c
                                                        ,parent__r.type__c,parent__r.remaining_mw__c
                                                        FROM Program_Incentive_Block__c 
                                                        WHERE parent__r.is_active__c = true AND parent__r.open_datetime__c != NULL 
                                                        AND parent__r.closed_datetime__c = NULL AND closed_datetime__c = NULL
                                                        AND parent__c != NULL])
                {
                    String recType = translateRecordType(block.parent__r.type__c);
                    if (recType == NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME)
                        IncentiveBlocks.putData(new String[]{recType,block.parent__r.utility__c},block);
                    else
                        IncentiveBlocks.putData(new String[]{recType,block.parent__r.utility__c,block.parent__r.type__c},block);
                }
                
            }
            return IncentiveBlocks;
        }
        set;
    }
    
    private static Utility_MapChain AllIncentiveBlocks // current incentive blocks.  Should never have more than 8 values for NY Sun
    {
        get
        {
            if (AllIncentiveBlocks == null)
            {
                AllIncentiveBlocks = new Utility_MapChain();
                for(Program_Incentive_Block__c block :[SELECT planned_amount__c,exhausted_amount__c,planned_mw__c,exhausted_mw__c
                                                        ,max_rate__c,min_rate__c,breaking_point_kw__c,monetary_rate__c
                                                        ,volumetric_rate__c,utility__c,type__c,remaining_mw__c,sequence__c
                                                        ,open_datetime__c,closed_datetime__c
                                                        FROM Program_Incentive_Block__c 
                                                        WHERE is_active__c = true AND parent__c = NULL
                                                        ORDER BY type__c desc,utility__c,sequence__c])
                {
                    Program_Incentive_Block__c[] blocks = (Program_Incentive_Block__c[]) AllIncentiveBlocks.getData(new String[]{block.utility__c,block.type__c});

                    if (blocks == null)
                    {
                        blocks = new Program_Incentive_Block__c[]{};
                        AllIncentiveBlocks.putData(new String[]{block.utility__c,block.type__c},blocks);
                    }
                    blocks.add(block);
                }
                
            }

            return AllIncentiveBlocks;
        }
        set;
    }
    
    /*
  * Method Name: getBlock
  * Description: helper method to get the current block based on record type, utility and residential vs non-residential
  * @param: String recType
  * @param: String utility
  * @param: String typ
  * @return: Program_Incentive_Block__c                                                       
  */ 
    public static Program_Incentive_Block__c getBlock(String recType, String utility, String typ)
    {
        if (recType == NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME)
            return (Program_Incentive_Block__c) IncentiveBlocks.getData(new String[]{recType,utility});
        return (Program_Incentive_Block__c) IncentiveBlocks.getData(new String[]{recType,utility,typ});
    }
    
    /*
  * Method Name: getBlocks
  * Description: helper method to get the current block based on record type, utility and residential vs non-residential
  * @param: String utility
  * @param: String typ
  * @return: Program_Incentive_Block__c                                                       
  */
    public static Program_Incentive_Block__c[] getBlocks(String utility, String typ)
    {
        if (utility == UTILITY_SECTOR_COMMERCIAL)
            return (Program_Incentive_Block__c[]) AllIncentiveBlocks.getData(new String[]{utility,typ});
        return (Program_Incentive_Block__c[]) AllIncentiveBlocks.getData(new String[]{utility,typ});
    }
    
    /*
  * Method Name: translateUtility
  * Description: take a utility from a project and translate it to a block utility
  * @param: String utility
  * @return: String                                                       
  */
    public static String translateUtility(String utility)
    {
        if (UTILITY_CON_EDISON_PICKLIST.contains(utility))
            return UTILITY_CON_EDISON;
        else if (UTILITY_PSEG_PICKLIST.contains(utility))
            return UTILITY_PSEG;
        else
            return UTILITY_REST_OF_STATE;
    }
    
    /*
  * Method Name: translateUtilitySector
  * Description: take a sector from a project and translate it to a block sector
  * @param: String utilitySector
  * @return: String                                                       
  */
    public static String translateUtilitySector(String utilitySector)
    {
        if (utilitySector == UTILITY_SECTOR_NONRESIDENTIAL_INPUT)
            return UTILITY_SECTOR_NONRESIDENTIAL;
        return UTILITY_SECTOR_RESIDENTIAL;
    }
    
    /*
  * Method Name: translateUtilitySector
  * Description: take a record type developer name and a sector from a project and translate it to a block sector
  * @param: String utilitySector
  * @param: String recordTypeDevName
  * @return: String                                                       
  */
    public static String translateUtilitySector(String recordTypeDevName, String utilitySector)
    {
        if (recordTypeDevName == NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME)
            return UTILITY_SECTOR_COMMERCIAL;
        else
            return translateUtilitySector(utilitySector);
    }
    
    /*
  * Method Name: translateRecordType
  * Description: take a block sector and translate it to a record type
  * @param: String typ
  * @return: String                                                       
  */
    private static String translateRecordType(String typ)
    {
        if (typ == UTILITY_SECTOR_RESIDENTIAL || typ == UTILITY_SECTOR_NONRESIDENTIAL)
            return NYSUN_Helper.RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME;
        else
            return NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME;
    }
    
    /*
  * Method Name: openNewBlock
  * Description: when a block is ready to close, open a new one
  * @param: String utility
  * @param: String typ
  * @param: Decimal seq
  * @param: Id blockId
  * @return: void                                                       
  */
    @future
    public static void openNewBlock(String utility, String typ, Decimal seq, Id blockId)
    {
        System.debug(seq);
        Program_Incentive_Block__c[] blocks = [SELECT open_datetime__c,sequence__c,Name FROM Program_Incentive_Block__c
                                                    WHERE utility__c = :utility
                                                    AND type__c = :typ
                                                    AND sequence__c > :seq
                                                    AND open_datetime__c = null AND closed_datetime__c = null
                                                    AND is_active__c = true AND parent__c = null
                                                    ORDER BY sequence__c LIMIT 1];
        Program_Incentive_Block__c blockToOpen;
        if (blocks.size() > 0)
            blockToOpen = blocks[0];
        if (blockToOpen != null)
        {
            blockToOpen.open_datetime__c = system.now();
            update blockToOpen;
        }
        // reassign existing applications in the old block
        Project__c[] projectsToReassign = [SELECT program_incentive_block__c,Name,Is_Current_Block_Changed__c, 
                               Current_Block_Rate__c, Total_System_Size__c,status__c,
                               Estimated_Annual_Energy_Production__c,Strategic_Location__c,
                               Net_Metering_Crediting_Method__c,
                               (Select Incentive_Amount__c, Sub_Type__c 
                                  From Project_Milestones__r
                                 Where Parent__c != null)
                           			FROM Project__c
                                            WHERE program_incentive_block__r.parent__c = :blockId
                                            AND (status__c = :Project_Helper.PROJECT_STATUS_UNSUBMITTED
                                             OR  Is_Current_Block_Changed__c = true)];
        
        if (projectsToReassign.size() > 0)
        {
            Program_Incentive_Block__c newSubBlock;
            if (blockToOpen != null)
            {
                newSubBlock = [SELECT Id, Min_Rate__c, Max_Rate__c,
                            Parent__r.Utility__c,Parent__r.Max_Rate__c,
                            Parent__r.Volumetric_Rate__c, Parent__r.Monetary_Rate__c
                         FROM Program_Incentive_Block__c
                                WHERE parent__c = :blockToOpen.Id LIMIT 1];
            }
            
            Boolean isSubmittedProject;                                            
            Id newSubBlockId = newSubBlock == null ? null : newSubBlock.Id;
            Set<Id> projectsToUncompleteComponentsTab = new Set<Id>();
            List<Project_Milestones__c> milestoneToBeUpdate = new List<Project_Milestones__c>();
            List<Program_Incentive_Block__c> incentiveBlockToBeUpdate = new List<Program_Incentive_Block__c>();
            for (Project__c project :projectsToReassign)
            {
              isSubmittedProject = false;   
                project.program_incentive_block__c = newSubBlockId;
                //recalcualted submitted project incentive amount based on new allocated blcok
                if(project.Is_Current_Block_Changed__c && project.Status__c == Project_Helper.PROJECT_STATUS_SUBMITTED
                   && project.Estimated_Annual_Energy_Production__c != null && project.Estimated_Annual_Energy_Production__c > 0) 
                {
                  isSubmittedProject = true;  
                  Decimal currentBlockRate = 0;
                  Decimal pbiRate = 0;
                  Decimal calculatedBaseIncentive;
                  Decimal additionalIncentive = 0;
                  Decimal strategicLocationIncentive = 0;
                  if(newSubBlock.Parent__r.Utility__c == 'Con Edison') 
                  {
                  currentBlockRate = newSubBlock.Parent__r.Max_Rate__c;
              } else if(project.Net_Metering_Crediting_Method__c == 'Volumetric') 
              {
                  currentBlockRate = newSubBlock.Parent__r.Volumetric_Rate__c;
              } else if(project.Net_Metering_Crediting_Method__c == 'Monetary') 
              { 
                  currentBlockRate = newSubBlock.Parent__r.Monetary_Rate__c;
              }
                  //assign new current block rate
                  project.Current_Block_Rate__c = currentBlockRate;
                  project.Is_Current_Block_Changed__c = false;
                  //calculate new incentive
                  pbiRate = ((currentBlockRate * 1000) / (8760 * 3 * 0.134)).setScale(3);
                  calculatedBaseIncentive = (pbiRate * project.Estimated_Annual_Energy_Production__c * 3).setScale(2);
                  
                  if(project.Strategic_Location__c)  
                  {
                  strategicLocationIncentive = ((calculatedBaseIncentive * 1.2) - calculatedBaseIncentive).setScale(2);
              } 
              calculatedBaseIncentive += strategicLocationIncentive;
              
              //Distribute incentive in milestone
              for(Project_Milestones__c milestone : project.Project_Milestones__r) 
              {
                if(milestone.Sub_Type__c != NYSUN_Helper.ENERGY_EFFICIENCY_INCENTIVE_SUB_TYPE && milestone.Sub_Type__c != NYSUN_Helper.BATTERY_STORAGE_INCENTIVE_SUB_TYPE ) 
                {
                          milestone.Incentive_Amount__c = calculatedBaseIncentive/4;
                } else {
                  additionalIncentive += milestone.Incentive_Amount__c;
                }
                milestoneToBeUpdate.add(milestone);
              }
              
              //Update incentive Block Amount and MW
              incentiveBlockToBeUpdate.add(new Program_Incentive_Block__c(Id=newSubBlockId, exhausted_mw__c=(project.Total_System_Size__c/1000), 
                                                            exhausted_amount__c=(calculatedBaseIncentive+additionalIncentive)));
                }
                
                //Flag if current block is changing for unsubmtted projects.
                if(project.Status__c == Project_Helper.PROJECT_STATUS_UNSUBMITTED) {
                  project.Is_Current_Block_Changed__c = true;
                }
                
                if(!isSubmittedProject) 
                {
                  projectsToUncompleteComponentsTab.add(project.id);
                }
            }
            
            update projectsToReassign;
            
            if(milestoneToBeUpdate.size() > 0) 
            {
              update milestoneToBeUpdate;
            }
            
            if(incentiveBlockToBeUpdate.size() > 0) 
            {
              update incentiveBlockToBeUpdate;
            }
            
            // uncomplete steps 5-7 if we changed blocks and 
            // reject Documents
            NYSUN_Helper.uncompletetabsAndRejectProjectDocuments(projectsToUncompleteComponentsTab);
        }
    }

    /*
  * Method Name: resetCache
  * Description: purpose to set the IncentiveBlocks as null for the test class
  * @param: String typ
  * @return: String                                                       
  */
    public static void resetCache(){
        IncentiveBlocks  = null;
    }
}