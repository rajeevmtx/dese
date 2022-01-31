import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllDocumentFiles from '@salesforce/apex/EEC_DocumentLibraryInternal.getAllDocumentFiles';
import getAccountAndDocInfo from '@salesforce/apex/EEC_DocumentLibraryInternal.getAccountAndDocInfo';
import getCommunications from '@salesforce/apex/EEC_DocumentLibraryInternal.getCommunications';
import fetchPicklist from "@salesforce/apex/EEC_DocumentLibraryInternal.getAllPicklistValue";
import saveDocuments from "@salesforce/apex/EEC_DocumentLibraryInternal.saveDocuments";
import getAWSCustomSetting from "@salesforce/apex/EEC_DocumentLibraryInternal.getAWSCustomSetting";
import pubsub from 'c/pubsub' ; 
import AWS_SDK from '@salesforce/resourceUrl/AWS_SDK';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class EecViewDocuments extends LightningElement {
    @api docId;
    @api accId;
    @api transactionId;
    @api docName;
    @track documentFiles;
    @track error;
    @track editMode = false;
    @track documentsLoading = false;
    @track statusValue = [];
    @track showSpinner = false;
    @track showEditButtonOnModal = false;
    filesdata = [];
    s3FileUpload;
    awsCustomSetting;
    //urlValue;

    connectedCallback(){
        this.showSpinner = true;
        this.getCustomSetting();
        this.getPicklistValues();
        this.getDocs();
    }

    getPicklistValues(){
        fetchPicklist().then(
            result => {
                this.statusValue = result.status;  
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.showError();
        }); 
    }

    getCustomSetting() {
        getAWSCustomSetting().then(
            result => {
                if(result.length > 0){
                    this.awsCustomSetting = result[0];
                    this.loadAwsScript();
                }
                console.log('this.awsCustomSetting : ', this.awsCustomSetting);
        })
        .catch(error => {
            console.log('error', error);
        })
    }   
    
    loadAwsScript() {
        loadScript(this, AWS_SDK + '/dist/aws-sdk.js').then(()=> {
            this.s3FileUpload = new AWS.S3({
              accessKeyId : this.awsCustomSetting.S3_Key__c,
              secretAccessKey : this.awsCustomSetting.S3_Secret__c,
              signatureVersion: 'v4'
             })
             this.showSpinner = false;
        }).catch( (error) => {
              console.log('error', error);
        })

    }

    handleInput(event){
        var data = JSON.parse(JSON.stringify(this.filesdata));
        var elementId = event.currentTarget.dataset.id;
        var elementName = event.target.name;
        var elementValue = event.target.value;
        
        if(elementName == 'status'){
            data.find(x => x.fileId === elementId).status = elementValue;
        }else if(elementName == 'internalNotes'){
            data.find(x => x.fileId === elementId).internalNotes = elementValue;
        }
        console.log('data>',data);
       this.filesdata = [...data];
    }

    getDocs(){
        this.documentsLoading = true;
        getAllDocumentFiles({docId : this.docId})
        .then(result => {
            if(result.length > 0){
             console.log('result>',result);
             this.documentFiles = result;
             this.filesdata = [...result];

             getAccountAndDocInfo({docId : this.docId , accId : this.accId})
                .then(result =>{
                    console.log('^^^^'+result);
                    if(result == true){
                        this.showEditButtonOnModal = false;
                    }else{
                        this.showEditButtonOnModal = true;
                    }
                })
                .catch(error => {
                    console.log('error : ', error);
                    this.showError();
                    this.error = error;
                });

            } 
            console.log('documentFiles are', this.documentFiles);
        })
        .catch(error => {
            console.log('error : ', error);
            this.showError();
            this.error = error;
        });
 
        //getting the Tasks related to the Document  
        getCommunications({docId : this.docId})
        .then(tasks => {
            if(tasks.length > 0){
             this.documentTasks = [...tasks];
            } 
            this.documentsLoading = false;
            console.log('tasks are', this.documentTasks);
        })
        .catch(error => {
            console.log('error : ', error);
            this.showError();
            this.error = error;
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

    handleEdit(){
        this.filesdata = [...this.documentFiles];
        this.editMode = true;
    }
    handleSave(){
        this.showSpinner = true;
        var filedata = [...this.filesdata];
        saveDocuments({jsonData: JSON.stringify(filedata)}).then(
            result => {
                console.log('result>',result);
                this.editMode = false;
                this.showSpinner = false;
                this.documentFiles = [...this.filesdata];
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
            this.documentsLoading = false;
            this.showError();
        }); 
        
    }
    handleCancel(){
        this.filesdata = [];
        this.editMode = false;
    }
    closeModal(){
        this.documentFiles = [];
        this.filesdata = [];
        let message = {
            "message" : ''
        }
        pubsub.fire('closemodal', message ); 
    }

    emailProvider() {
        console.log('this.accId : ', this.accId);
        console.log('currentUrl : ', window.location.href);
        var currentUrl = window.location.href;

        console.log('transactionId : ', this.transactionId);
        console.log('accId : ', this.accId);
        //window.open("/apex/EEC_CustomEmailPage?docId="+this.docId+"&accId="+this.accId+"&url=https://eec-lead--dev.lightning.force.com/lightning/r/Account/0011100001zGEkdAAG/view?0.source=alohaHeadertype='P'","_blank");
        if(this.accId != undefined) {
            window.open("/apex/EEC_CustomEmailPage?docId="+this.docId+"&accId="+this.accId+"&url="+currentUrl+"?0.source=alohaHeadertype='P'","_blank");
        } else if(this.transactionId != undefined) {
            window.open("/apex/EEC_CustomEmailPage?docId="+this.docId+"&ltId="+this.transactionId+"&url="+currentUrl+"?0.source=alohaHeadertype='L'","_blank");
        }
    }

    openUploadedS3File(event) {
        var data = [...JSON.parse(JSON.stringify(this.documentFiles))];
        var elementId = event.currentTarget.dataset.id;
        var prefix = data.find(x => x.fileId === elementId).prefix;
        var fileName = data.find(x => x.fileId === elementId).fileName;
        var documentUrl = data.find(x => x.fileId === elementId).documentUrl;
        var fileNameTemp = prefix + '/' + fileName;
        console.log('fileNameTemp : ', fileNameTemp);

        if(fileName === 'tax-certification-statement') {
            window.open(documentUrl, "_blank");
        } else {
            if(fileNameTemp == '' || fileNameTemp == undefined || fileNameTemp == null) {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'No File Found',
                    variant: 'error',
                    mode: 'dismissable'    
                });
                this.dispatchEvent(event);
            }
            const params = { Bucket: this.awsCustomSetting.S3_New_Bucket_Name__c , Key: fileNameTemp};
            this.s3FileUpload.getSignedUrl('getObject', params, function (err, url) {
                if (err) {
                    throw err;
                }
                window.open(url, "_blank");
            });

        }
    }
}