public with sharing class nysdohVolunteerAssignmentController {
    @AuraEnabled(cacheable=true)
    public static List<VolunteerAssignmentWrapper> getVolunteerAssignments() {
        List<VolunteerAssignmentWrapper> volunteerAssignmentWrapperList = new List<VolunteerAssignmentWrapper>();
        for(Volunteer_Assignment__c vol : [SELECT Id, Volunteer__r.First_Name__c, Volunteer__r.Last_Name__c, Start_Date__c, End_Date__c, Status__c FROM Volunteer_Assignment__c]){
            System.debug('in>>>>>>..');
            VolunteerAssignmentWrapper volWrap = new VolunteerAssignmentWrapper();
            volWrap.volunteerName = vol.Volunteer__r.First_Name__c + ' ' + vol.Volunteer__r.Last_Name__c;
            volWrap.startDate = vol.Start_Date__c;
            volWrap.endDate = vol.End_Date__c;
            volWrap.status = vol.Status__c;
            volunteerAssignmentWrapperList.add(volWrap);
        }
        System.debug('volunteerAssignmentWrapperList>'+volunteerAssignmentWrapperList);
        return volunteerAssignmentWrapperList;
    }
    public class VolunteerAssignmentWrapper{
        @AuraEnabled public String volunteerName;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String status;
        public VolunteerAssignmentWrapper(){
            this.volunteerName = '';
            this.status = ''; 
        }
    }
}