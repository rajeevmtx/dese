/*
*   Class Name: AppIntakeBase_Controller
*   Description: Base Page Controller for Application Intake.  All program App Intake Controller inherits from this.
*                Controls things that are common across all programs, such as navigation and submission.
*
*/

public abstract class AppIntakeBase_Controller extends Base_Page_Controller {
    public String projectId{get; set;}
    public Project__c project{get; set;}
    public String programId;
    private String migrationEncodeId;
    private String migrationId;
    public String currentPage{get; set;}
    public Boolean isEditable{get;set;}
    public Boolean isShowDiscardButton{get;set;}
    public Boolean isReadOnlyApplication {get; set;} // Application should be ReadOnly after Submission i.e. Should be editable in case of Unsubmitted status only // T-01393
    public Boolean isPortalReadOnlyApplication {get; set;}
    public Boolean isMigratedApplication {get; set;} // Will be TRUE for the Migrated Projects. Project must be created by Integration User and also have a Legacy Application #
    public User currentUserInfo{get{return Utility_User_Helper.currentLoggedInUser;}set;}
    public String accountId{get {return currentUserInfo.accountId;} set;}
    public String accountName{get {return currentUserInfo.account.Name;} set;}
    public String contactId{get {return currentUserInfo.contactId;} set;}
    public Boolean isInternalUser{get;set;}
    List<Project__c> lstProject;

    public AppIntakeBase_Controller() {
        projectId = Apexpages.currentPage().getParameters().get('ProjectId');
        migrationEncodeId = Apexpages.currentPage().getParameters().get('migId');
        if(String.IsNotBlank(migrationEncodeId))
            migrationId = EncodingUtil.urlEncode(migrationEncodeId,'UTF-8');
        accountName = '';
        isEditable = true;
        isShowDiscardButton = false;
        isReadOnlyApplication = false;
        isPortalReadOnlyApplication = false;
        isMigratedApplication = false;
        isInternalUser = currentUserInfo.ContactId ==null ? true : false;

        for(User tempUser : [SELECT ContactId, Contact.AccountId, Contact.Account.Name FROM User WHERE Id =: UserInfo.getUserId()]){
            accountId = (tempUser.ContactId != null && tempUser.Contact.AccountId != null) ? tempUser.Contact.AccountId : null;
            accountName = (tempUser.ContactId != null && tempUser.Contact.AccountId != null) ? tempUser.Contact.Account.Name : null;
        }
        // using list instead of directly querying in a Object
        lstProject = [SELECT  Status__c, program_version__r.program__c,
                              RecordTypeId, RecordType.developerName,
                              Program_Incentive_Block__c, CreatedBy.Name, Legacy_Application__c,
                              Project_Approval_Date__c//,Migration_ID__c
                      FROM    Project__c
                      WHERE   Id = :projectId ];
        if(!lstProject.isEmpty()) {
            isMigratedApplication = String.isNotBlank(lstProject[0].Legacy_Application__c);

            programId = lstProject[0].program_version__r.program__c;
            // hold the project status
            if(Project_Helper.PROJECT_STATUS_UNSUBMITTED.equalsIgnoreCase(lstProject[0].Status__c)) {
              isShowDiscardButton = true;
            }

            if(lstProject[0].RecordTypeId != null &&  NYSUN_Helper.RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME.equalsIgnoreCase(lstProject[0].RecordType.developerName)
                                                  || NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME.equalsIgnoreCase(lstProject[0].RecordType.developerName)) {

                isReadOnlyApplication = !(Project_Helper.PROJECT_STATUS_UNSUBMITTED.equalsIgnoreCase(lstProject[0].Status__c));
            }

            // Added by TK - For NYSun Program
            if(lstProject[0].RecordTypeId != null &&
                            (NYSUN_Helper.RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME.equalsIgnoreCase(lstProject[0].RecordType.developerName)
                                    || NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME.equalsIgnoreCase(lstProject[0].RecordType.developerName)
                            ) &&
                            contactId != null
                ) {
                isPortalReadOnlyApplication = !(Project_Helper.PROJECT_STATUS_UNSUBMITTED.equalsIgnoreCase(lstProject[0].Status__c));
            }

        }

        isReadOnlyApplication = (isMigratedApplication ? isMigratedApplication : isReadOnlyApplication); // Additional check. A Migrated Project is always ReadOnly
        isEditable = !isReadOnlyApplication;
    }

    /*
    * Method Name: next
    * Description: go to next page url.
    * @param:  Pagereference
    * @return: page
    */
    public virtual Pagereference next() {
        return PageNavigationUtility.getNextPageURL(projectId, currentPage, null);//migrationId
    }

    /*
    * Method Name: previous
    * Description: go to previous page url with projectId.
    * @param:  Pagereference
    * @return: page
    */
    public virtual Pagereference previous() {

        return PageNavigationUtility.getPreviousPageURL(projectId, currentPage, null);//migrationId
    }

    /*
    * Method Name: discardChanges
    * @param:  none
    * @return - Method return Pagereference
    */
    public PageReference discardChanges() {
        Savepoint sp = Database.setSavepoint();
        try{
            Boolean isDiscarded = NYSUN_APPINTAKE_Discard_Service.discardChanges(projectId);
            if(isDiscarded)
                return new pageReference ('/apex/Core_Programs_Page');
        }
        catch(Exception e){
            Database.rollback( sp );
        }
        return null;
    }


    /*
    * Method Name: discardChanges
    * Description: submit button
    * @param:  none
    * @return - Method return Pagereference
    */
    public virtual PageReference submit() {
      // ReadOnly
      if(isMigratedApplication || isReadOnlyApplication) {
        return null;
      }

        Savepoint sp = Database.setSavepoint();
        try{
            upsert new Project__c(Id = projectId, Status__c = 'Submitted');
            update new Account(Id=accountId, Is_Company_Information_Submitted__c = true);
            PageReference returnPage = ApexPages.currentPage();
            String pageUrl = returnPage.getUrl();
            pageUrl = pageUrl.left(pageUrl.indexOf('?'));
            returnPage = new PageReference(pageUrl + '?ProjectId=' + projectId + '&isSubmit=1');
            ReturnPage.setRedirect(true);
            PageNavigationUtility.getTargetPageName(projectId, currentPage, true, null);
            return returnPage;
        } catch(DmlException objEx) { Database.rollback( sp ); addError(objEx.getDmlMessage(0));
        } catch(Exception objEx) { Database.rollback( sp ); Apexpages.addMessages(objEx); }
        return null;
    }

    /*
    * Method Name: discardChanges
    * Description: display page error message
    * @param:  none
    * @return - Method does not return a value
    */
    public virtual void addError(String strMessage) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            strMessage));
    }
}