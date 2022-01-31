import { LightningElement, api, track } from 'lwc';
import ConfirmationMessage from '@salesforce/label/c.NYS_DOH_Confirmation';

export default class NysdohConfirmation extends LightningElement {
    @api volunteer;
    @track showConfirmationMessage = ConfirmationMessage;
    handlesubmit() {
        event.preventDefault();
        const fields = event.detail.fields;
        let vol = JSON.parse(JSON.stringify(this.volunteer));
        fields.Status__c = 'Submitted';
        this.volunteer = vol;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(){
        this.dispatchEvent(new CustomEvent('thankyou', {
            detail: this.volunteer
        }));
    }
    goBack(){
        this.dispatchEvent(new CustomEvent('prev', {
            detail: this.volunteer
        }));
    }
}