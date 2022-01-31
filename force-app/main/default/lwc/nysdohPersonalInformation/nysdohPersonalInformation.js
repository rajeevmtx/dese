import { LightningElement, api, track } from 'lwc';
import personalInfoHelpText from '@salesforce/label/c.NYS_DOH_Personal_Information';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class NysdohPersonalInformation extends LightningElement {
    @api helpText = personalInfoHelpText;
    @api volunteer = {};
    @track showSpinner = false;
    @api subjectId;
    @track invalidTelephone = false;


    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        let vol = JSON.parse(JSON.stringify(this.volunteer));
        vol.First_Name__c = fields.First_Name__c;
        vol.Last_Name__c = fields.Last_Name__c;
        vol.Phone__c = fields.Phone__c;
        vol.Email__c = fields.Email__c;
        vol.Age__c = fields.Age__c;
        if(this.telephoneCheck(fields.Phone__c)) {
            this.volunteer = vol;
            this.dispatchEvent(new CustomEvent('next', {
                detail: this.volunteer
            }));
        } else {
            const event = new ShowToastEvent({
                title: 'Error!',
                variant: 'error',
                message: 'Please enter a valid phone number.',
            });
            this.dispatchEvent(event);
        }
         
    }

    telephoneCheck(str) {
        var patt = new RegExp(/^\+?1?\s*?\(?\d{3}(?:\)|[-|\s])?\s*?\d{3}[-|\s]?\d{4}$/);
        return patt.test(str);
    }
}