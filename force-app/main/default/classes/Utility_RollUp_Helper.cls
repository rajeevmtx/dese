/*
* 	Class Name: Utility_RollUp_Helper
* 	Description: Utility Class to roll up fields from a child to a parent
*
* 	Author/Date: George Acker/May 12, 2016	
*                        
*/
public without sharing class Utility_RollUp_Helper
{

    /*
	* Method Name: rollUpNumerics
	* Description: roll up data from sub-objects to parent objects - Only pass numeric field types
	* @param: sObject[] records
	* @param: Map<Id,sObject> oldMap
	* @param: String sObjectName
	* @param: String[] sObjectFields
	* @param: String parentFieldName
	* @return: void                                                       
	*/
    public static void rollUpNumerics(sObject[] records, Map<Id,sObject> oldMap, String sObjectName, String[] sObjectFields, String parentFieldName)
    {
        parentFieldName = String.escapeSingleQuotes(parentFieldName);
        sObjectName = String.escapeSingleQuotes(sObjectName);
        Set<Id> parentIds = new Set<Id>();
        for (sObject record :records)
        {
            if (record.get(parentFieldName) != null)
            {
                boolean shouldRecalculateParent = false;
                boolean shouldRecalculateOldParent = false;
                for (String sObjectField :sObjectFields)
                {
                    Decimal fldVal = (Decimal) record.get(sObjectField);
                    if ((oldMap == null && fldVal != null && fldVal > 0) || (oldMap != null && ((Decimal) oldMap.get(record.Id).get(sObjectField) != fldVal 
						 || (Boolean) record.get('Is_Active__c') != (Boolean) oldMap.get(record.Id).get('Is_Active__c'))))
                    {
                        shouldRecalculateParent = true;
                        if (oldMap != null)
                            shouldRecalculateOldParent = true;
                        break;
                    }
                }
                if (shouldRecalculateParent)
                {
                    parentIds.add((Id) record.get(parentFieldName));
                }
                if (shouldRecalculateOldParent)
                {
                    parentIds.add((Id) oldMap.get(record.Id).get(parentFieldName));
                }
            }
        }
        
        if (parentIds.size() > 0)
        {
            String soqlAggregateQuery = 'SELECT ' + parentFieldName;
            for (String sObjectField :sObjectFields)
            {
                soqlAggregateQuery += ',SUM(' + String.escapeSingleQuotes(sObjectField) + ')';
            }
            soqlAggregateQuery += ' FROM ' + sObjectName + ' WHERE ' + parentFieldName + ' IN :parentIds AND Is_Active__c = true GROUP BY ' + parentFieldName;
            system.debug('---------'+soqlAggregateQuery);
            AggregateResult[] parentAggregates = Database.Query(soqlAggregateQuery);
            
            sObject[] parents = new sObject[]{};
            for (AggregateResult pa :parentAggregates)
            {
                Id parentId = (Id) pa.get(parentFieldName);
                if (parentId != null)
                {
                    sObject record = Utility_Describe.globalDescribe.get(sObjectName).newSObject();
                    record.Id = parentId;
                    for (integer i=0; i<sObjectFields.size(); i++)
                    {
                        record.put(sObjectFields[i], (decimal) pa.get('expr' + i));
                    }
                    parents.add(record);
                }
            }
            if (parents.size() > 0)
                update parents;
        }
    }
}