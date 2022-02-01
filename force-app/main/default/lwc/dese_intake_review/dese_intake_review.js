import { LightningElement,api } from 'lwc';

export default class Dese_intake_review extends LightningElement {
    @api projectId = '';
    readOnlyValue = true;

    connectedCallback() {
        window.scrollTo(0, 0);
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    handlePrev() {
        this.dispatchEvent(new CustomEvent('previous'));
    }
    handleToggleSection(event){

    }
}