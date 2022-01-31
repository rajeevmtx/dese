public class nysdohSmsVerificationController {
    
    @AuraEnabled(cacheable=true)
    public static void processSms(String phNumber, String smsBody){
        errorResponseWrapper erw;
        String accountSid = 'ACfcf8783ea03920de9eaa85cb3bf56857';
        string token = '41bcef668ddb5fe235ddf15f4963d980';
        String fromPhNumber = '+12074176391';
        
        smsBody = 'Your OTP For Verification : ' + smsBody;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/'+accountSid+'/SMS/Messages.json');
        req.setMethod('POST');
        String VERSION  = '3.2.0';
        req.setHeader('X-Twilio-Client', 'salesforce-' + VERSION);
        req.setHeader('User-Agent', 'twilio-salesforce/' + VERSION);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Accept-Charset', 'utf-8');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
        req.setBody('To='+EncodingUtil.urlEncode(phNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(fromPhNumber,'UTF-8')+'&Body='+smsBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        if(res.getStatusCode()==201) 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'SMS Sent Successfully'));
        else{   
            erw =(errorResponseWrapper)json.deserialize(res.getBody(),errorResponseWrapper.class);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,erw.message));
        }
    }
    public void sendEmail(String Email,String body){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        if (Email != null) {
            // Step 1: Create a new Email
            Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
            // Set list of people who should get the email
            List<String> sendTo = new List<String>();
            sendTo.add(Email);
            mail.setToAddresses(sendTo);
            
            mail.setSubject('OTP Verification');
            mail.setHtmlBody(body);
            
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    
    public class errorResponseWrapper{
        String code;        
        String message;  
        String moreInfo;
        String status;    
    }
    

}