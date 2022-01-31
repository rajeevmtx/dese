global without sharing class psrRegisterController {

    public psrRegisterController() {

    }

    @TestVisible
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }

    @TestVisible
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl, '');
        return authConfig.isCommunityUsingSiteAsContainer();
    }

    @TestVisible
    private static void validatePassword(User u, String password, String confirmPassword) {
        if (!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }

    @AuraEnabled
    public static Account getAccountId(String accountName) {
        List<Account> accountList = [SELECT Id FROM Account WHERE Name =: accountName];
        if (accountList.size() > 0) {
            return accountList[0];
        }
        return null;
    } 

    @AuraEnabled
    public static Id getContactId(String userId) {
        List<User> userList = [SELECT Id, ContactId FROM User WHERE Id =: userId];
        if (userList.size() > 0 ) {
            return userList[0].ContactId;
        }
        return null;
    } 

    @AuraEnabled
    public static String selfRegister(String firstname, String lastname, String email, String password, String confirmPassword, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        //I-16166 cleared by:Srikanth Banda
        //I-16166 started
        //account was not inserted earlier
        User u = [SELECT Id FROM User WHERE Name = 'Harshit Jain'];
        Account account = new Account(Name = 'Dummy Account',OwnerId = u.Id);
        insert account;
        //I-16166 ended
        System.debug('inserted account:: '+account);
        for(Account selectedAccount : [SELECT Id,Name FROM Account WHERE Name = 'Dummy Account']) {
            account = selectedAccount;
        }
        
        return (selfRegisterWithDummyAccount(firstname, lastname, email, password, confirmPassword, account.Id, regConfirmUrl, extraFields, startUrl, includePassword));
    }

    @AuraEnabled
    public static String selfRegisterWithDummyAccount(String firstname, String lastname, String email, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        Savepoint sp = null;

        //check if user with same email exists already
        List < Contact > listOfExistingContact = [select id from contact where Email =: email];
        if (listOfExistingContact != null && listOfExistingContact.size() > 0) {
            throw new AuraHandledException('User already exist. Please try with different email');
        }
        if(!isValidPassword(password,confirmPassword)){
            throw new AuraHandledException('Password doesnt match');
        }
        try {

            sp = Database.setSavepoint();
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }

            //create new contact first
            Contact newContact = new Contact(firstName = firstName, lastName = lastName, email = email, accountId = accountId);
            insert newContact;

            //create AccountContact Relation
            //AccountContactRelation relation = new AccountContactRelation(accountId = accountId, contactId = newContact.Id);
            //insert relation;

            //create new user
            User u = new User();
            u.Username = email + '.KY';
            u.put('Email', email);
            u.FirstName = firstname;
            u.LastName = lastname;
            u.contactId = newContact.Id;

            String networkId = Network.getNetworkId();

            if (networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI', true);
            }

            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0, 1) : '') + lastname.substring(0, 1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
            u.put('CommunityNickname', nickname);

            if (includePassword) {
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
                validatePassword(u, password, confirmPassword);
            } else {
                password = null;
            }

            String userId = Site.createExternalUser(u, accountId, password);

            if (Test.isRunningTest()) {
                userId = 'fakeUserId';
            }

            if (userId != null) {
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(u.Username, password, startUrl + '&contactId=' + newContact.Id);
                    if (!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                } else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(confirmRef);
                    }

                }
            }

            return null;

        }
        Catch(Exception e) {
            //Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List < Map < String, Object >> getExtraFields(String extraFieldsFieldSet) {
        List < Map < String, Object >> extraFields = new List < Map < String, Object >> ();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if (!Test.isRunningTest()) {
            if (fieldSet != null) {
                for (Schema.FieldSetMember f: fieldSet.getFields()) {
                    Map < String, Object > fieldDetail = new Map < String, Object > ();
                    fieldDetail.put('dbRequired', f.getDBRequired());
                    fieldDetail.put('fieldPath', f.getFieldPath());
                    fieldDetail.put('label', f.getLabel());
                    fieldDetail.put('required', f.getRequired());
                    fieldDetail.put('type', f.getType());
                    fieldDetail.put('value', ''); // client will populate
                    extraFields.add(fieldDetail);
                }
            }
        }
        return extraFields;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static String getLoginUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getStartUrl(); 
        }
        return null;
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }
}