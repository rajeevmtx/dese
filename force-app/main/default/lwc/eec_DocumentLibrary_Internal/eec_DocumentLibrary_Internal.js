import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getAllDocumentsForIndividual from '@salesforce/apex/EEC_DocumentLibraryInternal.getAllDocumentsForIndividual';
import fetchPicklist from "@salesforce/apex/EEC_ReviewLicensingDocumentExtensionLWC.getAllPicklistValue";
import saveDocumentChanges from "@salesforce/apex/EEC_DocumentLibraryInternal.saveDocumentChanges";
import sendRejectedDocsToProvider from "@salesforce/apex/EEC_DocumentLibraryInternal.sendRejectedDocsToProvider";
import is_GSA_Or_RP from "@salesforce/apex/EEC_DocumentLibraryInternal.is_GSA_Or_RP";
import doCreateDocs from "@salesforce/apex/EEC_DocumentLibraryInternal.doCreateDocs";
import pubsub from 'c/pubsubnew' ; 

export default class Eec_DocumentLibrary_Internal extends LightningElement {
    @api recordId;
    @api lastRecordCategory;
    @track tableData;
    @track viewModalOpen = false;
    @track showSpinner;
    @track documentId;
    @track documentTypeName;
    @track editMode = false;
    @track statusValue = [];
    @track isGsaOrRpRecord = false;
    @track documentsPresent = false;
    @track areDocsCreated = false;
    documentChanges = [];
    defaultCheckboxValue = false;
    showModal = false;
    showNewModal = false;
    theIframe
    @track isChatter = false;
    @track currentEvId = "";

    @track sharepointUrls =['https://mtxgroupinc.sharepoint.com/:w:/r/sites/DESE_Demo/_layouts/15/Doc.aspx?sourcedoc=%7B580910F2-C29C-44CE-8C94-24161362CACD%7D&file=I-0370%20Visit%20Summary%20Report.docx&action=default&mobileredirect=true',
    'https://mtxgroupinc.sharepoint.com/:w:/r/sites/DESE_Demo/_layouts/15/Doc.aspx?sourcedoc=%7B7BFACC0B-C7D1-4BC0-885F-AD812EBF299F%7D&file=0524.docx&action=default&mobileredirect=true',
    'https://mtxgroupinc.sharepoint.com/:w:/r/sites/DESE_Demo/_layouts/15/Doc.aspx?sourcedoc=%7BDEDCC086-C68E-401B-81DE-339C8B689130%7D&file=50500000.docx&action=default&mobileredirect=true',
    'https://mtxgroupinc.sharepoint.com/sites/DESE_Demo/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FDESE%5FDemo%2FShared%20Documents%2Fitem3%5FA5p603cmr44%2Dtracked%2Epdf&parent=%2Fsites%2FDESE%5FDemo%2FShared%20Documents',
    'https://mtxgroupinc.sharepoint.com/sites/DESE_Demo/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FDESE%5FDemo%2FShared%20Documents%2Fspp%2Dapr%2D2018%2Epdf&parent=%2Fsites%2FDESE%5FDemo%2FShared%20Documents'];

    connectedCallback(){ 
        this.getPicklistValues();
        this.isGsaOrRp();
        //this.doCreateDocuments();    
        pubsub.register('closemodal', this.handleEvent.bind(this));
    }
    handleEvent(messageFromEvt){
        this.getAllDocuments();
        this.viewModalOpen = false;
    }

    getPicklistValues(){
        this.showSpinner = true;
        fetchPicklist().then(
            result => {
                this.statusValue = result.status;
                console.log('result.status ', result.status);
                //this.showSpinner = false;         
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showSpinner = false;
            this.showToast('Error!','Please Contact System Administrator for more details','error');
        }); 
    }

    isGsaOrRp() {
        //this.showSpinner = true;
        is_GSA_Or_RP({accId: this.recordId}).then(
            result => {
                this.isGsaOrRpRecord = result;
                console.log('responseValue is : ', result);
                this.doCreateDocuments(); 
            })
        .catch(error => {
            console.log('message : ', error);
        }); 
    }

    handleUploadFinished() {
        this.closeModal();
    }

    openUploadDocumentPageNew() {
        this.isUpload = true;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    closeNewModal() {
        this.showNewModal = false;
    }

    doCreateDocuments() {
        //this.showSpinner = true;
        doCreateDocs({accountId: this.recordId}).then(
            result => {
              console.log('result : ', result);
              this.areDocsCreated = true;
              this.getAllDocuments();
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showSpinner = false;
            this.showToast('Error!','Please Contact System Administrator for more details','error');
        }); 
    }
    

    // @wire(getAllDocumentsForIndividual, {accountId:'$recordId'})
    // documentData({error,data}){
    //     if(data){
    //         if(data.length > 0) {
    //             this.documentsPresent = true;
    //             console.log('docs present');
    //         }
    //         this.tableData = data;
    //         this.documentChanges = [...data];
    //         console.log('data is : ', data);
    //     }
    //     else if(error){
    //         console.log('message : ', error);
    //     }
    // }

    getAllDocuments() {
        getAllDocumentsForIndividual({accountId: this.recordId})
        .then(data => {
            if(data.length > 0) {
                this.documentsPresent = true;
                console.log('docs present');
            } 

            this.showSpinner = false;
            this.tableData = data;
            this.documentChanges = [...data];
            console.log('data is : ', data);
        })
        .catch(error => {
            console.log('message : ', error);
            this.showSpinner = false;
        });
    } 
    

    openViewModal(event) {
        // var elementId = event.currentTarget.dataset.id;
        // var documentName = event.currentTarget.dataset.name;
        // this.documentTypeName = documentName;
        // if(elementId){
        //     console.log('elementId : ', elementId);
        //     this.documentId = elementId;
        //     this.viewModalOpen = true;
        // }
       
        if(event.currentTarget.dataset.name.startsWith('3')){
            window.open(this.sharepointUrls[3], "_blank");
        }
        else if(event.currentTarget.dataset.name.startsWith('2')){
            window.open(this.sharepointUrls[2], "_blank");
        }
        else if(event.currentTarget.dataset.name.startsWith('1')){
            window.open(this.sharepointUrls[1], "_blank");
        }
        else{
                var index = Math.floor(Math.random() * 4);
                window.open(this.sharepointUrls[index], "_blank");
        }
    }

    showModalForSubCat(event){
        this.documentTypeName = event.detail.documentName;
        this.documentId = event.detail.documentId;
        this.viewModalOpen = true;
    }

    openUploadDocumentPage(event) {
       console.log('event.currentTarget.id : ', event.currentTarget.id);
       let docId = (event.currentTarget.id).split('-')[0];
       window.open("/apex/EEC_AttachmentSelection?id="+docId,"_blank");
    }

    handleEdit(){
        this.editMode = true;
        pubsub.fire('childEditMode', 'editMode' );
        this.documentChanges = [...this.tableData]
    }

    handleInput(event){
        pubsub.fire('childInput', event);   
        var dataMap = JSON.parse(JSON.stringify(this.documentChanges));
        var category = event.target.getAttribute('data-category');
        for(let row of this.documentChanges) {
            if(row.categoryName !== category) {
               continue;
            } else {
               console.log('row : ', row);
               var data = JSON.parse(JSON.stringify(row.innerFields));
               var elementId = event.currentTarget.dataset.id;
               var elementName = event.target.name;
               var elementValue = elementName == 'status' ?event.target.value:event.target.checked;
               console.log('elementName : ', elementName);
               console.log('event.target.value : ', event.target.value);

               if(elementName == 'status'){
                   data.find(x => x.documentId === elementId).status = elementValue;
                   if(elementValue == 'Returned for Revision'){
                      data.find(x => x.documentId === elementId).isReturnedForRevision = true;
                      data.find(x => x.documentId === elementId).isLegacyReviewed = false;
                      data.find(x => x.documentId === elementId).isOtherStatus = false;

                   } else if(elementValue == 'Legacy Reviewed') {
                      data.find(x => x.documentId === elementId).isLegacyReviewed = true;
                      data.find(x => x.documentId === elementId).isReturnedForRevision = false;
                      data.find(x => x.documentId === elementId).isOtherStatus = false;
                   } else {
                      data.find(x => x.documentId === elementId).isOtherStatus = true;
                      data.find(x => x.documentId === elementId).isLegacyReviewed = false;
                      data.find(x => x.documentId === elementId).isReturnedForRevision = false;
                   }
               }else if(elementName == 'docApplicableEditMode'){
                   data.find(x => x.documentId === elementId).documentNotApplicable = elementValue;
               } 

               dataMap.find(x => x.categoryName === row.categoryName).isAllDocsReviewed = true;
               console.log('data : ', data);
               for(let docData of data) {
                   console.log('here');
                   if(docData.status !== 'Legacy Reviewed') {
                     dataMap.find(x => x.categoryName === row.categoryName).isAllDocsReviewed = false;
                     break;
                   }
               }

               dataMap.find(x => x.categoryName === row.categoryName).innerFields = [...data];

               this.documentChanges = [...dataMap];
               console.log('this.documentChanges : ', this.documentChanges);
               break;
            }
        }
    }

    handleCancel(){
        this.editMode = false;
        this.documentChanges = [];

        pubsub.fire('cancelChildEditMode', 'cancelEditMode' );
    }

    checkComments(){
        let needComment = false;
        this.documentChanges.forEach(doctype => {
            doctype.innerFields.forEach(doc => {
                if (doc.isReturnedForRevision)
                    needComment = true;
            })
        })
        if(needComment){
            this.showNewModal = true;
        }
        else{
            this.handleSave();
        }
    }

    handleSave(){
        this.closeNewModal();
        this.showSpinner = true;
        var changesToSave = [...this.documentChanges];
        console.log('save this : ', changesToSave);
        saveDocumentChanges({jsonData: JSON.stringify(changesToSave)}).then(
            result => {
                console.log('result>',result);
                this.editMode = false;
                pubsub.fire('childSave', 'saveChild');
                pubsub.fire('cancelChildEditMode', 'cancelEditMode' );
                this.showSpinner = false;
                if(changesToSave)
                this.tableData = [...changesToSave];
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showSpinner = false;
            this.showError();
        });   
    }

    showError() {
        const event = new ShowToastEvent({
            title: 'Error!',
            message: 'Error fetching Documents',
            variant: 'error',
            mode: 'dismissable'    
        });
        this.dispatchEvent(event);
    }

    sendRejectedDocsToProvider() {
        this.showSpinner = true;
        sendRejectedDocsToProvider({accId: this.recordId})
        .then(result => {
            console.log('result : ', result);
            if(result === null) {
                this.showSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Email Sent!',
                    message: 'An email has been sent to Provider regarding rejected document.',
                    variant: 'Success',
                    mode: 'dismissable'    
                });
                this.dispatchEvent(event);
            } else {
                this.showSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: result,
                    variant: 'Error',
                    mode: 'sticky'    
                });
                this.dispatchEvent(event);
            } 
        })
        .catch(error => {
            console.log('error : ', error);

           
        });
    }

    showToast(title,msg,type){
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: type,
        });
        this.dispatchEvent(evt);
    }

    handleFinalSave() {
        
        this.closeNewModal = false;
    }


    get fullUrl() {
        return 'https://mtxlicensingpermit--desedemo--c.visualforce.com/apex/PsrChatterPage?id=' + this.currentEvId
    }
    renderedCallback() {
        if (console.log("rendred callback called" + this.theIframe),
        null == this.theIframe) {
            this.fullurl = 'https://mtxlicensingpermit--desedemo--c.visualforce.com/apex/PsrChatterPage?id=' + this.currentEvId
        }
    }
    redirectToChatter(event) {
        console.log(
            "redirectToChatter: " + event.currentTarget.getAttribute("data-id")
        );
        this.currentEvId = event.currentTarget.getAttribute("data-id");
        this.isChatter = true;
        this.fullurl= 'https://mtxlicensingpermit--desedemo--c.visualforce.com/apex/PsrChatterPage?id='+event.currentTarget.getAttribute('data-id');
        //this.fullurl= '/apex/PsrChatterPage?id='+event.currentTarget.getAttribute('data-id');
        console.log("URL: " + this.fullurl);
    }
    handleCloseModal() {
        this.isChatter = false;
        this.currentEvId = "";
    }
}