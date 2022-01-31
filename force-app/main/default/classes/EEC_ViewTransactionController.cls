public without sharing class EEC_ViewTransactionController implements EEC_AssistantInterface
{
  public Id ltId { get; set; }
  public Account provider { get; set; }
  public Licensing_Transaction__c licenseTransation { get; set; }
  public String licenseRecordTypeName { get; set; }
  public String licenseRecordTypeLabel { get; set; }
  public List<Household_Member__c> ihmList { get; set; }
  //public List<FCC_Assistant__c> faList {get;set;}
  public List<Employment_History__c> ehList { get; set; }
  public List<Room__c> roomList { get; set; }
  public List<Training_Experience__c> teList { get; set; }
  public Integer rowNum { get; set; }
  public List<String> selectedHestElems { get; set; }
  public String selectedHestStr { get; set; }
  public String memberId { get; set; }
  public List<Variance_on_Regulation__c> varianceList {get;set;}

  public List<S3_File__c> attachments { get; set; }

  public EEC_ViewTransactionController() {
    ltId = ApexPages.currentPage().getParameters().get('ltID');
    memberId = ApexPages.currentPage().getParameters().get('member');
    getLicenseTrans();
  }

  public void getLicenseTrans() {
    List<Licensing_Transaction__c> ltList = [Select id From Licensing_Transaction__c l where Id = :ltId];

    if (ltList != null && ltList.size() > 0) {
      licenseTransation = ltList.get(0);
      licenseRecordTypeName = licenseTransation.RecordType.DeveloperName;
      licenseRecordTypeLabel = licenseTransation.RecordType.Name;
      provider = [select Id, Recordtype.DeveloperName, RecordType.Name, License_Status__c, First_Issue_Date__c, Renewal_date__c, Provider_Status__c, capacity__c,
                  Accept_Referral__c, Can_Communicate_in_English__c, PPM_Meeting_Attended_Date__c,
                  ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Unlisted_Phone_Number__c, Alternate_Phone__c, Fax, Provider_Email__c,
                  Provider_Address_1__c, Provider_Address_2__c, Provider_City__c, Provider_Zip_Code__c, Live_at_this_address__c, Language__c, Preferred_Language__c
                  from Account where Id = :licenseTransation.Provider__c];

      ihmList = [Select Id, Provider__c, Licensing_Transactions__c, Current__c, First_Name__c, Last_Name__c, Date_of_Birth__c, Relationship_to_Provider__c, Occupation__c, Number_of_Hours_Home_During_Child_Care__c, Current_School_Grade__c, Email_Address__c From Household_Member__c where Licensing_Transactions__c = :licenseTransation.Id];
      ehList = [Select Name, Contact__c, Licensing_Transaction__c, Position__c, Start_Date__c, End_Date__c, Reason_for_Leaving__c, Employer__c, Employer_Address__c, Employer_Phone__c From Employment_History__c where Licensing_Transaction__c = :licenseTransation.Id];
      roomList = [Select Id, Name, Source_Transaction__c, Current__c, Use__c, Dimension_Length_feet__c, Dimension_Width_feet__c, Dimension_Square_Feet__c, Floor_Level__c, Provider_Name__c From Room__c where Source_Transaction__c = :licenseTransation.Id];
      teList = [Select Id, Name, Contact__c, Licensing_Transactions__c, Topic__c, Date_of_the_Training__c, Number_of_Training_Hours__c From Training_Experience__c where Licensing_Transactions__c = :licenseTransation.Id];
     // varianceList = [SELECT Id, Associated_Regulation__r.Name,Associated_Regulation__r.Regulation_Number__c, ProviderType__c, Associated_Regulation__r.Article__c, current__c, Provider_Understanding_of_Regulation__c,isCopied__c  
         //  From Variance_on_Regulation__c where Source_Transaction__c = :licenseTransation.Id];
           
      if (String.isNotEmpty(licenseTransation.Heating_Elements__c)) {
        selectedHestElems = licenseTransation.Heating_Elements__c.split(';');
      }
      refreshAttachmentsList();
    }
    else {
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Provide a valid Licensing Transaction Id');
      ApexPages.addMessage(msg);
      return;
    }
  }

  public Pagereference CancelTransaction() {
    licenseTransation.Status__c = 'Cancelled';
    licenseTransation.Status_Reason__c = 'Applicant withdrew';
    licenseTransation.Reason_Closed_Cancelled__c = 'Cancelled by portal user';
    update licenseTransation;

 //   PageReference pPage = page.EEC_PortalProviderPage;
    //if (memberId != null)
    //pPage.getParameters().put('member', EEC_Util.encryptGetParam(memberId));
    //return pPage;
    return null;
  }

  public Pagereference backInstruction() {
    //PageReference pPage = page.EEC_PortalProviderPage;
   // if (memberId != null)
   // pPage.getParameters().put('member', EEC_Util.encryptGetParam(memberId));
   // return pPage;
    return null;
  }

  public Pagereference editInstruction() {
    /*PageReference pPage = EEC_Util.lastStepMap.get(licenseTransation.Last_Reached_Step__c);
    pPage.getParameters().put('ltId', licenseTransation.Id);
    pPage.getParameters().put('accountId', provider.Id);
    return pPage;*/
     return null;
}
   
  public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption> ();
    options.add(new SelectOption('Yes', 'Yes'));
    options.add(new SelectOption('No', 'No'));
    return options;
  }

  public List<SelectOption> getHeatingElements() {

    List<SelectOption> hElements = new List<SelectOption> ();
    Schema.DescribeFieldResult fieldResult = Licensing_Transaction__c.Heating_Elements__c.getDescribe();
    list<schema.picklistentry> values = fieldResult.getPickListValues();
    for (Schema.PicklistEntry a : values)
    {
      hElements.add(new SelectOption(a.getValue(), a.getLabel()));
    }
    return hElements;
  }
  
  /**
   * refreshAttachmentsList
   * 
   * This function will collect all the attachments for the transaction and store them into a list for use on the attachment page.
   * @author Darkis 
   */
  public List<S3_File__c> refreshAttachmentsList() {
    attachments = new List<S3_File__c> ();
    /*List<FileMap__c> fileMappings = [Select Id, S3_File__r.Id, S3_File__r.CreatedDate, S3_File__r.Filename__c From FileMap__c Where Object_Id__c = :licenseTransation.Id];
    System.debug('----> Transaction ID: ' + licenseTransation.Id);
    System.debug('----> File Mappings: ' + fileMappings);
    if (fileMappings.size() > 0) {
      Set<Id> fileIds = new Set<Id> ();

      for (FileMap__c filemap : fileMappings) {
        fileIds.add(filemap.S3_File__r.Id);
      }*/
      attachments = [Select Id, Filename__c, Content_Type__c, CreatedDate From S3_File__c Where Object_Id__c = :licenseTransation.Id];
      System.debug('----> All Files: ' + attachments);
      return attachments;
    //}
  }

  /**
   * getCtrlInstance
   * 
   * This function will return an instance of this controller with interface reference.
   * @author Darkis
   * @return EEC_ViewTransactionController
   */
  public EEC_ViewTransactionController getCtrlInstance() {
    return this;
  }

  /*-----Interface Methods-----*/


  public Licensing_Transaction__c getBaseLicenseTransaction() {
   return licenseTransation;
  }

  public String getBaseLicenseRecordTypeName() {
    return licenseRecordTypeName;
  }
}