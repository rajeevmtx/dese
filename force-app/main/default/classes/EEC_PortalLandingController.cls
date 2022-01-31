public without sharing class EEC_PortalLandingController {
    //private String loggedInUser;//variable to store the logged in user id.
    public set<String> setOfRecordTypes = new set<String>{
            'EEC_FCC_Modification', 'EEC_GSA_Modification', 'EEC_RP_Modification'
    };
    public Account acc { get; set; }
    public User licensor { get; set; }
    public Lead_Configuration__c leadConfig { get; set; }
    public String profileName { get; set; }
    public List<MenuItem> lstMenuItems { get; set; }
    public Boolean isWithoutTransaction { get; set; }
    public List<Account> providerslist { get; set; }
    public Map<String, String> secureIdMap { get; set; }
    public List<EEC_LicenseTransactionWrapperClass> providerDraftLT { get; set; }
    public List<EEC_LicenseTransactionWrapperClass> providerSubmittedLT { get; set; }
    public List<EEC_LicenseTransactionWrapperClass> providerInProgressLT { get; set; }
    public List<EEC_LicenseTransactionWrapperClass> providerProcessedLT { get; set; }
    public List<Inspection_Item__c> visititems { get; set; }
    //public List<Non_Compliant__c> noncompitems { get; set; }
    public string memberId { get; set; }
    public Boolean accessProviderFlag { get; set; }
    public Boolean accessUmbrellaFlag { get; set; }
    public Integer remainingDays { get; set; }
    public String daysFromRenewalDue { get; set; }
    public integer LeadconfigDays { get; set; }
    public Boolean isFccAssistant { get; set; }
    public Boolean isRPFlow { get; set; }
    Public Boolean requiresLicenseeBRCRenewalApplication { get; set; }
    String accountId;
    public boolean isDocumentExpired { get; set; }
    public EEC_PortalLandingController() {
        accessProviderFlag = false;
        accessUmbrellaFlag = false;
        isDocumentExpired = false;
        memberId = ApexPages.currentPage().getParameters().get('member');
        actionMethod();
    }
    public PageReference gotoPersonalPage() {
        Id uid = Userinfo.getUserId();
        USER u = [Select Id,ContactId from User where Id = :uid limit 1];
        PageReference contactPage = Page.EEC_ContactPage;
        contactPage.getParameters().put('Id', u.ContactId);
        contactPage.getParameters().put('page', 'home');
        contactPage.setRedirect(true);
        return contactPage;
    }
    public pagereference actionMethod() {
        List<Profile> profiles = [SELECT Name from Profile where Id = :UserInfo.getProfileId() LIMIT 1];
        if (profiles != null && profiles.size() > 0) {
            profileName = profiles[0].Name;
            isWithoutTransaction = profileName.contains('without transactions');
        }
        User loggedUser = [
                SELECT Id, Name,contactId
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        Contact contact = [
                SELECT Id, Account.Id, Account.RecordType.Name, Account.Umbrella_Members__c
                FROM Contact
                WHERE Id = :loggedUser.contactId
        ];
        if (memberId == null) {
            accountId = contact.Account.Id;
        } else {
            accountId = memberId;
        }
        EEC_Config__c config = EEC_Config__c.getOrgDefaults();
        Date todayDate = Date.Today();
        for (Document__c docObj : [
                SELECT Id, Document_Name__c, Document_Type__c,Status__c,Uploaded_Date__c,Expiration_Date__c
                FROM Document__c
                WHERE Provider__c = :accountId AND Not_Applicable__c = false
        ]) {
            if (docObj.Expiration_Date__c != null) {
                Integer numberOfdays = todayDate.daysBetween(docObj.Expiration_Date__c);
                if (numberOfdays <= config.Document_Expiration_Warning_Days__c) {
                    isDocumentExpired = true;
                    break;
                }
            }
            if (!string.isBlank(docObj.Status__c) && docObj.Status__c != EEC_Constants.DOCUMENT_STATUS_SUBMITTED && !isDocumentExpired) {
                isDocumentExpired = true;
                break;
            }
        }
        if (memberId == null || memberId == '') {
            acc = [
                    SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Use_Physical_Restraints__c, Restraint_Method__c,
                        Provider_Status__c,License_Type__c, Certified_As__c, License_Status__c, OwnerId, Funded_Status__c,
                        Capacity__c, Last_Issue_Date__c, Renewal_date__c,Is_GSA__c, Funded_Provider_Status__c, (
                        Select Id
                        From Licensing_Transactions__r
                            Where Status__c IN:new Set<String>{
                                    'Submitted', 'Under Review'
                            } And RecordType.Name like '%Renewal%'
                    )
                    From Account
                    where ID in (SELECT Accountid FROM User WHERE id = :Userinfo.getUserId())
                    LIMIT 1
            ];
        } else {
            acc = [
                    SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, Use_Physical_Restraints__c, Restraint_Method__c,
                            Provider_Status__c,License_Type__c, Certified_As__c, License_Status__c, OwnerId,Funded_Status__c,
                            Capacity__c, Last_Issue_Date__c, Renewal_date__c,Is_GSA__c,Funded_Provider_Status__c, (
                            Select Id
                            From Licensing_Transactions__r
                            Where Status__c IN:new Set<String>{
                                    'Submitted', 'Under Review'
                            } And RecordType.Name like '%Renewal%'
                    )
                    From Account
                    where ID = :memberId
                    LIMIT 1
            ];
        }
        requiresLicenseeBRCRenewalApplication = false;
        if (acc.Recordtype.DeveloperName == 'Large_Group' || acc.Recordtype.DeveloperName == 'Small_Group') {
            Date todaysDate = Date.Today();
            for (Contact con : [SELECT id,BRC_Role__c,BRC_Renewal_Date__c FROM Contact WHERE BRC_Role__c = 'Licensee' AND AccountId = :acc.id]) {
                if (con.BRC_Renewal_Date__c != null && con.BRC_Renewal_Date__c.daysBetween(todaysDate) <= 120 && !requiresLicenseeBRCRenewalApplication) {
                    requiresLicenseeBRCRenewalApplication = true;
                }
            }
        }
        // system.assert(false,requiresLicenseeBRCRenewalApplication);
        isRPFlow = false;
        if (acc.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
            isFccAssistant = true;
        }
        if (acc.Recordtype.DeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY || acc.Recordtype.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER) {
            isRPFlow = true;
        }
        licensor = [SELECT Id, Name, Email FROM User WHERE Id = :acc.OwnerId Limit 1];
        if (acc.Renewal_date__c != null) {
            remainingDays = Date.today().daysBetween(acc.Renewal_date__c);
            remainingDays = (remainingDays < 0) ? 0 : remainingDays;
            Integer rDays = Date.today().daysBetween(acc.Renewal_date__c.addDays(-30));
            daysFromRenewalDue = (rDays < 0) ? (acc.Licensing_Transactions__r.size() > 0 ? '0' : 'Overdue') : (rDays > 120 ? 'N/A' : '-' + rDays);
        }
        if (acc != null) {
            If (acc.Recordtype.Name.contains('Umbrella')) {
                secureIdMap = new Map<String, String>();
                getproviderslist(acc.Id);
                if (memberId == null || memberId == '') {
                    accessUmbrellaFlag = true;
                } else {
                    accessUmbrellaFlag = false;
                }
            } else {
                accessProviderFlag = true;
                Set<String> addContactsEligibleApplicationSet = new Set<String>{'FCC_New_License', 'FCC_License_Upgrade', 'Change_of_Address', 
                    'FCC_Change_of_Household', 'FCC_Renewal', 'Background_Record_Check', 'GSA_New_License', 'GSA_Renewal', 'GSA_Move',
                    'GSA_Temporary_Move', 'GSA_Change_of_Admin_Authority', 'Contact_Management', 'Licensee_BRC_Renewal', 'Residential_New_License',
                    'Residential_License_Renewal', 'R_P_Change_of_Admin_Authority', 'Placement_New_License', 'Placement_Renewal', 'Placement_Move',
                    'CBC_New_License_Application', 'Private_School_New_Funding_Application', 'Public_School_New_Funding_Application',
                    'Other_Eligible_Providers_New_Funding_Application', 'Summer_Camp_New_Application', 'Child_Care_Licensing_Exemption','Licensee_Management'
                };
                providerDraftLT = getLicensingTransactionByStatus(acc.Id, new List<String> {'Unsubmitted'}, addContactsEligibleApplicationSet);
                providerSubmittedLT = getLicensingTransactionByStatus(acc.Id, new List<String>{'Submitted'}, addContactsEligibleApplicationSet);
                providerInProgressLT = getLicensingTransactionByStatus(acc.Id, new List<String>{'Under Review'}, addContactsEligibleApplicationSet);
                providerProcessedLT = getLicensingTransactionByStatus(acc.Id, new List<String>{'Closed'}, addContactsEligibleApplicationSet);
                /*visititems = [
                        SELECT ID, Name
                        FROM Inspection_Item__c
                        WHERE Inspection_No__r.Provider_No__c = :acc.Id
                        AND To_Review_on_Portal__c = true
                        LIMIT 150
                ]; */
                /*noncompitems = [
                        SELECT Id, Name
                        FROM Non_Compliant__c
                        WHERE Investigation__r.Provider_No__c = :acc.Id
                        AND To_Review_on_Portal__c = true
                        limit 150
                ]; */
            }
            // Get the LEAD config.
            Lead_Configuration__c[] leadConfigs = [Select Id,Name, Portal_Home_Useful_Links__c, Portal_Home_Welcome__c, Portal_Home_Latest_News__c,GSA_days_Prior_Renewal_Can_Go_To_Meeting__c From Lead_Configuration__c Where Name = :acc.RecordType.Name];
            if (leadConfigs != null && leadConfigs.size() > 0) {
                leadConfig = leadConfigs[0];
                LeadconfigDays = integer.valueof(leadConfig.GSA_days_Prior_Renewal_Can_Go_To_Meeting__c);
            }
            getMenuItems();
        }
        return null;
    }
    public List<EEC_LicenseTransactionWrapperClass> getLicensingTransactionByStatus(Id accountID, List<String> status, Set<String> addContactsEligibleApplicationSet) {
        List<EEC_LicenseTransactionWrapperClass> licenseTransactionRecordList = new List<EEC_LicenseTransactionWrapperClass>();
        for (Licensing_Transaction__c transRec : [SELECT Id, Name, Status__c, RecordType.Name,RecordType.DeveloperName,
                                                        Submission_Date__c,Provider__c,
                                                        Provider__r.Is_FCC__c,Provider__r.Is_GSA__c,Provider__r.Is_R_P__c,
                                                        Last_Reached_Step__c, Assigned_To__r.Name,Tax_Certification_Status__c, (
                                                        SELECT ID,Checklist_Name__c,Status__c,Unique_API_Name__c
                                                        FROM Transaction_Due_Diligence__r)
                                                    FROM Licensing_Transaction__c
                                                    WHERE Provider__c = :accountID
                                                    AND Status__c IN:status
                                                    AND Legacy_System_Transaction_Number__c = ''
                                                    AND RecordType.DeveloperName NOT IN :setOfRecordTypes
                                                    ORDER BY CreatedDate DESC 
                                                    LIMIT 5]) {
            licenseTransactionRecordList.add(new EEC_LicenseTransactionWrapperClass(transRec, addContactsEligibleApplicationSet.contains(transRec.RecordType.DeveloperName)));
        }
        return licenseTransactionRecordList;
    }
    public Lead_Configuration__c getLeadConfiguration() {
        return leadConfig;
    }
    public Account getAccount() {
        return acc;
    }
    public void getproviderslist(Id accountId) {
        providerslist = [
                SELECT Id, Name, Provider_Number__c, Provider_city_text__c,
                        Phone, License_Status__c, Provider_Status__c,Is_GSA__c
                FROM Account
                WHERE Umbrella_Members__c = :accountId
                ORDER BY Name ASC NULLS LAST
        ];
    }
    private void createSecureMemberMap() {
        for (Account acc : providerslist) {
            secureIdMap.put(acc.Id, EncodingUtil.urlEncode(EEC_Util.encryptGetParam(acc.Id), 'UTF-8'));
        }
    }
    public PageReference goToProviderPage() {
        PageReference pPage = page.EEC_PortalProviderPage;
        return pPage;
    }
    public PageReference goToUmbrellaPage() {
        PageReference pPage = page.EEC_Umbrella;
        return pPage;
    }
    public PageReference goToSubmitNewTransaction() {
        PageReference pPage = page.EEC_TransactionIntroduction;
        return pPage;
    }
    public PageReference noncomp() {
        PageReference pPage = page.EEC_PortalNonCompliancePage;
        return pPage;
    }
    public PageReference investigationPage() {
        PageReference pPage = page.EEC_Interventionpage;
        return pPage;
    }
    public PageReference goToSubmitNewIncident() {
        PageReference pPage = page.EEC_CasesIncidentsPage;
        return pPage;
    }
    public PageReference goToSubmitNewRestraint() {
        PageReference pPage = Page.EEC_RestraintReport;
        return pPage;
    }
    public PageReference goToNonComplianceAction() {
        PageReference pPage = Page.EEC_PortalNonCompliancePage;
        return pPage;
    }
    public String getEncryptedAccountId() {
        return EncodingUtil.urlEncode(EEC_Util.encryptGetParam(acc.Id), 'UTF-8');
    }
    public void getMenuItems() {
        lstMenuItems = new List<MenuItem>();
        if (acc.Recordtype.DeveloperName == EEC_Constants.PRO_UMBRELLA) {
            lstMenuItems.add(new MenuItem('Your Umbrella Information', 'Review your umbrella information, and select a provider to review', 'fa-umbrella', 'EEC_Umbrella'));
        } else if (acc.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
            lstMenuItems.add(new MenuItem('Assistant Information', 'Review your certificate information as well as the transaction and other past interactions with EEC.', 'fa-user', 'EEC_PortalProviderPage?member=' + acc.Id));
            lstMenuItems.add(new MenuItem('New Transaction', 'Create a new transaction (new license, renewal, upgrade..) and submit to EEC', 'fa-check-square-o', 'EEC_TransactionIntroduction?member=' + acc.Id));
        } else if (acc.Recordtype.DeveloperName == EEC_Constants.PRO_GROUP_CARE || (acc.Recordtype.DeveloperName == EEC_Constants.PRO_LARGE_GROUP || acc.Recordtype.DeveloperName == EEC_Constants.PRO_SMALL_GROUP) || acc.Recordtype.DeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY || acc.Recordtype.DeveloperName == EEC_Constants.PRO_ADOPTION_AGENCY || acc.Recordtype.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER) {
            lstMenuItems.add(new MenuItem('Program Information', 'Review your provider and license information as well as the past and current transactions.', 'fa-user', 'EEC_PortalProviderPage?member=' + acc.Id));
            lstMenuItems.add(new MenuItem('New Transaction', 'Create a new transaction (new license, renewal, upgrade..) and submit to EEC', 'fa-check-square-o', 'EEC_TransactionIntroduction?member=' + acc.Id));
            if ((acc.Recordtype.DeveloperName == EEC_Constants.PRO_LARGE_GROUP || acc.Recordtype.DeveloperName == EEC_Constants.PRO_SMALL_GROUP) && requiresLicenseeBRCRenewalApplication) {
                lstMenuItems.add(new MenuItem('BRC Licensee Renewal', 'BRC Licensee Renewal', 'fa-check-square-o', 'EEC_LicenseeBRCRenewalPage?member=' + acc.Id));
            }
        } else {
           /* Integer visititems = [
                    SELECT Count()
                    FROM Inspection_Item__c
                    WHERE Inspection_No__r.Provider_No__c = :acc.Id
                    AND To_Review_on_Portal__c = true
            ];*/
            lstMenuItems.add(new MenuItem('Provider Information', 'Review your provider and license information as well as the past and current transactions.', 'fa-user', 'EEC_PortalProviderPage?member=' + acc.Id));
            lstMenuItems.add(new MenuItem('New Transaction', 'Create a new transaction (new license, renewal, upgrade..) and submit to EEC', 'fa-check-square-o', 'EEC_TransactionIntroduction?member=' + acc.Id));
            if (acc.License_Status__c == 'Licensed') {
                lstMenuItems.add(new MenuItem('New Incident / Injury', 'Log a new self-reported incident/injury involving a child in your program.', 'fa-tasks', 'EEC_CasesIncidentsPage'));
            }
            if (acc.Use_Physical_Restraints__c && acc.Restraint_Method__c != null && acc.Restraint_Method__c != 'NonRestraint ' && (acc.Recordtype.DeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER || acc.Recordtype.DeveloperName == EEC_Constants.PRO_GROUP_CARE)) {
                lstMenuItems.add(new MenuItem('Submit Quarterly Restraint Report', 'Submit a new Quarterly Restraint report to electronically to EEC.', 'fa-pie-chart', 'EEC_RestraintReport'));
            }
            if (acc.Is_GSA__c == true && remainingdays != null && remainingdays <= LeadconfigDays && remainingdays >= 0) {
                lstMenuItems.add(new MenuItem('Renewal Meeting Registration', 'Manage your registration for the mandatory renewal meeting.', 'fa-pie-chart', 'EEC_meetingRegistration'));
            }
            if (acc.Recordtype.DeveloperName == EEC_Constants.PRO_FCC && acc.License_Status__c == 'Licensed') {
                lstMenuItems.add(new MenuItem('Update Affiliated Assistants', 'Update the list of FCC assistants working with you and submit the update to EEC', 'fa-street-view', 'EEC_AssistantUpdateList?param=' + getEncryptedAccountId()));
            }
        }
        if (!(acc.Recordtype.DeveloperName == EEC_Constants.PRO_FCC) && !(acc.Recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) && profileName != 'Community Standard Umbrella User for EEC') {
            lstMenuItems.add(new MenuItem('Document Library', 'A gallery for all your portal documents and attachments.', 'fa-archive', 'EEC_DocumentLibrary?member=' + acc.Id));
        }
        if (!(acc.Recordtype.DeveloperName == EEC_Constants.PRO_UMBRELLA) && profileName != 'Community Standard Umbrella User for EEC') {
            lstMenuItems.add(new MenuItem('Fill Non-Compliance Corrective Actions', 'Review your pending non-compliance statement and submit your corrective actions', 'fa-folder-open', 'EEC_PortalNonCompliancePage'));
            lstMenuItems.add(new MenuItem('Technical Helpdesk', 'Manage your all support tickets.', 'fa-ticket ', 'EEC_SupportHelpdesk'));
        }
        if (acc.Recordtype.DeveloperName == EEC_Constants.PRO_UMBRELLA) {
            lstMenuItems.add(new MenuItem('Document Library', 'A gallery for all your portal documents and attachments.', 'fa-archive', 'EEC_DocumentLibrary'));
            lstMenuItems.add(new MenuItem('Technical Helpdesk', 'Manage your all support tickets.', 'fa-ticket ', 'EEC_SupportHelpdesk'));
        }
        if (!(acc.Recordtype.DeveloperName == EEC_Constants.PRO_UMBRELLA) && profileName == 'Community Standard Umbrella User for EEC') {
            lstMenuItems.add(new MenuItem('Fill Non-Compliance Corrective Actions', 'Review your pending non-compliance statement and submit your corrective actions', 'fa-folder-open', 'EEC_PortalNonCompliancePage?member=' + acc.Id));
            lstMenuItems.add(new MenuItem('Document Library', 'A gallery for all your portal documents and attachments.', 'fa-archive', 'EEC_DocumentLibrary?member=' + acc.Id));
            lstMenuItems.add(new MenuItem('Go Back to Umbrella', 'Go back to your umbrella account', 'fa-home', 'EEC_PortalLandingPage'));
        }
        if(acc.Recordtype.DeveloperName == EEC_Constants.PRO_FCC 
                || acc.Recordtype.DeveloperName == EEC_Constants.PRO_LARGE_GROUP 
                || acc.Recordtype.DeveloperName == EEC_Constants.PRO_SMALL_GROUP) {
            lstMenuItems.add(new MenuItem('Parent Portal Self Service', 'Navigate to parent portal self service portal.', 'fa-file-image-o', 'EEC_ChildCareSchedulesHours'));
        }
    }
    public class MenuItem { 
        public string name { get; set; }
        public string description { get; set; }
        public string icon { get; set; }
        public string destination { get; set; }
        public MenuItem(string name, string description, string icon, string destination) {
            this.name = name;
            this.description = description;
            this.icon = icon;
            this.destination = destination;
        }
    }
}