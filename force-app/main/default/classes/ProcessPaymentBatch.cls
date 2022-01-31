global class ProcessPaymentBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('INSIDE START');
        String fileName ='INVOICE_'+String.valueof(System.now()).split('\\s[0-9,:]*')[0]+'_paid.xml';
        System.debug('fileName'+fileName);
        
        String queryString = 'SELECT FirstPublishLocationId,PathOnClient,VersionData,CreatedDate,LastModifiedDate, ContentModifiedDate FROM ContentVersion WHERE PathOnClient =' + fileName;
        System.debug('QUERYSTRIG '+queryString);
        return Database.getQueryLocator('SELECT FirstPublishLocationId,PathOnClient,VersionData,CreatedDate,LastModifiedDate, ContentModifiedDate FROM ContentVersion WHERE PathOnClient = :fileName');
    }
    
    global void execute(Database.BatchableContext BC, List<ContentVersion> lConVersion) {
        System.debug('INSIDE EXECUTE');
        try{
            if(lConVersion.size() >0){
                
                List<Project_Invoice__c> lInvoice = new List<Project_Invoice__c>();
                for(Project_Invoice__c pI : [Select Id,Status__c from Project_Invoice__c where Status__c ='Sent to Finance']){
                    Project_Invoice__c pInvoice = new Project_Invoice__c();
                    pInvoice.Id = pI.Id;
                    pInvoice.Status__c = 'Paid';
                    pInvoice.Payment_Date__c = System.today();
                    lInvoice.add(pInvoice);
                }
                
                update lInvoice;
                
            }
        }catch(Exception e){
            System.debug('Error'+e);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug('INSIDE FINISH');
    }
}