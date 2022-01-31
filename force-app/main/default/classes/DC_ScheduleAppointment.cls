public class DC_ScheduleAppointment {

    public static Final String ACCOUNT_TYPE = 'Testing Site';
    
    @AuraEnabled
    public static List<SObject> getSiteAccounts(){  
        return  [Select Id,Name FROM Account WHERE Type =: ACCOUNT_TYPE];                   
    }

    @AuraEnabled
    public static Map<String,Object> getAppointmentDetail(String appointmentId) { 
        Map<String,Object> result = new Map<String,Object>();
        for(Appointment__c appointment : [SELECT Id, Testing_Site__c, Patient__c, Appointment_Slot__c,Status__c FROM Appointment__c WHERE Id =: appointmentId]) {
            result.put('appointment',appointment);
        }
        return result;                   
    }

    @AuraEnabled
    public static void createAppointment(String accountId,String contactId,String slotId){
        List<Appointment__c> existingAppointmentList = [SELECT Id,Testing_Site__c,Appointment_Slot__c FROM Appointment__c WHERE Patient__c =: contactId AND (Status__c = 'To Be Scheduled' OR Status__c = 'Scheduled') LIMIT 1];
        if(existingAppointmentList.size() > 0) {
            existingAppointmentList[0].Testing_Site__c = accountId;
            existingAppointmentList[0].Appointment_Slot__c = slotId;
            existingAppointmentList[0].Status__c = 'To Be Scheduled';
            update existingAppointmentList;

        } else {
            insert new Appointment__c(Testing_Site__c = accountId,Patient__c = contactId,Appointment_Slot__c = slotId,Status__c = 'To Be Scheduled');
        }
    }

    @AuraEnabled
    public static void updateAppointment(String accountId,String appointmentId,String slotId){
        List<Appointment__c> existingAppointmentList = [SELECT Id,Testing_Site__c,Appointment_Slot__c FROM Appointment__c WHERE Id =: appointmentId LIMIT 1];
        if(existingAppointmentList.size() > 0) {
            existingAppointmentList[0].Testing_Site__c = accountId;
            existingAppointmentList[0].Appointment_Slot__c = slotId;
            existingAppointmentList[0].Status__c = 'To Be Scheduled';
            update existingAppointmentList;

        }
    }
    
    @AuraEnabled
    public static Map<String,Object> getAccountSlots(String accountId){  
        Map<String,Object> result = new Map<String,Object>();
        List<Appointment_Slot__c> appointmentSlot = new List<Appointment_Slot__c>();
        
        Set<Id> appointIds = new Set<Id>();
        List<String> timeSlots = new List<String>();
        Map<String,List<SObject>> slotMap = new Map<String,List<SObject>>();
        Map<Date,Map<String,List<SObject>>> dateMap = new Map<Date,Map<String,List<SObject>>>{Date.today().addDays(1) => new Map<String,List<SObject>>() ,
            																			Date.today().addDays(2) => new Map<String,List<SObject>>() ,
                                                                                          Date.today().addDays(3) => new Map<String,List<SObject>>() ,
                                                                                          Date.today().addDays(4) => new Map<String,List<SObject>>() ,
                                                                                          Date.today().addDays(5) => new Map<String,List<SObject>>() ,
                                                                                          Date.today().addDays(6) => new Map<String,List<SObject>>() ,
            																			Date.today().addDays(7) => new Map<String,List<SObject>>() };
        
        appointmentSlot = [SELECT Id,Name,Account__c, Date__c, Start_Time__c, End_Time__c, Unscheduled__c, Appointment_Count__c, Remaining_Capacity__c 
                                    FROM Appointment_Slot__c
                                    WHERE Account__c =: accountId
                                    AND Date__c = NEXT_N_DAYS:7
                          			ORDER BY Date__c ASC,Start_Time__c ASC];     
        for(Appointment_Slot__c slot : appointmentSlot){
            DateTime dateTimeVar = DateTime.newInstance(Date.today(),slot.Start_Time__c);
            system.debug(dateMap.containsKey(slot.Date__c));
            if(dateMap.containsKey(slot.Date__c)) {
                Map<String,List<SObject>> slotAndAppointMentMap = dateMap.get(slot.Date__c);
                if(!slotAndAppointMentMap.containsKey(dateTimeVar.format('hh:mm aa'))) {
                    slotAndAppointMentMap.put(dateTimeVar.format('hh:mm aa'),new List<SObject>());
                }
                if(slot.Appointment_Count__c == 0)
                    slotAndAppointMentMap.get(dateTimeVar.format('hh:mm aa')).add(slot);
                dateMap.put(slot.Date__c,slotAndAppointMentMap);
            }
            if(!timeSlots.contains(dateTimeVar.format('hh:mm aa')))
                timeSlots.add(dateTimeVar.format('hh:mm aa'));
        }
        result.put('records',dateMap);
        result.put('timeSlots',timeSlots);
        return result;
        
    }
    public class UnBookedSlotsMap {
        public Integer rowNumber {get;set;}
        public Integer columnNumber {get;set;}

        public UnBookedSlotsMap(Integer rowNumber, Integer columnNumber) {
            this.rowNumber = rowNumber;
            this.columnNumber = columnNumber;
        }
    }

}