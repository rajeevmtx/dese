import { LightningElement, track, wire, api } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";

export default class NysdohRegistration extends LightningElement {
    
    @api subjectId;
    @api currentStep = 1;
    @api originalStep = 1;
    @track showSpinner = false;
    @track showPersonalInformation = false;
    @track showAddressInformation = false;
    @track showOtherInformation = false;
    @track showConfirmation =false;
    @track showThankYouScreen = false;
    @track travelInfoId;
    @track volunteer = {};

    connectedCallback() {
        this.showPersonalInformation = true;
        registerListener("handleSideBarClick", this.handleSideBarClick, this);
    }

    hideComponents(event) {
        if(event) {
            this.volunteer = JSON.parse(JSON.stringify(event.detail));
        }
        this.showPersonalInformation = false;
        this.showOtherInformation = false;
        this.showSymptoms = false;
        this.showAddressInformation = false;
        this.showConfirmation = false;
        this.showThankYouScreen = false;
        // console.log('event',event.detail);
    }

    navigateToPersonalInfo(event) {
        this.currentStep = 1;
        this.hideComponents(event);
        this.showPersonalInformation = true;
    }

    navigateAddressInformation(event) {
        this.currentStep = 2;
        this.hideComponents(event);
        this.showAddressInformation = true;
    }

    navigateToOtherInformation(event) {
        this.currentStep = 3;
        this.hideComponents(event);
        this.showOtherInformation = true;
    }

    navigateToConfirmation(event) {
        this.currentStep = 4;
        this.hideComponents(event);
        this.showConfirmation = true;
    }

    navigateToThankYou(event){
        this.currentStep = 5;
        this.hideComponents(event);
        this.showThankYouScreen = true;
    }

    handleSideBarClick(currentStep) {
        this.currentStep = currentStep;
        this.hideComponents();

        
        switch(currentStep) {
            case 1: {
                this.showPersonalInformation = true;
                break;
            }
            case 2: {
                this.showAddressInformation = true;
                break;
            }
            case 3: {
                this.showOtherInformation = true;
                break;
            }
            case 4: {
                this.showConfirmation = true
                break;
            }
        }
    }
}