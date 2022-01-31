public with sharing class FcAdoptionInformationController {
    @AuraEnabled
    public static void saveChildDesireInformation(String jsonString){
        ChildDesireWrapper wrapper = (ChildDesireWrapper) JSON.deserialize(jsonString, ChildDesireWrapper.class );
        for(ChildDesireArrayWrapper wpr : wrapper.childDesireArray){
            System.debug('wpr>'+wpr);
        }
    }

    public class ChildDesireWrapper{
        public String permitId;
        public String dependent;
        public String childPreferences;
        public String siblings;
        public List<ChildDesireArrayWrapper> childDesireArray;
    }

    public class ChildDesireArrayWrapper{
        public String name;
        public String gender;
        public String dob;
        public String relationship;
        public String dop;
        public String county;
        public String heading;
        public String key;
        public String isDelete;
    }
}