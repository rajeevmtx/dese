/**
    * EEC_PortalMyProviderPageController
    *
    * @description An apex class that views and updates provider/umbrella information. Portal provider
    * page is made up of different sections that are displayed/hidden based on available provider data.
    * Provider can reports incidents, submit the corrective action or request portal access from this page.
    * Each section will display list of available records e.g. investigations section will list investigations
    * related to that provider.
*/
public without sharing class EEC_PortalMyProviderPageController {
    public Map<Id,String> mapContactIdWithRoles                         { get; set; }
    public Map<Id, String> mapConIdWithRoles                            { get; set; }
    public List<Conditions_and_Limitations__c> conditions               { get; set; }
    public String condition_none                                        { get; set; }
    public List<Account> providerslist                                  { get; set; }
    public list<ContactWrapper> contactlist                             { get; set; }
    public list<UserWrapper> userlist                                   { get; set; }
    public List<ContactRoleWrapper> contactRolelist                     { get; set; }
    public list<Inspection__c> inspectionlist                           { get; set; }
 //   public list<Investigation__c> investlist                            { get; set; }
    public list<Licensing_Transaction__c> licenselist                   { get; set; }
    //public list<Restraint_Report__c> reportlist                         { get; set; }
    public list<CaseWrapper> incidentlist                               { get; set; }
    public list<CaseWrapper> requiredNotificationList                   { get; set; }
    //public list<Intervention__c> interventionlist                       { get; set; }
    public List<EEC_AssistantListCtrl.AssistantInfoWrap> assistantList  { get; set; }
    public List<EEC_VarianceListCtrl.VarianceInfoWrap> varianceList     { get; set; }
    public String conditionStr                                          { get; set; }
    public String profileName                                           { get; set; }
    public Boolean isWithoutTransaction                                 { get; set; }
    public String memberId                                              { get; set; }
    public String memberIds                                             { get; set; }
    private String sortDirection = 'ASC';
    private String sortExp = 'License_Status__c';
    public String Attachmentid                                          { get; set; }
    public map<string, string> attachmap                                { get; set; }
    public set<string> caseid = new set<string>();
    public integer listsize                                             { get; set; }
    public Map<String, PageReference> lastStepMap;
    public Map<String, String> secureMemberMap                          { get; set; }
    public Map<String, String> secureIdMap                              { get; set; }
    public String errorMsg                                              { get; set; }
    public Boolean isUmbrellaUser                                       { get; set; }
    public EEC_PaginatedSelectList allCityList                          { get; set; }
    public EEC_PaginatedSelectList maCityList                           { get; set; }
    public string accountName                                           { get; set; }
    private Account account;
    private Contact contact;
    private String accountid;
    private User user;
    private boolean isEdit = false;
    String PageURL;
    public Account getAccount() {
        return account;
    }
    public Contact getContact() {
        return contact;
    }
    public User getUser() {
        return user;
    }
    public Boolean getIsEdit() {
        return isEdit;
    }
    public class CaseWrapper {
        public Case casedetail                   { get; set; }
        public Attachment attachment             { get; set; }
    }
    public class ContactWrapper {
        public Contact contactdetail             { get; set; }
        public User userdetail                   { get; set; }
        public Task taskdetail                   { get; set; }
    }
    public class ContactRoleWrapper {
        public Contact_Role__c contactroledetail { get; set; }
        public User userdetail                   { get; set; }
        public Task taskdetail                   { get; set; }
    }
    public class UserWrapper {
        public User userdetail                   { get; set; }
        public Task taskdetail                   { get; set; }
    }
    public EEC_PortalMyProviderPageController() {
        List<Account> tempAccount;
        isUmbrellaUser = (String) [SELECT Contact.Account.recordType.Name FROM User WHERE Id = :Userinfo.getUserId()].Contact.Account.recordType.Name == 'Umbrella';
        secureIdMap = new Map<String, String> ();
        attachmap = new map<string, string>();
        PageURL = ApexPages.currentPage().getUrl();
        memberId = ApexPages.currentPage().getParameters().get('member');
        List<Profile> profiles = [SELECT Name from profile where Id = :userinfo.getProfileId() LIMIT 1];
        if (profiles.size() > 0) {
            profileName = profiles[0].Name;
            isWithoutTransaction = profileName.contains('without transactions');
        }
        if (PageUrl.equalsIgnoreCase(Page.EEC_Umbrella.getURL())) {
            tempAccount = [Select Id, Umbrella_Members__c, RecordType.Name From Account Where ID in (Select Accountid From User Where id = :Userinfo.getUserId()) Limit 1];
            if (tempAccount != null && tempAccount.size() == 1 && !tempAccount[0].Recordtype.Name.contains('Umbrella')) {
                tempAccount = [Select Id, RecordType.Name From Account Where Id = :tempAccount.get(0).Umbrella_Members__c];
            }
        } else {
            if (!String.isBlank(memberId)) {
                // memberId = EEC_Util.decryptGetParam(memberId);
                tempAccount = [Select Id, Name,RecordType.Name From Account Where ID = :memberId Limit 1];
                accountName = tempAccount[0].Name;
            } else {
                tempAccount = [Select Id, RecordType.Name From Account Where ID in (Select Accountid From User Where id = :Userinfo.getUserId()) Limit 1];
            }
        }
        if (tempAccount != null && tempAccount.size() == 1) {
            accountid = tempAccount.get(0).Id;
        }
        if (accountid == null) {
            accountid = ApexPages.currentPage().getParameters().get('accountid');
        }
        if (accountid != null) {
            getProviderdata();
        }
        if (account != null) {
            getContactlist();
            getContactRolelist();
            getLicenselist();
            getinspectionlist();
            getincidentslist();
            getinvestlist();
            getreportlist();
            getconditions();
            getproviderslist();
            getProviders();
            getinterventionlist();
            defineLastStepMap();
            defineattachmap();
            createSecureMemberMap();
            if (account.Recordtype.Name != 'FCC Assistant') {
                maCityList = EEC_Util.maCityList();
            } else {
                maCityList = EEC_Util.allCityList();
            }
            EEC_AssistantListCtrl assistCtrl = new EEC_AssistantListCtrl();
            assistCtrl.mAccount = account;
            assistCtrl.mPopulateUsingAssistant = true;
            assistantList = assistCtrl.getAssistantsList();
            //Variances for this provider - fix for LEAD-4670
            EEC_VarianceListCtrl varianceCtrl = new EEC_VarianceListCtrl();
            varianceCtrl.mAccount = account;
            varianceCtrl.mPopulateUsingAccount = true;
            varianceList = varianceCtrl.getVariancesList();
        }
        if (String.isBlank(accountid) && account == null) {
            errorMsg = 'An error has occured. Please contact your administrator for assistance.';
        }
    }
    public SelectOption[] getCityOptions() {
        SelectOption[] cities = new SelectOption[]{
        };
        cities.add(new SelectOption('', '--None--'));
        for (City__c c : [SELECT id, Name, State__c FROM City__c WHERE isdeleted = false order by Name]) {
            cities.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
        }
        return cities;
    }
    public SelectOption[] getMACityOptions() {
        SelectOption[] cities = new SelectOption[]{
        };
        cities.add(new SelectOption('', '--None--'));
        for (City__c c : [SELECT id, Name, State__c FROM City__c WHERE State__c = 'MA' AND isdeleted = false order by Name]) {
            cities.add(new SelectOption(c.id, c.name + ' (' + c.State__c + ')'));
        }
        return cities;
    }
    public PageReference trxIntro() {
        PageReference pPage = page.EEC_TransactionIntroduction;
        addMemberIdParameter(pPage);
        return pPage;
    }
    public PageReference noncomp() {
        PageReference pPage = page.EEC_PortalNonCompliancePage;
        addMemberIdParameter(pPage);
        return pPage;
    }
    public PageReference investigationPage() {
        PageReference pPage = page.EEC_Interventionpage;
        addMemberIdParameter(pPage);
        return pPage;
    }
    public PageReference home() {
        return Page.EEC_PortalLandingPage;
    }
    public Pagereference cancel() {
        isEdit = false;
        PageReference pageRef = new PageReference(PageURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference subInc() {
        PageReference pPage = page.EEC_CasesIncidentsPage;
        addMemberIdParameter(pPage);
        return pPage;
    }
    public PageReference subReqNotification() {
        PageReference pPage = page.EEC_CasesIncidentsPage;
        pPage.getParameters().put('type', 'required_notification');
        if (String.isNotBlank(memberId))
            pPage.getParameters().put('member', accountid);
        return pPage;
    }
    public PageReference resReport() {
        PageReference pPage = page.EEC_RestraintReport;
        addMemberIdParameter(pPage);
        return pPage;
    }
    public PageReference save() {
        try {
            if (account != null) {
                account.Need_A_Change_Of_Address__c = true;
                update account;
            }
            isEdit = false;
        } catch (DmlException e) {
            ApexPages.addMessages(e);
        }
        PageReference pageRef = new PageReference(PageURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public void getProviderdata() {
        try {
            account = [
                    select id, name, Umbrella_Members__c,School_Year_From__c,Number_of_toilets__c,Well_Water_Test_date__c,Detailed_Inspection__c,Indoor_Compliance_with_ADA__c,Lead_Paint_Compliance__c,Fire_Inspection_Issue_date__c,Integrated_Pest_Management_Date__c,PWS_Public_Water_Source_Number__c,Health_Inspection_Expiration_Date__c,Building_Codes__c,Building_inspection_expiration_Date__c,Building_Inspection_Max_Capacity__c,Pool_roof_inspection_date__c,Number_of_sinks__c,Record_Type_Name__c,Indoor_Square_Footage__c,Outdoor_Square_footage__c,School_Year_To__c, Umbrella_Members__r.Name, Business_Name__c, Recordtype.Name, Provider_Number__c, License_Status__c, Provider_Status__c, Tax_ID__c, OwnerId
                            , Public_Approval__c, Publish_on_Web__c, Head_Start__c, Accept_Referral__c, Phone, Alternate_Phone__c, fax, Provider_Email__c, Provider_Address_1__c,
                            Provider_Address_2__c, Certified_As__c, Provider_City__r.Name, State__c, Provider_Zip_Code__c, Outdoor_Compliance_with_ADA__c,Sub_contractor_Name__c,Current_License_Number__c, License_Type__c,//ShippingAddress,
                            First_Issue_Date__c, Last_Issue_Date__c, Renewal_date__c, Foster_Parent__c, Bi_lingual_Licensor__c, Language__c, capacity__c,
                            Preferred_Language__c, Race__c, Regulatory_Status__c, Gender__c, Has_Multi_Age_Group__c, Min_Age_Years_LG_SG__c, Min_Age_Months__c,
                            Max_Age_Years_LG_SG__c, Max_Age_Months__c, Has_Full_Day_Program__c, Has_Camp_Capacity__c, Full_School_Year__c,
                            Pool_Approved__c, Provide_Transportation__c, Cafeteria_Approved__c, Gym_Approved__c, Offsite_Outdoor_Play_Location__c, Other_Approved_Additional_Space__c,
                            Total_Staff__c, Referral_Required__c, Referral_Agency__c, Private_Adoption__c, Program_Age__c, Level_of_Care__c, Approved_Reg_766__c, Use_Physical_Restraints__c,
                            Restraint_Method__c, Secured_Facility__c, Locked_Facility__c, Administer_Own_School__c, Has_Medical_Administration__c, Characteristics_of_Children_Served__c,
                            Specialties__c, Number_of_Foster_Homes__c, Number_of_Children_Placed_in_Care__c, Awake_Ratio__c, Asleep_Ratio__c, Ratios__c, Ratio_Comment__c,
                            Infant_birth_15_mo__c, Infant_Toddler_birth_33_mo__c, Toddler_15_mo_33_mo__c, Toddler_Preschool_15_mo_K__c, Preschool_33_mo_K__c, Preschool_SA_33_mo_8_yr__c,
                            Kindergarten__c, Kindergarten_School_Age__c, School_Age_5_yr_14_yr__c, Multi_Age_Group_birth_14_yr__c, Summer_Capacity__c,
                            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Provider_city_text__c, FCC_System__c, Can_Communicate_in_English__c, RecordType.DeveloperName,
                            Full_Day_Program_Available_On__c, Full_Day_Program_Available_From__c, Half_Day_Morning_Program_Available_On__c, Half_Day_Morning_Program_Available_From__c,
                            Half_Day_Afternoon_Program_Available_On__c, Half_Day_Afternoon_Program_Avail_From__c, Evenings_Service_Provided__c, Full_Day_Program_Available_To__c, Half_Day_Morning_Program_Available_To__c, Half_Day_Afternoon_Program_Available_To__c, Extended_Day_Available_On__c, Drop_In_Service_Provided__c, Summer_Camp_Services_Provided__c,
                            Account_books_Responsible__c,
                            Records_Responsible__c,
                            Personnel_Records_Responsible__c,
                            Children_s_Records_Responsible__c,
                            Financial_Documentation_Responsible__c,
                            Staff_Schedules_Responsible__c,
                            Early_Childhood_Education_Program_Resp__c,
                            Kindergarten_Responsible__c,
                            School_age_Responsible__c,
                            Services_for_Children_w_Disability_Resp__c,
                            Daily_activities_Responsible__c,
                            Equipment_Responsible__c,
                            Staff_Development_Responsible__c,
                            Staff_Training_Responsible__c,
                            Staff_Orientation_Responsible__c,
                            Staff_Supervision_Responsible__c,
                            Parent_Involvement_Responsible__c,
                            Social_Services_Responsible__c,
                            Infant_Toddler_Program_Responsible__c,
                            Is_At_Temporary_Address__c,
                            Projected_Date_of_Return__c,
                            BillingStreet, BillingCity, BillingState, BillingPostalCode
                    from account
                    where id = :accountId
                    limit 1
            ];
            if (account != null) {
                List<Contact> contactList = [select id, Name, Title, Email, Phone, Role__c from Contact where Accountid = :account.id limit 1];
                List<User> userList = [select id, name, Phone, Email from user where id = :account.Ownerid limit 1];
                if (contactList.size() > 0) {
                    contact = contactList[0];
                }
                if (userList.size() > 0) {
                    user = userList[0];
                }
            }
        } catch (exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator');
            ApexPages.addMessage(errMsg);
        }
    }
    public String getFCCSystemName() {
        Account[] fccSystem = [Select Id, Name From Account Where Id = :account.FCC_System__c];
        if (fccSystem.size() > 0)
            return fccSystem[0].Name;
        return null;
    }
    public void getContactlist() {
        try {
            //Mod by LD on 1/9/17 - Fix for LEAD-4725
            if (account.Recordtype.Name.contains('Family') || account.Recordtype.Name.contains('Assistant')) {
                contactlist = new List<ContactWrapper>();
                userlist = new List<UserWrapper>();
                List<Contact> listcontact = [
                        select id, Name, Title, Email, Phone, Role__c,Status__c
                        from Contact
                        where Status__c = :EEC_Constants.CONTACT_ROLE_STATUS_ACTIVE AND Accountid = :account.id and Role__c in
                        (:EEC_Constants.CONTACT_ROLE_DIRECTOR, :EEC_Constants.CONTACT_ROLE_DESIGNEE, :EEC_Constants.CONTACT_ROLE_BOARD_CHAIR,
                                :EEC_Constants.CONTACT_ROLE_FUNDING_SOURCE, :EEC_Constants.CONTACT_ROLE_LICENSEE, :EEC_Constants.CONTACT_ROLE_ASSISTANT,:EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR,:EEC_Constants.CONTACT_ROLE_EXECUTIVE_DIRECTOR)
                        limit 50
                ];
                List<User> listUser = [select Id, UserName, Name, ContactId, Email, LastLoginDate from User where ContactId in :listcontact];
                List<Task> listtask = [SELECT ID, Subject, Status, WhoID FROM Task Where WhoID in :listcontact and status <> 'Completed'];
                Map<ID, User> mapuser = new Map<ID, User>();
                Map<ID, List<Task>> maptask = new Map<Id, List<Task>>();
                for (User user : listUser) {
                    mapuser.put(user.contactid, user);
                }
                for (Task task : listtask) {
                    List<Task> tasks;
                    if (maptask.get(task.whoid) == null) {
                        tasks = new List<Task>();
                    } else {
                        tasks = maptask.get(task.whoid);
                    }
                    tasks.add(task);
                    maptask.put(task.whoid, tasks);
                }
                for (Contact c : listcontact) {
                    ContactWrapper contactwrapper = new ContactWrapper();
                    contactwrapper.contactdetail = c;
                    User user = mapuser.get(c.id);
                    if (user != null) {
                        contactwrapper.userdetail = user;
                    }
                    List<Task> tasks = maptask.get(c.id);
                    if (tasks != null) {
                        for (Task task : tasks) {
                            if (task.subject == 'Request by ' + c.Name + ' related to ' + account.Name + ' to activate user with user name: ' + c.Email && task.status != EEC_Constants.TASK_STATUS_COMPLETED) {
                                contactwrapper.taskdetail = task;
                                break;
                            }
                        }
                    }
                    contactlist.add(contactwrapper);
                }
                for (User user : listuser) {
                    UserWrapper userwrapper = new UserWrapper();
                    userwrapper.userdetail = user;
                    List<Task> tasks = maptask.get(user.contactid);
                    if (tasks != null) {
                        for (Task task : tasks) {
                            if (task.subject == 'Request by ' + user.Name + ' related to ' + account.Name + ' to inactivate user with user name: ' + user.UserName && task.status != EEC_Constants.TASK_STATUS_COMPLETED) {
                                userwrapper.taskdetail = task;
                                break;
                            }
                        }
                    }
                    userlist.add(userwrapper);
                }
            }
        } catch (exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator');
            ApexPages.addMessage(errMsg);
            system.assert(false, ex.getMessage() + ' line ' + ex.getLineNumber() + ' trace ' + ex.getStackTraceString());
        }
    }
    public String getAttachmentId() {
        list<attachment> Att = new list<attachment>([Select id,name,parentid from attachment where parentid IN:Caseid and name = 'CaseSubmitted.pdf']);
        if (att.size() > 0)
            return att[0].id;
        return null;
    }
    public void defineattachmap() {
        list<attachment> Att = new list<attachment>([Select id,name,parentid from attachment where parentid IN:Caseid and name = 'CaseSubmitted.pdf']);
        if (Att.size() > 0)
            for (Attachment a : Att)
                attachmap.put(a.parentid, a.id);
    }
    //Added by LD on 1/9/17 - Fix for LEAD-4725
    public void getContactRolelist() {
        try {
            //Mod by LD on 1/9/17 - Fix for LEAD-4725
            if (!account.Recordtype.Name.contains('Family') && !account.Recordtype.Name.contains('Assistant')) {
                mapContactIdWithRoles = new Map<Id,String> ();
                Set<Contact> setContact = new Set<Contact>();
                Set<Id> setContacts = new Set<Id>();
                contactlist = new List<ContactWrapper>();
                contactRolelist = new List<ContactRoleWrapper>();
                userlist = new List<UserWrapper>();
                mapConIdWithRoles = new Map<Id, String>();
                List<Contact_Role__c> listContactRole;
                if (account.Recordtype.Name.contains(EEC_Constants.PRO_UMBRELLA)) {
                    listContactRole = [select id,Role__c, Start_Date__c, Contact__r.Name,  Contact__r.Role__c, Contact__r.Title,Contact__r.Start_Date__c, Contact__r.Email,Contact__r.Status__c, Contact__r.Phone, Contact__r.Id from Contact_Role__c where Contact__r.Status__c = 'Active' AND  Status__c = 'Active' AND Provider__r.Id = :account.id and Current_Formula__c = true limit 50];
                } else {
                    listContactRole = [
                            select id,Role__c, Start_Date__c, Contact__r.Name, Contact__r.Title,Contact__r.Start_Date__c,  Contact__r.Role__c, Contact__r.Email,Contact__r.Status__c, Contact__r.Phone, Contact__r.Id
                            from Contact_Role__c
                            where Contact__r.Status__c = :EEC_Constants.CONTACT_STATUS_ACTIVE AND   Status__c = :EEC_Constants.CONTACT_ROLE_STATUS_ACTIVE AND  Provider__r.Id = :account.id and Role__c in
                            (:EEC_Constants.CONTACT_ROLE_DIRECTOR, :EEC_Constants.CONTACT_ROLE_DESIGNEE, :EEC_Constants.CONTACT_ROLE_BOARD_CHAIR,
                                    :EEC_Constants.CONTACT_ROLE_FUNDING_SOURCE, :EEC_Constants.CONTACT_ROLE_LICENSEE, :EEC_Constants.CONTACT_ROLE_ASSISTANT,:EEC_Constants.CONTACT_ROLE_PROGRAM_DIRECTOR,:EEC_Constants.CONTACT_ROLE_EXECUTIVE_DIRECTOR) and Current_Formula__c = true
                            limit 50
                    ];
                }
                for (Contact_Role__c contactRole : listContactRole) {
                    setContacts.add(contactRole.Contact__r.Id);
                    if(!setContact.contains(contactRole.Contact__r)) {
                        ContactWrapper conWrapper = new ContactWrapper();
                        conWrapper.contactdetail = contactRole.Contact__r;
                        contactlist.add(conWrapper);
                        setContact.add(contactRole.Contact__r);
                    }
                }
                List<User> listUser = [select Id, UserName, Name, ContactId, Email, LastLoginDate from User where ContactId in :setContacts];
                List<Task> listtask = [SELECT ID, Subject, Status, WhoID FROM Task Where whoId in :setContacts];
                Map<ID, User> mapuser = new Map<ID, User>();
                Map<ID, List<Task>> maptask = new Map<Id, List<Task>>();
                for (User user : listUser) {
                    mapuser.put(user.contactid, user);
                }
                for (Task task : listtask) {
                    List<Task> tasks;
                    if (maptask.get(task.whoid) == null) {
                        tasks = new List<Task>();
                    } else {
                        tasks = maptask.get(task.whoid);
                    }
                    tasks.add(task);
                    maptask.put(task.whoid, tasks);
                }
                for (Contact_Role__c contactRole : listContactRole) {
                    ContactRoleWrapper contactrolewrapper = new ContactRoleWrapper();
                    contactrolewrapper.contactroledetail = contactRole;
                    if (!mapConIdWithRoles.containsKey(contactRole.Contact__c)) {
                        mapConIdWithRoles.put(contactRole.Contact__c, contactRole.Role__c);
                    } else {
                        String contactRoleName = mapConIdWithRoles.get(contactRole.Contact__c);
                        contactRoleName += '; ' + contactRole.Role__c;
                        mapConIdWithRoles.put(contactRole.Contact__c, contactRoleName);
                    }
                    User user = mapuser.get(contactRole.Contact__r.Id);
                    if (user != null) {
                        contactrolewrapper.userdetail = user;
                    }
                    List<Task> tasks = maptask.get(contactRole.Contact__r.Id);
                    if (tasks != null) {
                        for (Task task : tasks) {
                            if (task.subject == 'Request by ' + contactRole.Contact__r.Name + ' related to ' + account.Name + ' to activate user with user name: ' + contactRole.Contact__r.Email && task.status != EEC_Constants.TASK_STATUS_COMPLETED) {
                                contactrolewrapper.taskdetail = task;
                                break;
                            }
                        }
                    }
                    contactRolelist.add(contactrolewrapper);
                }
                for (User user : listuser) {
                    UserWrapper userwrapper = new UserWrapper();
                    userwrapper.userdetail = user;
                    List<Task> tasks = maptask.get(user.contactid);
                    if (tasks != null) {
                        for (Task task : tasks) {
                            if (task.subject == 'Request by ' + user.Name + ' related to ' + account.Name + ' to inactivate user with user name: ' + user.UserName && task.status != EEC_Constants.TASK_STATUS_COMPLETED) {
                                userwrapper.taskdetail = task;
                                break;
                            }
                        }
                    }
                    userlist.add(userwrapper);
                }
            }
        } catch (exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator');
            ApexPages.addMessage(errMsg);
        }
    }
    public void requestDeactivate() {
        String userId = ApexPages.currentPage().getParameters().get('userId');
        User user = [select Id, Name,UserName, ContactId from User where Id = :userId];
        Task deactivateTask = new Task();
        deactivateTask.Status = EEC_Constants.TASK_STATUS_NOT_STARTED;
        deactivateTask.Priority = EEC_Constants.TASK_PRIORITY_MEDIUM;
        deactivateTask.WhatId = account.Id;
        deactivateTask.WhoId = user.ContactId;
        deactivateTask.OwnerId = account.OwnerId;
        deactivateTask.ActivityDate = date.today() + 2;
        deactivateTask.Description = EEC_Constants.TASK_DESCRIPTION_MAKE_USER_INACTIVE;
        deactivateTask.IsVisibleInSelfService = true;
        deactivateTask.Subject = 'Request by ' + user.Name + ' related to ' + account.Name + ' to inactivate user with user name: ' + user.UserName;
        insert deactivateTask;
        getContactlist();
        getContactRolelist();
    }
    public void requestPortalAccess() {
        String contactId = ApexPages.currentPage().getParameters().get('contactId');
        Contact Contact = [select Id, Name, Email from Contact where Id = :contactId];
        Task requestAccessTask = new Task();
        requestAccessTask.Status =  EEC_Constants.TASK_STATUS_NOT_STARTED;
        requestAccessTask.Priority = EEC_Constants.TASK_PRIORITY_MEDIUM;
        requestAccessTask.WhatId = account.Id;
        requestAccessTask.OwnerId = account.OwnerId;
        requestAccessTask.ActivityDate = date.today() + 2;
        requestAccessTask.Description = EEC_Constants.TASK_DESCRIPTION_ACTIVATE_USER;
        requestAccessTask.WhoId = contactId;
        requestAccessTask.IsVisibleInSelfService = true;
        requestAccessTask.Subject = 'Request by ' + Contact.Name + ' related to ' + account.Name + ' to activate user with user name: ' + Contact.Email;
        insert requestAccessTask;
        getContactlist();
        getContactRolelist();
    }
    public void getLicenselist() {
        licenselist = [
                Select
                        id,
                        Name,
                        Recordtype.Name,
                        RecordType.DeveloperName,
                        Status__c,
                        ECE_program_Responsible__c,
                        Last_Reached_Step__c,
                        Submission_Date__c,
                        Assigned_To__r.name,
                        Assigned_To__r.Email,
                        Assigned_To__r.Phone,
                        Operation_Type__c
                From Licensing_Transaction__c
                Where Provider__c = :account.id AND RecordType.DeveloperName != :EEC_Constants.LT_LEGACY_SYSTEM_TRANSACTION
                order by CreatedDate Desc
                limit 50
        ];
    }
    public void getinspectionlist() {
        
    }
    public void getincidentslist() {
       
    }
    public void getinvestlist() {
      
    }
    public void getreportlist() {
      
    }
    public void getconditions() {
        try {
            conditions = [SELECT id from Conditions_and_Limitations__c WHERE Condition_Status__c = :EEC_Constants.CONDITION_LIMITATION_STATUS_APPROVED AND Provider__c = :accountId];
        } catch (exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error occurred ! Please contact your System Administrator');
            ApexPages.addMessage(errMsg);
        }
        if (conditions == null || conditions.size() == 0) {
            conditionStr = 'None';
        } else {
            conditionStr = '';
            for (Conditions_and_Limitations__c cond : conditions) {
                //conditionStr = conditionStr + cond.Condition_On_License__c + '. ';
            }
            if (String.isNotBlank(conditionStr) && conditionStr.length() > 2) {
                conditionStr = conditionStr.substring(0, conditionStr.length() - 2);
            }
        }
    }
    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC'; else
                    sortDirection = 'ASC';
            sortExp = value;
        }
    }
    public String getSortDirection() {
        if (sortExpression == null || sortExpression == '')
            return 'ASC'; else
                return sortDirection;
    }
    public void setSortDirection(String value) {
        sortDirection = value;
    }
    public PageReference getProviders() {
        string sortFullExp = ' order by ' + sortExpression + ' ' + sortDirection + ' NULLS LAST' ;
        string query = 'Select id,name,Provider_Number__c,Provider_city_text__c,Phone,License_Status__c,recordtype.name,Provider_Status__c FROM Account WHERE Umbrella_Members__c = \'' + account.Id + '\'' + sortFullExp;
        providerslist = Database.query(query);
        return null;
    }
    public void getproviderslist() {
        providerslist = [SELECT Id, Name, RecordType.Name, Provider_Number__c, Provider_city_text__c, Phone, License_Status__c, Provider_Status__c FROM Account WHERE Umbrella_Members__c = :account.id LIMIT 50];
    }
    public void getinterventionlist() {
        
    }
    public void edit() {
        isEdit = true;
    }
    public void addMemberIdParameter(PageReference pPage) {
        if (String.isNotBlank(memberId))
            pPage.getParameters().put('member', accountid);
    }
    public Pagereference editInstruction() {
        String ltId = ApexPages.currentPage().getParameters().get('licTransId');
        Licensing_Transaction__c lt;
        Licensing_Transaction__c[] lts = [select Id, Last_Reached_Step__c from Licensing_Transaction__c where Id = :ltId];
        if (lts.size() > 0) {
            lt = lts[0];
            PageReference pPage;
            if (lt.Last_Reached_Step__c == EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP && account.recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
                pPage = Page.EEC_AssistantInvolvementExperience;
            } else {
                if (account.recordtype.DeveloperName == EEC_Constants.PRO_FCC) {
                    pPage = EEC_Util.lastFCCStepMap.get(lt.Last_Reached_Step__c);
                } else if (account.recordtype.DeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
                    pPage = EEC_Util.lastFCCAssitantStepMap.get(lt.Last_Reached_Step__c);
                } else if (account.recordtype.DeveloperName == EEC_Constants.PRO_LARGE_GROUP|| account.recordtype.name == EEC_Constants.PRO_SMALL_GROUP) {
                    pPage = EEC_Util.lastGSAStepMap.get(lt.Last_Reached_Step__c);
                } else {
                    pPage = EEC_Util.lastRPStepMap.get(lt.Last_Reached_Step__c);
                }
            }
            pPage.getParameters().put('ltId', lt.Id);
            addMemberIdParameter(pPage);
            return pPage;
        } else
                return null;
    }
    private void defineLastStepMap() {
        lastStepMap = new Map<String, PageReference>();
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_INSTRUCTION, Page.EEC_TransactionInstructions);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_TRANSACTION_PRO_INFO, Page.EEC_TransactionProvider);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_HOUSEHOLD_MEMBER, Page.EEC_HouseHoldMembers);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_LICENSE_STATUS_CAPACITY_ASSISTANT_INFO, Page.EEC_LicenseStatusCapacityInfo);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_EEC_INVOLVEMENT_EXPERIENCE_PROFE_EXP, Page.EEC_InvolvementExperience);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_BACKGROUND_INFO, Page.EEC_BackgroundInformation);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_TRAINING_INFO, Page.EEC_TrainingInformation);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_INDOR_OUTDOOR_SPACE_INFO, Page.EEC_IndoorSpacePage);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_DAILY_ROUTING_ACTIVITIES_TECH_ASSISTANCE, Page.EEC_TechnicalAssistance);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_ATTACHMENTS, Page.EEC_LicenseTransactionAttachments);
        lastStepMap.put(EEC_Constants.LT_LAST_REACHED_REVIEW_SUMMARY_AND_SUBMISSION, Page.EEC_ReviewSummarySubmission);
    }
    private void createSecureMemberMap() {
        this.getproviderslist();
        for (Account acc : providerslist) {
            secureIdMap.put(acc.Id, acc.Id);
        }
    }
    public void createSecureTransactionMap() {
        for (Licensing_Transaction__c lt : licenselist) {
            secureIdMap.put(lt.Id, lt.Id);
        }
    }
    public List<Account> getUmbrellaFCCSystem() {
        List<Account> assocProviders = [Select Id, Name,RecordType.DeveloperName, Provider_Number__c, Provider_city_text__c, License_Status__c, Provider_Status__c, Phone From Account Where FCC_System__c = :account.Id];
        return assocProviders;
    }
    public Boolean getFCCSystemExists() {
        Integer count = [Select Count() From Account Where FCC_System__c = :account.Id];
        return count > 0 ? true : false;
    }
    public Boolean getIsAssistant() {
        return(Account.RecordType.DeveloperName.contains('Assistant'));
    }
    public String getEncryptedAccountId() {
        return EncodingUtil.urlEncode(EEC_Util.encryptGetParam(account.Id), 'UTF-8');
    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption('Yes', 'Yes'));
        options.add(new SelectOption('No', 'No'));
        return options;
    }
}