/*
* Class Name: BudgetDetail_TriggerHandler
* Description: Handler class for Budget detail   
* Author/Date: Gaurav Sinha  6/16/2016
*                                                             
*/


public with sharing  class BudgetDetail_TriggerHandler {
    
    
    /*
	* Method Name: afterInsert
	* Description: Method to call the processing after insert
	* @return:  void
	* @param:  map<id,BudgetDetail__c > mapNewBudget :new map of budget detail
	*/
      
    public static void afterInsert(map<id,BudgetDetail__c > mapNewBudget){
        if(!Utility_BudgetCloneTriggerDisable.executeTrigger){
            System.debug('do not enter');
            createBudgetCategory(mapNewBudget);    
        }
        set<id> budgetSummary = new set<id>();
        for(BudgetDetail__c bd : mapNewBudget.values()){
            budgetSummary.add(bd.BudgetSummary__c);
        }
        if(!budgetSummary.isEmpty())
            summarizeBudget(budgetSummary);        
    }
    
     
    /*
	* Method Name: afterUpdate
	* Description: Method to call the processing after update
	* @return:  void
	* @param:  map<id,BudgetDetail__c > mapNewBudget :new map of budget detail
	* @param:  list<BudgetDetail__c> newListBudgetDetail : list of budget detail
	*/
    
    public static void afterUpdate(list<BudgetDetail__c> newListBudgetDetail,map<id,BudgetDetail__c > mapoldBudget){
        set<id> budgetSummary = new set<id>();
        Set<id> setBudgetIdentifier = new set<Id>();
        set<id> budgetDetailUpdateId = new Set<Id>();
        for(BudgetDetail__c varLoop : newListBudgetDetail){
            // Capturing Budget Summary
            budgetSummary.add(varLoop.BudgetSummary__c);  
            // Detecting change in Active 
            if(varLoop.Active__c == true && 
                mapoldBudget.get(varLoop.id).active__C == false &&
                varloop.status__c == 'Approved'){
                    setBudgetIdentifier.add(varloop.BudgetIdentifier__c);
                    budgetDetailUpdateId.add(varLoop.id);
            }            
        }
        if(!budgetSummary.isEmpty())
            summarizeBudget(budgetSummary);
        if(!setBudgetIdentifier.isEmpty() && !budgetDetailUpdateId.isEmpty()){
            oneActiveBudget(setBudgetIdentifier,budgetDetailUpdateId);
        }
    }
    /*
	* Method Name: oneActiveBudget
	* Description: Purpose of this method is to Keep only one Active Approved budget all times
	* @return:  void
	* @param:  Set<id> setBudgetIdentifier :set of id's 
	* @param:  set<id> budgetDetailUpdateId : set of id's 
	*/
    public static void oneActiveBudget(Set<id> setBudgetIdentifier , set<id> budgetDetailUpdateId){

        List<BudgetDetail__c> updateBudgetDetail = new List<BudgetDetail__c>();
        for(BudgetDetail__c varloop: [select id, active__C 
                                        from BudgetDetail__c 
                                        where BudgetIdentifier__c in :setBudgetIdentifier
                                        and   id not in :budgetDetailUpdateId]){
            varLoop.active__c = false;
            updateBudgetDetail.add(varLoop);
        }
        if(!updateBudgetDetail.isEmpty())
            update updateBudgetDetail;
    } 
    
    /*
	* Method Name: createBudgetCategory
	* Description: Method to call the create Budget category object
	* @return:  void
	* @param:  map<id,BudgetDetail__c > mapNewBudget : map of budget detail 
	*/   
       
    public static void createBudgetCategory(map<id,BudgetDetail__c > mapNewBudget){
        // Metadata Budget_Category_Settings__mdt stores all the input required to create the budget category
        list<Budget_Category_Settings__mdt> libcSetting = new list<Budget_Category_Settings__mdt>();
        for(Budget_Category_Settings__mdt varloop: [select id,label ,HoursRate__c,RateBase__c,RateElement__c,Sequence__c
                                                    from Budget_Category_Settings__mdt 
                                                    where active__C = true
                                                    order by Sequence__c asc]){
                libcSetting.add(varloop);
            
        }
        list<BudgetCategory__c> libudgetCategory = new List<BudgetCategory__c>();
        for(id varLoop: mapNewBudget.keySet()){
            for(Budget_Category_Settings__mdt bcsetting : libcSetting){
                libudgetCategory.add(new BudgetCategory__c(Budget_Detail__c = varloop,
                                                            name= bcsetting.label,
                                                            HoursRate__c = bcsetting.HoursRate__c,
                                                            RateBase__c = bcsetting.RateBase__c,
                                                            RateElement__c = bcsetting.RateElement__c,
                                                            Sequence__c = bcsetting.Sequence__c
                                                            ) );
                
            }
        }
        
        if(!libudgetCategory.isempty()){
            insert libudgetCategory;
        }
    }
    
    /*
	* Method Name: afterDelete
	* Description: Method trigger if any budget category is deleted.
	* @return:  void
	* @param:  List<BudgetDetail__c> deleteBudgetCategory : list of budget detail 
	*/  
    
    public static void afterDelete(List<BudgetDetail__c> deleteBudgetCategory){
        set<id> budgetSummary = new set<id>();
        for(BudgetDetail__c bd : deleteBudgetCategory){
            budgetSummary.add(bd.BudgetSummary__c);
        }
        summarizeBudget(budgetSummary);
    }
    
    /*
	* Method Name: summarizeBudget
	* Description: Method for rollup Budget Detail on Budget summary
	* @return:  void
	* @param: Set<Id> budgetIds : set of id's 
	*/
    
    public static void summarizeBudget(Set<Id> budgetIds) {
        //Get budgets to Update
        list<BudgetSummary__c> budgetSum = querybudgetsById(budgetIds);

        Map<Id, Budgetwrapper> results = getBudgetAmountsBybudgetId(budgetIds);

        //Loop budgets and set Won Amount
        List<BudgetSummary__c> budgetsToUpdate = new List<BudgetSummary__c>();
        Budgetwrapper bw;
        for (BudgetSummary__c bs : budgetSum) {
            boolean valid = false;

            if (results.containsKey(bs.Id)) {
                bw = results.get(bs.Id);

            //Determine if Total Amount has Changed
                if (bs.DirectLaborCostShare__c != bw.DirectLaborCostShare) {
                    bs.DirectLaborCostShare__c = bw.DirectLaborCostShare;
                    valid=true; //Add budget to collection to be updated
                }               
                
                if (bs.DirectLaborNYSERDACost__c != bw.DirectLaborNYSERDACost) {
                    bs.DirectLaborNYSERDACost__c = bw.DirectLaborNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.DirectMaterialsCostShare__c != bw.DirectMaterialsCostShare) {
                    bs.DirectMaterialsCostShare__c = bw.DirectMaterialsCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.DirectMaterialsNYSEDRACost__c != bw.DirectMaterialsNYSEDRACost) {
                    bs.DirectMaterialsNYSEDRACost__c = bw.DirectMaterialsNYSEDRACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.EquipmentCostShare__c != bw.EquipmentCostShare) {
                    bs.EquipmentCostShare__c = bw.EquipmentCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.EquipmentNYSERDACost__c != bw.EquipmentNYSERDACost) {
                    bs.EquipmentNYSERDACost__c = bw.EquipmentNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.GeneralAdministrationExpNYSERDACost__c != bw.GeneralAdministrationExpNYSERDACost) {
                    bs.GeneralAdministrationExpNYSERDACost__c = bw.GeneralAdministrationExpNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.GeneralAdministrationExpenCostShare__c != bw.GeneralAdministrationExpenCostShare) {
                    bs.GeneralAdministrationExpenCostShare__c = bw.GeneralAdministrationExpenCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.LaborOverheadCostShare__c != bw.LaborOverheadCostShare) {
                    bs.LaborOverheadCostShare__c = bw.LaborOverheadCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.LaborOverheadNYSERDACost__c != bw.LaborOverheadNYSERDACost) {
                    bs.LaborOverheadNYSERDACost__c = bw.LaborOverheadNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.MaterialsOverheadCostShare__c != bw.MaterialsOverheadCostShare) {
                    bs.MaterialsOverheadCostShare__C = bw.MaterialsOverheadCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                
                if (bs.MaterialsOverheadNYSERDACost__c != bw.MaterialsOverheadNYSERDACost) {
                    bs.MaterialsOverheadNYSERDACost__c = bw.MaterialsOverheadNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.TravelCostShare__c != bw.TravelCostShare) {
                    bs.TravelCostShare__c = bw.TravelCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.TravelNYSERDACost__c != bw.TravelNYSERDACost) {
                    bs.TravelNYSERDACost__c = bw.TravelNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.SubcontractorsConsultantsNYSERDACost__c != bw.SubcontractorsConsultantsNYSERDACost) {
                    bs.SubcontractorsConsultantsNYSERDACost__c = bw.SubcontractorsConsultantsNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                }                 
                
               if (bs.SubcontractorsConsultantsCostShare__c != bw.SubcontractorsConsultantsCostShare) {
                    bs.SubcontractorsConsultantsCostShare__c = bw.SubcontractorsConsultantsCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.OutsideSpecialTestingNYSERDACost__c != bw.OutsideSpecialTestingNYSERDACost) {
                    bs.OutsideSpecialTestingNYSERDACost__c = bw.OutsideSpecialTestingNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.OutsideSpecialTestingCostShare__c != bw.OutsideSpecialTestingCostShare) {
                    bs.OutsideSpecialTestingCostShare__c = bw.OutsideSpecialTestingCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                
                if (bs.OtherDirectCostsCostShare__c != bw.OtherDirectCostsCostShare) {
                    bs.OtherDirectCostsCostShare__c = bw.OtherDirectCostsCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.OtherDirectCostsNYSERDACost__c != bw.OtherDirectCostsNYSERDACost) {
                    bs.OtherDirectCostsNYSERDACost__c = bw.OtherDirectCostsNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.FeeProfitCostShare__c != bw.FeeProfitCostShare) {
                    bs.FeeProfitCostShare__c = bw.FeeProfitCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.FeeProfitNYSERDACost__c != bw.FeeProfitNYSERDACost) {
                    bs.FeeProfitNYSERDACost__c = bw.FeeProfitNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                }  
                
                if (bs.FinalDeliverableCostShare__c != bw.FinalDeliverableCostShare) {
                    bs.FinalDeliverableCostShare__c = bw.FinalDeliverableCostShare;
                    valid=true; //Add budget to collection to be updated
                } 
                
                if (bs.FinalDeliverableNYSERDACost__c != bw.FinalDeliverableNYSERDACost) {
                    bs.FinalDeliverableNYSERDACost__c = bw.FinalDeliverableNYSERDACost;
                    valid=true; //Add budget to collection to be updated
                }           
                
                if(valid){
                    budgetsToUpdate.add(bs);
                }
            }


        }

        if(budgetsToUpdate.isEmpty() == false) {
            Database.SaveResult[] saveResults = Database.update(budgetsToUpdate, false);
            System.debug(saveResults);
        }
    }
    
    /*
	* Method Name: getBudgetAmountsBybudgetId
	* Description: to get budget amount by budget id's
	* @return:  Map<Id, Budgetwrapper>
	* @param: Set<Id> budgetSummary : set of id's 
	*/
    //Private Methods
    Private static Map<Id, Budgetwrapper> getBudgetAmountsBybudgetId(Set<Id> budgetSummary) {
       Map<Id, Budgetwrapper> mapBudget = new Map<Id, Budgetwrapper>();
        
        Budgetwrapper bw ;
        //Summarize Won Opportunity Amounts by budget Id
        AggregateResult[] results = aggregateBudgetAmounts(budgetSummary);
        for (AggregateResult result : results) {
        bw = new Budgetwrapper();
            Id budgetSumId = (Id) result.get('BudgetSummary__c');
            double total = (double) result.get('DirectLaborCostShare');
            bw.DirectLaborCostShare = total!=null ? total:0;
            total = (double) result.get('DirectLaborNYSERDACost');
            bw.DirectLaborNYSERDACost = total!=null ? total:0;            
            total = (double) result.get('DirectMaterialsCostShare');
            bw.DirectMaterialsCostShare = total!=null ? total:0;      
            total = (double) result.get('DirectMaterialsNYSEDRACost');
            bw.DirectMaterialsNYSEDRACost = total!=null ? total:0;      
            total = (double) result.get('EquipmentCostShare');
            bw.EquipmentCostShare = total!=null ? total:0;      
            total = (double) result.get('EquipmentNYSERDACost');
            bw.EquipmentNYSERDACost = total!=null ? total:0;      
            total = (double) result.get('GeneralAdministrationExpNYSERDACost');
            bw.GeneralAdministrationExpNYSERDACost = total!=null ? total:0;      
            total = (double) result.get('GeneralAdministrationExpenCostShare');
            bw.GeneralAdministrationExpenCostShare = total!=null ? total:0;      
            total = (double) result.get('LaborOverheadCostShare');
            bw.LaborOverheadCostShare = total!=null ? total:0;      
            total = (double) result.get('LaborOverheadNYSERDACost');
            bw.LaborOverheadNYSERDACost = total!=null ? total:0;      
            total = (double) result.get('MaterialsOverheadCostShare');
            bw.MaterialsOverheadCostShare = total!=null ? total:0;      
            total = (double) result.get('MaterialsOverheadNYSERDACost');
            bw.MaterialsOverheadNYSERDACost = total!=null ? total:0;      
            total = (double) result.get('TravelCostShare');
            bw.TravelCostShare = total!=null ? total:0;      
            total = (double) result.get('TravelNYSERDACost');
            bw.TravelNYSERDACost = total!=null ? total:0;      
            total = (double) result.get('SubcontractorsConsultantsNYSERDACost');
            bw.SubcontractorsConsultantsNYSERDACost = total!=null ? total:0;      
            total = (double) result.get('SubcontractorsConsultantsCostShare');
            bw.SubcontractorsConsultantsCostShare = total!=null ? total:0;      
            total = (double) result.get('OutsideSpecialTestingNYSERDACost');
            bw.OutsideSpecialTestingNYSERDACost = total!=null ? total:0;      
            total = (double) result.get('OutsideSpecialTestingCostShare');
            bw.OutsideSpecialTestingCostShare = total!=null ? total:0;                  
            total = (double) result.get('OtherDirectCostsCostShare');
            bw.OtherDirectCostsCostShare = total!=null ? total:0;   
            total = (double) result.get('OtherDirectCostsNYSERDACost');
            bw.OtherDirectCostsNYSERDACost = total!=null ? total:0;   
            total = (double) result.get('FeeProfitCostShare');
            bw.FeeProfitCostShare = total!=null ? total:0;   
            total = (double) result.get('FeeProfitNYSERDACost');
            bw.FeeProfitNYSERDACost = total!=null ? total:0; 
            total = (double) result.get('FinalDeliverableCostShare');
            bw.FinalDeliverableCostShare = total!=null ? total:0;   
            total = (double) result.get('FinalDeliverableNYSERDACost');
            bw.FinalDeliverableNYSERDACost = total!=null ? total:0;               
            mapBudget.put(budgetSumId, bw);
        }
        return mapBudget;
    }

    //Query Methods
    private static  List<BudgetSummary__c> querybudgetsById(Set<Id> budgetSummary) {
        return [SELECT 
                DirectLaborCostShare__c,DirectLaborNYSERDACost__c,
                DirectLaborTotalCost__c,DirectMaterialsCostShare__c,
                DirectMaterialsNYSEDRACost__c,DirectMaterialsTotalCost__c,
                EquipmentCostShare__c,EquipmentNYSERDACost__c,EquipmentTotalCost__c,
                FeeProfitCostShare__c,FeeProfitNYSERDACost__c,FeeProfitTotalCost__c,
                GeneralAdministrationExpenCostShare__c,GeneralAdministrationExpNYSERDACost__c,
                GeneralAdministrationTotalCost__c,Id,IsDeleted,LaborOverheadCostShare__c,
                LaborOverheadNYSERDACost__c,LaborOverheadTotalCost__c,LastActivityDate,
                MaterialsOverheadCostShare__c,MaterialsOverheadNYSERDACost__c,
                MaterialsOverheadTotalCost__c,Name,OtherDirectCostsCostShare__c,
                OtherDirectCostsNYSERDACost__c,OtherDirectCostsTotalCost__c,
                OutsideSpecialTestingCostShare__c,OutsideSpecialTestingNYSERDACost__c,
                OutsideSpecialTestingTotalCost__c,SubcontractorsConsultantsCostShare__c,
                SubcontractorsConsultantsNYSERDACost__c,SubcontractorsConsultantsTotalCost__c,
                SystemModstamp,TravelCostShare__c,TravelNYSERDACost__c,TravelTotalCost__c,
                FinalDeliverableCostShare__c,FinalDeliverableNYSERDACost__c,FinalDeliverableTotalCost__c
            FROM 
                BudgetSummary__c 
            WHERE 
                Id IN :budgetSummary];
    }
    
    private static  AggregateResult[] aggregateBudgetAmounts(Set<Id> budgetSummary) {
        return [SELECT BudgetSummary__c,SUM(DirectLaborCostShare__c) DirectLaborCostShare,SUM(DirectLaborNYSERDACost__c) DirectLaborNYSERDACost,SUM(
               DirectLaborTotalCost__c) DirectLaborTotalCost,SUM(DirectMaterialsCostShare__c) DirectMaterialsCostShare,SUM(DirectMaterialsNYSEDRACost__c) DirectMaterialsNYSEDRACost,
               SUM(DirectMaterialsTotalCost__c) DirectMaterialsTotalCost,SUM(EquipmentCostShare__c) EquipmentCostShare,SUM(EquipmentNYSERDACost__c) EquipmentNYSERDACost,SUM(EquipmentTotalCost__c) EquipmentTotalCost,
                SUM(FeeProfitCostShare__c) FeeProfitCostShare,SUM(FeeProfitNYSERDACost__c) FeeProfitNYSERDACost,SUM(FeeProfitTotalCost__c) FeeProfitTotalCost,SUM(GeneralAdministrationExpenCostShare__c) GeneralAdministrationExpenCostShare,
                SUM(GeneralAdministrationExpNYSERDACost__c) GeneralAdministrationExpNYSERDACost,SUM(GeneralAdministrationTotalCost__c) GeneralAdministrationTotalCost,
                SUM(LaborOverheadCostShare__c) LaborOverheadCostShare,SUM(LaborOverheadNYSERDACost__c) LaborOverheadNYSERDACost,SUM(
                LaborOverheadTotalCost__c) LaborOverheadTotalCost,SUM(MaterialsOverheadCostShare__c) MaterialsOverheadCostShare,SUM(MaterialsOverheadNYSERDACost__c)MaterialsOverheadNYSERDACost,
                SUM(MaterialsOverheadTotalCost__c) MaterialsOverheadTotalCost,SUM(OtherDirectCostsCostShare__c) OtherDirectCostsCostShare,
                SUM(OtherDirectCostsNYSERDACost__c) OtherDirectCostsNYSERDACost,SUM( OtherDirectCostsTotalCost__c) OtherDirectCostsTotalCost,
                SUM(OutsideSpecialTestingCostShare__c) OutsideSpecialTestingCostShare,SUM(OutsideSpecialTestingNYSERDACost__c) OutsideSpecialTestingNYSERDACost,
                SUM( OutsideSpecialTestingTotalCost__c) OutsideSpecialTestingTotalCost,SUM(SubcontractorsConsultantsCostShare__c) SubcontractorsConsultantsCostShare,
                SUM(SubcontractorsConsultantsNYSERDACost__c) SubcontractorsConsultantsNYSERDACost,SUM(SubcontractorsConsultantsTotalCost__c) SubcontractorsConsultantsTotalCost,
                SUM(TravelCostShare__c) TravelCostShare,SUM(TravelNYSERDACost__c) TravelNYSERDACost,SUM(TravelTotalCost__c)  TravelTotalCost,
                SUM(FinalDeliverableCostShare__c) FinalDeliverableCostShare,SUM(FinalDeliverableNYSERDACost__c) FinalDeliverableNYSERDACost,SUM(FinalDeliverableTotalCost__c)  FinalDeliverableTotalCost
        FROM BudgetDetail__c
        where active__c = true
        and   status__c ='Approved'
            GROUP BY 
                BudgetSummary__c];
    }
    
    private class Budgetwrapper {
        
        public Double DirectLaborCostShare;
        public Double DirectLaborNYSERDACost;
        public Double DirectMaterialsCostShare;
        public Double DirectMaterialsNYSEDRACost;
        public Double EquipmentCostShare;
        public Double EquipmentNYSERDACost;
        public Double GeneralAdministrationExpNYSERDACost;
        public Double GeneralAdministrationExpenCostShare;
        public Double LaborOverheadCostShare;
        public Double LaborOverheadNYSERDACost;
        public Double MaterialsOverheadCostShare;
        public Double MaterialsOverheadNYSERDACost; 
        public Double TravelCostShare;
        public Double TravelNYSERDACost;
        public Double SubcontractorsConsultantsNYSERDACost;
        public Double SubcontractorsConsultantsCostShare;
        public Double OutsideSpecialTestingNYSERDACost;
        public Double OutsideSpecialTestingCostShare;
        public Double OtherDirectCostsCostShare;
        public Double OtherDirectCostsNYSERDACost;
        public Double FeeProfitCostShare;
        public Double FeeProfitNYSERDACost;
        public Double FinalDeliverableCostShare;
        public Double FinalDeliverableNYSERDACost;
        
        
    }


}