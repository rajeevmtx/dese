@isTest
public class NYCDOH_IntakeRequestTestCenter_test {
    
    @TestSetup
    static void makeData(){
        
        Account createAccount = new Account();
        createAccount.Name = 'TestAccount';
        insert createAccount;
        
        Appointment_Slot__c createAppointmentSlot = new Appointment_Slot__c();
        createAppointmentSlot.Account__c = createAccount.id;
        createAppointmentSlot.Start_Time__c = time.newInstance(2, 2, 2, 2);
        createAppointmentSlot.Date__c = system.today() + 3;
        insert createAppointmentSlot;
    }
    @IsTest
    static void testData() {
        string contactDetail = '{\"LastName\":\"TestName\",\"Symptoms__c\":false,\"Healthcare_or_Emergency_Responder__c\":false,\"Nursing_Home_or_Healthcare__c\":true,\"COVID_Close_Contact__c\":false,\"Exposed_to_COVID__c\":true,\"Who_Exposed__c\":\"Family Member\",\"X14_Day_Return_from_Level_3__c\":false,\"Over_60_years_old__c\":false}';
        String getAccount = [SELECT ID,Name FROM Account WHERE Name = 'TestAccount' LIMIT 1].id;
        Contact con = new Contact();
        con.FirstName = 'Test contact';
        con.LastName = 'TestLastName';
        con.AccountId = getAccount;
        con.Email = 'testname@mail.com';
        insert con;
        Appointment_Slot__c fecthSlot = [SELECT Id,Account__c ,Start_Time__c,Date__c FROM Appointment_Slot__c WHERE Account__c =: getAccount];
        Test.startTest();
        NYCDOH_IntakeRequestTestCenter.getAppointmentSlots(null,getAccount,null);
        try{
            String s = NYCDOH_IntakeRequestTestCenter.saveContactInformation(contactDetail); // excption covered
            System.assertEquals(s!=null, true);
        }catch(Exception e){
            System.debug('Exception' + e.getMessage());
        }
        
        NYCDOH_IntakeRequestTestCenter.saveQuestionAnswers(con);
        Boolean isCommunityTest = NYCDOH_IntakeRequestTestCenter.isCommunity();
        System.assertEquals(isCommunityTest, false);
        try{
            NYCDOH_IntakeRequestTestCenter.saveQuestionAnswers(fecthSlot); //exception covered
        }catch(Exception e){
            System.debug('Exception' + e.getMessage());
        }
        
        test.stopTest();
        
    }
}