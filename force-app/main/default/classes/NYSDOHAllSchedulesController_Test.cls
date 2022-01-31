@isTest
public class NYSDOHAllSchedulesController_Test {
    
    @testSetup
    static void makeData(){
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);
        List<Contact> contactList = NYSDOH_TestFactory.createContact(accountList[0].id,true);
        List<Appointment_Slot__c> appointmentSlotList = NYSDOH_TestFactory.createAppointmentSlot(accountList[0].id,true);
        List<Appointment__c> appointment = NYSDOH_TestFactory.createAppointment(appointmentSlotList[0].id,true);
    }
    @isTest
    static void fetchAllSlotsTest(){
        String accId = [SELECT id FROM Account LIMIT 1].id;
        String startdate = String.valueOf(date.today());
        String endDate = String.valueOf(date.today()+3);
        NYSDOHAllSchedulesController.SlotWrapper wrap = new NYSDOHAllSchedulesController.SlotWrapper();
        wrap = NYSDOHAllSchedulesController.fetchAllSlots(accId,startdate,endDate);
        System.assertEquals(wrap!=null, true);
    }
    @istest
    static void createAppoitmentTest(){
        Appointment_Slot__c appointmentSlot = [SELECT ID,Account__c,Date__c,End_Time__c,Start_Time__c,Remaining_Capacity__c
                                               FROM Appointment_Slot__c LIMIT 1];
        appointmentSlot.Date__c = date.today();
        appointmentSlot.End_Time__c = time.newInstance(1, 0, 0, 0);
        appointmentSlot.Start_Time__c = time.newInstance(2, 0, 0, 0);
        //appointmentSlot.Remaining_Capacity__c = 1.0;
        update appointmentSlot;
        
        String slotId = [SELECt ID FROM Appointment_Slot__c LIMIT 1].id;
        String contactId = [SELECt ID FROM Contact LIMIT 1].id;
        NYSDOHAllSchedulesController.createAppoitment(slotId,contactId);
        
    }

}