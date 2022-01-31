@isTest
private class NysdohTechnicalHelpdeskControllerTest {
    
    @TestSetup
    static void setup(){
        
        User testUser = NYSDOH_TestFactory.createUser('TestUSe333333123@gmail.com','testUser@gmail.com',true);
    }
    @isTest
    private static void createCaseTest(){
        User u = [Select Id,Email,firstName,LastName FROM User LIMIT 1];
        String res;
        Test.StartTest();
        System.runAs(u){
            res = NysdohTechnicalHelpdeskController.createCase('Test Case','Medium','Test Case Obj');
        }
           Test.StopTest();
        System.assertEquals(res,'Success');
    }
}