/*
*   Class Name: Utility_Copy_Sobject
*   Description: Utility to copy objects based off dynamic configurations
*
*   Author/Date: George Acker/July 18, 2016
*                        
*/
public without sharing class Utility_Copy_Sobject
{
    private static final STRING CONST_TRANSLATION_TYPE_REPLACE = 'Replace';
    private static final STRING CONST_TRANSLATION_TYPE_EXACT_COPY = 'Exact Copy';
    private static final STRING CONST_NULL = 'NULL';
    private static Map<object,object> translationCache;
    private static String sourceObjectName;
    private static String targetObjectName;
    private static String sourceField;
    private static String targetField;
    private static String sourceTrans;
    private static String targetTrans;
    private static String transType;
    private static String sourceParentKeyField;
    private static String targetParentKeyField;
    private static String ignoreDirectionField;

    // pass the (unique) developer name of the Object_Mapper__mdt record, the ID of the record to copy, and whether to go forward (true) or backward (false)
    public static void copyAll(String objMapperName, Id recordToCopy, boolean forwardDirection)
    {
        translationCache = new Map<object,object>();

        // so we don't have if logic all over the place, set these source and target api names once in advance
        if (forwardDirection)
        {
            sourceObjectName = 'source_object__c';
            targetObjectName = 'target_object__c';
            sourceField = 'source_field__c';
            targetField = 'target_field__c';
            sourceTrans = 'source_value__c';
            targetTrans = 'target_value__c';
            transType   = 'translation_type__c';
            sourceParentKeyField = 'source_parent_key_field__c';
            targetParentKeyField = 'target_parent_key_field__c';
            ignoreDirectionField = 'ignore_forward_direction__c';
        }
        else
        {
            sourceObjectName = 'target_object__c';
            targetObjectName = 'source_object__c';
            sourceField = 'target_field__c';
            targetField = 'source_field__c';
            sourceTrans = 'target_value__c';
            targetTrans = 'source_value__c';
            transType   = 'translation_type__c';
            sourceParentKeyField = 'target_parent_key_field__c';
            targetParentKeyField = 'source_parent_key_field__c';
            ignoreDirectionField = 'ignore_backward_direction__c';
        }

        copy(objMapperName, new Set<Id>(new Id[]{recordToCopy}));
    }

    /*
  * Method Name: copy
  * Description: this method calls itself recursively to handle child object mappers  
  * @param:  String objMapperName
  * @param:  Set<Id> recordsToCopy
  * @return: void                                                       
  */
    private static void copy(String objMapperName, Set<Id> recordsToCopy)
    {
        // Load records from configuration (query object_mapper__mdt, field_mapper__mdt, field_translation__mdt)
        Object_Mapper__mdt objMapping = [SELECT source_object__c,target_object__c,source_record_reference_field__c,copy_attachments__c FROM Object_Mapper__mdt WHERE DeveloperName = :objMapperName];
        Field_Mapper__mdt[] fldMappings = [SELECT source_field__c,target_field__c,is_parent_key__c,static_value__c,ignore_forward_direction__c,ignore_backward_direction__c,override_ignore_flag_on_insert__c,(SELECT source_value__c,target_value__c,translation_type__c FROM Field_Translations__r) FROM Field_Mapper__mdt WHERE object_mapper__c = :objMapping.Id ORDER BY ignore_backward_direction__c ASC];
 
        String queryForSource = 'SELECT ';
        Set<String> soqlQueryColumns_Unique = new Set<String>();
        // loop through the fields and generate a query to get the data from the source object
        for (Field_Mapper__mdt fldMap : fldMappings)
        {
            if(!soqlQueryColumns_Unique.contains((String) fldMap.get(sourceField)))
            {
                queryForSource = addToQuery(queryForSource,(String) fldMap.get(sourceField));
                soqlQueryColumns_Unique.add((String) fldMap.get(sourceField));
            }
        }  
        queryForSource += ' FROM ';
        queryForSource += (String) objMapping.get(sourceObjectName);
        queryForSource += ' WHERE Id IN :recordsToCopy';

        sObject[] targetObjectsToInsert = new sObject[]{};
        sObject[] targetObjectsToUpdate = new sObject[]{}; 
        Set<Id> setOfIdsToUpdate = new Set<Id>();

        SourceTargetAssociation[] sourceTargetLinks = new SourceTargetAssociation[]{};
        system.debug('queryForSource-----'+queryForSource+'--------'+recordsToCopy);
        // get our source objects with the right field data
        for (sObject sourceObject :Database.Query(queryForSource))
        {
            // Create our new targetObject instance based on metadata configuration
            sObject targetObject = Utility_Describe.globalDescribe.get((String) objMapping.get(targetObjectName)).newSObject();
            System.debug('>>> targetObject BEFORE = ' + targetObject);
            // now loop through the field mappings and populate the target object with appropriate values
            for (Field_Mapper__mdt fldMap : fldMappings)
            {
                if (!((boolean) fldMap.get(ignoreDirectionField)) || (fldMap.override_ignore_flag_on_insert__c && targetObject.Id == null))
                {
                    object targetValue;
                    // if we have translations to deal with (record types for example)
                    if (fldMap.Field_Translations__r.size() > 0)
                    {
                        String srcValue = (String) sourceObject.get((String) fldMap.get(sourceField));
                        Map<object,object> translations = new Map<object,object>();
                        for (Field_Translation__mdt fldTrans : fldMap.Field_Translations__r)
                        {
                            if(isValidNonEmptyStringVal(srcValue) && CONST_TRANSLATION_TYPE_REPLACE.equalsIgnoreCase((String)fldTrans.get(transType)))
                            {
                                // e.g. replacing '{Project_Site__c}' with '{Case_Site__c}' to get '{Project_Site__c}.Affordable_Solar__c = True' as '{Case_Site__c}.Affordable_Solar__c = True'
                                srcValue = srcValue.replace((String)fldTrans.get(sourceTrans),(String)fldTrans.get(targetTrans));
                            }
                            translations.put(fldTrans.get(sourceTrans),fldTrans.get(targetTrans));
                        }
                        // If there is still any scope of Exact Copy then proceed with Static Exact Copy
                        targetValue = (translations.containsKey(srcValue) ? translations.get(srcValue) : srcValue);
                    }
                    else if (fldMap.is_parent_key__c) // we are dealing with a key translation for a parent record we previously created, i.e. project id -> case id
                    {
                        targetValue = translationCache.get(sourceObject.get((String) fldMap.get(sourceField)));
                    }
                    else if (fldMap.static_value__c != null && fldMap.static_value__c.length() > 0) // we have a static function to deal with
                    {
                        targetValue = fldMap.static_value__c;
                    }
                    else // this is just a straight up mapping from source to target
                    {
                        targetValue = sourceObject.get((String) fldMap.get(sourceField));
                    }

                    // Override for Value Only
                    if((boolean) fldMap.get(ignoreDirectionField) && fldMap.override_ignore_flag_on_insert__c && targetObject.Id == null) {

                      if(targetValue == null || String.isBlank((String)targetValue)) {
                        continue;
                      }

                    }

                    targetObject.put((String) fldMap.get(targetField),targetValue);
                    System.debug( '<<< Field: = ' + targetField + ': ' + (String) fldMap.get(targetField) + '<--------->' + targetValue);
                }
            }

            System.debug('>>> targetObject AFTER = ' + targetObject);
            sourceTargetLinks.add(new SourceTargetAssociation(sourceObject,targetObject));
            if (targetObject.Id == null) {
                targetObjectsToInsert.add(targetObject);
            } else {
                if(!setOfIdsToUpdate.contains(targetObject.Id)) {
                  setOfIdsToUpdate.add(targetObject.Id);
                  targetObjectsToUpdate.add(targetObject);
                }
            }
        }

        // upsert our data
        insert targetObjectsToInsert;
        update targetObjectsToUpdate;

        Set<Id> insertedRecordIds = new Set<Id>();
        for(sObject objVar : targetObjectsToInsert) {
          insertedRecordIds.add(objVar.id);
        }

        Map<Id,Id> sourceTargetIdMap = new Map<Id,Id>(); // Map to support Attachment Copy

        // now that we have inserted/updated data we can link the IDs in our translation cache
        for (SourceTargetAssociation sourceTargetLink :sourceTargetLinks)
        {
            translationCache.put(sourceTargetLink.sourceObject.Id,sourceTargetLink.targetObject.Id);
            if (objMapping.Copy_Attachments__c && insertedRecordIds.contains(sourceTargetLink.targetObject.Id)) {
                sourceTargetIdMap.put(sourceTargetLink.sourceObject.Id,sourceTargetLink.targetObject.Id);
            }
        }

        if(sourceTargetIdMap.size() > 0)
        {
            copyAttachments_FutureCall(sourceTargetIdMap);
        }

        // now let's see if we have any child records to deal with
        for (Object_Mapper__mdt objMap :[SELECT source_object__c,target_object__c,source_parent_key_field__c,target_parent_key_field__c,developerName,copy_attachments__c FROM Object_Mapper__mdt WHERE parent_id__c = :objMapping.Id])
        {
            Set<Id> idsToProcessNext = new Set<Id>();
            for(sObject childToProcess :Database.Query('SELECT Id FROM ' + (String) objMap.get(sourceObjectName) + ' WHERE ' + (String) objMap.get(sourceParentKeyField) + ' IN :recordsToCopy'))
            {
                idsToProcessNext.add(childToProcess.Id);
            }

            copy(objMap.developerName,idsToProcessNext);
        }
    }

  /*
  * Method Name: isValidNonEmptyStringVal
  * Description: Purpose to validate string value
  * @param:  String strValue
  * @return: Boolean                                                       
  */
    private static Boolean isValidNonEmptyStringVal(String strValue)
    {
        return (String.isNotBlank(strValue) && !CONST_NULL.equalsIgnoreCase(strValue));
    }

  /*
  * Method Name: addToQuery
  * Description: Purpose to validate string value
  * @param:  String query
  * @param:  String val
  * @return: String                                                       
  */
    private static String addToQuery(String query, String val)
    {
        if (query == 'SELECT ')
            return query + val;
        return query + ',' + val;
    }

    /*
  * Method Name: copyAttachments_FutureCall
  * Description: Purpose : FUTURE METHOD to copy Attachments based on Source-Target Id Map
  * @param:  String query
  * @param : Map<Id,Id> sourceTargetIdMap
  * @return: void                                                       
  */
    @future(callout=true)
    public static void copyAttachments_FutureCall(Map<Id,Id> sourceTargetIdMap )
    {
        List<Attachment> lstAttachment = new List<Attachment>();
        Id targetId = null;
        if(sourceTargetIdMap != null && sourceTargetIdMap.size() > 0)
        {
            Map<Id, List<Attachment>> srcObjWiseAttachment = new Map<Id, List<Attachment>>();
            for(Attachment objAttach : [  SELECT  Name, ParentId, Body
                                            FROM    Attachment
                                            WHERE   ParentId IN :sourceTargetIdMap.keySet() ORDER BY ParentId])
            {
                if(!srcObjWiseAttachment.containsKey(objAttach.ParentId))
                {
                    srcObjWiseAttachment.put(objAttach.ParentId, new List<Attachment>());
                }
                srcObjWiseAttachment.get(objAttach.ParentId).add(objAttach);
            }

            if(srcObjWiseAttachment.size() > 0)
            {
                for(Id srcId : sourceTargetIdMap.keySet())
                {
                    targetId = sourceTargetIdMap.get(srcId);
                    if(targetId != null && srcObjWiseAttachment.containsKey(srcId))
                    {
                        for(Attachment objAttachment : srcObjWiseAttachment.get(srcId))
                        {
                            Attachment attachment = new Attachment();
                            attachment.ParentId = targetId;
                            attachment.Name = objAttachment.Name;
                            attachment.Body = objAttachment.Body;
                            lstAttachment.add(attachment);
                        }
                    }
                }
                try
                {
                    if(lstAttachment.size() > 0)
                    {
                        insert lstAttachment;
                    }
                }
                catch (Exception e)
                {
                      // Do Nothing
                }
                finally
                {
                    lstAttachment  = new List<Attachment>();
                }
            }
        }
    }

    private class SourceTargetAssociation
    { 
        public sObject sourceObject;
        public sObject targetObject;

        public SourceTargetAssociation(sObject s, sObject t)
        {
            sourceObject = s;
            targetObject = t;
        }
    }

  // */
}