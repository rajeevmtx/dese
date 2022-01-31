/*
*@author Manish
*@purpose extension class for InvoiceEditView page
*/
public class CORE_Invoice_Extension {

    private String flowSource;
    private Boolean isPartOfFlow;

    private ID milestoneRecordtypeId;
    private ID invoiceId;
    private static final String INVOICE_PAGE = 'CORE_Invoice_Page';
    private static final String DOCUMENT_PAGE = 'CORE_Invoice_Documents_Page';
    private static final String ERR_MSG_UNAPPROVED_PROJECT = 'Can\'t submit Invoice for Unapproved Project.';
    private static final String MISSING_DOC_MESSAGE = 'Please upload the required documents.';

    public Map<Id, Project_Milestones__c> mapOfIdAndMilestone {get; set;}

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

    public Boolean isNew {get; set;}
    public Boolean isEdit{get; set;}
    public Project__c project{get;set;}
    public String mstTypeIncentive { get { return ProjectMilestones_Helper.MILESTONE_TYPE_NYSERDA_INCENTIVE; } }
    public Boolean isLocked { get{ return invoice.Status__c != ProjectInvoice_Helper.STATUS_DRAFT;} }

    public String projectRType {get; set;}
    public List<MilestoneWrapper> listOfMilestones {get; set;}
    public List<Project_Document__c> listOfDocuments {get; set;}

    public Map<Id, Project_Document__c> mapOfIdAndProjDoc {get; set;}

    public Boolean isPortalUser {get; set;}
    public Boolean isEditMode {get; set;}
    public Boolean isAllDeliverablesApproved {get; set;}
    public Boolean isRejectedDocumentPresent {get; set;}
    public Boolean approvAllDoc {get; set;}
    public String invoiceStatus{get; set;}

    public List<SelectOption> getStatus() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Approve','Approve'));
        options.add(new SelectOption('Reject','Reject'));
        return options;
    }

    //constructor
    public CORE_Invoice_Extension(ApexPages.StandardController ctrl){
        flowSource = Apexpages.currentPage().getParameters().get('flow');
        isPartOfFlow = flowSource != null && flowSource != '';
        milestoneRecordtypeId = ProjectMilestones_Helper.ParentMilestoneRecordType.Id;
        isPortalUser = currentUser.IsPortalEnabled;
        isEditMode = false;
        approvAllDoc = false;

        listOfMilestones = new List<MilestoneWrapper>();

        if(ctrl.getId() == null){
            isNew = true;
            invoice = new Project_Invoice__c(Company_Name__c = currentUser.Account.Name, Contact_Name__c = currentUser.Contact.Name,
                                             City__c = currentUser.Account.BillingCity, State__c = currentUser.Account.BillingState,
                                             Street__c = currentUser.Account.BillingStreet, Zip__c = currentUser.Account.BillingPostalCode,
                                             Due_Date__c = System.today() + 30, Invoice_Date__c = System.today(), Status__c = 'Draft');

            String pId = getParentId('Project__c');
            if(String.isNotBlank(pId)){
                for(Project__c proj : [SELECT Id, Name,Status__c, RecordType.name FROM Project__c WHERE Id =:pId]){
                    invoice.Project__c = proj.Id;
                    project = proj;
                }
            }

            if(invoice.Project__c != null){
                fetchMilestoneSelectOptions();
                getPrepopulatedMilestones(invoice.Project_Invoice_Lines__r);
            }
        }else{
            isNew = false;
            isEdit = false;
            invoiceId = ctrl.getId();
            fetchInvoice();
            project = invoice.Project__r;
            fetchMilestoneSelectOptions();
            getPrepopulatedMilestones(invoice.Project_Invoice_Lines__r);
            fetchDocuments();
            Set<Id> setOfMilestoneId = new Set<Id>();
            for(Project_Invoice_Line__c invLine : invoice.Project_Invoice_Lines__r){
                setOfMilestoneId.add(invLine.Milestone__c);
            }

            fetchDeliverables();
        }

    }

    public List<SelectOption> listOfProjectMilestoneSelectOptions {get; set;}

    public void fetchMilestoneSelectOptions(){
        listOfProjectMilestoneSelectOptions = new List<SelectOption>();
        if(invoice.Project__c != null){

            mapOfIdAndMilestone = new Map<Id, Project_Milestones__c>();
            for(Project_Milestones__c mst : [SELECT Id, Name, Incentive_Amount__c, Type__c FROM Project_Milestones__c WHERE Project__c = :invoice.Project__c AND RecordtypeId = :milestoneRecordtypeId]){
                mapOfIdAndMilestone.put(mst.Id, mst);
                listOfProjectMilestoneSelectOptions.add(new SelectOption(mst.Id, mst.Name));
            }
        }
    }

    private void fetchInvoice(){
        if(String.isNotBlank(invoiceId)){
            invoice = [SELECT Id, NAme,Purchase_Order__c , Project__c, Project__r.Name,Project__r.Status__c,Project__r.RecordType.Name, Invoice_Date__c, Due_Date__c, Total_Amount_Due__c,
                       Company_Name__c, Contact_Name__c, Street__c, City__c, State__c, Zip__c, Invoice_Notes__c, Status__c,Payment_Date__c,
                       (SELECT Id, Name,Requesting__c ,Date_Range_End__c, Date_Range_Start__c ,Actual_kWh__c, Invoice__c, Description__c, Amount__c, Milestone__c, Milestone__r.Name, Milestone__r.Incentive_Amount__c, Milestone__r.Type__c
                        FROM Project_Invoice_Lines__r
                        WHERE Milestone__r.RecordtypeId = :milestoneRecordtypeId ORDER BY CreatedDate)
                       FROM Project_Invoice__c WHERE Id = :invoiceId];
        }

    }

    private void fetchDocuments(){
        listOfDocuments = new List<Project_Document__c>();
        if(invoice.Id != null){
            mapOfIdAndProjDoc = new Map<Id, Project_Document__c>([SELECT Id, Name, Project_Deliverables__c, Project__c, CreatedDate, (SELECT Id, Name FROM Attachments LIMIT 1) FROM Project_Document__c WHERE Invoice__c =:invoice.Id]);
            listOfDocuments = mapOfIdAndProjDoc.values();
        }
    }

    public void addMilestone(){
        listOfMilestones.add(new MilestoneWrapper());
    }

    public void deleteMilestone(){
        if(listOfMilestones.size() > index){
            if(listOfMilestones[index].projectInvoiceLine.Id != null){
                Database.delete(listOfMilestones[index].projectInvoiceLine);
                fetchInvoice();
            }
            listOfMilestones.remove(index);
        }
    }

    public void editAll(){
        isEdit = true;
    }

    public Pagereference goToDocumentsPage(){
        Pagereference pg;
        if(isPartOfFlow){
            pg = new Pagereference('/apex/'+DOCUMENT_PAGE+'?id='+invoice.id+'&flow=' + flowSource);
        }else{
            pg = new Pagereference('/apex/'+DOCUMENT_PAGE+'?id='+invoice.id);
        }
        return pg;
    }

    public void cancelChanges() {
    	isEdit = false;
    }

    public Pagereference saveInvoiceRecord(){
        Pagereference pg;
        Savepoint sp = Database.setSavepoint();
        try{
            Database.upsert(invoice);
            if(project!=null)
                Database.update(project);

            if(invoice.id != null){
                saveMilestones();
                if(isPartOfFlow && invoice.Status__c == ProjectInvoice_Helper.STATUS_PENDING_REVIEW){
                    pg = PageNavigationUtility.getNextPageURL(invoice.Project__c, flowSource, null);
                }else if(isPartOfFlow){
                    pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id+'&flow=' + flowSource);
                }else{
                    pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id);
                }
                pg.setRedirect(true);
            }
        }catch(DMLException e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return pg;
    }

    public void updateListOfMilestones(){
        for(MilestoneWrapper mst : listOfMilestones){
            if(mst.projectInvoiceLine.Requesting__c!=null){
                Integer percentage = Integer.valueof(mst.projectInvoiceLine.Requesting__c.removeEnd('%'));
                if(mst.projectInvoiceLine.Milestone__c != null && mapOfIdAndMilestone.containsKey(mst.projectInvoiceLine.Milestone__c)){
                    if(mapOfIdAndMilestone.get(mst.projectInvoiceLine.Milestone__c).Incentive_Amount__c!=null)
                    mst.projectInvoiceLine.Amount__c = mapOfIdAndMilestone.get(mst.projectInvoiceLine.Milestone__c).Incentive_Amount__c * percentage/100;
                }
            }else if(mst.projectInvoiceLine.Amount__c == null){
                mst.projectInvoiceLine.Amount__c = mapOfIdAndMilestone.get(mst.projectInvoiceLine.Milestone__c).Incentive_Amount__c;
            }
        }
    }

    public void saveMilestones(){
        List<Project_Invoice_Line__c> listToUpdate = new List<Project_Invoice_Line__c>();
        for(MilestoneWrapper mst : listOfMilestones){
            if(mst.projectInvoiceLine.Milestone__c != null){
                if(mst.projectInvoiceLine.Invoice__c == null)
                    mst.projectInvoiceLine.Invoice__c = invoice.Id;
                listToUpdate.add(mst.projectInvoiceLine);
            }
        }
        if(listToUpdate.size() > 0)
            Database.upsert(listToUpdate);
        fetchInvoice();

    }

    public PageReference submitForReview(){
        Pagereference pg;
        if(isRequiredDocumentMissing()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MISSING_DOC_MESSAGE));
            return null;
         }/*else if(invoice.Project__r.Status__c != Project_Helper.PROJECT_STATUS_APPROVED){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERR_MSG_UNAPPROVED_PROJECT));
             return null;
         }*/
        else{
            invoice.Status__c = ProjectInvoice_Helper.STATUS_PENDING_REVIEW;
            Database.update(invoice);
            if(isPartOfFlow && invoice.Status__c == ProjectInvoice_Helper.STATUS_PENDING_REVIEW){
                pg = PageNavigationUtility.getNextPageURL(invoice.Project__c, flowSource, null);
            }else if(isPartOfFlow){
                pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id+'&flow=' + flowSource);
            }else{
                pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id);
            }
            pg.setRedirect(true);
        }
        return pg;
    }

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



    // @RemoteAction
    // public static List<Project__c> fetchListOfProjects(String searchText){
    //     return [SELECT Id, Name FROM Project__c WHERE Name LIKE :searchText+'%' LIMIT 20];
    // }

    private void getPrepopulatedMilestones(List<Project_Invoice_Line__c> localListOfInvoices){
        if(listOfMilestones!=null && localListOfInvoices.size() > 0){
            for(Project_Invoice_Line__c invoice : localListOfInvoices){
                MilestoneWrapper milestone = new MilestoneWrapper();
                milestone.projectInvoiceLine = invoice;
                listOfMilestones.add(milestone);
            }

        }else{
            for(Project_Milestones__c mst : mapOfIdAndMilestone.values()){
                if(mst.Type__c == mstTypeIncentive){
                    MilestoneWrapper milestone = new MilestoneWrapper();
                    milestone.projectInvoiceLine = new Project_Invoice_Line__c(Milestone__c = mst.id, Amount__c = mst.Incentive_Amount__c);
                    listOfMilestones.add(milestone);
                }
            }
        }
    }

    //Milestone Wrapper
    public class MilestoneWrapper{
        public Project_Invoice_Line__c projectInvoiceLine{get;set;}
        public String purchaseOrder{get;set;}
        public Decimal totalDue{get;set;}
        public Date installationDate {get;set;}
        public Date utilityInterconnectDate{get;set;}
        public Date dateRange{get;set;}
        public Decimal actualKWH{get;set;}
        MilestoneWrapper(){
            projectInvoiceLine =  new Project_Invoice_Line__c();
        }
    }



    public Map<Id, Boolean> mapOfDeliverableIdAndRequiredStatus {get; set;}
    public Map<Id, Project_Deliverables__c> mapOfIdAndDeliverables {get; set;}
    public Map<Id, Project_Document__c> mapOfIdAndDocuments {get; set;}
    public List<Project_Milestones__c> listOfProjectMilestones {get; set;}
    public Map<Id, Attachment> mapOfDeliverableIdAndAttachment {get; set;}


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

        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>([SELECT Id, Name, Status__c, CreatedDate,
                                                                      (SELECT Id, Name , Version__c, Notes__c,
                                                                       CreatedDate, CreatedBy.Name, Status__c
                                                                       FROM Project_Documents__r ORDER BY CreatedDate desc)
                                                                      FROM Project_Deliverables__c
                                                                      WHERE Id IN :mapOfDeliverableIdAndAttachment.keySet()]);


        mapOfIdAndDocuments = new Map<Id,Project_Document__c>([SELECT Id, Name, Project_Deliverables__c, Version__c, Notes__c, Status__c, CreatedDate, CreatedBy.Name,
                                                              (SELECT Id, Name, BodyLength FROM Attachments LIMIT 1)
                                                              FROM Project_Document__c
                                                              WHERE Project_Deliverables__c IN :mapOfDeliverableIdAndAttachment.keySet() ]);

        isAllDeliverablesApproved = true;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(mapOfDeliverableIdAndRequiredStatus.containsKey(projDeliverablesRec.Id)){
                if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c != 'Approve') {
                    isAllDeliverablesApproved = false;
                    break;
                }
            }
        }

        isRejectedDocumentPresent = false;
        for(Project_Deliverables__c projDeliverablesRec : mapOfIdAndDeliverables.values()) {
            if(projDeliverablesRec.Project_Documents__r.size() > 0 && projDeliverablesRec.Project_Documents__r[0].Status__c == 'Reject') {
                isRejectedDocumentPresent = true;
                break;
            }
        }
    }

    public PageReference setInvoiceStatus() {
        invoice.Status__c = invoiceStatus;
        update invoice;

        return goToMainInvoicePage();
    }

    public PageReference setEditMode() {
        isEditMode = true;
        fetchDeliverables();
        return null;
    }

    public PageReference cancelChangesOfApprovalProcess() {
        fetchDeliverables();
        isEditMode = false;
        return null;
    }

    public Pagereference saveProjectDocuments() {
        List<Project_Document__c> docListToUpdate = new List<Project_Document__c>();
        List<Project_Deliverables__c> projDeliverablesListToUpdate = new List<Project_Deliverables__c>();

        for(Project_Deliverables__c projDeliverableRec : mapOfIdAndDeliverables.values()) {
            Project_Document__c projDocumentRec = new Project_Document__c();
            if(approvAllDoc && projDeliverableRec.Project_Documents__r.size() > 0) {
                projDocumentRec.Status__c = 'Approve';
                projDocumentRec.Id = projDeliverableRec.Project_Documents__r[0].Id;
                projDocumentRec.Notes__c = projDeliverableRec.Project_Documents__r[0].Notes__c;
                docListToUpdate.add(projDocumentRec);
            } else if(projDeliverableRec.Project_Documents__r.size() > 0 && projDeliverableRec.Project_Documents__r[0].Status__c != null) {
                if(mapOfDeliverableIdAndRequiredStatus.containsKey(projDeliverableRec.Id)){
                    docListToUpdate.add(projDeliverableRec.Project_Documents__r[0]);
                }
            }
        }

        if(docListToUpdate.size() > 0) {
            update docListToUpdate;
        }

        isAllDeliverablesApproved = true;
        for(Project_Document__c projDocumentRec : docListToUpdate) {
            if(projDocumentRec.Status__c != 'Approve') {
                isAllDeliverablesApproved = false;
                break;
            }
        }

        isRejectedDocumentPresent = false;
        for(Project_Document__c projDocumentRec : docListToUpdate) {
            if(projDocumentRec.Status__c == 'Reject') {
                isRejectedDocumentPresent = true;
                break;
            }
        }

        isEditMode = false;
        return null;
    }

    public PageReference saveDocuments(){
        List<Project_Document__c> listOfProjectDocumentToInsert = new List<Project_Document__c>();
        List<Attachment> listOfAttachmentToUpsert = new List<Attachment>();
        Savepoint sp = Database.setSavepoint();
        Project_Document__c localDoc;
        try{
            for(Id dId : mapOfDeliverableIdAndAttachment.keySet()){
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
            Database.upsert(listOfAttachmentToUpsert);
            return goToMainInvoicePage();
        }catch(Exception e){
            throw e;
            Database.rollback(sp);
        }

        return null;
    }

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

    public PageReference goToMainInvoicePage(){
        Pagereference pg;
        if(isPartOfFlow){
            pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id+'&flow=' + flowSource);
        }else{
            pg = new Pagereference('/apex/'+INVOICE_PAGE+'?id='+invoice.id);
        }
        pg.setRedirect(true);
        return pg;
    }

}