public class UpdateInvoiceController {
    
    public UpdateInvoiceController( ApexPages.StandardController controller ) {}
    
    public static void updateInvo(){
        try {
            String fileName ='PROCESSED_INVOICE_'+String.valueof(System.now()).split('\\s[0-9,:]*')[0]+'.xml';
            System.debug('FILENAME'+fileName);
            List<ContentVersion> lConVersion = new List<ContentVersion>();
            lConVersion = [SELECT FirstPublishLocationId,PathOnClient,VersionData,CreatedDate,LastModifiedDate,
                           ContentModifiedDate FROM ContentVersion WHERE PathOnClient = :fileName];
            
            System.debug('QUERY '+lConVersion);
            
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
            }}catch(Exception e){
                System.debug(e);
            }
        }
}