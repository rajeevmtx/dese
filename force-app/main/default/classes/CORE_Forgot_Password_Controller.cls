/*
* Class Name: CORE_Forgot_Password_Controller
* Description: Controller class of CORE_Forgot_Password_Page   
* Author/Date:  Ashish Sharma   4/16/2017
* Date         New/Modified      Author             Description
* 4/30/2017     Modified        Tarun Khandelwal   --------------
*                                                             
*/

public with sharing class CORE_Forgot_Password_Controller {
    public String username {get;set;}
    public boolean isSuccess{get;set;}
    public Boolean isNYGreen {get;set;}
    
    public CORE_Forgot_Password_Controller() {
        isSuccess = false;
        isNYGreen = false; 
        String solicitationId = ApexPages.currentPage().getParameters().get('SolicitationId');
        
        List<Program_Version__c> solicitationList = [SELECT Name, NY_Green_Bank_RFP__c FROM Program_Version__c WHERE Id =: solicitationId];
        if(solicitationList.size() > 0) {
            isNYGreen = solicitationList[0].NY_Green_Bank_RFP__c;
        }
    }
    
    /*
    * Method Name: forgotPassword
    * Description: To Reset the password
    * @param: none   
    * @return: void                                                            
    */
    
    public void forgotPassword() {
        try {  
            site.forgotPassword(username);
            isSuccess = true;
        } catch(Exception e) {
            ApexPages.addMessages(e);
            isSuccess = false;
        }
    }
}