public class EEC_RecordTypeUtil {

    private static final Map<ID, RecordType> BY_ID_MAP = new Map<ID, RecordType>();
    private static final Map<String, RecordType> BY_NAME_MAP = new Map<String, RecordType>();
    private static final Map<String, Schema.SObjectField> FIELD_DESCRIBE_MAP;
    
    static {
        Schema.DescribeSObjectResult describe = RecordType.getSObjectType()
                .getDescribe();
        FIELD_DESCRIBE_MAP = describe.fields.getMap();
        String soql = 'select ';
        List<String> fieldNames = new List<String>(FIELD_DESCRIBE_MAP.keySet());
        for (Integer i = 0; i < fieldNames.size(); i++) {
            String fieldName = fieldNames[i];
            soql += fieldName;
            if (i < fieldNames.size() - 1) {
                soql += ', ';
            }
        }
        soql += ' from RecordType';
        for (RecordType rt : Database.query(soql)) {
            BY_ID_MAP.put(rt.Id, rt);
            BY_NAME_MAP.put((rt.SobjectType + '.' + rt.DeveloperName)
                    .toUpperCase(), rt);
        }
    }
    
   
    public static RecordType findById(ID recordTypeId) {
        return BY_ID_MAP.get(recordTypeId);
    }
    
    
    public static RecordType findByName(String dqDeveloperName) {
        System.debug('----- BY_NAME_MAP '+BY_NAME_MAP);
        return BY_NAME_MAP.get(dqDeveloperName.toUpperCase());
    }
    
}