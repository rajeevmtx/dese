//
// Budget Left Naviagtion Class
//
// June 19, 2016     Gaurav Sinha     original
public class CORE_Budget_Left_Navigation_Controller {
    public String projectID{
        get{
            if(projectID==null){
                projectID = Apexpages.currentPage().getParameters().get('projectId');
            }
            return projectID;
        }
        private set;
    }
    
    public project__c project{
        get{
            if(project==null){
                
                for(project__C varloop: [select id,status__c 
                                         from project__c 
                                         where id=:projectid]){
                                             project = varloop;
                                         }
            }
            return project;
        }
        private set;
    }
    public String profilerole{
        Get{
            if(profilerole==null){
                if(userinfo.getUserType()==CORE_Deliverables_Helper.USER_TYPE_STANDARD){
                    for(project_role__c varloop:  [select role__c
                                                   from project_role__c 
                                                   where project__c = :projectid 
                                                   and User__c =: userinfo.getUserId()]){
                                                       profilerole = varLoop.role__c;
                                                   }
                    
                }else{

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
    public boolean profileAccess{Get;set;}
    public Boolean showDeleteLink {get; set;}
    public map<id,List<BudgetDetail__c>> mapBudgetDetail{get;set;}
    public map<id,BudgetDetail__c> activeVersion{get;set;}
    public transient BudgetSummary__c budgetSummary{get;set;}
    public Id itemToDelId {get; set;}
    
    public CORE_Budget_Left_Navigation_Controller(){
        getGlobalData();
        checkMetdataforAccess();
    }
    
    public void checkMetdataforAccess(){
        
        profileAccess = false;
        
        for(Budget_Security_Config__mdt varloop : [select create__c,update__c,delete__c
                                                   from Budget_Security_Config__mdt 
                                                   where project_Status__c =: project.status__c
                                                   and budget_Status__c = null 
                                                   and  role__c =: profilerole limit 1]) { 
		   showDeleteLink = varloop.delete__c;                                         	
           profileAccess = varloop.create__c;
       }
    }
    public Map<Id, Boolean> activeVersionToDeletableMap {get; set;}
    
    public void getGlobalData(){
        
        mapBudgetDetail = new map<id,List<BudgetDetail__c>>();
        activeVersion = new map<id,BudgetDetail__c> ();
        for(BudgetSummary__c varLoop : [SELECT id,name,project__r.name,
                                        (SELECT id,name,Active__c ,status__c,version__c,BudgetIdentifier__c FROM Budget_Details__r  order by createdDate desc
                                        )
                                        FROM 
                                        BudgetSummary__c 
                                        where project__c = : projectid
                                        limit 1]){
                                            budgetSummary = varLoop;
                                            for(BudgetDetail__c bdloop : varLoop.Budget_Details__r){
                                                // if(bdloop.active__c ==true && bdloop.status__c == Clean_Transportation_Helper.CONST_BUDGET_DETAIL_APPROVED){
                                                activeVersion.put(bdloop.BudgetIdentifier__c,bdloop);
                                                //    }
                                                if(mapBudgetDetail.get(bdloop.BudgetIdentifier__c)==null || bdloop.BudgetIdentifier__c==null){
                                                    mapBudgetDetail.put(bdloop.BudgetIdentifier__c,new List<BudgetDetail__c>{bdloop});
                                                }else{
                                                    mapBudgetDetail.get(bdloop.BudgetIdentifier__c).add(bdloop);
                                                }
                                                //mapBudgetDetail.put(bdloop.id,newList<bdloop);
                                                
                                            }
                                        }
        
        
        activeVersionToDeletableMap = new Map<Id, Boolean>();
        for(Id activeVersionId : activeVersion.keySet()) {
        	Boolean isActiveAppovedPresent = false;
    		for(BudgetDetail__c budgetDetailRec : mapBudgetDetail.get(activeVersionId)) {
    			if(budgetDetailRec.status__c == 'Approved' && budgetDetailRec.active__c) {
    				isActiveAppovedPresent = true;
    				break;
    			}
    		}
        	activeVersionToDeletableMap.put(activeVersionId, isActiveAppovedPresent);
        }
        
    }
    
    public PageReference deleteBudget() {
    	List<BudgetDetail__c> budgetDetailsToDelList = new List<BudgetDetail__c>();
    	Set<Id> deleteIdSet = new Set<Id>();
    	budgetDetailsToDelList.add(new BudgetDetail__c(Id = itemToDelId));
    	deleteIdSet.add(itemToDelId);
    	if(mapBudgetDetail.containsKey(itemToDelId)) {
    		for(BudgetDetail__c budgetRec : mapBudgetDetail.get(itemToDelId)) {
    			if(!deleteIdSet.contains(budgetRec.Id)) {
    				budgetDetailsToDelList.add(new BudgetDetail__c(Id = budgetRec.Id));
    				deleteIdSet.add(budgetRec.Id);
    			}
    		}
    	}
    	
    	if(budgetDetailsToDelList.size() > 0) {
    		delete budgetDetailsToDelList;
    	}
    	PageReference pg = new PageReference('/apex/CORE_Budget_Summary_page?projectId=' + projectID);
    	return pg;
    }
}