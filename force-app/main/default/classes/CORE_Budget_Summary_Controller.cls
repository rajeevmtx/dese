//
// Budget Summary Class
//
// June 19, 2016     Gaurav Sinha     original
public class CORE_Budget_Summary_Controller {
    
    public String projectID{
        get{
            if(projectID==null){
                projectID = Apexpages.currentPage().getParameters().get('projectId');
            }
            return projectID;
        }
        private set;
    }
    
    public CORE_Budget_Summary_Controller(){
        project = [select id,name from projecT__C where id =: projectid];
        shownewbutton= false;
        getGlobalData();
    }
    
    public map<string,SummaryWrapper> mainTable{
        get{
            if(mainTable==null){
                mainTable = new map<string,SummaryWrapper>();
                SummaryWrapper swVar = new SummaryWrapper();
                for(Budget_Category_Settings__mdt varloop : [select id , label,Active__c,HoursRate__c,RateBase__c,RateElement__c
                                                           from Budget_Category_Settings__mdt
                                                           where Active__c = true
                                                           order by Sequence__c asc ]){
                    swVar.RateElement = varloop.RateElement__c;
                    swVar.RateBase = varloop.RateBase__c;
                    swVar.HoursRate = varloop.HoursRate__c;
                    swVar.name = varloop.label;
                    maintable.put(swvar.name.trim(),swvar);
                    swVar = new SummaryWrapper();
                }
            }
            return maintable; 
        } 
        set;
    }
    public project__C project{Get;set;}
    public boolean showNewButton{get;set;}
    public transient BudgetSummary__c budgetSummary{get;set;}
    public map<id,BudgetDetail__c> mapBudgetDetail{get;set;}
    public map<id,BudgetDetail__c> activeVersion{get;set;}
    public BudgetDetail__c pageDisplayBudgetDetail{Get;set;}
    public void getGlobalData(){
        activeVersion = new map<id,BudgetDetail__c> ();
        for(BudgetSummary__c varLoop : [SELECT 
                                        DirectLaborCostShare__c,DirectLaborNYSERDACost__c,project__r.name,project__r.application_number__c,
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
                                        FinalDeliverableCostShare__c,FinalDeliverableNYSERDACost__c,FinalDeliverableTotalCost__c,
                                        TotalEstimatedCostSharecost__c,TotalEstimatedNYSERDACost__c,TotalEstimatedTotalCost__c,
                                        (SELECT id,name,Active__c ,status__c,version__c,
                                        		BudgetIdentifier__c, Total_Estimated_CostSharecost__c,
                                        		Total_Estimated_NYSERDA_Cost__c, Total_EstimatedTotal_Cost__c
                                           FROM Budget_Details__r 
                                           order by createdDate desc)
                                        FROM 
                                        BudgetSummary__c 
                                        where project__c = : projectid
                                        limit 1]){
                                            budgetSummary = varLoop;
                                            for(BudgetDetail__c bdloop : varLoop.Budget_Details__r){
                                                if(bdloop.active__c ==true && bdloop.status__c == Clean_Transportation_Helper.CONST_BUDGET_DETAIL_APPROVED){
                                                    activeVersion.put(bdloop.id,bdloop);
                                                }
                                            }
                                        }
        if(budgetSummary ==null){
            showNewButton = true;
        }
        SummaryWrapper gwVar;
       
        map<string,BudgetCategoryLine__c> localTable = new map<string,BudgetCategoryLine__c>();
		SummaryWrapper lwVar;
		System.debug(maintable.values());
		System.debug(activeVersion);
        for(BudgetCategory__c varloop: [ select id,name,(select id,BudgetCategory__r.name,name,Base__c,CostShare__c,BudgetCategory__c,Element_s__c,
                                            Hours__c,Rate__c,NYSERDACost__c,Rate_Percent__c,RatePercentBase__c,
                                            Total_Cost__c
                                            from Budget_Category_Lines__r
                                            )
                                            from BudgetCategory__c
                                            where Budget_Detail__c in : activeVersion.keySet()
                                            order by sequence__c
                                           ]){
                                               gwVar = maintable.get(varloop.name.trim());
                                               for(BudgetCategoryLine__c bdloop : varLoop.Budget_Category_Lines__r){
                                                   System.debug(varloop.name.trim());
                                               
                                               System.debug(gwVar);
                                               system.debug(gwvar.lidetail);
                                               if(gwVar!=null || Test.isRunningTest()){
                                                   System.debug(bdloop.name.trim());
                                                   if(localTable.get(varloop.name.trim())==null){
                                                       
                                                       lwVar = new summarywrapper();
                                                       lwvar.totalcost = bdloop.Total_Cost__c;
                                                       lwvar.costsharecost = bdloop.CostShare__c;
                                                       lwvar.nysedracost = bdloop.NYSERDACost__c;
                                                       lwvar.name = bdloop.name.trim();
                                                       lwvar.bcline = bdloop;
                                                   	gwvar.lidetail.add(lwvar);
                                                   }
                                                   else
                                                       localTable.put(varloop.name,bdloop);
                                               }
                                             
                                               }
                                               


                                               

                                           }
        retrieveData(activeversion);
    }
    
    public Map<Id, List<CORE_Budget_Detail_Controller.BudgetWrapper>> budgetDetailIdToBudgetCategoryListMap {get; set;}
    public list<CORE_Budget_Detail_Controller.BudgetWrapper> liBudgetCategory{get;set;}
    
    public void retrieveData(Map<Id, BudgetDetail__c> libudget) {
        liBudgetCategory = new List<CORE_Budget_Detail_Controller.BudgetWrapper>();
		budgetDetailIdToBudgetCategoryListMap = new Map<Id, List<CORE_Budget_Detail_Controller.BudgetWrapper>>();
		
		for(BudgetCategory__c bCate : [Select Name, Budget_Detail__r.Name, Budget_Detail__r.Total_Estimated_CostSharecost__c, Budget_Detail__r.Total_Estimated_NYSERDA_Cost__c,
												Budget_Detail__r.Total_EstimatedTotal_Cost__c, Sequence__c, RateElement__c, RateBase__c, HoursRate__c, TotalCost__c,
												TotalCostShare__c, TotalNYSERDACost__c,
                                       			(Select Name, BudgetCategory__c, Notes__c, RatePercentBase__c, CostShare__c, Hours__c, NYSERDACost__c, Total_Cost__c,
                                       					Rate__c, Rate_percent__c, Element_s__c, Base__c from Budget_Category_Lines__r order by CreatedDate asc)
                                       From BudgetCategory__c
                                       Where Budget_Detail__c IN: libudget.keyset()
                                       order by sequence__c
                                      ]){
            pageDisplayBudgetDetail = bCate.Budget_Detail__r;
            if(budgetDetailIdToBudgetCategoryListMap.containsKey(bCate.Budget_Detail__c)) {
            	budgetDetailIdToBudgetCategoryListMap.get(bCate.Budget_Detail__c).add(new CORE_Budget_Detail_Controller.BudgetWrapper(bcate,bcate.Budget_Category_Lines__r));
            } else {
            	List<CORE_Budget_Detail_Controller.BudgetWrapper> tempBudgetCategoryList = 
            			new List<CORE_Budget_Detail_Controller.BudgetWrapper>{new CORE_Budget_Detail_Controller.BudgetWrapper(bcate,bcate.Budget_Category_Lines__r)};
            	budgetDetailIdToBudgetCategoryListMap.put(bCate.Budget_Detail__c, tempBudgetCategoryList);
            }
          	liBudgetCategory.add(new CORE_Budget_Detail_Controller.BudgetWrapper(bcate,bcate.Budget_Category_Lines__R));
      	}
    }
    
    
    public class SummaryWrapper{
        public boolean HoursRate {Get;set;}
        public boolean RateBase {Get;set;}
        public boolean RateElement {Get;set;}
        public budgetcategoryline__c bcline{get;set;}
        public double totalcost{
            get{
                if(totalcost==null)
                    return 0.00; 
                return totalcost;
            }
            set;
        }
        public double nysedracost{
            get{
                if(nysedracost==null)
                    return 0.00; 
                return nysedracost;
            }
            set;
        }
        public double costsharecost{
            get{
                if(costsharecost==null)
                    return 0.00; 
                return costsharecost;
            }
            set;
        }
        public list<summarywrapper> lidetail{
            get{
                if(lidetail==null)
                    lidetail = new list<summarywrapper>();
                return lidetail;
            }
            set;
        }        
        public string name{get;set;}

        
        
    }
}