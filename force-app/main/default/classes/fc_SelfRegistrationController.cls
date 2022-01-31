global without sharing class fc_SelfRegistrationController implements Auth.ConfigurableSelfRegHandler {
    
    private final Long CURRENT_TIME = Datetime.now().getTime();
    private final String[] UPPERCASE_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    private final String[] LOWERCASE_CHARS = 'abcdefghijklmnopqrstuvwxyz'.split('');
    private final String[] NUMBER_CHARS = '1234567890'.split('');
    private final String[] SPECIAL_CHARS = '!#$%-_=+<>'.split('');
    
    @AuraEnabled
    public static Map<String, String> createUserData(Map<String, String> userAttributes) {
        String password = '';
        Boolean hasAdditionalApplicant = false;
        Contact partnerContact = new Contact();
        Contact additionlApplicant = new Contact();
        Account partnerAccount = new Account();
        String lastName;

        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>();
        for(String str : userAttributes.keySet()) {
            if(str == 'FirstName') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
                partnerAccount.Name = userAttributes.get(str);
                partnerContact.FirstName = userAttributes.get(str);
            } else if(str == 'LastName') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
                lastName = userAttributes.get(str);
                partnerContact.LastName = userAttributes.get(str);
            } else if(str == 'Username') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
            } else if(str == 'Email') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
                partnerContact.Email = userAttributes.get(str);
            } else if(str == 'Phone') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
                partnerContact.Phone = userAttributes.get(str);
            } else if(str == 'ApplicantFirstName') {
                additionlApplicant.Firstname = userAttributes.get(str);
            } else if(str == 'ApplicantLastName') {
                additionlApplicant.Lastname = userAttributes.get(str);
            } else if(str == 'ApplicantEmail') {
                additionlApplicant.Email = userAttributes.get(str);
            } else if(str == 'Source') {
                partnerAccount.Learn_About_Agency__c = userAttributes.get(str);
            } else if(str == 'ApplicantType') {
                if(userAttributes.get(str) != 'Single Applicant') {
                    hasAdditionalApplicant = true;
                }
            } else if(str == 'Password') {
                password = userAttributes.get(str);
            }              
        }
        
        partnerAccount.Name = partnerAccount.Name + ' '+ lastName;
        partnerAccount.OwnerId = [SELECT Id FROM User WHERE UserRoleId != '' AND Profile.Name = 'System Administrator' LIMIT 1].Id;
        Database.insert(partnerAccount);
        
        partnerAccount.IsPartner = true;
        update partnerAccount; 
        
        if(hasAdditionalApplicant) {
            additionlApplicant.AccountId = partnerAccount.id;
            additionlApplicant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Foster Care Contact').getRecordTypeId();
            insert additionlApplicant;
        }
        
        partnerContact.AccountId = partnerAccount.id;
        partnerContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Foster Care Contact').getRecordTypeId();
        insert partnerContact;
        
        userAttributes.put('AccountId',partnerAccount.Id);
        //userAttributes.put('ContactId',partnerContact.Id);
        return userAttributes;
    }
    
    @AuraEnabled
    public static void createUserAction(Map<String, String> userAttributes) {
        String password = '';
        Id accountId;
        Id profileId = [SELECT Id,Name FROM Profile WHERE Name = 'Foster Care Community User' LIMIT 1].Id;       
        Map<SObjectField, String> registrationAttributes = new Map<SObjectField, String>();
        for(String str : userAttributes.keySet()) {
            if(str == 'FirstName') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
            } else if(str == 'LastName') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
            } else if(str == 'Username') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
            } else if(str == 'Email') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
            } else if(str == 'Phone') {
                registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
            } else if(str == 'ContactId') {
                //registrationAttributes.put(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get(str),userAttributes.get(str));
            }  else if(str == 'Password') {
                password = userAttributes.get(str);
            }  else if(str == 'AccountId') {
                accountId = userAttributes.get(str);
            }             
        }
        
        fc_SelfRegistrationController sf = new fc_SelfRegistrationController();
        sf.createUser(accountId, profileId, registrationAttributes, password);
    }
    
    global Id createUser(Id accountId, Id profileId, Map<SObjectField, String> registrationAttributes, String password) {
        UserRole portalRole = [Select Id From UserRole Where Name = 'Foster Child Partner Role' Limit 1];
        User u = new User();
        
        u.ProfileId = profileId;
       // u.UserRoleId = portalRole.id;
        for (SObjectField field : registrationAttributes.keySet()) {
            String value = registrationAttributes.get(field);
            u.put(field, value);
        }
        
        u = handleUnsetRequiredFields(u);
        generateContact(u, accountId);
        if (String.isBlank(password)) {
            password = generateRandomPassword();
        }
        Site.validatePassword(u, password, password);
        if (u.contactId == null) {
            return Site.createExternalUser(u, accountId, password);
        }
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = UserInfo.getTimezone().getID();
        insert u;
        System.setPassword(u.Id, password);
        return u.id;
    }
 
    private String generateRandomPassword() {
        String[] characters = new List<String>(UPPERCASE_CHARS);
        characters.addAll(LOWERCASE_CHARS);
        characters.addAll(NUMBER_CHARS);
        characters.addAll(SPECIAL_CHARS);
        String newPassword = '';
        Boolean needsUpper = true, needsLower = true, needsNumber = true, needsSpecial = true;
        while (newPassword.length() < 50) {
            Integer randomInt = generateRandomInt(characters.size());
            String c = characters[randomInt];
            if (needsUpper && c.isAllUpperCase()) {
                needsUpper = false;
            } else if (needsLower && c.isAllLowerCase()) {
                needsLower = false;
            } else if (needsNumber && c.isNumeric()) {
                needsNumber = false;
            } else if (needsSpecial && !c.isAlphanumeric()) {
                needsSpecial = false;
            }
            newPassword += c; 
        }
        newPassword = addMissingPasswordRequirements(newPassword, needsLower, needsUpper, needsNumber, needsSpecial);
        return newPassword;
    }
    
    private String addMissingPasswordRequirements(String password, Boolean addLowerCase, Boolean addUpperCase, Boolean addNumber, Boolean addSpecial) {
        if (addLowerCase) {
            password += LOWERCASE_CHARS[generateRandomInt(LOWERCASE_CHARS.size())];
        }
        if (addUpperCase) {
            password += UPPERCASE_CHARS[generateRandomInt(UPPERCASE_CHARS.size())];
        }
        if (addNumber) {
            password += NUMBER_CHARS[generateRandomInt(NUMBER_CHARS.size())];
        }
        if (addSpecial) {
            password += SPECIAL_CHARS[generateRandomInt(SPECIAL_CHARS.size())];
        }
        return password;
    }
 
    private Integer generateRandomInt(Integer max) {
        return Math.mod(Math.abs(Crypto.getRandomInteger()), max);
    }
 
    private User handleUnsetRequiredFields(User u) {
        if (String.isBlank(u.LastName)){
            u.LastName = generateLastName();
        }
        if (String.isBlank(u.Username)) {
            u.Username = generateUsername();
        }
        if (String.isBlank(u.Email)) {
            u.Email = generateEmail();
        }
        if (String.isBlank(u.Alias)) {
            u.Alias = generateAlias();
        }
        if (String.isBlank(u.CommunityNickname)) {
            u.CommunityNickname = generateCommunityNickname();
        }
        return u;
    }
 
    private void generateContact(User u, Id accountId) {
        // Add logic here if you want to build your own 
        // contact for the use.
    }
 
    private String generateAlias() {
        String timeString = String.valueOf(CURRENT_TIME);
        return timeString.substring(timeString.length() - 8);
    }
 
    private String generateLastName() {
        return 'ExternalUser' + CURRENT_TIME;
    }
 
    private String generateUsername() {
        return 'externaluser' + CURRENT_TIME + '@company.com';
    }
 
    private String generateEmail() {
        return 'externaluser' + CURRENT_TIME + '@company.com';
    }
 
    private String generateCommunityNickname() {
        return 'ExternalUser' + CURRENT_TIME;
    }
}