public without sharing class EEC_HouseholdMembersController {
    public List<TransactionContactWrapper> transactionContactList   {get; set;}
    public Transaction_Contact__c transactionContactRec             {get; set;}
    public boolean isSaveOnly                                       {get; set;}
    public String ltId;
    public String memberId                                          {get; set;}
    public Account provider                                         {get; set;}
    public string applicationDisplayName                            {get; set;}
    public String licenseRecordTypeLabel                            {get; set;}
    public LEAD_Configuration__c leadConfiguration                  {get; set;}
    public User loggedUser                                          {get; set;}
    public String highestStepReached                                {get; set;}
    public String numberOfMainContactsString                        {get; set;}
    public List<Transaction_Document__c> transDocList;
    public String selectedTransactionContactId                      {get; set;}
    public Licensing_Transaction__c licenseTransation               {get; set;}
    public string previousPageName                                  {get; set;}
    public Boolean isSubmitted                                      {get; set;}
    public boolean isProviderWithoutEmail                           {get; set;}
    public boolean isInternalUser                                   {get; set;}
    public boolean isHouseHoldMemberOrRegularlyOnPremise            {get; set;}
    public EEC_HouseholdMembersController(){ 
        transDocList = new List<Transaction_Document__c>();
        numberOfMainContactsString = '';
        isProviderWithoutEmail = false;
        isInternalUser = false;
        isHouseHoldMemberOrRegularlyOnPremise = true;
        ltId = ApexPages.currentPage().getParameters().get('ltId');
        memberId = ApexPages.currentPage().getParameters().get('member');
        isSubmitted = false;
        isSaveOnly = false;
        transactionContactList = new List<TransactionContactWrapper>();
        transactionContactRec = new Transaction_Contact__c();
        for(Licensing_Transaction__c ltRec : [SELECT ID, Household_Attestation__c, Status__c, Name, RecordType.DeveloperName ,RecordType.Name, providerRecordTypeDeveloperName__c,
                                                    Highest_Reached_Step__c, Provider__r.RecordType.Name,Assigned_To__c, Provider__r.Owner.Id,transactionRecordTypeDeveloperName__c,
                                                    Provider__r.Name, Provider__c, Provider__r.Provider_Email__c, Provider_Email__c, Provider__r.RecordType.DeveloperName,
                                                    Provider__r.Is_GSA__c, Provider__r.Is_FCC__c, Provider__r.Is_R_P__c
                                            FROM Licensing_Transaction__c
                                            WHERE Id =: ltId]){
            if(ltRec.Provider_Email__c == null || ltRec.Provider_Email__c ==''){
                isProviderWithoutEmail = true;
            }
            licenseTransation = ltRec;
        }
        loggedUser = [select Id, Name, contactId, UserType from User where Id = :UserInfo.getUserId()];
        if(loggedUser.contactId == null){
            isInternalUser = true;  
        }
        if(String.isNotBlank(ltId) && String.isNotBlank(licenseTransation.RecordType.Name)){ 
            leadConfiguration = [Select Visit_Narrative_Summary_Default__c,Application_Display_Name__c ,SystemModstamp, Portal_Transaction_Introduction__c,
                                Number_of_days_for_Investigation_Visit__c, No_of_Days_Prior_Corr_Action_Deadline__c, No_of_Days_For_Investigation_Due_Date__c, Name,
                                Large_Group_Instruction__c, Investigation__c, Investig_Non_comp_Default_if_Any__c, Follow_up_Visit_Estimated_Deadline__c
                                , Transaction_Submission_Disclaimer__c,Training_Instructions__c,Transaction_Attachments_New__c, Transaction_Attachments_Renewal__c, Transaction_Attachments_Upgrade__c 
                                from LEAD_Configuration__c where Name = :licenseTransation.RecordType.Name];
            applicationDisplayName = leadConfiguration.Application_Display_Name__c;
        }
        checkLicenseStatus();
        populateTransactionContact();
    }   
    private void checkLicenseStatus(){
        if(licenseTransation.Status__c == EEC_Constants.LT_CLOSED){
            isSubmitted = true;
        }
    }
   private void populateTransactionContact(){
        if(String.isNotBlank(ltId)){
            List<String> numberOfMainContactsList = new List<String>();
            for(Transaction_Contact__c transCon:[SELECT First_Name__c,Last_Name__c,Middle_Initial__c,Date_of_Birth__c,Email__c,
                                                    Relationship_to_Provider__c,Occupation__c,Role__c,Start_Date__c,
                                                    Current_School_Grade__c,Number_of_Hours_Home_During_Child_Care__c,Status__c,
                                                    End_Date__c,Contact__c, Do_You_Need_a_BRC_Form__c, Added_after_submission__c 
                                                FROM Transaction_Contact__c 
                                                WHERE Licensing_Transaction__c =: ltId 
                                                AND Role__c includes(:EEC_Constants.TC_ROLE_HOUSEHOLD_MEMBER,:EEC_Constants.TC_ROLE_REGULARLY_ON_PREMISE,:EEC_Constants.TC_ROLE_LICENSEE) ]){
                if(transCon.Role__c == EEC_Constants.TC_ROLE_LICENSEE && transCon.Status__c == EEC_Constants.TC_STATUS_ACTIVE){
                    numberOfMainContactsList.add(transCon.Id);  
                }
                transactionContactList.add(new TransactionContactWrapper(transCon, transCon.Do_You_Need_a_BRC_Form__c == EEC_Constants.TC_DO_YOU_NEED_BRC_FORM ? true : false));
            }
            numberOfMainContactsString = JSON.serialize(numberOfMainContactsList);
        }
    } 
    /*
        * Method Name: resetMember
        * Description: Reset Transaction Contact 
        * @param:  null
        * @return: void                                                       
    */
    public void resetMember() {
        transactionContactRec = new Transaction_Contact__c();
        transactionContactRec.recordTypeId = Schema.SObjectType.Transaction_Contact__c.getRecordTypeInfosByDeveloperName().get(licenseTransation.providerRecordTypeDeveloperName__c).getRecordTypeId();
        isHouseHoldMemberOrRegularlyOnPremise = true;
    }
    /*
        * Method Name: getTransactionContactMember
        * Description: Getting Transaction Contact Record 
        * @param:  null
        * @return: void                                                       
    */
    public void getTransactionContactMember() {
        isHouseHoldMemberOrRegularlyOnPremise = true;
        List<Transaction_Contact__c> TransactionContactList = [SELECT First_Name__c,Last_Name__c,Middle_Initial__c,
                                                                    Date_of_Birth__c,Email__c,Relationship_to_Provider__c,
                                                                    Occupation__c, Added_after_submission__c,Current_School_Grade__c,
                                                                    Number_of_Hours_Home_During_Child_Care__c,Status__c,Role__c,
                                                                    Start_Date__c,End_Date__c,Licensing_Transaction__c,Do_You_Need_a_BRC_Form__c 
                                                                FROM Transaction_Contact__c 
                                                                WHERE Id =: selectedTransactionContactId ]; 
        if(TransactionContactList.size() > 0) {
            transactionContactRec = TransactionContactList[0]; 
            if(transactionContactRec.End_Date__c != null){
                isHouseHoldMemberOrRegularlyOnPremise = false;
            }
        } else { 
            transactionContactRec = new Transaction_Contact__c();
            if(String.isNotBlank(ltId)){
                transactionContactRec.recordTypeId = Schema.SObjectType.Transaction_Contact__c.getRecordTypeInfosByDeveloperName().get(licenseTransation.providerRecordTypeDeveloperName__c).getRecordTypeId();
                transactionContactRec.Licensing_Transaction__c = ltId;
            }
        } 
    }
    /*
        * Method Name: saveTransactionContact
        * Description: Method to save Transaction Contact
        * @param:  null
        * @return: PageReference                                                       
    */
    public PageReference saveTransactionContact() {
        Boolean isTransactionContactExist = false;
        try {
            if(transactionContactRec.End_Date__c != null ){
                transactionContactRec.Status__c = EEC_Constants.TC_STATUS_INACTIVE;
            } else{
                transactionContactRec.Status__c = EEC_Constants.TC_STATUS_ACTIVE;
            }
            for(Transaction_Contact__c transCon:[SELECT Id,First_Name__c,Last_Name__c,Status__c,Date_of_Birth__c 
                                                   FROM Transaction_Contact__c 
                                                  WHERE Licensing_Transaction__c =:ltId 
                                                    AND Id!=:transactionContactRec.Id]){
                if(transCon.First_Name__c == transactionContactRec.First_Name__c
                && transCon.Last_Name__c == transactionContactRec.Last_Name__c
                && transCon.Date_of_Birth__c == transactionContactRec.Date_of_Birth__c
                && transCon.Status__c == 'Active' &&  transactionContactRec.Status__c =='Active'){
                    isTransactionContactExist = True;
                }      
            }
            if(!isTransactionContactExist){
                Licensing_Transaction__c transactionRecord;
                transactionContactRec.Licensing_Transaction__c = ltId;
                transactionContactRec.OwnerId = licenseTransation.Provider__r.Owner.Id;
                transactionContactRec.Not_Applicable__c = false;
                if(licenseTransation.Status__c == EEC_Constants.LT_SUBMITTED || licenseTransation.Status__c == EEC_Constants.LT_UNDER_REVIEW) {
                    transactionContactRec.Added_after_submission__c = true;
                    transactionRecord = new Licensing_Transaction__c(Id=licenseTransation.Id, Added_contact_after_submission__c=true);
                    transactionRecord.Household_Attestation__c = false;
                    transactionContactRec.BRC_Required__c = true;
                }
                if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_BACKGROUND_RECORD_CHECK) {
                    transactionContactRec.Do_You_Need_a_BRC_Form__c = EEC_Constants.TC_DO_YOU_NEED_BRC_FORM;
                }
                upsert transactionContactRec;
                if(transactionRecord != null) {
                    update transactionRecord;
                }
                if(transactionContactRec.Added_after_submission__c) {
                    EEC_Util.resetAfterSubmissionContactChecklistItems(licenseTransation.Id, transactionContactRec);
                }
                return getCurrentPageReference();
            } else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'A Contact with this First Name and Last Name already exists for this program.   Please click “Close” below, and then click “Edit” next to the existing Contact’s name to make any updates to that person’s information.'));
                return null;
            }
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }
    }
    /*
        * Method Name: deleteTransactionContact
        * Description: Method to delete Transaction Contact
        * @param:  null
        * @return: PageReference                                                       
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
                                 Email__c,Start_Date__c,Status__c,End_Date__c,Role__c,Schedule_Administrative_Hours__c,
                                 Schedule_Teaching_Hours__c
                                 FROM Transaction_Contact__c 
                                 WHERE Id =: selectedTransactionContactId limit 1];
        if(transactionContactToDelete.Role__c == EEC_Constants.TC_ROLE_HOUSEHOLD_MEMBER){
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
                } catch(DMLException ex){
                    System.debug(' EEC_householdmembers existingDocumentsToDelete error ' + ex.getMessage());
                }
            }
        }
    }
    /*
        * Method Name: getCurrentPageReference
        * Description: Method to get current Page Reference  
        * @param:  null
        * @return: PageReference                                                       
    */
    private PageReference getCurrentPageReference() {
        PageReference pPage = Page.EEC_HouseholdMembers;
        pPage.getParameters().put('ltId', licenseTransation.Id);
        addMemberIDPageParameter(pPage, false);
        pPage.setRedirect(true);
        return pPage;
    }
    public Pagereference SaveAndNextHH() {
        try {
            if (licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_FCC_NEW_LICENSE 
                || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_FCC_RENEWAL 
                || licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_FCC_LICENSE_UPGRADE) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_LICENSING_STATUS_AND_CAPACITY;
                PageReference pPage = Page.EEC_LicenseStatusCapacityInfo;
                if(isSaveOnly){
                    pPage = Page.EEC_HouseholdMembers;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
                }
                if(!isSubmitted){
                    update licenseTransation;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_CHANGE_OF_ADDRESS) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO;
                PageReference pPage = Page.EEC_IndoorSpacePage;
                if(isSaveOnly){
                    pPage = Page.EEC_HouseholdMembers;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
                }
                if(!isSubmitted){
                    update licenseTransation;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if (licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_FCC_CHANGE_OF_HOUSEHOLD) {
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE;
                PageReference pPage = Page.EEC_TechnicalAssistance;
                if(isSaveOnly){
                        pPage = Page.EEC_HouseholdMembers;
                }
                if(!isSubmitted){
                    update licenseTransation;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            } else if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_BACKGROUND_RECORD_CHECK){
                licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_REVIEW_SUMMARY_AND_SUBMISSION;
                PageReference pPage = Page.EEC_ReviewSummarySubmission;
                if(isSaveOnly){
                    pPage = Page.EEC_HouseholdMembers;
                    licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
                }
                if(!isSubmitted){
                    update licenseTransation;
                }
                if(!transactionContactList.isEmpty()) {
                    List<Transaction_Contact__c> tempTransactionContactList = new List<Transaction_Contact__c>();
                    for(TransactionContactWrapper transactionCon : transactionContactList) {
                        transactionCon.transactionContact.Do_You_Need_a_BRC_Form__c = transactionCon.needBrcForm ? 'Yes' : 'No';
                        tempTransactionContactList.add(transactionCon.transactionContact);
                    }
                    update tempTransactionContactList;
                }
                pPage.getParameters().put('ltId', licenseTransation.Id);
                addMemberIDPageParameter(pPage, false);
                pPage.setRedirect(true);
                return pPage;
            }
            PageReference pPage = page.EEC_PortalProviderPage;
            if(isSaveOnly){
                        pPage = Page.EEC_HouseholdMembers;
                        licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
            }
            addMemberIDPageParameter(pPage, true);
            return pPage;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage()));
        }
        return null;
    }
    public Pagereference SaveAndPreviousHH() {
        try {
            //saveHH();
            licenseTransation.Last_Reached_Step__c = EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER;
            //update licenseTransation;
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
                        || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_FOSTER_CARE_AGENCY || licenseTransation.providerRecordTypeDeveloperName__c == EEC_Constants.PRO_ADOPTION_AGENCY){
                    pPage = EEC_Util.lastRPStepMap.get(previousPageName);
                }
            }else if(licenseTransation.transactionRecordTypeDeveloperName__c == EEC_Constants.LT_BACKGROUND_RECORD_CHECK){
                pPage = Page.EEC_transactioninstructions;
            }else{
                pPage = Page.EEC_TransactionProvider;
            }
            pPage.getParameters().put('ltId', licenseTransation.Id);
            addMemberIDPageParameter(pPage, false);
            pPage.setRedirect(true);
            return pPage;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator - ' + e.getMessage()));
        }
        return null;
    }
    Public void addMemberIDPageParameter(PageReference pPage, Boolean encrypt) {
        if (String.isNotBlank(memberId)) {
            pPage.getParameters().put('member', memberId);
        }
    }
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
    public void updateTransactionContactBrcValue() {
        Integer index = Integer.valueOf(Apexpages.currentPage().getParameters().get('transactionIndex'));
        if(index != null && !transactionContactList.isEmpty()) {
            Transaction_Contact__c transactionContact = new Transaction_Contact__c();
            transactionContact = transactionContactList[index].transactionContact;
            transactionContact.Do_You_Need_a_BRC_Form__c = transactionContactList[index].needBrcForm ? 'Yes' : 'No';
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