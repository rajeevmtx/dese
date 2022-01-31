/**
 * Created by arunm on 21-03-2020.
 */

public with sharing class VolunteerController {

    @AuraEnabled
    public static list<Volunteer> getVolunteers(){
        List<Volunteer> volunteerWrappers = new List<Volunteer>();
        List<Volunteer__c> volunteers = [Select Id, First_Name__c, Last_Name__c, State__c, Street_Address__c, City__c,
            Country__c, Postal_Code__c, Address_Geolocation__Latitude__s, Address_Geolocation__Longitude__s
            FROM Volunteer__c LIMIT 100];

        for(Volunteer__c volunteer : volunteers){
            VolunteerLocation volunteerLocationWrapper = new VolunteerLocation();
            volunteerLocationWrapper.Latitude = volunteer.Address_Geolocation__Latitude__s;
            volunteerLocationWrapper.Longitude = volunteer.Address_Geolocation__Longitude__s;

            Volunteer volunteerWrapper = new Volunteer();
            volunteerWrapper.icon = 'utility:location';
            volunteerWrapper.title = volunteer.First_Name__c + ' ' + volunteer.Last_Name__c;
            volunteerWrapper.location = volunteerLocationWrapper;

            volunteerWrappers.add(volunteerWrapper);
        }
        return volunteerWrappers;
    }

    public class Volunteer {
        @AuraEnabled public String icon {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public VolunteerLocation location {get; set;}
    }

    public class VolunteerLocation {
        @AuraEnabled public String Street {get; set;}
        @AuraEnabled public String PostalCode {get; set;}
        @AuraEnabled public String City {get; set;}
        @AuraEnabled public String State {get; set;}
        @AuraEnabled public String Country {get; set;}
        @AuraEnabled public Decimal Latitude {get; set;}
        @AuraEnabled public Decimal Longitude {get; set;}
    }

}