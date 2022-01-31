/**
* Created by hardikranjan on 22/03/20.
*/

public without sharing class NYCDOH_IntakeRequestTestCenter {
    
    @AuraEnabled
    public static void saveQuestionAnswers(SObject objData){
        try {
            System.debug('Contact objData: '+objData);
            Contact con = (Contact) objData;
            update con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+ ' - '+e.getLineNumber());
        }
    }
    
    
    @AuraEnabled
    public static String saveContactInformation(String objData) {
        try {
            Contact con = (Contact) JSON.deserializeStrict(objData, Contact.class);
            con.AccountId = System.Label.NYC_Contact_Infor_Account_Association;
            con.Intake_Type__c = isCommunity() ? 'External' : 'Internal';
            insert con;

            List<Appointment_Slot__c> alot = [Select id from Appointment_Slot__c  
            WHERE 
            Account__c =: con.Preferred_Testing_Site__c 
            AND Date__c = null 
            And Start_Time__c = null 
            AND End_Time__c = null
            AND Unscheduled__c = true 
            ];

            Appointment__c app = new Appointment__c();
            app.Patient__c = con.Id;
            app.Appointment_Slot__c = alot[0].Id;
            insert app;
            
            return con.Id;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean isCommunity(){
        return (Network.getNetworkId()!=null);
    }
    
    @AuraEnabled
    public static AppointmentSlots getAppointmentSlots(Id contactId, Id accountId, Boolean isPriority){
        Map<Date, Map<String, SlotWrapper>> mapDateToTimeslots = new Map<Date, Map<String, SlotWrapper>>();
        // Main query: SELECT Id, Date__c, Start_Time__c FROM Appointment_Slot__c WHERE Remaining_Capacity__c > 0 AND Date__c = THIS_WEEK AND Account__c = :accountId
        for(Appointment_Slot__c slot : [SELECT Id, Date__c, Start_Time__c FROM Appointment_Slot__c WHERE Date__c = THIS_WEEK AND Account__c = :accountId LIMIT 10]) {
            Map<String, SlotWrapper> slotWrapperMap = new Map<String, SlotWrapper>();
            
            String timeString = getTimeString(slot.Start_Time__c);
            
            if(mapDateToTimeslots.containsKey(slot.Date__c)) slotWrapperMap = mapDateToTimeslots.get(slot.Date__c);
            slotWrapperMap.put(timeString, new SlotWrapper(slot.Id, slot.Date__c, slot.Start_Time__c));
            
            mapDateToTimeslots.put(slot.Date__c, slotWrapperMap);
        }
        
        System.debug('HG: ');
        System.debug(JSON.serialize(mapDateToTimeslots));
        
        Date startDate = resetStartDate();
        Date endDate = startDate + 4;
        
        Time startTime = Time.newInstance(10, 0, 0, 0);
        Time endTime = Time.newInstance(11, 0, 0, 0);
        
        AppointmentSlots appointmentSlots = new AppointmentSlots();
        appointmentSlots.slotWrappers = new List<List<SlotWrapper>>();
        appointmentSlots.dateWrapperObj = new List<DateWrapper>();
        
        while(startDate <= endDate) {
            startDate = startDate + 1;
            appointmentSlots.dateWrapperObj.add(new DateWrapper(startDate));
        }

        startDate = resetStartDate();

        while(startTime <= endTime) {
            System.debug('Time is ' + startTime);
            
            String timeString = getTimeString(startTime);
            System.debug('HG: timestring ' + timeString);
            
            List<SlotWrapper> slotsForATime = new List<SlotWrapper>();
            
            startDate = resetStartDate();

            while(startDate <= endDate) {
                System.debug('HG: startDate is ' + startDate);

                if(mapDateToTimeslots.containsKey(startDate) && mapDateToTimeslots.get(startDate).containsKey(timeString)) {
                    slotsForATime.add(mapDateToTimeslots.get(startDate).get(timeString));
                } else {
                    slotsForATime.add(new SlotWrapper(startDate, startTime));
                }
                
                startDate = startDate.addDays(1);
            }
            
            appointmentSlots.slotWrappers.add(slotsForATime);
            
            startTime = startTime.addMinutes(10);
        }
        
        System.debug('HG: ' + JSON.serialize(appointmentSlots.slotWrappers));
        
        return appointmentSlots;
    }
    
    private static String getTimeString(Time timeObj) {
        String hour = timeObj.hour() != 0 ? String.valueOf(timeObj.hour()) : '00';
        String minute = timeObj.minute() != 0 ? String.valueOf(timeObj.minute()) : '00';
        
        return hour + minute;
    }

    private static Date resetStartDate() {
        return Date.today().toStartOfWeek() + 1;
    }
    
    public class DateWrapper {
        @AuraEnabled public Date currentDate;
        @AuraEnabled public String dayOfWeek;
        
        public DateWrapper(Date currentDate) {
            this.currentdate = currentDate;
            this.dayOfWeek = ((DateTime) currentDate).format('E');
        }
    }
    
    public class SlotWrapper {
        @AuraEnabled public boolean isAvailable;
        @AuraEnabled public boolean isSelected;
        @AuraEnabled public Date slotDate;
        @AuraEnabled public Time slotTime;
        @AuraEnabled public String slotId;
        @AuraEnabled public String uniqueId;
        
        public SlotWrapper (Id slotId, Date slotDate, Time slotTime) {
            this.isAvailable = true;
            this.isSelected = false;
            this.slotDate = slotDate;
            this.slotTime = slotTime;
            this.slotId = slotId;
            this.uniqueId = String.valueOf(slotDate) + slotTime;
        }
        
        public SlotWrapper (Date slotDate, Time slotTime) {
            this.isAvailable = false;
            this.isSelected = false;
            this.slotDate = slotDate;
            this.slotTime = slotTime;
            this.slotId = '';
            this.uniqueId = String.valueOf(slotDate) + slotTime;
        }
    }
    
    public class AppointmentSlots {
        @AuraEnabled public List<DateWrapper> dateWrapperObj;
        @AuraEnabled public List<List<SlotWrapper>> slotWrappers;
    }
    
}