/*
* 	Class Name: Utility_RecordType_Helper
* 	Description: Helper class for Record Types
*
* 	Author/Date: George Acker/March 15, 2016 	
*                        
*/
public class Utility_RecordType_Helper
{
    private static Utility_MapChain recordTypes;
    private static Set<string> sObjectsQueried;

    /*
	* Method Name: getRecordType
	* Description: return a record type based on object name and record type developer name
	* @param: String sObjectName
	* @param: String recTypeDevName
	* @return: RecordType                                                       
	*/
    public static RecordType getRecordType(String sObjectName, String recTypeDevName) {
        if (recordTypes == null || !sObjectsQueried.contains(sObjectName))
            setupRecordTypes(new Set<String> {sObjectName});
        
        return (RecordType) recordTypes.getData(new string[]{sObjectName,recTypeDevName});
    }
    
    
    /*
	* Method Name: setupRecordTypes
	* Description: :populates a MapChain with record types for the object(s) passed in
    			   :MapChain stays in memory to avoid querying the same object's record types multiple times
    			   :if # of queries is a concern (test methods inserting thousands of records), you can call this method directly
    			   :to populate multiple object record types in one single query
    			   :don't call this method directly unless you have to as it is unnecessary for most normal use cases
	* @param: Set<String> sObjs
	* @return: void                                                       
	*/
    public static void setupRecordTypes(Set<String> sObjs)
    {
        if (sObjectsQueried == null)
            sObjectsQueried = new Set<string>();
        sObjectsQueried.addAll(sObjs);
        if (recordTypes == null)
            recordTypes = new Utility_MapChain();
        for (RecordType recType :[SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE sObjectType IN :sObjs])
        {
            recordTypes.putData(new string[] {recType.sObjectType,recType.DeveloperName},recType);
        }
    }
}