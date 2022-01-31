public class UpdateAppointmentController {
	@AuraEnabled
    public static void updateStatus(String appointmentId){
        Appointment__c appointment = [SELECT Id, Status__c FROM Appointment__c WHERE Id =: appointmentId LIMIT 1];
        if(appointment.Status__c != 'Closed'){
         	appointment.Status__c = 'Closed';   
        }
        update appointment;
    }
}