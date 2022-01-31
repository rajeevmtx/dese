global class GenerateXMLBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         System.debug('INSIDE START');
        return Database.getQueryLocator('SELECT Id,Name, Invoice_Date__c,Total_Amount_Due__c,Status__c  from Project_Invoice__c where Status__c =\'Approved\' LIMIT 200');
    }
    
    global void execute(Database.BatchableContext BC, List<Project_Invoice__c> lInvoice) {
        System.debug('INSIDE EXECUTE');
        try{
            if(lInvoice.size() >0){
                
                Dom.Document doc = new Dom.Document();
                Dom.Xmlnode rootNode = doc.createRootElement('XMLInvoiceFile', null, null);
                
                Dom.Xmlnode headerNode = rootNode.addChildElement('INVOICE', null, null);
                
                
                headerNode.setAttribute('Id', 'HEADER'); 
                
                for(Integer i=0; i< lInvoice.size();i++){
                    Dom.Xmlnode childNode = headerNode.addChildElement('Invoice_Detail', null, null); 
                    childNode.setAttribute('Id',lInvoice[i].Name);    
                    childNode.setAttribute('DATE',string.valueOfGmt(lInvoice[i].Invoice_Date__c));
                    childNode.setAttribute('AMOUNT',string.valueOf(lInvoice[i].Total_Amount_Due__c));
                    childNode.setAttribute('STATUS',lInvoice[i].Status__c);
                }
                
                String xmlString = doc.toXmlString();
                
                System.debug('xmlString =' + xmlString);
                
                String docName = 'INVOICE_'+String.valueof(System.now()).split('\\s[0-9,:]*')[0]+'.xml';
                System.debug(docName);
                
                
                ContentVersion contentVersion = new ContentVersion(
                    Title='INVOICE_'+String.valueof(System.now()).split('\\s[0-9,:]*')[0], 
                    PathOnClient =docName,
                    VersionData = Blob.valueOf(xmlString), 
                    origin = 'H',
                    SharingPrivacy = 'N',
                    SharingOption ='A'
                );
                insert contentVersion;
                
                /*ContentVersion conVer = [SELECT Id,ContentDocumentId  from ContentVersion  WHERE Id = :contentVersion.Id];
                
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = '5003F000006fK6tQAE';
                contentlink.ContentDocumentId = conVer.ContentDocumentId;
                contentlink.ShareType = 'V';
                insert contentlink;*/
                
                DESE_XML_Document_Tracker__c  obj  = [SELECT Id,DocID__c FROM DESE_XML_Document_Tracker__c LIMIT 1];
                obj.DocID__c = contentVersion.Id;
                update obj;
                
                for(Integer i=0; i< lInvoice.size();i++){
                    lInvoice[i].Status__c ='Sent to Finance';
                }  
                
                update lInvoice;
                
            }}
        catch(Exception e){
            System.debug('Error'+e);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug('INSIDE FINISH');
    }
}