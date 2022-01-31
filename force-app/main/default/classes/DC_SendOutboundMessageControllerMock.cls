@isTest
global class DC_SendOutboundMessageControllerMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        //  response.setHeader('Content-Type', 'application/json');
        response.setBody('[contentType=application/json; charset=utf-8, errorMessage=null, httpStatus=201, parser=TwilioJsonParser:  [OriginalJson={"sid": "SMe9b6481adeb6451cba27206dc8831ce1", "date_created": "Mon, 16 Mar 2020 13:59:59 +0000","date_updated": "Mon, 16 Mar 2020 13:59:59 +0000", "date_sent": null, "account_sid": "AC10038fdf5235c774f140a6c76c68323a"}]]');
        response.setStatus('OK');
        response.setStatusCode(200);
        return response; 
    }
}