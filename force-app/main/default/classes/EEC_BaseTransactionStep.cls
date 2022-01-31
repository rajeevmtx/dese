/**
* EEC_BaseTransactionStep
*
* @author mdarkis@incapsulate.com/matt.darkis@bluespurs.com
* @description  This class will represent the base class for any Transaction wizard step. It contains
*                 all required base functions used accross all pages. 
* @created 26 Jan 2016
*/
public abstract with sharing class EEC_BaseTransactionStep {
  
  protected final Integer SAVE_AND_NEXT = 1;
  protected final Integer SAVE_AND_PREVIOUS = 2;
  protected final Integer SAVE_AND_RETURN = 3;
  protected final Integer MODE_REVIEW = 4;
  protected final Integer SAVE_AND_RETURN_TO_SAME_PAGE = 5;
  // General Variables
  public Account provider { get; set; }
  public LEAD_Configuration__c leadConfiguration { get; set; }
  public Contact primaryContact { get; set; }
  public String memberId { get; set; } 
  public final Boolean isFccAssistant { get; set; }
  // Transaction Variables
  public Licensing_Transaction__c licenseTransaction { get; set; }
  public String licenseRecordTypeName { get; set; }
  public String licenseRecordTypeLabel { get; set; }
  public String licenseInstructionMessage { get; set; }
  public String formattedLicenseRecordTypeLabel { get; set; }
  // File Attachments Variables.
  public String attachmentsJson { get; set; }
  public List<S3_File__c> attachments { get; set; }
  public List<S3_File__c> transactionAttachments { get; set; }
  public Map<String, Map<String, String>> transactionAttachmentsMap { get; set; }
  public Map<Id, String> transactionAttachmentsUrlMap { get; set; }
  // AWS Variables
  public final String accessKey { get; set; }
  public static final String awsCredentialName = 'eec';
  public static final String bucketName = 'eec-lead';
  public static final String bucketItemAccess = 'authenticated-read';
  public String highestStepReached {get; set;}

  /**
   * EEC_BaseTransactionStep
   *
   * @description This constructor will setup the transaction and it's provider for use in the pages.
   * @author Darkis
   * @created 26 Jan 2016
   * @return EEC_BaseTransactionStep 
   */
  public EEC_BaseTransactionStep() {
    // Get the GET params from the url.
    String ltId = ApexPages.currentPage().getParameters().get('ltId');
    memberId = ApexPages.currentPage().getParameters().get('member');
    String accountId = '';

    // If the member string, umbrella member, is set then make it the account ID.
    if (String.isNotBlank(memberId)) {
      accountId = memberId;
    } else {
      List<Account> tempAccount = [SELECT Id FROM Account WHERE Id IN(SELECT Accountid FROM User WHERE id = :Userinfo.getUserId()) Limit 1];

      if (tempAccount != null && tempAccount.size() == 1) {
        accountId = tempAccount.get(0).Id;
      }
    }
    // Set the account ID to the params if there is non currently available. 
    if (String.isBlank(accountId)) {
      accountId = ApexPages.currentPage().getParameters().get('accountId');
    }
    // Retrieve the active provider. 
    provider = [SELECT
                Id, License_Type__c, Recordtype.DeveloperName, RecordType.Name, License_Status__c, First_Issue_Date__c, Renewal_date__c, Provider_Status__c,
                Accept_Referral__c, Can_Communicate_in_English__c, PPM_Meeting_Attended_Date__c, capacity__c,
                ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Unlisted_Phone_Number__c, Alternate_Phone__c, Fax, Provider_Email__c,
                Provider_Address_1__c, Provider_Address_2__c, Provider_City__c, Provider_City__r.Name, Provider_Zip_Code__c, Live_at_this_address__c, Language__c, Preferred_Language__c, Race__c,
    (SELECT Id, Status__c, RecordType.DeveloperName, Took_FCC_Orientation__c FROM Licensing_Transactions__r order BY CreatedDate DESC)
                FROM Account
                WHERE Id = :accountId
               ];
    // Get the 'Main Contact' for the provider if there is one. 
    List<Contact> conList = [SELECT
                             FirstName, LastName, BirthDate, MobilePhone, Prof_Qualification_Reg_Number__c
                             FROM Contact
                             WHERE AccountId = :provider.Id AND Role__c LIKE 'Main Contact%' ORDER BY CreatedDate DESC LIMIT 1
                            ];
    // Set the primary contact.
    if (conList != null && conList.size() > 0) {
      primaryContact = conList.get(0);
    }
    // Get the LEAD configuration for the current provider type.
    leadConfiguration = [Select
                         Visit_Narrative_Summary_Default__c, SystemModstamp, Portal_Transaction_Introduction__c,
                         Number_of_days_for_Investigation_Visit__c, No_of_Days_Prior_Corr_Action_Deadline__c, No_of_Days_For_Investigation_Due_Date__c, Name,
                         Large_Group_Instruction__c, Investigation__c, Investig_Non_comp_Default_if_Any__c, Follow_up_Visit_Estimated_Deadline__c,
                         EEC_Licensing_Transaction_Instructions__c,                         
                          Transaction_Attachments_New__c, Transaction_Attachments_Renewal__c, Transaction_Attachments_Upgrade__c
                         FROM LEAD_Configuration__c
                         WHERE Name = :provider.RecordType.Name];
    // If the transaction id is not blank then retrieve its details.

    //System.Debug('STDebug: ltId: ' + ltId);

    licenseTransaction = (String.isNotBlank(ltId) ? getLicenseTrans(ltId) : new Licensing_Transaction__c());
    // Get the AWS access key using the credential name. 
    accessKey = new AWSKeys(awsCredentialName).key;

    // Process Attachments
    /*generateAttachmentMappings();
      refreshAttachmentsList();
      retrieveAddtionalTrainingAttachmentsList();*/

    // Verify if we are dealing with an FCC Assistant or not. 
    isFccAssistant = (provider.RecordType.Name == 'FCC Assistant' ? true : false);
    //System.debug('----> isFccAssistant: ' + isFccAssistant);
  }

  /**
   * getLicenseTrans
   *
   * @description This function will retieve the License Transaction information if an ID is provided.
   * @author Darkis
   * @created 26 Jan 2016
   * @param ltId String The Transaction ID.
   */
  public Licensing_Transaction__c getLicenseTrans(String ltId) {
    Licensing_Transaction__c tempTransaction = null;
    //selectedHestElems = new List<String> ();

    List<Licensing_Transaction__c> ltList = [Select
                                            
                                             l.To_Process_Flag__c, l.Technical_Assistance__c, l.Tax_Certification_Status__c, l.Submission_Date__c, l.Name, l.Approved_Foster_Care_Provider_Descrip__c, l.Tax_Certification_Statement_Request_Date__c, l.Tax_Cert_Statement_Signed_Date__c, l.Submitter__c, l.Submitter_Email_Address__c,
                                             l.Stove_Meets_Requirements_Evidence__c, l.Status__c, l.Source__c, l.Sex_Offender_Nature_of_Incident__c, l.SIDS_Training_Cert__c, l.Revocation_Suspension_Surrender_Reas__c, l.Restraining_Order_Issued__c, l.Restraining_Order_Description__c, l.Registering_as_Sex_Offender__c,
                                             l.RecordTypeId, l.Alcoholic_Bev_Narcotics_Drugs_Desc__c, l.Reason_for_Request__c,l.Previous_Application_Certif_with_EEC__c, l.Prev_App_Certif_with_EEC_Descrip__c, l.Prev_App_Certif_with_Another_State__c,
                                             l.Prev_App_Certif_with_Another_State_Desc__c, l.Outdoor_Space_Changes_Description__c, l.Outdoor_Space_Changed__c,
                                             l.Date_Last_SIDS_Training_Taken__c, l.Date_FCC_Orientation_Taken__c, l.Date_Closed__c, l.Date_Care_Resumes__c, l.Date_Activity_Ends__c, l.Daily_Routine_and_Activities__c, l.Condition_Added__c, l.Children_Home_Schooled__c, l.Children_Home_Schooled_Description__c, l.Child_Emergency_Injury_Last_3_Years__c,
                                             l.Child_Emerg_Injury_Last_3_Years_Descrip__c, l.Charges_Description__c, l.Charged_or_Arrested_for_Crime__c, l.Certificate_or_License_Surrendered__c, l.Certificate_of_License_Revoked_Suspend__c, l.Caring_For_Children_Not_Related__c, l.Capacity__c, l.CPR_Certified__c, l.CPR_Certification_Issue_Date__c,
                                             l.CPR_Certificate__c, l.Business_Operated_Out_of_Own_Home__c, l.Bus_Operated_Out_of_Own_Home_Descrip__c, l.Belong_to_Food_Program__c, l.Becoming_Foster_Care_Provider__c, l.Approved_by_Manager__c, l.Approved_Foster_Care_Provider__c,
                                             l.Date_FCC_Orientation_Mod_1_Taken__c, l.Took_FCC_Orientation_Module_1__c, l.Abused_or_neglected_a_child__c, l.Abused_or_neglected_a_child_Description__c, l.Transaction_Special_Requests_Comments__c, l.Steps_for_Guiding_Child_Behavior__c, l.Medical_Emergency_Steps__c, l.Caring_for_your_own_children_Years__c, l.Caring_for_your_own_children_Months__c, l.Caring_for_your_own_children_Hrs_Week__c, 
                                             l.Provider_Doesnt_Know_Assistant__c, l.Highest_Reached_Step__c
                                             FROM Licensing_Transaction__c l
                                             WHERE Id = :ltId
                                            ];
    //system.debug('ltlist:'+ltlist);
    if (ltList != null && ltList.size() > 0) {
      tempTransaction = ltList.get(0);
      highestStepReached = tempTransaction.Highest_Reached_Step__c;
      licenseRecordTypeName = tempTransaction.RecordType.DeveloperName;
      licenseRecordTypeLabel = tempTransaction.RecordType.Name;
      formattedLicenseRecordTypeLabel = licenseRecordTypeName.replaceAll('_', ' ');

      /*if (licenseRecordTypeName.equalsIgnoreCase('FCC_Assistant_License_Upgrade')) {
        //licenseInstructionMessage = (String) leadConfiguration.get('FCC_License_Upgrade_Instruction__c');
      } else if (licenseRecordTypeName.equalsIgnoreCase('FCC_Assistant_New_License')) {
        //licenseInstructionMessage = (String) leadConfiguration.get('FCC_New_License_Instruction__c');
      } else if (licenseRecordTypeName.equalsIgnoreCase('FCC_Assistant_Renewal')) {
        //licenseInstructionMessage = (String) leadConfiguration.get('FCC_Renewal_Instruction__c');
      } else {*/
      licenseInstructionMessage = (String) leadConfiguration.get('EEC_Licensing_Transaction_Instructions__c');
      //}

      provider = [
                  SELECT
                  Id, Race__c, License_Type__c, Recordtype.DeveloperName, RecordType.Name, License_Status__c, First_Issue_Date__c, Renewal_date__c, Provider_Status__c,
                  Accept_Referral__c, Can_Communicate_in_English__c, PPM_Meeting_Attended_Date__c, capacity__c,
                  ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Unlisted_Phone_Number__c, Alternate_Phone__c, Fax, Provider_Email__c,
                  Provider_Address_1__c, Provider_Address_2__c, Provider_City__c, Provider_City__r.Name, Provider_Zip_Code__c, Live_at_this_address__c, Language__c, Preferred_Language__c
                  FROM Account
                  WHERE Id = :tempTransaction.Provider__c
                 ]; 

      /* TODO: Prune Commented Code to be more modular for new class structure once other pages are converted.

        ihmList = [Select Id, Provider__c, Licensing_Transactions__c, Current__c, First_Name__c, Last_Name__c, Date_of_Birth__c, Relationship_to_Provider__c, Occupation__c, Number_of_Hours_Home_During_Child_Care__c, Current_School_Grade__c, Email_Address__c From Household_Member__c where Licensing_Transactions__c = :licenseTransation.Id];
        ihmListJson = JSON.serialize(ihmList);
        //faList = [Select Id, Name, First_Name__c, Last_Name__c, Mailing_Address__c, License_Number__c, License_Expiration_Date__c, Source_Transaction__c, Provider__c, Current__c From FCC_Assistant__c where Source_Transaction__c = :licenseTransation.Id];
        ehList = [Select Name, Contact__c, Licensing_Transaction__c, Position__c, Start_Date__c, End_Date__c, Reason_for_Leaving__c, Employer__c, Employer_Address__c, Employer_Phone__c From Employment_History__c where Licensing_Transaction__c = :licenseTransation.Id];
        roomList = [Select Id, Name, Source_Transaction__c, Current__c, Use__c, Dimension_Length_feet__c, Dimension_Width_feet__c, Dimension_Square_Feet__c, Floor_Level__c, Provider_Name__c From Room__c where Source_Transaction__c = :licenseTransation.Id];
        teList = [Select Id, Name, Contact__c, Licensing_Transactions__c, Topic__c, Date_of_the_Training__c, Number_of_Training_Hours__c From Training_Experience__c where Licensing_Transactions__c = :licenseTransation.Id];
        initHH = true;
        initLS = true;
        initIndoor = true;
        initTraining = true;

        if (String.isNotEmpty(tempTransaction.Heating_Elements__c)) {
        selectedHestElems = tempTransaction.Heating_Elements__c.split(';');
        }
       */
    }
    return tempTransaction;
  }

  /**
  * generateAttachmentMappings
  *
  * @description This function will generate a map with all the attachments mapped to their respective objects.
  * @author Darkis
  * @created 26 Jan 2016
  */
  public void generateAttachmentMappings() {
    // Get all attachments for the transaction.
    transactionAttachments = [Select Id, CreatedDate, Filename__c, Bucket__c, Content_Type__c, Prefix__c From S3_File__c Where Object_Id__c = :licenseTransaction.Id ORDER BY CreatedDate DESC];
    // Initialize the Mapping.
    transactionAttachmentsMap = new Map<String, Map<String, String>> ();
    transactionAttachmentsUrlMap = new Map<Id, String> ();
    //Set<Id> transactionFileIds = new Set<Id> ();
    // Loop through the file maps and creating a mapping based on filename.
    
  // Get the AWS credentials based on a config value.
  // TODO: Config the name of the aws key.
  AWSKeys creds = new AWSKeys('eec');
  
    for (S3_File__c fileMap : transactionAttachments) {
      //System.debug('----> FileMap: ' + fileMap);
      // Get the full filename including prefix if necessary for urls.
      String filename = (!String.isBlank(fileMap.Prefix__c) ? fileMap.Prefix__c + '/' + fileMap.Filename__c : fileMap.Filename__c);
      String[] filenameSplit = (fileMap.Filename__c).split('\\.');
      // Generate an attribute map for the page.
      Map<String, String> fileAttributeMap = new Map<String, String> {
        'FileMap_Id' => fileMap.Id,
        'File_Id' => fileMap.Id,
        'Bucket__c' => fileMap.Bucket__c,
        'Content_Type__c' => fileMap.Content_Type__c,
        'Prefix__c' => fileMap.Prefix__c,
        'Filename__c' => fileMap.Filename__c
      };
      transactionAttachmentsMap.put(filenameSplit[0], fileAttributeMap);
      // Map the FileMap's temp urls for use on the page. 
      transactionAttachmentsUrlMap.put(fileMap.Id, EEC_S3ComponentCtrl.generateTempS3Url(fileMap.Bucket__c, filename, creds));
      // Add the file id to the ids list. 
      //transactionFileIds.add(fileMap.Id);
    }
    // Create a list of S3_File__c objects from the FileMap.
    //List<S3_File__c> transactionFiles = [Select Id, Filename__c From S3_File__c Where Id IN :transactionFileIds];
    attachmentsJson = JSON.serialize(transactionAttachments);
    //System.debug('----> Attachment Json: ' + attachmentsJson);
    //System.debug('----> transactionAttachmentsMap: ' + transactionAttachmentsMap);
  }

  /**
   * CancelTransaction
   *
   * @description This function will cancel the transaction and send the user back to the portal provider page.
   * @author Darkis
   * @created 26 Jan 2016
   * @return Pagereference 
   */
  public Pagereference CancelTransaction() {
    Licensing_Transaction__c lt = new Licensing_Transaction__c(id = licenseTransaction.id);
    lt.Status__c = 'Cancelled';
    lt.Status_Reason__c = 'Applicant withdrew';
    lt.Reason_Closed_Cancelled__c = 'Cancelled by portal user';
    update lt;

   // PageReference pPage = page.EEC_PortalProviderPage;
   // EEC_Util.addMemberIDPageParameter(memberId, pPage, true);
   // return pPage;
   return null;
  }
}