@isTest
private class GenerateAppointmentControllerrTest {

     @TestSetup
    static void setup(){
        Account acc =  new Account(
        Name = 'Test Account',
        Type = 'Testing Site'
       );
       insert acc;
     List<Appointment_Slot__c> slotList = NYSDOH_TestFactory.createAppointmentSlot(acc.Id,True);
      List<Appointment__c> appointment = NYSDOH_TestFactory.createAppointment(slotList[0].Id, false);
        appointment[0].status__c = 'Scheduled';
        appointment[0].Testing_Site__c = acc.Id;
        insert appointment;
    }
   
   @isTest static void GenerateAppointmentControllerrTest(){
   List<Appointment__c> apptList = [Select Id,Status__c FROM Appointment__c LIMIT 1];
     List<Account> acctList = [Select Id FROM Account LIMIT 1];  
        ApexPages.StandardController sc = new ApexPages.StandardController(acctList[0]);
       GenerateAppointmentControllerr ctrl = new GenerateAppointmentControllerr(sc);
       System.assertNotEquals(ctrl.appRec,null);
   }
    @isTest static void savePDFTest(){
         List<Account> acctList = [Select Id FROM Account LIMIT 1];  
        ApexPages.StandardController sc = new ApexPages.StandardController(acctList[0]);
		GenerateAppointmentControllerr ctrl = new GenerateAppointmentControllerr(sc);  
        ctrl.savePDF();
    }
}