public without sharing class EEC_OwnershipAdministratorInfoController { 
    public Licensing_Transaction__c licenseTransation               {get; set;}
    public List<TransactionContactWrapper> transactionContactList   {get; set;} 
    public Transaction_Contact__c transaContactObj                  {get; set;}
    public String selectedTransactionContactId                      {get; set;}
    public string getTransactionContactMember                       {get; set;}
    public string checkLicenseStatus                                {get; set;}
    public string applicationDisplayName                            {get; set;}
    public LEAD_Configuration__c leadConfiguration                  {get; set;}
    public boolean isProgramContractorPresent                       {get; set;}
    public Integer noMainContactBrcRolePresent                      {get; set;} 
    public Integer noOfMainContact                                  {get; set;}
    public string previousPageName                                  {get; set;}
    public Boolean isSubmitted                                      {get; set;}
    public User loggedUser                                          {get; set;}
    public boolean isInternalUser                                   {get; set;}
    public boolean isUserOnPremise                                  {get; set;}
    public String noOfAdminDesigneePresentString                    {get; set;}
    public List<SelectOption> brcRoleOptions                        {get; set;}
    public String navigationSavePreviousWrapper                     {get; set;}
    public List<Transaction_Document__c> transDocList;
    private String ltId;
    string memberId; 
    public EEC_OwnershipAdministratorInfoController(){
        transDocList = new List<Transaction_Document__c>();
        ltId = ApexPages.currentPage().getParameters().get('ltId');
        memberId = ApexPages.currentPage().getParameters().get('member');
        leadConfiguration = new LEAD_Configuration__c();
        isSubmitted = false;
        isInternalUser = false;
        isUserOnPremise = true;
        noOfAdminDesigneePresentString = '';
        licenseTransation = new Licensing_Transaction__c();
        loggedUser = [select Id, Name, contactId, UserType from User where Id = :UserInfo.getUserId()];
        if(loggedUser.contactId == null){
            isInternalUser  = true;
        }
        transactionContactList = new List<TransactionContactWrapper>();
        transaContactObj = new Transaction_Contact__c();
        for(Licensing_Transaction__c ltRec : [SELECT Id, Name, transactionRecordTypeDeveloperName__c, 
                    Status__c,RecordType.DeveloperName, RecordType.Name, Highest_Reached_Step__c,
                    Provider__r.RecordType.Name, Assigned_To__c,Provider__r.Owner.Id,Provider__r.Name,Provider__c, 
                    providerRecordTypeDeveloperName__c, Provider__r.Is_GSA__c, Provider__r.Is_FCC__c, Provider__r.Is_R_P__c
                FROM Licensing_Transaction__c
                WHERE Id =: ltId]){
            licenseTransation = ltRec;
        }
        isProgramContractorPresent = false;
        if(String.isNotBlank(ltId) && String.isNotBlank(licenseTransation.RecordType.Name)){
            leadConfiguration = [SELECT Application_Display_Name__c
            FROM LEAD_Configuration__c WHERE Name =: licenseTransation.RecordType.Name];
            applicationDisplayName = leadConfiguration.Application_Display_Name__c;
        }
        addBrcRolePicklistValues();
        checkLicenseStatus();
        populateTransactionContact();
    }
    private void checkLicenseStatus(){
        if(licenseTransation.Status__c == EEC_Constants.LT_CLOSED){
            isSubmitted = true;
        }
    }
    /*
        * Method Name: getTransactionContactMember
        * Description: populate transaction Contact in edit mode
        * @param:  null
        * @return: void 
    */
    public void getTransactionContactMember() {
        isUserOnPremise = true;
        List<Transaction_Contact__c> TransactionContactList = [SELECT First_Name__c,Last_Name__c,Contact__c,Middle_Initial__c,Date_of_Birth__c,Email__c,
                                                                    Relationship_to_Provider__c,Occupation__c,
                                                                    Current_School_Grade__c,Number_of_Hours_Home_During_Child_Care__c,Status__c,
                                                                    Role__c,BRC_Role__c,Start_Date__c,End_Date__c,Schedule_Administrative_Hours__c,
                                                                    Schedule_Teaching_Hours__c,Licensing_Transaction__c,
                                                                    Licensing_Transaction__r.RecordType.DeveloperName,Do_You_Need_a_BRC_Form__c,BRC_Id__c, 
                                                                    Added_after_submission__c, RecordTypeId
                                                                FROM Transaction_Contact__c
                                                                WHERE Id =: selectedTransactionContactId ];
        if(TransactionContactList.size() > 0) {
            transaContactObj = TransactionContactList[0];
            if(transaContactObj.End_Date__c != null){
                isUserOnPremise = false;
            }
        } else {
            transaContactObj = new Transaction_Contact__c();
            if(String.isNotBlank(ltId)){
                transaContactObj.recordTypeId = Schema.SObjectType.Transaction_Contact__c.getRecordTypeInfosByDeveloperName().get(licenseTransation.providerRecordTypeDeveloperName__c).getRecordTypeId();
                transaContactObj.Licensing_Transaction__c = ltId;
            }
        }
    }
    /* 
        * Method Name: populateTransactionContact
        * Description: populate transaction Contact data on page
        * @param:  null
        * @return: void
    */
    private void populateTransactionContact(){
        Set<String> multiselectValues;
        noOfMainContact = 0;
        noMainContactBrcRolePresent = 0;
        if(String.isNotBlank(ltId)){
            List<String> noOfAdminDesigneePresentList = new List<String>();
            for(Transaction_Contact__c transContact : [SELECT Id,First_Name__c,Last_Name__c,Contact__c,Licensing_Transaction__c,Middle_Initial__c,
                    Email__c,Start_Date__c,Status__c,End_Date__c,Role__c,BRC_Role__c,Schedule_Administrative_Hours__c,Do_You_Need_a_BRC_Form__c,
                    Schedule_Teaching_Hours__c,BRC_Id__c,Licensing_Transaction__r.Provider__r.Is_GSA__c,Added_after_submission__c
                FROM Transaction_Contact__c
                WHERE Licensing_Transaction__c =: ltId ]){
                transactionContactList.add(new TransactionContactWrapper(transContact, transContact.Do_You_Need_a_BRC_Form__c == EEC_Constants.TC_DO_YOU_NEED_BRC_FORM  ? true : false));
                multiselectValues = new Set<String>(); 
                if(String.isNotBlank(transContact.Role__c)) {
                    multiSelectValues.addAll(transContact.Role__c.split(';'));
                }
                if(!isProgramContractorPresent && transContact.Status__c == EEC_Constants.TC_STATUS_ACTIVE){
                    if(multiSelectValues.contains(EEC_Constants.TC_ROLE_PROGRAM_DIRECTOR)){
                        isProgramContractorPresent = true;
                    }
                }
                if(multiSelectValues.contains(EEC_Constants.TC_ROLE_LICENSEE) && transContact.Status__c == EEC_Constants.TC_STATUS_ACTIVE){
                    noOfMainContact++;
                }
                if(transContact.BRC_Role__c == EEC_Constants.TC_ROLE_LICENSEE && transContact.Status__c == EEC_Constants.TC_STATUS_ACTIVE){
                    noMainContactBrcRolePresent++;
                }
                if(multiSelectValues.contains('Designated Administrator') && transContact.Status__c == EEC_Constants.TC_STATUS_ACTIVE){
                    noOfAdminDesigneePresentList.add(transContact.Id);
                }
            }
            noOfAdminDesigneePresentString = JSON.serialize(noOfAdminDesigneePresentList);
        }
    }
    /*
        * Method Name: resetMember
        * Description: Reset Transaction Contact
        * @param:  null
        * @return: void
    */
    public void resetMember() {
        if(String.isBlank(selectedTransactionContactId)) {
            transaContactObj = new Transaction_Contact__c();
            transaContactObj.recordTypeId = Schema.SObjectType.Transaction_Contact__c.getRecordTypeInfosByDeveloperName().get(licenseTransation.providerRecordTypeDeveloperName__c).getRecordTypeId();
            isUserOnPremise = true;
        }
    }
    public void addBrcRolePicklistValues() {
        brcRoleOptions = new List<SelectOption>();
        brcRoleOptions.add(new SelectOption('', '--None--'));
        for(Schema.PicklistEntry brcRole : Transaction_Contact__c.BRC_Role__c.getDescribe().getPicklistValues()){
            if(String.isNotBlank(ltId) && licenseTransation.Provider__r.Is_GSA__c && brcRole.getValue() == 'BRC Program Administrator'){
                continue;
            }
            brcRoleOptions.add(new SelectOption(brcRole.getLabel(), brcRole.getValue()));
        }
    }
    /*
        * Method Name: saveTransactionContact
        * Description: Update or insert transaction Contact
        * @param:  PageReference
        * @return: getCurrentPageReference()
    */
    public PageReference saveTransactionContact() {
        Licensing_Transaction__c transactionRecord;
        Boolean isTransactionContactExist = false;
        try{
            if (transaContactObj != null) {
                if (transaContactObj.End_Date__c != null) {
                    transaContactObj.Status__c = EEC_Constants.TC_STATUS_INACTIVE;
                } else {
                    transaContactObj.Status__c = EEC_Constants.TC_STATUS_ACTIVE;
                }
                for(Transaction_Contact__c transCon : [SELECT Id,First_Name__c,Last_Name__c,Status__c
                                                        FROM Transaction_Contact__c 
                                                        WHERE Licensing_Transaction__c =:licenseTransation.id 
                                                        AND ID != :transaContactObj.Id ]){
                    if(transCon.First_Name__c == transaContactObj.First_Name__c 
                    && transCon.Last_Name__c == transaContactObj.Last_Name__c 
                    && transCon.Status__c =='Active' && transaContactObj.Status__c =='Active'){
                         isTransactionContactExist = True;
                    }
                } 
                if(!isTransactionContactExist){
                    if (transaContactObj.Do_You_Need_a_BRC_Form__c != null && transaContactObj.Do_You_Need_a_BRC_Form__c == EEC_Constants.TC_DO_YOU_NEED_BRC_FORM  && transaContactObj.BRC_Role__c == null) {
                        transaContactObj.BRC_Role__c = EEC_Constants.TC_ROLE_LICENSEE;
                    }
                    transaContactObj.Licensing_Transaction__c = licenseTransation.id;
                    transaContactObj.Not_Applicable__c = false;
                    transaContactObj.OwnerId = licenseTransation.Provider__r.Owner.Id;
                    if ((licenseTransation.Status__c == EEC_Constants.LT_SUBMITTED || licenseTransation.Status__c == EEC_Constants.LT_UNDER_REVIEW)) {
                        transaContactObj.Added_after_submission__c = true;
                        transactionRecord = new Licensing_Transaction__c(Id = licenseTransation.Id, Added_contact_after_submission__c = true);
                        if (String.isNotBlank(transaContactObj.BRC_Role__c) && licenseTransation.RecordType.DeveloperName != EEC_Constants.LT_CONTACT_MANAGEMENT) {
                            transaContactObj.BRC_Required__c = true;
                        }
                    }
                    if (transaContactObj.BRC_Role__c == EEC_Constants.TC_BRC_ROLE_PROGRAM_ADMINISTRATOR || transaContactObj.BRC_Role__c == null) {
                    //  transaContactObj.Contact_Management_BRC_Scenerio__c = EEC_Constants.TC_CM_BRC_SCENARIO_PROGRAM_A_UPDATE;
                    } else if (transaContactObj.BRC_Role__c == EEC_Constants.TC_BRC_ROLE_LICENSEE) {
                    //  transaContactObj.Contact_Management_BRC_Scenerio__c = EEC_Constants.TC_CM_BRC_SCENARIO_LICENSEE_UPDATE;
                    }
                    if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_BACKGROUND_RECORD_CHECK) {
                        transaContactObj.Do_You_Need_a_BRC_Form__c = EEC_Constants.TC_DO_YOU_NEED_BRC_FORM;
                    }
                    if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME) {
                        transaContactObj.Brc_Role__c = EEC_Constants.TC_BRC_ROLE_LICENSEE;
                    }
                    upsert transaContactObj;
                    if (transactionRecord != null) {
                        update transactionRecord;
                    }
                    if (transaContactObj.Added_after_submission__c) {
                        EEC_Util.resetAfterSubmissionContactChecklistItems(licenseTransation.Id, transaContactObj);
                    }
                    return getCurrentPageReference();    
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'A Contact with this First Name and Last Name already exists for this program.   Please click “Close” below, and then click “Edit” next to the existing Contact’s name to make any updates to that person’s information.'));
                    return null;
                }
            }
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }  
       return null; 
    }
    /*
        * Method Name: deleteTransactionContact
        * Description: delete selected transaction Contact
        * @param:  PageReference
        * @return: getCurrentPageReference()
    */
    public Pagereference deleteTransactionContact() {
        try {
            if(!isSubmitted){
                deleteTransactionDocument();
                delete new Transaction_Contact__c(Id = selectedTransactionContactId);
            }
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, e.getMessage()));
        }
        return getCurrentPageReference();
    }
    public void deleteTransactionDocument(){
        list<Transaction_Document__c> existingDocumentsToDelete = new list<Transaction_Document__c>();
        Transaction_Contact__c transactionContactToDelete = [SELECT Id,First_Name__c,Last_Name__c,Contact__c,Licensing_Transaction__c,Middle_Initial__c,
                Email__c,Start_Date__c,Status__c,End_Date__c,Role__c,BRC_Role__c,Schedule_Administrative_Hours__c,
                Schedule_Teaching_Hours__c
        FROM Transaction_Contact__c
        WHERE Id =: selectedTransactionContactId limit 1];
        for(Transaction_Document__c transactionDocument: [Select Id, Transaction_Document_Name__c,Document__c
        From Transaction_Document__c
        Where Licensing_Transaction__c =: licenseTransation.id]) {
            if(transactionDocument.Transaction_Document_Name__c == ('Notarize Consent Form - ' +transactionContactToDelete.First_Name__c +' '+ transactionContactToDelete.Last_Name__c)){
                existingDocumentsToDelete.add(transactionDocument);
                break;
            }
        }
        if(existingDocumentsToDelete.size() > 0){
            try {
                delete new Document__c(Id = existingDocumentsToDelete.get(0).Document__c);
                delete new Transaction_Document__c(Id = existingDocumentsToDelete.get(0).Id);
            } catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ex.getMessage()));
            }
        }
    }
    /*
        * Method Name: getCurrentPageReference
        * Description: redirect page to current page after save or delete
        * @param:  PageReference
        * @return: getCurrentPageReference()
    */
    private PageReference getCurrentPageReference() {
        Pagereference  pg = new Pagereference('/apex/EEC_OwnershipAdministratorInfo?ltId=' + ltId+'&member='+memberId);
        pg.setRedirect(true);
        return pg;
    }
    /*
        * Method Name: closeAndreturnToHome
        * Description: redirect page to home page
        * @param:  PageReference
        * @return: PageReference
    */
    public Pagereference closeAndreturnToHome() {
        if(!isInternalUser){
            PageReference pPage;
            pPage = Page.EEC_PortalLandingPage;
            //pPage.getParameters().put('ltId', licenseTransation.Id);
            //addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } else{
            PageReference pPage = new PageReference('/' + licenseTransation.Id);
            return pPage;
        }
    }
    /*
        * Method Name: SaveAndPreviousOwnership
        * Description: redirects user to previous in the flow
        * @param:  PageReference
        * @return: PageReference
    */
    public Pagereference SaveAndPreviousOwnership() {
        try{
            PageReference pPage;
            if(string.IsNotBlank(previousPageName)){
                if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC){
                    pPage = EEC_Util.lastFCCStepMap.get(previousPageName);
                } else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FCC_ASSISTANT){
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(previousPageName);
                } else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_LARGE_GROUP 
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SMALL_GROUP 
                        || licenseTransation.providerRecordTypeDeveloperName__c == 'Large and Small Group Umbrella' ){
                    pPage = EEC_Util.lastGSAStepMap.get(previousPageName);
                } else if(licenseTransation.providerRecordTypeDeveloperName__c == 'R&P Umbrella' 
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER 
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY 
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                } else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_PRIVATE_SCHOOL
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_PUBLIC_SCHOOL
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER){
                    pPage = EEC_Util.lastCBCStepMap.get(previousPageName);
                } else if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_SUMMER_CAMP){
                   // pPage = EEC_Util.lastSummerCampStepMap.get(previousPageName);
                }
            } else if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_BACKGROUND_RECORD_CHECK 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_CONTACT_MANAGEMENT || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_LICENSEE_BRC_RENEWAL_NEW_APPLICATION){
                pPage = Page.EEC_transactioninstructions;
            } else{
                pPage = Page.eec_transactionprovider;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            pPage.getParameters().put('member', memberId);
            pPage.setRedirect(true);
            return pPage;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getLineNumber() + 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage()));
        }
        return null;
    }
    /*
        * Method Name: SaveAndPreviousOwnership
        * Description: redirects user to next page in the flow
        * @param:  PageReference
        * @return: PageReference
    */
    public Pagereference SaveAndNextOwnership() {
        try {
            PageReference pPage;
            if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_LICENSE_CHANGE 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_PLACEMENT_CHANGE_IN_LICENSE 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_RESIDENTIAL_CHANGE_IN_LICENSE){
                pPage = Page.EEC_CapacityInformation;
            } else  if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_NEW_LICENSE
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_RENEWAL
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_MOVE
                    ||licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_TEMPORARY_MOVE
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_GSA_CHANGE_OF_ADMIN_AUTHORITY
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_OTHER_ELIGIBLE_PROVIDERS_NEW_APPLICATION
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_SUMMER_CAMP_NEW_APPLICATION
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_PUBLIC_SCHOOL_NEW_APPLICATION
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_PRIVATE_SCHOOL_NEW_APPLICATION){
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DESIGNATION_ADMIN_RESPONSIBILITY;
                pPage = Page.EEC_DesignationOfAdministrative;
            } else  if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_RESIDENTIAL_NEW_LICENSE
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_RESIDENTIAL_MOVE 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_RESIDENTIAL_LICENSE_RENEWAL ){
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_RESIDENTIAL_PROGRAM_DETAILS;
                pPage = Page.EEC_ResidentialProgramDetail;
            } else  if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_PLACEMENT_NEW_LICENSE
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_PLACEMENT_RENEWAL 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_PLACEMENT_MOVE ||
                    licenseTransation.transactionRecordTypeDeveloperName__c == 'Placement_License_Change'){
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_PLACEMENT_AGENCY_ADDITIONAL_INFO;
                pPage = Page.EEC_PlacementAgency;
            } else  if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_R_P_CHANGE_OF_ADMIN_AUTHORITY){
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_ATTACHMENTS;
                pPage = Page.eec_licensingattachment;
            } else if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_BACKGROUND_RECORD_CHECK 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_EEC_LICENSEE_MANAGEMENT_API_NAME 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_CONTACT_MANAGEMENT 
                    || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_LICENSEE_BRC_RENEWAL_NEW_APPLICATION){
                if(licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_TEMPORARY_SHELTER 
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_GROUP_CARE
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY 
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
                    pPage = Page.EEC_rp_reviewsummary;
                } else{
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUBMISSION;
                    pPage = Page.EEC_gsareviewsummary;
                }
                if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_BACKGROUND_RECORD_CHECK && !transactionContactList.isEmpty()) {
                    List<Transaction_Contact__c> tempTransactionContactList = new List<Transaction_Contact__c>();
                    for(TransactionContactWrapper transactionCon : transactionContactList) {
                        transactionCon.transactionContact.Do_You_Need_a_BRC_Form__c = transactionCon.needBrcForm ? EEC_Constants.TC_DO_YOU_NEED_BRC_FORM : EEC_Constants.TC_DO_YOU_NEED_BRC_FORM_NO;
                        tempTransactionContactList.add(transactionCon.transactionContact);
                    }
                    update tempTransactionContactList;
                }
            }
            if(!isSubmitted){
                update licenseTransation;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id); 
            pPage.getParameters().put('member', memberId);
            pPage.setRedirect(true);
            return pPage;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getLineNumber() + ' Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage()));
       }
        return null;
    }
    public void updateTransactionContactBrcValue() {
        Integer index = Integer.valueOf(Apexpages.currentPage().getParameters().get('transactionIndex'));
        if(index != null && !transactionContactList.isEmpty()) {
            Transaction_Contact__c transactionContact = new Transaction_Contact__c();
            transactionContact = transactionContactList[index].transactionContact;
            transactionContact.Do_You_Need_a_BRC_Form__c = transactionContactList[index].needBrcForm ?  EEC_Constants.TC_DO_YOU_NEED_BRC_FORM : EEC_Constants.TC_DO_YOU_NEED_BRC_FORM_NO;
            update transactionContact;
        }
    }
    public class TransactionContactWrapper {
        public Transaction_Contact__c transactionContact    {get; set;}
        public Boolean needBrcForm                          {get; set;}
        public TransactionContactWrapper(Transaction_Contact__c transactionContact, Boolean needBrcForm) {
            this.transactionContact = transactionContact;
            this.needBrcForm        = needBrcForm;
        }
    }
}