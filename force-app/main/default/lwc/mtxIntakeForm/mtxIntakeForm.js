import { LightningElement, track, wire, api } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTravelInfo from '@salesforce/apex/MtxIntakeFormController.getTravelInfo';
import getSymptomInfo from '@salesforce/apex/MtxIntakeFormController.getSymptomInfo';

export default class MtxIntakeForm extends LightningElement {
    @api subjectId;
    @api currentStep = 1;
    @api originalStep = 1;
    @track showSpinner = false;
    @track showInstructionsPage = false;
    @track showTravelerInformation = false;
    @track showAddressInformation = false;
    @track showGuardianInformation = false;
    @track showTravelInformation = false;
    @track showSymptoms = false;
    @track showConsent = false;
    @track showThankYouScreen = false;
    @track footerText = "Copyright © 2020 Massachusetts Department of Elementary & Secondary Education - All rights reserved.";
    @track travelInfoId;
    @track consentId;
    @track symptomsId;

    connectedCallback() {
        this.showInstructionsPage = true;
        registerListener("handleSideBarClick", this.handleSideBarClick, this);
        // this.showTravelerInformation = true;
    }

    handleUpdateExisting(event) {
        // this.subjectId
        // this.getTravelInformation();
        // this.getSymptomInformation();
    }

    getTravelInformation() {
        getTravelInfo({ subjectId: this.subjectId })
            .then(result => {
                console.log('travelIdresult>' + result);
                if (result) {
                    this.travelInfoId = result;
                }
            })
            .catch(error => {
                console.log('error.body.message>>', error.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error getting Travel record',
                        variant: 'error'
                    })
                );
            }).finally(() => {
                this.showSpinner = false;
            });
    }

    getSymptomInformation() {
        getSymptomInfo({ subjectId: this.subjectId })
            .then(result => {
                if (result) {
                    this.symptomsId = result;
                }
            })
            .catch(error => {
                console.log('error.body.message>>', error.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error getting Travel record',
                        variant: 'error'
                    })
                );
            }).finally(() => {
                this.showSpinner = false;
            });
    }


    hideComponents() {
        this.showInstructionsPage = false;
        this.showTravelerInformation = false;
        this.showAddressInformation = false;
        this.showGuardianInformation = false;
        this.showTravelInformation = false;
        this.showSymptoms = false;
        this.showThankYouScreen = false;
        this.showConsent = false;
    }

    navigateToInstructions() {
        this.currentStep = 1;
        this.hideComponents();
        this.showInstructionsPage = true;
    }

    navigateToAddressInfo(event) {
        console.log(event.detail);
        this.subjectId = event.detail;
        this.currentStep = 3;
        this.hideComponents();
        this.showAddressInformation = true;
    }

    navigateToTravelerInfo() {
        this.currentStep = 2;
        this.hideComponents();
        this.showTravelerInformation = true;

    }

    navigateToGuardianInfo() {
        this.currentStep = 4;
        this.hideComponents();
        this.showGuardianInformation = true;
    }

    navigateToAddressFromGuardian() {
        this.currentStep = 3;
        this.hideComponents();
        this.showAddressInformation = true;
    }

    navigateToTravelInfo() {
        console.log('this.travelInfoId>>' + this.travelInfoId);
        this.currentStep = 5;
        this.hideComponents();
        this.showTravelInformation = true;
    }

    navigateToShowSymptoms(event) {
        this.currentStep = 6;
        this.hideComponents();
        this.showSymptoms = true;
        if (event.detail) {
            this.travelInfoId = event.detail;
        }
    }

    navigateToShowConsent(event) {
        this.currentStep = 7;
        this.hideComponents();
        this.showConsent = true;
        if (event.detail) {
            this.symptomsId = event.detail;
        }
    }

    navigateToThankYou(event) {
        this.hideComponents();
        this.showThankYouScreen = true;

    }

    handleSideBarClick(currentStep) {
        this.currentStep = currentStep;
        this.hideComponents();

        switch (currentStep) {
            case 1: {
                this.showInstructionsPage = true;
                break;
            }
            case 2: {
                this.showTravelerInformation = true;
                break;
            }
            case 3: {
                this.showAddressInformation = true;
                break;
            }
            case 4: {
                this.showGuardianInformation = true;
                break;
            }
            case 5: {
                this.showTravelInformation = true;
                break;
            }
            case 6: {
                this.showSymptoms = true;
                break;
            }
            case 7: {
                this.showConsent = true;
                break;
            }
        }
    }
}