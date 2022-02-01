public class GeneratePermitController {
	
    public Application__c applicationRecord {get;set;}
    
    public GeneratePermitController(ApexPages.StandardController std){
        Id applicationRecordId = std.getId();
        applicationRecord = [SELECT Id,Name FROM Application__c WHERE Id = :applicationRecordId];
    }
    
    public PageReference saveLicensingPDF(){
        PageReference pagePdf = Page.GenerateLicensePermitPDF;
        pagePdf.getParameters().put('id', applicationRecord.Id); 
             
        /*Attachment insertAttach = new Attachment();
        insertAttach.Body = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pagePdf.getContentAsPdf();
        insertAttach.ParentID = applicationRecord.Id;
        insertAttach.Name = applicationRecord.Name + ' Permit.pdf';
        insert insertAttach;
         
        //Get attachment
         Attachment attach = [SELECT Id, Name, Body, ContentType, ParentId,OwnerId  
                              From Attachment  WHERE Id = :insertAttach.Id];
         
         //Insert ContentVersion
         ContentVersion cVersion = new ContentVersion();
         cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
         cVersion.PathOnClient = attach.Name;//File name with extention
         cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
         cVersion.OwnerId = attach.OwnerId;//Owner of the file
         cVersion.Title = attach.Name;//Name of the file
         cVersion.VersionData = attach.Body;//File content
         Insert cVersion;
         
         //After saved the Content Verison, get the ContentDocumentId
         Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;*/
         Id conDocument = '06903000001rW0sAAE';
         
         //Insert ContentDocumentLink
         ContentDocumentLink cDocLink = new ContentDocumentLink();
         cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
         //cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
         cDocLink.LinkedEntityId = applicationRecord.Id;//Add attachment parentId
         cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
         cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
         Insert cDocLink;
         
        return new PageReference('/' + applicationRecord.Id);
    }
    
     public PageReference savePDF(){
        PageReference pagePdf = Page.GenerateApplicationPermitPDF;
        pagePdf.getParameters().put('id', applicationRecord.Id); 
             
        Attachment insertAttach = new Attachment();
        insertAttach.Body = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pagePdf.getContentAsPdf();
        insertAttach.ParentID = applicationRecord.Id;
        insertAttach.Name = applicationRecord.Name + ' Permit.pdf';
        insert insertAttach;
         
        //Get attachment
         Attachment attach = [SELECT Id, Name, Body, ContentType, ParentId,OwnerId  
                              From Attachment  WHERE Id = :insertAttach.Id];
         
         //Insert ContentVersion
         ContentVersion cVersion = new ContentVersion();
         cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
         cVersion.PathOnClient = attach.Name;//File name with extention
         cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
         cVersion.OwnerId = attach.OwnerId;//Owner of the file
         cVersion.Title = attach.Name;//Name of the file
         cVersion.VersionData = attach.Body;//File content
         Insert cVersion;
         
         //After saved the Content Verison, get the ContentDocumentId
         Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
         
         //Insert ContentDocumentLink
         ContentDocumentLink cDocLink = new ContentDocumentLink();
         cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
         cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
         cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
         cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
         Insert cDocLink;
         
        return new PageReference('/' + applicationRecord.Id);
    }
    
    /*public GeneratePermitController(){
        Id applicationRecordId  = ApexPages.currentPage().getParameters().get('id');
        applicationRecord = [SELECT Id,Name FROM Application__c WHERE Id = :applicationRecordId]; 
        system.debug('applicationRecord >>'+applicationRecord);
        //savePDF();
    }
    
    public PageReference savePDF(){
        
        system.debug('Inside PDF >>');
        PageReference pagePdf = pdfPageReference;
        pagePdf.getParameters().put('id', applicationRecord.Id); 
             
        Attachment insertAttach = new Attachment();
        insertAttach.Body = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : pagePdf.getContentAsPdf();
        insertAttach.ParentID = applicationRecord.Id;
        insertAttach.Name = 'Permit' + applicationRecord.Name + '.pdf';
        insert insertAttach;
        system.debug('insertAttach >>'+insertAttach);
        return new PageReference('/' + applicationRecord.Id);
    }
    
    public PageReference pdfPageReference(){
        return Page.GeneratePermitPDF;
    }*/
      
     
}