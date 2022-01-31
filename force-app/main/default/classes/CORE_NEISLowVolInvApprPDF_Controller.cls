/*
* Class Name:  CORE_NEISLowVolInvApprPDF_Controller
* Description: Controller class for CORE_NEISLowVolInvApprPDF_Page to generate Summary PDF
* Author/Date: Ajay Gautam  07/14/2016 
* 
* Case 8381: Edited to show company name instead of contractor name for payee if this is NYSUN Commercial
* Author/Date: Alex Phillips 06/29/2017
*                                                           
*/

public without sharing class CORE_NEISLowVolInvApprPDF_Controller {
  transient public Project_Invoice__c invoiceRec {get; set;}
  transient public List<Project_Milestones__c> lstMilestones {get; set;}
  transient public List<Project_Invoice_Line__c> lstInvoiceLines {get; set;}
  transient String invoiceId, tranId;
  transient public Account supplierAccount {get; set;}
  transient public String programContactEmail {get;set;}
  transient public InvoiceLineWrapper invoiceItem {get; set;}
  transient public String paymentSupplierId { get; private set;}
  transient public Boolean isCommunityDG{get; private set;}
  transient public Project__c project{get; private set;}
  transient public Boolean isFirstInvoice {get; private set;}
   
  public Boolean is_NYSUN_COMMERCIAL_INDUSTRAIL{ get{return project.RecordType.Name == 'NY Sun - Commercial/Industrial';} private set;}
  public Boolean is_NYSUN_RESIDENTIAL_COMMERCIAL{ get{return project.RecordType.Name == 'NY Sun - Residential/Small Commercial';} private set;}
  public Boolean is_GSHP{ get{return project.RecordType.Name == 'GSHP Large System';} private set;}

  // Case: 00004472
  public String payeeName { get; set;}
  // Case: 00004472
  public static final String PROJECT_ROLE_PAYEE = 'Payee';
  private final String COMMUNITY_DG = 'Community DG';

    public class InvoiceLineWrapper{
      public Project_Invoice_Line__c invoiceLineItem {get; set;}

      public List<ProjectFundingDistributionWrapper> distributions{get; set;}

      public InvoiceLineWrapper(Project_Invoice_Line__c invoiceLineItem,
                             List<ProjectFundingDistributionWrapper> distributions){
        this.invoiceLineItem = invoiceLineItem;

          this.distributions = distributions;
      }
    }

    public class ProjectFundingDistributionWrapper{
      public Project_Invoice_Distribution_Line__c distribution{get; set;}
      public String fund{get; set;}
      public String header{get; set;}

      public ProjectFundingDistributionWrapper(String fund, String accountNumber, String activity, String projectID,
                                               String department, String marketFocus, String poLineNumber,
                                               Project_Invoice_Distribution_Line__c distribution){
          this.fund = fund;

          this.header = 'Activity: ' +  (activity != null ? activity : '') + '<br/>' +
                           'Project ID: ' +  (projectID != null ? projectID : '') + '<br/>' +
                          'PO Line #: ' +  (poLineNumber != null ? poLineNumber : '');

          this.distribution = distribution;
      }
    }

  public CORE_NEISLowVolInvApprPDF_Controller(ApexPages.StandardController controller) {
    payeeName = '';
    paymentSupplierId = '';
    invoiceRec = (Project_Invoice__c) controller.getRecord();
    supplierAccount = new Account();
    programContactEmail = '';
    lstMilestones = new List<Project_Milestones__c>();
    lstInvoiceLines = new List<Project_Invoice_Line__c>();
    project = new Project__c();
    Set<Id> milestoneIds = new Set<Id>();
    isFirstInvoice = true;
    invoiceId = Apexpages.currentPage().getParameters().get('id');
    tranId = Apexpages.currentPage().getParameters().get('tranId');
    Id projectId = null;
    if(String.isNotBlank(invoiceId)) {




      for(Project_Invoice_Line__c objInvoiceLine : [SELECT  Amount__c, Milestone__c , Invoice__c ,
                                                            Milestone__r.Name, Milestone__r.Name_with_Percentage__c, Milestone__r.Start_Date__c,
                                                            Milestone__r.Type__c, Invoice__r.Project__c,
                                                            Invoice__r.Project__r.Program_Version__r.Default_Project_Coordinator__r.Email,
                                                            Invoice__r.Project__r.RecordTypeId,
                                                            Invoice__r.Project__r.Budget_Type__c,
                                                            Requesting__c, Date_Range_Start__c, Date_Range_End__c
                                                    FROM    Project_Invoice_Line__c
                                                    WHERE   Invoice__c = :invoiceId]) {

        invoiceItem =  new InvoiceLineWrapper(objInvoiceLine, new List<ProjectFundingDistributionWrapper>());

        programContactEmail = objInvoiceLine.Invoice__r.Project__r.Program_Version__r.Default_Project_Coordinator__r.Email;
        projectId = objInvoiceLine.Invoice__r.Project__c;

        if( Clean_Transportation_Helper.ctRecordtypeexist(objInvoiceLine.Invoice__r.Project__r.RecordTypeId) &&
            CORE_Deliverables_Helper.CONST_MILESTONE.equalsIgnoreCase(objInvoiceLine.Invoice__r.Project__r.Budget_Type__c)) {
            if(objInvoiceLine.Milestone__c != null) {
            milestoneIds.add(objInvoiceLine.Milestone__c);
            lstInvoiceLines.add(objInvoiceLine);
            }
        } else {
            milestoneIds.add(objInvoiceLine.Milestone__c);
            lstInvoiceLines.add(objInvoiceLine);
        }

      }
      getProjectFunding();
      if(milestoneIds.size() > 0) {
        lstMilestones = [ SELECT  Id, Name,Name_with_Percentage__c,Total_Cost__c,Start_Date__c, Type__c
                          FROM    Project_Milestones__c
                          WHERE   Id IN :milestoneIds];
      }
      if(projectId != null) {
         // get Program Partnership records per Project via Primary Contractor

            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT RecordType.DeveloperName, Program_Version__c, Program_Version__r.Program__c,
                                                                      RecordType.Name,
                                                                      	(SELECT  Contact__c, Contact__r.AccountId,
                                                                                      Contact__r.Account.Supplier_ID__c,
                                                                                      Account__r.Supplier_ID__c, Account__c,
                                                                                      FirstName__c, LastName__c,Role__c,
                                                                                      Primary_Customer_Contact__c,company_name__c
                                                                              FROM    Project_Roles__r
                                                                              WHERE   (    Role__c = :ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE
                                                                                        OR Role__c = :PROJECT_ROLE_PAYEE)
                                                                              AND     Primary_Customer_Contact__c = true),
                                                                              (SELECT Supplier_ID__c FROM Project_Contracts__r LIMIT 1 ),
                                                                              (SELECT Id, Metering_Method__c FROM Project_Site__r)
                                                                      FROM Project__c
                                                                      WHERE Id = :projectId]);
              Set<Id> accountIds = new Set<Id>();
              Set<Id> programIds = new Set<Id>();

              for(Project_Invoice__c inv : [SELECT Id, Status__c, Total_Amount_Due__c ,Createdby.isPortalEnabled
                                                FROM Project_Invoice__c WHERE Status__c NOT IN :ProjectInvoice_Helper.SET_OF_REJECTED_OR_CANCEL_STATUSES
                                                AND Project__c =: projectId]){
                    if(inv.Id != invoiceRec.Id){
                        isFirstInvoice = false;
                    }
              }

              for(Project__c projRec : projectMap.values()) {
                System.debug('**projRec**'+projRec);

                project = projRec;

            if(projRec.Project_Contracts__r != null && projRec.Project_Contracts__r.size() > 0) {
              paymentSupplierId = (String.isNotBlank(projRec.Project_Contracts__r[0].Supplier_ID__c) ? projRec.Project_Contracts__r[0].Supplier_ID__c : '');
            }

            for(Project_Site__c proSite : projRec.Project_Site__r){
                if(proSite.Metering_Method__c == COMMUNITY_DG){
                    isCommunityDG = true;
                }
            }

                programIds.add(projRec.Program_Version__r.Program__c);
                System.debug('>>> projRec.Project_Roles__r = ' + projRec.Project_Roles__r);
                for(Project_Role__c objProjRole : projRec.Project_Roles__r) {
              System.debug('**objProjRole**'+objProjRole);
              if(ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objProjRole.Role__c)) {
                  if(objProjRole.Account__c != null) {
                    accountIds.add(objProjRole.Account__c);
                  } else if (objProjRole.Contact__c != null && objProjRole.Contact__r.AccountId != null) {
                    accountIds.add(objProjRole.Contact__r.AccountId);
                  }
              }
                }

            // Case: 00004472
            for(Project_Role__c objRole : projRec.Project_Roles__r) {
              if(PROJECT_ROLE_PAYEE.equalsIgnoreCase(objRole.Role__c) && objRole.Primary_Customer_Contact__c) {
                if(is_NYSUN_COMMERCIAL_INDUSTRAIL){
                    payeeName = objRole.company_name__c != null ? objRole.company_name__c : '';
                }
                Else{
                    payeeName =  objRole.FirstName__c != null ? objRole.FirstName__c : '';
                    payeeName += objRole.LastName__c != null ? ' ' + objRole.LastName__c : '';
                }
              }
            }

              }
              accountIds.remove(null);
              programIds.remove(null);
              System.debug('>>> accountIds = ' + accountIds);
              System.debug('>>> programIds = ' + programIds);
              if(accountIds.size() > 0 && programIds.size() > 0) {
                for(Program_Partnership__c objProgPart : [SELECT  Review_Count_Expedited__c, Expedited__c, Applications_Received_Expedited__c,
                                                                  Status__c, Program__c, Account__c, Account__r.Supplier_ID__c, Account__r.Name,
                                                                  Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,
                                                                  Account__r.BillingPostalCode,Account__r.BillingCountry,
                                                                  Account__r.County__c
                                                          FROM    Program_Partnership__c
                                                          WHERE   Account__c IN :accountIds
                                                          AND     Program__c IN :programIds]) {

                  supplierAccount = new Account();
                  supplierAccount.Supplier_ID__c = objProgPart.Account__r.Supplier_ID__c;
                  supplierAccount.Name = objProgPart.Account__r.Name;
                  supplierAccount.BillingStreet = objProgPart.Account__r.BillingStreet;
                  supplierAccount.BillingCity = objProgPart.Account__r.BillingCity;
                  supplierAccount.BillingState = objProgPart.Account__r.BillingState;
                  supplierAccount.BillingPostalCode = objProgPart.Account__r.BillingPostalCode;
                  supplierAccount.BillingCountry = objProgPart.Account__r.BillingCountry;
                  supplierAccount.County__c = objProgPart.Account__r.County__c;
                }
              }
            // EndOf: get Program Partnership records per Project via Primary Contractor
      }
    }

  }
    /*
    * Method Name: getProjectFunding
    * Description: get project funding
    * @return:  Pagereference
    */
    public Pagereference getProjectFunding(){
      invoiceItem.distributions = new List<ProjectFundingDistributionWrapper>();

      if(invoiceRec.Project_Purchase_Order__c != null){

        Set<Id> fundingLineIds = new Set<Id>();

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
                                       WHERE Project_Purchase_Order_Funding_Line__r.Project_Purchase_Order_Line__r.Project_Purchase_Order__c =: invoiceRec.Project_Purchase_Order__c
                                       AND Project_Invoice_Line__c =: invoiceItem.invoiceLineItem.Id]){

          if(!fundingLineIds.contains(distribution.Project_Purchase_Order_Funding_Line__c)
             && distribution.Project_Purchase_Order_Funding_Line__r != null
             && distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r != null
             && distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Fund__c != null){

            fundingLineIds.add(distribution.Project_Purchase_Order_Funding_Line__c);

            invoiceItem.distributions.add(new ProjectFundingDistributionWrapper(distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Fund__c,
                                                                                 distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Account_Number__c,
                                                                                 distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Activity_ID__c,
                                                                                 distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Project_ID__c,
                                                                                 distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Department__c,
                                                                                 distribution.Project_Purchase_Order_Funding_Line__r.Project_Funding__r.Market_Focus__c,
                                                                                 distribution.Project_Purchase_Order_Funding_Line__r.Name, distribution));
          }
        }

        for(Project_Purchase_Order_Funding_Line__c fundingLine : [SELECT Id,Name, Project_Funding__r.Fund__c, Project_Funding__r.Account_Number__c,
                                                                              Project_Funding__r.Activity_ID__c,
                                                                              Project_Funding__r.Project_ID__c, Project_Funding__r.Department__c,
                                                                          Project_Funding__r.Market_Focus__c FROM Project_Purchase_Order_Funding_Line__c
                                                                    WHERE Project_Purchase_Order_Line__r.Project_Purchase_Order__c =: invoiceRec.Project_Purchase_Order__c]){

          if(!fundingLineIds.contains(fundingLine.Id)){
            invoiceItem.distributions.add(new ProjectFundingDistributionWrapper(fundingLine.Project_Funding__r.Fund__c,
                                                                             fundingLine.Project_Funding__r.Account_Number__c,
                                                                             fundingLine.Project_Funding__r.Activity_ID__c,
                                                                             fundingLine.Project_Funding__r.Project_ID__c,
                                                                             fundingLine.Project_Funding__r.Department__c,
                                                                             fundingLine.Project_Funding__r.Market_Focus__c,
                                                                             fundingLine.Name,
                                                                             new Project_Invoice_Distribution_Line__c(Project_Purchase_Order_Funding_Line__c = fundingLine.Id)));
          }
        }
      }

      if(invoiceItem.distributions.size() == 1){
        invoiceItem.distributions[0].distribution.Amount__c = invoiceItem.invoiceLineItem.Amount__c;
      }

      return null;
    }


}