import { api, LightningElement} from 'lwc';

export default class Dese_homepage extends LightningElement {
    @api currentStep;
    get step1CSS() {
        if (this.currentStep == 1) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 1) {
            return 'slds-progress__item slds-is-completed';
        }
    }
    get step2CSS() {
        if (this.currentStep == 2) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 2) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }
    get step3CSS() {
        if (this.currentStep == 3) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 3) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }
    get step4CSS() {
        if (this.currentStep == 4) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 4) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }

    get step5CSS() {
        if (this.currentStep == 5) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 5) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }
    get step6CSS() {
        if (this.currentStep == 6) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 6) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }
    get step7CSS() {
        if (this.currentStep == 7) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 7) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }
    get step8CSS() {
        if (this.currentStep == 8) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 8) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }
    get step9CSS() {
        if (this.currentStep == 9) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 9) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }
    get step10CSS() {
        if (this.currentStep == 10) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 10) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }

    get step11CSS() {
        if (this.currentStep == 11) {
            return 'slds-progress__item slds-is-active';
        }
        else if (this.currentStep > 11) {
            return 'slds-progress__item slds-is-completed';
        }
        else{
            return 'slds-progress__item';
        }
    }

    handleStep(event) {
        let currentStep = (event.currentTarget.dataset.id);
        console.log(currentStep);
        this.currentStep = parseInt(currentStep);
        event.preventDefault();
        const selectedEvent = new CustomEvent('selected', { detail: currentStep });
        this.dispatchEvent(selectedEvent);
    }
}