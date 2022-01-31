public with sharing class EEC_DesignationOfAdministrativeCtrl {
  public Licensing_Transaction__c licenseTransation             {get; set;}
  public List<Transaction_Contact__c> contactlist               {get; set;}
  public String applicationDisplayName                          {get; set;}
  public LEAD_Configuration__c leadConfiguration                {get; set;}
  public String licenseRecordTypeName                           {get; set;}
  public String licenseRecordTypeLabel                          {get; set;}
  public User loggedUser                                        {get; set;}
  public String highestStepReached                              {get; set;}
  public String previousPageName                                {get; set;}
  public Boolean isSaveOnly                                     {get; set;}
  public String selectedTransactionContactId                    {get; set;}
  public Transaction_Contact__c contactRec                      {get; set;} 
  public List<String> ownershipTypeList;
  public String ltId;
  public List<SelectOption> options                             {get;set;}
  public Set<Id> transactionContactIds;
  Map<String,String> mapOfTC;
  public Boolean schoolAgeNotApplicable;
  public String schoolAgeNotApplicableNotes;
  public Boolean kinderGartenNotApplicable;
  public String kinderGartenNotApplicableNotes;
  public Boolean earlyEducationApplicable;
  public String earlyEducationApplicableNotes;
  public Boolean infantToddlerApplicable;
  public String  infantToddlerApplicableNotes;
  public Boolean isSubmitted                                    {get;set;}
  public string accountId                                       {get;set;}
  public string accountName                                     {get;set;}
  public string memberId                                        {get;set;}
  public boolean isInternalUser                                 {get;set;}
  public EEC_DesignationOfAdministrativeCtrl() {
    ltId = ApexPages.currentPage().getParameters().get('ltId');
    memberId = ApexPages.currentPage().getParameters().get('member');
    licenseTransation = new Licensing_Transaction__c();
    contactlist = new List<Transaction_Contact__c>();
    leadConfiguration = new LEAD_Configuration__c();
    options = new List<SelectOption>();
    options.add(new SelectOption('','--None--'));
    transactionContactIds =new Set<Id> ();
    isSubmitted = false;
        isInternalUser = false;
    String contactName;
    for(Transaction_Contact__c transObj:[SELECT Id,Name,First_Name__c,Last_Name__c,Infant_Toddler_Program__c,Social_Services__c,
                        Parent_Involvement__c,Staff_Supervision__c,Staff_Orientation__c,Staff_Training__c,Staff_Development__c,
                        Equipment__c,Daily_Activities__c,Services_for_children_with_disabilities__c,School_Age__c,Kindergarten__c,
                        Early_childhood_education_program__c,Staff_Schedules__c,Financial_Documentation__c,Children_s_Records__c,
                        Personnel_Records__c,Records__c,Account_books__c,Licensing_Transaction__c,
                        Licensing_Transaction__r.School_Age_Not_Applicable__c,Licensing_Transaction__r.School_Age_Not_Applicable_Notes__c
                       FROM Transaction_Contact__c 
                       WHERE Licensing_Transaction__c=:ltId]){
      transactionContactIds.add(transObj.Id);                     
      contactName = transObj.First_Name__c+' '+transObj.Last_Name__c;
      options.add(new SelectOption(transObj.id,contactName));  
    }
    isSaveOnly = false;
    List<Licensing_Transaction__c> transList = [SELECT Name, Highest_Reached_Step__c, RecordType.DeveloperName, RecordType.Name, Provider__r.RecordType.Name,Status__c,Provider__c,Provider__r.Name,
                                                              Accounts_Responsible__c,Personnel_Records_Responsible__c,Records_Responsible__c,providerRecordTypeDeveloperName__c,transactionRecordTypeDeveloperName__c,
                                                              Children_Records_Responsible__c,Financial_Documentation_Responsible__c,Early_Childhood_Education_Program_Resp__c,
                                                              Kindergarten_Responsible__c,School_age_Responsible__c,Services_4_Disable_children_Responsible__c,Kindergarten_Not_Applicable_Notes__c,
                                                               Daily_activities_Responsible__c,Equipment_Responsible__c,Staff_Development_Responsible__c,School_Age_Not_Applicable_Notes__c,
                                                              Staff_Orientation_Responsible__c,Staff_Schedule_Responsible__c,Staff_Supervision_Responsible__c,Parent_Involvement_Responsible__c,
                                                              Infant_Toddler_Program_Responsible__c ,Staff_Training_Responsible__c,Social_Services_Responsible__c,Early_childhood_education_program_N_A__c,
                                                              Kindergarten_Not_Applicable__c,School_Age_Not_Applicable__c,Infant_Toddler_Not_Applicable__c,Early_childhood_edu_program_N_A_Notes__c,
                                                              Infant_Toddler_Not_Applicable_Notes__c,
                                (Select First_Name__c, Last_Name__c, Contact__c from Transaction_Contacts__r)  
                             FROM Licensing_Transaction__c WHERE Id =: ltId];
    if(transList.size() > 0) {
      licenseTransation = transList[0];
      accountId = transList[0].Provider__c;
      accountName = transList[0].Provider__r.Name; 
      contactlist = licenseTransation.Transaction_Contacts__r;
      licenseRecordTypeName = licenseTransation.RecordType.DeveloperName;
      licenseRecordTypeLabel = licenseTransation.RecordType.Name;
      highestStepReached = licenseTransation.Highest_Reached_Step__c;
    }
    checkLicenseStatus();
    if(String.isNotBlank(ltId) && String.isNotBlank(licenseTransation.transactionRecordTypeDeveloperName__c)){
          leadConfiguration = [Select Application_Display_Name__c from LEAD_Configuration__c where Name =: licenseRecordTypeLabel];
          applicationDisplayName = leadConfiguration.Application_Display_Name__c;
        }
        loggedUser = [select Id, Name, contactId, UserType from User where Id = :UserInfo.getUserId()];
        if(loggedUser.contactId == null){
           isInternalUser = true; 
        }
  }
   private void checkLicenseStatus(){
      if(licenseTransation.Status__c == EEC_Constants.LT_SUBMITTED || licenseTransation.Status__c == EEC_Constants.LT_CLOSED || licenseTransation.Status__c == EEC_Constants.LT_UNDER_REVIEW){
        isSubmitted = true;
      }
    }
 @TestVisible private PageReference getCurrentPageReference() {
        if(memberId != null){
          Pagereference pg = new Pagereference('/apex/EEC_DesignationOfAdministrative?ltId=' + ltId+'&member='+memberId);
           pg.setRedirect(true);
          return pg;
         }else{
           Pagereference pg = new Pagereference('/apex/EEC_DesignationOfAdministrative?ltId=' + ltId);
           pg.setRedirect(true);
          return pg;
         }
    }
  public PageReference SaveAndPreviousDesign() {
        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DESIGNATION_ADMIN_RESPONSIBILITY;
        PageReference pPage;
        if(string.IsNotBlank(previousPageName)){
            if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC){
                pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT){
                pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella' ){
                pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
            }
            else if(licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                    || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                pPage = EEC_Util.lastRPStepMap.get(previousPageName);
            }else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_PRIVATE_SCHOOL || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_PUBLIC_SCHOOL){
                pPage = EEC_Util.lastCBCStepMap.get(previousPageName);

            }else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SUMMER_CAMP){
              //  pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
            }
        }
        else{
                pPage = page.EEC_OwnershipAdministratorInfo;
            }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        if(memberId != null){
          pPage.getParameters().put('member', memberId);
        }
        pPage.setRedirect(true);
        return pPage;        
    }
    
    public Pagereference closeAndreturnToHome() {
        if(!isInternalUser){
            PageReference pPage;
            pPage = Page.EEC_PortalLandingPage;
            pPage.setRedirect(true);
            return pPage;
        }else{
            PageReference pPage = new PageReference('/' + licenseTransation.Id);
            return pPage;  
        }
    }
    public PageReference SaveAndNextDesign() {


        PageReference pPage;
        if(LicenseRecordTypeName == EEC_Constants.LT_GSA_NEW_LICENSE
                ||LicenseRecordTypeName == EEC_Constants.LT_GSA_MOVE
                ||LicenseRecordTypeName == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                ||LicenseRecordTypeName == EEC_Constants.LT_GSA_RENEWAL
                ||LicenseRecordTypeName == EEC_Constants.LT_GSA_LICENSE_CHANGE
                || LicenseRecordTypeName == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                || LicenseRecordTypeName == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION){
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_CAPACITY_INFO;
            pPage = page.EEC_CapacityInformation;
            if(isSaveOnly){
                pPage = page.eec_designationofadministrative;
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DESIGNATION_ADMIN_RESPONSIBILITY;
            }
        }else if(LicenseRecordTypeName == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY){
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
            pPage = page.EEC_LicensingAttachment;
            if(isSaveOnly){
                pPage = page.eec_designationofadministrative;
                licenseTransation.Last_Reached_Step__c =  EEC_Constants.LT_LAST_REACHED_DESIGNATION_ADMIN_RESPONSIBILITY;
            }
        }
        if(!isSubmitted){
            update licenseTransation;
        }
        pPage.getParameters().put('ltId', licenseTransation.Id);
        if(memberId != null){
            pPage.getParameters().put('member', memberId);
        }
        //addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
        // }catch(Exception e) {
        //    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
        //    ApexPages.addMessage(errMsg);
        //    System.Debug('Error from SaveAndNextDesign: ' + e.getMessage());
        // }
        return null;
    }


    
    public PageReference SaveOnly() {
        if(!isSubmitted){
            update licenseTransation;
        }
        // }catch(Exception e) {
        //    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage());
        //    ApexPages.addMessage(errMsg);
        // }
        return null;
    }
    public PageReference populatedata(){
       return null;
    }
}