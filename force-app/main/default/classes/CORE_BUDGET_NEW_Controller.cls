//
// Budget New Class
//
// June 19, 2016     Gaurav Sinha     original
public class CORE_BUDGET_NEW_Controller {

    public id projectID{
        get{
            if(projectID==null){
                projectID = Apexpages.currentPage().getParameters().get('projectId');
            }
            return  projectID;
        }
        private set;
    }
    public id budgetSummaryID{
        get{
            if(budgetSummaryID==null){
                            for(BudgetSummary__c varloop: [select id from BudgetSummary__c where project__C = : projectid]){
                budgetSummaryID = varloop.id;
            }
            }
            return  budgetSummaryID;
        }
        private set;
    }
    public string budgetname{Get;set;}
    public string selectedBudget{get;set;}
    public List<SelectOption> soBudgetName{get{
        if(soBudgetName==null){
            soBudgetName = new List<SelectOption>();
            soBudgetName.add(new selectoption('','None'));
            if(budgetSummaryID!=null){
            for(BudgetDetail__c varLoop:[select id,name
                from BudgetDetail__c
                where active__c = true
                and BudgetSummary__c =: budgetSummaryID
                and status__c=:Clean_Transportation_Helper.CONST_BUDGET_DETAIL_APPROVED]){
                    soBudgetName.add(new selectoption(varloop.id,varLoop.name));
                }
            }
        }
        return soBudgetName;
    }
        private set;
    }
    public CORE_BUDGET_NEW_Controller(){

    }

    public pagereference CreateBudgetDetails(){
        String budgetDetailid;
        if(budgetname==null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,System.label.Clean_Transportation_Budget_Enter_Name);
            ApexPages.addMessage(myMsg);
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        try{
            if(budgetSummaryID==null){
        BudgetSummary__c budgetSummary;
        string ProjectName = [select application_number__c from project__c where id =:projectid].application_number__c;
        budgetSummary = new BudgetSummary__c(name = ProjectName,project__c =projectid);
        insert budgetSummary;
        budgetSummaryID = budgetSummary.id;
            }
        System.debug(selectedBudget);
        if(selectedBudget!=null){
           budgetDetailid =  createCloneBudget();
        }else{
            budgetDetailid =createNewBudget();
        }
        String url= page.CORE_Budget_Detail_page.getUrl()+'?id='+budgetDetailid+'&projectId='+projectId;
        Pagereference ref = new Pagereference(url);
        ref.setRedirect(true);
        System.debug(url);
        return ref;
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
    }

    private String createCloneBudget(){
        Utility_BudgetCloneTriggerDisable.setExecuteTrigger();
        System.debug(Utility_BudgetCloneTriggerDisable.executeTrigger);
        list<BudgetCategory__c> newBudgetCategoryList = new List<BudgetCategory__c>();
        map<String,list<BudgetCategoryLine__c>> mapBudgetCategoryLineList = new map<String,List<BudgetCategoryLine__c>>();
        BudgetDetail__c budgetDetailClone = new BudgetDetail__c(name =budgetName,BudgetSummary__c=budgetSummaryid,
                                            status__c=Clean_Transportation_Helper.CONST_BUDGET_DETAIL_DRAFT);
        insert budgetDetailClone;
        budgetDetailClone.BudgetIdentifier__c = budgetDetailClone.id;
        update budgetDetailClone;
        System.debug(budgetDetailClone);
        List<BudgetCategoryLine__c> temp;
        for(BudgetCategory__c budgetCat : [select id,Budget_Detail__c,HoursRate__c,Name,RateBase__c,RateElement__c,Sequence__c,
                                        (SELECT Base__c,BudgetCategory__c,CostShare__c,
                                            Element_s__c,Hours__c,Id,total_cost__c,
                                            IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,
                                            Name,Notes__c,
                                            NYSERDACost__c,RatePercentBase__c,Rate_Percent__c,
                                            Rate__c
                                        FROM Budget_Category_Lines__r)
                                    FROM BudgetCategory__c
                                    where Budget_Detail__c = : selectedBudget
                                    ]){
            System.debug(budgetCat);
            System.debug(budgetCat.Budget_Category_Lines__r);
            BudgetCategory__c newBudgetCategory = budgetCat.clone(false, true); //do a deep clone
            newBudgetCategory.Budget_Detail__c = budgetDetailClone.Id;
            newBudgetCategoryList.add(newBudgetCategory);
            temp = budgetCat.Budget_Category_Lines__r;
            if(temp!=null)
            mapBudgetCategoryLineList.put(newBudgetCategory.name,budgetCat.Budget_Category_Lines__r.deepClone(false, false));

        }

        //insert budgetCatefgory
        insert newBudgetCategoryList;
        System.debug(mapBudgetCategoryLineList);
        System.debug(newBudgetCategoryList);
        map<String,string> mapnameToid = new map<String,string>();
        for(BudgetCategory__c varloop : newBudgetCategoryList){
            mapnameToid.put(varloop.name,varloop.id);
        }
        list<BudgetCategoryLine__c> newBudgetCategorylineList= new list<BudgetCategoryLine__c>();

        for(String budgetCat :mapBudgetCategoryLineList.keySet()){
            for(BudgetCategoryLine__c varLoop : mapBudgetCategoryLineList.get(budgetCat)){
                varLoop.BudgetCategory__c = mapnameToid.get(budgetCat);
                newBudgetCategorylineList.add(varloop);
            }
        }

        insert newBudgetCategorylineList;
        System.debug(newBudgetCategorylineList);
        budgetDetailClone.BudgetIdentifier__c = budgetDetailClone.id;
        update budgetDetailClone;
        return budgetDetailClone.id;
    }

    private string createNewBudget(){

        BudgetDetail__c insertBudget;
        if(String.isEmpty(selectedBudget)){
             insertBudget= new BudgetDetail__c(name=budgetname,BudgetSummary__c = budgetSummaryID,
                                                status__c=Clean_Transportation_Helper.CONST_BUDGET_DETAIL_DRAFT);
        }
        insert insertBudget;
        insertBudget.BudgetIdentifier__c = insertBudget.id;
        update insertBudget;
        return insertBudget.id;
    }


}