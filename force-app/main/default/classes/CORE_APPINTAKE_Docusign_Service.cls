/**
* Class Name: CORE_APPINTAKE_Docusign_Service 
* Description: Service class to handle the functionalities of related to docusign and signning
* Author/Date:  Ashish   12/29/2016
*
* Date         New/Modified      Author             Description
* 05/17/2017   Modified          Ghanshyam          Commenting
*                                                             
*/
global without sharing class CORE_APPINTAKE_Docusign_Service{
    
    global static Date completedDate;
    
    /**
    * Method Name: getSiginingUrl
    * Description: Method to populate signning URL
    * @param: projectId as String
    * @param: domainURL as String
    * @param: returnPageName as String
    * @param: pdfPageName as String
    * @return: String                                                  
    */
    global static String getSiginingUrl(String projectId, String domainURL, String returnPageName, String pdfPageName){
        
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
        
        response = h.send(request);
        
        dom.Document doc = response.getBodyDocument();
        
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
        
        PageReference pg = new PageReference('/psr/apex/' + pdfPageName + '?ProjectId=' + projectId);
        
        String signerName = UserInfo.getName();
        
        String signerEmail = UserInfo.getUserEmail();
        
        String documentName = 'Core Project Application';
        
         Blob content;
          if (Test.IsRunningTest())
          {
              content=Blob.valueOf('UNIT.TEST');
          }
          else
          {
              content=pg.getContentAsPDF();
          }
        // this example uses XML formatted requests, JSON format is also accepted
        body =  '<envelopeDefinition xmlns=\'http://www.docusign.com/restapi\'>' +
                '<emailSubject>' + 'Please Sign the Document' + '</emailSubject><emailBlurb>Please review this document and sign electronically. Thank you.</emailBlurb>' +
                '<documents><document><name>' + documentName + '</name><documentId>1</documentId>' +
                '<documentBase64>' + EncodingUtil.base64Encode(content) + '</documentBase64>' +
                '</document></documents>' +
                '<accountId>' + accountId + '</accountId>' +
                '<status>sent</status>' +   
                '<emailSubject>DocuSign API Call - Signature request from template</emailSubject>' +
                '<recipients><signers><signer><email>' + signerEmail + '</email>' +
                '<name>' + signerName + '</name><recipientId>1</recipientId><routingOrder>1</routingOrder>' +
                '<clientUserId>1001</clientUserId>' + 
                '<tabs><dateSignedTabs><dateSigned><documentId>1</documentId><pageNumber>2</pageNumber><recipientId>1</recipientId><tabLabel>Signing Date</tabLabel><name>Signing Date</name><anchorString>Signing Date</anchorString><anchorXOffset>0</anchorXOffset>' +
                '<anchorYOffset>10</anchorYOffset></dateSigned></dateSignedTabs><signHereTabs><signHere>' +
                '<documentId>1</documentId><pageNumber>2</pageNumber><recipientId>1</recipientId><name>Signature Panel Tag</name><anchorString>Signature Panel Tag</anchorString><anchorXOffset>0</anchorXOffset>' +
                '<anchorYOffset>40</anchorYOffset></signHere></signHereTabs>' +
                '</tabs></signer></signers></recipients>' +
                '<fromFolderId>8186333d-832d-405b-aeff-0eba147f05d2</fromFolderId>' +
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
        
        response = h.send(request);
        
        String uri = '';
        
        String envelopeId = '';
        
        doc = response.getBodyDocument();
        
        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
                if(node.getName() == 'uri') {
                    
                    uri = node.getText();
                }
                
                if(node.getName() == 'envelopeId') {
                    
                    envelopeId = node.getText();
                }
        }
        
        String signingUrl;
    
        //============================================================================
        // STEP 3 - Get the Embedded Signing View
        //============================================================================
        
        url = baseURL + uri + '/views/recipient';   // append envelope uri + 'views/recipient' to url 
        
        
        // this example uses XML formatted requests, JSON format is also accepted
        body = '<recipientViewRequest xmlns=\'http://www.docusign.com/restapi\'>'  +
                '<authenticationMethod>email</authenticationMethod>' + 
                '<email>' + signerEmail + '</email>' + 
                '<returnUrl>' + domainURL + 
                '/psr/apex/' + returnPageName + '?ProjectId=' + projectId + '</returnUrl>' + 
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
        
        response = h.send(request);
            
        doc = response.getBodyDocument();
        
        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
          
          if(node.getName() == 'url') {
             
                signingUrl = node.getText();
           }
        }
        
        if(envelopeId != null){
            
            saveEnvelopeId(projectId, envelopeId);
        }
        
        return signingUrl;
    }
    
    /**
    * Method Name: attachSignedDocument
    * Description: Method to attach sugned document to application
    * @param: projectId as String
    * @return                                                  
    */
    public static void attachSignedDocument(String projectId){
        
        String envelopeId = '';
        for(Project__c project : [SELECT EnvelopeId__c FROM Project__c
                                  WHERE Id =: projectId]){
            
            envelopeId = project.EnvelopeId__c;
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
        
        response = h.send(request);
        
        dom.Document doc = response.getBodyDocument();
        
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
        
        Date signingDate;
            
        String signingStatus;
            
        url = baseURL + '/envelopes/' + envelopeId; 
             
        request = new HttpRequest();
         
        request.setEndpoint(url);
    
        request.setMethod('GET');
        request.setHeader('X-DocuSign-Authentication', authenticationHeader);
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('Accept', 'application/xml');
        
        h = new http();
        
        response = new HttpResponse();
        
        response = h.send(request);
        
        doc = response.getBodyDocument();
        
        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
          
          if(node.getName() == 'status') {
             
             signingStatus = node.getText();
          }
          System.debug('>>>' + node.getName());
          if(node.getName() == 'completedDateTime') {
             System.debug('1');
             if(node.getText() != null){
             System.debug('2');                
                List<String> tempList = node.getText().split('T');
                
                if(tempList != null && tempList.size() != 0){
                                 System.debug('3');
                    tempList = tempList.get(0).split('-');
                    
                    if(tempList != null && tempList.size() > 2){
                                     System.debug('4Syste');
                        signingDate = Date.parse(tempList.get(1) + '/' + tempList.get(2) + '/' +tempList.get(0));
                    }
                }
             }
          }
        }
        if(signingStatus == 'completed'){
            
            url = baseURL + '/envelopes/' + envelopeId + '/documents/combined'; 
                 
            request = new HttpRequest();
             
            request.setEndpoint(url);
        
            request.setMethod('GET');
            request.setHeader('X-DocuSign-Authentication', authenticationHeader);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/pdf');
            
            h = new http();
            
            response = new HttpResponse();
            
            response = h.send(request);
            
            //saveSignedDocument(projectId, response.getBodyAsBlob(), envelopeId, signingDate);
            asyncSaveSignedDocument(projectId, response.getBodyAsBlob(), envelopeId, signingDate);
        }
    }
    
    @future
    public static void asyncSaveSignedDocument(String projectId, blob body, String envelopeId,
                                               Date signingDate){
        
        saveSignedDocument(projectId, body, envelopeId, signingDate);
    }
    
    /**
    * Method Name: saveSignedDocument
    * Description: Method to save the signed document
    * @param 
    * @return                                                  
    */
    public static void saveSignedDocument(String projectId, blob body, String envelopeId,
                                          Date signingDate){
        
        Id projectContent;
        
        for(Project_Content__c proContent : [SELECT Id FROM Project_Content__c 
                                             WHERE Project__c =: projectId
                                             AND Type__c =: CORE_Helper.TYPE_PROJECT_APP
                                             AND Sub_Type__c =: CORE_Helper.SUB_TYPE_CON_APP]){
            
            projectContent = proContent.Id;
        }
        
        if(projectContent != null){
            
            String documentName = CORE_Helper.SUB_TYPE_CON_APP;
            
            Decimal version = 1;
            
            for(Project_Document__c proDoc : [SELECT Version__c FROM Project_Document__c
                                              WHERE Project__c =: projectId
                                              AND Project_Content__c =: projectContent]){
                                                
                version = version + 1;
            }
            
            Project_Document__c proDocument = new Project_Document__c(Name = CORE_Helper.SUB_TYPE_CON_APP,
                                                                      Project__c = projectId, Version__c = version,
                                                                      Project_Content__c = projectContent,
                                                                      Status__c = CORE_Helper.DOCUMENT_STATUS_SUBMITTED);
                                                                      
            insert proDocument;
            
            Attachment attachment = new Attachment(ParentId = proDocument.Id, Body = body,
                                                   Name = documentName,
                                                   ContentType = 'application/pdf');
                
            insert attachment;
            
            Project__c project = new Project__c(Id = projectId, Signed_Date__c = signingDate);
                
            update project;  
        }
    }
    
    @future
    public static void saveEnvelopeId(String projectId, String envelopeId){
        
        Project__c project = new Project__c(Id = projectId, EnvelopeId__c = envelopeId);
            
        update project;
    }
}