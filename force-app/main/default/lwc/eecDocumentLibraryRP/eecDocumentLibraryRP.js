import { LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getAllDocumentsFor_R_P from "@salesforce/apex/EEC_DocumentLibraryInternal.getAllDocumentsFor_R_P";
import fetchPicklist from "@salesforce/apex/EEC_ReviewLicensingDocumentExtensionLWC.getAllPicklistValue";
import saveDocumentChangesRP from "@salesforce/apex/EEC_DocumentLibraryInternal.saveDocumentChangesRP";
import sendRejectedDocsToProvider from "@salesforce/apex/EEC_DocumentLibraryInternal.sendRejectedDocsToProvider";
import pubsub from 'c/pubsub';

export default class EecDocumentLibraryRP extends LightningElement {
    @api accId;
    @track tableData;
    @track editMode = false;
    @track statusValue = [];
    @track showSpinner;
    @track documentId;
    @track documentTypeName;
    @track viewModalOpen = false;
    @track documentsPresent = false;
    documentChanges = [];

    connectedCallback(){ 
        this.getPicklistValues();
        this.getAllDocuments();  
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
                this.showSpinner = false;         
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showSpinner = false;
            this.showToast('Error!','Please Contact System Administrator for more details','error');
        }); 
    }

    getAllDocuments() {
        getAllDocumentsFor_R_P({accountId: this.accId})
        .then(data => {
            if(data.length > 0) {
                this.documentsPresent = true;
                console.log('docs present RP');
            }
            this.tableData = data;
            this.showSpinner = false;
            console.log('this.showSpinner : ', this.showSpinner);
        })
        .catch(error => {
            console.log('message : ', error);
            this.showSpinner = false;
        });
    }

    // @wire(getAllDocumentsFor_R_P, {accountId:'$accId'})
    // getAllDocumentsFor_R_P({error,data}){
    //     if(data){
    //         console.log('data is : ', data);
    //         if(data.length > 0) {
    //            this.documentsPresent = true;
    //         }
    //         this.tableData = data;
    //     }
    //     else if(error){
    //         console.log('message : ', error);
    //     }
    // }

    handleEdit(){
        this.editMode = true;
        this.documentChanges = [...this.tableData]
    }

    showToast(title,msg,type){
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: type,
        });
        this.dispatchEvent(evt);
    }

    handleCancel(){
        this.editMode = false;
        this.documentChanges = [];
    }

    handleInput(event){
        console.log('event.targert.checked : ', event.target.checked);
        var data = [...JSON.parse(JSON.stringify(this.documentChanges))];
        var elementId = event.currentTarget.dataset.id;
        var elementName = event.target.name;
        var elementValue = elementName == 'status'?event.target.value:event.target.checked;

        if(elementName == 'status'){
            data.find(x => x.documentId === elementId).status = elementValue;
        }else if(elementName == 'docApplicableEditMode'){
            data.find(x => x.documentId === elementId).documentNotApplicable = elementValue;
        } 
        this.documentChanges = [...data];
    }

    handleSave() {
        this.showSpinner = true
        var data = [...this.documentChanges];
        console.log('save this : ', data);
        saveDocumentChangesRP({jsonData: JSON.stringify(data)}).then(
            result => {
                console.log('result>',result);
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

    openViewModal(event) {
        var elementId = event.currentTarget.dataset.id;
        var documentName = event.currentTarget.dataset.name;
        this.documentTypeName = documentName;
        if(elementId){
            this.documentId = elementId;
            this.viewModalOpen = true;
        }
    }

    openUploadDocumentPage(event) {
        console.log('event.currentTarget.id : ', event.currentTarget.id);
        let docId = (event.currentTarget.id).split('-')[0];
        window.open("/apex/EEC_AttachmentSelection?id="+docId,"_blank");
     }

     sendRejectedDocsToProvider() {
        this.showSpinner = true;
        sendRejectedDocsToProvider({accId: this.accId})
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
}