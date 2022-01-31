/**
 * Created by arunm on 21-03-2020.
 */

public without sharing class NYSDOH_VolunteerController {

    @AuraEnabled
    public static Volunteer_Assignment__c updateAssignmentStatus(Id volunteerAssignmentId, Boolean status) {
        Volunteer_Assignment__c volunteerAssignment = [SELECT  Id, Status__c FROM Volunteer_Assignment__c WHERE Id=:volunteerAssignmentId];
        volunteerAssignment.Status__c = 'Rejected';
        if(status) {
            volunteerAssignment.Status__c = 'Pending';
        }
        update volunteerAssignment;
        return volunteerAssignment;
    }

    @AuraEnabled
    public static List<VolunteerAssignmentWrapper> getVolunteerAssignments() {
        List<VolunteerAssignmentWrapper> volunteerAssignmentWrappers = new List<VolunteerAssignmentWrapper>();

        User currentUser = NYSDOH_RequestController.getCurrentUser();
        Id accountId = currentUser.AccountId;
        Id contactId = currentUser.ContactId;

        String volunteerAssignmentQuery = 'SELECT Id, Account__c, Account__r.Name, Account__r.BillingStreet, Shift_Type__c, Volunteer__r.First_Name__c, ';
        volunteerAssignmentQuery += 'Volunteer__c, Volunteer__r.Contact__c, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, ';
        volunteerAssignmentQuery += 'Volunteer__r.Last_Name__c, Start_Date__c, End_Date__c, Status__c FROM Volunteer_Assignment__c ';

        if(currentUser.Profile.Name  == 'DOH Hospital User') {
            volunteerAssignmentQuery += 'WHERE Account__c =:accountId';
        }
        else if(currentUser.Profile.Name  == 'DOH Volunteer User') {
            volunteerAssignmentQuery += 'WHERE Volunteer__r.Contact__c =:contactId';
        }

        List<Volunteer_Assignment__c> volunteerAssignments = Database.query(volunteerAssignmentQuery);
        for(Volunteer_Assignment__c volunteerAssignment : volunteerAssignments){
            String hospitalAddress = '';
            if(volunteerAssignment.Account__r.BillingStreet != null) {
                hospitalAddress += volunteerAssignment.Account__r.BillingStreet + '\n';
            }
            if(volunteerAssignment.Account__r.BillingCity != null) {
                hospitalAddress += volunteerAssignment.Account__r.BillingCity + ', ';
            }
            if(volunteerAssignment.Account__r.BillingState != null) {
                hospitalAddress += volunteerAssignment.Account__r.BillingState + ', ';
            }
            if(volunteerAssignment.Account__r.BillingPostalCode != null) {
                hospitalAddress += volunteerAssignment.Account__r.BillingPostalCode;
            }
            VolunteerAssignmentWrapper volunteerAssignmentWrapper = new VolunteerAssignmentWrapper();
            volunteerAssignmentWrapper.Id = volunteerAssignment.Id;
            volunteerAssignmentWrapper.volunteerId = volunteerAssignment.Volunteer__c;
            volunteerAssignmentWrapper.volunteerName = volunteerAssignment.Volunteer__r.First_Name__c + ' ' + volunteerAssignment.Volunteer__r.Last_Name__c;
            volunteerAssignmentWrapper.hospitalName = volunteerAssignment.Account__r.Name;
            volunteerAssignmentWrapper.hospitalAddress = hospitalAddress;
            volunteerAssignmentWrapper.startDate = volunteerAssignment.Start_Date__c;
            volunteerAssignmentWrapper.endDate = volunteerAssignment.End_Date__c;
            volunteerAssignmentWrapper.status = volunteerAssignment.Status__c;
            volunteerAssignmentWrapper.shiftType = volunteerAssignment.Shift_Type__c;
            volunteerAssignmentWrappers.add(volunteerAssignmentWrapper);
        }
        return volunteerAssignmentWrappers;
    }

    @AuraEnabled
    public static List<Volunteer> getVolunteers(String county, String fieldService, String status, String speciality){
        List<Volunteer> volunteerWrappers = new List<Volunteer>();
        String volunteerQuery = 'Select Id, First_Name__c, County_pick__c, Last_Name__c, State__c, Street_Address__c, ';
        volunteerQuery += 'City__c, Country__c, Postal_Code__c, Address_Geolocation__Latitude__s, Address_Geolocation__Longitude__s, ';
        volunteerQuery += 'Medical_Profession__c FROM Volunteer__c';

        List<Volunteer__c> volunteers = Database.query(volunteerQuery);

        for(Volunteer__c volunteer : volunteers){
            VolunteerLocation volunteerLocationWrapper = new VolunteerLocation();
            volunteerLocationWrapper.Latitude = volunteer.Address_Geolocation__Latitude__s;
            volunteerLocationWrapper.Longitude = volunteer.Address_Geolocation__Longitude__s;
            volunteerLocationWrapper.County = volunteer.County_pick__c;

            Volunteer volunteerWrapper = new Volunteer();
            volunteerWrapper.icon = 'utility:location';
            //volunteerWrapper.title = volunteer.First_Name__c + ' ' + volunteer.Last_Name__c;
            volunteerWrapper.fieldService = volunteer.Medical_Profession__c;
            volunteerWrapper.location = volunteerLocationWrapper;

            volunteerWrappers.add(volunteerWrapper);
        }
        return volunteerWrappers;
    }

    public class Volunteer {
        @AuraEnabled public String icon {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String fieldService {get; set;}
        @AuraEnabled public VolunteerLocation location {get; set;}
    }

    public class VolunteerLocation {
        @AuraEnabled public String County {get; set;}
        @AuraEnabled public String Street {get; set;}
        @AuraEnabled public String PostalCode {get; set;}
        @AuraEnabled public String City {get; set;}
        @AuraEnabled public String State {get; set;}
        @AuraEnabled public String Country {get; set;}
        @AuraEnabled public Decimal Latitude {get; set;}
        @AuraEnabled public Decimal Longitude {get; set;}
    }

    public class VolunteerAssignmentWrapper {

        @AuraEnabled public String Id;
        @AuraEnabled public String volunteerId;
        @AuraEnabled public String volunteerName;
        @AuraEnabled public String hospitalName;
        @AuraEnabled public String hospitalAddress;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String status;
        @AuraEnabled public String shiftType;

        public VolunteerAssignmentWrapper(){
            this.volunteerName = '';
            this.status = '';
        }
    }

}