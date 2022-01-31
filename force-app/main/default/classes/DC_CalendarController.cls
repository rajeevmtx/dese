public class DC_CalendarController {
    public static string currentUserTimeZone;

    @AuraEnabled
    public static void blockCalender(String appointmentId,Datetime appointmentStartDate ,Datetime appointmentEndDate){        
        Appointment__c appointment = [Select id,Account__c,Appointment_Type__c,Contact__c,Doctor__c,
                                        Reason_of_Appointment__c,Status__c,Appointment_Start_Date__c ,
                                        Appointment_End_Date__c 
                                        from Appointment__c Where Id =: appointmentId];

        Appointment__c newAppointment = appointment.clone(false, false, false, false);
        newAppointment.Appointment_Start_Date__c = appointmentStartDate;
        newAppointment.Appointment_End_Date__c = appointmentEndDate;            
        insert newAppointment;
    }
    
    @AuraEnabled
    public static Appointment__c fetchAppointmenToSchedule(String appointmentId){
        Appointment__c appointment = [Select id,Name,Appointment_Start_Date__c ,Appointment_End_Date__c, Status__c 
                                    FROM Appointment__c 
                                    WHERE Id =:appointmentId LIMIT 1];
        return appointment;
    }

    @AuraEnabled
    public static List<AppointmentWrapper> fetchAppointmens(){
        List<AppointmentWrapper> appointmentWrappers = new List<AppointmentWrapper>();

        for( Appointment__c appointment : [Select id,Name,Appointment_Start_Date__c ,Appointment_End_Date__c,Status__c FROM Appointment__c] ){
            appointmentWrappers.add( new AppointmentWrapper(appointment) );
        }

        return appointmentWrappers;
    }

    public static DateTime convertToCurrentSiteTimezone(DateTime currentDateTime,String timezone){
        String newDateTimeString = currentDateTime.format('yyyy-MM-dd HH:mm:ss',timezone);
        Datetime mewDateTime = Datetime.valueofGmt(newDateTimeString);
        return mewDateTime;
    }

    public static string getUserTimezone(){
        if( string.isBlank(currentUserTimeZone) ){
            currentUserTimeZone = [Select TimeZoneSidKey from User where id =: USerInfo.getUserId()].TimeZoneSidKey;
        }
        return currentUserTimeZone;
    }

    public class AppointmentWrapper{
        @AuraEnabled public ID appointmentId;
        @AuraEnabled public String appointmentName;
        @AuraEnabled public String appointmentStatus; 
        @AuraEnabled public Datetime appointmentStartDate;
        @AuraEnabled public Datetime appointmentEndDate;
        
        public AppointmentWrapper(Appointment__c appointment) {
            this.appointmentId = appointment.Id;
            this.appointmentName = appointment.Name;
            this.appointmentStatus = appointment.Status__c;
            this.appointmentStartDate = convertToCurrentSiteTimezone( appointment.Appointment_Start_Date__c, getUserTimezone() );
            this.appointmentEndDate = convertToCurrentSiteTimezone( appointment.Appointment_End_Date__c, getUserTimezone() );
        }
    }
}