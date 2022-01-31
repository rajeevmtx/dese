@isTest
public class NYSDOH_VolunteerController_Test {

    @isTest
    static void getVolunteers() {
        List<Volunteer__c> volunteerList = NYSDOH_TestFactory.createVolunteer(true);
        NYSDOH_VolunteerController.getVolunteers(volunteerList[0].County_pick__c, volunteerList[0].Medical_Profession__c, null, null);
        
        List<Volunteer__c> forAssertion = [SELECT County_pick__c, Medical_Profession__c FROM Volunteer__c WHERE Id =: volunteerList[0].Id];
        System.assertEquals('Albany', forAssertion[0].County_pick__c, 'Expected Albany for County');
        System.assertEquals('MD', forAssertion[0].Medical_Profession__c, 'Expected MD as medical profession');
    }

    @isTest
    static void createVolunteerAssignment() {
        List<Account> accountList = NYSDOH_TestFactory.createAccount(true);
        List<Volunteer__c> volunteerList = NYSDOH_TestFactory.createVolunteer(true);
        List<Volunteer_Assignment__c> volunteerAssignmentList = NYSDOH_TestFactory.createVolunteerAssignment(volunteerList[0].Id,accountList[0].Id, true);
        NYSDOH_VolunteerController.getVolunteerAssignments();

        List<Volunteer__c> forAssertion = [SELECT First_Name__c, Last_Name__c FROM Volunteer__c WHERE Id =: volunteerList[0].Id];
        List<Volunteer_Assignment__c> assertWithVolunteer = [SELECT Volunteer__r.First_Name__c, Volunteer__r.Last_Name__c, Start_Date__c, End_Date__c, Status__c FROM Volunteer_Assignment__c WHERE Volunteer__c =: volunteerList[0].Id];
        System.assertEquals(assertWithVolunteer[0].Status__c, 'Requested','Expected Request as Status');
        System.assertEquals(assertWithVolunteer[0].Start_Date__c, System.today(),'Expected same date');
    }
}