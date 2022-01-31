/*
*   Class Name: Utility_Describe
*   Description: Utility class to enhance and optimize use of the Salesforce Describe object
*
*   Author/Date: 
*                        
*/
public without sharing class Utility_Describe
{
    // property to get globalDescribe once and persist
    public static Map<String,Schema.SObjectType> globalDescribe
    {
        get
        { 
            if (globalDescribe == null)
            {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        set;
    }
    
    /* 
  * Method Name: getSharingObjectName
  * Description: method that takes an sObject API name and returns the corresponding share sObject API name
  * @param: String sObjectType
  * @return: String                                                       
  */
    public static String getSharingObjectName(String sObjectType)
    {
        if (sObjectType.endsWith('__c'))
            return sObjectType.replace('__c','__share');
        else
            return sObjectType + 'Share';
    }
}