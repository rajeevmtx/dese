/*
* Class Name: DC_VolunteerMassCreation
* Created By: Hitesh Yadav
*/
public without sharing class DC_VolunteerMassCreation {
    
	public static final string STATUS = 'Requested';
    
    /*
    * Method Name: createVolunteerAssignment
    * Description: Method to create assignments for Volunteers
    * @param: List<String> volunteerIds, String data
    * @return null
    */
    @AuraEnabled
    public static InitialWrapper getInitialDetail(){
        User u = [select Id, contactId from User where Id =: UserInfo.getUserId()];
		Contact contact = [Select Id, AccountId,Account.Name from Contact where Id =: u.contactId LIMIT 1];
            
        List<ShiftWrapper> shiftWrapperList = new List<ShiftWrapper>();
        
        String objectName = 'Volunteer_Assignment__c';
        String fieldName ='Shift_Type__c';
          
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
    		System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            ShiftWrapper shiftWrapper = new ShiftWrapper(pickListVal);
            shiftWrapperList.add(shiftWrapper);
		}   
        
        InitialWrapper initwrapper = new InitialWrapper(shiftWrapperList,contact);
        return initwrapper;
    }
    
    /*
    * Method Name: createVolunteerAssignment
    * Description: Method to create assignments for Volunteers
    * @param: List<String> volunteerIds, String data
    * @return null
    */
    @AuraEnabled
    public static void createVolunteerAssignment(String volunteers,String shift,Date startDate,Date endDate){
        System.debug('volunteers--->'+volunteers+'____'+'shift-->'+shift+'____'+'startDate--->'+startDate+'___'+'endDate--->'+endDate);
        
        List<String> volunteerIds = volunteers.split(',');
        System.debug('volunteerIds--->'+volunteerIds);
        
        // Fetching Account Information
        User u = [select Id, contactId from User where Id =: UserInfo.getUserId()];
		Contact contact = [Select Id, AccountId,Account.Name from Contact where Id =: u.contactId LIMIT 1];
        
        List<Volunteer_Assignment__c> volunteerAssgnList = new List<Volunteer_Assignment__c>();
        
        for(Volunteer__c volunteer : [SELECT Id FROM Volunteer__c where Id IN: volunteerIds]){
            Volunteer_Assignment__c assignment = new Volunteer_Assignment__c();
            assignment.Account__c = contact.AccountId;
            assignment.Volunteer__c = volunteer.Id;
            assignment.Status__c = STATUS;
            assignment.Start_Date__c = startDate;
            assignment.End_Date__c = endDate;
            assignment.Shift_Type__c = shift;
            volunteerAssgnList.add(assignment);
        }
        System.debug('volunteerAssgnList--->'+volunteerAssgnList);
        if(volunteerAssgnList.size() > 0){
            insert volunteerAssgnList;
        }
        
    }
    
    public class InitialWrapper{
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public List<ShiftWrapper> shift;
        @AuraEnabled public String accountName;
        
        public InitialWrapper (List<ShiftWrapper> shiftList, Contact contact){
            startDate = Date.today();
            endDate = Date.today();
            shift = shiftList;
            accountName = contact.Account.Name;
        }
    }
    
    public class ShiftWrapper{
    
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public ShiftWrapper(Schema.PicklistEntry pickListVal){
            label = pickListVal.getLabel();
            value = pickListVal.getValue();
        }
    }

}