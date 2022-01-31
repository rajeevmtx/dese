/*
*   Class Name: Utility_RollUp_Helper
*   Description: Utility class for Apex Sharing.  This class defines a template for inserting into a share table that can
*         easily be called from other classes.
*   Author/Date: 
*                        
*/
public without sharing class Utility_Sharing
{ 

    private static final Integer LIMIT_DML_ROWS_SF = Limits.getLimitDmlRows();
    public  static Integer LIMIT_DML_ROWS_DEFINED = (Limits.getLimitDmlRows() - 1000); // Fix: TOO MANY DML ROWS

    public static final String ACCESS_READ = 'read';
    public static final String ACCESS_WRITE = 'edit';


    public static String sharingReasonOverride = null;

    public static Map<String,String> rowCauseMap
    {
        get
        { 
            if (rowCauseMap == null)
            {
                rowCauseMap = new Map<String,String>();
                rowCauseMap.put('Project__c',Schema.Project__share.RowCause.Contractor__c); 
                rowCauseMap.put('Project_Document__c',Schema.Project_Document__share.RowCause.Contractor__c);
            }
            return rowCauseMap;
        }
        set;
    }

  /*
  * Method Name: unshareObjects
  * Description: Remove sharing record for Case and UserOrGroup type
  * @param: String sObjectType
  * @param: SharingRecord[] records
  * @return: void                                                       
  */
    public static void unshareObjects(String sObjectType, SharingRecord[] records)
    {
        String sharingTable = Utility_Describe.getSharingObjectName(sObjectType);
        String shareReason = rowCauseMap.get(sObjectType);
        Map<Id,SharingRecord> recordMap = new Map<Id,SharingRecord>();
        for (SharingRecord r :records)
            recordMap.put(r.recordId,r);

        Set<Id> recordMapKeys = recordMap.keyset();
        sObject[] sharingRecordsToPurge = new sObject[]{};

        if(recordMapKeys.size() > 0 && String.valueOf(new List<Id>(recordMapKeys)[0]).StartsWith('500')) {
          shareReason = 'RelatedPortalUser';
          sObject[] sharingRecords = Database.Query('SELECT Id,CaseId,UserOrGroupId FROM ' + CORE_Helper.doEscapeSingleQuotes(sharingTable) + ' WHERE RowCause = :shareReason AND CaseId IN :recordMapKeys');
          for (sObject r : sharingRecords)
          {
              Id cId = (Id) r.get('CaseId');
              Id uId = (Id) r.get('UserOrGroupId');
              if (recordMap.containsKey(cId) && recordMap.get(cId).userIds.contains(uId))
                  sharingRecordsToPurge.add(r);
          }
        } else {
          sObject[] sharingRecords = Database.Query('SELECT Id,ParentId,UserOrGroupId FROM ' + CORE_Helper.doEscapeSingleQuotes(sharingTable) + ' WHERE RowCause = :shareReason AND ParentId IN :recordMapKeys');
          for (sObject r : sharingRecords)
          {
              Id pId = (Id) r.get('ParentId');
              Id uId = (Id) r.get('UserOrGroupId');
              if (recordMap.containsKey(pId) && recordMap.get(pId).userIds.contains(uId))
                  sharingRecordsToPurge.add(r);
          }
        }

        delete sharingRecordsToPurge;
    }
  
  /*
  * Method Name: shareObjects
  * Description: Remove sharing record for Case and UserOrGroup type
  * @param: String sObjectType
  * @param: SharingRecord[] records
  * @return: void                                                       
  */
    public static void shareObjects(String sObjectType, SharingRecord[] records)
    {
        String sharingTable = Utility_Describe.getSharingObjectName(sObjectType);
        String shareReason = (String.isNotBlank(sharingReasonOverride) ? sharingReasonOverride : rowCauseMap.get(sObjectType)); // This has to be handled carefully

        sObject[] shareRecordsToInsert = new sObject[]{};
        Schema.SObjectType shareObjectType = Utility_Describe.globalDescribe.get(sharingTable);
        System.debug('--records--> '+records);

        // Fix: TOO MANY DML ROWS
        Set<Set<String>> userObjMapSet = new set<Set<String>>();
        Set<String> userObjMapping = new Set<String>();
        Integer recordCount = 0;
        // Fix: TOO MANY DML ROWS

        for (SharingRecord record :records)
        {
            for (SharingRecordUser u : record.users)
            {
                String userObjStr ;
                sObject shareRecord = shareObjectType.newSObject();
                //system.debug(shareReason);
                if(String.valueOf(record.recordId).StartsWith('500')) {
                  shareRecord.put('RowCause','RelatedPortalUser');
                  shareRecord.put('CaseId',record.recordId);
                  shareRecord.put('UserOrGroupId',u.userId);
                  shareRecord.put('CaseAccessLevel',u.accessLevel);
                    userObjStr = 'RelatedPortalUser' + '~' + record.recordId + '~' + u.userId + '~' +u.accessLevel; // Fix: TOO MANY DML ROWS
                } else {
                  shareRecord.put('RowCause',shareReason);
                  shareRecord.put('ParentId',record.recordId);
                  shareRecord.put('UserOrGroupId',u.userId);
                  shareRecord.put('AccessLevel',u.accessLevel);
                    userObjStr = shareReason + '~' + record.recordId+ '~'+ u.userId + '~' +u.accessLevel; // Fix: TOO MANY DML ROWS
                }
                recordCount++;
                userObjMapping.add(userObjStr);
                shareRecordsToInsert.add(shareRecord);
                if(recordCount == LIMIT_DML_ROWS_DEFINED) {
                    userObjMapSet.add(userObjMapping.clone()); // Avoid referencing the Original Set
                    userObjMapping.clear();
                    recordCount = 0;
                }
            }
        }

        System.debug('>>> BulkMode Map Size: ' + userObjMapSet.size() + ' Remaining: ' + userObjMapping.size() + ' Count: ' + recordCount);
        if(userObjMapSet.size() > 0 && userObjMapping.size() > 0 && recordCount != 0) {
            userObjMapSet.add(userObjMapping.clone()); // Avoid referencing the Original Set
            userObjMapping.clear();
            recordCount = 0;
        }

        System.debug('--shareRecordsToInsert---'+shareRecordsToInsert.size());

        if(!System.isFuture() && userObjMapSet.size() > 0) {
            // Fix: TOO MANY DML ROWS
            // Avoid Error: Future method cannot be called from a future or batch method
            System.debug('>>> Future method Iterations = ' + userObjMapSet.size());
            for(set<String> userObjMappingSet :  userObjMapSet){
                System.debug('>>> Scope size SENT = ' + userObjMappingSet.size());
                Utility_Sharing.createShareRecords(userObjMappingSet,sObjectType);
            }
        } else if(shareRecordsToInsert.size() > 0){
            System.debug('>>> Direct DML Invoked: ' + shareRecordsToInsert.size());

            // DML Rows check  Case: 00006677
            if((Limits.getDmlRows() + shareRecordsToInsert.size()) < LIMIT_DML_ROWS_SF) {
              insert shareRecordsToInsert;
            }
        }
    }
    
  /*
  * Method Name: createShareRecords
  * Description: Insert shares records 
  * @param: Set<String> userObjMapping
  * @param: String sObjectType
  * @return: void                                                       
  */
    @future
    public static void createShareRecords(Set<String> userObjMapping, String sObjectType){

        String sharingTable = Utility_Describe.getSharingObjectName(sObjectType);
        String shareReason = rowCauseMap.get(sObjectType);
        String rowCause_Default = 'RelatedPortalUser';
        sObject[] shareRecordsToInsert = new sObject[]{};
        Schema.SObjectType shareObjectType = Utility_Describe.globalDescribe.get(sharingTable);

        if(userObjMapping != null) {
          System.debug('>>> Scope size = ' + userObjMapping.size());
        }

        for(String userObjStr : userObjMapping){
            sObject shareRecord = shareObjectType.newSObject();
            List<String> splitStr = userObjStr.split('~');

            // FORMAT: shareReason + '~' + recordId+ '~'+ userId + '~' + accessLevel; // Fix: TOO MANY DML ROWS

            if(splitStr.size() > 1 ) {

                shareRecord.put('RowCause',(String.isNotBlank(splitStr[0]) ? splitStr[0] : rowCause_Default));
                shareRecord.put('UserOrGroupId',splitStr[2]);

                if(String.valueOf(splitStr[1]).StartsWith('500')) {
                    shareRecord.put('CaseId',splitStr[1]);
                    shareRecord.put('CaseAccessLevel',splitStr[3]);
                }
                else{
                    shareRecord.put('ParentId',splitStr[1]);
                    shareRecord.put('AccessLevel',splitStr[3]);
                }
            }
            //System.debug('>>> shareRecord = ' + shareRecord);
            shareRecordsToInsert.add(shareRecord);
        }
        if(shareRecordsToInsert.size() > 0) {
            insert shareRecordsToInsert;
        }
    }

    public class SharingRecord
    {
        public Id recordId;
        public SharingRecordUser[] users;
        public Set<Id> userIds
        {
            get
            {
                if (userIds == null)
                {
                    if (users != null)
                    {
                        userIds = new Set<Id>();
                        for (SharingRecordUser sru :users)
                            userIds.add(sru.userId);
                    }
                }
                return userIds;
            }
            set;
        }

        public SharingRecord(Id r, SharingRecordUser[] u)
        {
            recordId = r;
            users = u;
        }
    }

    public class SharingRecordUser
    {
        public Id userId;
        public String accessLevel;

        public SharingRecordUser(Id u, String a)
        {
            userId = u;
            accessLevel = a;
        }
    }
}