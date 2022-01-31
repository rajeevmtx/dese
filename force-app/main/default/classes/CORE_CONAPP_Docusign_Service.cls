/*
* Class Name: CORE_CONAPP_Docusign_Service
* Description: Service class to handle the functionalities related to signning and docusign
*
*/

global without sharing class CORE_CONAPP_Docusign_Service{

    global static boolean isPayee;
    public static Boolean isAsyncCall = false; //#T-01286

    /*
    * Method Name: getSiginingUrl
    * Description: Method to get signning URL
    * @param:  appId as String
    * @param:  domainURL as String
    * @param:  pdfPageName as String
    * @param:  retURLPageName as String
    * @return: String
    */
    global static String getSiginingUrl(String appId, String domainURL,
                                        String pdfPageName, String retURLPageName){

        Docusign_Configuration__c docusignConfig = Docusign_Configuration__c.getInstance();

        String integratorKey = docusignConfig.Integrator_Key__c; // integrator key (found on Preferences -> API page)
        String username = docusignConfig.User_Name__c; // account email (or your API userId)
        String password = docusignConfig.Password__c; // account password
        //------------------------------------------------------------------------------------

        // construct the DocuSign authentication header
        String authenticationHeader =
                    '<DocuSignCredentials>' +
                        '<Username>' + username + '</Username>' +
                        '<Password>' + password + '</Password>' +
                        '<IntegratorKey>' + integratorKey + '</IntegratorKey>' +
                    '</DocuSignCredentials>';

        //============================================================================
        // STEP 1 - Make the Login API call to retrieve your baseUrl and accountId
        //============================================================================

        String url = docusignConfig.Docusign_URL__c + '/restapi/v2/login_information';
        String body = '';   // no request body for the login call

        HttpRequest request = new HttpRequest();

        request.setEndpoint(url);

        request.setMethod('GET');
        request.setHeader('X-DocuSign-Authentication', authenticationHeader);
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/xml');

        http h = new http();

        HttpResponse response = new HttpResponse();

        Dom.Document doc;

        if(!Test.isRunningTest()){
            response = h.send(request);

            doc = response.getBodyDocument();
        }else{

            doc = new Dom.Document();
            doc.load('<loginInformation xmlns="http://www.docusign.com/restapi" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><loginAccounts><loginAccount><accountId>35840759</accountId><baseUrl>https://na2.docusign.net/restapi/v2/accounts/35840759</baseUrl><email>Dan.Quickenton@nyserda.ny.gov</email><isDefault>true</isDefault><name>Carahsoft obo New York State Energy Research and Development Authority</name><siteDescription/><userId>cab2563c-3170-4b71-954c-ca7922fa9a02</userId><userName>Dan Quickenton</userName></loginAccount></loginAccounts></loginInformation>');
        }

        String baseUrl = '';

        String accountId = '';

        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {

          if(node.getName() == 'loginAccounts') {

             for(dom.XmlNode node1 : node.getChildElements()) {

                if(node1.getName() == 'loginAccount') {

                    for(dom.XmlNode node2 : node1.getChildElements()) {

                        if(node2.getName() == 'accountId') {

                            accountId = node2.getText();
                        }

                        if(node2.getName() == 'baseUrl') {

                            baseUrl = node2.getText();
                        }
                    }
                }
             }
           }
        }

        //============================================================================
        // STEP 2 - Signature Request from Template API Call
        //============================================================================

        url = baseURL + '/envelopes';   // append '/envelopes' to baseUrl for signature request call

        String pdfPageUrl = '/apex/' + pdfPageName + '?ApplicationId=' + appId;

        if(isPayee != null && isPayee){
            pdfPageUrl += '&type=payee';
        }

        PageReference pg = new PageReference(pdfPageUrl);

        String signerName = '';

        String signerEmail = '';

        for(Application_Content__c appContent : [SELECT Customer_First_Name__c, Customer_Last_Name__c, Email__c
                                                 FROM Application_Content__c WHERE Contractor_Application__c =: appId
                                                 AND Type__c = 'Primary Contact' LIMIT 1]){


           if(appContent.Customer_First_Name__c != null && appContent.Customer_First_Name__c != ''){

               signerName += appContent.Customer_First_Name__c;
           }

           if(appContent.Customer_Last_Name__c != null && appContent.Customer_Last_Name__c != ''){

               signerName += ' ' + appContent.Customer_Last_Name__c;
           }

           if(signerName.contains('&')){   //
                signerName = signerName.replace('&','And');
            }

           signerEmail = appContent.Email__c;

        }

        // this example uses XML formatted requests, JSON format is also accepted
        body =  '<envelopeDefinition xmlns=\'http://www.docusign.com/restapi\'>' +
                '<emailSubject>Application Review Document: ' + appId + '</emailSubject>' +
                '<documents><document><name>Application Review Document</name><documentId>1</documentId>';

        if(!Test.isRunningTest()){

            body += '<documentBase64>' + EncodingUtil.base64Encode(pg.getContentAsPDF()) + '</documentBase64>';
        }

        body += '</document></documents>' +
                '<accountId>' + accountId + '</accountId>' +
                '<status>sent</status>' +
                '<emailSubject>DocuSign API Call - Signature request from template</emailSubject>' +
                '<recipients><signers><signer><email>' + signerEmail + '</email>' +
                '<name>' + signerName + '</name><recipientId>1</recipientId><routingOrder>1</routingOrder><clientUserId>1001</clientUserId>' +
                '<tabs><signHereTabs><signHere>' +
                '<documentId>1</documentId><pageNumber>2</pageNumber><recipientId>1</recipientId><name>SIGNATURE</name><anchorString>SIGNATURE</anchorString><anchorXOffset>0</anchorXOffset>' +
                '<anchorYOffset>-20</anchorYOffset></signHere></signHereTabs>' +
                '</tabs></signer></signers></recipients>' +
                '</envelopeDefinition>';

        request = new HttpRequest();

        request.setEndpoint(url);

        request.setMethod('POST');
        request.setHeader('X-DocuSign-Authentication', authenticationHeader);
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/xml');
        request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setBody(body);

        h = new http();

        response = new HttpResponse();

        if(!Test.isRunningTest()){
            response = h.send(request);

            doc = response.getBodyDocument();
        }else{

            doc = new Dom.Document();
            doc.load('<envelopeSummary xmlns="http://www.docusign.com/restapi" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><envelopeId>e7ca57d6-3651-43ae-b26a-403f5fac1f89</envelopeId><status>sent</status><statusDateTime>2016-05-15T11:53:36.8930000Z</statusDateTime><uri>/envelopes/e7ca57d6-3651-43ae-b26a-403f5fac1f89</uri></envelopeSummary>');
        }

        String uri = '';

        String envelopeId = '';

        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
                if(node.getName() == 'uri') {

                    uri = node.getText();
                }

                if(node.getName() == 'envelopeId') {

                    envelopeId = node.getText();
                }
        }

        //============================================================================
        // STEP 3 - Get the Embedded Signing View
        //============================================================================

        url = baseURL + uri + '/views/recipient';   // append envelope uri + 'views/recipient' to url


        // this example uses XML formatted requests, JSON format is also accepted
        body = '<recipientViewRequest xmlns=\'http://www.docusign.com/restapi\'>'  +
                '<authenticationMethod>email</authenticationMethod>' +
                '<email>' + signerEmail + '</email>' +
                '<returnUrl>' + domainURL +
                '/apex/' + retURLPageName + '?ApplicationId=' + appId + '</returnUrl>' +
                '<clientUserId>1001</clientUserId>' +   //*** must match clientUserId set in Step 2!
                '<userName>' + signerName + '</userName>' +
                '</recipientViewRequest>';

        request = new HttpRequest();

        request.setEndpoint(url);

        request.setMethod('POST');
        request.setHeader('X-DocuSign-Authentication', authenticationHeader);
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/xml');
        request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setBody(body);

        h = new http();

        response = new HttpResponse();


       if(!Test.isRunningTest()){
            response = h.send(request);

            doc = response.getBodyDocument();
        }else{

            doc = new Dom.Document();
            doc.load('<viewUrl xmlns="http://www.docusign.com/restapi" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><url>https://na2.docusign.net/Signing/startinsession.aspx?t=453b1ae1-106e-4cc0-8994-f5d87359bc73</url></viewUrl>');
        }

        String signingUrl = '';

        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {

          if(node.getName() == 'url') {

                signingUrl = node.getText();
           }
        }

        if(envelopeId != null){

            saveEnvelopeId(appId, envelopeId);
        }

        return signingUrl;
    }

    /*
    * Method Name: attachSignedDocument
    * Description: Method to attach signed document
    * @param: appId as String
    * @return
    */
    public static void attachSignedDocument(String appId){

        String envelopeId = '';

        for(Contractor_Application__c app : [SELECT EnvelopeId__c FROM Contractor_Application__c
                                                   WHERE Id =: appId]){

            envelopeId = app.EnvelopeId__c;
        }

        Docusign_Configuration__c docusignConfig = Docusign_Configuration__c.getInstance();

        String integratorKey = docusignConfig.Integrator_Key__c; // integrator key (found on Preferences -> API page)
        String username = docusignConfig.User_Name__c; // account email (or your API userId)
        String password = docusignConfig.Password__c; // account password
        //------------------------------------------------------------------------------------

        // construct the DocuSign authentication header
        String authenticationHeader =
                    '<DocuSignCredentials>' + 
                        '<Username>' + username + '</Username>' +
                        '<Password>' + password + '</Password>' +
                        '<IntegratorKey>' + integratorKey + '</IntegratorKey>' +
                    '</DocuSignCredentials>';
 
        //============================================================================
        // STEP 1 - Make the Login API call to retrieve your baseUrl and accountId
        //============================================================================

        String url = docusignConfig.Docusign_URL__c + '/restapi/v2/login_information';
        String body = '';   // no request body for the login call

        HttpRequest request = new HttpRequest();

        request.setEndpoint(url);

        request.setMethod('GET');
        request.setHeader('X-DocuSign-Authentication', authenticationHeader);
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/xml');

        http h = new http();

        HttpResponse response = new HttpResponse();

        Dom.Document doc;

        if(!Test.isRunningTest()){
            response = h.send(request);

            doc = response.getBodyDocument();
        }else{

            doc = new Dom.Document();
            doc.load('<loginInformation xmlns="http://www.docusign.com/restapi" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><loginAccounts><loginAccount><accountId>35840759</accountId><baseUrl>https://na2.docusign.net/restapi/v2/accounts/35840759</baseUrl><email>Dan.Quickenton@nyserda.ny.gov</email><isDefault>true</isDefault><name>Carahsoft obo New York State Energy Research and Development Authority</name><siteDescription/><userId>cab2563c-3170-4b71-954c-ca7922fa9a02</userId><userName>Dan Quickenton</userName></loginAccount></loginAccounts></loginInformation>');
        }

        String baseUrl = '';

        String accountId = '';

        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {

          if(node.getName() == 'loginAccounts') {

             for(dom.XmlNode node1 : node.getChildElements()) {

                if(node1.getName() == 'loginAccount') {

                    for(dom.XmlNode node2 : node1.getChildElements()) {

                        if(node2.getName() == 'accountId') {

                            accountId = node2.getText();
                        }

                        if(node2.getName() == 'baseUrl') {

                            baseUrl = node2.getText();
                        }
                    }
                }
             }
           }
        }

        url = baseURL + '/envelopes/' + envelopeId + '/documents/combined';

        request = new HttpRequest();

        request.setEndpoint(url);

        request.setMethod('GET');
        request.setHeader('X-DocuSign-Authentication', authenticationHeader);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/pdf');

        h = new http();

        response = new HttpResponse();

        if(!Test.isRunningTest()){
            response = h.send(request);
            //#T-01286 to avoid multiple call
            if(!isAsyncCall)
                saveSignedDocument(appId, response.getBodyAsBlob(), envelopeId);
            else
                saveSignedDocument_ASync(appId,response.getBodyAsBlob(),envelopeId);
        }else{
            if(!isAsyncCall)
                saveSignedDocument(appId, blob.valueOf('Dummy Body'), envelopeId);
            else
                saveSignedDocument_ASync(appId,blob.valueOf('Dummy Body'),envelopeId);
        }
    }

    @future
    public static void saveSignedDocument(String appId, blob body, String envelopeId){
        saveSignedDocument_ASync(appId,body,envelopeId);
    }

    //#T-01286 by Pankaj
    /*
    * Method Name: saveSignedDocument_ASync
    * Description: Method to get contact list
    * @param : appId as String
    * @param : body as Blob
    * @param : envelopeId as String
    * @return
    */
    public static void saveSignedDocument_ASync(String appId, blob body, String envelopeId){

        Id appContent;
        for(Application_Content__c proContent : [SELECT Id FROM Application_Content__c
                                                 WHERE Contractor_Application__c =: appId
                                                 AND Type__c =: CORE_Helper.TYPE_CON_APP
                                                 AND Sub_Type__c =: CORE_Helper.SUB_TYPE_CON_APP]){
                                                     appContent = proContent.Id;
                                                 }

        if(appContent != null){




            Project_Document__c proDocument = new Project_Document__c(Name = CORE_Helper.SUB_TYPE_CON_APP,
                                                                      Contractor_Application__c = appId, Version__c = 1,
                                                                      Application_Content__c = appContent,
                                                                      Status__c = CORE_Helper.DOCUMENT_STATUS_SUBMITTED);
            insert proDocument;




            Attachment attachment = new Attachment(ParentId = proDocument.Id, Body = body,
                                                   Name = CORE_Helper.SUB_TYPE_CON_APP + ': ' + envelopeId,
                                                   ContentType = 'application/pdf');
            insert attachment;
            Contractor_Application__c app = new Contractor_Application__c(Id = appId, Authorized_Signature_Date__c = DateTime.now());
            update app;
        }
    }

    @future
    public static void saveEnvelopeId(String appId, String envelopeId){

        Contractor_Application__c app = new Contractor_Application__c(Id = appId, EnvelopeId__c = envelopeId);

        update app;
    }
}