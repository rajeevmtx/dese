/*
* Class Name: Core_Registration_Controller
* Description: Controller class of Core_Registration_Page
* Author/Date:   Ashish Sharma   11/26/2016

* Date         New/Modified      Author             Description
* 4/30/2017     Modified        Tarun Khandelwal   --------------
* 05/25/2017    Modified        Ajay Gautam        NY Green Bank specific fix S-00781
*
*/

public without sharing class Core_Registration_Controller {

    private static final String PEC_ROLE = 'Primary Energy Consultant';
  
   public static final String PROFILE_PORTAL_USER_BY_LOGIN = 'Portal User by Login';
   
    public static String COST_EMAIL_TEMPLATE_API_NAME_EXISTING_USER_NYSERDA = 'Core_Existing_User_Login_Notification';
    public static String COST_EMAIL_TEMPLATE_API_NAME_EXISTING_USER_NY_GREEN_BANK = 'NY_Green_Bank_Existing_User_Login_Notification';    // S-00781

    public Project_Role__c projectRole{get; set;}
    public String companyName{get; set;}
    public Program__c program{get; set;}
    public boolean sendVarification{get; set;}
    public boolean isProcessSuccessful{get; set;}
    public boolean isPortalUserExist{get; set;}
    public String solicitationId{get; set;}
    public String reviewTeamId{get; set;}
    public  transient List<Messaging.SingleEmailMessage> existingUserMails;
    public User existingPortalUser;
    public String projectRoleId;
    public String password{get; set;}
    public Boolean isNYGreen {get;set;}

    Id accountId;
    Id contactId;

    public Core_Registration_Controller(){
        projectRole = new Project_Role__c();
        companyName = '';
        sendVarification = false;
        isProcessSuccessful = false;
        isPortalUserExist = false;
        isNYGreen = false;

        String programName = ApexPages.currentPage().getParameters().get('programName');
        projectRoleId = ApexPages.currentPage().getParameters().get('roleId');
        solicitationId = ApexPages.currentPage().getParameters().get('SolicitationId');
        reviewTeamId = ApexPages.currentPage().getParameters().get('reviewteammemberid');

        program = new Program__c();

        List<Program_Version__c> solicitationList = [SELECT Name, NY_Green_Bank_RFP__c FROM Program_Version__c WHERE Id =: solicitationId];
        if(solicitationList.size() > 0) {
            isNYGreen = solicitationList[0].NY_Green_Bank_RFP__c;
        }

        if(programName != null && programName != ''){
            for(Program__c temp : [SELECT Id, Name FROM Program__c
                                   WHERE Application_Type__c =: programName
                                   AND Status__c = 'Active'
                                   ORDER BY CreatedDate DESC LIMIT 1]){
                                       program = temp;
                                   }
        }

        if(projectRoleId != null && projectRoleId != ''){
            for(Project_Role__c temp : [SELECT Id, Name, FirstName__c, LastName__c, Title__c,
                                        Email__c, Phone__c, Company_Name__c, Account__c, Contact__c,
                                        Contact__r.FirstName, Contact__r.LastName, Contact__r.Title,
                                        Contact__r.Email, Contact__r.Phone,
                                        Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
                                        Account__r.BillingPostalCode, Address_2__c, Address_1__c, City__c, State__c,
                                        Zip__c FROM Project_Role__c
                                        WHERE Id =: projectRoleId LIMIT 1]){
                                            projectRole = temp;
                                            companyName = temp.Company_Name__c;

                                            projectRole.Address_1__c = temp.Address_1__c;
                                            projectRole.Address_2__c = temp.Address_2__c;
                                            projectRole.City__c = temp.City__c;
                                            projectRole.State__c = temp.State__c;
                                            projectRole.Zip__c = temp.Zip__c;

                                            projectRole.FirstName__c = temp.FirstName__c;
                                            projectRole.LastName__c = temp.LastName__c;
                                            projectRole.Title__c = temp.Title__c;
                                            projectRole.Email__c = temp.Email__c;
                                            projectRole.Phone__c = temp.Phone__c;
                                        }
        }
    }

    /*
  * Method Name: save
  * Description: To save all details of Core_Registration_Page
  * @param: Pagereference
  */

    public Pagereference save(){
        companyName = companyName != null ? companyName.trim() : companyName;
        projectRole.Address_1__c = projectRole.Address_1__c != null ? projectRole.Address_1__c.trim() : projectRole.Address_1__c;
        projectRole.Address_2__c = projectRole.Address_2__c != null ? projectRole.Address_2__c.trim() : projectRole.Address_2__c;
        projectRole.City__c = projectRole.City__c != null ? projectRole.City__c.trim() : projectRole.City__c;
        projectRole.FirstName__c = projectRole.FirstName__c != null ? projectRole.FirstName__c.trim() : projectRole.FirstName__c;
        projectRole.LastName__c = projectRole.LastName__c != null ? projectRole.LastName__c.trim() : projectRole.LastName__c;
        projectRole.Title__c = projectRole.Title__c != null ? projectRole.Title__c.trim() : projectRole.Title__c;

        Savepoint sp = Database.setSavepoint();
        
        existingUserMails = new List<Messaging.SingleEmailMessage>();
        if(projectRoleId == null || projectRoleId == '')
            projectRole.Company_Name__c = companyName;

        try{
            sendVarification = false;
            isProcessSuccessful = false;
            isPortalUserExist = false;

            if(program.Id != null){

                if(projectRole.Id <> null && projectRole.Account__c <> null
                   && projectRole.Contact__c <> null){
                       accountId = projectRole.Account__c;
                       contactId = projectRole.Contact__c;

                       update projectRole;

                       for(User usr : [SELECT Id, Email, AccountId, ContactId, Profile.Name, UserName, FirstName
                                       FROM User
                                       WHERE Email =: projectRole.Email__c]){

                                           if(usr.ContactId != null && usr.Profile.Name == PROFILE_PORTAL_USER_BY_LOGIN){
                                               isPortalUserExist = true;
                                               existingPortalUser = usr;
                                           }
                                       }

                   }else{
                       createContactAndAccount();
                   }

                if(isPortalUserExist){
                    if(existingUserMails.size() > 0){
                        existingUserMails = CORE_Helper.setOrgWideEmailAddress_CORE(existingUserMails);
                        Messaging.sendEmail(existingUserMails);
                    }

                }else if(!sendVarification){
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.AllowSave = true;

                    Database.update(new Account(Id = accountId,
                                                Name = companyName,
                                                BillingStreet = projectRole.Address_1__c + (projectRole.Address_2__c != null ? ' ' + projectRole.Address_2__c : ''),
                                                BillingCity = projectRole.City__c,
                                                BillingState = projectRole.State__c,
                                                BillingPostalCode = projectRole.Zip__c,
                                                OwnerId = CORE_Constants_Setting__c.getOrgDefaults().Portal_User_Registration_Owner_Id__c),
                                    dml);

                    Database.update(new Contact(Id = contactId,
                                                Company__c = companyName,
                                                FirstName = projectRole.FirstName__c,
                                                LastName = projectRole.LastName__c,
                                                Title = projectRole.Title__c,
                                                Email = projectRole.Email__c,
                                                Phone = projectRole.Phone__c,
                                                OwnerId = CORE_Constants_Setting__c.getOrgDefaults().Portal_User_Registration_Owner_Id__c),
                                    dml);

                    if(projectRole.Id <> null){
                        Database.update(new Project_Role__c(Id=projectRole.Id, Contact__c=contactId, Account__c=accountId));
                    }
 
                    Id programPartnershipId;
 
                    for(Program_Partnership__c programPartner : [SELECT Id FROM Program_Partnership__c
                                                                 WHERE Account__c =: accountId
                                                                 AND Program__c =: program.Id]){
                                                                     programPartnershipId = programPartner.Id;
                                                                 }

                    if(programPartnershipId == null){
                        Program_Partnership__c newProgramPartnership = new Program_Partnership__c(Status__c = 'Provisional',
                                                                                                  Contractor__c = false,
                                                                                                  Account__c = accountId,
                                                                                                  Program__c = program.Id,
                                                                                                  Default_Primary_Contact__c = contactId);
                        if(projectRole.Id <> null && projectRole.Role__c == PEC_ROLE){
                            newProgramPartnership.Contractor__c = true;
                        }
                        insert newProgramPartnership;

                        programPartnershipId = newProgramPartnership.Id;
                    }

                    ID profileId;

                    for(Profile profile : [SELECT Id FROM Profile
                                           WHERE Name = :PROFILE_PORTAL_USER_BY_LOGIN]){

                                               profileId = profile.Id;
                                           }

                    if(profileId != null){
                        Integer randomInt = Integer.valueOf(math.rint(math.random()*10));
                        String uniqueName = (projectRole.FirstName__c.length() > 2 ? projectRole.FirstName__c.substring(0, 2) : projectRole.FirstName__c.substring(0, projectRole.FirstName__c.length() -1)) +
                            (projectRole.LastName__c.length() > 2 ? projectRole.LastName__c.substring(0, 2) : projectRole.LastName__c.substring(0, projectRole.LastName__c.length() -1)) +  +
                            randomInt;

                        if(uniqueName.length() > 8){
                            uniqueName = uniqueName.subString(0, 8);
                        }

                        Integer userCount = 0;
                        Integer nickNameCount = 0;
                        Integer aliasCount = 0;

                        for(User usr : [SELECT Id, Email, UserName, CommunityNickName, alias
                                        FROM User WHERE CommunityNickName =: uniqueName
                                        OR alias =: uniqueName
                                        OR Email =: projectRole.Email__c]){

                                            if(usr.CommunityNickName == uniqueName){
                                                nickNameCount += 1;
                                            }

                                            if(usr.alias == uniqueName){
                                                aliasCount += 1;
                                            }

                                            if(usr.Email == projectRole.Email__c){
                                                userCount += 1;
                                            }else if(usr.UserName == (projectRole.Email__c + '.egrants') || usr.UserName == (projectRole.Email__c + '.egrants' + userCount)){
                                                userCount += 1;
                                            }
                                        }

                        userCount += 1;

                        String nickName = uniqueName;

                        if(nickNameCount > 0){
                            nickNameCount += 1;
                            nickName = nickName.subString(0, nickName.length()-1) + nickNameCount;

                            if(nickName.length() > 8){
                                nickName = nickName.subString(0, 6) + nickNameCount;
                            }
                        }

                        String aliasName = uniqueName;

                        if(aliasCount > 0){
                            aliasCount += 1;
                            aliasName = aliasName.subString(0, aliasName.length()-2) + aliasCount;

                            if(aliasName.length() > 8){
                                aliasName = aliasName.subString(0, 6) + aliasCount;
                            }
                        }

                        String temp = String.valueOf(randomInt);
                        temp = temp.subString(0, temp.length()-1);

                        User newUser = new User(FirstName = projectRole.FirstName__c,
                                                LastName = projectRole.LastName__c,
                                                Title = projectRole.Title__c,
                                                Email = projectRole.Email__c,
                                                Phone = projectRole.Phone__c,
                                                ContactId = contactId,
                                                UserName = (userCount > 1) ? (projectRole.Email__c + '.egrants' + userCount) : (projectRole.Email__c + '.egrants'),
                                                ProfileId = profileId,
                                                TimeZoneSidKey = 'America/New_York',
                                                LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
                                                LanguageLocaleKey = 'en_US',
                                                alias = aliasName, CommunityNickName = nickName + temp,
                                                IsActive = true);

                        insert newUser;

                        isProcessSuccessful = true;
                    }
                }else{
                    String verficationCode = String.valueOf(math.random());

                    if(verficationCode.length() > 40){
                        verficationCode = verficationCode.subString(0, 39);
                    }

                    Program_Partnership_Request__c programPartnershipRequest =
                        new Program_Partnership_Request__c(Program__c = program.Id,
                                                           Status__c = 'Open',
                                                           Email_Verification_Code__c = verficationCode,
                                                           Email_Address_Verified__c = 'Request Sent',
                                                           Company_Name__c = companyName,
                                                           Street_Address__c = projectRole.Address_1__c + (projectRole.Address_2__c != null ? ' ' + projectRole.Address_2__c : ''),
                                                           State__c = projectRole.State__c,
                                                           City__c = projectRole.City__c,
                                                           Zip_Code__c = projectRole.Zip__c,
                                                           First_Name__c = projectRole.FirstName__c,
                                                           Last_Name__c = projectRole.LastName__c,
                                                           Title__c = projectRole.Title__c,
                                                           Email__c = projectRole.Email__c,
                                                           Phone__c = projectRole.Phone__c);
                    if(projectRole.Id <> null){
                        programPartnershipRequest.Project_Role__c = projectRole.Id;
                    }

                    insert programPartnershipRequest;

                    List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();
                    EmailTemplate mailTemplate;

                    for(EmailTemplate template : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE
                                                  DeveloperName = 'CORE_Email_Verification_Template']){

                                                      mailTemplate = template;
                                                  }

                    if(mailTemplate != null){
                        Messaging.SingleEmailMessage newEmail = Messaging.renderStoredEmailTemplate(mailTemplate.Id, null, programPartnershipRequest.Id);
                        Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();
                        mailToBeSent.setSubject(newEmail.subject);
                        mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                        mailToBeSent.setPlainTextBody(newEmail.PlainTextBody);
                        mailToBeSent.saveAsActivity = false;
                        mailToBeSent.setToAddresses(new List<String>{projectRole.Email__c});
                        notifications.add(mailToBeSent);
                    }

                    if(notifications.size() > 0){
                        notifications = CORE_Helper.setOrgWideEmailAddress_CORE(notifications);
                        Messaging.sendEmail(notifications);
                    }
                }
            }else if(!String.isBlank(solicitationId)){
              createContactAndAccount();

              if(isPortalUserExist){
                    if(existingUserMails.size() > 0){
                        existingUserMails = CORE_Helper.setOrgWideEmailAddress_CORE(existingUserMails);
                        Messaging.sendEmail(existingUserMails);
                    }

                }else if(!sendVarification){
                  //Savepoint sp = Database.setSavepoint();

                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.AllowSave = true;

                    Database.update(new Account(Id = accountId,
                                                Name = companyName,
                                                BillingStreet = projectRole.Address_1__c + (projectRole.Address_2__c != null ? ' ' + projectRole.Address_2__c : ''),
                                                BillingCity = projectRole.City__c,
                                                BillingState = projectRole.State__c,
                                                BillingPostalCode = projectRole.Zip__c,
                                                OwnerId = CORE_Constants_Setting__c.getOrgDefaults().Portal_User_Registration_Owner_Id__c),
                                    dml);

                    Database.update(new Contact(Id = contactId,
                                                Company__c = companyName,
                                                FirstName = projectRole.FirstName__c,
                                                LastName = projectRole.LastName__c,
                                                Title = projectRole.Title__c,
                                                Email = projectRole.Email__c,
                                                Phone = projectRole.Phone__c,
                                                OwnerId = CORE_Constants_Setting__c.getOrgDefaults().Portal_User_Registration_Owner_Id__c),
                                    dml);

                    ID profileId;

                    for(Profile profile : [SELECT Id FROM Profile
                                           WHERE Name = :PROFILE_PORTAL_USER_BY_LOGIN]){
                       profileId = profile.Id;
                    }

                    if(profileId != null){
                        Integer randomInt = Integer.valueOf(math.rint(math.random()*10));
                        String uniqueName = (projectRole.FirstName__c.length() > 2 ? projectRole.FirstName__c.substring(0, 2) : projectRole.FirstName__c.substring(0, projectRole.FirstName__c.length() -1)) +
                            (projectRole.LastName__c.length() > 2 ? projectRole.LastName__c.substring(0, 2) : projectRole.LastName__c.substring(0, projectRole.LastName__c.length() -1)) +  +
                            randomInt;

                        if(uniqueName.length() > 8){
                            uniqueName = uniqueName.subString(0, 8);
                        }

                        Integer userCount = 0;
                        Integer nickNameCount = 0;
                        Integer aliasCount = 0;

                        for(User usr : [SELECT Id, Email, UserName, CommunityNickName, alias
                                        FROM User WHERE CommunityNickName =: uniqueName
                                        OR alias =: uniqueName
                                        OR Email =: projectRole.Email__c]){

                            if(usr.CommunityNickName == uniqueName){
                                nickNameCount += 1;
                            }

                            if(usr.alias == uniqueName){
                                aliasCount += 1;
                            }

                            if(usr.Email == projectRole.Email__c){
                                userCount += 1;
                            }else if(usr.UserName == (projectRole.Email__c + '.egrants') || usr.UserName == (projectRole.Email__c + '.egrants' + userCount)){
                                userCount += 1;
                            }
                        }

                        userCount += 1;

                        String nickName = uniqueName;

                        if(nickNameCount > 0){
                            nickNameCount += 1;
                            nickName = nickName.subString(0, nickName.length()-1) + nickNameCount;

                            if(nickName.length() > 8){
                                nickName = nickName.subString(0, 6) + nickNameCount;
                            }
                        }

                        String aliasName = uniqueName;

                        if(aliasCount > 0){
                            aliasCount += 1;
                            aliasName = aliasName.subString(0, aliasName.length()-2) + aliasCount;

                            if(aliasName.length() > 8){
                                aliasName = aliasName.subString(0, 6) + aliasCount;
                            }
                        }

                        String temp = String.valueOf(randomInt);
                        temp = temp.subString(0, temp.length()-1);

                        User newUser = new User(FirstName = projectRole.FirstName__c,
                                                LastName = projectRole.LastName__c,
                                                Title = projectRole.Title__c,
                                                Email = projectRole.Email__c,
                                                Phone = projectRole.Phone__c,
                                                ContactId = contactId,
                                                UserName = (userCount > 1) ? (projectRole.Email__c + '.egrants' + userCount) : (projectRole.Email__c + '.egrants'),
                                                ProfileId = profileId,
                                                TimeZoneSidKey = 'America/New_York',
                                                LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
                                                LanguageLocaleKey = 'en_US',
                                                alias = aliasName, CommunityNickName = nickName + temp,
                                                IsActive = true);

                        try{
                          String userId = Site.createPortalUser(newUser, accountId, password);

                          if(userId != null){
                            isProcessSuccessful = true;

                            if (password != null && password.length() > 1) {
                                if(String.isNotBlank(reviewTeamId)) {
                                  //return Site.login(newUser.UserName, password,  '/Core_NYSERDA_NDA_Page?solicitationId=' + solicitationId + '&reviewteammemberid=' + reviewTeamId);
                                  return Site.login(newUser.UserName, password,  '/PROPOSAL_CORE_SelectProposal_Page?SolicitationId=' + solicitationId);                                
                                } else {
                                  return Site.login(newUser.UserName, password,  '/PROPOSAL_CORE_SelectProposal_Page?SolicitationId=' + solicitationId);
                                }

                    }
                          }
                        }catch(DMLException e){
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, e.getMessage()));
                    isProcessSuccessful = false;
                    Database.rollback(sp);
                        }catch(Exception e){
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, e.getMessage()));
                    isProcessSuccessful = false;
                    Database.rollback(sp);
                        }
                    }
                }
            }
        }catch(DMLException e){
            String ErrMsg = e.getMessage();
            if(e.getMessage().contains('DUPLICATE_USERNAME'))
                ErrMsg = 'Duplicate username found.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ErrMsg));
            isProcessSuccessful = false;
            Database.rollback(sp);
        }catch(Exception e){
            String ErrMsg = e.getMessage();
            if(e.getMessage().contains('DUPLICATE_USERNAME'))
                ErrMsg = 'Duplicate username found.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, ErrMsg));
            isProcessSuccessful = false;
            Database.rollback(sp);
        }

        return null;
    }

    /*
  * Method Name: createContactAndAccount
  * Description: To Create new contact and accounts if Contact/Account does not already exists
  * @param: void
  */

    public void createContactAndAccount() {
        sendVarification = false;
        boolean isAccountExist = false;

        for(Account acc : [SELECT Id FROM Account
                           WHERE Name =: projectRole.Company_Name__c]){

                               isAccountExist = true;
                           }

        boolean isContactExist = false;

        for(Contact con : [SELECT Id FROM Contact WHERE
                           FirstName =: projectRole.FirstName__c AND
                           LastName =: projectRole.LastName__c AND
                           Email =: projectRole.Email__c]){

                               isContactExist = true;
                           }

        boolean isUserExist = false;

        for(User usr : [SELECT Id, Email, AccountId, ContactId, Profile.Name, UserName, FirstName, LastName
                        FROM User
                        WHERE Email =: projectRole.Email__c]){

                            if(usr.ContactId != null && usr.Profile.Name == PROFILE_PORTAL_USER_BY_LOGIN){
                                isPortalUserExist = true;
                                existingPortalUser = usr;
                            }
                            isUserExist = true;
                        }

        if(isPortalUserExist){
            prepareExistingUserEmail();

        }else if(((!isAccountExist) && (!isContactExist) && (!isUserExist)) || (!String.isBlank(solicitationId))){
            Account accountToInsert = new Account(Name = companyName,
                                                  BillingStreet = projectRole.Address_1__c + (projectRole.Address_2__c != null ? ' ' + projectRole.Address_2__c : ''),
                                                  BillingCity = projectRole.City__c,
                                                  BillingState = projectRole.State__c,
                                                  BillingPostalCode = projectRole.Zip__c,
                                                  OwnerId = CORE_Constants_Setting__c.getOrgDefaults().Portal_User_Registration_Owner_Id__c);

            String mailingStreet = ((projectRole.Address_1__c != null) ? projectRole.Address_1__c : '');
            mailingStreet += ((projectRole.Address_2__c != null) ? ', ' + projectRole.Address_2__c : '');

            Contact contactToInsert = new Contact(FirstName = projectRole.FirstName__c,
                                                  LastName = projectRole.LastName__c,
                                                  Email = projectRole.Email__c,
                                                  Phone = projectRole.Phone__c,
                                                  MailingStreet = mailingStreet,
                                                  MailingCity = projectRole.City__c,
                                                  MailingState = projectRole.State__c,
                                                  MailingPostalCode = projectRole.Zip__c);

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(accountToInsert, dml);
            accountId = accountToInsert.Id;

            contactToInsert.AccountId = accountId;

            Database.insert(contactToInsert, dml);
            contactId = contactToInsert.Id;
        }else{
          sendVarification = true;
        }
    }

    /*
  * Method Name: prepareExistingUserEmail
  * Description: prepare the user email to send email to user
  * @param: void
  */

    public void prepareExistingUserEmail(){

        if(isPortalUserExist && existingPortalUser != null) {

            // NY Green Bank specific fix: Ajay Gautam 05/25/2017 - S-00781
            String emailTemplateDevName = COST_EMAIL_TEMPLATE_API_NAME_EXISTING_USER_NYSERDA;
                                          
            // NY Green Bank specific fix: Ajay Gautam 05/25/2017 - S-00781

            EmailTemplate templateEmailToExistingUser = [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE
                                                         DeveloperName = :emailTemplateDevName];

            Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage();

            String subject = templateEmailToExistingUser.Subject;
            String plainBody = templateEmailToExistingUser.Body;
            plainBody = plainBody.replace('{!User.FirstName}', existingPortalUser.FirstName);
            plainBody = plainBody.replace('{!User.LastName}', existingPortalUser.LastName);
            plainBody = plainBody.replace('{!User.Username}', existingPortalUser.Username);

            plainBody = plainBody.replace('{!$Label.CORE_NYSERDA_Portal_URL}', System.Label.CORE_NYSERDA_Portal_URL);

            mailToBeSent.setSubject(subject);
            mailToBeSent.plainTextBody = plainBody;
            mailToBeSent.saveAsActivity = false;
            mailToBeSent.setToAddresses(new List<String>{existingPortalUser.Email});
            existingUserMails.add(mailToBeSent);
        }
    }
}