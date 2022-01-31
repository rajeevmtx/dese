/*
* Class Name:  FormulaInterpretUtility
* Description: A utility class to interpret formulas
* Author/Date: Harshit Jain ,  3/3/2016 
*                                                            
*/
public with sharing class FormulaInterpretUtility {
    
    
    
    public static Map<String, String> parseFormula(String formulaString) {
        Map<String, String> stringLiteralToFormulaValueMap = new Map<String, String>();
        
        if(formulaString != null && formulaString.length() > 0) {
            String fieldValue = formulaString.substringBefore(' ');
            String remainingString = formulaString.substringAfter(' ');
            String operator = remainingString.substringBefore(' ');
            remainingString = remainingString.substringAfter(' ');
            stringLiteralToFormulaValueMap.put('FieldName', fieldValue);
            stringLiteralToFormulaValueMap.put('Operator', operator);
            stringLiteralToFormulaValueMap.put('Value', remainingString);
        }
        /*List<String> subStrings = (formulaString.length() > 0) ? formulaString.split(' ') : new List<String>();
        if(subStrings.size() > 2) {
            stringLiteralToFormulaValueMap.put('FieldName', subStrings[0]);
            stringLiteralToFormulaValueMap.put('Operator', subStrings[1]);
            stringLiteralToFormulaValueMap.put('Value', subStrings[2]);
            
        }*/
        return stringLiteralToFormulaValueMap;
    }
    /*
	* Method Name: checkForRequried
	* Description: check For Requried
	* @return:  Boolean
	* @param:  Application_Content__c appContentRec 
	*/ 
   public static Boolean checkForRequried(Application_Content__c appContentRec) {
        Boolean isConditionallyRequired = false;
        if(appContentRec.Conditionally_Required__c) {
            isConditionallyRequired = true;
            List<String> validationLogicList = appContentRec.Validation_Logic__c.split(' AND ');
            for(String validationStr : validationLogicList) {
                Boolean isRequired = false;
                Map<String, String> stringLiteralToFormulaValueMap = parseFormula(validationStr);
                String fieldName = stringLiteralToFormulaValueMap.get('FieldName');
                String operatorStr = stringLiteralToFormulaValueMap.get('Operator');
                String value = stringLiteralToFormulaValueMap.get('Value');
                
                String objectName;
                String relationshipName;
                String relationshipName2;
                String queryObject;
                if(fieldName.contains('.')) {
                    relationshipName = fieldName.substringBefore('.');
                    if(relationshipName.contains('{') && relationshipName.contains('}')) {
                        queryObject = relationshipName.replace('{', '').replace('}', '');
                        objectName = queryObject;
                    } else if(relationshipName.contains('__r')) {
                        objectName = relationshipName.replace('__r', '__c');
                    }
                    fieldName = fieldName.substringAfter('.');
                    
                    if(fieldName.contains('.')) {
                        relationshipName2 = fieldName.substringBefore('.');
                        fieldName = fieldName.substringAfter('.');
                    }
                    
                } else {
                    objectName = 'Application_Content__c';
                }
                system.debug('----queryObject'+queryObject);
                if(queryObject != null) {
                    isRequired = checkRequiredForSpecialCondition(appContentRec.Contractor_Application__c, queryObject, fieldName, value, operatorStr);
                    
                } else {
                    Schema.DisplayType dataType = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                    Object objValue;
                   
                    if(relationshipName2 != null && appContentRec.getSobject(relationshipName) != null && appContentRec.getSobject(relationshipName).getSobject(relationshipName2) != null) {
                        objValue = appContentRec.getSobject(relationshipName).getSobject(relationshipName2).get(fieldName);
                       } else if(relationshipName != null && appContentRec.getSobject(relationshipName) != null) {
                        objValue = appContentRec.getSobject(relationshipName).get(fieldName);
                    } else {
                        objValue = appContentRec.get(fieldName);
                    }
                    isRequired = checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value);
                }
                
                isConditionallyRequired = isConditionallyRequired && isRequired;
            }
        }
        return isConditionallyRequired;
    }  
    /*
	* Method Name: checkForRequried
	* Description: check For Requried
	* @return:  Boolean
	* @param:  Project_Content__c projContentRec 
	*/
    public static Boolean checkForRequried(Project_Content__c projContentRec) {
        Boolean isConditionallyRequired = false;
        if(projContentRec.Conditionally_Required__c) {
            isConditionallyRequired = true;
            List<String> validationLogicList = projContentRec.Validation_Logic__c.split(' AND ');
            for(String validationStr : validationLogicList) {
                Boolean isRequired = false;
                Map<String, String> stringLiteralToFormulaValueMap = parseFormula(validationStr);
                String fieldName = stringLiteralToFormulaValueMap.get('FieldName');
                String operatorStr = stringLiteralToFormulaValueMap.get('Operator');
                String value = stringLiteralToFormulaValueMap.get('Value');
                
                String objectName;
                String relationshipName;
                String relationshipName2;
                String queryObject;
                if(fieldName.contains('.')) {
                    relationshipName = fieldName.substringBefore('.');
                    if(relationshipName.contains('{') && relationshipName.contains('}')) {
                        queryObject = relationshipName.replace('{', '').replace('}', '');
                        objectName = queryObject;
                    } else if(relationshipName.contains('__r')) {
                        objectName = relationshipName.replace('__r', '__c');
                    }
                    fieldName = fieldName.substringAfter('.');
                    
                    if(fieldName.contains('.')) {
                        relationshipName2 = fieldName.substringBefore('.');
                        fieldName = fieldName.substringAfter('.');
                    }
                    
                } else {
                    objectName = 'Project_Content__c';
                }
                
                if(queryObject != null) {
                    isRequired = checkRequiredForSpecialCondition(projContentRec.Project__c, queryObject, fieldName, value, operatorStr);
                    
                } else {
                    Schema.DisplayType dataType = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                    Object objValue;
                    if(relationshipName2 != null && projContentRec.getSobject(relationshipName) != null && projContentRec.getSobject(relationshipName).getSobject(relationshipName2) != null) {
                        objValue = projContentRec.getSobject(relationshipName).getSobject(relationshipName2).get(fieldName);
                    } else if(relationshipName != null && projContentRec.getSobject(relationshipName) != null) {
                        objValue = projContentRec.getSobject(relationshipName).get(fieldName);
                    } else {
                        objValue = projContentRec.get(fieldName);
                    }
                    isRequired = checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value);
                }
                
                isConditionallyRequired = isConditionallyRequired && isRequired;
            }
        }
        return isConditionallyRequired;
    }
    /*
	* Method Name: checkForRequried
	* Description: check For Requried
	* @return:  Boolean
	* @param:  Case_Content__c caseContentRec
	* @param:  String projectId
	*/
    public static Boolean checkForRequried(Case_Content__c caseContentRec, String projectId) {
        Boolean isConditionallyRequired = false;
        if(caseContentRec.Conditionally_Required__c) {
            isConditionallyRequired = true;
             
            if(caseContentRec.Validation_Logic__c.contains('Project__r')){
                caseContentRec.Validation_Logic__c = caseContentRec.Validation_Logic__c.replace('Project__r', 'Case__r');
            }
            
            List<String> validationLogicList = caseContentRec.Validation_Logic__c.split(' AND ');
            for(String validationStr : validationLogicList) {
                Boolean isRequired = false;
                Map<String, String> stringLiteralToFormulaValueMap = parseFormula(validationStr);
                String fieldName = stringLiteralToFormulaValueMap.get('FieldName');
                String operatorStr = stringLiteralToFormulaValueMap.get('Operator');
                String value = stringLiteralToFormulaValueMap.get('Value');
                
                String objectName;
                String relationshipName;
                String relationshipName2;
                String queryObject;
                if(fieldName.contains('.')) {
                    
                    relationshipName = fieldName.substringBefore('.');
                    if(relationshipName.contains('{') && relationshipName.contains('}')) {
                        queryObject = relationshipName.replace('{', '').replace('}', '');
                        objectName = queryObject;
                    } else if(relationshipName.contains('__r')) {
                        objectName = relationshipName.replace('__r', '__c');
                    }
                    fieldName = fieldName.substringAfter('.');
                    
                    if(fieldName.contains('.')) {
                        relationshipName2 = fieldName.substringBefore('.');
                        fieldName = fieldName.substringAfter('.');
                    }
                    
                } else {
                    objectName = 'Case_Content__c';
                }
                
                if(queryObject != null) {
                    isRequired = checkCaseRequiredForSpecialCondition(caseContentRec.Case__c, projectId, queryObject, fieldName, value, operatorStr);
                    
                } else {
                    if(objectName == 'Case__c' || objectName == 'Case__r'){
                        objectName = 'Case';
                    }
                    Schema.DisplayType dataType = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                    Object objValue;
                    if(relationshipName2 != null && caseContentRec.getSobject(relationshipName) != null && caseContentRec.getSobject(relationshipName).getSobject(relationshipName2) != null) {
                        objValue = caseContentRec.getSobject(relationshipName).getSobject(relationshipName2).get(fieldName);
                    } else if(relationshipName != null && caseContentRec.getSobject(relationshipName) != null) {
                        objValue = caseContentRec.getSobject(relationshipName).get(fieldName);
                    } else {
                        objValue = caseContentRec.get(fieldName);
                    }
                    isRequired = checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value);
                }
                
                isConditionallyRequired = isConditionallyRequired && isRequired;
            }
        }
        return isConditionallyRequired;
    }
    
    /*
	* Method Name: checkForRequried
	* Description: check conditionally required for for Project Deliverables
	* @return:  Boolean
	* @param:  Project_Deliverables__c projContentRec
	*/
    public static Boolean checkForRequried(Project_Deliverables__c projContentRec) {
         return chekForRequired(projContentRec,null);
    }
    /*
	* Method Name: checkForRequried
	* Description: check For Requried
	* @return:  Boolean
	* @param:  Project_Deliverables__c projContentRec
	* @param:  String invoiceId
	*/
    public static Boolean chekForRequired(Project_Deliverables__c projContentRec, String invoiceId){
        Boolean isConditionallyRequired = false;
        if(projContentRec.Conditionally_Required__c) {
            isConditionallyRequired = true;
            List<String> validationLogicList = projContentRec.Validation_Logic__c.split(' AND ');
            for(String validationStr : validationLogicList) {
                Boolean isRequired = false;
                Map<String, String> stringLiteralToFormulaValueMap = parseFormula(validationStr);
                String fieldName = stringLiteralToFormulaValueMap.get('FieldName');
                String operatorStr = stringLiteralToFormulaValueMap.get('Operator');
                String value = stringLiteralToFormulaValueMap.get('Value');
                
                String objectName;
                String relationshipName;
                String relationshipName2;
                String queryObject;
                String childQueryObjectRName;
                String childFieldName;
                if(fieldName.contains('.')) {
                    relationshipName = fieldName.substringBefore('.');
                    if(relationshipName.contains('{') && relationshipName.contains('}')) {
                        queryObject = relationshipName.replace('{', '').replace('}', '');
                        objectName = queryObject;
                    } else if(relationshipName.contains('__r')) {
                        objectName = relationshipName.replace('__r', '__c');
                    }
                    fieldName = fieldName.substringAfter('.');
                    if(queryObject != null){
                        if(fieldName.contains('[') && fieldName.contains(']')){
                            childQueryObjectRName = fieldName.substringBefore('.').replace('[', '').replace(']', '');
                            childFieldName = fieldName.substringAfter('.');
                        }
                    }else if(fieldName.contains('.')) {
                        relationshipName2 = fieldName.substringBefore('.');
                        fieldName = fieldName.substringAfter('.');
                    }
                    
                } else {
                    objectName = 'Project_Deliverables__c';
                }
                
                if(childQueryObjectRName != null){
                    if(invoiceId!=null && invoiceId!= '')
                        isRequired = checkRequiredForSpecialConditionWithChild(projContentRec.Project__c, queryObject, value, operatorStr, childQueryObjectRName, childFieldName,invoiceId);   
                    else
                        isRequired = checkRequiredForSpecialConditionWithChild(projContentRec.Project__c, queryObject, value, operatorStr, childQueryObjectRName, childFieldName);
                }else if(queryObject != null) {
                    isRequired = checkRequiredForSpecialCondition(projContentRec.Project__c, queryObject, fieldName, value, operatorStr);
                } else {
                    Schema.DisplayType dataType = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
                    Object objValue;
                    if(relationshipName2 != null && projContentRec.getSobject(relationshipName) != null && projContentRec.getSobject(relationshipName).getSobject(relationshipName2) != null) {
                        objValue = projContentRec.getSobject(relationshipName).getSobject(relationshipName2).get(fieldName);
                    } else if(relationshipName != null && projContentRec.getSobject(relationshipName) != null) {
                        objValue = projContentRec.getSobject(relationshipName).get(fieldName);
                    } else {
                        objValue = projContentRec.get(fieldName);
                    }
                    isRequired = checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value);
                }
                isConditionallyRequired = isConditionallyRequired && isRequired;
            }
        }
        return isConditionallyRequired;
    }
    
    
    /*
	* Method Name: checkRequiredForSpecialCondition
	* Description: check Required For Special Condition
	* @return:  Boolean
	* @param:  String projectId
	* @param:  String queryObject
	* @param:  String fieldName
	* @param:  String value
	* @param:  String operatorStr
	*/
    private static Boolean checkRequiredForSpecialCondition(String projectId, String queryObject, String fieldName, String value, String operatorStr) {
        Boolean isRequired = false; 
        String query = 'SELECT Id, ' + fieldName + ' FROM ' + queryObject + ' WHERE Project__c =: projectId';
        system.debug('-----'+query);
        List<Sobject> sobjList = Database.query(query);
        
        for(Sobject sobj : sobjList) {
            Schema.DisplayType dataType = Schema.getGlobalDescribe().get(queryObject).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
            Object objValue = sobj.get(fieldName);
            
            if(checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value)) {
                isRequired = true;
                break; 
            }
        }
        return isRequired;
    }
    /*
	* Method Name: checkCaseRequiredForSpecialCondition
	* Description: check Case Required For Special Condition
	* @return:  Boolean
	* @param:  String projectId
	* @param:  String queryObject
	* @param:  String fieldName
	* @param:  String value
	* @param:  String operatorStr
	* @param:  String caseId
	*/
    private static Boolean checkCaseRequiredForSpecialCondition(String caseId, String projectId, String queryObject, String fieldName, String value, String operatorStr) {
        Boolean isRequired = false; 
        
        String query = 'SELECT Id, ' + fieldName + ' FROM ' + queryObject;
        
        if(queryObject == 'Case_Content__c' || queryObject == 'Case_Role__c'){
            query += ' WHERE Case__c =: caseId';
        }else{
            query += ' WHERE Project__c =: projectId';
        }
        
        List<Sobject> sobjList = Database.query(query);
        
        for(Sobject sobj : sobjList) {
            Schema.DisplayType dataType = Schema.getGlobalDescribe().get(queryObject).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
            Object objValue = sobj.get(fieldName);
            
            if(checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value)) {
                isRequired = true;
                break; 
            }
        }
        return isRequired;
    }
    /*
	* Method Name: checkRequiredForSpecialConditionWithChild
	* Description: check Required For Special Condition With Child
	* @return:  Boolean
	* @param:  String projectId
	* @param:  String queryObject
	* @param:  String childField
	* @param:  String value
	* @param:  String operatorStr
	* @param:  String childObjectRelationshipName
	*/
    private static Boolean checkRequiredForSpecialConditionWithChild(String projectId, String queryObject, String value, String operatorStr, String childObjectRelationshipName, String childField) {
       /* Boolean isRequired = false;         
        String query = 'SELECT Id, ' + '( SELECT Id, '+ childField + ' FROM '+ childObjectRelationshipName+ ')' + ' FROM ' + queryObject + ' WHERE Project__c =: projectId';
        System.debug('**'+query);
        List<Sobject> sobjList = Database.query(query);
        
        for(Sobject sobj : sobjList) {
            for(Sobject sobjChild : sobj.getSObjects(childObjectRelationshipName)){
                Schema.DisplayType dataType = sobjChild.getSobjectType().getDescribe().fields.getMap().get(childField).getDescribe().getType();
                Object objValue = sobjChild.get(childField);
                
                if(checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value)) {
                    System.debug('**objValue**'+objValue+'**dataType**'+dataType+'**operatorStr**'+operatorStr+'**value**'+value);
                    isRequired = true;
                    break; 
                }        
            }
        }
        return isRequired;*/
        return checkRequiredForSpecialConditionWithChild(projectId, queryObject, value, operatorStr, childObjectRelationshipName, childField, null);
    }
    
    /*
	* Method Name: checkRequiredForSpecialConditionWithChild
	* Description: check Required For Special Condition With Child
	* @return:  Boolean
	* @param:  String projectId
	* @param:  String queryObject
	* @param:  String childField
	* @param:  String value
	* @param:  String operatorStr
	* @param:  String childObjectRelationshipName
	* @param:  String queryObjectId
	*/
     private static Boolean checkRequiredForSpecialConditionWithChild(String projectId, String queryObject, String value, String operatorStr, String childObjectRelationshipName, String childField, String queryObjectId) {
        Boolean isRequired = false; 
        
        String query = 'SELECT Id, ' + '( SELECT Id, '+ childField + ' FROM '+ childObjectRelationshipName+ ')' + ' FROM ' + queryObject + ' WHERE Project__c =: projectId';
        if(queryObjectId!=null && queryObjectId!= '')
            query += ' AND  id=: queryObjectId';
         
        System.debug('**'+query);
        List<Sobject> sobjList = Database.query(query);
        
        for(Sobject sobj : sobjList) {
            for(Sobject sobjChild : sobj.getSObjects(childObjectRelationshipName)){
                Schema.DisplayType dataType = sobjChild.getSobjectType().getDescribe().fields.getMap().get(childField).getDescribe().getType();
                Object objValue = sobjChild.get(childField);
                
                if(checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), operatorStr, value)) {
                    System.debug('**objValue**'+objValue+'**dataType**'+dataType+'**operatorStr**'+operatorStr+'**value**'+value);
                    isRequired = true;
                    break; 
                }        
            }
        }
        return isRequired;
    }
    
    /*
	* Method Name: checkRequiredForSpecialConditionWithChild
	* Description: check Required For Special Condition With Child
	* @return:  Boolean
	* @param:  Object objValue
	* @param:  String dataType
	* @param:  String value
	* @param:  String operatorStr
	*/
    private static Boolean checkValueBasedOnDataTypes(Object objValue, String dataType, String operatorStr, String value) {
        Boolean isConditionallyRequired = false;
        if(String.valueOf(dataType) == 'STRING' || String.valueOf(dataType) == 'PICKLIST') {
            if(objValue != null && value != null) {
                String fieldValue = String.valueOf(objValue);
                system.debug(operatorStr+'&&'+fieldValue+'&&'+value);
                //fieldValue = '\'' + fieldValue + '\'';
                if(operatorStr == '=' && fieldValue == value) {
                    isConditionallyRequired = true;
                } else if(operatorStr == '<>' && fieldValue != value) {
                    isConditionallyRequired = true;
                } else if(operatorStr == 'contains' && fieldValue.contains(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == 'does_not_contain' && !fieldValue.contains(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == 'equals') {
                    String delimeterStr = value.contains(';') ? ';' : ',' ;
                    if(value.contains(delimeterStr)) {
                        List<String> values = value.split(delimeterStr);
                        for(String valueStr : values) {
                            if(valueStr == fieldValue) {
                                isConditionallyRequired = true;
                                break;
                            }
                        }
                    } else if(value == fieldValue) {
                        isConditionallyRequired = true;
                    }
                } 
            }
        }
        
        else if(String.valueOf(dataType) == 'DOUBLE' || String.valueOf(dataType) == 'PERCENT' || String.valueOf(dataType) == 'CURRENCY') {
            if(objValue != null && value != null) {
                Decimal fieldValue = Decimal.valueOf(String.valueOf(objValue));
                if(operatorStr == '=' && fieldValue == Decimal.valueOf(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == '<>' && fieldValue != Decimal.valueOf(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == '>' && fieldValue > Decimal.valueOf(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == '>=' && fieldValue >= Decimal.valueOf(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == '<' && fieldValue < Decimal.valueOf(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == '<=' && fieldValue <= Decimal.valueOf(value)) {
                    isConditionallyRequired = true;
                }
            }
        } 
        
        else if(String.valueOf(dataType) == 'BOOLEAN') {
            if(objValue != null && value != null) {
                Boolean fieldValue = Boolean.valueOf(String.valueOf(objValue));
                if(operatorStr == '=' && fieldValue == Boolean.valueOf(value)) {
                    isConditionallyRequired = true;
                } else if(operatorStr == '<>' && fieldValue != Boolean.valueOf(value)) {
                    isConditionallyRequired = true;
                } 
            }
        }
        
        return isConditionallyRequired;
    }
    
    /*
	* Method Name: breakAllConditions
	* Description: break All Conditions
	* @return:  List<String>
	* @param:  String validationLogicString
	*/
    private static List<String> breakAllConditions(String validationLogicString) {
        List<String> validationLogicList = new List<String>();
        validationLogicList = validationLogicString.split(' AND '); 
        return validationLogicList; 
    }
    
    /*
	* Method Name: checkForRequried1
	* Description: check For Requried
	* @return:  Boolean
	* @param:  SObject sobjectRec
	*/
    public static Boolean checkForRequried1(SObject sobjectRec) {
        Boolean isConditionallyRequired = false;
        if(sobjectRec.get('Conditionally_Required__c') != null && Boolean.valueOf(sobjectRec.get('Conditionally_Required__c'))) {
            isConditionallyRequired = true;
            //added by pankaj
            List<String> fullLogicList = String.valueOf(sobjectRec.get('Validation_Logic__c')).split(' OR ');
            for(String validationLogic : fullLogicList){
                isConditionallyRequired = processANDValidationLogicString(sobjectRec,validationLogic);
                if(isConditionallyRequired)break;
            }
        }
        return isConditionallyRequired;
    }
    
    /*
	* Method Name: processANDValidationLogicString
	* Description: process AND Validation Logic String (created by pankaj)
	* @return:  Boolean
	* @param:  SObject sobjectRec
	* @param:  String andValidationString
	*/
    
    public static Boolean processANDValidationLogicString(SObject sobjectRec, String andValidationString){
        Boolean isConditionallyRequired = true;
        List<String> validationLogicList = breakAllConditions(andValidationString);        
        for(String validationStr : validationLogicList) {
            Boolean isRequired = false;
            Map<String, String> stringLiteralToFormulaValueMap = parseFormula(validationStr);
            String conditionFieldName = stringLiteralToFormulaValueMap.get('FieldName');
            String conditionOperatorStr = stringLiteralToFormulaValueMap.get('Operator');
            String conditionFieldValue = stringLiteralToFormulaValueMap.get('Value');
            
            String objectName;
            String parentRelationshipName;
            String parentRelationshipName2;
            String siblingObject;
            
            if(conditionFieldName.contains('.')) {
                parentRelationshipName = conditionFieldName.substringBefore('.');
                if(parentRelationshipName.contains('{') && parentRelationshipName.contains('}')) {
                    siblingObject = parentRelationshipName.replace('{', '').replace('}', '');
                    objectName = siblingObject;
                } else if(parentRelationshipName.contains('__r')) {
                    objectName = parentRelationshipName.replace('__r', '__c');
                }
                conditionFieldName = conditionFieldName.substringAfter('.');
                
                if(conditionFieldName.contains('.')) {
                    parentRelationshipName2 = conditionFieldName.substringBefore('.');
                    conditionFieldName = conditionFieldName.substringAfter('.');
                }
            } else {
                String recordId = String.valueOf(sobjectRec.get('Id'));
                if(recordId != null) {
                    objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
                }
            }
            
            if(siblingObject != null) {
                String projectId = String.valueOf(sobjectRec.get('Project__c'));
                isRequired = checkRequiredForSpecialCondition(projectId, siblingObject, conditionFieldName, conditionFieldValue, conditionOperatorStr);
            } else {
                Schema.DisplayType dataType = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(conditionFieldName).getDescribe().getType();
                Object objValue;
                if(parentRelationshipName2 != null && sobjectRec.getSobject(parentRelationshipName2) != null && sobjectRec.getSobject(parentRelationshipName2).getSobject(parentRelationshipName) != null) {
                    objValue = sobjectRec.getSobject(parentRelationshipName2).getSobject(parentRelationshipName).get(conditionFieldName);
                } else if(parentRelationshipName != null && sobjectRec.getSobject(parentRelationshipName) != null) {
                    objValue = sobjectRec.getSobject(parentRelationshipName).get(conditionFieldName);
                } else {
                    objValue = sobjectRec.get(conditionFieldName);
                }
                isRequired = checkValueBasedOnDataTypes(objValue, String.valueOf(dataType), conditionOperatorStr, conditionFieldValue);
                
            }
            isConditionallyRequired = isConditionallyRequired && isRequired;
        }
        return isConditionallyRequired;
    }
    /*
	* Method Name: convertConditionOfProjectContents
	* Description: convert Condition Of Project Contents
	* @return:  Boolean
	* @param:  List<Case_Content__c> caseContentList
	*/
    public static List<Case_Content__c> convertConditionOfProjectContents(List<Case_Content__c> caseContentList) {
    	for(Case_Content__c caseContentRec : caseContentList) {
    		if(caseContentRec.Conditionally_Required__c && caseContentRec.Validation_Logic__c != null) {
    			if(caseContentRec.Validation_Logic__c.toLowerCase().contains('{project_site__r}')) {
    				caseContentRec.Validation_Logic__c = null;
    				caseContentRec.Conditionally_Required__c = false;
    				caseContentRec.Document_Criteria_Met__c = false;
    				caseContentRec.Mandatory_by_default__c = true;
    			} else if(caseContentRec.Validation_Logic__c.toLowerCase().contains('project__r')) {
    				caseContentRec.Validation_Logic__c = caseContentRec.Validation_Logic__c.replaceAll('Project__r', 'Case__r');
    			}
    		}
    	}
    	return caseContentList;
    }
}