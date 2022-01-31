import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import customSR from '@salesforce/resourceUrl/NM_FormStyles';
import createCase from '@salesforce/apex/FC_ChildIntakeFormController.createCase';
import updateCase from '@salesforce/apex/FC_ChildIntakeFormController.updateCase';
import updateCaseAbuseData from '@salesforce/apex/FC_ChildIntakeFormController.saveNeglectAbuseData';
import { updateRecord } from 'lightning/uiRecordApi';
import CASE_ID from '@salesforce/schema/Account.Id';
import SIGN_EMOTIONAL from '@salesforce/schema/Case.Signs_of_Emotional_Injury__c';
import SIGN_NEGLECT from '@salesforce/schema/Case.Signs_of_Neglect__c';
import SIGN_PHYSICAL from '@salesforce/schema/Case.Signs_of_Physical_Abuse__c';
import SIGN_SEXUAL from '@salesforce/schema/Case.Signs_of_Sexual_Abuse__c';
import SIGN_DESCRIPTION from '@salesforce/schema/Case.Neglect_and_Abuse_Description__c';



export default class FcChildIntakeForm extends LightningElement {
    @api subjectId;
    @api currentStep = 1;
    @api originalStep = 1;

    @track FC_Intake_Form = 'Report Abuse/Incident';

    //Track Variables
    @track showSpinner = false;
    @track showChildInformation = 'display: block';
    @track showPartyInvolved = 'display: none';
    @track showNeglectAbuse = 'display: none';
    @track showAddressInformation = 'display: none';
    @track isThankYou = 'display: none';
    @track wizardData = {};
    @track caseId = undefined;

    @track abusePageData;

    //Non-active variable

    //Custom Labels


    //Hide Component on LWC
    hideComponents() {
        this.showChildInformation = 'display: none';
        this.showPartyInvolved = 'display: none';
        this.showNeglectAbuse = 'display: none';
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

    navigateToNeglectAbuse(event) {
        let addressInfo = this.template.querySelector('c-fc-address-information');
        if (addressInfo.isValid()) {
            console.log('Value in Field : ' + JSON.stringify(addressInfo.getData()));
            var data = addressInfo.getData();
            this.wizardData.streetaddress = data.streetaddressline1 + '' + data.streetaddressline2;
            this.wizardData.city = data.city;
            this.wizardData.state = data.state;
            this.wizardData.zipcode = data.zipcode;
            this.createCaseRecord();

            this.showSpinner = true;
            this.erroMsg = undefined;
            this.currentStep = 3;
            this.hideComponents();
            this.showNeglectAbuse = 'disyplay: block';
            this.showSpinner = false;
        }
    }

    //Navigate to Contacts
    navigateToPartyInvolved(event) {
        // let addressInfo = this.template.querySelector('c-fc-address-information');
        // if (addressInfo.isValid()) {
        //     console.log('Value in Field : ' + JSON.stringify(addressInfo.getData()));
        //     var data = addressInfo.getData();
        //     this.wizardData.streetaddress = data.streetaddressline1 + '' + data.streetaddressline2;
        //     this.wizardData.city = data.city;
        //     this.wizardData.state = data.state;
        //     this.wizardData.zipcode = data.zipcode;
        //     this.createCaseRecord();

        //     this.showSpinner = true;
        //     this.erroMsg = undefined;
        //     this.currentStep = 3;
        //     this.hideComponents();
        //     this.showPartyInvolved = 'disyplay: block';
        //     this.showSpinner = false;
        // }
        try {
            let isEmpty;
            for (var key in this.abusePageData) {
                if (this.abusePageData[key] !== null && this.abusePageData[key] != "")
                    isEmpty = false;
            }

            if (!isEmpty) {
                this.showSpinner = true;
                const fields = {

                };
                fields[CASE_ID.fieldApiName] = this.caseId;
                fields[SIGN_EMOTIONAL.fieldApiName] = this.abusePageData.signsEmotionalInjury;
                fields[SIGN_NEGLECT.fieldApiName] = this.abusePageData.singsNeglect;
                fields[SIGN_PHYSICAL.fieldApiName] = this.abusePageData.signsPhysicalAbuse;
                fields[SIGN_SEXUAL.fieldApiName] = this.abusePageData.signsSexualAbuse;
                fields[SIGN_DESCRIPTION.fieldApiName] = this.abusePageData.description;


                const recordInput = {
                    fields
                };

                console.log('grand parent: ', JSON.stringify(recordInput));

                updateCaseAbuseData({ caseData: fields })
                    .then(() => {
                        this.showSpinner = false;
                        this.currentStep = 4;
                        this.hideComponents();
                        this.showPartyInvolved = 'disyplay: block';
                    })
                    .catch(error => {
                        this.showSpinner = false;
                        this.currentStep = 4;
                        this.hideComponents();
                        this.showPartyInvolved = 'disyplay: block';
                        console.log('error in saving abuse page -- ' + JSON.stringify(error));
                    });

                // updateRecord(recordInput)
                //     .then((result) => {
                //         console.log('result : ', JSON.stringify(result));
                //         this.showSpinner = false;
                //         this.currentStep = 4;
                //         this.hideComponents();
                //         this.showPartyInvolved = 'disyplay: block';
                //         // showMessage(this, { title: 'Success', message: 'Disabled batch renewal for the Site.', messageType: 'success', mode: 'dismissible' });
                //     })
                //     .catch(error => {
                //         this.showSpinner = false;
                //         this.currentStep = 4;
                //         this.hideComponents();
                //         this.showPartyInvolved = 'disyplay: block';
                //         console.log('error in saving abuse page -- ' + JSON.stringify(error));
                //     });
            } else {
                this.currentStep = 4;
                this.hideComponents();
                this.showPartyInvolved = 'disyplay: block';
                this.showSpinner = false;
            }
        } catch (error) {
            console.log('error: ', error);
            this.currentStep = 4;
            this.hideComponents();
            this.showPartyInvolved = 'disyplay: block';
            this.showSpinner = false;
        }
    }



    //Navigation to Thank You Page
    navigateToThankYou(event) {
        this.currentStep = 4;
        this.hideComponents();
        this.isThankYou = 'disyplay: block';
    }

    createCaseRecord() {
        if (this.caseId == undefined) {
            this.showSpinner = true;
            createCase({
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

    handleAbusePageData(event) {
        this.abusePageData = { ...event.detail };
    }
}