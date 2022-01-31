/**
 * @author sachin kadian
 * @email sachin@mtxb2b.com
 * @create date 2019-05-02 11:02:11
 * @modify date 2019-05-02 11:02:11
 * @desc Apex class for gtmSetup LWC component
 */

public without sharing class GTMSetupController {

    // @AuraEnabled(cacheable=true)
    // public static  InitialInfoWrapper getInitialInfo(Id recordId){
    //     InitialInfoWrapper initialInfo = new InitialInfoWrapper();
    //     if(recordId.getSobjectType().getDescribe().fields.getMap().keySet().contains('meeting_id__c')){
            
    //     }else{
    //         throw new AuraHandledException('No field with API Name Meeting_Id__c exist on this object');
    //     }
        
    //     return initialInfo;
    // }
    @AuraEnabled
    public static void createMeeting(EventWrapper eventData) {
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type','application/json');
        String bodyString;
        //if meeting is GTM
        if(eventData.meetingType == 'gtm'){
            req.setEndpoint(Test.isRunningTest() ? 'http://callout.dummyURL/createGTM' : 'callout:GTM/G2M/rest/meetings');
            //create meeting body
            JSONGenerator body = JSON.createGenerator(true);    
            body.writeStartObject();      
            body.writeStringField('subject', eventData.subject);
            body.writeStringField('starttime',eventData.startDateTime);
            body.writeStringField('endtime',eventData.endDateTime);
            body.writeBooleanField('passwordrequired',false);
            body.writeStringField('conferencecallinfo','Free');
            body.writeStringField('timezonekey','');
            body.writeStringField('meetingtype','immediate');
            body.writeEndObject(); 
            bodyString = body.getAsString();
            System.debug('request Body==='+bodyString);
            req.setBody(bodyString);
            Http http = new Http();
            HTTPResponse res = http.send(req);

            if(res.getStatusCode() == 201){
                System.debug(res.getBody());
                List<GTMResponseWrapper> response = (List<GTMResponseWrapper>) JSON.deserialize(res.getBody(), List<GTMResponseWrapper>.class);
                sendGoogleInvite(eventData,false,response[0].meetingid);
            }else if(res.getStatusCode() == 403){
                //GTM api send status code 403 once the token is expired, but named credentials only refresh token if status code is 401
                // So i am just hitting one dummy endpoint which return status code 401 , so that named credentials can refresh itself
                // i know its hacky but its the only way for now ;)
                HttpRequest req1 = new HttpRequest();
                req1.setMethod('POST');
                req1.setHeader('Accept', 'application/json');
                req1.setHeader('Content-Type','application/json');
                req1.setEndpoint(Test.isRunningTest() ? 'http://callout.dummyURL' : 'callout:GTM/oauth/v2/token');
                Http http1 = new Http();
                HTTPResponse res1 = http1.send(req1);
                
                //now named credenails refrehsed the tokan, hit the create end point again
                createMeeting(eventData);
            }else{
                System.debug('Status code --'+res.getStatusCode());
                System.debug('body -- '+res);
                System.debug('body -- '+res.getBody());
                throw new AuraHandledException('Error while creating GTM :'+ res.getBody());
            }
        }else if(eventData.meetingType == 'hm'){ // if it is hangout meeting
            sendGoogleInvite(eventData,true,null);
        }
        

    }

    public class InitialInfoWrapper{
        

    }

    @AuraEnabled
    public static void sendGoogleInvite(EventWrapper eventData,Boolean createHangoutMeet,String meetingId){
        
        HttpRequest req = new HttpRequest();
        GoogleEventInfoWrapper event = new GoogleEventInfoWrapper();
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json'); 
        req.setHeader('Content-Type','application/json');

        if(createHangoutMeet){
            req.setEndpoint(Test.isRunningTest() ? 'http://callout.dummyURL/createHangout' : 'callout:Google_Calendar/calendars/'+'primary'+'/events?sendUpdates=all&conferenceDataVersion=1');
            event.conferenceData = new ConferenceData();
            event.conferenceData.createRequest = new CreateRequest();
            event.conferenceData.createRequest.conferenceSolutionKey = new ConferenceSolutionKey();
            event.conferenceData.createRequest.conferenceSolutionKey.type= 'hangoutsMeet';
            event.conferenceData.createRequest.requestId = 'rew-wres-etr';
        }else{
            req.setEndpoint(Test.isRunningTest() ? 'http://callout.dummyUR/createHangout' : 'callout:Google_Calendar/calendars/'+'primary'+'/events?sendUpdates=all&conferenceDataVersion=0');
        }
        
        
        DateWrapper startDate = new DateWrapper();
        startDate.dateTime1 =  eventData.startDateTime;

        DateWrapper endDate = new DateWrapper();
        endDate.dateTime1 =  eventData.endDateTime;

        event.start = startDate;
        event.end1 = endDate;
        event.summary = eventData.subject;
        String description = eventData.description ;
        if(!createHangoutMeet){
            description += '\n https://global.gotomeeting.com/join/' + meetingId;
        }
        event.description = description;
        
        List<String> listOfAttendees = new List<String>();
        /*if(eventData.attendees != null){
            listOfAttendees = eventData.attendees.split(',');
        } */
        //listOfAttendees.add(UserInfo.getUserEmail());
        listOfAttendees.add([select email from Contact where id=:eventData.recordId ].email);

        event.attendees = new List<AttendeesWrapper>();
        for(String attendeeEmail : listOfAttendees){
            AttendeesWrapper attendee = new AttendeesWrapper();
            attendee.email = attendeeEmail;
            event.attendees.add(attendee);
        }

        req.setBody(JSON.serialize(event).replace('date1','date').replace('end1','end').replace('dateTime1','dateTime'));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if(res.getStatusCode() == 200){
            //create new salesforce event here
            Event newEvent = new Event();
            newEvent.StartDateTime = (DateTime)JSON.deserialize('"' + eventData.startDateTime + '"', DateTime.class); 
            newEvent.EndDateTime = (DateTime)JSON.deserialize('"' + eventData.endDateTime + '"', DateTime.class); 
            newEvent.Subject = eventData.subject;
            newEvent.Description = description;
            newEvent.whoId = eventData.recordId;

            if(createHangoutMeet){
                System.debug(res.getBody());
                GMResponseWrapper response = (GMResponseWrapper) JSON.deserialize(res.getBody(),GMResponseWrapper.Class);
                newEvent.Meeting_Id__c = response.conferenceData.conferenceId;
            }else{
                newEvent.Meeting_Id__c = meetingId;
            }

            try{
                insert newEvent; 
                System.debug(newEvent.Id);
            }catch(Exception e){
                throw new AuraHandledException('Error while creating Event in Salesforce  : '+e.getMessage());
            } 
        }else{
            throw new AuraHandledException('Error while creating Google Meet :'+ res.getBody());
        }
    }

    @AuraEnabled
    public static String startMeeting(Id eventId){
        
        List<Event> listOfEvents = [select id,Meeting_Id__c from Event where whoId=: eventId order by createdDate desc];
        if(listOfEvents != null && listOfEvents.size() > 0 && listOfEvents[0].Meeting_Id__c != null){
             if(listOfEvents[0].Meeting_Id__c.length() == 9){
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(Test.isRunningTest() ? 'http://callout.dummyURL/startGTM' : 'callout:GTM/G2M/rest/meetings/'+listOfEvents[0].Meeting_Id__c+'/start');
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-Type','application/json');
                Http http = new Http();
                HTTPResponse res = http.send(req);
                if(res.getStatusCode() == 200){
                    GTMResponseWrapper response = (GTMResponseWrapper) JSON.deserialize(res.getBody(), GTMResponseWrapper.class);
                    return response.hostURL;
                }else if(res.getStatusCode() == 403){
                    //GTM api send status code 403 once the token is expired, but named credentials only refresh token if status code is 401
                    // So i am just hitting one dummy endpoint which return status code 401 , so that named credentials can refresh itself
                    // i know its hacky but its the only way for now ;)
                    HttpRequest req1 = new HttpRequest();
                    req1.setMethod('POST');
                    req1.setHeader('Accept', 'application/json');
                    req1.setHeader('Content-Type','application/json');
                    req1.setEndpoint(Test.isRunningTest() ? 'http://callout.dummyURL' : 'callout:GTM/oauth/v2/token');
                    Http http1 = new Http();
                    HTTPResponse res1 = http1.send(req1);
                    
                    //now named credenails refrehsed the tokan, hit the create end point again
                    startMeeting(eventId);
                }else{
                    throw new AuraHandledException('Error while starting GTM meeting : '+res.getBody());
                }
            }else{
                return 'https://meet.google.com/'+listOfEvents[0].Meeting_Id__c+'?pli=1&authuser=0';
            } 
            
        }else{
            throw new AuraHandledException('No Meeting id found'); 
        } 
        return null;
    }

    @AuraEnabled
    public static List<AttendeesWrapper> getAttendees(Id eventId){
        /* List<Event> listOfEvents = [select id,Meeting_Id__c from Event where id=: eventId];
        if(listOfEvents != null && listOfEvents.size() > 0 && listOfEvents[0].Meeting_Id__c != null){
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(Test.isRunningTest() ? 'http://callout.dummyURL/getAttendee' : 'callout:GTM/G2M/rest/meetings/'+listOfEvents[0].Meeting_Id__c+'/attendees');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type','application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                System.debug(res.getBody());
                List<AttendeesWrapper> response = (List<AttendeesWrapper>) JSON.deserialize(res.getBody(), List<AttendeesWrapper>.class);
                return response;
            }else{
                throw new AuraHandledException('Error while fetching Attendees : '+res.getBody());
            }
        }else{
            throw new AuraHandledException('No Meeting id found');
        } */
        return null;
    }


    public class GoogleEventInfoWrapper{
        public DateWrapper start;
        public DateWrapper end1;
        public String summary;
        public String description;
        public List<AttendeesWrapper> attendees;
        public ConferenceData conferenceData;
    }

    public class DateWrapper{
        public String date1;
        public String dateTime1;
        public String timeZone;
    }

    Public class AttendeesWrapper{
        @AuraEnabled public String email;
        @AuraEnabled public String attendeeName;
        @AuraEnabled public String attendeeEmail;
        @AuraEnabled public String joinTime;
        @AuraEnabled public String leaveTime;
    }

    Public class ConferenceData{
        public CreateRequest createRequest;
        public String conferenceId;   
    }

    public class CreateRequest{
        public conferenceSolutionKey conferenceSolutionKey;
        public String requestId;
    }

    public class ConferenceSolutionKey{
        public String type;
    }

    public class EventWrapper{
        @AuraEnabled public String recordId{get;set;}
        @AuraEnabled public String subject{get;set;}
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public String startDateTime{get;set;}
        @AuraEnabled public String endDateTime{get;set;}
        @AuraEnabled public String meetingType{get;set;}
        @AuraEnabled public String attendees{get;set;}
    }

    public Class GTMResponseWrapper{
        public String meetingid;
        public String joinURL;
        public String hostURL;
    }

    public Class GMResponseWrapper{
        public ConferenceData conferenceData;
    }
   
}