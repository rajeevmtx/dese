/*
*   Class Name: Utility_User_Helper
*   Description: Utility Class to get additional fields on the logged in User
*   Author/Date: 
*                        
*/
public without sharing class Utility_User_Helper
{
    public static final String NYSERDA_USERNAME_SUFFIX = '.nyserda';
    
    public static final String NYSERDA_NICKNAME_SUFFIX = 'NYSERDA';
    
    public static final String NYSERDA_USER_EMAIL_ENCODING_KEY = 'ISO-8859-1';
     
    public static User currentLoggedInUser
    {
        get
        {
            if (currentLoggedInUser == null)
                currentLoggedInUser = [SELECT AccountId, ContactId, Account.Name, 
                                              Name, Contact.Name, isPortalEnabled, 
                                                    Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                                                    FirstName, LastName, Email, UserName, CreatedDate, IsActive, Profile.Name,
                                                    Contact.AccountId
                                        FROM  User WHERE id = :UserInfo.getUserId()];
            return currentLoggedInUser;
        }
        set;
    }
}