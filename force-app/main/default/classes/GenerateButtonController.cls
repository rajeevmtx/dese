public class GenerateButtonController {

    public Account accountRecord {get;set;}

    public GenerateButtonController(ApexPages.StandardController std){
        Id accountId = std.getId();
        accountRecord = [SELECT Id,Name FROM Account WHERE Id = :accountId];
    }

    public PageReference saveRestraintPDF(){
        PageReference pagePdf = Page.GenerateLicensePermitPDF;
        pagePdf.getParameters().put('id', accountRecord.Id); 
         Id conDocument = '06903000001rVkFAAU';
         
         //Insert ContentDocumentLink
         ContentDocumentLink cDocLink = new ContentDocumentLink();
         cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
         //cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
         cDocLink.LinkedEntityId = accountRecord.Id;//Add attachment parentId
         cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
         cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
         Insert cDocLink;
         
        return new PageReference('/' + accountRecord.Id);
    }

    public PageReference saveNonCompliancePDF(){
        PageReference pagePdf = Page.GenerateLicensePermitPDF;
        pagePdf.getParameters().put('id', accountRecord.Id); 
         Id conDocument = '06903000001rVkBAAU';
         
         //Insert ContentDocumentLink
         ContentDocumentLink cDocLink = new ContentDocumentLink();
         cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
         //cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
         cDocLink.LinkedEntityId = accountRecord.Id;//Add attachment parentId
         cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
         cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
         Insert cDocLink;
         
        return new PageReference('/' + accountRecord.Id);
    }

    public PageReference saveVisitPDF(){
        PageReference pagePdf = Page.GenerateLicensePermitPDF;
        pagePdf.getParameters().put('id', accountRecord.Id); 
         Id conDocument = '06903000001rVkAAAU';
         
         //Insert ContentDocumentLink
         ContentDocumentLink cDocLink = new ContentDocumentLink();
         cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
         //cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
         cDocLink.LinkedEntityId = accountRecord.Id;//Add attachment parentId
         cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
         cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
         Insert cDocLink;
         
        return new PageReference('/' + accountRecord.Id);
    }
}