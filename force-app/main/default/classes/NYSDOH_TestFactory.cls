public class NYSDOH_TestFactory {
    
    //create account
    public static List<Account> createAccount(Boolean doInsert) {
        List<Account> listOfAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Test Account Name';
        listOfAccount.add(account);
        if(doInsert){
            insert listOfAccount;
        }
        return listOfAccount;
    }
    
    //create Volunteer__c    
    public static List<Volunteer__c> createVolunteer(Boolean doInsert) {
        List<Volunteer__c> listOfVolunteer = new List<Volunteer__c>();
        Volunteer__c volunteer = new Volunteer__c();
        volunteer.First_Name__c = 'Volunteer First Name';
        volunteer.Last_Name__c = 'Volunteer Last Name';
        volunteer.County_pick__c = 'Albany';
        volunteer.State__c = 'NY';
        volunteer.City__c = 'NY';
        volunteer.Postal_Code__c= '12203';
        volunteer.Address_Geolocation__Latitude__s = 42.65258;
        volunteer.Address_Geolocation__Longitude__s = -73.75623;
        volunteer.Medical_Profession__c = 'MD';
        listOfVolunteer.add(volunteer);
        
        if(doInsert) {
            insert listOfVolunteer;
        }
        return listOfVolunteer;
    }
    
    //create Volunteer_Assignment__c
    public static List<Volunteer_Assignment__c> createVolunteerAssignment(Id volunteerId,Id accountId, Boolean doInsert) {
        List<Volunteer_Assignment__c> listOfVolunteerAssignment =  new List<Volunteer_Assignment__c>();
        Volunteer_Assignment__c volunteerAssignment = new Volunteer_Assignment__c();
        volunteerAssignment.Volunteer__c = volunteerId;        
        volunteerAssignment.Start_Date__c = System.today();
        volunteerAssignment.End_Date__c = System.today().addDays(2);
        volunteerAssignment.Status__c = 'Requested';
        volunteerAssignment.Account__c = accountId;
        listOfVolunteerAssignment.add(volunteerAssignment);           
        if(doInsert) {
            insert listOfVolunteerAssignment;
        }
        return listOfVolunteerAssignment;
    }
    public static User createUser(String userName,String userEmail,Boolean isInsert){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = userEmail,
            Username = userName,
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        if(isInsert){
            insert u;
        }
        return u;
    }
    public static List<Appointment_Slot__c> createAppointmentSlot(String accountId,Boolean doInsert) {
        List<Appointment_Slot__c> listOfAppointmentSlot = new List<Appointment_Slot__c>();
        Appointment_Slot__c appointmentSlotRec = new Appointment_Slot__c();
        appointmentSlotRec.Account__c = accountId;
        listOfAppointmentSlot.add(appointmentSlotRec);
        
        if(doInsert) {
            insert listOfAppointmentSlot;
        }
        return listOfAppointmentSlot;
    }   
    public static List<Appointment__c> createAppointment(String appointmentSlotId,Boolean doInsert) {
        List<Appointment__c> listOfAppointment = new List<Appointment__c>();
        Appointment__c appointmentRec = new Appointment__c();
        appointmentRec.Appointment_Slot__c = appointmentSlotId;
        
        listOfAppointment.add(appointmentRec);
        
        if(doInsert) {
            insert listOfAppointment;
        }
        return listOfAppointment;
    }
    public static List<Contact> createContact(String accountId,Boolean doInsert) {
        List<Contact> listOfContact = new List<Contact>();
        Contact con = new Contact();
        con.FirstName = 'TestFirst';
        con.LastName = 'TestLast';
        con.AccountId = accountId;
        con.Email = 'testname@mail.com';
        listOfContact.add(con);
        
        if(doInsert) {
            insert listOfContact;
        }
        return listOfContact;
    }
    
    //create Request__c
    public static List<Request__c> createRequest(Id accountId, Boolean doInsert) {
        List<Request__c> listOfRequest = new List<Request__c>();
        Request__c request = new Request__c();
        request.Hospital__c = accountId;
        request.Item_Name__c = 'Test Item';
        request.Quantity__c = 10;
        request.Status__c = 'Pending';
        request.Type__c = 'Water';
        listOfRequest.add(request);
        if(doInsert) {
            insert listOfRequest;
        }
        return listOfRequest;
    }
    
    //create Bid__c
    public static List<Bid__c> createBid(Id requestId,Boolean doInsert) {
        List<Bid__c> listOfBid = new List<Bid__c>();
        Bid__c bid = new Bid__c();
        bid.Bid_Status__c = 'Submitted';
        bid.Amount__c = 10000.00;
        bid.Request__c = requestId;
        listOfBid.add(bid);
        if(doInsert) {
            insert listOfBid;
        }
        return listOfBid;
    }
    
    
}