@isTest
public class NYSDOH_RegistrationController_Test {
	@isTest
    static void getPicklistValues() {
        
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);               
		NYSDOH_RegistrationController.fetchPicklist('Account','Type');	
        
        List<Account> forAssertion = [SELECT Name, Type FROM Account WHERE Id =: accountList[0].Id];
        System.assertEquals('Analyst', forAssertion[0].Type, 'Expected Analyst as Type');
    }
}