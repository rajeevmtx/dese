public with sharing class FcHouseholdInformationController {
    @AuraEnabled
    public static void saveMinorChildrenInformation(String jsonString){
        MinorChildWrapper wrapper = (MinorChildWrapper) JSON.deserialize(jsonString, MinorChildWrapper.class );
        for(MinorChildArrayWrapper wpr : wrapper.minorChildArray){
            System.debug('wpr>'+wpr);
        }
    }

    @AuraEnabled
    public static void saveAdultInformation(String jsonString){
        AdultWrapper wrapper = (AdultWrapper) JSON.deserialize(jsonString, AdultWrapper.class );
        for(AdultArrayWrapper wpr : wrapper.adultArray){
            System.debug('wpr>adu>'+wpr);
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

    public class AdultWrapper{
        public String permitId;
        public String minorChildrenInFamilty;
        public List<AdultArrayWrapper> adultArray;
    }

    public class AdultArrayWrapper{
        public String name;
        public String dob;
        public String relationship;
        public String residing;
        public String heading;
        public String key;
        public String isDelete;
    }
}