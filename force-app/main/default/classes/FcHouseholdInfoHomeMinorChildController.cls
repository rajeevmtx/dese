public with sharing class FcHouseholdInfoHomeMinorChildController {
    @AuraEnabled
    public static void saveInformation(String jsonString){
        MinorChildWrapper wrapper = (MinorChildWrapper) JSON.deserialize(jsonString, MinorChildWrapper.class );
        for(MinorChildArrayWrapper wpr : wrapper.minorChildArray){
            System.debug('wpr>'+wpr);
        }
    }

    public class MinorChildWrapper{
        public String permitId;
        public String minorChildrenInFamilty;
        public List<MinorChildArrayWrapper> minorChildArray;
    }

    public class MinorChildArrayWrapper{
        public String nameMinorChild;
        public String gender;
        public String dob;
        public String relationship;
        public String finantiallySupport;
        public String heading;
        public String key;
        public String isDelete;
    }
}