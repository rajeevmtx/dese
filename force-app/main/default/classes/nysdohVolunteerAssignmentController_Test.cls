@isTest
public class nysdohVolunteerAssignmentController_Test {

    @isTest
    static void createVolunteerAssignment() {
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);
        List<Volunteer__c> volunteerList = NYSDOH_TestFactory.createVolunteer(true);
        List<Volunteer_Assignment__c> volunteerAssignmentList = NYSDOH_TestFactory.createVolunteerAssignment(volunteerList[0].Id,accountList[0].Id, true);
        nysdohVolunteerAssignmentController.getVolunteerAssignments();
        
        
        List<Volunteer__c> forAssertion = [SELECT First_Name__c, Last_Name__c FROM Volunteer__c WHERE Id =: volunteerList[0].Id];
        List<Volunteer_Assignment__c> assertWithVolunteer = [SELECT Volunteer__r.First_Name__c, Volunteer__r.Last_Name__c, Start_Date__c, End_Date__c, Status__c FROM Volunteer_Assignment__c WHERE Volunteer__c =: volunteerList[0].Id];
        System.assertEquals(assertWithVolunteer[0].Status__c, 'Requested','Expected Request as Status');        
        System.assertEquals(assertWithVolunteer[0].Start_Date__c, System.today(),'Expected same date');        
    }
}