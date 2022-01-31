@istest
public class NysDohSchdulerConfigurationsControl_Test {
    @testSetup
    static void makedata(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Testing Site').getRecordTypeId();
        List<Account> accountList = NYSDOH_TestFactory.createAccount(false);
        accountList[0].recordtypeid = recordTypeId;
        insert accountList;
        List<Appointment_Slot__c> appointmentSlotList = NYSDOH_TestFactory.createAppointmentSlot(accountList[0].id,true);
    }
    @isTest
    static void initMethodTest(){
        NysDohSchdulerConfigurationsController.ViewData viewDataWrapper = new NysDohSchdulerConfigurationsController.ViewData();
        viewDataWrapper = NysDohSchdulerConfigurationsController.initMethod();
        System.assertEquals(viewDataWrapper!=null, true);
    }
    @isTest
    static void generateRecordsTest(){
        Appointment_Slot__c appSlotRec = [SELECT ID FROM Appointment_Slot__c LIMIT 1];
        Account acc = [Select Id,Name FROM Account];
       // String slotRecord = JSON.serialize(appSlotRec);
       // System.debug('>>>>>>' + slotRecord);
        string slotRecord ='{"timeSlots":[{"startTime":"18:30:02.020Z","scheduleDate":"2020-03-27","lane":4,"endTime":"19:30:02.020Z","duration":40}],"siteList":[{"value":"XYZ","label":"xyz"}],"accountName":"'+acc.Name+'","accountId":"'+acc.Id+'"}';
       Appointment_Slot__c slotList = [Select Id,Account__c FROM Appointment_Slot__c WHERE Account__c =:acc.Id LIMIT 1];
        Test.startTest();
        NysDohSchdulerConfigurationsController.generateRecords(slotRecord);
        Test.stopTest();
        System.assertNotEquals(slotList,null);
        
    }
}