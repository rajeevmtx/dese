public class GenerateButtonController {

    public Application__c applicationRecord {get;set;}

    public GenerateButtonController(ApexPages.StandardController std){
        Id accountId = std.getId();
        applicationRecord = [SELECT Id,Name FROM Application__c WHERE Id = :accountId];
    }

    public PageReference saveRestraintPDF(){
        PageReference pagePdf = Page.GenerateLicensePermitPDF;
        pagePdf.getParameters().put('id', applicationRecord.Id); 
         Id conDocument = '06903000001rW0FAAU';
         
         List<ContentDocumentLink> contentList = [SELECT ID,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :applicationRecord.Id and ContentDocumentId = :conDocument];
        if(contentList.size()>0){
            delete contentList;
        }
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

    public PageReference saveNonCompliancePDF(){
        PageReference pagePdf = Page.GenerateLicensePermitPDF;
        pagePdf.getParameters().put('id', applicationRecord.Id); 
         Id conDocument = '06903000001rVkBAAU';
         
         List<ContentDocumentLink> contentList = [SELECT ID,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :applicationRecord.Id and ContentDocumentId = :conDocument];
        if(contentList.size()>0){
            delete contentList;
        }
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

    public PageReference saveVisitPDF(){
        PageReference pagePdf = Page.GenerateLicensePermitPDF;
        pagePdf.getParameters().put('id', applicationRecord.Id); 
         Id conDocument = '06903000001rVkAAAU';
         
         List<ContentDocumentLink> contentList = [SELECT ID,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :applicationRecord.Id and ContentDocumentId = :conDocument];
        if(contentList.size()>0){
            delete contentList;
        }
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
}