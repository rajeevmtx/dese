import {
    LightningElement, 
    track,
    api
} from 'lwc';
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import customSR from '@salesforce/resourceUrl/NM_FormStyles';
import createCaseForInternal from '@salesforce/apex/FC_ChildIntakeFormController.createCaseForInternal';
import updateCase from '@salesforce/apex/FC_ChildIntakeFormController.updateCase';
import saveAdditionalInformation from '@salesforce/apex/FC_ChildIntakeFormController.saveAdditionalInformation';


export default class FcChildIntakeFormInternal extends LightningElement {
    @api subjectId;
    @api currentStep = 1; 
    @api originalStep = 1;

    @track FC_Intake_Form_Internal = 'Foster Child Care Intake Form';

    //Track Variables
    @track showSpinner = false;
    @track showChildInformation = 'display: block';
    @track showAdditionalInformation = 'display: none';
    @track showPartyInvolved = 'display: none';
    @track showAddressInformation = 'display: none';
    @track isThankYou = 'display: none';
    @track wizardData = {};
    @track additionalInformationData = [];
    @track caseId = undefined;
    @track isAdditionInfoInserted = false;

    //Non-active variable

    //Custom Labels


    //Hide Component on LWC
    hideComponents() {
        this.showChildInformation = 'display: none';
        this.showAdditionalInformation = 'display: none';
        this.showPartyInvolved = 'display: none';
        this.showAddressInformation = 'display: none';
        this.isThankYou = 'display: none';
    }

    //Navigate to Verification
    navigateToChildInformation(event) {
        this.erroMsg = undefined;
        this.currentStep = 1;
        this.hideComponents();
        this.showChildInformation = 'disyplay: block';
    }


    //Navigate to Verification
    navigateToAddressInformation(event) {
        // let verificationWizard = this.template.querySelector('c-fc-additional-information');
        let verificationWizard = this.template.querySelector('c-fc-child-information');
        console.log('verificationWizard.isValid()>>>>', verificationWizard.isValid());
        if (verificationWizard.isValid()) {
            //Fire Search and 
            console.log('Value in Field : ' + JSON.stringify(verificationWizard.getData()));
            var data = verificationWizard.getData();
            this.wizardData.childFirstName = data.firstName;
            this.wizardData.childLastName = data.lastName;
            this.wizardData.ageGroup = data.ageGroup;	
            this.erroMsg = undefined;
            this.currentStep = 2;
            this.hideComponents();
            this.showAddressInformation = 'disyplay: block';
        }
    }

    //Navigate to Verification
    navigateToAdditionalInformation(event) {
        let verificationWizard = this.template.querySelector('c-fc-address-information');
        console.log('verificationWizard.isValid()>>>>', verificationWizard.isValid());
        if (verificationWizard.isValid()) {
            //Fire Search and 
            console.log('Value in Field : ' + JSON.stringify(verificationWizard.getData()));
            var data = verificationWizard.getData();
            this.wizardData.streetaddress = data.streetaddressline1 + '' + data.streetaddressline2;
            this.wizardData.city = data.city;
            this.wizardData.state = data.state;
            this.wizardData.zipcode = data.zipcode;
            this.erroMsg = undefined;
            this.currentStep = 3;
            this.createCaseRecord();
            this.hideComponents();
            this.showAdditionalInformation = 'disyplay: block';
        }
    }

    //Navigate to Contacts
    navigateToPartyInvolved(event) {
        let additionalInformation = this.template.querySelector('c-fc-additional-information');
            console.log('Value in Field : ' + JSON.stringify(additionalInformation.getData()));
            this.additionalInformationData = additionalInformation.getData();
            console.log('this.additionalInformationData>>>', JSON.stringify(this.additionalInformationData));
            this.showSpinner = true;
            this.erroMsg = undefined;
            this.currentStep = 4;
            this.createAdditionalInfoRecord();
            this.hideComponents();
            this.showPartyInvolved = 'disyplay: block';
            this.showSpinner = false;
    }

    //Navigation to Thank You Page
    navigateToThankYou(event) {
        this.currentStep = 5;
        this.hideComponents();
        this.isThankYou = 'disyplay: block';
    }

    createAdditionalInfoRecord(){
        console.log('this.additionalInformationData>>>', JSON.stringify(this.additionalInformationData));
        console.log('this.caseId>>>', this.caseId);
        if(this.caseId != undefined && this.isAdditionInfoInserted == false){
            this.showSpinner = true;
            saveAdditionalInformation({
                jsondata: JSON.stringify(this.additionalInformationData),
                caseId: this.caseId
            })
            .then(result => {
                console.log('Success..!!!');
                this.isAdditionInfoInserted = true;
                this.erroMsg = undefined;
                this.showSpinner = false;
            })
            .catch(error => {
                this.erroMsg = error.message || error.body.message;
                this.showSpinner = false;
            });
            this.showSpinner = false;
        }
    }

    createCaseRecord(){
        if(this.caseId == undefined){
            this.showSpinner = true;
            createCaseForInternal({
                caseData: JSON.stringify(this.wizardData)
            })
            .then(result => {
                this.caseId = result;
                console.log('caseId>>>', this.caseId);
                this.erroMsg = undefined;
                this.showSpinner = false;
            })
            .catch(error => {
                this.erroMsg = error.message || error.body.message;
                this.showSpinner = false;
            });
            this.showSpinner = false;
        }
    }
    saveRecord() {
        this.showSpinner = true;
        console.log('this.caseId>>', this.caseId);
        updateCase({
            caseId: this.caseId
        })
        .then(patientRecord => {
            this.erroMsg = undefined;
            this.navigateToThankYou();
            this.showSpinner = false;
        })
        .catch(error => {
            this.erroMsg = error.message || error.body.message;
            this.showSpinner = false;
        });
    }

    valid(componentName) {
        return this.template.querySelector(componentName).isValid()
    }

    //Rendered Callback
    renderedCallback() {
        Promise.all([
                loadStyle(this, customSR),
            ])
            .then(() => {
                console.log('Files Loaded');
            })
            .catch(error => {
                console.log('Error Loaded ' + error.body.message);
            });
    }
}