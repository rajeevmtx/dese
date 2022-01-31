@isTest
private class UpdateAppointmentControllerTest {

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
        insert appointment;
    }
   
   @isTest static void UpdateAppointmentControllerTest(){
   List<Appointment__c> apptList = [Select Id,Status__c FROM Appointment__c LIMIT 1];    
    UpdateAppointmentController.updateStatus(apptList[0].Id);
   List<Appointment__c> appt = [Select Id,Status__c FROM Appointment__c LIMIT 1];   
   System.assertEquals(appt[0].Status__c,'Closed');
   } 
}