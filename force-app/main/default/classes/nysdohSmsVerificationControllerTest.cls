@isTest
private class nysdohSmsVerificationControllerTest {
     @isTest static void testSmsmVerification() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new smsVerifcationMock());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        nysdohSmsVerificationController.processSms('8092755489','Test');
         Test.stopTest();
        
        
    }

    @isTest static void sendEmailTest(){
        Test.startTest();
        nysdohSmsVerificationController cntrl = new nysdohSmsVerificationController();
        cntrl.sendEmail('xyz@gmail.com','Test');
        Test.stopTest();
    }	
}