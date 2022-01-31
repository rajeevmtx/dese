public class NYSDOH_CustomLookupController {
	@AuraEnabled
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField){
        String key = '%' + searchKey + '%';
        String QUERY = 'Select Id, '+searchField+' From '+objectName +' Where '+searchField +' LIKE :key'+' LIMIT 10';
        System.debug(System.LoggingLevel.DEBUG, QUERY);
        List<SObject> sObjectList = Database.query(QUERY);        
        return sObjectList;
    }
}