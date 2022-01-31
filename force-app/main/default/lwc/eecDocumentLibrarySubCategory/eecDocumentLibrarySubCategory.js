import { LightningElement, api, track } from 'lwc';
import getAllDocumentsForSubCategory from '@salesforce/apex/EEC_DocumentLibraryInternal.getAllDocumentsForSubCategory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import fetchPicklist from "@salesforce/apex/EEC_ReviewLicensingDocumentExtensionLWC.getAllPicklistValue";
import saveDocumentChangesRP from "@salesforce/apex/EEC_DocumentLibraryInternal.saveDocumentChangesRP";
import pubsub from 'c/pubsub' ; 

export default class EecDocumentLibrarySubCategory extends LightningElement {
    @api recordId;
    @api subCategory;
    @track tableData;
    @track documentId;
    @track viewModalOpen = false;
    @track editMode = false;
    @track documentTypeName;
    documentChanges = [];

    connectedCallback(){    
        this.getAllDocuments();
        this.getPicklistValues();
        pubsub.register('closemodal', this.handleEvent.bind(this));
        pubsub.register('childEditMode', this.handleEditClick.bind(this));
        pubsub.register('cancelChildEditMode', this.handleCancelEditClick.bind(this));
        pubsub.register('childInput', this.handleInputEvent.bind(this));               
        pubsub.register('childSave', this.handleSaveEvent.bind(this));               
              
    }
    handleEvent(messageFromEvt){
        this.getAllDocuments();
        this.viewModalOpen = false;
    }
    
    handleEditClick(){
        this.editMode = true;
        this.documentChanges = [...this.tableData]
    }

    handleCancelEditClick(){
        this.editMode = false;
        this.documentChanges = [];
    }

    handleInputEvent(event){
        this.handleInput(event);
    }

    handleSaveEvent(){
        this.handleSave();
    }

    getAllDocuments(){     
        getAllDocumentsForSubCategory({accId: this.recordId, subCategory: this.subCategory}).then(
            result => {
            console.log('result>',result);
            this.tableData = result;
            this.documentChanges = [...result];           
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showToast('Error!','Please Contact System Administrator for more details','error');
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

    openViewModal(event) {
        var elementId = event.currentTarget.dataset.id;
        var documentName = event.currentTarget.dataset.name;
        this.documentTypeName = documentName;
        if(elementId){
            this.documentId = elementId;
            //this.viewModalOpen = true;
        }

        const selectedEvent = new CustomEvent('view', { detail: {documentName: this.documentTypeName, documentId : this.documentId} });

        this.dispatchEvent(selectedEvent);
    }

    openUploadDocumentPage(event) {
        console.log('event.currentTarget.id : ', event.currentTarget.id);
        let docId = (event.currentTarget.id).split('-')[0];
        window.open("/apex/EEC_AttachmentSelection?id="+docId,"_blank");
    }

    getPicklistValues(){
        this.showSpinner = true;
        fetchPicklist().then(
            result => {
                this.statusValue = result.status;
                console.log('result.status ', result.status);
                this.showSpinner = false;         
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showSpinner = false;
            this.showToast('Error!','Please Contact System Administrator for more details','error');
        }); 
    }

    handleInput(event){
        console.log('event.targert.checked : ', event.target.checked);
        var data = JSON.parse(JSON.stringify(this.documentChanges));
        var elementId = event.currentTarget.dataset.id;
        var elementName = event.target.name;
        var elementValue = elementName == 'status' ?event.target.value:event.target.checked;

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

        this.documentChanges = [...data];
    }

    handleSave() {
        this.showSpinner = true
        var data = [...this.documentChanges];
        console.log('save child : ', JSON.parse(JSON.stringify(data)));
        saveDocumentChangesRP({jsonData: JSON.stringify(data)}).then(
            result => {
                console.log('saved this>',result);
                this.editMode = false;
                this.showSpinner = false;
                if(data)
                this.tableData = [...data];
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showSpinner = false;
            this.showToast('Error!','Please Contact System Administrator for more details','error');
        });
    }
}