import { LightningElement, track, api} from 'lwc';
import { showMessage } from 'c/util';
import fetchRequestPermitType from '@salesforce/apex/PSRContractorInformationController.getAccountInformation';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/Account.Account_Type__c';
import CITY_FIELD from '@salesforce/schema/Account.City_Formula__c';
import PROVDER_AD1_FIELD from '@salesforce/schema/Account.Provider_Address_1__c';
import STATE_FIELD from '@salesforce/schema/Account.State__c';
import ZIP_FIELD from '@salesforce/schema/Account.Provider_Zip_Code__c';

export default class PsrDocumentLibrary extends LightningElement {
    @track currentEvId = "a0a03000000FPYCAA4";
    @track showSpinner=false;
    @track uploadedFileNames;
    @track show1 = false;
    @track show2 = false;
    @track show3 = false;
    @track show4 = false;
    @track show5 = false;
    @track show6 = false;
    @track show7 = false;
    @track accountInformation = {};
    @track obj1 = {
        name:'Devereux CARES Day Program',
        city:'New York',
        phone:'999999999'
    };
    @track obj2 = {
        name:'Devereux Residential Program',
        city:'New York',
        phone:'999999999'
    };
    @track obj3 = {
        name:'Devereux Day Program',
        city:'New York',
        phone:'999999999'
    };
    myFields = [NAME_FIELD, ACCOUNT_TYPE_FIELD, PROVDER_AD1_FIELD, CITY_FIELD, STATE_FIELD, ZIP_FIELD];

    loadData(){
        fetchRequestPermitType()
        .then(result => {
            this.accountInformation = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            showMessage(this, { message: message, messageType: 'error', mode: 'pester' });
        });
    }

    connectedCallback(){
        this.loadData();
    }

    handleSubmit(event) {
        console.log(event.detail);
    }
    handleSuccess(event) {
    }

    viewDiv1(event) {
        let temp = event.target.id;
        console.log(temp.indexOf('show1'));
        if (temp.indexOf('show1') > -1)
        this.show1 = !this.show1;
        if (temp.indexOf('show2') > -1)
        this.show2 = !this.show2;
        if (temp.indexOf('show3') > -1)
        this.show3 = !this.show3;
        if (temp.indexOf('show4') > -1)
        this.show4 = !this.show4;
        if (temp.indexOf('show5') > -1)
        this.show5 = !this.show5;
        if (temp.indexOf('show6') > -1)
        this.show6 = !this.show6;
        if (temp.indexOf('show7') > -1)
        this.show7 = !this.show7;
    }

    @track isManageDocumentOpen = false;
    @track isEmailOpen = false;
    @track isChatterOpen = false;

    openModalManageDocument() {
        this.isManageDocumentOpen = true;
    }
    closeModalManageDocument() {
        this.isManageDocumentOpen = false;
    }
    submitDetailsManageDocument() {
        this.isManageDocumentOpen = false;
    }

    
    openModalEmail() {
        this.isEmailOpen = true;
    }
    closeModalEmail() {
        this.isEmailOpen = false;
    }
    submitDetailsEmail() {
        this.isEmailOpen = false;
    }

    handleUploadFinished(event) {
        this.showSpinner = true;
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.uploadedFileNames = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            if(i==uploadedFiles.length-1)
            this.uploadedFileNames += uploadedFiles[i].name ;
            else
            this.uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        this.showSpinner = false;
    }

    openModalChatter(event) {
       
        //this.currentEvId = event.currentTarget.getAttribute("data-id");
        this.isChatterOpen = true;
    }

    closeModalChatter() {
        this.isChatterOpen = false;
    }

    get fullUrl() {
        let url0 = window.location.protocol+'//'+window.location.hostname;
            let url = '/psr/apex/PsrChatterPage?id=a0a03000000FPZyAAO';
            let completeURL = url0+url;
             //"https://demo-lp.force.com/psr/apex/PsrChatterPage?id=" + this.currentEvId
        return (
            completeURL 
        );
    }

}