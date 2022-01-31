/*
* Name: CORE_Invoice_Router_Extension
* Author:  Manish Kumar
* Desc: purpose extension class for NYSERDA_Invoice_ page
* Date:  6/7/2016
*   Date         New/Modified    User                   Description
* 08/06/2017     Modified       Rajat Jain     Added the routing condition for CEEP Invoicing (T-02913)
* 09/19/2017     Modified       Rajesh Keerthi     Added the routing condition for LSR Invoicing
*/

public class CORE_Invoice_Router_Extension {
    private FINAL String LSR_INVOICE_PAGE = 'LSR_Invoice_Page';
    private FINAL String CORE_INVOICE_PAGE = 'CORE_Invoice_Page';
    private FINAL String RTEM_INVOICE_PAGE = 'RTEM_Invoice_Page';
    private FINAL String NYSUN_INVOICE_PAGE = 'NYSUN_Invoice_Page';
    private FINAL String CT_INVOICE_PAGE = 'CT_Invoice_Page';
    private FINAL String ZEV_INVOICE_PAGE = 'ZEV_Invoice_Page';
    private FINAL String CHP_INVOICE_PAGE = 'CHP_Invoice_Page';
    private FINAL String CEC_INVOICE_PAGE = 'CEC_Invoice_Page';
    private FINAL String CEEP_INVOICE_PAGE = 'CEEP_Invoice_Page';
    private FINAL String CTenant_INVOICE_PAGE = 'CTenant_Invoice_Page';
    private FINAL String CORE_MILESTONE_INVOICE_PAGE = 'CORE_Milestone_Invoice_Page';

    public final String LSR_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Large_Scale_Renewables';
    public final String RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Residential';
    public final String COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'NY_Sun_Commercial';
    public final String COMMERCIAL_RTEM_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Commercial_Real_Time_Energy_Management';
    public final String PS_RECORD_TYPE_DEVELOPER_NAME = 'RHNY_Pellet_Stove';
    public final String ZEV_RECORD_TYPE_DEVELOPER_NAME = 'Zero_Emission_Vehicles';
    public final String CHP_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Onsite_Power_Combined_Heat_and_Power';
    public final String CEC_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Communities_Local_Government_Clean_Energy_Community';
    public final String CTenant_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Commercial_Tenant';
    public final String GSHP_SMALL_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'GSHP_Small_System';
    public final String GSHP_LARGE_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'GSHP_Large_System';
    public final String CEEP_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Community_Energy_Engagement_Program_Outreach';   //T-02913 (RJ:08/06/2017)
    public final String CEC_GRAND_AWARD_PROJECT_RECORD_TYPE_DEVELOPER_NAME = 'Communities_Local_Government_Clean_Energy_Communities_Grant_Award';

    public Project_Invoice__c invoice {get; set;}
    public Project__c project{get;set;}
    private ID invoiceId;

    public Boolean showError {get; private set;}
    public String  errorMessage {get; private set;}

    public Boolean is_CTenant{ get{return project.RecordType.DeveloperName == CTenant_PROJECT_RECORD_TYPE_DEVELOPER_NAME;} set;}
    public Boolean is_CT_MILESTONE { get{return (Clean_Transportation_Helper.ctRecordtypeexist(project.recordtypeid) && project.Budget_Type__c == Project_Helper.BUDGET_TYPE_MILESTONE) ;}set;}
    public Boolean is_CT_TNM { get{return (Clean_Transportation_Helper.ctRecordtypeexist(project.recordtypeid) && project.Budget_Type__c == Project_Helper.BUDGET_TYPE_TnM);}set;}
    public Boolean is_CEEP{ get{return project.RecordType.DeveloperName == CEEP_PROJECT_RECORD_TYPE_DEVELOPER_NAME;} set;}      //T-02913 (RJ:08/06/2017)
    public Boolean is_CEC_GRAND_AWARD{ get{return project.RecordType.DeveloperName == CEC_GRAND_AWARD_PROJECT_RECORD_TYPE_DEVELOPER_NAME;} set;}
    private String controllerId;
    //constructor
    public CORE_Invoice_Router_Extension(ApexPages.StandardController ctrl){
      showError = false;
      errorMessage = '';
      controllerId = ctrl.getId();
    }

     /*
      * Method Name: invoiceRedirect
      * Description: Method redirecting invoice
      * @return:  pageReference
      * @param: None
     */

    public pageReference invoiceRedirect(){

        if( controllerId == null){
            invoice = new Project_Invoice__c();
            String pId = getParentId('Project__c');
            if(String.isNotBlank(pId)){
                for(Project__c proj : [SELECT Name, Status__c, RecordTypeId,RecordType.Name,
                                              RecordType.DeveloperName, Budget_Type__c
                                         FROM Project__c
                                        WHERE Id =:pId]) {
                    invoice.Project__c = proj.Id;
                    project = proj;
                }
            } else {
              showError = true;
              errorMessage = Label.CORE_Invoice_Tab_New_Button_Error_Message;
              return null;
            }
        }else{
            invoiceId = controllerId;
            fetchInvoice();
            project = invoice.Project__r;
        }
        PageReference redirectPageRef ;

        /*
          Any data that are migrated (invoices) we don't want them to go to our invoice UI.
          We should redirect them to the standard layout.
          Any invoice created in salesforce will go to our branded UI.
        */

        if(invoiceId != null && invoice != null && invoice.Id != null && invoice.Legacy__c) {

          // View Mode
          if(Apexpages.currentPage().getParameters().get('retURL') == null) {
            redirectPageRef = new PageReference('/'+invoiceId+'?nooverride=1&');
          } else {
            // Edit Mode
            redirectPageRef = new PageReference('/'+invoiceId+'/e?nooverride=1&');
          }


        } else {
            if(is_CT_MILESTONE){
              redirectPageRef = new PageReference('/apex/'+CORE_MILESTONE_INVOICE_PAGE+'?');
            }else if(is_CT_TNM){
              redirectPageRef = new PageReference('/apex/'+CT_INVOICE_PAGE+'?');
            }else if(is_CTenant) {
              redirectPageRef = new PageReference('/apex/'+CTenant_INVOICE_PAGE+'?projectId='+project.Id+'&');
            } else if(is_CEC_GRAND_AWARD){
             redirectPageRef = new PageReference('/apex/'+CORE_MILESTONE_INVOICE_PAGE+'?projectId='+project.Id+'&');
            }
            else{
                redirectPageRef = new PageReference('/apex/'+CORE_INVOICE_PAGE+'?');
            }
        }
        Map<String, String> parameterMap = Apexpages.currentPage().getParameters();
        for(String pgParam : parameterMap.keySet()){
            redirectPageRef.getParameters().put(pgParam,parameterMap.get(pgParam));
        }
        return redirectPageRef;

    }

     /*
      * Method Name: fetchInvoice
      * Description: Method fetching invoice
      * @return:  void
      * @param: None
      */

    private void fetchInvoice(){
        if(String.isNotBlank(invoiceId)){
            invoice = [SELECT Id, Name, Purchase_Order__c, Project__c, Project__r.Name, Project__r.Budget_Type__c,
                              Project__r.RecordType.Name, Project__r.RecordType.DeveloperName, Legacy__c
                         FROM Project_Invoice__c WHERE Id = :invoiceId];
        }

    }

    /*
     * Method Name: getParentId
     * Description: Method getting parent id
     * @return:  String
     * @param: String objectName
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
}