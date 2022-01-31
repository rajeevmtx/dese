@isTest
public class NHDOH_QRScanController_Test {
    @testSetup
    static void makedata(){
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);
        
        Appointment_Slot__c createAppointmentSlot = new Appointment_Slot__c();
        //createAppointmentSlot.Account__c = accountList[0].id;
        //createAppointmentSlot.Name = 'test Appointment';
        insert createAppointmentSlot;
        
        Appointment__c createAppointment = new Appointment__c();
        //createAppointment.Name = 'Test appointment';
        //createAppointment.Account__c = accountList[0].id;
        createAppointment.Status__c = 'Closed';
        createAppointment.Appointment_Slot__c = createAppointmentSlot.Id;
        insert createAppointment;
    }
    @istest
    static void updateAppointmentTest(){
        String accName = [SELECT Id FROM account LIMIT 1].id;
        String appointmentId = [SELECT ID FROM Appointment__c LIMIT 1].id;
        NHDOH_QRScanController.updateAppointment(appointmentId);
    }

}