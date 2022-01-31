import { LightningElement, api, track } from 'lwc';
import addressInfoHelpText from '@salesforce/label/c.NYS_DOH_Addresss_Information';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class NysdohAddressInformation extends LightningElement {
    @api helpText = addressInfoHelpText;
    @api volunteer = {};
    @track showSpinner = false;
    @api subjectId;

    handlesubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        let vol = JSON.parse(JSON.stringify(this.volunteer));
        vol.Street_Address_Line_1__c = fields.Street_Address_Line_1__c;
        vol.Street_Address_Line_2__c = fields.Street_Address_Line_2__c;
        vol.City__c = fields.City__c;
        vol.State__c = fields.State__c;
        vol.Zip_Code__c = fields.Zip_Code__c;
        vol.County_pick__c = fields.County_pick__c;
        if(this.telephoneCheck(fields.Zip_Code__c)) {
            this.volunteer = vol;
            this.dispatchEvent(new CustomEvent('next', {
                detail: this.volunteer
            }));
        } else {
            const event = new ShowToastEvent({
                title: 'Error!',
                variant: 'error',
                message: 'Please enter a valid zip code.',
            });
            this.dispatchEvent(event);
        }
    }
    goBack(){
        this.dispatchEvent(new CustomEvent('prev', {
            detail: this.volunteer
        }));
    }

    telephoneCheck(str) {
        var patt = new RegExp(/^\d{5}$|^\d{5}-\d{4}$/);
        return patt.test(str);
    }
}