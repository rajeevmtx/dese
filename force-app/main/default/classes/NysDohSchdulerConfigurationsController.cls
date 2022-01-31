public class NysDohSchdulerConfigurationsController {
    
    
    @AuraEnabled
    public static ViewData initMethod(){
        
        ViewData view = new  ViewData ();        
        timeValues testData = new timeValues();
        List<timeValues> listVal = new  List<timeValues>();
        listVal.add(testData);
        view.timeSlots = listVal;
        view.siteList = getAccountList();
        return view;
        
    }
    
    public static List<picklistWrapper> getAccountList(){
        List<picklistWrapper> listOfValues = new List<picklistWrapper>();
        for(Account acc : [select id,name from Account where recordtypeid =: Label.NYSDOH_Account_RecordType]){
            picklistWrapper pw = new picklistWrapper();
            pw.label = acc.name;
            pw.value = acc.id;
            listOfValues.add(pw);
        }
        return listOfValues;
    }
    @AuraEnabled
    public static void generateRecords(String slotRecords){
        Boolean slotFlag = false;
        ViewData view = new  ViewData();
        if(!string.isBlank(slotRecords)){
            view = (ViewData)System.JSON.deserialize(slotRecords,ViewData.class);
        }
        system.debug('view'+slotRecords);
        Account relatedAccount = new Account();
        if(view.accountId != null)
            relatedAccount = [SELECT Id,(SELECT id,Date__c,End_Time__c ,Unscheduled__c,Start_Time__c  FROM Appointment_Slots__r ) FROM Account where id=:view.accountId LIMIT 1];
        for(Appointment_Slot__c slotVar :relatedAccount.Appointment_Slots__r){
            if(slotVar.Date__c == null && slotVar.End_Time__c == null && slotVar.Start_Time__c == null && slotVar.Unscheduled__c ==true ){
                slotFlag = true; 
            }
        }
        
        List<Appointment_Slot__c> appointmentSlotList = new List<Appointment_Slot__c>();
        
        if(!slotFlag){
            Appointment_Slot__c appointSlot = new Appointment_Slot__c();
            appointSlot.Date__c = null;
            appointSlot.Account__c = view.accountId;
            appointSlot.Start_Time__c = null;
            appointSlot.End_Time__c  = null;
            appointSlot.Unscheduled__c  = true;
            appointmentSlotList.add(appointSlot);
        }
        
        for(timeValues slot : view.timeSlots){
            Time finalTime = NysDohSchdulerConfigurationsController.GetElapsedTime(slot.startTime,slot.endTime); 
            Integer timeInMinute = (finalTime.hour()*60) + finalTime.minute();
            Integer timeInterval = timeInMinute/slot.duration;
            for(Integer firstCount=0;firstCount<slot.lane;firstCount++){
                Integer counter = 0;
                for(Integer count=0;count<timeInterval;count++){  
                    Appointment_Slot__c appointmentSlot = new Appointment_Slot__c();
                    appointmentSlot.Date__c = slot.scheduleDate;
                    appointmentSlot.Account__c = view.accountId;
                    appointmentSlot.Start_Time__c = NysDohSchdulerConfigurationsController.getUserTime(slot.scheduleDate,slot.startTime.addMinutes(counter));
                    appointmentSlot.End_Time__c  = appointmentSlot.Start_Time__c.addMinutes(slot.duration);
                    counter = counter+slot.duration;
                    appointmentSlotList.add(appointmentSlot);
                }
            }
        }
        
        if(!appointmentSlotList.isEmpty()){
            insert appointmentSlotList;
        }
        
    }
    public static Time getUserTime (Date dateValue, Time timeValue){
        
        DateTime dt = DateTime.newInstance(dateValue, timeValue);
        Integer offset = UserInfo.getTimezone().getOffset(dt);
        Datetime local = dt.addSeconds(offset/1000);
        return local.time();
        
    }
    
    public static Time GetElapsedTime(Time startTime, Time endTime)
    {
        if(startTime == null || endTime == null)
            return Time.newInstance(0, 0, 0, 0);
        Integer elapsedHours = endTime.hour() - startTime.hour();
        Integer elapsedMinutes = endTime.minute() - startTime.minute();
        Integer elapsedSeconds = endTime.second() - startTime.second();
        Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
        return Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
    }
    public class ViewData{
        @AuraEnabled public Id accountId{get;set;}
        @AuraEnabled public String accountName{get;set;}
        @AuraEnabled public List<picklistWrapper> siteList{get;set;}
        @AuraEnabled public List<timeValues> timeSlots{get;set;}
    }
    
    public class timeValues{
        @AuraEnabled public Date scheduleDate{get;set;}
        @AuraEnabled public Integer lane{get;set;}
        @AuraEnabled public Integer duration {get;set;}
        @AuraEnabled public Time startTime{get;set;}
        @AuraEnabled public Time endTime{get;set;}  
    }
    public class picklistWrapper{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;} 
    }
    
}