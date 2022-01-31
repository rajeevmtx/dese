global class NHDOH_QRScanController {
    
    @RemoteAction
    global static void updateAppointment(string accountName){
        //system.assertEquals(true, false);
        Appointment__c acc = new Appointment__c();
        acc.Id = accountName;
        acc.Status__c = 'Closed';
        update acc;
    }

}