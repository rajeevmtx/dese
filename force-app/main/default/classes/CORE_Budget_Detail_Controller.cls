//
// Budget Detail Class
//
// June 19, 2016     Gaurav Sinha     original
public class CORE_Budget_Detail_Controller{

    //public List<BudgetCategory__c> liBudgetCategory{get;set;}
    public boolean iscontractor{get;set;}
    public String projectID{
        get{
            if(projectID==null){
                projectID = Apexpages.currentPage().getParameters().get('projectId');
            }
            return projectID;
        }
        private set;
    }
    public project__C project{
        get{
            if(project==null){
                project = [select id,name,Status__c  from project__C where id =: projectid];
            }
            return project;
        }
        private set;
    }
    public String profilerole{
        Get{
            if(profilerole==null){
                if(userinfo.getUserType()==CORE_Deliverables_Helper.USER_TYPE_STANDARD){
                    iscontractor = false;
                    for(project_role__c varloop:  [select role__c
                                                    from project_role__c 
                                                    where project__c = :projectid 
                                                    and User__c =: userinfo.getUserId()]){
                        profilerole = varLoop.role__c;
                    }
                        
                }else{
                    iscontractor = true;
                    String contactid = [select id,contactid 
                                            from user 
                                            where id=:userinfo.getUserId() 
                                            limit 1][0].contactid;
                    if(contactid!=null){
                        for(project_role__c varloop:  [select role__c
                                                        from project_role__c 
                                                        where project__c = :projectid 
                                                        and contact__c =: contactid]){
                            profilerole = varLoop.role__c;
                        }
                      
                    }
                }
            }
            return profilerole;
        }
    
        private set;
        
    }    
    public String headerName {get; set;}
    public boolean profileAccess{Get;set;}
    public boolean showNewVersion{get;set;}
    public integer rowCount{Get;set;}
    public boolean isEdit{get;set;}
    public boolean showApprovedButton{Get;set;}
    public BudgetDetail__c budgetDetail{get;set;}
    public list<BudgetWrapper> liBudgetCategory{get;set;}
    public boolean statusAccess{get;set;}
    
    public CORE_Budget_Detail_Controller(Apexpages.StandardController  cont){
        statusAccess = true;
        if(!test.isRunningTest())
            cont.addFields(new list<String>{'Name','BudgetSummary__c','Status__c','Active__c','StatusNotes__c','Version__c','BudgetIdentifier__c','Parent_Budget_Detail__c'});
        budgetDetail = (BudgetDetail__c) cont.getRecord();
        if(budgetDetail.Status__c == Clean_Transportation_Helper.CONST_BUDGET_DETAIL_APPROVED || 
            budgetDetail.Status__c ==CORE_Deliverables_Helper.CONST_BUDGET_STATUS_CANCELLED)
        {
            statusAccess = false;
        }
        isEdit = false;
        newRow = new BudgetCategoryLine__c();
/*        if(iscontractor && profileAccess && budgetDetail.Status__c ==CORE_Deliverables_Helper.Budget_DRAFT && (
                            project.status__c == CORE_Deliverables_Helper.PROJECT_Unsubmitted ||
                            project.status__c == CORE_Deliverables_Helper.Project_Approved ||
                            project.status__c == CORE_Deliverables_Helper.PROJECT_AWARDED) ){
            profileAccess = true;

        }else if (!iscontractor && profileAccess && (budgetDetail.Status__c ==CORE_Deliverables_Helper.Budget_DRAFT && 
                                    project.status__c == CORE_Deliverables_Helper.PROJECT_AWARDED) ||
                                    (budgetDetail.Status__c ==CORE_Deliverables_Helper.CONST_STATUS_Pending_Approval && 
                                    project.status__c == CORE_Deliverables_Helper.CONST_STATUS_Pending_Approval) || 
                                    (budgetDetail.Status__c ==CORE_Deliverables_Helper.Budget_DRAFT && 
                                    project.status__c == CORE_Deliverables_Helper.PROJECT_APPROVED) ||
                                    (budgetDetail.Status__c ==CORE_Deliverables_Helper.CONST_STATUS_Pending_Approval && 
                                    project.status__c == CORE_Deliverables_Helper.PROJECT_APPROVED) ) {
            profileAccess = true;
            
        }else{
            profileAccess = false;
        }*/
        checkMetdataforAccess();
        retreiveData();
    }
    public void checkMetdataforAccess(){
        String budgetstatus = budgetDetail.status__c ==Clean_Transportation_Helper.CONST_BUDGET_DETAIL_APPROVED && 
                            budgetDetail.Active__c ? 
                            CORE_Deliverables_Helper.CONST_APPROVEDACTIVE :
                            budgetDetail.status__c;
        profileAccess = false;
        showNewVersion = false;
		showApprovedButton = false;
		system.debug('-----------'+project.status__c);
		system.debug('-----------'+budgetstatus);
		system.debug('-----------'+profilerole);
        for(Budget_Security_Config__mdt varloop : [select create__c,update__c,approve__c
                                                    from Budget_Security_Config__mdt 
                                                    where project_Status__c =: project.status__c
                                                    and   budget_Status__c = : budgetstatus
                                                    and  role__c =: profilerole limit 1]){
            profileAccess = varLoop.update__c;
            showNewVersion = varloop.create__c;
			showApprovedButton = varloop.approve__c;
        }
        system.debug('-----------'+showApprovedButton);
        system.debug('-----------'+showNewVersion);
    }

    map<id,BudgetCategoryLine__c> mapCateegoryline{Get;set;}
    public string deleteItemID{Get;set;}
    //public BudgetSummary__c budgetSummary{get;set;}
    public BudgetCategoryLine__c newRow {Get;set;}
    Map<id,BudgetWrapper> newItemsmap{Get;set;}

    public BudgetDetail__c pageDisplayBudgetDetail{Get;set;}
    public void retreiveData(){
        integer count = [select count() 
                        from BudgetDetail__c 
                        where BudgetIdentifier__c = : budgetdetail.BudgetIdentifier__c
                        and status__c =: Clean_Transportation_Helper.CONST_BUDGET_DETAIL_DRAFT limit 1];
        if(showNewVersion)
            showNewVersion = count == 0;
        
        mapCateegoryline = new map<id,BudgetCategoryLine__c> ();
        newItemsmap = new Map<id,BudgetWrapper>();
        liBudgetCategory = new List<BudgetWrapper>();
        for(BudgetCategory__c bCate : [select id , Name , Budget_Detail__r.Total_Estimated_CostSharecost__c,Budget_Detail__r.Total_Estimated_NYSERDA_Cost__c,Budget_Detail__r.Total_EstimatedTotal_Cost__c,
                                        sequence__c,RateElement__c,RateBase__c,HoursRate__c,TotalCost__c,TotalCostShare__c,TotalNYSERDACost__c, Includes_fully_loaded_rate__c,
                                       (select Name  ,BudgetCategory__c,notes__c,RatePercentBase__c,Sequence__c,CostShare__c,Hours__c,NYSERDACost__c,Total_Cost__c,Rate__c,rate_percent__c,element_s__C,base__c
                                         from Budget_Category_Lines__R order by Sequence__c, createdDate asc
                                       )
                                       from BudgetCategory__c
                                       where budget_detail__c =: budgetDetail.id
                                       order by sequence__c
                                      ]){
                                          
            pageDisplayBudgetDetail = bCate.Budget_Detail__r;
                                          newItemsmap.put(bcate.id,new BudgetWrapper(bcate,bcate.Budget_Category_Lines__R));
                                          liBudgetCategory.add(new BudgetWrapper(bcate,bcate.Budget_Category_Lines__R));
                                          for(BudgetCategoryLine__c bcateLine : bCate.Budget_Category_Lines__R){
                                              
                                              mapCateegoryline.put(bcateLine.id,bcateLine);
                                          }
                                      }
        
    }

    public string masterID{Get;set;}
    public void updateCategoeyLine(){
        List<BudgetCategoryLine__c> tempListlineItem=  new List<BudgetCategoryLine__c>();
        List<BudgetCategory__c> budgetCategoryRecs = new  List<BudgetCategory__c>();
        for(BudgetWrapper bCate : liBudgetCategory){
            for(BudgetCategoryLine__c bcateLine : bCate.budgetcategoryline){
                if(bcateLine.name!=null){
                    System.debug('bcateLine==>'+bcateLine.name);
                    tempListlineItem.add(bcateLine);
                }
            }
            if(bCate.budgetdetail.Id != null) {
            	budgetCategoryRecs.add(new BudgetCategory__c(Id = bCate.budgetdetail.Id, 
            												 Includes_Fully_Loaded_Rate__c = bCate.budgetdetail.Includes_Fully_Loaded_Rate__c));
            }
        }

        if(!tempListlineItem.isEmpty()){
            upsert tempListlineItem;
        }
        if(budgetCategoryRecs.size() > 0) {
        	update budgetCategoryRecs;
        }
        
        if(budgetdetail != null && budgetdetail.Id <> null){
        	update budgetdetail;
        }
        
        if(budgetdetail.Status__c == Clean_Transportation_Helper.CONST_BUDGET_DETAIL_APPROVED)
        	approveBudget();
        
        //checkMetdataforAccess();
        changeMode();
        //getGlobalData();
    }
    
    public void approveBudget(){
        budgetdetail.Status__c = Clean_Transportation_Helper.CONST_BUDGET_DETAIL_APPROVED;
        budgetdetail.Active__c = true;   
        update budgetdetail;
        checkMetdataforAccess();
        retreiveData();
        //changeMode();
    }
    
    public void pendingReviewBudget(){
        budgetdetail.Status__c = Clean_Transportation_Helper.CONST_BUDGET_DETAIL_PENDING_APPROVAL;
        update budgetdetail;
        if(projectid != null) {
        	update (new Project__c(Id=projectid, Notifications_on_Approved_App_Hidden__c='Budget Pending Approval'));
        }
        checkMetdataforAccess();
        retreiveData();
    }
    

    public void changeMode(){
        isEdit = !isEdit;
        if(!isEdit)
            retreiveData();
    }
    public void initializeNewrow(){
        BudgetCategoryLine__c newRow = new BudgetCategoryLine__c(BudgetCategory__c = masterID);
        
        newItemsmap.get(masterid).budgetCategoryLine.add(newRow);
        liBudgetCategory = newItemsmap.values();

    }

    public void deleteItems(){
        if(String.isEmpty(deleteItemID) || deleteItemID.equalsIgnoreCase('null')){
            if(newItemsmap.get(masterid).budgetCategoryLine.size() >= rowCount)
            	newItemsmap.get(masterid).budgetCategoryLine.remove(rowCount-1);
        }
        else{
            if(deleteItemID != null){
                BudgetCategoryLine__c  deleteItem = new BudgetCategoryLine__c(id=deleteItemID);
                delete deleteItem;
            }
            retreiveData();
        }
    }
    public BudgetCategoryLine__c  editItem{Get;set;}
    public void updateNotesInitialize(){
     //   if(String.isEmpty(deleteItemID) || deleteItemID.equalsIgnoreCase('null')){
            integer count=1;
            System.debug(rowCount);
            for(BudgetCategoryLine__c varLoop: newItemsmap.get(masterid).budgetCategoryLine){
                if(rowCount==count){
                    editItem = varloop;
                    break;
                }
                count++;
            }
      //  }
       // else
         //   editItem = mapCateegoryline.get(deleteItemID);
    }

    public void updateNotes(){
        if(editItem.id==null)
            return;
        update editItem;
    }
    
    public Pagereference createVersion(){
        Savepoint sp = Database.setSavepoint();
        try{
        Utility_BudgetCloneTriggerDisable.setExecuteTrigger();
        System.debug(Utility_BudgetCloneTriggerDisable.executeTrigger);
        list<BudgetCategory__c> newBudgetCategoryList = new List<BudgetCategory__c>();
        map<String,list<BudgetCategoryLine__c>> mapBudgetCategoryLineList = new map<String,List<BudgetCategoryLine__c>>();

        Decimal versionNumber = [select id,version__c 
                                    from BudgetDetail__c 
                                    where BudgetIdentifier__c= :budgetdetail.BudgetIdentifier__c 
                                    order by version__c desc 
                                    limit 1][0].version__c;

        BudgetDetail__c budgetDetailClone = new BudgetDetail__c(name =budgetdetail.name,
                                            BudgetSummary__c=budgetdetail.BudgetSummary__c,
                                            Parent_Budget_Detail__c = budgetdetail.BudgetIdentifier__c,
                                            status__c=Clean_Transportation_Helper.CONST_BUDGET_DETAIL_DRAFT,
                                            version__c=versionNumber+1,
                                            BudgetIdentifier__c = budgetdetail.BudgetIdentifier__c);
        insert budgetDetailClone;
        System.debug(budgetDetailClone);
        List<BudgetCategoryLine__c> temp;
        for(BudgetCategory__c budgetCat : [select id,Budget_Detail__c,HoursRate__c,Name,RateBase__c,RateElement__c,Sequence__c, Includes_fully_loaded_rate__c,
                                        (SELECT Base__c,BudgetCategory__c,CostShare__c,
                                            Element_s__c,Hours__c,Id,total_cost__c,
                                            IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate, 
                                            Name,Notes__c,
                                            NYSERDACost__c,RatePercentBase__c,Rate_Percent__c,
                                            Rate__c
                                        FROM Budget_Category_Lines__r)
                                    FROM BudgetCategory__c
                                    where Budget_Detail__c = : budgetDetail.id
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
        

        String url= page.CORE_Budget_Detail_page.getUrl()+'?id='+budgetDetailClone.id+'&projectId='+projectId;
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
    public class BudgetWrapper{
        public BudgetCategory__c budgetdetail{Get;set;}
        public list<BudgetCategoryLine__c> budgetCategoryLine{get;set;}
        public integer widthSize{Get;set;}
        public BudgetWrapper(BudgetCategory__c budgetdetail,list<BudgetCategoryLine__c> budgetCategoryLine){
            this.budgetdetail = budgetdetail;
            this.budgetCategoryLine = budgetCategoryLine;
            this.widthSize = budgetdetail.RateBase__c || budgetdetail.HoursRate__c || budgetdetail.RateElement__c ? 30 : 60;
        }
    }
}