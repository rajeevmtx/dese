public class GenerateAppointmentControllerr {
    public Id accId{get;set;}
    Public List<Appointment__c> appointmentList{get;set;}
    Public List<Appointment_Slot__c> appointmentSLotList{get;set;}
    
     Public Appointment__c appRec{get;set;}
    
    
    public GenerateAppointmentControllerr(ApexPages.StandardController std){
        
        accId= std.getId(); 
        
        if(accId == null){
            accId = ApexPages.currentPage().getParameters().get('Id');
        }
        
        
        appointmentList = new List<Appointment__c>();
        appointmentSLotList = new List<Appointment_Slot__c>(); 
        
        for(Appointment__c appointment:[SELECT id,Name,Appointment_End_Date__c, Appointment_Slot__c,Appointment_Slot__r.Date__c, Appointment_Slot__r.Start_Time__c,
                                                Appointment_Start_Date__c, Appointment_Summary__c, Appointment_Type__c,Doctor__c, Patient__c,
                                                Patient__r.FirstName,Patient__r.LastName,Patient__r.Birthdate, QR_Code__c, Reason_of_Appointment__c,
                                                Testing_Site__r.BillingStreet,Testing_Site__r.BillingState, Testing_Site__r.BillingCity,Testing_Site__r.BillingPostalCode,
                                                Patient__r.Sex__c,Patient__r.Email, Patient__r.Phone
                                          FROM Appointment__c 
                                         WHERE Testing_Site__c =:accId /*AND Appointment_Slot__r.Date__c= '3/24/2020'*/]){
                                               
              appointmentList.add(appointment);  
        }
        
        //system.assert(false,appointmentList);
        
        if(!appointmentList.isEmpty()){
            appRec= appointmentList[0];
        }
                
         
        
    }
    
    
    public PageReference savePDF(){
        PageReference pagePdf = pdfPageReference();
        pagePdf.getParameters().put('id', accId); 
        
        
        Attachment a = new Attachment();
        a.Body = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pagePdf.getContentAsPdf();
        a.ParentID = accId;
        a.Name = 'Appointment Certificate - ' + System.Today().format() + '.pdf';
        
        insert a;
       
        return new PageReference('/' + accId);
    }
    
    public PageReference pdfPageReference(){
        return Page.GenerateAppointmentLetterPDF;
    } 

}