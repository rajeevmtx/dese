/*
* Class Name:  ProjectInvoiceLine_TriggerHandler
* Description: TriggerHandler for ProjectInvoiceLine_Trigger
*                                                            
*/
public class ProjectInvoiceLine_TriggerHandler {
    
    private static final Set<String> setOfInvoiceStatusToIgnore = new Set<String>{'Draft', 'Rejected'};
    
      /*
          * Method Name: onAfterInsert
          * Description: Method to call the processing after Insert
          * @return:  void
          * @param: Map<Id,Project_Invoice_Line__c> : Map of project Invoice Line
          */
    public static void onAfterInsert(Map<Id,Project_Invoice_Line__c> invoiceLineItemMap){   
        //checkTotalAmountOnProjectInvoice(invoiceLineItemMap);
    }
     /*
     * Method Name: onAfterUpdate
     * Description: Method to call the processing after Update     
     * @return:  void
     * @param: Map<Id,Project_Invoice_Line__c> invoiceLineItemMap,  Map<Id,Project_Invoice_Line__c> oldMap
     */
    public static void onAfterUpdate(Map<Id,Project_Invoice_Line__c> invoiceLineItemMap,  Map<Id,Project_Invoice_Line__c> oldMap){
        //checkTotalAmountOnProjectInvoice(invoiceLineItemMap,oldMap);
    }
     /*
     * Method Name: onBeforeUpdate
     * Description: Method to call the processing before Update
     * @return:  void
     * @param: Map<Id,Project_Invoice_Line__c> invoiceLineItemMap,  Map<Id,Project_Invoice_Line__c> oldMap
     */
    public static void onBeforeUpdate(Map<Id,Project_Invoice_Line__c> invoiceLineItemMap,  Map<Id,Project_Invoice_Line__c> oldMap){
        checkMilestoneAmount(invoiceLineItemMap.values());
    }
     /*
     * Method Name: onBeforeInsert
     * Description: Method to call the processing before Insert
     * @return:  void
     * @param: List<Project_Invoice_Line__c> : List of project Invoice Line
     */
    public static void onBeforeInsert(List<Project_Invoice_Line__c> invoiceLineItems){
        checkMilestoneAmount(invoiceLineItems);
    }
    
    /* Commented as Calling method also commented
    private static void checkTotalAmountOnProjectInvoice(Map<Id,Project_Invoice_Line__c> invoiceLineItemMap, Map<Id,Project_Invoice_Line__c> oldMap){
        Map<Id,List<Project_Invoice_Line__c>> projectInvoiceMap  = prepareProjectIds(invoiceLineItemMap.values());
        Map<Id,List<Project_Invoice__c>>  projectIdInvoiceMap = getProjectIds(projectInvoiceMap.keySet());
        Set<Id> projectIds = projectIdInvoiceMap.keyset();
        Set<Id> excessiveAmountInvoiceIds = new Set<Id>();
        //fetch all projects and project invoices related to that project 
        if(projectIds.size()>0){
            for(Project__c project : [Select id, Total_NYSERDA_Incentive_Amount__c, (Select id,Total_Amount_Due__c from Project_Invoices__r where status__c NOT IN ('Draft','Rejected')) from Project__c where ID IN : projectIdInvoiceMap.keySet()]){
                Decimal totalAmountOnProjectInvoices = 0 ;
                Set<Id> localInvoiceIds = new Set<Id>();
                List<Project_Invoice__c> projectInvoices = project.Project_Invoices__r;                
                if(projectIdInvoiceMap.containsKey(project.Id))projectInvoices.addAll(projectIdInvoiceMap.get(project.Id)); 
                for(Project_Invoice__c projectInvoice: projectInvoices){                     
                    // sum of all project inoices available on project
                    totalAmountOnProjectInvoices += projectInvoice.Total_Amount_Due__c !=null ? projectInvoice.Total_Amount_Due__c : 0; 
                    // check if invoice was part of this transaction  
                    if(projectInvoiceMap.containsKey(projectInvoice.id)) {
                        localInvoiceIds.add(projectInvoice.id);
                        for(Project_Invoice_Line__c projectInvoiceLine : projectInvoiceMap.get(projectInvoice.id)){                            
                            totalAmountOnProjectInvoices = totalAmountOnProjectInvoices - oldMap.get(projectInvoiceLine.Id).Amount__c + projectInvoiceLine.Amount__c ;
                        }
                    }        
                    // check if total on project invoice is greater than project amount
                    if(totalAmountOnProjectInvoices >  project.Total_NYSERDA_Incentive_Amount__c)
                        // add all project invoice to set which are part of current transcation only
                        excessiveAmountInvoiceIds.addAll(localInvoiceIds);
                }                
            }
            if(excessiveAmountInvoiceIds.size()>0)
                showErrorOnRecords (excessiveAmountInvoiceIds,projectInvoiceMap);
        }
    }
    */
    
    /*
    //called after insert
    private static void checkTotalAmountOnProjectInvoice(Map<Id,Project_Invoice_Line__c> invoiceLineItemMap){
        Map<Id,List<Project_Invoice_Line__c>> projectInvoiceMap  = prepareProjectIds(invoiceLineItemMap.values());
        Map<Id,List<Project_Invoice__c>>  projectIdInvoiceMap = getProjectIds(projectInvoiceMap.keySet());
        Set<Id> projectIds = projectIdInvoiceMap.keyset();
        Set<Id> excessiveAmountInvoiceIds = new Set<Id>();
        //fetch all projects and project invoices related to that project 
        if(projectIds.size()>0){
            for(Project__c project : [Select id, Total_NYSERDA_Incentive_Amount__c, (Select id,Total_Amount_Due__c from Project_Invoices__r where status__c NOT IN ('Draft','Rejected')) from Project__c where ID IN : projectIdInvoiceMap.keySet()]){
                Decimal totalAmountOnProjectInvoices = 0 ;
                Set<Id> localInvoiceIds = new Set<Id>();                
                List<Project_Invoice__c> projectInvoices = project.Project_Invoices__r;                
                if(projectIdInvoiceMap.containsKey(project.Id))projectInvoices.addAll(projectIdInvoiceMap.get(project.Id));
                for(Project_Invoice__c projectInvoice: projectInvoices){                                      
                    // sum of all project inoices available on project
                    totalAmountOnProjectInvoices += projectInvoice.Total_Amount_Due__c !=null ? projectInvoice.Total_Amount_Due__c : 0; 
                    // check if invoice was part of this transaction   
                    if(projectInvoiceMap.containsKey(projectInvoice.id)) {
                        localInvoiceIds.add(projectInvoice.id);
                        for(Project_Invoice_Line__c projectInvoiceLine : projectInvoiceMap.get(projectInvoice.id)){  
                            totalAmountOnProjectInvoices = totalAmountOnProjectInvoices + projectInvoiceLine.Amount__c ;
                        }
                    }
                    // check if total on project invoice is greater than project amount
                    if(totalAmountOnProjectInvoices > project.Total_NYSERDA_Incentive_Amount__c)
                        // add all project invoice to set which are part of current transcation only
                        excessiveAmountInvoiceIds.addAll(localInvoiceIds);                                        
                }                
            }
            if(excessiveAmountInvoiceIds.size()>0)
                showErrorOnRecords (excessiveAmountInvoiceIds,projectInvoiceMap);
        }
    }
    */
    
    /*
     * Method Name: checkMilestoneAmount
     * Description: Method to check Milestone Amount
     * @return:  void
     * @param: List<Project_Invoice_Line__c> : List of project Invoice Line
     */
     
    private static void checkMilestoneAmount(List<Project_Invoice_Line__c> invoiceLines){
        Map<Id,Project_Invoice_Line__c> milestoneInvoiceMap = new Map<Id,Project_Invoice_Line__c>();
        List<Project_Milestones__c> listOfMilestones = new List<Project_Milestones__c>();
        Set<Id> invoiceIds = new Set<Id>();
        Map<Id, String> invoiceToStatusMap = new Map<Id, String>();
        
        for(Project_Invoice_Line__c invoiceLine : invoiceLines ){
            milestoneInvoiceMap.put(invoiceLine.Milestone__c, invoiceLine);
            invoiceIds.add(invoiceLine.Invoice__c);
        }
        
        for(Project_Invoice__c invoice : [SELECT Id, Status__c FROM Project_Invoice__c WHERE ID In:invoiceIds]) {
            invoiceToStatusMap.put(invoice.Id, invoice.Status__c);
        }
        
        Map<Id, Decimal> childMilestoneTotalMap = new Map<Id, Decimal>();
        Map<Id, Decimal> parentMilestoneRemainingBudgetMap = new Map<Id, Decimal>();
        Map<Id, Id> childParentMilestoneIdMap = new Map<Id, Id>();
        
        for(Project_Milestones__c milestone : [Select id, Project__r.Id, Project__r.RecordType.Name, 
                                               Incentive_Amount__c, Type__c, RecordTypeId, Remaining_Budget__c,
                                               Quantity__c, Parent__c, Parent__r.Enable_Task_Limit__c,
                                               Parent__r.Remaining_Budget__c
                                               from Project_Milestones__c 
                                                where Id IN : milestoneInvoiceMap.keySet()]){
            
            if(milestone.project__r.RecordType.Name == 'NY Sun - Residential/Small Commercial'){
                if(milestone.Incentive_Amount__c!=null && milestoneInvoiceMap.get(milestone.Id).Amount__c!=null &&  (milestone.Incentive_Amount__c).round(System.RoundingMode.HALF_UP) < milestoneInvoiceMap.get(milestone.Id).Amount__c){
                    milestoneInvoiceMap.get(milestone.Id).addError('Amount cant be greater than parent milestone amount.');
                }
            }else if(milestone.project__r.RecordType.Name == 'NY Sun - Commercial/Industrial' && milestone.Type__c == 'Yearly Performance Payment' && milestoneInvoiceMap.get(milestone.Id).Amount__c != null){
                //Skipping the amount check 
            }else if(invoiceToStatusMap.get(milestoneInvoiceMap.get(milestone.Id).Invoice__c) == 'Draft') {
                if(milestone.Quantity__c != 'No Limit' &&
                   milestone.Remaining_Budget__c != null && milestoneInvoiceMap.get(milestone.Id).Amount__c != null 
                    && milestone.Remaining_Budget__c.setScale(2) < milestoneInvoiceMap.get(milestone.Id).Amount__c.setScale(2)){
                        milestoneInvoiceMap.get(milestone.Id).addError('Amount can not be greater than parent milestone amount.');
                }else if(milestone.Quantity__c == 'No Limit' && milestone.Parent__c != null &&
                         milestone.Parent__r.Enable_Task_Limit__c){
                    
                    if(!childMilestoneTotalMap.containsKey(milestone.Parent__c)){
                        childMilestoneTotalMap.put(milestone.Parent__c, 0);
                    }
                    
                    if(milestoneInvoiceMap.get(milestone.Id).Amount__c != null){
                        childMilestoneTotalMap.put(milestone.Parent__c, childMilestoneTotalMap.get(milestone.Parent__c) + milestoneInvoiceMap.get(milestone.Id).Amount__c);
                    }
                    
                    if(!parentMilestoneRemainingBudgetMap.containsKey(milestone.Parent__c)){
                        parentMilestoneRemainingBudgetMap.put(milestone.Parent__c, milestone.Parent__r.Remaining_Budget__c);
                    }
                    
                    childParentMilestoneIdMap.put(milestone.Id, milestone.Parent__c);
                }
            }
        }
        
        if(childMilestoneTotalMap.size() > 0){
            for(Project_Invoice_Line__c invoiceLine : invoiceLines ){
                if(childParentMilestoneIdMap.containsKey(invoiceLine.Milestone__c) &&
                   childParentMilestoneIdMap.get(invoiceLine.Milestone__c) != null &&
                   childMilestoneTotalMap.containsKey(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) &&
                   childMilestoneTotalMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) != null &&
                   parentMilestoneRemainingBudgetMap.containsKey(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) &&
                   parentMilestoneRemainingBudgetMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) != null &&
                   parentMilestoneRemainingBudgetMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)).setScale(2) < 
                          childMilestoneTotalMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)).setScale(2)){
                    
                    invoiceLine.addError('Amount can not be greater than parent milestone amount.');
                }
            }
        }
    }
    
    /* Commented as Calling method also commented
    private static Map<Id,List<Project_Invoice_Line__c>> prepareProjectIds(List<Project_Invoice_Line__c> invoiceLineItems){
        Map<Id,List<Project_Invoice_Line__c>> projectInvoiceMap = new Map<Id,List<Project_Invoice_Line__c>> ();
        // fetch all project invoice ids
        for(Project_Invoice_Line__c invoiceLineItem : invoiceLineItems ){
            if(projectInvoiceMap.containsKey(invoiceLineItem.Invoice__c)) projectInvoiceMap.get(invoiceLineItem.Invoice__c).add(invoiceLineItem);
            else projectInvoiceMap.put(invoiceLineItem.Invoice__c, new List<Project_Invoice_Line__c>{invoiceLineItem});
        }
        return projectInvoiceMap;
    }
    
    private static Map<Id,List<Project_Invoice__c>>  getProjectIds(Set<Id> projectInvoiceIds ){
        Map<Id,List<Project_Invoice__c>> projectInvoiceIdMap = new Map<Id,List<Project_Invoice__c>>();
        //fetech all project ids so that all inovice which are related to project and not part of this transaction can be considered for total amount //AND Status__c='Draft'
        for(Project_Invoice__c projectInvoice : [Select id, Project__c, Total_Amount_Due__c from Project_Invoice__c where ID IN : projectInvoiceIds]){
            if(projectInvoiceIdMap.containsKey(projectInvoice.Project__c))projectInvoiceIdMap.get(projectInvoice.Project__c).add(projectInvoice);
            else projectInvoiceIdMap.put(projectInvoice.Project__c, new List<Project_Invoice__c>{projectInvoice});
        }
        return projectInvoiceIdMap;
    }
     
 
    private static void showErrorOnRecords( Set<Id> excessiveAmountInvoiceIds,Map<Id,List<Project_Invoice_Line__c>> projectInvoiceMap){
        //iterate through all project invoice ids which having excessive amount and show error message on there line items
        for(Id key : excessiveAmountInvoiceIds){
            if(projectInvoiceMap.containsKey(key)){
                for(Project_Invoice_Line__c projectInvoiceLine : projectInvoiceMap.get(key)){
                    // add error message to inovice line item
                    projectInvoiceLine.addError('Invoice amount cant be greater than total amount for Project');
                }
            }
        }
    }
    */
}