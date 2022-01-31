/*
*   Class Name: CT_Invoice_Extension
*   Description: extension class for CT_Invoice page
*
*   Author/Date: Manish Kumar / June 30, 2016
*
*/
public class CT_Invoice_Extension {

  // Varibales used in calcualtion
    private String description;
    private String flowSource;
    private Boolean isPartOfFlow;
    private ID milestoneRecordtypeId;
    private ID invoiceId;

    public map<Id,Project_Purchase_Order__c> poIdToPoMap;

  // Constant string error message used to show on Page
    private static final String DESC_IDENTIFIER_BUDGET_INVOICE = 'BUDGET INVOICE LINE';
    private static final String INVOICE_PAGE = 'CT_Invoice_Page';
    private static final String DOCUMENT_PAGE = 'CT_Invoice_Documents_Page';
    private static final String MISSING_DOC_MESSAGE = 'Please upload the required documents.';
    private static final String ERR_MSG_EXCESS_AMOUNT = 'No amount left for invoice.';
    private static final String ERR_MSG_BUDGET_EXCESS_AMOUNT = 'Your invoice amount does not match the amount from the previous step.';
    private static final String ERR_MSG_PENDING_APPROVAL = 'Your project does not allow multiple unapproved invoices.';
    private static final String ERR_MSG_NO_MORE_INVOICE = 'No more invoicing allowed for this Project.';

  // Different properties used on VF page
    public Map<Id, Project_Milestones__c> mapOfIdAndMilestone {get; set;}
    public List<Project_Invoice_Line_To_Classifications__c> selectedClassifications{get; set;}
    public Integer selectedClassificationIndex{get; set;}
    public String selectedInvoiceLine{get; set;}
    public boolean isSaved{get; set;}
    public boolean isError{get; set;}
    public boolean isDirectLaborIncluded{get; set;}
    public Integer index {get; set;}
    public Project_Invoice__c invoice {get; set;}
    public User currentUser{
        get{
            return Utility_User_Helper.currentLoggedInUser;
        }
        set;
    }
    public Id selectedDeliverabeldId {get; set;}
    public String projectName {get; set;}

    public Boolean hideEditButtons {get;set;}
    public Boolean isCurrentUserPM {get; set;}
    public Boolean isCurrentUserPEC {get;set;}
    public Boolean isReadOnlyMode{get; set;}
    public Boolean isBudgetView {get; set;}
    public Boolean isInvoicingAllowed {get; set;}
    public Boolean isFirstInvoice {get; set;}
    public Boolean isNew {get; set;}
    public Boolean isEdit{get; set;}
    public Decimal invAmount {get; set;}
    public String pageErrorMessage {get; set;}

    public Decimal amountFromInvoicesApprovedAndAfterStatuses {get;set;} //   I-03864

    public String mstTypeIncentive { get { return ProjectMilestones_Helper.MILESTONE_TYPE_NYSERDA_INCENTIVE; } }
    //public Boolean isLocked { get{ return invoice.Status__c != ProjectInvoice_Helper.STATUS_DRAFT;} private set; }
    public Boolean isLocked { get; private set; }
    public Project__c project{get;set;}

    public String projectRType {get; set;}
    public List<MilestoneWrapper> listOfMilestones {get; set;}

    public List<Project_Document__c> listOfDocuments {get; set;}

    public Map<Id, Project_Document__c> mapOfIdAndProjDoc {get; set;}

    public Boolean approvAllDoc {get; set;}
    public Boolean isPortalUser {get; set;}
    public Boolean isEditMode {get; set;}
    public Boolean isAllDeliverablesApproved {get; set;}
    public Boolean isRejectedDocumentPresent {get; set;}
    public String invoiceStatus{get; set;}

    public List<OtherDocument> otherDocumentList {get; set;}
    public Integer rowNumber{get; set;}
    public List<SelectOption> purchaseOrderList {get;set;}
    public Boolean isApprovedPOExist {get; set;}
    public Decimal nyserdaIncentiveAmount {get; set;}
    public Decimal costIncentiveAmount {get; set;}

    //public Boolean isDelinquentAccount {get; set;} //T-02786

    public String neisContractId{get; set;}

    public String supportedFileType{
        get {
            String supportedFileType = '';
            if(Documents_File_Extensions__c.getAll() != null){
                for(String fileType : Documents_File_Extensions__c.getAll().keySet()){
                    if(supportedFileType != '') {
                        supportedFileType += ', ';
                    }
                    supportedFileType += fileType;
                }
            }
            return supportedFileType;
        }
    }

    // Constructor
    public CT_Invoice_Extension(ApexPages.StandardController ctrl){
        isLocked = false;
        hideEditButtons = false;
        amountFromInvoicesApprovedAndAfterStatuses = 0;
        poIdToPoMap = new map<Id,Project_Purchase_Order__c>();

        // get VF page URL parameters
        flowSource = Apexpages.currentPage().getParameters().get('flow');
        isPartOfFlow = flowSource != null && flowSource != '';

        // Initialize variables used in logic
        milestoneRecordtypeId = ProjectMilestones_Helper.ParentMilestoneRecordType.Id;
        isInvoicingAllowed = true;
        listOfMilestones = new List<MilestoneWrapper>();
        selectedClassifications = new List<Project_Invoice_Line_To_Classifications__c>();
        isSaved = false;
        isError = false;
        isPortalUser = currentUser.IsPortalEnabled;
        isEditMode = false;
        approvAllDoc = false;
        isFirstInvoice = true;
        nyserdaIncentiveAmount = 0;
        costIncentiveAmount = 0;
        isCurrentUserPM = false;
        isCurrentUserPEC = false;
        isDirectLaborIncluded = false;
        String projectRoleValue_Invoice = ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE;

        // If invoice Id is not null, then fetch current invoice reocrd else create instance of Invoice Record based on values
        if(ctrl.getId() == null){
            isNew = true;
            invoice = new Project_Invoice__c(Status__c = ProjectInvoice_Helper.STATUS_DRAFT);
            String pId = getParentId('Project__c');
            if(String.isNotBlank(pId)){
                fetchProject(pId);
                invoice = fetchInvoiceValues(invoice, pId,projectRoleValue_Invoice);
            }
        }else{
            isNew = false;
            isEdit = false;

            // Invoice Record Id
            invoiceId = ctrl.getId();
            fetchInvoice();

            isLocked = (invoice != null && (invoice.Status__c != ProjectInvoice_Helper.STATUS_DRAFT));

            fetchProject(invoice.Project__c);
            fetchDocuments();
            Set<Id> setOfMilestoneId = new Set<Id>();
            for(Project_Invoice_Line__c invLine : invoice.Project_Invoice_Lines__r){
                setOfMilestoneId.add(invLine.Milestone__c);
            }
            fetchDeliverables();
        }

        if(project.Budget_Type__c == 'T&M'){
            isBudgetView = true;
            fetchBudgetingData();

            for(BudgetCategory__c budgetCat : listOfBudgetCategory){
                if(budgetCat.Budget_Category_Lines__r != null && budgetCat.Budget_Category_Lines__r.size() > 0){
                    for(BudgetCategoryLine__c catLine : budgetCat.Budget_Category_Lines__r){
                        if(mapOfBudgetLineIdAndMilestones.containsKey(catLine.Id) &&
                           mapOfBudgetLineIdAndMilestones.get(catLine.Id).projectInvoiceLine.invoiceLineItem.Amount__c != null){

                            nyserdaIncentiveAmount += mapOfBudgetLineIdAndMilestones.get(catLine.Id).projectInvoiceLine.invoiceLineItem.Amount__c;
                        }

                        if(mapOfBudgetLineIdAndMilestones.containsKey(catLine.Id) &&
                           mapOfBudgetLineIdAndMilestones.get(catLine.Id).projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c != null){

                            costIncentiveAmount += mapOfBudgetLineIdAndMilestones.get(catLine.Id).projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c;
                        }

                    }
                }
            }
        }

       // fetchPurchaseOrderList();

        String isBudgetViewFlag = Apexpages.currentPage().getParameters().get('isBudgetView');

        if(isBudgetViewFlag != null && isBudgetViewFlag != '' && isBudgetViewFlag == 'false'){
            isBudgetView = false;
        }

        if(purchaseOrderList != null && purchaseOrderList.size() == 2){
            invoice.Project_Purchase_Order__c = purchaseOrderList.get(1).getValue();
        }

    // Fetch Project funding record
        getProjectFunding();

        neisContractId ='';

        if(project.Id <> null){
            for(Project_Contract__c contract : [SELECT NEIS_Contract_ID__c FROM Project_Contract__c
                                                WHERE Project__c =: project.Id
                                                ORDER BY CreatedDate DESC LIMIT 1]){
                neisContractId = contract.NEIS_Contract_ID__c;
            }


            for(Project_Role__c tempRole : [SELECT Id FROM Project_Role__c
                                            WHERE Role__c =: ProjectRole_Helper.PROJECT_MANAGER_ROLE
                                            AND Project__c =: project.Id
                                            AND User__c =: UserInfo.getUserId()]){
                isCurrentUserPM = true;
            }
        }
    }

    /*
    * Method Name: fetchCostShareClassification
    * Description: Purpose to fetch cost share classification
    * @param: none
    * @return void
    */
    public void fetchCostShareClassification(){

      // Initialize variables used in logic
        isSaved = false;
        isError = false;

        selectedClassifications = new List<Project_Invoice_Line_To_Classifications__c>();

    // Fetch Project Cost share Classification detail
        for(Project_Cost_Share_Classification__c temp : [SELECT Id, Name,

                                                         (SELECT Id, Actual_Cash_Amount__c, Actual_In_Kind_Amount__c, Actual_Total__c,
                                                          Name, Project_Invoice_Line__c, Classifications__c
                                                          FROM Project_Invoice_Line_To_Classifications__r
                                                          WHERE Project_Invoice_Line__c =: selectedInvoiceLine)

                                                         FROM Project_Cost_Share_Classification__c
                                                         WHERE Project__c =: project.Id
                                                         ORDER BY CreatedDate]){

            if(temp.Project_Invoice_Line_To_Classifications__r != null &&
               temp.Project_Invoice_Line_To_Classifications__r.size() > 0){

                selectedClassifications.addAll(temp.Project_Invoice_Line_To_Classifications__r);
            }else{
                selectedClassifications.add(new Project_Invoice_Line_To_Classifications__c(Name = temp.Name,
                                                Project_Invoice_Line__c = selectedInvoiceLine,
                                                Classifications__c = temp.Id));
            }
        }
    }

    /*
    * Method Name: addNewClassification
    * Description: Purpose to add new classification
    * @param: N/A
    * @return void
    */
    public void addNewClassification(){
        selectedClassifications.add(new Project_Invoice_Line_To_Classifications__c(
                                                Project_Invoice_Line__c = selectedInvoiceLine));
    }

    /*
    * Method Name: removeClassification
    * Description: Purpose to remove classification
    * @param: N/A
    * @return void
    */
    public void removeClassification(){

        if(selectedClassifications.size() > selectedClassificationIndex){
            Project_Invoice_Line_To_Classifications__c tempClassification = selectedClassifications.get(selectedClassificationIndex);

            if(tempClassification.Id <> null){
                delete tempClassification;
            }

            selectedClassifications.remove(selectedClassificationIndex);
        }
    }

    /*
    * Method Name: saveCostSharingClassification
    * Description: Purpose to save cost sharing classification
    * @param: none
    * @return Pagereference
    */
    public Pagereference saveCostSharingClassification(){
        if(selectedClassifications.size() > 0){

            Decimal totalLineItemCostShare = 0;

      // Logic to set total line item cost share
            for(MilestoneWrapper tempMilestone : listOfMilestones){
                if(tempMilestone.projectInvoiceLine != null &&
                       tempMilestone.projectInvoiceLine.invoiceLineItem != null &&
                       tempMilestone.projectInvoiceLine.invoiceLineItem.Id == selectedInvoiceLine &&
                       tempMilestone.projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c != null){

                        totalLineItemCostShare += tempMilestone.projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c;
                }
            }

            Decimal totalCostShare = 0;

            for(Project_Invoice_Line_To_Classifications__c temp : selectedClassifications){

                totalCostShare += (temp.Actual_Total__c != null ? temp.Actual_Total__c : 0);
            }

            if(totalLineItemCostShare != totalCostShare){
                isSaved = false;
                isError = true;
                return null;
            }

      // Initialize variables used in logic
            List<Project_Cost_Share_Classification__c> classificationsToInsert =
                                                        new List<Project_Cost_Share_Classification__c>();

            List<Project_Invoice_Line_To_Classifications__c> invoiceLineToClassificationToInsert =
                                                             new List<Project_Invoice_Line_To_Classifications__c>();

            List<Project_Invoice_Line_To_Classifications__c> invoiceLineToClassificationToUpdate =
                                                             new List<Project_Invoice_Line_To_Classifications__c>();

            for(Project_Invoice_Line_To_Classifications__c temp : selectedClassifications){

                if(temp.Classifications__c != null){
                    invoiceLineToClassificationToUpdate.add(temp);
                }else{
                    invoiceLineToClassificationToInsert.add(temp);
                    classificationsToInsert.add(new Project_Cost_Share_Classification__c(Name = temp.Name,
                                                 Project__c = project.Id));
                }
            }

      // Insert or update list
            if(classificationsToInsert.size() > 0 && invoiceLineToClassificationToInsert.size() > 0){
                insert classificationsToInsert;

                for(Integer i=0; i<invoiceLineToClassificationToInsert.size(); i++){
                    invoiceLineToClassificationToInsert[i].Classifications__c = classificationsToInsert[i].Id;
                }

                insert invoiceLineToClassificationToInsert;
            }

            if(invoiceLineToClassificationToUpdate.size() > 0){
                upsert invoiceLineToClassificationToUpdate;
            }
        }

        isSaved = true;
        isError = false;

        return null;
    }

    /*
    * Method Name: fetchInvoiceValues
    * Description: To fetch invoice values for project role
    * @param: Project_Invoice__c inv
    * @param: Id pId
    * @return Project_Invoice__c
    */
    private Project_Invoice__c fetchInvoiceValues(Project_Invoice__c inv, Id pId, String projectRole){

    // Fetch Project Role record list
        for(Project_Role__c projRole : [SELECT  Id, Contact__r.Name, Account__r.Name,
                                                Account__r.BillingCity, Account__r.BillingState,
                                                Account__r.BillingStreet, Account__r.BillingPostalCode,
                                                Account__r.Supplier_ID__c
                                        FROM    Project_Role__c
                                        WHERE   Project__c = :pId
                                        AND     Role__c = :projectRole
                                        AND     Primary_Customer_Contact__c = TRUE LIMIT 1]){
            inv.Company_Name__c = projRole.Account__r.Name;
            inv.Contact_Name__c = projRole.Contact__r.Name;
            inv.City__c = projRole.Account__r.BillingCity;
            inv.State__c = projRole.Account__r.BillingState;
            inv.Street__c = projRole.Account__r.BillingStreet;
            inv.Zip__c = projRole.Account__r.BillingPostalCode;
            inv.Supplier_ID__c = projRole.Account__r.Supplier_ID__c;
        }
        return inv;
    }

    /*
    * Method Name: fetchProject
    * Description: To fetch project records
    * @param: Id pId
    * @return void
    */
    private void fetchProject(Id pId){
      amountFromInvoicesApprovedAndAfterStatuses = 0;

        // Get project record by query
        project = [SELECT Id, Name, Total_NYSERDA_Incentive_Amount__c, Status__c, Budget_Type__c, Total_Bill_To_Date_Amount__c,
                   RecordType.Name, RecordTypeId, Total_NYSERDA_Task_Incentives__c,
                   Program_Version__r.Allow_Multiple_Invoices__c,Program_Version__r.Invoice_Type__c,
                   (SELECT Id, Status__c, Total_Amount_Due__c
                    FROM Project_Invoices__r WHERE Status__c NOT IN :ProjectInvoice_Helper.SET_OF_REJECTED_OR_CANCEL_STATUSES),
                    (SELECT Id, Name, Project__c, Status__c, PO_Status__c, NEIS_PO_ID__c,Amount__c
                        FROM Project_Purchase_Orders__r
                        WHERE PO_Status__c IN :Clean_Transportation_Helper.SET_PurchaseOrder_PO_STATUS_FOR_INVOICE),
                   (SELECT Company_Name__c, Email__c, FirstName__c,
                    LastName__c  FROM Project_Roles__r
                    WHERE Primary_Customer_Contact__c =: TRUE
                    AND Role__c =: NYSUN_Helper.PROJECT_ROLE_CUSTOMER limit 1)
                   FROM Project__c
                   WHERE Id =:pId];


        if(project != null){
            if(invoice.Project__c == null){
                invoice.Project__c = project.Id;
            }
            Integer noOfApprovedInvoices = 0;

            // Check for number of Invoice record
            for(Project_Invoice__c inv : project.Project_Invoices__r){
                if(inv.Id != invoice.Id)
                    isFirstInvoice = false;
                if(inv.Status__c != null && ProjectInvoice_Helper.SET_OF_APPROVED_AND_AFTER_STATUSES.contains(inv.Status__c)){
                    noOfApprovedInvoices++;
                    amountFromInvoicesApprovedAndAfterStatuses = amountFromInvoicesApprovedAndAfterStatuses + (inv.Total_Amount_Due__c != null ? inv.Total_Amount_Due__c : 0);
                }else if(isNew && !project.Program_Version__r.Allow_Multiple_Invoices__c){
                    throwPageError(ERR_MSG_PENDING_APPROVAL);
                }
            }

      // Populate purchase order mapping
            for(Project_Purchase_Order__c pOrder : project.Project_Purchase_Orders__r){
              poIdToPoMap.put(pOrder.Id, pOrder);
            }

      // Fetch milstone picklist
            fetchMilestoneSelectOptions();

            // Fetch Prepopulated milestone list
            getPrepopulatedMilestones(invoice.Project_Invoice_Lines__r);
        }
    }


    //T-02786
    /*
    * Method Name: checkForDelinquentAccount
    * Description: Purpose to Check wether primary contractor Account is allowed to raise Invoice
    * @param: none
    * @return void
    */

/*
    private void checkForDelinquentAccount(){
        isDelinquentAccount = false;

        if(project != null){
                Project__c projRec = [Select Id,
                                            (Select Id, Account__c, Account__r.Delinquent__c ,Role__c, Primary_Customer_Contact__c
                                                    From Project_Roles__r
                                                    WHERE Role__c =: NYSUN_Helper.PROJECT_ROLE_CONTRACTOR AND Primary_Customer_Contact__c = true)
                                        From Project__c WHERE Id=: project.Id];

                for(Project_Role__c projRoleRec :projRec.Project_Roles__r){
                    if(projRoleRec.Account__r.Delinquent__c && currentUser.AccountId == projRoleRec.Account__c){
                        isDelinquentAccount = true;
                        break;
                    }
                }

                if(isDelinquentAccount) {
                    throwPageError(System.Label.Innovation_Delinquent_Account_Err_Msg);
                }
        }
    }
    */

    /*
    * Method Name: fetchPurchaseOrderList
    * Description: Purpose to fetch list of purchase order records
    * @param: none
    * @return void
    
    private void fetchPurchaseOrderList() {
        purchaseOrderList = new list<SelectOption>();
        isApprovedPOExist = false;
        if(project != null && project.Project_Purchase_Orders__r.size() > 0){

          // Add default values in picklist option list
            purchaseOrderList.add(new SelectOption('', '-- None --'));
            for(Project_Purchase_Order__c pOrder : project.Project_Purchase_Orders__r){
                if((pOrder.Status__c == ProjectPurchaseOrder_Helper.PO_STATUS_APPROVED
                    || pOrder.Status__c == ProjectPurchaseOrder_Helper.PO_STATUS_CLOSED) && pOrder.NEIS_PO_ID__c != null) {
                        purchaseOrderList.add(new SelectOption(pOrder.Id, pOrder.NEIS_PO_ID__c));
                        isApprovedPOExist = true;
                    }
            }
        }

        if(project.Program_Version__r.Invoice_Type__c == 'Voucher'){
            isApprovedPOExist = true;
        }

    // Show error on page if there is no approved PO exists
        if(!isApprovedPOExist) {
            throwPageError(System.Label.CORE_Invoice_Raise_Restrict_on_No_Open_PO_Msg);
        }
        //checkForDelinquentAccount();
    } */

    /*
    * Method Name: throwPageError
    * Description: To catch page error
    * @param: String errText
    * @return void
    */
    private void throwPageError(String errText){
        isInvoicingAllowed = false;
        pageErrorMessage = errText;
    }

    public List<SelectOption> listOfProjectMilestoneSelectOptions {get; set;}

    public List<ID> listOfMilestoneIdsAvailable {get; set;}

    /*
    * Method Name: fetchMilestoneSelectOptions
    * Description: Purpose to fetch milestone select options
    * @param: none
    * @return void
    */
    public void fetchMilestoneSelectOptions(){
        listOfProjectMilestoneSelectOptions = new List<SelectOption>();
        //Create a set of all active phase so invoice can only be generetaed on active phase milestones.

        if(invoice.Project__c != null){
            mapOfIdAndMilestone = new Map<Id, Project_Milestones__c>();

            // Fetch record and populate dropdown values
            for(Project_Milestones__c mst : [SELECT Id, Name, Hybrid_Budget__c, Parent__r.Sequence__c, Sequence__c, Incentive_Amount__c, Status__c, Type__c,
                                                    Parent__c, Recordtype.Name, Recordtype.DeveloperName, RecordTypeId, Project_Task__c, Cost_Share__c,
                                                    Remaining_Budget__c, Billed_To_Date_Cost_Share__c, Remaining_Budget_Cost_Share__c, Billed_To_Date__c, Parent__r.Hybrid_Budget__c,
                                                    Parent__r.Name, Parent__r.Remaining_Budget__c, Parent__r.Enable_Task_Limit__c, Consumed_Quantity__c, Quantity__c,Project__r.RecordType.DeveloperName
                                              FROM Project_Milestones__c
                                             WHERE Project__c = :invoice.Project__c
                                             ORDER BY Parent__c, Parent__r.Sequence__c, Sequence__c ASC]){
                 if((project.Budget_Type__c == 'T&M'
                         && ((!mst.Hybrid_Budget__c && mst.RecordTypeId == ProjectMilestones_Helper.ParentMilestoneRecordType.Id)
                         || (mst.Parent__r.Hybrid_Budget__c && mst.Status__c == 'Approved' && mst.RecordTypeId == ProjectMilestones_Helper.ChildMilestoneRecordType.Id)))){

                     mapOfIdAndMilestone.put(mst.Id, mst);
                     listOfProjectMilestoneSelectOptions.add(new SelectOption(mst.Id, mst.Name));
                 }
             }
        }
    }

    /*
    * Method Name: fetchInvoice
    * Description: Purpose to fetch invoice
    * @param: none
    * @return void
    */
    private void fetchInvoice(){
        if(String.isNotBlank(invoiceId)){

          // Fetch Project Invoice record based on invoice Id
            invoice = [SELECT Id, NAme,Purchase_Order__c , Project__c,Total_Retainage_Amount__c, Project__r.Name,
                       Project__r.Status__c,Project__r.RecordType.Name, Invoice_Date__c, Due_Date__c, Total_Amount_Due__c, Project__r.Budget_Type__c,
                       Company_Name__c, Contact_Name__c, Street__c, City__c, State__c, Zip__c, Invoice_Notes__c, Status__c, Final_Payment__c,
                       Project_Purchase_Order__c, Project_Purchase_Order__r.Name, Project_Purchase_Order__r.NEIS_PO_ID__c,
                       (SELECT Id, Name,Requesting__c ,Date_Range_End__c, Date_Range_Start__c ,Actual_kWh__c, Invoice__c, Description__c, Budget_Category_Line__c, Is_Budget_Type__c, Amount_Cost_Share__c,
                        Amount__c, Milestone__c, Milestone__r.Name, Milestone__r.Hybrid_Budget__c, Milestone__r.Parent__r.Hybrid_Budget__c, Milestone__r.Parent__r.Name,
                        Milestone__r.RecordType.Name, Milestone__r.RecordType.DeveloperName, Milestone__r.Incentive_Amount__c, Milestone__r.Type__c, Milestone__r.Parent__c,
                        Milestone__r.Project_Task__c, Milestone__r.Cost_Share__c, Milestone__r.Remaining_Budget__c, Milestone__r.Parent__r.Remaining_Budget__c, Milestone__r.Parent__r.Enable_Task_Limit__c,
                        Milestone__r.Parent__r.Sequence__c, Milestone__r.Sequence__c, Milestone__r.Billed_To_Date_Cost_Share__c, Milestone__r.Remaining_Budget_Cost_Share__c, Milestone__r.Billed_To_Date__c,
                        Quantity__c, Milestone__r.Consumed_Quantity__c, Milestone__r.Quantity__c
                       FROM Project_Invoice_Lines__r ORDER BY Milestone__r.Parent__c, Milestone__r.Parent__r.Sequence__c, Milestone__r.Sequence__c ASC)
                       FROM Project_Invoice__c WHERE Id = :invoiceId];

           if(invoice != null && invoice.Project__r.Budget_Type__c == 'T&M'
              && invoice.Project_Invoice_Lines__r != null){
           }
        }

    }

    /*
    * Method Name: fetchDocuments
    * Description: Purpose to fetch documenits
    * @param: none
    * @return void
    */
    private void fetchDocuments(){
        listOfDocuments = new List<Project_Document__c>();
        if(invoice.Id != null){

          // Create mapping for Documents list
            mapOfIdAndProjDoc = new Map<Id, Project_Document__c>([SELECT Id, Name, Project_Deliverables__c, Project__c, CreatedDate, (SELECT Id, Name FROM Attachments LIMIT 1) FROM Project_Document__c WHERE Invoice__c =:invoice.Id]);
            listOfDocuments = mapOfIdAndProjDoc.values();
        }
    }

    /*
    * Method Name: addMilestone
    * Description: Purpose to add milestone
    * @param: none
    * @return void
    */
    public void addMilestone(){
        listOfMilestones.add(new MilestoneWrapper());
    }

    /*
    * Method Name: deleteMilestone
    * Description: Purpose to add milestone
    * @param: none
    * @return void
    */
    public void deleteMilestone(){
        if(listOfMilestones.size() > index){
            if(listOfMilestones[index].projectInvoiceLine.invoiceLineItem.Id != null){
                Database.delete(listOfMilestones[index].projectInvoiceLine.invoiceLineItem);
                fetchInvoice();
            }
            listOfMilestones.remove(index);
        }
    }

    /*
    * Method Name: editAll
    * Description: To enable edit mode
    * @param: none
    * @return void
    */
    public void editAll(){
        isEdit = true;
    }

    /*
    * Method Name: editAllBudgetView
    * Description: Method to expose all budget view into edit mode
    * @param: none
    * @return void
    */
    public void editAllBudgetView(){
        isEdit = true;
        isBudgetView = true;
    }

    /*
    * Method Name: cancelChanges
    * Description: Purpose to cancel changes
    * @param: none
    * @return Pagereference
    */
    public Pagereference cancelChanges() {
        Pagereference pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=false');
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: cancelChangesBudget
    * Description: Purpose to cancel changes budget
    * @param: none
    * @return Pagereference
    */
    public Pagereference cancelChangesBudget() {
        Pagereference pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=true');
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: goToDocumentsPage
    * Description: Purpose to go to documents page
    * @param: none
    * @return Pagereference
    */
    public Pagereference goToDocumentsPage(){
        Pagereference pg;
        if(isPartOfFlow){
            pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id+'&flow=' + flowSource);
        }else{
            pg = new Pagereference('/apex/'+DOCUMENT_PAGE+'?id='+invoice.id);
        }
        return pg;
    }

    /*
    * Method Name: checkForStageGateExceedValidation
    * Description: Purpose to check for stage gate exceed validation
    * @param: none
    * @return Boolean
    */
    private Boolean checkForStageGateExceedValidation() {
        Boolean isExceed = false;

        // If Project budget type is "T&M", then fetch project milestone records for Stage gate exceed validation
        if(project.Budget_Type__c == 'T&M') {
            List<Project_Milestones__c> milestoneList = [select Not_to_Exceed_Amount__c from Project_Milestones__c
                                                            where Project__c =: project.Id
                                                            AND Stage_Gate__c = true
                                                            AND (Stage_Gate_Status__c =: ProjectMilestones_Helper.STAGE_GATE_PENDING_STATUS
                                                            OR   Stage_Gate_Status__c = '')
                                                            AND Not_to_Exceed_Amount__c != null
                                                            order by Sequence__c limit 1];
            Decimal incentiveAmount = 0;

            // Logic to calculate Total incentive amount
            for(MilestoneWrapper milestoneRec : listOfMilestones) {
                incentiveAmount += milestoneRec.projectInvoiceLine.invoiceLineItem.Amount__c != null ? milestoneRec.projectInvoiceLine.invoiceLineItem.Amount__c : 0;
            }
            if(milestoneList.size() > 0) {
                if(project.Total_Bill_To_Date_Amount__c + incentiveAmount >= milestoneList[0].Not_to_Exceed_Amount__c) {
                    isExceed = true;
                }
            }
        }
        return isExceed;
    }


  /*
  * Method Name: I-03743: checkForPOAmountExceedValidation
  * Description: Purpose to check for PO Amount exceed validation
  * @param: none
  * @return Boolean
  */
    private Boolean checkForPOAmountExceedValidation(Boolean checkFromBudget) {
        Boolean isExceed = false;
            Decimal invoiceAmount = 0;

      // Logic to calculate total Incentive Amount
            if(checkFromBudget) {
            if(mapOfBudgetLineIdAndMilestones != null && mapOfBudgetLineIdAndMilestones.size() > 0) {
                for(MilestoneWrapper mst : mapOfBudgetLineIdAndMilestones.values()) {
                    invoiceAmount += mst.projectInvoiceLine.invoiceLineItem.Amount__c != null ? mst.projectInvoiceLine.invoiceLineItem.Amount__c : 0;
                }
            }
            } else {
            for(MilestoneWrapper milestoneRec : listOfMilestones) {
                invoiceAmount += milestoneRec.projectInvoiceLine.invoiceLineItem.Amount__c != null ? milestoneRec.projectInvoiceLine.invoiceLineItem.Amount__c : 0;
            }
            }

            if(poIdToPoMap.containsKey(invoice.Project_Purchase_Order__c)) { // I-03864
                if(invoiceAmount > poIdToPoMap.get(invoice.Project_Purchase_Order__c).Amount__c ||
                amountFromInvoicesApprovedAndAfterStatuses > poIdToPoMap.get(invoice.Project_Purchase_Order__c).Amount__c ||
                invoiceAmount > (poIdToPoMap.get(invoice.Project_Purchase_Order__c).Amount__c - amountFromInvoicesApprovedAndAfterStatuses)) {

                  isExceed = true;
                }
            }
            System.debug(' >>> Invoice = ' + invoiceAmount + ' PO = ' + poIdToPoMap.get(invoice.Project_Purchase_Order__c).Amount__c);
        return isExceed;
    }

    /*
    * Method Name: saveInvoiceRecord
    * Description: Purpose to save invoice records
    * @param: none
    * @return Pagereference
    */
    public Pagereference saveInvoiceRecord(){
        Pagereference pg;

        // Transational Handling - Set Savepoint
        Savepoint sp = Database.setSavepoint();
        try{

            if(checkForStageGateExceedValidation()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Clean_Transportation_Stage_Gate_Not_To_Exceed_Validation_Message));
                return null;
            }

      // If there is no error, Update or Insert Invoice
            Database.upsert(invoice);

            if(invoice.id != null){

        // Save Milestone list
                saveMilestones();

        // Create Distribution list to insert
                if(invoice.Project_Purchase_Order__c != null && !isPortalUser){

                    List<Project_Invoice_Distribution_Line__c> distributionsToUpsert = new List<Project_Invoice_Distribution_Line__c>();

                    for(MilestoneWrapper tempMilestone : listOfMilestones){
                        if(tempMilestone.projectInvoiceLine.distributions != null &&
                           tempMilestone.projectInvoiceLine.distributions.size() > 0){

                            for(ProjectFundingDistributionWrapper tempFunding : tempMilestone.projectInvoiceLine.distributions){

                                if(tempMilestone.projectInvoiceLine.invoiceLineItem.Id != null && tempFunding.distribution.Project_Invoice_Line__c == null){
                                    tempFunding.distribution.Project_Invoice_Line__c = tempMilestone.projectInvoiceLine.invoiceLineItem.Id;
                                }

                                if(invoice.Id != null && tempFunding.distribution.Project_Invoice__c == null){
                                    tempFunding.distribution.Project_Invoice__c = invoice.Id;
                                }

                                distributionsToUpsert.add(tempFunding.distribution);
                            }
                        }
                    }

                    if(distributionsToUpsert.size() > 0){
                        upsert distributionsToUpsert;
                    }
                }

        // Refresh page
                if(isPartOfFlow && invoice.Status__c == ProjectInvoice_Helper.STATUS_PENDING_REVIEW){
                    pg = PageNavigationUtility.getNextPageURL(invoice.Project__c, flowSource, null);
                }else if(isPartOfFlow){
                    pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id+'&flow=' + flowSource);
                }else{
                    pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=false');
                }
                pg.setRedirect(true);
            }
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            Database.rollback(sp);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
        }
        return pg;
    }

    /*
    * Method Name: saveMilestones
    * Description: This method use to save records of milestone
    * @param: none
    * @return void
    */
    public void saveMilestones() {
        system.debug('-------'+listOfMilestones);
        List<Project_Invoice_Line__c> listToUpdate = new List<Project_Invoice_Line__c>();

        for(MilestoneWrapper mst : listOfMilestones) {
            if(mst.projectInvoiceLine.invoiceLineItem.Milestone__c != null) {
                if(mst.projectInvoiceLine.invoiceLineItem.Invoice__c == null) {
                    mst.projectInvoiceLine.invoiceLineItem.Invoice__c = invoice.Id;
                }
                listToUpdate.add(mst.projectInvoiceLine.invoiceLineItem);
            }
        }

        system.debug('-------'+mapOfBudgetLineIdAndMilestones);
        if(mapOfBudgetLineIdAndMilestones != null && mapOfBudgetLineIdAndMilestones.size() > 0) {
            for(MilestoneWrapper mst : mapOfBudgetLineIdAndMilestones.values()){
                if(mst.projectInvoiceLine.invoiceLineItem.Invoice__c == null) {
                    mst.projectInvoiceLine.invoiceLineItem.Invoice__c = invoice.Id;
                }
                listToUpdate.add(mst.projectInvoiceLine.invoiceLineItem);
            }
        }

    // Updateor Insert milestone records
        if(listToUpdate.size() > 0){
            Database.upsert(listToUpdate);
        }

        fetchInvoice();
    }

    /*
    * Method Name: submitForReview
    * Description: This method use to submite application for review
    * @param: none
    * @return PageReference
    */
    public PageReference submitForReview(){
        Pagereference pg;
        if(isSubmissionAllowed()){
            if(invoice.Id <> null){

              // Populate cost share and line item cost
                Decimal totalLineItemCostShare = 0;

                for(MilestoneWrapper tempMilestone : listOfMilestones){

                    if(tempMilestone.projectInvoiceLine != null &&
                       tempMilestone.projectInvoiceLine.invoiceLineItem != null &&
                       tempMilestone.projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c != null){

                        totalLineItemCostShare += tempMilestone.projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c;

                    }
                }

                Decimal totalCostShare = 0;

                for(Project_Invoice_Line_To_Classifications__c temp : [SELECT Actual_Total__c
                                                                       FROM Project_Invoice_Line_To_Classifications__c
                                                                       WHERE Project_Invoice_Line__r.Invoice__c =: invoiceId]){

                    totalCostShare += (temp.Actual_Total__c != null ? temp.Actual_Total__c : 0);
                }

                if(totalLineItemCostShare != totalCostShare){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Clean_Transportation_Cost_Share_Validation_Message));
                    return null;
                }
            }

      // Set Status, Due date and Invoice Date
            invoice.Status__c = ProjectInvoice_Helper.STATUS_SUBMITTED;
            invoice.Due_Date__c = System.today() + 30;
            invoice.Invoice_Date__c = System.today();
            Database.update(invoice);


            Set<Id> projectMilestoneIds = new Set<Id>();
            Set<Id> budgetCategoryLineIds = new Set<Id>();
            Set<String> invalidStatus = new Set<String>{'Draft', 'Rejected', 'Cancelled'};

            //fetch milestone Ids
            for(MilestoneWrapper mst : listOfMilestones){
                if(mst.projectInvoiceLine.invoiceLineItem.Milestone__c != null){
                    projectMilestoneIds.add(mst.projectInvoiceLine.invoiceLineItem.Milestone__c);
                }
            }

            //fetch budget category line Ids
            if(mapOfBudgetLineIdAndMilestones != null && mapOfBudgetLineIdAndMilestones.size() > 0) {
                for(MilestoneWrapper mst : mapOfBudgetLineIdAndMilestones.values()){
                    if(mst.budgetCategoryLine != null && mst.budgetCategoryLine.Id != null){
                        budgetCategoryLineIds.add(mst.budgetCategoryLine.Id);
                    }
                }
            }


            if(projectMilestoneIds.size() > 0) {
                List<Project_Milestones__c> listOfMilestoneToUpdate = new List<Project_Milestones__c>();

        // Fetch Project Milestone record
                for(Project_Milestones__c tempProMilestone : [SELECT Id, Legacy_Billed_To_Date__c, Legacy_Billed_To_Date_Cost_Share__c,
                                                                        (SELECT Id, Amount__c, Amount_Cost_Share__c
                                                                           FROM Project_Invoice_Lines__r
                                                                          WHERE Invoice__r.Status__c NOT IN : invalidStatus)
                                                              FROM Project_Milestones__c
                                                              WHERE ID IN : projectMilestoneIds]){

                    Decimal totalBilledToDate = 0;
                    Decimal totalBilledToDateCostShare = 0;
                    Decimal legacyBilledToDate = (tempProMilestone.Legacy_Billed_To_Date__c != null) ? tempProMilestone.Legacy_Billed_To_Date__c : 0;
                    Decimal legacyBilledToDateCostShare = (tempProMilestone.Legacy_Billed_To_Date_Cost_Share__c != null) ? tempProMilestone.Legacy_Billed_To_Date_Cost_Share__c : 0;

                    for(Project_Invoice_Line__c tempInvoiceLine : tempProMilestone.Project_Invoice_Lines__r){
                        totalBilledToDate += (tempInvoiceLine.Amount__c != null) ? tempInvoiceLine.Amount__c : 0;
                        totalBilledToDateCostShare += (tempInvoiceLine.Amount_Cost_Share__c != null) ? tempInvoiceLine.Amount_Cost_Share__c : 0;
                    }

                    listOfMilestoneToUpdate.add(new Project_Milestones__c(Id = tempProMilestone.Id,
                                                                          Billed_To_Date__c = (totalBilledToDate + legacyBilledToDate),
                                                                          Billed_To_Date_Cost_Share__c = (totalBilledToDateCostShare + legacyBilledToDateCostShare)));
                }

        // Update milestone list
                if(listOfMilestoneToUpdate.size() > 0){
                    Database.update(listOfMilestoneToUpdate);
                }
            }

            if(budgetCategoryLineIds.size() > 0) {
                List<BudgetCategoryLine__c> listOfCategoryLineToUpdate = new List<BudgetCategoryLine__c>();

        // Fetch Budget category lines
                for(BudgetCategoryLine__c tempBudgetCatLine : [SELECT Id, Legacy_Billed_To_Date__c, Legacy_Billed_To_Date_Cost_Share__c,
                                                                      (SELECT Id, Amount__c, Amount_Cost_Share__c
                                                                         FROM Project_Invoice_Lines__r
                                                                        WHERE Invoice__r.Status__c NOT IN : invalidStatus)
                                                                  FROM BudgetCategoryLine__c
                                                                 WHERE ID IN : budgetCategoryLineIds]){

                    Decimal totalBilledToDate = 0;
                    Decimal totalBilledToDateCostShare = 0;
                    Decimal legacyBilledToDate = (tempBudgetCatLine.Legacy_Billed_To_Date__c != null) ? tempBudgetCatLine.Legacy_Billed_To_Date__c : 0;
                    Decimal legacyBilledToDateCostShare = (tempBudgetCatLine.Legacy_Billed_To_Date_Cost_Share__c != null) ? tempBudgetCatLine.Legacy_Billed_To_Date_Cost_Share__c : 0;


                    for(Project_Invoice_Line__c tempInvoiceLine : tempBudgetCatLine.Project_Invoice_Lines__r){
                        totalBilledToDate += (tempInvoiceLine.Amount__c != null) ? tempInvoiceLine.Amount__c : 0;
                        totalBilledToDateCostShare += (tempInvoiceLine.Amount_Cost_Share__c != null) ? tempInvoiceLine.Amount_Cost_Share__c : 0;
                    }

                    listOfCategoryLineToUpdate.add(new BudgetCategoryLine__c(Id = tempBudgetCatLine.Id,
                                                                             Billed_To_Date__c = (totalBilledToDate + legacyBilledToDate),
                                                                             Billed_To_Date_Cost_Share__c = (totalBilledToDateCostShare + legacyBilledToDateCostShare)));
                }

        // Update Category Lines
                if(listOfCategoryLineToUpdate.size() > 0){
                    Database.update(listOfCategoryLineToUpdate);
                }
            }


      // Refresh page
            if(isPartOfFlow && invoice.Status__c == ProjectInvoice_Helper.STATUS_PENDING_REVIEW){
                pg = PageNavigationUtility.getNextPageURL(invoice.Project__c, flowSource, null);
            }else if(isPartOfFlow){
                pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id+'&flow=' + flowSource + '&issubmit=1');
            }else{
                pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=false&issubmit=1');
            }
            pg.setRedirect(true);
        }
        return pg;
    }

    /*
    * Method Name: getParentId
    * Description: Purpose to get parent Id
    * @param: String objectName
    * @return String
    */
    private String getParentId(String objectName){
      // Fetch VF page URL parameter for Project Id
        String parentId = Apexpages.currentPage().getParameters().get('pid');
        String objectPrefix = '';
        for(String pgParam : Apexpages.currentPage().getParameters().keySet()){
            if(pgParam.endsWith('_lkid')){
                if(objectName == 'Project__c'){
                    objectPrefix = Project__c.sobjectType.getDescribe().getKeyPrefix();
                }
                if((Apexpages.currentPage().getParameters().get(pgParam)).startsWith(objectPrefix)){
                    parentId = Apexpages.currentPage().getParameters().get(pgParam);
                }
            }
        }
        return parentId;
    }

    /*
    * Method Name: fetchListOfProjects
    * Description: To fetch list of projects
    * @param: String searchText
    * @return List<Project__c>
    */
    @RemoteAction
    public static List<Project__c> fetchListOfProjects(String searchText){
        return [SELECT Id, Name FROM Project__c WHERE Name LIKE :searchText+'%' LIMIT 20];
    }

    private Map<Id, Project_Invoice_Line__c> mapOfBCatLineIdAndProjInvLine;

    /*
    * Method Name: getPrepopulatedMilestones
    * Description: Purpose to get prepopulated milestones
    * @param: List<Project_Invoice_Line__c> localListOfInvoices
    * @return void
    */
    private void getPrepopulatedMilestones(List<Project_Invoice_Line__c> localListOfInvoices){
      // Initialize variables used in logic

        MilestoneWrapper milestone;
        mapOfBCatLineIdAndProjInvLine = new Map<Id, Project_Invoice_Line__c>();

        // Create mapping for Category line and Invoice Lines
        if(listOfMilestones!=null && localListOfInvoices.size() > 0){
            for(Project_Invoice_Line__c invoiceLine : localListOfInvoices){
                if(invoiceLine.Budget_Category_Line__c == null){
                    milestone = new MilestoneWrapper();
                    milestone.projectInvoiceLine = new InvoiceLineWrapper(invoiceLine, new List<ProjectFundingDistributionWrapper>());
                    listOfMilestones.add(milestone);
                }else{
                    mapOfBCatLineIdAndProjInvLine.put(invoiceLine.Budget_Category_Line__c, invoiceLine);

                }
            }
        }else{
            for(Project_Milestones__c mst : mapOfIdAndMilestone.values()){
                milestone = new MilestoneWrapper();
                milestone.projectInvoiceLine = new InvoiceLineWrapper(new Project_Invoice_Line__c(Milestone__c = mst.id, Amount__c = 0, Milestone__r = mst),
                                                                      new List<ProjectFundingDistributionWrapper>());

                listOfMilestones.add(milestone);
            }
            //updateListOfMilestones();
        }

        if(listOfMilestones.size() > 0){
            Integer milestonesSize = listOfMilestones.size();

            for(Integer y=0; y<listOfMilestones.size(); y++){
                boolean swapped = false;

                for(Integer x=0; x<milestonesSize; x++){
                    if(x+1 == listOfMilestones.size())break;

                    boolean isConditionMatch = false;

                    Integer xSequence = 0;

                    if(listOfMilestones.get(x).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r != null
                       && listOfMilestones.get(x).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r.Sequence__c != null){
                        xSequence = Integer.valueOf(listOfMilestones.get(x).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r.Sequence__c);
                    }else if(listOfMilestones.get(x).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r == null &&
                             listOfMilestones.get(x).projectInvoiceLine.invoiceLineItem.Milestone__r.Sequence__c != null){
                        xSequence = Integer.valueOf(listOfMilestones.get(x).projectInvoiceLine.invoiceLineItem.Milestone__r.Sequence__c);
                    }

                    Integer ySequence = 0;

                    if(listOfMilestones.get(x+1).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r != null
                       && listOfMilestones.get(x+1).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r.Sequence__c != null){
                        ySequence = Integer.valueOf(listOfMilestones.get(x+1).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r.Sequence__c);
                    }else if(listOfMilestones.get(x+1).projectInvoiceLine.invoiceLineItem.Milestone__r.Parent__r == null
                             && listOfMilestones.get(x+1).projectInvoiceLine.invoiceLineItem.Milestone__r.Sequence__c != null){
                        ySequence = Integer.valueOf(listOfMilestones.get(x+1).projectInvoiceLine.invoiceLineItem.Milestone__r.Sequence__c);
                    }

                    if(xSequence > ySequence){
                        MilestoneWrapper swapMilestone = listOfMilestones.get(x);
                        swapped = true;
                        listOfMilestones.set(x, listOfMilestones.get(x+1));
                        listOfMilestones.set(x+1, swapMilestone);
                    }
                }

                milestonesSize--;

                if(!swapped){y = listOfMilestones.size();}
            }
        }
    }

  // Various properties used on VF page
    public Map<Id, Boolean> mapOfDeliverableIdAndRequiredStatus {get; set;}
    public Map<Id, Project_Deliverables__c> mapOfIdAndDeliverables {get; set;}
    public Map<Id, Project_Document__c> mapOfIdAndDocuments {get; set;}
    public List<Project_Milestones__c> listOfProjectMilestones {get; set;}
    public Map<Id, Attachment> mapOfDeliverableIdAndAttachment {get; set;}

    /*
    * Method Name: fetchDeliverables
    * Description: This method use to fetch deliverbles
    * @param: none
    * @return void
    */
    public void fetchDeliverables(){

    // Initialize Properties used ON VF page
        listOfProjectMilestones = new List<Project_Milestones__c>();
        mapOfDeliverableIdAndRequiredStatus = new Map<Id, Boolean>();
        mapOfDeliverableIdAndAttachment = new Map<Id, Attachment>();
        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>();
        mapOfIdAndDocuments = new Map<Id, Project_Document__c>();

        Set<Id> setOfProjectMilestones = new Set<Id>();


        for(Project_Invoice_Line__c invoiceLine : invoice.Project_Invoice_Lines__r){
            setOfProjectMilestones.add(invoiceLine.Milestone__c);
        }


    // Fetch Project Milestone record and check for Required
        Boolean isRequiredLocal = false;
        for(Project_Milestones__c milestone : [SELECT Id, Name, Incentive_Amount__c, (SELECT Id, Name, Mandatory_by_Default__c,Project__r.Name,Conditionally_Required__c, Validation_Logic__c, Status__C FROM Project_Deliverables1__r) FROM Project_Milestones__c WHERE ID IN :setOfProjectMilestones]){
            listOfProjectMilestones.add(milestone);
            for(Project_Deliverables__c deliverable : milestone.Project_Deliverables1__r){
                if(deliverable.Mandatory_by_Default__c){
                    isRequiredLocal = true;
                }else if(deliverable.Conditionally_Required__c){
                    isRequiredLocal = FormulaInterpretUtility.checkForRequried(deliverable);
                }else{
                    isRequiredLocal = false;
                }
                mapOfDeliverableIdAndRequiredStatus.put(deliverable.id, isRequiredLocal);
                mapOfDeliverableIdAndAttachment.put(deliverable.id, new Attachment());
            }
        }

        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>();

    // Create Mapping for Deliverables records
        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>([SELECT Id, Name, Status__c, CreatedDate,
                                                                      (SELECT Id, Name , Version__c, Status__c, Invoice__c, Notes__c, CreatedDate, CreatedBy.Name FROM Project_Documents__r WHERE Invoice__c =: invoice.Id ORDER BY CreatedDate desc)
                                                                      FROM Project_Deliverables__c
                                                                      WHERE Project__c =: invoice.Project__c
                                                                      AND Project_Milestone__c = null
                                                                      AND Project_Invoice__c =: invoice.Id]);

        mapOfIdAndDocuments = new Map<Id, Project_Document__c>();

    // Create Mapping for Document records
        mapOfIdAndDocuments = new Map<Id,Project_Document__c>([SELECT Id, Name, Project_Deliverables__c, Version__c, Status__c, CreatedDate, CreatedBy.Name, Notes__c,
                                                              (SELECT Id, Name, BodyLength FROM Attachments LIMIT 1)
                                                              FROM Project_Document__c
                                                              WHERE Project_Deliverables__c IN :mapOfIdAndDeliverables.keySet()
                                                              AND Invoice__c =: invoice.Id]);

        List<Project_Deliverables__c> tempDeliverablesList = new List<Project_Deliverables__c>();

        otherDocumentList = new List<OtherDocument>();

        Map<String, Attachment> otherProjectDeliverablesIdToAttachmentRecMap = new Map<String, Attachment>();

    // Create other doucment list
        if(mapOfIdAndDeliverables != null && mapOfIdAndDeliverables.values().size() > 0){
            otherProjectDeliverablesIdToAttachmentRecMap = getAttachmentList(mapOfIdAndDeliverables.values(), invoice.Id);

            for(Project_Deliverables__c deliverables : mapOfIdAndDeliverables.values()){

                OtherDocument otherDoc = new OtherDocument(deliverables.Id, deliverables.Name,
                                                           new Attachment(),
                                                           otherProjectDeliverablesIdToAttachmentRecMap.get(deliverables.Id),
                                                           deliverables.Status__c);
                otherDocumentList.add(otherDoc);
            }

        }

    // Check for all deliverables approved
        isAllDeliverablesApproved = true;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c != 'Approve') {
                isAllDeliverablesApproved = false;
                break;
            }
        }

    // Check for rejected documents
        isRejectedDocumentPresent = false;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c == 'Reject') {
                isRejectedDocumentPresent = true;
                break;
            }
        }

        if((!isLocked) || isNew){
            addDocumentInOtherDocumentList();
        }
    }

    /*
    * Method Name: saveOtherDocumentsBeforeAddMore
    * Description: This method use to save other documents before add more
    * @param: none
    * @return PageReference
    */
    public PageReference saveOtherDocumentsBeforeAddMore() {
        saveDocuments();

        return goToDocumentsPage();
    }

    /*
    * Method Name: getAttachmentList
    * Description: Purpose to get list of attachmenits
    * @param: List<Project_Deliverables__c> projectDeliverablesList
    * @param: Id invoiceId
    * @return Map<String, Attachment>
    */
    public static Map<String, Attachment> getAttachmentList(List<Project_Deliverables__c> projectDeliverablesList, Id invoiceId) {

      // Fetch Project Document list
        List<Project_Document__c> documentList = [SELECT Id, Name, Project_Deliverables__c, (SELECT Id, Name FROM Attachments)
                                                  FROM Project_Document__c
                                                  WHERE Project_Deliverables__c IN: projectDeliverablesList
                                                  AND Invoice__c =: invoiceId Order by Version__c DESC nulls last];

        List<Attachment> attachmentList = new List<Attachment>();
        Map<String, Attachment> projDeliverablesIdToAttachmentRecMap = new Map<String, Attachment>();

    // Create mapping for deliverable and attachment
        for(Project_Document__c doc : documentList) {
            if(!projDeliverablesIdToAttachmentRecMap.containsKey(doc.Project_Deliverables__c)) {
                Attachment att = (doc.attachments.size() > 0) ? doc.attachments[0] : new Attachment();
                projDeliverablesIdToAttachmentRecMap.put(doc.Project_Deliverables__c, att);
            }
        }

        for(Project_Deliverables__c projDeliverables : projectDeliverablesList) {
            if(!projDeliverablesIdToAttachmentRecMap.containsKey(projDeliverables.Id)) {
                projDeliverablesIdToAttachmentRecMap.put(projDeliverables.Id, new Attachment());
            }
        }

        return projDeliverablesIdToAttachmentRecMap;
    }

    /*
    * Method Name: addDocumentInOtherDocumentList
    * Description: Purpose to add documents in other documents list
    * @param: none
    * @return: PageReference
    */
    public PageReference addDocumentInOtherDocumentList() {
        for(Integer i=0; i<10; i++){
            otherDocumentList.add(new OtherDocument(null, '', new Attachment(), new Attachment(), ''));
        }

        return null;
    }

    /*
    * Method Name: removeDocumentFromList
    * Description: Purpose to remove documents from list
    * @param: none
    * @return: PageReference
    */
    public PageReference removeDocumentFromList() {
        OtherDocument otherDoc = otherDocumentList.get(rowNumber);
        if(otherDoc.documentId != null) {
            otherDocumentList.remove(rowNumber);
            Project_Deliverables__c projectDeliverables = new Project_Deliverables__c(Id = otherDoc.documentId);
            delete projectDeliverables;
        }
        return null;
    }

    /*
    * Method Name: saveDocuments
    * Description: To save documelnits
    * @param: none
    * @return: PageReference
    */
    public PageReference saveDocuments(){

        try{
      // Initialize variables used in logic
            List<Project_Deliverables__c> projDeliverablesList = new List<Project_Deliverables__c>();

            List<OtherDocument> validOtherDocumentsList = new List<OtherDocument>();

      // Populate Project Deliverable record value and update records
            for(OtherDocument otherDoc : otherDocumentList) {
                if((!String.isBlank(otherDoc.documentName)) && ((otherDoc.documentId != null)
                                                                || (otherDoc.attach.body != null))) {
                    Project_Deliverables__c projDeliverables = new Project_Deliverables__c();
                    projDeliverables.Id = otherDoc.documentId;
                    projDeliverables.Name = otherDoc.documentName;
                    projDeliverables.Project_Invoice__c = invoice.Id;

                    if(otherDoc.status != 'Approve' && otherDoc.status != 'Submitted'){
                        projDeliverables.Status__c = 'Submitted';
                    }

                    if(String.isBlank(otherDoc.documentId)) {
                        projDeliverables.Project__c = invoice.Project__c;
                    }
                    projDeliverablesList.add(projDeliverables);

                    validOtherDocumentsList.add(otherDoc);
                }
            }

            if(projDeliverablesList.size() > 0) {
                upsert projDeliverablesList;
            }

            Map<Id, Integer> projDeliverablesSizeMap = new Map<Id, Integer>();

            List<Project_Document__c> documentListToUpdate = new List<Project_Document__c>();

      // Fetch Project Deliverables list
            for(Project_Deliverables__c deliverables : [SELECT Id, (SELECT Version__c, Project__c,
                                                        Project_Deliverables__c, Name, Status__c FROM Project_Documents__r
                                                        ORDER BY Version__c DESC)
                                                        FROM Project_Deliverables__c WHERE Id IN: projDeliverablesList
                                                        AND Project_Invoice__c =: invoice.Id]){
                if(deliverables.Project_Documents__r != null && deliverables.Project_Documents__r.size() > 0){
                    projDeliverablesSizeMap.put(deliverables.Id, deliverables.Project_Documents__r.size());

                    if(deliverables.Project_Documents__r[0].Status__c != 'Approve' &&
                       deliverables.Project_Documents__r[0].Status__c != 'Submitted'){
                        Project_Document__c tempDocument = deliverables.Project_Documents__r[0];
                        tempDocument.Status__c = 'Submitted';
                        documentListToUpdate.add(tempDocument);
                    }
                }else{
                    projDeliverablesSizeMap.put(deliverables.Id, 0);
                }
            }

            List<Project_Document__c> documentListToInsert = new List<Project_Document__c>();
            List<Attachment> attachmentListToInsert = new List<Attachment>();

      // Populate Project Document record and Attachment for Deliverables
            for(Integer i = 0; i < validOtherDocumentsList.size(); i++) {
                if(validOtherDocumentsList[i].attach.body != null) {
                    Integer totalDocuments = projDeliverablesSizeMap.containsKey(projDeliverablesList[i].Id) ? projDeliverablesSizeMap.get(projDeliverablesList[i].Id) : 0;
                    Project_Document__c doc = new Project_Document__c();
                    doc.Version__c = totalDocuments + 1;
                    doc.Project__c = invoice.Project__c;
                    doc.Project_Deliverables__c = projDeliverablesList[i].Id;
                    doc.Name = projDeliverablesList[i].Name;
                    doc.Status__c = 'Submitted';
                    doc.Invoice__c = invoice.Id;
                    documentListToInsert.add(doc);

                    Attachment attach = new Attachment();
                    attach.Body = validOtherDocumentsList[i].attach.body;
                    attach.Name = validOtherDocumentsList[i].attach.Name;
                    attachmentListToInsert.add(attach);
                }
            }

      // Insert document list
            if(documentListToInsert.size() > 0) {
                upsert documentListToInsert;
            }

      // Set Parent Id in Attachment record and Insert Attachment record
            if(attachmentListToInsert.size() > 0) {
                for(Integer i = 0; i < documentListToInsert.size(); i++) {
                    attachmentListToInsert[i].ParentId = documentListToInsert[i].Id;
                }
                insert attachmentListToInsert;
            }

            if(documentListToUpdate.size() > 0) {
                upsert documentListToUpdate;
            }

      // Refresh list to show on page
            fetchDeliverables();
            return goToDocumentsPage();
        }catch(Exception e){
            throw e;
        }

    }

    /*
    * Method Name: setEditMode
    * Description: Purpose to enable edit mode
    * @param: none
    * @return: PageReference
    */
    public PageReference setEditMode() {
        isEditMode = true;
        fetchDeliverables();
        return null;
    }

    /*
    * Method Name: cancelChangesOfApprovalProcess
    * Description: Purpose to cancel changes of approval process
    * @param: none
    * @return: PageReference
    */
    public PageReference cancelChangesOfApprovalProcess() {
        fetchDeliverables();
        isEditMode = false;
        return null;
    }

    /*
    * Method Name: getStatus
    * Description: Purpose to get status
    * @param: none
    * @return: List<SelectOption>
    */
    public List<SelectOption> getStatus() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Approve','Approve'));
        options.add(new SelectOption('Reject','Reject'));
        return options;
    }

    /*
    * Method Name: setStatusOfProjectDocuments
    * Description: Purpose to set status of project documents
    * @param: none
    * @return: Pagereference
    */
    public Pagereference setStatusOfProjectDocuments() {

      // Initialize variables used in logic
        List<Project_Document__c> docListToUpdate = new List<Project_Document__c>();
        List<Project_Deliverables__c> projDeliverablesListToUpdate = new List<Project_Deliverables__c>();

    // Check for deliverable records
        for(Project_Deliverables__c projDeliverableRec : mapOfIdAndDeliverables.values()) {
            Project_Document__c projDocumentRec = new Project_Document__c();
            if(approvAllDoc && projDeliverableRec.Project_Documents__r.size() > 0) {
                projDocumentRec.Status__c = 'Approve';
                projDocumentRec.Id = projDeliverableRec.Project_Documents__r[0].Id;
                projDocumentRec.Notes__c = projDeliverableRec.Project_Documents__r[0].Notes__c;
                docListToUpdate.add(projDocumentRec);
                projDeliverablesListToUpdate.add(new Project_Deliverables__c(Id = projDeliverableRec.id, Status__c = 'Approve'));
            } else if(projDeliverableRec.Project_Documents__r.size() > 0 && projDeliverableRec.Project_Documents__r[0].Status__c != null) {
                docListToUpdate.add(projDeliverableRec.Project_Documents__r[0]);
                projDeliverablesListToUpdate.add(new Project_Deliverables__c(Id = projDeliverableRec.id, Status__c = projDeliverableRec.Project_Documents__r[0].Status__c));
            }
        }

    // Update Document list
        if(docListToUpdate.size() > 0) {
            update docListToUpdate;
        }

    // Update Project Deliverable list
        if(projDeliverablesListToUpdate.size() > 0) {
            update projDeliverablesListToUpdate;
        }

    // Check for Approved list
        isAllDeliverablesApproved = true;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c != 'Approve') {
                isAllDeliverablesApproved = false;
                break;
            }
        }

    // Check for Rejected list
        isRejectedDocumentPresent = false;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c == 'Reject') {
                isRejectedDocumentPresent = true;
                break;
            }
        }

        isEditMode = false;
        return null;
    }

    /*
    * Method Name: setInvoiceStatus
    * Description: Purpose to set invoice status
    * @param: none
    * @return: Pagereference
    */
    public PageReference setInvoiceStatus() {

        PageReference pg;
        if(invoiceStatus == 'Rejected') {
            pg = null;
        } else {
            updateProjectInvoiceLine();
            invoice.Status__c = invoiceStatus;
            update invoice;

            // Refresh page
            pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=false&invoiceStatus=' + invoiceStatus);
            pg.setRedirect(true);
        }
        return pg;
    }

    /*
    * Method Name: updateProjectInvoiceLine
    * Description: This method use to update project invoice line
    * @param: none
    * @return: void
    */
    private void updateProjectInvoiceLine() {
        Set<Id> milestoneIdSet = new Set<Id>();
        for(MilestoneWrapper milestoneRec : listOfMilestones) {
            milestoneIdSet.add(milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c);
        }

    // Fetch Project Milestone list
        Map<Id, Project_Milestones__c> projectMilestoneMap = new Map<Id, Project_Milestones__c>([SELECT Billed_To_Date__c, Billed_To_Date_Cost_Share__c
                                                                                                 FROM   Project_Milestones__c
                                                                                                 WHERE  Id IN: milestoneIdSet]);

        List<Project_Milestones__c> projectMilestoneList = new List<Project_Milestones__c>();
        for(MilestoneWrapper milestoneRec : listOfMilestones) {
            Decimal amount = 0;
            Decimal costShare = 0;

            // Logic to calculate Incentive amount and Cost share amount
            if(milestoneRec.projectInvoiceLine.invoiceLineItem != null) {
                amount = (milestoneRec.projectInvoiceLine.invoiceLineItem.Amount__c != null?
                                          milestoneRec.projectInvoiceLine.invoiceLineItem.Amount__c : 0);
                amount += ((projectMilestoneMap.containsKey(milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c)
                              && projectMilestoneMap.get(milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date__c != null) ?
                            projectMilestoneMap.get(milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date__c : 0);
            }
            if(milestoneRec.projectInvoiceLine.invoiceLineItem != null) {
                costShare = (milestoneRec.projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c != null?
                                          milestoneRec.projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c : 0);
                costShare += ((projectMilestoneMap.containsKey(milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c)
                              && projectMilestoneMap.get(milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date_Cost_Share__c != null) ?
                            projectMilestoneMap.get(milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date_Cost_Share__c : 0);
            }

            // Set default field on Project Milestone record
            Project_Milestones__c proMilestoneRec = new Project_Milestones__c(Id = milestoneRec.projectInvoiceLine.invoiceLineItem.Milestone__c);
            proMilestoneRec.Billed_To_Date__c = amount;
            proMilestoneRec.Billed_To_Date_Cost_Share__c = costShare;
            projectMilestoneList.add(proMilestoneRec);
        }

    // Update project milestone list
        if(projectMilestoneList.size() > 0) {
            update projectMilestoneList;
        }
    }

    /*
    * Method Name: isRequiredDocumentMissing
    * Description: This method use to validate required document is missing or not
    * @param: none
    * @return: Boolean
    */
    private Boolean isRequiredDocumentMissing(){
        Boolean isMissing = false;
        fetchDeliverables();
        for(Id dId : mapOfDeliverableIdAndRequiredStatus.keySet()){
            if(mapOfDeliverableIdAndRequiredStatus.get(dId) == true && mapOfIdAndDeliverables.get(dId).Project_Documents__r.size() == 0){
                isMissing = true;
                break;
            }
        }
        return isMissing;
    }

    /*
    * Method Name: isSubmissionAllowed
    * Description: This method use to expose submission allowed
    * @param: none
    * @return: Boolean
    */
    private Boolean isSubmissionAllowed(){
      // Check for errors
        if(isRequiredDocumentMissing()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MISSING_DOC_MESSAGE));
            return false;
        }else if(hasExcessAmount()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MSG_EXCESS_AMOUNT));
            return false;
        }else if(project.Budget_Type__c == 'T&M' && hasMoreInvoicingThanBudget()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MSG_BUDGET_EXCESS_AMOUNT));
            return false;
        }
        return true;
    }

    /*
    * Method Name: hasMoreInvoicingThanBudget
    * Description: This method use to expose more invoicing than budget
    * @param: none
    * @return: Boolean
    */
    private Boolean hasMoreInvoicingThanBudget(){
        Decimal budgetAmount = 0;
        Decimal invoiceAmount = 0;

        // Calculate Budget amount and Invoice Amount
        for(Project_Invoice_Line__c invLine : invoice.Project_Invoice_Lines__r){
            if(invLine.Budget_Category_Line__c != null && invLine.Amount__c != null){
                budgetAmount += invLine.Amount__c;
            }

            if(invLine.Milestone__c != null && invLine.Amount__c != null){
                invoiceAmount += invLine.Amount__c;
            }
        }

        if(budgetAmount != invoiceAmount){
            return true;
        }
        return false;
    }

    /*
    * Method Name: hasExcessAmount
    * Description: Purpose to check excess amount
    * @param: none
    * @return: Boolean
    */
    private Boolean hasExcessAmount(){
        for(MilestoneWrapper tempMilestone : listOfMilestones){
            if(tempMilestone.projectInvoiceLine.invoiceLineItem.Id != null) {
                if(tempMilestone.projectInvoiceLine.invoiceLineItem.Amount__c > 0 && tempMilestone.projectInvoiceLine.invoiceLineItem.Milestone__r.Remaining_Budget__c < tempMilestone.projectInvoiceLine.invoiceLineItem.Amount__c) {
                    return true;
                }
            }
        }
        return false;
    }

    /*
    * Method Name: goToMainInvoicePage
    * Description: Purpose to go to main invoice page
    * @param: none
    * @return: PageReference
    */
    public PageReference goToMainInvoicePage(){
        Pagereference pg;
        if(isPartOfFlow){
            pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id+'&flow=' + flowSource);
        }else{
            pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=false');
        }
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: goToTaskInvoiceView
    * Description: Purpose to to to task invoice view
    * @param: none
    * @return: void
    */
    public void goToTaskInvoiceView(){
        isBudgetView = false;

        //if(invoice.Id != null){
          //  Database.upsert(invoice);

          //  saveMilestones();
        //}
    }

    /*
    * Method Name: saveBudgetView
    * Description: Purpose to save budget view
    * @param: none
    * @return: PageReference
    */
    public PageReference saveBudgetView(){

    // Update or Insert Invoice Record
        Database.upsert(invoice);

        // Save Milestone list
        //ProjectInvoiceLine_TriggerHandler.skipMilestoneAmountValidation = true;  // 00007067 - skip milestone amount validation, only when specified
        saveMilestones();
        //ProjectInvoiceLine_TriggerHandler.skipMilestoneAmountValidation = false; // 00007067 - skip milestone amount validation, only when specified

        isEdit = false;

    // Refersh list
        Pagereference pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=true');
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: goToTaskBudgetView
    * Description: Purpose to go to task budget view
    * @param: none
    * @return: void
    */
    public void goToTaskBudgetView(){
        isBudgetView = true;
    }

    public List<BudgetCategory__c> listOfBudgetCategory {get; set;}
    public Map<Id, MilestoneWrapper> mapOfBudgetLineIdAndMilestones {get; set;}

    /*
    * Method Name: fetchBudgetingData
    * Description: Purpose to fetch budgeting data
    * @param: none
    * @return: void
    */
    private void fetchBudgetingData(){
        // Fetch Budget category list
        // Rajat/Ajay (01/31/2019 - Case 22166) - Added the logic to fetch the budget category List as per the Budget Version
        Project_Invoice_Line__c existingLine = new Project_Invoice_Line__c();
        if(isnew){
            listOfBudgetCategory = [SELECT Id, Name,
                                    (SELECT Id, Name, Billed_To_Date__c, BudgetCategory__c, NYSERDACost__c, Remaining_Budget__c,
                                     CostShare__c, Billed_To_Date_Cost_Share__c, Remaining_Budget_Cost_Share__c
                                     FROM Budget_Category_Lines__r
                                     ORDER BY CreatedDate asc)
                                    FROM BudgetCategory__c
                                    WHERE
                                    Budget_Detail__r.BudgetSummary__r.Project__c =:project.Id
                                    ORDER BY Sequence__c];
       }
       else {

           for(Project_Invoice_Line__c  proInvoiceLineRec: [Select id, Budget_Category_Line__r.BudgetCategory__r.Budget_Detail__r.id
                                                           from Project_Invoice_Line__c where Invoice__c =: invoice.Id
                                                           AND Budget_Category_Line__c != NULL Limit 1]){
               existingLine = proInvoiceLineRec;
           }

           listOfBudgetCategory= [SELECT Id, Name,
                                (SELECT Id, Name, Billed_To_Date__c, BudgetCategory__c, NYSERDACost__c, Remaining_Budget__c,
                                 CostShare__c, Billed_To_Date_Cost_Share__c, Remaining_Budget_Cost_Share__c
                                 FROM Budget_Category_Lines__r
                                 ORDER BY CreatedDate asc)
                                FROM BudgetCategory__c
                                WHERE Budget_Detail__c =: existingLine.Budget_Category_Line__r.BudgetCategory__r.Budget_Detail__C
                                ORDER BY Sequence__c
                                ];
       }

        mapOfBudgetLineIdAndMilestones = new Map<Id, MilestoneWrapper>();
        for(BudgetCategory__c budCat : listOfBudgetCategory){
            for(BudgetCategoryLine__c budCatLine : budCat.Budget_Category_Lines__r){
                mapOfBudgetLineIdAndMilestones.put(budCatLine.Id, new MilestoneWrapper(budCatLine));
                if(mapOfBCatLineIdAndProjInvLine.containsKey(budCatLine.Id)){
                    mapOfBudgetLineIdAndMilestones.get(budCatLine.Id).projectInvoiceLine.invoiceLineItem = mapOfBCatLineIdAndProjInvLine.get(budCatLine.Id);
                }
            }
        }
    }

    /*
    * Method Name: getProjectFunding
    * Description: Purpose to get project funding
    * @param: none
    * @return: Pagereference
    */
    public Pagereference getProjectFunding(){

        if(invoice.Project_Purchase_Order__c != null){
            Set<Id> invoiceLineIds = new Set<Id>();

            for(MilestoneWrapper tempMilestone : listOfMilestones){
                if(tempMilestone.projectInvoiceLine.invoiceLineItem.Id != null){
                    invoiceLineIds.add(tempMilestone.projectInvoiceLine.invoiceLineItem.Id);
                }
            }

            Map<Id, List<Project_Invoice_Distribution_Line__c>> invoiceDistributionMap =
                                                                new Map<Id, List<Project_Invoice_Distribution_Line__c>>();

      // Fetch Project Invoice Distribution line list
            for(Project_Invoice_Distribution_Line__c distribution : [SELECT Id, Project_Purchase_Order_Funding_Line__c, Amount__c,
                                                                     Project_Invoice_Line__c, Project_Invoice__c,
                                                                     Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Fund__c,
                                                                     Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Account_Number__c,
                                                                     Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Activity_ID__c,
                                                                     Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Project_ID__c,
                                                                     Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Department__c,
                                                                     Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Market_Focus__c,
                                                                     Project_Purchase_Order_Funding_Line__r.Name
                                                                     FROM Project_Invoice_Distribution_Line__c
                                                                     WHERE Project_Purchase_Order_Funding_Line__r.Project_Purchase_Order_Line__r.Project_Purchase_Order__c =: invoice.Project_Purchase_Order__c
                                                                     AND Project_Invoice_Line__c IN : invoiceLineIds]){
                if(!invoiceDistributionMap.containsKey(distribution.Project_Invoice_Line__c)){
                    invoiceDistributionMap.put(distribution.Project_Invoice_Line__c, new List<Project_Invoice_Distribution_Line__c>());
                }

                invoiceDistributionMap.get(distribution.Project_Invoice_Line__c).add(distribution);
            }

            List<Project_Purchase_Order_Funding_Line__c> fundingLines = new List<Project_Purchase_Order_Funding_Line__c>();

      // Fetch Project Purchase order funding lines
            for(Project_Purchase_Order_Funding_Line__c fundingLine : [SELECT Id, Name, Project_Funding__r.Fund__c, Project_Funding__r.Account_Number__c,
                                                                      Project_Funding__r.Activity_ID__c, Project_Funding__r.Project_ID__c, Project_Funding__r.Department__c,
                                                                      Project_Funding__r.Market_Focus__c FROM Project_Purchase_Order_Funding_Line__c
                                                                      WHERE Project_Purchase_Order_Line__r.Project_Purchase_Order__c =: invoice.Project_Purchase_Order__c]){

                fundingLines.add(fundingLine);
            }

            for(MilestoneWrapper tempMilestone : listOfMilestones){
                tempMilestone.projectInvoiceLine.distributions = new List<ProjectFundingDistributionWrapper>();

                Set<Id> fundingLineIds = new Set<Id>();

                if(tempMilestone.projectInvoiceLine.invoiceLineItem.Id != null &&
                   invoiceDistributionMap.containsKey(tempMilestone.projectInvoiceLine.invoiceLineItem.Id)
                   && invoiceDistributionMap.get(tempMilestone.projectInvoiceLine.invoiceLineItem.Id) != null){

                    for(Project_Invoice_Distribution_Line__c distribution : invoiceDistributionMap.get(tempMilestone.projectInvoiceLine.invoiceLineItem.Id)){

                        if(!fundingLineIds.contains(distribution.Project_Purchase_Order_Funding_Line__c)
                           && distribution.Project_Purchase_Order_Funding_Line__r != null
                           && distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r != null
                           && distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Fund__c != null){

                            fundingLineIds.add(distribution.Project_Purchase_Order_Funding_Line__c);

                            tempMilestone.projectInvoiceLine.distributions.add(new ProjectFundingDistributionWrapper(distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Fund__c,
                                                                                                                     distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Account_Number__c,
                                                                                                                     distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Activity_ID__c,
                                                                                                                     distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Project_ID__c,
                                                                                                                     distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Department__c,
                                                                                                                     distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Market_Focus__c,
                                                                                                                     distribution.Project_Purchase_Order_Funding_Line__r.Name, distribution));
                        }
                    }
                }

                for(Project_Purchase_Order_Funding_Line__c fundingLine : fundingLines){

                    if(!fundingLineIds.contains(fundingLine.Id)){
                        tempMilestone.projectInvoiceLine.distributions.add(new ProjectFundingDistributionWrapper(fundingLine.Project_Funding__r.Fund__c,
                                                                                                                 fundingLine.Project_Funding__r.Account_Number__c,
                                                                                                                 fundingLine.Project_Funding__r.Activity_ID__c,
                                                                                                                 fundingLine.Project_Funding__r.Project_ID__c,
                                                                                                                 fundingLine.Project_Funding__r.Department__c,
                                                                                                                 fundingLine.Project_Funding__r.Market_Focus__c,
                                                                                                                 fundingLine.Name,
                                                                                                                 new Project_Invoice_Distribution_Line__c(Project_Purchase_Order_Funding_Line__c = fundingLine.Id)));
                    }
                }

                if(tempMilestone.projectInvoiceLine.distributions.size() == 1){

                    tempMilestone.projectInvoiceLine.distributions[0].distribution.Amount__c = (tempMilestone.projectInvoiceLine.invoiceLineItem.Amount__c != null ? tempMilestone.projectInvoiceLine.invoiceLineItem.Amount__c : 0);
                }
            }
        }

        return null;
    }

    //Milestone Wrapper
    public class MilestoneWrapper{
        public InvoiceLineWrapper projectInvoiceLine{get;set;}
        public BudgetCategoryLine__c budgetCategoryLine {get; set;}
        /*public String purchaseOrder{get;set;}
        public Decimal totalDue{get;set;}
        public Date installationDate {get;set;}
        public Date utilityInterconnectDate{get;set;}
        public Date dateRange{get;set;}
        public Decimal actualKWH{get;set;}
        */
        public MilestoneWrapper(){
            projectInvoiceLine =  new InvoiceLineWrapper(new Project_Invoice_Line__c(Amount__c = 0, Amount_Cost_Share__c = 0),
                                                         new List<ProjectFundingDistributionWrapper>());
        }

        public MilestoneWrapper(BudgetCategoryLine__c bCatLine){
            budgetCategoryLine = bCatLine;
            if(bCatLine.Billed_To_Date__c == null)
                bCatLine.Billed_To_Date__c = 0;
            if(bCatLine.Billed_To_Date_Cost_Share__c == null)
                bCatLine.Billed_To_Date_Cost_Share__c = 0;

            projectInvoiceLine =  new InvoiceLineWrapper(new Project_Invoice_Line__c(Budget_Category_Line__c = bCatLine.Id, Is_Budget_Type__c = TRUE, Amount__c = 0, Amount_Cost_Share__c = 0),
                                                         new List<ProjectFundingDistributionWrapper>());
        }
    }

  // Wrapper class for Other document
    public class OtherDocument {

        public String documentId {get; set;}
        public String documentName {get; set;}
        public Attachment attach {get; set;}
        public Attachment recentAttach {get; set;}
        public String status {get; set;}

        public OtherDocument(String docId, String docName, Attachment attachRec, Attachment recentAttachRec, String docStatus) {
            documentId = docId;
            documentName = docName;
            attach = attachRec;
            recentAttach = recentAttachRec;
            status = docStatus;
        }
    }

  // Wrapper class for Invoice Line
    public class InvoiceLineWrapper{
        public Project_Invoice_Line__c invoiceLineItem {get; set;}

        public List<ProjectFundingDistributionWrapper> distributions{get; set;}

        public InvoiceLineWrapper(Project_Invoice_Line__c invoiceLineItem,
                                                 List<ProjectFundingDistributionWrapper> distributions){
            this.invoiceLineItem = invoiceLineItem;

            this.distributions = distributions;
        }
    }

  // Wrapper class for Project Funding Distribution Line
    public class ProjectFundingDistributionWrapper{
        public Project_Invoice_Distribution_Line__c distribution{get; set;}
        public String fund{get; set;}
        public String title{get; set;}
        public String header{get; set;}

        public ProjectFundingDistributionWrapper(String fund, String accountNumber, String activity, String projectID,
                                                 String department, String marketFocus, String poLineNumber,
                                                 Project_Invoice_Distribution_Line__c distribution){
            this.fund = fund;

            this.title = 'PO Line #: ' +  (poLineNumber != null ? poLineNumber : '') + '\n' +
                         'Account Number: ' +  (accountNumber != null ? accountNumber : '') + '\n' +
                         + 'Fund: ' +  (fund != null ? fund : '') + '\n' +
                         + 'Activity: ' +  (activity != null ? activity : '') + '\n' +
                         + 'Project ID: ' +  (projectID != null ? projectID : '') + '\n' +
                         + 'Department: ' +  (department != null ? department : '') + '\n' +
                         + 'Market Focus: ' +  (marketFocus != null ? marketFocus : '');

            this.header = 'Activity: ' +  (activity != null ? activity : '') + '<br/>' +
                           'Project ID: ' +  (projectID != null ? projectID : '') + '<br/>' +
                          'PO Line #: ' +  (poLineNumber != null ? poLineNumber : '');

            this.distribution = distribution;
        }
    }
}//EOF