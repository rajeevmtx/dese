/*
* Class Name: CORE_Solicitation_Login_Controller
* Description: Controller class of CORE_Solicitation_Login_Page  
* Author/Date: Harshit Jain   3/29/2017
* Date         New/Modified    Author          Description
* 5/4/2017     Modified        Harshit Jain   --------------
*                                                             
*/

public with sharing class CORE_Solicitation_Login_Controller {
    public String solicitationId {get;set;}
    public String username {get;set;}
    public String password {get;set;}
    public boolean isError{get;set;}
    public Boolean isNYGreen {get;set;}
    
    public CORE_Solicitation_Login_Controller() {
    	solicitationId = Apexpages.currentPage().getParameters().get('SolicitationId');
    	isError=false;
    	isNYGreen = false;
    	List<Program_Version__c> solicitationList = [SELECT Name, NY_Green_Bank_RFP__c FROM Program_Version__c WHERE Id =: solicitationId];
        if(solicitationList.size() > 0) {
            isNYGreen = solicitationList[0].NY_Green_Bank_RFP__c;
        }
    }
    /*
	* Method Name: doLogin
	* Description: Make a request to login onto site page
	* @param: none   
	* @return: pageReference                                                       
	*/
    public pageReference doLogin() {
    	PageReference pg;
    	try {  
    		pg = site.login(username, password, '/PROPOSAL_CORE_SelectProposal_Page?SolicitationId='+solicitationId);
     	} catch(Exception e) {
    		ApexPages.addMessages(e);
    		isError=true;
    	}
        system.debug('pd++++'+pg);
    	return pg;
    }
    
  /*
	* Method Name: checkUserType
	* Description: Check if user is partner or not
	* @param: none   
  * @return: pageReference                                                          
	*/
    public pageReference checkUserType() {
    	String portalURL;
    	portalURL =  Label.CORE_NYSERDA_Portal_URL;
    	if(String.isNotBlank(solicitationId) && userInfo.getUserType().containsIgnoreCase('partner')) {
            return new PageReference(portalURL+'proposal_core_selectproposal_page?SolicitationId='+solicitationId);
        }
        return null;
    }
}