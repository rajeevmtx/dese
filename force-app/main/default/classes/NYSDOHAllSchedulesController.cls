public class NYSDOHAllSchedulesController {
    
    @AuraEnabled
    public static SlotWrapper fetchAllSlots(string accountId, string startDate, string endDate){
        List<Appointment_Slot__c> slots = [Select id,Account__c,Date__c,End_Time__c,
        Start_Time__c,Remaining_Capacity__c from Appointment_Slot__c Order By Date__c, Start_Time__c];


        SlotWrapper sw = new SlotWrapper();

        Set<Date> dates = new Set<Date>();
        Set<Time> times = new Set<Time>();
        
        Map<String,Appointment_Slot__c > dateTimeAndASlot = new Map<String, Appointment_Slot__c>();

        for( Appointment_Slot__c slot : slots ){
            dates.add(slot.Date__c);
            times.add(slot.Start_Time__c);
            
            string dtKey = slot.Date__c + '-' + slot.Start_Time__c;
            dateTimeAndASlot.put(dtKey, slot);
        }

        SlotWrapper slotWrapperObj = new SlotWrapper();
        sw.dates = new List<Date>();
        slotWrapperObj.rows = new List<SlotRowWrapper>();

        for( Time tm : times){
            //Row
            SlotRowWrapper srw = new SlotRowWrapper();
            srw.timeSt = tm+'';
            srw.cols = new List<SlotColWrapper>();
            
            for( Date dt : dates ){

                string dtKey = dt + '-' + tm;

                //Col
                Appointment_Slot__c alot = dateTimeAndASlot.get(dtKey);
                
                SlotColWrapper scw = new SlotColWrapper();
                scw.isAvailable = true;
                scw.slotId = alot.Id;

                srw.cols.add(scw);
            }

            slotWrapperObj.rows.add(srw);
        }

        sw.dates.addAll(dates);
        
        return slotWrapperObj;
    }


    @AuraEnabled
    public static void createAppoitment(string appoitmentSlotId, string contactId){
        Appointment_Slot__c aslot = [Select id,Account__c,Date__c,End_Time__c,
                                Start_Time__c,Remaining_Capacity__c from Appointment_Slot__c 
                                Where id =: appoitmentSlotId];
    
        Appointment__c ap = new Appointment__c();
        ap.Appointment_Slot__c = aslot.Id;
        ap.Appointment_Start_Date__c = Datetime.newInstance( aslot.Date__c, aslot.Start_Time__c );
        ap.Appointment_End_Date__c = Datetime.newInstance( aslot.Date__c, aslot.End_Time__c );
        ap.Account__c = aslot.Account__c;
        ap.Patient__c = contactId;
        insert ap;
    }
    
    public class SlotWrapper{
        @AuraEnabled public List<Date> dates;
        @AuraEnabled public List<SlotRowWrapper> rows;
    }

    public class SlotRowWrapper{
        @AuraEnabled public string timeSt;
        @AuraEnabled public List<SlotColWrapper> cols;
    }

    public class SlotColWrapper{
        @AuraEnabled public boolean isAvailable;
        @AuraEnabled public string slotId;
    }
}