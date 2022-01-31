/*
*  Class Name: ProjectInvoice_TriggerHandler
*  Description: Handler class for ProjectInvoice_Trigger to manage operations for Trigger
*
*/

public with sharing class ProjectInvoice_TriggerHandler {

  private static final Integer iTargetLength_SupplierID = 10;

  private static Program_Partnership__c currentProgPartnershipRecord = null;

  // Trigger Methods Here //

      /*
      * Method Name: beforeInsertUpdate
      * Description: Method to call the processing before Insert and Update
      * @return:  void
      * @param: List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices
      */

  public static void beforeInsertUpdate(List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices) {
    stampApprovalFieldsOnInvoice(lstProjInvoices,oldMapProjInvoices); // T-01474: Low Volume real time push
    setStatusFromMetadataMapping(lstProjInvoices,oldMapProjInvoices);
    //stampAccountInfoOnInvoice(lstProjInvoices,oldMapProjInvoices);
  }

    /*
     * Method Name: afterInsertUpdate
     * Description: Method to call the processing after Insert and Update
     * @return:  void
     * @param: List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices
     */

  public static void afterInsertUpdate(List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices) {
    sendInvoicesForLowVolumeRealTime(lstProjInvoices,oldMapProjInvoices); // T-01474: Low Volume real time push
    if(oldMapProjInvoices != null && oldMapProjInvoices.size() > 0){
        updateProjectFields(lstProjInvoices,oldMapProjInvoices);
        recalculateBudget(lstProjInvoices,oldMapProjInvoices);
    }
  }

     /*
     * Method Name: recalculateBudget
     * Description: Method to recalculate Budget
     * @return:  void
     * @param: List<Project_Invoice__c> lstProjInvoices,Map<Id, Project_Invoice__c> oldMapProjInvoices
     */

  public static void recalculateBudget(List<Project_Invoice__c> lstProjInvoices,
                                       Map<Id, Project_Invoice__c> oldMapProjInvoices){

    Set<String> invalidStatus = new Set<String>{'Draft', 'Rejected', 'Cancelled'};
    Set<Id> invoiceIdsToProcess = new Set<Id>();

    for(Project_Invoice__c invoice : lstProjInvoices){
        if(oldMapProjInvoices != null && invoice.Status__c != oldMapProjInvoices.get(invoice.Id).Status__c
           && invalidStatus.contains(invoice.Status__c)){

            invoiceIdsToProcess.add(invoice.Id);
        }
    }

    if(invoiceIdsToProcess.size() == 0){
        return;
    }

    Set<Id> projectMilestoneIds = new Set<Id>();
    Set<Id> budgetCategoryLineIds = new Set<Id>();

    for(Project_Invoice_Line__c invoiceLine : [SELECT Id, Milestone__c, Budget_Category_Line__c, Quantity__c
                                                 FROM Project_Invoice_Line__c
                                                WHERE Invoice__c IN : invoiceIdsToProcess]){
        if(invoiceLine.Milestone__c != null){
            projectMilestoneIds.add(invoiceLine.Milestone__c);
        }

        if(invoiceLine.Budget_Category_Line__c != null){
            budgetCategoryLineIds.add(invoiceLine.Budget_Category_Line__c);
        }
    }

    if(projectMilestoneIds.size() > 0){
        List<Project_Milestones__c> listOfMilestoneToUpdate = new List<Project_Milestones__c>();

        for(Project_Milestones__c tempProMilestone : [SELECT Id, Legacy_Billed_To_Date__c, Legacy_Billed_To_Date_Cost_Share__c,
                                                             (SELECT Id, Amount__c, Amount_Cost_Share__c, Quantity__c
                                                                FROM Project_Invoice_Lines__r WHERE Invoice__r.Status__c NOT IN : invalidStatus)
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

    if(budgetCategoryLineIds.size() > 0){
        List<BudgetCategoryLine__c> listOfCategoryLineToUpdate = new List<BudgetCategoryLine__c>();

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

        if(listOfCategoryLineToUpdate.size() > 0){
            Database.update(listOfCategoryLineToUpdate);
        }
    }
  }

  // Trigger Method Definitions Here //

  /*
  private static void stampAccountInfoOnInvoice(List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices) {
    Boolean isInsert = (Trigger.isInsert);
    Set<Id> projectIds = new Set<Id>();
    Map<Id, List<Project_Invoice__c>> projectWiseInvoice = new Map<Id, List<Project_Invoice__c>>();

    for(Project_Invoice__c objProjInvoice : lstProjInvoices) {
      if(objProjInvoice.Project__c != null && (String.isBlank(objProjInvoice.Supplier_ID__c) || String.isBlank(objProjInvoice.Company_Name__c)) &&
        (isInsert || (!isInsert && objProjInvoice.Project__c != oldMapProjInvoices.get(objProjInvoice.Id).Project__c))) {
         projectIds.add(objProjInvoice.Project__c);
         if(!projectWiseInvoice.containsKey(objProjInvoice.Project__c)) {
           projectWiseInvoice.put(objProjInvoice.Project__c, new List<Project_Invoice__c>());
         }
         projectWiseInvoice.get(objProjInvoice.Project__c).add(objProjInvoice);
      }
    }

    if(projectIds.size() > 0) {

        Map<Id, Project__c> mapOfIdAndProject = new Map<Id, Project__c>([SELECT Id, Status__c, Payment_Assignment__c,RecordType.DeveloperName,
                                                                                     (SELECT  Company_Name__c, Email__c,
                                                                                              Primary_Customer_Contact__c,Role__c,
                                                                                              FirstName__c,Account__r.Name,Contact__r.Name,
                                                                                                      Account__r.BillingStreet, Account__r.BillingCity,
                                                                                                      Account__r.BillingState,
                                                                                                      Account__r.Supplier_ID__c,
                                                                                                      Account__r.BillingPostalCode,LastName__c
                                                                                      FROM Project_Roles__r
                                                                                      WHERE Role__c IN :NYSUN_Helper.PROJECT_ROLE_SET )
                                                                         FROM Project__c
                                                                         WHERE Id IN :projectIds ]);

      for(Project__c proj : mapOfIdAndProject.values()) {
        for(Project_Role__c projectRole : proj.Project_Roles__r){
            String contactName = projectRole.FirstName__c != null ? projectRole.FirstName__c : '';
            contactName += projectRole.LastName__c != null ? ' ' + projectRole.LastName__c : '';

            if(projectWiseInvoice.containsKey(proj.id)) {
              for(Project_Invoice__c localInvoice : projectWiseInvoice.get(proj.id)) {
                 if(projectRole.Primary_Customer_Contact__c && projectRole.Role__c == NYSUN_Helper.PROJECT_ROLE_CONTRACTOR){
                        localInvoice.Company_Name__c = projectRole.Account__r.Name;
                        localInvoice.Contact_Name__c = contactName;
                        localInvoice.Street__c = projectRole.Account__r.BillingStreet;
                        localInvoice.City__c =  projectRole.Account__r.BillingCity;
                        localInvoice.State__c = projectRole.Account__r.BillingState;
                        localInvoice.Zip__c = projectRole.Account__r.BillingPostalCode;
                        localInvoice.Supplier_ID__c = projectRole.Account__r.Supplier_ID__c;
                    }
              }
            }
        }
      }
    }
  }
  */

     /*
     * Method Name: stampApprovalFieldsOnInvoice
     * Description: Method stamp approval fields on Invoice
     * @return:  void
     * @param: List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices
     */

  private static void stampApprovalFieldsOnInvoice(List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices) {
    Boolean isInsert = (Trigger.isInsert);
    Id loggedInUserId = UserInfo.getUserId();
    for(Project_Invoice__c objProjInvoice : lstProjInvoices) {
      if(objProjInvoice.Project__c != null && ProjectInvoice_Helper.STATUS_APPROVED.equalsIgnoreCase(objProjInvoice.Status__c) &&
        (isInsert || (!isInsert && !objProjInvoice.Status__c.equalsIgnoreCase(oldMapProjInvoices.get(objProjInvoice.Id).Status__c)))) {
          // Approved By and Approved Date
          objProjInvoice.Approved_By__c = loggedInUserId;
          objProjInvoice.Approved_Date__c = Date.today();
      }
    }
  }

     /*
     * Method Name: sendInvoicesForLowVolumeRealTime
     * Description: Method to send invoices for low volume real time
     * @return: void
     * @param: List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices
     */

  public static void sendInvoicesForLowVolumeRealTime(List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices) {
    Boolean isInsert = (Trigger.isExecuting && Trigger.isInsert);
    Map<Id, List<Project_Invoice__c>> projectWiseInvoices = new Map<Id, List<Project_Invoice__c>>();
    Map<Id, Id> projectAndProgramVersionIdMap = new Map<Id, Id>();
    Map<Id, Program_Version__c> programVersionsInScope = new Map<Id,Program_Version__c>();
    List<Project_Invoice__c> eligibleInvoices_BeforeProgFilter = new List<Project_Invoice__c>();
    Id progVersionId = null;
    Program_Version__c objCurrentProgVersion = new Program_Version__c();


    if(lstProjInvoices.size() == 1) { // STRICTLY One record only.
        // Case 00008620 - Added CEC Record Type for Submitted status based PDF email
        // Case 00009596 - Added GSHP Large System
        for(Project_Invoice__c objProjInvoice : lstProjInvoices) {
          if(objProjInvoice.Project__c != null &&
             (  ProjectInvoice_Helper.STATUS_APPROVED.equalsIgnoreCase(objProjInvoice.Status__c) ||
                ( ProjectInvoice_Helper.STATUS_SUBMITTED.equalsIgnoreCase(objProjInvoice.Status__c) &&
                  (Clean_Transportation_Helper.validRecordtypes.contains(objProjInvoice.Project_Record_Type__c)
                  )
                )
             ) &&
              (isInsert ||
               (!isInsert && oldMapProjInvoices != null && oldMapProjInvoices.containsKey(objProjInvoice.Id)
                          && !objProjInvoice.Status__c.equalsIgnoreCase(oldMapProjInvoices.get(objProjInvoice.Id).Status__c))
              )) {
              if(!projectWiseInvoices.containsKey(objProjInvoice.Project__c)) {
                projectWiseInvoices.put(objProjInvoice.Project__c, new List<Project_Invoice__c>());
              }
              projectWiseInvoices.get(objProjInvoice.Project__c).add(objProjInvoice);
              eligibleInvoices_BeforeProgFilter.add(objProjInvoice);
          }
        }
    }
    if(eligibleInvoices_BeforeProgFilter.size() > 0 && projectWiseInvoices.size() > 0) {
      for(Project__c objProj : [SELECT  Program_Version__c
                                FROM    Project__c
                                WHERE   Id IN :projectWiseInvoices.keySet()
                                AND     Program_Version__r.Include_in_NEIS_Invoice_Batch__c = false
                                AND     Program_Version__r.Invoice_Summary_Email_Template_API_Name__c != null]) {
        projectAndProgramVersionIdMap.put(objProj.Id, objProj.Program_Version__c);
      }
      if(projectAndProgramVersionIdMap.size() > 0) {
        Set<Id> progVersionIds = new Set<Id>();
        progVersionIds.addAll(projectAndProgramVersionIdMap.values());

        if(progVersionIds.size() > 0) {
              programVersionsInScope = new Map<Id,Program_Version__c>([SELECT Include_in_NEIS_Invoice_Batch__c,
                                                                              Financial_Aide_s_Email__c,RecordTypeId,
                                                                              RecordType.DeveloperName,RecordType.Name,
                                                                              NEIS_Invoice_Batch_PDF_Summary_File_Name__c,
                                                                              NEIS_Invoice_Batch_CSV_File_Name__c, Name,
                                                                              Additional_CC_Emails_on_Invoice_Summary__c,
                                                                              Can_Use_Batch_Processing_for_Invoices__c,
                                                                              Invoice_Summary_Email_Template_API_Name__c,
                                                                              ProjectInvoice_FieldSet_API_Name_for_CSV__c,
                                                                              Program__c
                                                                       FROM   Program_Version__c
                                                                       WHERE  Id IN :progVersionIds ]);
        }
      }
    }

    if(eligibleInvoices_BeforeProgFilter.size() >  0 && projectAndProgramVersionIdMap.size() > 0 && programVersionsInScope.size() > 0) {
      Map<Id, Transaction_Log_Detail__c> mapOfInvoiceAndTranDetail = new Map<Id, Transaction_Log_Detail__c>();
      Map<Id, Transaction_Log__c> invoiceWiseTransactionLogMap = new Map<Id, Transaction_Log__c>();
      Map<Id, Id> projectInvoiceIdToTransactionDetailLogIdMap = new Map<Id, Id>();

      for(Project_Invoice__c objProjInvoiceVar : eligibleInvoices_BeforeProgFilter) {
        if(projectAndProgramVersionIdMap.containsKey(objProjInvoiceVar.Project__c)) {
          progVersionId = projectAndProgramVersionIdMap.get(objProjInvoiceVar.Project__c);
          if(progVersionId != null) {
            objCurrentProgVersion = programVersionsInScope.get(progVersionId);
            if(objCurrentProgVersion != null) {
              Transaction_Log__c objTran = createTransactionLogRecord(objCurrentProgVersion, TransactionLog_Helper.TRANSACTION_LOG_TYPE_INVOICES, false);
              objTran.Total_Amount_Approved__c = objProjInvoiceVar.Total_Amount_Due__c;
              objTran.Total_Records_Processed__c = 1;
              invoiceWiseTransactionLogMap.put(objProjInvoiceVar.Id, objTran);
            }
          }
        }
      }
      if(invoiceWiseTransactionLogMap.size() > 0) {
        insert invoiceWiseTransactionLogMap.values();
        for(Project_Invoice__c objProjInvoiceVarAfterTran : eligibleInvoices_BeforeProgFilter) {
          if(invoiceWiseTransactionLogMap.containsKey(objProjInvoiceVarAfterTran.Id)) {
            Transaction_Log__c objTran = invoiceWiseTransactionLogMap.get(objProjInvoiceVarAfterTran.Id);
            if(objTran != null) {
              Transaction_Log_Detail__c objTranDetail = createTransactionLogDetailRecord(objTran.Id, objProjInvoiceVarAfterTran.Id);
              objTranDetail.Status__c = TransactionLogDetail_Helper.STATUS_INITIATED;
              mapOfInvoiceAndTranDetail.put(objProjInvoiceVarAfterTran.Id, objTranDetail);
            }
          }
        }
        if(mapOfInvoiceAndTranDetail.size() > 0) {
          insert mapOfInvoiceAndTranDetail.values();
            for(Project_Invoice__c objProjInvoiceVarAfterTranDetail : eligibleInvoices_BeforeProgFilter) {
              if(mapOfInvoiceAndTranDetail.containsKey(objProjInvoiceVarAfterTranDetail.Id)) {
                Transaction_Log_Detail__c objTranDetail = mapOfInvoiceAndTranDetail.get(objProjInvoiceVarAfterTranDetail.Id);
                if(objTranDetail != null) {
                  // Prepare for Future Call --All is related with Ids
                  projectInvoiceIdToTransactionDetailLogIdMap.put(objProjInvoiceVarAfterTranDetail.Id, objTranDetail.Id);
                }
              }
            }
        }
        if(projectInvoiceIdToTransactionDetailLogIdMap.size() > 0) {
          sendInvoicesAndLogTransaction_FutureCall(projectInvoiceIdToTransactionDetailLogIdMap,projectAndProgramVersionIdMap,true); // This is Future Call here
        }
      }
    }
  }


    /*
     * Method Name: sendInvoicesAndLogTransaction_FutureCall
     * Description: FUTURE METHOD to send Low-Volume invoices
     * @return: void
     * @param: Map<Id, Id> projectInvoiceIdToTransactionDetailLogIdMap,Map<Id, Id> projectAndProgramVersionIdMap, Boolean attachDeliverables
     */
  @future(callout=true)
  public static void sendInvoicesAndLogTransaction_FutureCall(Map<Id, Id> projectInvoiceIdToTransactionDetailLogIdMap,
                                                              Map<Id, Id> projectAndProgramVersionIdMap, Boolean attachDeliverables) {



    Map<Id, Project_Invoice__c> projectInvoiceMap = new Map<Id, Project_Invoice__c>();
    Map<Id, List<Project_Invoice_Line__c>> projectInvoiceLineMapWithInvId = new Map<Id, List<Project_Invoice_Line__c>>();
    Map<Id, Program_Version__c> programVersionsInScope = new Map<Id,Program_Version__c>();
    Map<Id, Transaction_Log_Detail__c> transactionLogDetailMap = new Map<Id,Transaction_Log_Detail__c>();
    Set<Id> progVersionIds = new Set<Id>();
    Set<Id> transactionLogDetailIds = new Set<Id>();
    Set<Id> docIds = new Set<Id>();
    Set<Id> milestoneIds = new Set<Id>();
    Map<Id, Set<Id>> milestoneIdWiseProjDocIds = new Map<Id, Set<Id>>();

    if(projectInvoiceIdToTransactionDetailLogIdMap != null && projectInvoiceIdToTransactionDetailLogIdMap.size() > 0) {
      transactionLogDetailIds.addAll(projectInvoiceIdToTransactionDetailLogIdMap.values());
      for(Project_Invoice__c objInvoice : [SELECT Name,Total_Amount_Due__c,Status__c,Invoice_Date__c,
                                                  Project__r.Program_Version__c,
                                                  Project__r.Program_Version__r.Name,
                                                  Project__r.Program_Version__r.Program__c,
                                                  Project__c,Company_Name__c,Final_Payment__c,
                                                  Project__r.RecordTypeId,
                                                  Project__r.Budget_Type__c,
                                                  (SELECT Id, Milestone__c
                                                   FROM   Project_Invoice_Lines__r
                                                   WHERE  Milestone__c != null)
                                           FROM   Project_Invoice__c
                                           WHERE  Id IN :projectInvoiceIdToTransactionDetailLogIdMap.keySet()]) {
        progVersionIds.add(objInvoice.Project__r.Program_Version__c);
        projectInvoiceMap.put(objInvoice.Id, objInvoice);
        for(Project_Invoice_Line__c objInvoiceLine : objInvoice.Project_Invoice_Lines__r) {
          milestoneIds.add(objInvoiceLine.Milestone__c);
        }
      }
        if(progVersionIds.size() > 0) {
          programVersionsInScope = new Map<Id,Program_Version__c>([SELECT Include_in_NEIS_Invoice_Batch__c,
                                                                          Financial_Aide_s_Email__c,RecordTypeId,
                                                                          RecordType.DeveloperName,RecordType.Name,
                                                                          NEIS_Invoice_Batch_PDF_Summary_File_Name__c,
                                                                          NEIS_Invoice_Batch_CSV_File_Name__c, Name,
                                                                          Additional_CC_Emails_on_Invoice_Summary__c,
                                                                          Can_Use_Batch_Processing_for_Invoices__c,
                                                                          Invoice_Summary_Email_Template_API_Name__c,
                                                                          ProjectInvoice_FieldSet_API_Name_for_CSV__c,
                                                                          Program__c, Program__r.Name
                                                                   FROM   Program_Version__c
                                                                   WHERE  Id IN :progVersionIds ]);
        }

        if(transactionLogDetailIds.size() > 0) {
          transactionLogDetailMap = new Map<Id,Transaction_Log_Detail__c>([SELECT Status__c, Project_Invoice__c,
                                                                                  Error_Details_if_Any__c, Transaction_Log__c
                                                                           FROM   Transaction_Log_Detail__c
                                                                           WHERE  Id IN :transactionLogDetailIds]);
        }

        if(milestoneIds.size() > 0) {
          for(Project_Deliverables__c objProdDel : [SELECT Id,Project_Milestone__c,
                                                           (SELECT Id FROM Project_Documents__r ORDER BY Version__c DESC LIMIT 1 )
                                                    FROM   Project_Deliverables__c
                                                    WHERE  Project_Milestone__c IN :milestoneIds]) {
            if(!milestoneIdWiseProjDocIds.containsKey(objProdDel.Project_Milestone__c)) {
              milestoneIdWiseProjDocIds.put(objProdDel.Project_Milestone__c, new Set<Id>());
            }
            for(Project_Document__c objDoc : objProdDel.Project_Documents__r) {
              milestoneIdWiseProjDocIds.get(objProdDel.Project_Milestone__c).add(objDoc.Id);
            }
          }
        }
    }
    if(projectInvoiceMap.size() > 0 && transactionLogDetailMap.size() > 0 && programVersionsInScope.size() > 0) {
      Map<String, Id> emailTemplateNameAndIdMap = new Map<String, Id>();
      List<Messaging.SingleEmailMessage> lstEmailMessages = new List<Messaging.SingleEmailMessage>();
      Map<Id, Transaction_Log_Detail__c> tranDetailsToBeUpdated = new Map<Id, Transaction_Log_Detail__c>();
      Map<Id, Transaction_Log__c> TransactionMap = new Map<Id, Transaction_Log__c>();
      Set<Id> invoicesSent = new Set<Id>();
        for(Id invoiceId : projectInvoiceMap.keySet()) {
          docIds = new Set<Id>();
          Project_Invoice__c objInvoice = projectInvoiceMap.get(invoiceId);
          Program_Version__c objProgVersion = programVersionsInScope.get(objInvoice.Project__r.Program_Version__c);
          Id transactionLogDetailId = projectInvoiceIdToTransactionDetailLogIdMap.get(invoiceId);
          Transaction_Log_Detail__c objTranDetail = transactionLogDetailMap.get(transactionLogDetailId);
          Transaction_Log__c objTransaction_Current;
          if(objTranDetail != null && objProgVersion != null) {
            objTransaction_Current = new Transaction_Log__c(Id = objTranDetail.Transaction_Log__c);

              // Email and Content
              if(String.isNotBlank(objProgVersion.Invoice_Summary_Email_Template_API_Name__c)) {
                // Set Email attributes

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                List<String> lstToAddress = new List<String>();
                List<String> lstCCAddress = new List<String>();


                // Set Email attributes for recipient(s) -- Case 00008414
                if(String.isNotBlank(objProgVersion.Financial_Aide_s_Email__c)) {
                  // If a dedicated finance email box is setup in solicitation, all approved invoices will go there.
                  lstToAddress.add(objProgVersion.Financial_Aide_s_Email__c);
                } else {
                  // If there is no dedicated email box for the solicitation,
                  //    then all approved invoices would go to the finance aide configured/mapped for the supplier in NEIS
                  currentProgPartnershipRecord = null;
                  String strEmail = emailsFromfinanceAideMapping(objInvoice.Project__c);
                  if(String.isNotBlank(strEmail)) {
                    lstToAddress.add(strEmail);
                  } else {
                    // if no such finance aide is configured for the supplier then the email would go to
                    //  email(s) specified in Custom Label: CORE_InvoicePDF_NEIS_Finance_Aide_Mailbox_Default
                    strEmail = System.Label.CORE_InvoicePDF_NEIS_Finance_Aide_Mailbox_Default;
                    if(String.isNotBlank(System.Label.CORE_InvoicePDF_NEIS_Finance_Aide_Mailbox_Default)) {
                      lstToAddress.add(System.Label.CORE_InvoicePDF_NEIS_Finance_Aide_Mailbox_Default);
                    }
                  }
                  objTransaction_Current.Finance_Aide_Email__c = strEmail;
                }
                // Set Email attributes for recipient(s) -- Case 00008414

                if(String.isNotBlank(objProgVersion.Additional_CC_Emails_on_Invoice_Summary__c)) {
                  lstCCAddress.addAll(objProgVersion.Additional_CC_Emails_on_Invoice_Summary__c.split(','));
                } 
                if(lstToAddress.size() == 0) {
                  lstToAddress = lstCCAddress;
                }

                Id templateId = null;
                if(!emailTemplateNameAndIdMap.containsKey(objProgVersion.Invoice_Summary_Email_Template_API_Name__c)) {
                for(EmailTemplate objEmailTemplate : [SELECT  Id, DeveloperName, Subject, Body
                                                      FROM    EmailTemplate
                                                      WHERE   DeveloperName = :objProgVersion.Invoice_Summary_Email_Template_API_Name__c] ) {
                  templateId = objEmailTemplate.Id;
                }
                emailTemplateNameAndIdMap.put(objProgVersion.Invoice_Summary_Email_Template_API_Name__c,templateId);
                }

                if(templateId != null) {
                  Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(templateId, null, objTransaction_Current.Id); // Object Must have 'Allow Activities' ON.
                  String companyName = String.isNotBlank(objInvoice.Company_Name__c) ? objInvoice.Company_Name__c : '';
                  String subject = String.isNotBlank(newEmail.Subject) ? newEmail.Subject.replace(ProjectInvoice_Helper.CONST_COMPANY_NAME_TAG_EMAIL_TEMPLATE_SUBJECT, companyName) : newEmail.Subject;
                  String htmlBody = String.isNotBlank(newEmail.HTMLBody) ? newEmail.HTMLBody.replace(ProjectInvoice_Helper.CONST_SALESFORCE_INVOICE_NUMBER_TAG_EMAIL_TEMPLATE_BODY, objInvoice.Name) : newEmail.HTMLBody;
                  String textBody = String.isNotBlank(newEmail.PlainTextBody) ? newEmail.PlainTextBody.replace(ProjectInvoice_Helper.CONST_SALESFORCE_INVOICE_NUMBER_TAG_EMAIL_TEMPLATE_BODY, objInvoice.Name) : newEmail.PlainTextBody;
                  if(String.isNotBlank(objInvoice.Project__r.Budget_Type__c)) {
                    if(objInvoice.Project__r.Budget_Type__c == 'T&M' || objInvoice.Project__r.Budget_Type__c == 'Milestone') {
                        htmlBody = String.isNotBlank(htmlBody) ? htmlBody.replace('Approved by', 'Submitted By') : htmlBody;
                        textBody = String.isNotBlank(textBody) ? textBody.replace('Approved by', 'Submitted By') : textBody;
                    }
                    String basisDate = ((objInvoice.Invoice_Date__c != null) ? 'Basis Date – ['+ objInvoice.Invoice_Date__c.format()+']': '');
                    subject = String.isNotBlank(newEmail.Subject) ? newEmail.Subject.replace(ProjectInvoice_Helper.CONST_COMPANY_NAME_TAG_EMAIL_TEMPLATE_SUBJECT, basisDate +' '+companyName) : newEmail.Subject;
                  }
                  mail.setSubject(subject);
                  mail.setHtmlBody(htmlBody);
                  mail.setPlainTextBody(textBody);
                  mail.setToAddresses(lstToAddress);
                  mail.setCcAddresses(lstCCAddress);

                  currentProgPartnershipRecord = null;

                  Attachment attachment = new Attachment();

                  // PDF
                  PageReference pgSummary = Page.CORE_NEISLowVolInvApprPDF_Page;

                  pgSummary.getParameters().put('id', objInvoice.Id);
                  pgSummary.getParameters().put('tranId', objTransaction_Current.Id);

                  System.debug('>>> PDF page pgSummary = ' + pgSummary);

                  Blob pdfBlob;
                  if(!Test.isRunningTest()) {
                    pdfBlob = pgSummary.getContentAsPDF();
                  } else {
                    pdfBlob = Blob.valueOf('Test');
                  }

                  String pdfName = '';
                  // "Program Name - Invoice # - yyyy-mm-dd"
                  if(String.isNotBlank(objProgVersion.NEIS_Invoice_Batch_PDF_Summary_File_Name__c)) {
                    pdfName = objProgVersion.NEIS_Invoice_Batch_PDF_Summary_File_Name__c;
                  } else {
                    pdfName = objProgVersion.Program__r.Name;
                  }
                  pdfName = pdfName + invoiceNumber(objInvoice.Name) + suffixDateStr() + '.pdf';

                  // Attaching to Transaction Record
                  attachment = new Attachment();
                  attachment.ParentId = objTransaction_Current.Id;
                  attachment.Name = pdfName;
                  if(!Test.isRunningTest()) {
                    attachment.body = pdfBlob;
                  } else {
                    Blob bodyBlob = Blob.valueOf('Test');
                    attachment.body = bodyBlob;
                  }
                  insert attachment;
                  attachment = new Attachment();

                  Messaging.EmailFileAttachment pdfAttc = new Messaging.EmailFileAttachment();
                  pdfAttc.setFileName(pdfName);
                  pdfAttc.setBody(pdfBlob);

              /*
                  // Project Deliverables
                  // NO NEED
                  List<Attachment> lstAttachmentsForTran_DMLInsideLoop = new List<Attachment>();
                  for(Project_Invoice_Line__c objInvoiceLine : objInvoice.Project_Invoice_Lines__r) {
                    if(milestoneIdWiseProjDocIds.containsKey(objInvoiceLine.Milestone__c)) {
                      docIds = milestoneIdWiseProjDocIds.get(objInvoiceLine.Milestone__c);
                      if(docIds.size() > 0) {
                        for(Attachment objAttch : [SELECT Name, Body, ParentId
                                                   FROM   Attachment
                                                   WHERE  ParentId IN :docIds]) {
                          Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
                          emailAttach.setFileName(objAttch.Name);
                          emailAttach.setBody(objAttch.Body);
                          emailAttachments.add(emailAttach);

                          Attachment objTemp = new Attachment();
                      objTemp.ParentId = objTransaction_Current.Id;
                      objTemp.Name = objAttch.Name;
                      objTemp.body = objAttch.Body;
                          lstAttachmentsForTran_DMLInsideLoop.add(objTemp);
                        }
                      }
                    }
                  }
                  if(lstAttachmentsForTran_DMLInsideLoop.size() > 0) {
                    insert lstAttachmentsForTran_DMLInsideLoop;
                    lstAttachmentsForTran_DMLInsideLoop.clear();
                  }
                  // NO NEED
                  // Project Deliverables
              */

                  emailAttachments.add(pdfAttc);
                  mail.setFileAttachments(emailAttachments);
              lstEmailMessages.add(mail);

              System.debug('>>> newEmail UPDATED = ' + newEmail);

              invoicesSent.add(objInvoice.Id);
              objTranDetail.Status__c = TransactionLogDetail_Helper.STATUS_SUCCESS;
              tranDetailsToBeUpdated.put(objTranDetail.Id, objTranDetail);
              objTransaction_Current.Total_Records_Sent_Successfully__c = 1;
              transactionMap.put(objTransaction_Current.Id, objTransaction_Current);
                  //try {
                    //updateInvoicesAsSentToFinance(programInvoiceIdsProcessed);
                  //} catch (Exception e) {
                   // objTranDetail = markTransactionLevelError(objTranDetail, e.getMessage());
                  //}
                } else {
                  objTranDetail = markTransactionLevelError(objTranDetail, ' EmailTemplate Id = ' + templateId);
                  tranDetailsToBeUpdated.put(objTranDetail.Id, objTranDetail);
                }
              } else {
                objTranDetail = markTransactionLevelError(objTranDetail, 'Program_Version__c.Invoice_Summary_Email_Template_API_Name__c is ' + objProgVersion.Invoice_Summary_Email_Template_API_Name__c);
                tranDetailsToBeUpdated.put(objTranDetail.Id, objTranDetail);
              }
          }
        }
        if(transactionMap.size() > 0) {
          update transactionMap.values();
        }
        if(tranDetailsToBeUpdated.size() > 0) {
          update tranDetailsToBeUpdated.values();
        }

        //Savepoint spInvoiceUpdates = Database.setSavepoint();

      if(lstEmailMessages.size() > 0) {
        lstEmailMessages = CORE_Helper.setOrgWideEmailAddress_CORE(lstEmailMessages);
        List<Messaging.SendEmailResult> lstEmailResult = Messaging.sendEmail(lstEmailMessages, false);
      updateInvoicesAsSentToFinance(invoicesSent);

        Boolean updateErrorDetails = false;
        for(Messaging.SendEmailResult emailResult : lstEmailResult) {
          if(!emailResult.success) {
            updateErrorDetails = true;
            if(tranDetailsToBeUpdated != null) {
                for(Transaction_Log_Detail__c objTranDetail : tranDetailsToBeUpdated.values()) {
                  markTransactionLevelError(objTranDetail, emailResult.getErrors().get(0).getStatusCode() + ' ' + emailResult.getErrors().get(0).getMessage());
                }
              for(Transaction_Log__c objTran : transactionMap.values()) {
                          objTran.Total_Records_Sent_Successfully__c = 0;
                          objTran.Total_Records_Flagged__c = 1;
              }
            }
          }
        }
        if(updateErrorDetails && tranDetailsToBeUpdated != null && tranDetailsToBeUpdated.values().size() > 0) {

          //Database.rollback(spInvoiceUpdates);

          update transactionMap.values();
          update tranDetailsToBeUpdated.values();

        }

      }

    }
  }


  /*
   * Method Name: emailsFromfinanceAideMapping
   * Description: Method to send emails from finance Aide Mapping
   * @return: String
   * @param: Id projectId
  */
  private static String emailsFromfinanceAideMapping(Id projectId) { //Set<Id> projectIds
    // get Program Partnership records per Project via Primary Contractor
    String supplierId = null, fillerStr = '';
    String strEmail = '';
    Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT RecordType.DeveloperName, Program_Version__c, Program_Version__r.Program__c,
                                                                     (SELECT  Contact__c, Contact__r.AccountId,
                                                                              Role__c, Role_Supplier_ID__c,
                                                                              Primary_Customer_Contact__c
                                                                      FROM    Project_Roles__r
                                                                      WHERE   Role__c = :ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE
                                                                      AND     Primary_Customer_Contact__c = true LIMIT 1),
                                                                      (SELECT Supplier_ID__c, Status__c
                                                                       FROM   Project_Contracts__r
                                                                       WHERE  Supplier_ID__c != NULL
                                                                       ORDER BY CreatedDate DESC LIMIT 1)
                                                              FROM Project__c
                                                              WHERE Id = :projectId]);
      Set<Id> accountIds = new Set<Id>();
      Set<Id> programIds = new Set<Id>();

      for(Project__c projRec : projectMap.values()) {
        programIds.add(projRec.Program_Version__r.Program__c);
        for(Project_Role__c objProjRole : projRec.Project_Roles__r) {
          accountIds.add(objProjRole.Contact__r.AccountId);
        }
      }

      accountIds.remove(null);
      programIds.remove(null);
      if(accountIds.size() > 0 && programIds.size() > 0) {
        for(Program_Partnership__c objProgPart : [SELECT  Review_Count_Expedited__c, Expedited__c, Applications_Received_Expedited__c,
                                                          Status__c, Program__c, Account__c, Account__r.Supplier_ID__c, Account__r.Name
                                                  FROM    Program_Partnership__c
                                                  WHERE   Account__c IN :accountIds
                                                  AND     Program__c IN :programIds]) {
          supplierId = objProgPart.Account__r.Supplier_ID__c;
          currentProgPartnershipRecord = objProgPart;
        }
      }

      if(String.isBlank(supplierId)) { // No supplier id found yet!

          for(Project__c projRec : projectMap.values()) {

          // Get it from Project Contract
            for(Project_Contract__c objContract : projRec.Project_Contracts__r) {
              supplierId = objContract.Supplier_ID__c;
            }

            if(String.isBlank(supplierId)) { // Still, there is no supplier id
              // Get it from Role
              for(Project_Role__c objProjRole : projRec.Project_Roles__r) {
                if(ProjectRole_Helper.PROJECT_CONTRACTOR_ROLE.equalsIgnoreCase(objProjRole.Role__c) && objProjRole.Primary_Customer_Contact__c) {
                  supplierId = objProjRole.Role_Supplier_ID__c;
                }
              }
            }

          }
      }

        if(supplierId != null) {

          // Pad the missing ZEROs
          Integer iLength = supplierId.length();
          System.debug('>>> BEFORE supplierId = ' + supplierId);
          if(iLength > 0 && iLength < iTargetLength_SupplierID) {
              for(Integer i = 0; i < (iTargetLength_SupplierID - iLength); i++) {
                fillerStr = fillerStr + '0';
              }
          }
          supplierId = fillerStr + supplierId;
          System.debug('>>> AFTER supplierId = ' + supplierId);
          // EndOf: Pad the missing ZEROs

          for(Finance_Aide_Mapping__c objFinanceAideMapping : [SELECT Finance_Aide_Email_ID__c
                                                               FROM   Finance_Aide_Mapping__c
                                                               WHERE  NEIS_Supplier_Id__c = :supplierId
                                                               ORDER BY LastModifiedDate DESC LIMIT 1]) {
            if(String.isNotBlank(objFinanceAideMapping.Finance_Aide_Email_ID__c)) {
              strEmail = objFinanceAideMapping.Finance_Aide_Email_ID__c;
            }
          }
        }

    // EndOf: get Program Partnership records per Project via Primary Contractor
    return strEmail;
  }

    /*
     * Method Name: setStatusFromMetadataMapping
     * Description: Method to set status from metadata mapping
     * @return: void
     * @param: List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices
    */

  private static void setStatusFromMetadataMapping(List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices) {

    List<NEIS_Status_Mapping__mdt> mappingList = [SELECT Id, Field_1__c, Field_2__c, Field_3__c, Value_2__c, Value_1__c, Value_3__c, Result_Status__c
                                                  FROM NEIS_Status_Mapping__mdt
                                                  WHERE MasterLabel = 'Project_Invoice__c'];
    for(Project_Invoice__c invoice : lstProjInvoices) {
        for(NEIS_Status_Mapping__mdt mapping : mappingList) {
            if(invoice.get(mapping.Field_1__c) == mapping.Value_1__c && invoice.get(mapping.Field_2__c) == mapping.Value_2__c &&
                invoice.get(mapping.Field_3__c) == mapping.Value_3__c && invoice.Status__c != ProjectInvoice_Helper.STATUS_PAID && invoice.Status__c != ProjectInvoice_Helper.STATUS_PARTIALLY_PAID ) {
                invoice.Status__c = mapping.Result_Status__c;
            }
        }
    }
  }

    /*
     * Method Name: updateProjectFields
     * Description: Method To Update Project Fields When Invoice is Approved/Rejected
     * @return: void
     * @param: List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices
    */

  private static void updateProjectFields(List<Project_Invoice__c> lstProjInvoices, Map<Id, Project_Invoice__c> oldMapProjInvoices){
    set<ID> projectInvoiceIdSet = new set<ID>();
        for(Project_Invoice__c projectInvoiceRec : lstProjInvoices){
            projectInvoiceIdSet.add(projectInvoiceRec.Id);
        }
        if(projectInvoiceIdSet.size() > 0){
            list<Project_Invoice__c> requiredProjectInvoice = [SELECT Id,Project__c,Status__c,Project__r.RecordType.DeveloperName,Project__r.Invoice_Info_Requested__c ,Project__r.Approval_Date__c,Project__r.Program_Version__r.Invoice_Type__c FROM Project_Invoice__c WHERE ID in :projectInvoiceIdSet ];
                list<Project__c> projectToUpdate = new list<Project__c>();
                Project__c projectRec;
                for(Project_Invoice__c projectInvoiceRec : requiredProjectInvoice){
                    if((ProjectInvoice_Helper.STATUS_APPROVED.equalsIgnoreCase(projectInvoiceRec.Status__c) ||ProjectInvoice_Helper.STATUS_REJECTED.equalsIgnoreCase(projectInvoiceRec.Status__c) )){
                            projectRec = new Project__c();
                            projectRec.ID = projectInvoiceRec.Project__c;
                            projectRec.Invoice_Info_Requested__c = false; 
                            if(ProjectInvoice_Helper.STATUS_APPROVED.equalsIgnoreCase(projectInvoiceRec.Status__c)){
                                projectRec.Approval_Date__c = system.today();
                            }
                            projectToUpdate.add(projectRec);
                    } 

                    //Voucher based project status should be set to Closed once invoice get paid
                    if(ProjectInvoice_Helper.STATUS_PAID.equalsIgnoreCase(projectInvoiceRec.Status__c)
                        && projectInvoiceRec.Status__c != oldMapProjInvoices.get(projectInvoiceRec.Id).Status__c
                        && projectInvoiceRec.Project__r.Program_Version__r != null
                        && projectInvoiceRec.Project__r.Program_Version__r.Invoice_Type__c == Solicitation_Helper.INVOICE_VOUCHER_TYPE) {
                        projectToUpdate.add(new Project__c(Id=projectInvoiceRec.Project__c, Status__c=Project_Helper.PROJECT_STATUS_CLOSED));
                    }

                }

                if(projectToUpdate.size() > 0){
                    update projectToUpdate;
                }
        }
  }

  //********** UTILITY CLASS******************* //

   /*
     * Method Name: markTransactionLevelError
     * Description: Method To mark transaction level error
     * @return: static Transaction_Log_Detail__c
     * @param: Transaction_Log_Detail__c objLogDetail, String errorString
    */

  private static Transaction_Log_Detail__c markTransactionLevelError(Transaction_Log_Detail__c objLogDetail, String errorString) {
    if(objLogDetail != null) {
        objLogDetail.Status__c = TransactionLogDetail_Helper.STATUS_ERROR;
        objLogDetail.Error_Details_if_Any__c = objLogDetail.Error_Details_if_Any__c + ' ' + errorString;
    }
    return objLogDetail;
  }

   /*
     * Method Name: updateInvoicesAsSentToFinance
     * Description: Method To update Invoices as sent to finance
     * @return: static void
     * @param: Set<Id> invoiceIds
    */

  private static void updateInvoicesAsSentToFinance(Set<Id> invoiceIds) {
    List<Project_Invoice__c> lstInvoices = new List<Project_Invoice__c>();
    Date dtToday = Date.today();
    for(Id invoiceId : invoiceIds) {
      lstInvoices.add(new Project_Invoice__c(Id = invoiceId, Status__c = ProjectInvoice_Helper.STATUS_SENT_TO_FINANCE, Integration_Process_Date__c = dtToday));
      if(lstInvoices.size() > 1000) {
        update lstInvoices;
        lstInvoices = new List<Project_Invoice__c>();
      }
    }
    if(lstInvoices.size() > 0) {
      update lstInvoices;
    }
  }

    /*
     * Method Name: createTransactionLogRecord
     * Description:  Helper Method to create Transaction log object
     * @return: static Transaction_Log__c
     * @param: Program_Version__c objProgVersion, String transactionType, Boolean insertImmediatey
    */

  private static Transaction_Log__c createTransactionLogRecord(Program_Version__c objProgVersion, String transactionType, Boolean insertImmediatey) {
    Transaction_Log__c objTran = new Transaction_Log__c();
    if(objProgVersion != null) {
      objTran.Program_Version__c = objProgVersion.Id;
      objTran.Program__c = objProgVersion.Program__c;
      objTran.Finance_Aide_Email__c = objProgVersion.Financial_Aide_s_Email__c;
      objTran.Type__c = transactionType;
      objTran.Total_Records_Flagged__c = 0;
      objTran.Total_Records_Processed__c = 0;
      objTran.Total_Records_Sent_Successfully__c = 0;
      objTran.Total_Amount_Approved__c = 0;
      if(insertImmediatey) {
        insert objTran;
      }
    }
    return objTran;
  }

    /*
     * Method Name: createTransactionLogDetailRecord
     * Description: Method to create Transaction_Log_Detail__c record
     * @return: static Transaction_Log_Detail__c
     * @param: Id transactionLogId, Id projInvoiceId
    */

  private static Transaction_Log_Detail__c createTransactionLogDetailRecord(Id transactionLogId, Id projInvoiceId) {
    Transaction_Log_Detail__c objTranDetail = new Transaction_Log_Detail__c();
    objTranDetail.Project_Invoice__c = projInvoiceId;
    objTranDetail.Transaction_Log__c = transactionLogId;
    return objTranDetail;
  }

    /*
     * Method Name: invoiceNumber
     * Description: Method to return invoice number
     * @return: static String
     * @param: String invName
    */

  private static String invoiceNumber(String invName) {
    return ( ' - Invoice # ' + invName);
  }

   /*
     * Method Name: suffixDateStr
     * Description: Method to return suffix date
     * @return: static String
     * @param:none
    */

  private static String suffixDateStr() {
    return ( ' - ' + Datetime.now().format('YYYY-MM-dd'));
  }


//********** UTILITY CLASS******************* //


}