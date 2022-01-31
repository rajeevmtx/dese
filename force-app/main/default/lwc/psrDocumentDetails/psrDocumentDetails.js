import { LightningElement,track,api } from 'lwc';
import getApplicationDocument from "@salesforce/apex/PsrStatusInfo.fetchApplicationDocuments";
import { NavigationMixin } from 'lightning/navigation';
import { utility } from "c/pubsub";
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Application_Document__c.Status__c';
import ID_FIELD from '@salesforce/schema/Application_Document__c.Id';

export default class PsrDocumentDetails extends NavigationMixin(LightningElement) {
    @track appId;
    @track uploadedFiles;
    @track showSpinner = false;
    @api isReadyOnly;
    constructor() {
        super();
        this.appId = utility.getUrlParam('appId');
        console.log(this.appId);

    }

    @api
    get disabledFields() {
        return this.isReadyOnly;
    }
    set disabledFields(value) {
        this.isReadyOnly = value;
    }

    @api submitApplication() {
        return new Promise((resolve, reject) => {
              this.updateStep();
                resolve(true);
        })
    }
    connectedCallback() {
        this.showSpinner = true;
        this.fetchdocuments();
    }
    fetchdocuments(){
        getApplicationDocument({applicationId :this.appId})
        .then(result => {
            console.log(result);
            this.uploadedFiles =result;
            console.log(result);
            this.showSpinner = false;
            this.checkUploaded();
        })
        .catch(error => {
            console.log("**************", error);
            
        });
    }

    checkUploaded(){
        console.log(JSON.parse(JSON.stringify(this.uploadedFiles)));
        if (this.uploadedFiles.filter(file =>  (file.isRequired && file.Status !='Submitted') ).length){
            this.dispatchEvent(new CustomEvent('error'));
        }
        else {
            this.dispatchEvent(new CustomEvent('success'));
        }
    }
    
    handleUploadFinished(event){ 
       this.updateStatus(event);    
    }
    updateStatus(event){
        let recordId =event.target.getAttribute(`data-record`);
        console.log('boom',recordId);
        const fields = {};
            fields[ID_FIELD.fieldApiName] = recordId;
            fields[STATUS_FIELD.fieldApiName] = 'Submitted';
            const recordInput = { fields };
        updateRecord(recordInput)
                .then(() => {
                    this.fetchdocuments();
                })
                .catch(error => {
                });
    }
    handleFileOpen(){
        console.log('fired');
    }
    updateStep() {
        this.utility.setCurrentStep(5, this.appId);
    }
}