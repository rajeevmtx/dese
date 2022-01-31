/*
*  Class Name: CORE_Milestone_Invoice_Controller
*  Description: Controller class for CORE_Milestone_Invoice_Page
*  Author/Date: Ashish Sharma, 4/20/2017 Original
*
* Date         New/Modified    User          Identifier                   Description
* 08/30/2017    Modified       Ajay Gautam   Case 00009596                Case 00009596 - Unable to submit GSHP Invoices
*
*/

public class CORE_Milestone_Invoice_Controller {

    private String description;
    private String flowSource;
    private Boolean isPartOfFlow;

    private ID milestoneRecordtypeId;
    private ID invoiceId;

    private static final String DESC_IDENTIFIER_BUDGET_INVOICE = 'BUDGET INVOICE LINE';

    private static final String INVOICE_PAGE = 'CORE_Milestone_Invoice_Page';
    private static final String DOCUMENT_PAGE = 'CORE_Milestone_Invoice_Documents_Page';
    private static final String ERR_MSG_UNAPPROVED_PROJECT = 'Can\'t submit Invoice for Unapproved Project.';
    private static final String MISSING_DOC_MESSAGE = 'Please upload the required documents.';
    private static final String ERR_MSG_EXCESS_AMOUNT = 'No amount left for invoice.';
    private static final String ERR_MSG_PENDING_APPROVAL = 'Your project does not allow multiple unapproved invoices.';

    public Map<Id, Project_Milestones__c> mapOfIdAndMilestone {get; set;}

    public String selectedInvoiceLine{get; set;}
    public List<Project_Invoice_Line_To_Classifications__c> selectedClassifications{get; set;}
    public Integer selectedClassificationIndex{get; set;}
    public boolean isSaved{get; set;}
    public boolean isError{get; set;}

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

    public Boolean isCurrentUserPM {get; set;}
    public Boolean isReadOnlyMode{get; set;}

    public Boolean isBudgetView {get; set;}
    public Boolean isInvoicingAllowed {get; set;}
    public Boolean isFirstInvoice {get; set;}
    public Boolean isNew {get; set;}
    public Boolean isEdit{get; set;}
    public Decimal invAmount {get; set;}
    public String pageErrorMessage {get; set;}

    public String mstTypeIncentive { get { return ProjectMilestones_Helper.MILESTONE_TYPE_NYSERDA_INCENTIVE; } }
    public Boolean isLocked { get{ return invoice.Status__c != ProjectInvoice_Helper.STATUS_DRAFT;} }
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
    public Boolean isDelinquentAccount {get; set;} //T-02786

    public List<OtherDocument> otherDocumentList {get; set;}
    public Integer rowNumber{get; set;}
    public List<SelectOption> purchaseOrderList {get;set;}
    public Boolean isApprovedPOExist {get; set;}
    public Decimal nyserdaIncentiveAmount {get; set;}
    public Decimal costIncentiveAmount {get; set;}

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

    //constructor
    public CORE_Milestone_Invoice_Controller(ApexPages.StandardController ctrl){
        flowSource = Apexpages.currentPage().getParameters().get('flow');
        isPartOfFlow = flowSource != null && flowSource != '';
        milestoneRecordtypeId = ProjectMilestones_Helper.ParentMilestoneRecordType.Id;
        selectedClassifications = new List<Project_Invoice_Line_To_Classifications__c>();
        isInvoicingAllowed = true;
        listOfMilestones = new List<MilestoneWrapper>();
        isSaved = false;
        isError = false;
        isPortalUser = currentUser.IsPortalEnabled;
        isEditMode = false;
        approvAllDoc = false;
        isFirstInvoice = true;
        nyserdaIncentiveAmount = 0;
        costIncentiveAmount = 0;
        isCurrentUserPM = false;

        if(ctrl.getId() == null){
            isNew = true;
            invoice = new Project_Invoice__c(Status__c = ProjectInvoice_Helper.STATUS_DRAFT);
            String pId = getParentId('Project__c');
            if(String.isNotBlank(pId)){
                fetchProject(pId);
                invoice = fetchInvoiceValues(invoice, pId);
            }
        }else{
            isNew = false;
            isEdit = false;
            invoiceId = ctrl.getId();
            fetchInvoice();
            fetchProject(invoice.Project__c);
            fetchDocuments();
            Set<Id> setOfMilestoneId = new Set<Id>();
            for(Project_Invoice_Line__c invLine : invoice.Project_Invoice_Lines__r){
                setOfMilestoneId.add(invLine.Milestone__c);
            }
            fetchDeliverables();
        }

		fetchPurchaseOrderList();

       /* Id zevRecordTypeId = Utility_RecordType_Helper.getRecordType('Project__c','Zero_Emission_Vehicles').Id;
        if(project.RecordTypeId != zevRecordTypeId) {
            fetchPurchaseOrderList();
        } */

        String isBudgetViewFlag = Apexpages.currentPage().getParameters().get('isBudgetView');

        if(isBudgetViewFlag != null && isBudgetViewFlag != '' && isBudgetViewFlag == 'false'){
            isBudgetView = false;
        }

        if(purchaseOrderList != null && purchaseOrderList.size() == 2){
            invoice.Project_Purchase_Order__c = purchaseOrderList.get(1).getValue();
        }

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
    * Method Name: fetchInvoiceValues
    * Description: Method to fetch invoice values
    * @param: Project_Invoice__c inv, Id pId
    * @return: Project_Invoice__c
    */
    private Project_Invoice__c fetchInvoiceValues(Project_Invoice__c inv, Id pId){

        for(Project_Role__c projRole : [SELECT Id, Contact__r.Name, Account__r.Name, Account__r.BillingCity, Account__r.BillingState,
                                        Account__r.BillingStreet, Account__r.BillingPostalCode, Account__r.Supplier_ID__c
                                        FROM Project_Role__c
                                        WHERE Project__c = :pId
                                        AND Role__c = :CORE_Deliverables_Helper.PROJECT_Contractor
                                        AND Primary_Customer_Contact__c = TRUE LIMIT 1]){
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
    * Description: Method to fetch Project
    * @param: Id pId
    * @return: void
    */

    private void fetchProject(Id pId){
        project = [SELECT Id, Name, Total_NYSERDA_Incentive_Amount__c, Status__c, Budget_Type__c, Total_Bill_To_Date_Amount__c, Contractor_to_Create_Invoices__c,
                   RecordType.Name, RecordTypeId, Total_NYSERDA_Task_Incentives__c,
                   Program_Version__r.Allow_Multiple_Invoices__c, Program_Version__r.Invoice_Type__c,
                   Program_Version__r.Enable_Cost_Share__c, Program_Version__r.Enable_Milestone_Quantity__c,
                   (SELECT Id, Status__c, Total_Amount_Due__c
                    FROM Project_Invoices__r WHERE Status__c NOT IN (:ProjectInvoice_Helper.STATUS_REJECTED)),
                    (SELECT Id, Name, Project__c, Status__c, PO_Status__c, NEIS_PO_ID__c
                        FROM Project_Purchase_Orders__r
                        WHERE PO_Status__c IN :Clean_Transportation_Helper.SET_PurchaseOrder_PO_STATUS_FOR_INVOICE),
                   (SELECT Company_Name__c, Email__c, FirstName__c,
                    LastName__c  FROM Project_Roles__r
                    WHERE Primary_Customer_Contact__c =: TRUE
                    AND Role__c = 'Customer' limit 1)
                   FROM Project__c
                   WHERE Id =:pId];


        if(project != null){
            if(invoice.Project__c == null){
                invoice.Project__c = project.Id;
            }
            Integer noOfApprovedInvoices = 0;
            for(Project_Invoice__c inv : project.Project_Invoices__r) {
                if(inv.Id != invoice.Id)
                    isFirstInvoice = false;
                if(inv.Status__c == ProjectInvoice_helper.STATUS_APPROVED || inv.Status__c == ProjectInvoice_helper.STATUS_SENT_TO_FINANCE){
                    noOfApprovedInvoices++;
                }else if(isNew && !project.Program_Version__r.Allow_Multiple_Invoices__c){
                    throwPageError(ERR_MSG_PENDING_APPROVAL);
                }
            }

            if(isPortalUser && !project.Contractor_to_Create_Invoices__c) {
              throwPageError(Label.CORE_Milestone_Invoice_Raise_Restrict_for_Contractor);
            }

            fetchMilestoneSelectOptions();
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

    private void checkForDelinquentAccount(){
    	isDelinquentAccount = false;

    	if(project != null){
		    	Project__c projRec = [Select Id,
		    							 (Select Id, Account__c, Account__r.Delinquent__c ,Role__c, Primary_Customer_Contact__c
		    										From Project_Roles__r
		    										WHERE Role__c ='Contractor' AND Primary_Customer_Contact__c = true)
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

    /*
    * Method Name: fetchPurchaseOrderList
    * Description: Method to fetch purchase order list
    * @param: None
    * @return: void
    */

    private void fetchPurchaseOrderList() {
        purchaseOrderList = new list<SelectOption>();
        isApprovedPOExist = false;
        if(project != null && project.Project_Purchase_Orders__r.size() > 0){
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

        if(!isApprovedPOExist) {
            throwPageError(System.Label.CORE_Invoice_Raise_Restrict_on_No_Open_PO_Msg);
        }

     checkForDelinquentAccount();
    }

    /*
    * Method Name: throwPageError
    * Description: Method to throw page error
    * @param: String errText
    * @return: void
    */

    private void throwPageError(String errText){
        isInvoicingAllowed = false;
        pageErrorMessage = errText;
    }

    public List<SelectOption> listOfProjectMilestoneSelectOptions {get; set;}

    public List<ID> listOfMilestoneIdsAvailable {get; set;}

    /*
    * Method Name: fetchMilestoneSelectOptions
    * Description: Method to fetch milestones
    * @param: None
    * @return: void
    */

    public void fetchMilestoneSelectOptions(){
        listOfProjectMilestoneSelectOptions = new List<SelectOption>();

        if(invoice.Project__c != null){
            mapOfIdAndMilestone = new Map<Id, Project_Milestones__c>();
            for(Project_Milestones__c mst : [SELECT Id, Name, Hybrid_Budget__c, Parent__r.Sequence__c, Sequence__c, Incentive_Amount__c, Status__c, Type__c, Parent__c, Recordtype.Name, Recordtype.DeveloperName, RecordTypeId, Project_Task__c, Cost_Share__c,
                                             Remaining_Budget__c, Billed_To_Date_Cost_Share__c, Remaining_Budget_Cost_Share__c, Billed_To_Date__c, Parent__r.Hybrid_Budget__c,
                                             Parent__r.Name, Parent__r.Incentive_Amount__c, Parent__r.Cost_Share__c,Project__r.Program_Version__r.Enable_Milestone_Quantity__c,
                                             Parent__r.Billed_To_Date__c, Parent__r.Enable_Task_Limit__c, Consumed_Quantity__c, Quantity__c,
                                             Parent__r.Billed_To_Date_Cost_Share__c, Parent__r.Remaining_Budget__c,Project__r.Status__c,
                                             Parent__r.Remaining_Budget_Cost_Share__c, Parent__r.Total_NYSERDA_Payment__c,
                                             Parent__r.NYSERDA_Cost__c FROM Project_Milestones__c
                                             WHERE Project__c = :invoice.Project__c
                                             ORDER BY Parent__r.Sequence__c, Sequence__c ASC]){
                                                 if(mst.Status__c == 'Approved'
                                                   && mst.RecordTypeId == ProjectMilestones_Helper.ChildMilestoneRecordType.Id
                                                   && ((!mst.Parent__r.Enable_Task_Limit__c && mst.Project__r.Program_Version__r.Enable_Milestone_Quantity__c && mst.Consumed_Quantity__c != Integer.valueOf(mst.Quantity__c))
                                                   || (mst.Parent__r.Enable_Task_Limit__c && mst.Incentive_Amount__c <= mst.Parent__r.Remaining_Budget__c)
                                                   || (!mst.Project__r.Program_Version__r.Enable_Milestone_Quantity__c && mst.Incentive_Amount__c <= mst.Remaining_Budget__c)
                                                   || invoice.Status__c == 'Pending Program Review')){
                                                     mapOfIdAndMilestone.put(mst.Id, mst);
                                                     listOfProjectMilestoneSelectOptions.add(new SelectOption(mst.Id, mst.Name));
                                                 }
                                             }
        }
    }

    /*
    * Method Name: fetchInvoice
    * Description: Method to fetch Invoice
    * @param: None
    * @return: void
    */

    private void fetchInvoice(){
        if(String.isNotBlank(invoiceId)){
            invoice = [SELECT Id, NAme,Purchase_Order__c , Project__c,Total_Retainage_Amount__c, Project__r.Name,
                       Project__r.Status__c,Project__r.RecordType.Name, Invoice_Date__c, Due_Date__c, Total_Amount_Due__c, Project__r.Budget_Type__c,
                       Company_Name__c, Contact_Name__c, Street__c, City__c, State__c, Zip__c, Invoice_Notes__c, Status__c,Final_Payment__c,
                       Project_Purchase_Order__c, Project_Purchase_Order__r.Name, Project_Purchase_Order__r.NEIS_PO_ID__c,
                       (SELECT Id, Name,Requesting__c ,Date_Range_End__c, Date_Range_Start__c ,Actual_kWh__c, Invoice__c, Description__c, Budget_Category_Line__c, Is_Budget_Type__c, Amount_Cost_Share__c,
                        Amount__c, Milestone__c, Milestone__r.Name, Milestone__r.Hybrid_Budget__c, Milestone__r.Parent__r.Hybrid_Budget__c, Milestone__r.Parent__r.Name,
                        Milestone__r.RecordType.Name, Milestone__r.RecordType.DeveloperName, Milestone__r.Incentive_Amount__c, Milestone__r.Type__c, Milestone__r.Parent__c, Milestone__r.Project_Task__c, Milestone__r.Cost_Share__c,
                        Milestone__r.Remaining_Budget__c, Milestone__r.Parent__r.Sequence__c, Milestone__r.Sequence__c, Milestone__r.Billed_To_Date_Cost_Share__c, Milestone__r.Remaining_Budget_Cost_Share__c, Milestone__r.Billed_To_Date__c,
                        Milestone__r.Parent__r.Incentive_Amount__c, Milestone__r.Parent__r.Cost_Share__c, Milestone__r.Parent__r.Billed_To_Date__c,
                        Quantity__c, Milestone__r.Consumed_Quantity__c, Milestone__r.Quantity__c, Milestone__r.Parent__r.Enable_Task_Limit__c,
                        Milestone__r.Parent__r.Billed_To_Date_Cost_Share__c, Milestone__r.Parent__r.Remaining_Budget__c, Milestone__r.Parent__r.Remaining_Budget_Cost_Share__c,
                        Milestone__r.Parent__r.Total_NYSERDA_Payment__c, Milestone__r.Parent__r.NYSERDA_Cost__c
                        FROM Project_Invoice_Lines__r ORDER BY Milestone__r.Parent__r.Sequence__c, Milestone__r.Sequence__c ASC)
                       FROM Project_Invoice__c WHERE Id = :invoiceId];
        }
    }

    /*
    * Method Name: fetchDocuments
    * Description: Method to fetch Documents
    * @param: None
    * @return: void
    */

    private void fetchDocuments(){
        listOfDocuments = new List<Project_Document__c>();
        if(invoice.Id != null){
            mapOfIdAndProjDoc = new Map<Id, Project_Document__c>([SELECT Id, Name, Project_Deliverables__c, Project__c, CreatedDate, (SELECT Id, Name FROM Attachments LIMIT 1) FROM Project_Document__c WHERE Invoice__c =:invoice.Id]);
            listOfDocuments = mapOfIdAndProjDoc.values();
        }
    }

    /*
    * Method Name: editAll
    * Description: Method to edit all
    * @param: None
    * @return: void
    */

    public void editAll(){
        isEdit = true;
    }

    /*
    * Method Name: editAllBudgetView
    * Description: Method for edit all and budget view
    * @param: None
    * @return: void
    */

    public void editAllBudgetView(){
        isEdit = true;
        isBudgetView = true;
    }


    /*
    * Method Name: cancelChanges
    * Description: Method to cancel the changes
    * @param: None
    * @return: Pagereference
    */

    public Pagereference cancelChanges() {
        Pagereference pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=false');
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: cancelChangesBudget
    * Description: Method to cancel budget changes
    * @param: None
    * @return: Pagereference
    */

    public Pagereference cancelChangesBudget() {
        Pagereference pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=true');
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: goToDocumentsPage
    * Description: Method to go to documents page
    * @param: None
    * @return: Pagereference
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
    * Method Name: saveInvoiceRecord
    * Description: Method to save invoice record
    * @param: None
    * @return: Pagereference
    */

    public Pagereference saveInvoiceRecord(){
        Pagereference pg;
        try{

            Database.upsert(invoice);

            if(invoice.id != null){

                saveMilestones();

                if(invoice.Project_Purchase_Order__c != null && !isPortalUser){

                    List<Project_Invoice_Distribution_Line__c> distributionsToUpsert = new List<Project_Invoice_Distribution_Line__c>();

                    for(MilestoneWrapper tempMilestone : listOfMilestones){
                      for(InvoiceLineWrapper projectInvoiceLine : tempMilestone.projectInvoiceLines){
                        if(projectInvoiceLine.distributions != null &&
                             projectInvoiceLine.distributions.size() > 0){

                              for(ProjectFundingDistributionWrapper tempFunding : projectInvoiceLine.distributions){

                                  if(projectInvoiceLine.invoiceLineItem.Id != null && tempFunding.distribution.Project_Invoice_Line__c == null){
                                      tempFunding.distribution.Project_Invoice_Line__c = projectInvoiceLine.invoiceLineItem.Id;
                                  }

                                  if(invoice.Id != null && tempFunding.distribution.Project_Invoice__c == null){
                                      tempFunding.distribution.Project_Invoice__c = invoice.Id;
                                  }

                                  distributionsToUpsert.add(tempFunding.distribution);
                              }
                          }
                      }
                    }

                    if(distributionsToUpsert.size() > 0){
                        upsert distributionsToUpsert;
                    }
                }

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
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return pg;
    }

    /*
    * Method Name: updateListOfMilestones
    * Description: Method to update List Of Milestones
    * @param: None
    * @return: void
    */

    public void updateListOfMilestones(){
        for(MilestoneWrapper mst : listOfMilestones){
          for(InvoiceLineWrapper projectInvoiceLine : mst.projectInvoiceLines){
            projectInvoiceLine.invoiceLineItem.Amount__c = mapOfIdAndMilestone.get(projectInvoiceLine.invoiceLineItem.Milestone__c).Incentive_Amount__c;
          }
        }
    }

    /*
    * Method Name: saveMilestones
    * Description: Method to save Milestones
    * @param: None
    * @return: void
    */

    public void saveMilestones(){
      system.debug('-------'+listOfMilestones);
        List<Project_Invoice_Line__c> listToUpdate = new List<Project_Invoice_Line__c>();
        List<Project_Milestones__c> listOfMilestoneToUpdate = new List<Project_Milestones__c>();

        for(MilestoneWrapper mst : listOfMilestones){
          for(InvoiceLineWrapper projectInvoiceLine : mst.projectInvoiceLines){
            if(projectInvoiceLine.invoiceLineItem.Milestone__c != null){
                  if(projectInvoiceLine.invoiceLineItem.Invoice__c == null)
                     projectInvoiceLine.invoiceLineItem.Invoice__c = invoice.Id;

                  projectInvoiceLine.invoiceLineItem.Amount__c = mapOfIdAndMilestone.get(projectInvoiceLine.invoiceLineItem.Milestone__c).Incentive_Amount__c *
                                                                 projectInvoiceLine.invoiceLineItem.Quantity__c;

                  listToUpdate.add(projectInvoiceLine.invoiceLineItem);
              }
          }
        }

        if(listToUpdate.size() > 0){
            Database.upsert(listToUpdate);
        }

        fetchInvoice();
    }

    /*
    * Method Name: submitForReview
    * Description: Method to submit for review
    * @param: None
    * @return: PageReference
    */

    public PageReference submitForReview(){
        Pagereference pg;
        if(isSubmissionAllowed()){
          if(invoice.Id <> null){
              Decimal totalLineItemCostShare = 0;

            for(MilestoneWrapper tempMilestone : listOfMilestones){
          for(InvoiceLineWrapper projectInvoiceLine : tempMilestone.projectInvoiceLines){
            if(projectInvoiceLine != null &&
                   projectInvoiceLine.invoiceLineItem != null &&
                   projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c != null){

                  totalLineItemCostShare += projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c;
                }
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

           /* if(ProjectInvoice_Helper.SET_OF_PROJECT_RCD_TYPE_ID_FOR_PENDINGREVIEW_MILESTONE_INVOICES.contains(project.RecordTypeId)) {
              invoice.Status__c = ProjectInvoice_Helper.STATUS_PENDING_REVIEW; // Case: 00009596 - Ajay Gautam (08/30)
            } else {
              invoice.Status__c = ProjectInvoice_Helper.STATUS_SUBMITTED;
            } */

            invoice.Status__c = ProjectInvoice_Helper.STATUS_SUBMITTED;
            invoice.Due_Date__c = System.today() + 30;
            invoice.Invoice_Date__c = System.today();
            Database.update(invoice);

            Set<Id> projectMilestoneIds = new Set<Id>();

          for(MilestoneWrapper mst : listOfMilestones){
            for(InvoiceLineWrapper projectInvoiceLine : mst.projectInvoiceLines){
              if(projectInvoiceLine.invoiceLineItem.Milestone__c != null){
                    projectMilestoneIds.add(projectInvoiceLine.invoiceLineItem.Milestone__c);
                }
            }
          }

          Set<String> invalidStatus = new Set<String>{'Draft', 'Rejected', 'Cancelled'};

            if(projectMilestoneIds.size() > 0){
              List<Project_Milestones__c> listOfMilestoneToUpdate = new List<Project_Milestones__c>();

            for(Project_Milestones__c tempProMilestone : [SELECT Id, Legacy_Billed_To_Date__c, Legacy_Billed_To_Date_Cost_Share__c,
                                       (SELECT Id, Amount__c, Amount_Cost_Share__c, Quantity__c
                                                            FROM Project_Invoice_Lines__r
                                                             WHERE Invoice__r.Status__c NOT IN : invalidStatus)
                                                        FROM Project_Milestones__c
                                 WHERE ID IN : projectMilestoneIds]){

            Decimal totalBilledToDate = 0;
            Decimal totalBilledToDateCostShare = 0;
            Decimal totalQuantity = 0;
            Decimal legacyBilledToDate = (tempProMilestone.Legacy_Billed_To_Date__c != null) ? tempProMilestone.Legacy_Billed_To_Date__c : 0;
              Decimal legacyBilledToDateCostShare = (tempProMilestone.Legacy_Billed_To_Date_Cost_Share__c != null) ? tempProMilestone.Legacy_Billed_To_Date_Cost_Share__c : 0;

            for(Project_Invoice_Line__c tempInvoiceLine : tempProMilestone.Project_Invoice_Lines__r){
              totalBilledToDate += (tempInvoiceLine.Amount__c != null) ? tempInvoiceLine.Amount__c : 0;
              totalBilledToDateCostShare += (tempInvoiceLine.Amount_Cost_Share__c != null) ? tempInvoiceLine.Amount_Cost_Share__c : 0;
              totalQuantity += (tempInvoiceLine.Quantity__c != null) ? tempInvoiceLine.Quantity__c : 0;
            }

            listOfMilestoneToUpdate.add(new Project_Milestones__c(Id = tempProMilestone.Id,
                                          Billed_To_Date__c = (totalBilledToDate + legacyBilledToDate),
                                        Billed_To_Date_Cost_Share__c = (totalBilledToDateCostShare + legacyBilledToDateCostShare),
                                        Consumed_Quantity__c = totalQuantity));
        }

        if(listOfMilestoneToUpdate.size() > 0){
                Database.update(listOfMilestoneToUpdate);
        }
          }

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
    * Description: Method to get ParentId
    * @param: String objectName
    * @return: String
    */

    private String getParentId(String objectName){
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



    @RemoteAction

    /*
    * Method Name: fetchListOfProjects
    * Description: Method to fetch List Of Projects
    * @param: String searchText
    * @return: static List<Project__c>
    */

    public static List<Project__c> fetchListOfProjects(String searchText){
        return [SELECT Id, Name FROM Project__c WHERE Name LIKE :searchText+'%' LIMIT 20];
    }

    private Map<Id, Project_Invoice_Line__c> mapOfBCatLineIdAndProjInvLine;

    /*
    * Method Name: getPrepopulatedMilestones
    * Description: Method to get Prepopulated Milestones
    * @param: List<Project_Invoice_Line__c> localListOfInvoices
    * @return: void
    */

    private void getPrepopulatedMilestones(List<Project_Invoice_Line__c> localListOfInvoices){
        MilestoneWrapper milestone;
        mapOfBCatLineIdAndProjInvLine = new Map<Id, Project_Invoice_Line__c>();
        system.debug('--------'+localListOfInvoices.size());
        if(listOfMilestones!=null && localListOfInvoices.size() > 0){
          Map<Id, Project_Milestones__c> milestoneIdMap = new Map<Id, Project_Milestones__c>();
          Map<Id, List<Project_Invoice_Line__c>> milestoneIdInvoiceMap = new Map<Id, List<Project_Invoice_Line__c>>();

            for(Project_Invoice_Line__c invoiceLine : localListOfInvoices){
                if(invoiceLine.Budget_Category_Line__c == null && invoiceLine.Milestone__r.Parent__c != null){

                    if(!milestoneIdInvoiceMap.containsKey(invoiceLine.Milestone__r.Parent__c)){
                      milestoneIdInvoiceMap.put(invoiceLine.Milestone__r.Parent__c, new List<Project_Invoice_Line__c>());
                    }

                    milestoneIdInvoiceMap.get(invoiceLine.Milestone__r.Parent__c).add(invoiceLine);

                    milestoneIdMap.put(invoiceLine.Milestone__r.Parent__c, invoiceLine.Milestone__r.Parent__r);
                }
            }
            system.debug('--------'+milestoneIdInvoiceMap);
            system.debug('--------'+milestoneIdMap);
            for(Id milestoneId : milestoneIdMap.keySet()){
              milestone = new MilestoneWrapper();
              milestone.parentMilestone = milestoneIdMap.get(milestoneId);

              for(Project_Invoice_Line__c invoiceLine : milestoneIdInvoiceMap.get(milestoneId)){
                if(invoiceLine.Milestone__r.Consumed_Quantity__c == null){
                    invoiceLine.Milestone__r.Consumed_Quantity__c = 0;
                  }

                  if(invoiceLine.Quantity__c == null || (!project.Program_Version__r.Enable_Milestone_Quantity__c)){
                    invoiceLine.Quantity__c = 1;
                    invoiceLine.Amount__c = invoiceLine.Milestone__r.Incentive_Amount__c;
                  }

                  List<SelectOption> availableQuantities = new List<SelectOption>();

                  availableQuantities.add(new SelectOption(0 + '', 'None'));

                  if((!project.Program_Version__r.Enable_Milestone_Quantity__c)){
                    availableQuantities.add(new SelectOption('1', '1'));
                  }

                  if(invoiceLine.Milestone__r.Quantity__c == 'No Limit'){
                    for(Integer i=1; i<=20; i++){
                      availableQuantities.add(new SelectOption(i + '', i + ''));
                    }
                  }else if(invoiceLine.Milestone__r.Quantity__c != 'No Limit' && invoiceLine.Milestone__r.Quantity__c != null && (Integer.valueOf(invoiceLine.Milestone__r.Quantity__c) > invoiceLine.Milestone__r.Consumed_Quantity__c)
                           && invoiceLine.Milestone__r.Quantity__c != null){

                    for(Integer i=1; i<=(Integer.valueOf(invoiceLine.Milestone__r.Quantity__c)-invoiceLine.Milestone__r.Consumed_Quantity__c); i++){
                      availableQuantities.add(new SelectOption(i + '', i + ''));
                    }
                  }

                milestone.projectInvoiceLines.add(new InvoiceLineWrapper(invoiceLine, new List<ProjectFundingDistributionWrapper>(), availableQuantities));
              }
              system.debug('--------'+milestone);
              listOfMilestones.add(milestone);
            }
        }else{
          Map<Id, Project_Milestones__c> milestoneIdMap = new Map<Id, Project_Milestones__c>();
          Map<Id, List<Project_Invoice_Line__c>> milestoneIdInvoiceMap = new Map<Id, List<Project_Invoice_Line__c>>();

            for(Project_Milestones__c mst : mapOfIdAndMilestone.values()){
              if(!milestoneIdInvoiceMap.containsKey(mst.Parent__c)){
                  milestoneIdInvoiceMap.put(mst.Parent__c, new List<Project_Invoice_Line__c>());
                }

                if((!project.Program_Version__r.Enable_Milestone_Quantity__c)){
                  milestoneIdInvoiceMap.get(mst.Parent__c).add(new Project_Invoice_Line__c(Milestone__c = mst.id, Amount__c = mst.Incentive_Amount__c, Milestone__r = mst, Quantity__c = 1));
                }else{
                  milestoneIdInvoiceMap.get(mst.Parent__c).add(new Project_Invoice_Line__c(Milestone__c = mst.id, Amount__c = 0, Milestone__r = mst));
                }

                milestoneIdMap.put(mst.Parent__c, mst.Parent__r);
            }
            system.debug('--------'+milestoneIdInvoiceMap);
            system.debug('--------'+milestoneIdMap);
            for(Id milestoneId : milestoneIdMap.keySet()){
              milestone = new MilestoneWrapper();
              milestone.parentMilestone = milestoneIdMap.get(milestoneId);

              for(Project_Invoice_Line__c invoiceLine : milestoneIdInvoiceMap.get(milestoneId)){
                Project_Milestones__c mst = mapOfIdAndMilestone.get(invoiceLine.Milestone__c);

                if(mst.Consumed_Quantity__c == null){
                      mst.Consumed_Quantity__c = 0;
                  }

                  List<SelectOption> availableQuantities = new List<SelectOption>();

                  availableQuantities.add(new SelectOption(0 + '', 'None'));

                  if((!project.Program_Version__r.Enable_Milestone_Quantity__c)){
                    availableQuantities.add(new SelectOption('1', '1'));
                  }

                  if(mst.Quantity__c == 'No Limit'){
                    for(Integer i=1; i<=20; i++){
                      availableQuantities.add(new SelectOption(i + '', i + ''));
                    }
                  }else if(mst.Quantity__c != 'No Limit' && mst.Quantity__c != null && (Integer.valueOf(mst.Quantity__c) > mst.Consumed_Quantity__c)
                           && mst.Quantity__c != null){

                    for(Integer i=1; i<=(Integer.valueOf(mst.Quantity__c)-mst.Consumed_Quantity__c); i++){
                      availableQuantities.add(new SelectOption(i + '', i + ''));
                    }
                  }

                milestone.projectInvoiceLines.add(new InvoiceLineWrapper(invoiceLine, new List<ProjectFundingDistributionWrapper>(), availableQuantities));
              }

              listOfMilestones.add(milestone);
            }
        }
    }

    public Map<Id, Boolean> mapOfDeliverableIdAndRequiredStatus {get; set;}
    public Map<Id, Project_Deliverables__c> mapOfIdAndDeliverables {get; set;}
    public Map<Id, Project_Document__c> mapOfIdAndDocuments {get; set;}
    public List<Project_Milestones__c> listOfProjectMilestones {get; set;}
    public Map<Id, Attachment> mapOfDeliverableIdAndAttachment {get; set;}

    /*
    * Method Name: fetchDeliverables
    * Description: Method to fetch Deliverables
    * @param: None
    * @return: void
    */

    public void fetchDeliverables(){

        listOfProjectMilestones = new List<Project_Milestones__c>();
        mapOfDeliverableIdAndRequiredStatus = new Map<Id, Boolean>();
        mapOfDeliverableIdAndAttachment = new Map<Id, Attachment>();
        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>();
        mapOfIdAndDocuments = new Map<Id, Project_Document__c>();

        Set<Id> setOfProjectMilestones = new Set<Id>();


        for(Project_Invoice_Line__c invoiceLine : invoice.Project_Invoice_Lines__r){
            setOfProjectMilestones.add(invoiceLine.Milestone__c);
        }


        Boolean isRequiredLocal = false;
        for(Project_Milestones__c milestone : [SELECT Id, Name, Incentive_Amount__c, (SELECT Id, Name, Mandatory_by_Default__c,Project__r.Name, Conditionally_Required__c, Validation_Logic__c, Status__C FROM Project_Deliverables1__r) FROM Project_Milestones__c WHERE ID IN :setOfProjectMilestones]){
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

        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>([SELECT Id, Name, Status__c, CreatedDate,
                                                                      (SELECT Id, Name , Version__c, Status__c, Invoice__c, Notes__c, CreatedDate, CreatedBy.Name FROM Project_Documents__r WHERE Invoice__c =: invoice.Id ORDER BY CreatedDate desc)
                                                                      FROM Project_Deliverables__c
                                                                      WHERE Project__c =: invoice.Project__c
                                                                      AND Project_Milestone__c = null
                                                                      AND Project_Invoice__c =: invoice.Id]);

        mapOfIdAndDocuments = new Map<Id, Project_Document__c>();

        mapOfIdAndDocuments = new Map<Id,Project_Document__c>([SELECT Id, Name, Project_Deliverables__c, Version__c, Status__c, CreatedDate, CreatedBy.Name, Notes__c,
                                                              (SELECT Id, Name, BodyLength FROM Attachments LIMIT 1)
                                                              FROM Project_Document__c
                                                              WHERE Project_Deliverables__c IN :mapOfIdAndDeliverables.keySet()
                                                              AND Invoice__c =: invoice.Id]);

        List<Project_Deliverables__c> tempDeliverablesList = new List<Project_Deliverables__c>();

        otherDocumentList = new List<OtherDocument>();

        Map<String, Attachment> otherProjectDeliverablesIdToAttachmentRecMap = new Map<String, Attachment>();

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

        isAllDeliverablesApproved = true;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c != 'Approve') {
                isAllDeliverablesApproved = false;
                break;
            }
        }

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
    * Description: Method to save Other Documents Before Add More
    * @param: None
    * @return: PageReference
    */

    public PageReference saveOtherDocumentsBeforeAddMore() {
        saveDocuments();

        return goToDocumentsPage();
    }

    /*
    * Method Name: getAttachmentList
    * Description: Method to get Attachment List
    * @param: List<Project_Deliverables__c> projectDeliverablesList, Id invoiceId
    * @return: static Map<String, Attachment>
    */

    public static Map<String, Attachment> getAttachmentList(List<Project_Deliverables__c> projectDeliverablesList, Id invoiceId) {
        List<Project_Document__c> documentList = [SELECT Id, Name, Project_Deliverables__c, (SELECT Id, Name FROM Attachments)
                                                  FROM Project_Document__c
                                                  WHERE Project_Deliverables__c IN: projectDeliverablesList
                                                  AND Invoice__c =: invoiceId Order by Version__c DESC nulls last];

        List<Attachment> attachmentList = new List<Attachment>();
        Map<String, Attachment> projDeliverablesIdToAttachmentRecMap = new Map<String, Attachment>();

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
    * Method Name: fetchCostShareClassification
    * Description: Method to fetch Cost Share Classification
    * @param: None
    * @return: void
    */

    public void fetchCostShareClassification(){
      isSaved = false;
      isError = false;

      selectedClassifications = new List<Project_Invoice_Line_To_Classifications__c>();

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
    * Description: Method to add new Classification
    * @param: None
    * @return: void
    */

    public void addNewClassification(){
      selectedClassifications.add(new Project_Invoice_Line_To_Classifications__c(
                            Project_Invoice_Line__c = selectedInvoiceLine));
    }

    /*
    * Method Name: removeClassification
    * Description: Method to remove Classification
    * @param: None
    * @return: void
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
    * Description: Method to save Cost Sharing Classification
    * @param: None
    * @return: Pagereference
    */

    public Pagereference saveCostSharingClassification(){
      if(selectedClassifications.size() > 0){

        Decimal totalLineItemCostShare = 0;

          for(MilestoneWrapper tempMilestone : listOfMilestones){
            for(InvoiceLineWrapper projectInvoiceLine : tempMilestone.projectInvoiceLines){
              if(projectInvoiceLine != null &&
                 projectInvoiceLine.invoiceLineItem != null &&
                 projectInvoiceLine.invoiceLineItem.Id == selectedInvoiceLine &&
                 projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c != null){

                  totalLineItemCostShare += projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c;
              }
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
    * Method Name: addDocumentInOtherDocumentList
    * Description: Method to add document in other document list
    * @param: None
    * @return: Pagereference
    */

    public PageReference addDocumentInOtherDocumentList() {
        for(Integer i=0; i<10; i++){
            otherDocumentList.add(new OtherDocument(null, '', new Attachment(), new Attachment(), ''));
        }

        return null;
    }

    /*
    * Method Name: removeDocumentFromList
    * Description: Method to remove document from list
    * @param: None
    * @return: Pagereference
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
    * Description: Method to save documents
    * @param: None
    * @return: Pagereference
    */

    public PageReference saveDocuments(){
       /* List<Project_Document__c> listOfProjectDocumentToInsert = new List<Project_Document__c>();
        List<Attachment> listOfAttachmentToUpsert = new List<Attachment>();
        Savepoint sp = Database.setSavepoint();
        Project_Document__c localDoc;*/
        try{
            /*for(Id dId : mapOfDeliverableIdAndAttachment.keySet()){
                if(mapOfDeliverableIdAndAttachment.get(dId).Body != null){
                    localDoc = new Project_Document__c();
                    localDoc.Name = mapOfIdAndDeliverables.get(dId).Name;
                    localDoc.Project__c = invoice.Project__c;
                    localDoc.Invoice__c = invoice.Id;
                    localDoc.Project_Deliverables__c = dId;
                    localDoc.Version__c = mapOfIdAndDeliverables.get(dId).Project_Documents__r.size() + 1;
                    listOfProjectDocumentToInsert.add(localDoc);
                }
            }

            Database.insert(listOfProjectDocumentToInsert);
            Attachment localAtt;
            for(Project_Document__c doc : listOfProjectDocumentToInsert){
                if(mapOfDeliverableIdAndAttachment.containsKey(doc.Project_Deliverables__c)){
                    localAtt = mapOfDeliverableIdAndAttachment.get(doc.Project_Deliverables__c);
                    localAtt.ParentId = doc.Id;
                    listOfAttachmentToUpsert.add(localAtt);
                }
            }
            Database.upsert(listOfAttachmentToUpsert);*/

            List<Project_Deliverables__c> projDeliverablesList = new List<Project_Deliverables__c>();

            List<OtherDocument> validOtherDocumentsList = new List<OtherDocument>();

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

            if(documentListToInsert.size() > 0) {
                upsert documentListToInsert;
            }

            if(attachmentListToInsert.size() > 0) {
                for(Integer i = 0; i < documentListToInsert.size(); i++) {
                    attachmentListToInsert[i].ParentId = documentListToInsert[i].Id;
                }
                insert attachmentListToInsert;
            }

            if(documentListToUpdate.size() > 0) {
                upsert documentListToUpdate;
            }

            fetchDeliverables();
            return goToDocumentsPage();
        }catch(Exception e){
            throw e;
        }
        return null;
    }

    /*
    * Method Name: setEditMode
    * Description: Method to set edit mode
    * @param: None
    * @return: Pagereference
    */

    public PageReference setEditMode() {
        isEditMode = true;
        fetchDeliverables();
        return null;
    }

    /*
    * Method Name: cancelChangesOfApprovalProcess
    * Description: Method to cancel changes of approval process
    * @param: None
    * @return: Pagereference
    */

    public PageReference cancelChangesOfApprovalProcess() {
        fetchDeliverables();
        isEditMode = false;
        return null;
    }

    /*
    * Method Name: getStatus
    * Description: Method to get Status
    * @param: None
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
    * Description: Method to set status of project documents
    * @param: None
    * @return: Pagereference
    */
    public Pagereference setStatusOfProjectDocuments() {
        List<Project_Document__c> docListToUpdate = new List<Project_Document__c>();
        List<Project_Deliverables__c> projDeliverablesListToUpdate = new List<Project_Deliverables__c>();

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

        if(docListToUpdate.size() > 0) {
            update docListToUpdate;
        }

        if(projDeliverablesListToUpdate.size() > 0) {
            update projDeliverablesListToUpdate;
        }

        isAllDeliverablesApproved = true;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c != 'Approve') {
                isAllDeliverablesApproved = false;
                break;
            }
        }

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
    * Description: Method to set invoice status
    * @param: None
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
            pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=false&invoiceStatus=' + invoiceStatus);
            pg.setRedirect(true);
        }
        return pg;
    }

    /*
    * Method Name: updateProjectInvoiceLine
    * Description: Method to update project invoice line
    * @param: None
    * @return: void
    */

    private void updateProjectInvoiceLine() {
        Set<Id> milestoneIdSet = new Set<Id>();
        for(MilestoneWrapper milestoneRec : listOfMilestones) {
            milestoneIdSet.add(milestoneRec.parentMilestone.Id);
        }

        Map<Id, Project_Milestones__c> projectMilestoneMap = new Map<Id, Project_Milestones__c>([SELECT Billed_To_Date__c, Billed_To_Date_Cost_Share__c
                                                                                                 FROM   Project_Milestones__c
                                                                                                 WHERE  Id IN: milestoneIdSet]);

        List<Project_Milestones__c> projectMilestoneList = new List<Project_Milestones__c>();
        for(MilestoneWrapper milestoneRec : listOfMilestones) {
          for(InvoiceLineWrapper projectInvoiceLine : milestoneRec.projectInvoiceLines){
            Decimal amount = 0;
              Decimal costShare = 0;
              if(projectInvoiceLine.invoiceLineItem != null) {
                  amount = (projectInvoiceLine.invoiceLineItem.Amount__c != null?
                                            projectInvoiceLine.invoiceLineItem.Amount__c : 0);
                  amount += ((projectMilestoneMap.containsKey(projectInvoiceLine.invoiceLineItem.Milestone__c)
                                && projectMilestoneMap.get(projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date__c != null) ?
                              projectMilestoneMap.get(projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date__c : 0);
              }
              if(projectInvoiceLine.invoiceLineItem != null) {
                  costShare = (projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c != null?
                                            projectInvoiceLine.invoiceLineItem.Amount_Cost_Share__c : 0);
                  costShare += ((projectMilestoneMap.containsKey(projectInvoiceLine.invoiceLineItem.Milestone__c)
                                && projectMilestoneMap.get(projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date_Cost_Share__c != null) ?
                              projectMilestoneMap.get(projectInvoiceLine.invoiceLineItem.Milestone__c).Billed_To_Date_Cost_Share__c : 0);
              }
              Project_Milestones__c proMilestoneRec = new Project_Milestones__c(Id = projectInvoiceLine.invoiceLineItem.Milestone__c);
              proMilestoneRec.Billed_To_Date__c = amount;
              proMilestoneRec.Billed_To_Date_Cost_Share__c = costShare;
              projectMilestoneList.add(proMilestoneRec);
          }
        }

        if(projectMilestoneList.size() > 0) {
            update projectMilestoneList;
        }
    }

    /*
    * Method Name: isRequiredDocumentMissing
    * Description: Method to check missing required document
    * @param: None
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
    * Description: Method for Allowed Submission
    * @param: None
    * @return: Boolean
    */

    private Boolean isSubmissionAllowed(){
        if(isRequiredDocumentMissing()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MISSING_DOC_MESSAGE));
            return false;
        //}else if(invoice.Project__r.Status__c != Project_Helper.PROJECT_STATUS_APPROVED){
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MSG_UNAPPROVED_PROJECT));
            //return false;
        }else if(hasExcessAmount()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MSG_EXCESS_AMOUNT));
            return false;
        }

        return true;
    }

    /*
    * Method Name: hasExcessAmount
    * Description: Method to check excess amount
    * @param: None
    * @return: Boolean
    */

    private Boolean hasExcessAmount() {
      Map<Id,Project_Invoice_Line__c> milestoneInvoiceMap = new Map<Id,Project_Invoice_Line__c>();

    for(MilestoneWrapper tempMilestone : listOfMilestones){
          for(InvoiceLineWrapper projectInvoiceLine : tempMilestone.projectInvoiceLines){
            if(projectInvoiceLine.invoiceLineItem.Milestone__r.Quantity__c != 'No Limit'){
              if(projectInvoiceLine.invoiceLineItem.Id != null) {
                if(projectInvoiceLine.invoiceLineItem.Milestone__r.Remaining_Budget__c < projectInvoiceLine.invoiceLineItem.Amount__c) {
              return true;
                }
                  }
            }else{
              milestoneInvoiceMap.put(projectInvoiceLine.invoiceLineItem.Milestone__c, projectInvoiceLine.invoiceLineItem);
            }
          }
        }

        if(milestoneInvoiceMap.size() > 0){
          Map<Id, Decimal> childMilestoneTotalMap = new Map<Id, Decimal>();
          Map<Id, Decimal> parentMilestoneRemainingBudgetMap = new Map<Id, Decimal>();
          Map<Id, Id> childParentMilestoneIdMap = new Map<Id, Id>();

          for(Project_Milestones__c milestone : [SELECT Id, Remaining_Budget__c,
                               Quantity__c, Parent__c, Parent__r.Enable_Task_Limit__c,
                               Parent__r.Remaining_Budget__c
                               FROM Project_Milestones__c
                               WHERE Id IN : milestoneInvoiceMap.keySet()]){

                  if(milestone.Parent__c != null && milestone.Parent__r.Enable_Task_Limit__c){

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

          if(childMilestoneTotalMap.size() > 0){
            for(Project_Invoice_Line__c invoiceLine : milestoneInvoiceMap.values()){
              if(childParentMilestoneIdMap.containsKey(invoiceLine.Milestone__c) &&
                 childParentMilestoneIdMap.get(invoiceLine.Milestone__c) != null &&
                 childMilestoneTotalMap.containsKey(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) &&
                 childMilestoneTotalMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) != null &&
                 parentMilestoneRemainingBudgetMap.containsKey(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) &&
                 parentMilestoneRemainingBudgetMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)) != null &&
                 parentMilestoneRemainingBudgetMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)).setScale(2) <
                        childMilestoneTotalMap.get(childParentMilestoneIdMap.get(invoiceLine.Milestone__c)).setScale(2)){

                return true;
              }
            }
          }
        }

        return false;
    }

    /*
    * Method Name: goToMainInvoicePage
    * Description: Method for go to main invoice page
    * @param: None
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
    * Description: Method for go to task invoice view
    * @param: None
    * @return: void
    */

    public void goToTaskInvoiceView(){
        isBudgetView = false;

        //if(invoice.Id != null){
            Database.upsert(invoice);

            saveMilestones();
        //}
    }

    /*
    * Method Name: saveBudgetView
    * Description: Method to save budget view
    * @param: None
    * @return: PageReference
    */

    public PageReference saveBudgetView(){
        Database.upsert(invoice);

        saveMilestones();

        isEdit = false;

        Pagereference pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id + '&isBudgetView=true');
        pg.setRedirect(true);
        return pg;
    }

    /*
    * Method Name: goToTaskBudgetView
    * Description: Method for go to task budget view
    * @param: None
    * @return: void
    */

    public void goToTaskBudgetView(){
        isBudgetView = true;
    }

    /*
    * Method Name: getProjectFunding
    * Description: Method to get project funding
    * @param: None
    * @return: Pagereference
    */

    public Pagereference getProjectFunding(){

        if(invoice.Project_Purchase_Order__c != null){
            Set<Id> invoiceLineIds = new Set<Id>();

            for(MilestoneWrapper tempMilestone : listOfMilestones){
              for(InvoiceLineWrapper projectInvoiceLine : tempMilestone.projectInvoiceLines){
                if(projectInvoiceLine.invoiceLineItem.Id != null){
                      invoiceLineIds.add(projectInvoiceLine.invoiceLineItem.Id);
                  }
              }
            }

            Map<Id, List<Project_Invoice_Distribution_Line__c>> invoiceDistributionMap =
                                                                new Map<Id, List<Project_Invoice_Distribution_Line__c>>();

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

            for(Project_Purchase_Order_Funding_Line__c fundingLine : [SELECT Id, Name, Project_Funding__r.Fund__c, Project_Funding__r.Account_Number__c,
                                                                      Project_Funding__r.Activity_ID__c, Project_Funding__r.Project_ID__c, Project_Funding__r.Department__c,
                                                                      Project_Funding__r.Market_Focus__c FROM Project_Purchase_Order_Funding_Line__c
                                                                      WHERE Project_Purchase_Order_Line__r.Project_Purchase_Order__c =: invoice.Project_Purchase_Order__c]){

                fundingLines.add(fundingLine);
            }

            for(MilestoneWrapper tempMilestone : listOfMilestones){
              for(InvoiceLineWrapper projectInvoiceLine : tempMilestone.projectInvoiceLines){
                projectInvoiceLine.distributions = new List<ProjectFundingDistributionWrapper>();

                  Set<Id> fundingLineIds = new Set<Id>();

                  if(projectInvoiceLine.invoiceLineItem.Id != null &&
                     invoiceDistributionMap.containsKey(projectInvoiceLine.invoiceLineItem.Id)
                     && invoiceDistributionMap.get(projectInvoiceLine.invoiceLineItem.Id) != null){

                      for(Project_Invoice_Distribution_Line__c distribution : invoiceDistributionMap.get(projectInvoiceLine.invoiceLineItem.Id)){

                          if(!fundingLineIds.contains(distribution.Project_Purchase_Order_Funding_Line__c)
                             && distribution.Project_Purchase_Order_Funding_Line__r != null
                             && distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r != null
                             && distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Fund__c != null){

                              fundingLineIds.add(distribution.Project_Purchase_Order_Funding_Line__c);

                              projectInvoiceLine.distributions.add(new ProjectFundingDistributionWrapper(distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Fund__c,
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
                          projectInvoiceLine.distributions.add(new ProjectFundingDistributionWrapper(fundingLine.Project_Funding__r.Fund__c,
                                                                                                       fundingLine.Project_Funding__r.Account_Number__c,
                                                                                                       fundingLine.Project_Funding__r.Activity_ID__c,
                                                                                                       fundingLine.Project_Funding__r.Project_ID__c,
                                                                                                       fundingLine.Project_Funding__r.Department__c,
                                                                                                       fundingLine.Project_Funding__r.Market_Focus__c,
                                                                                                       fundingLine.Name,
                                                                                                       new Project_Invoice_Distribution_Line__c(Project_Purchase_Order_Funding_Line__c = fundingLine.Id)));
                      }
                  }

                  if(projectInvoiceLine.distributions.size() == 1){

                      projectInvoiceLine.distributions[0].distribution.Amount__c = (projectInvoiceLine.invoiceLineItem.Amount__c != null ? projectInvoiceLine.invoiceLineItem.Amount__c : 0);
                  }
              }
            }
        }

        return null;
    }

    //Milestone Wrapper
    public class MilestoneWrapper{
        public List<InvoiceLineWrapper> projectInvoiceLines{get;set;}
        public Project_Milestones__c parentMilestone{get; set;}

        public MilestoneWrapper(){
            projectInvoiceLines =  new List<InvoiceLineWrapper>();
            parentMilestone = new Project_Milestones__c();
        }
    }

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

    public class InvoiceLineWrapper{
        public Project_Invoice_Line__c invoiceLineItem {get; set;}

        public List<ProjectFundingDistributionWrapper> distributions{get; set;}

        public List<SelectOption> availableQuantities{get; set;}

    public InvoiceLineWrapper(){
      invoiceLineItem = new Project_Invoice_Line__c(Amount__c = 0, Amount_Cost_Share__c = 0);
      distributions = new List<ProjectFundingDistributionWrapper>();
            availableQuantities = new List<SelectOption>();
    }

        public InvoiceLineWrapper(Project_Invoice_Line__c invoiceLineItem,
                                  List<ProjectFundingDistributionWrapper> distributions,
                                  List<SelectOption> availableQuantities){
            this.invoiceLineItem = invoiceLineItem;

            this.distributions = distributions;

            this.availableQuantities = availableQuantities;
        }
    }

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
}