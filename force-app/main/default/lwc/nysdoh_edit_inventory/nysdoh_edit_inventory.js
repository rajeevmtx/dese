import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nysdoh_edit_inventory extends LightningElement {
    @api recid;
    @api invname;
    @track showSpinner = true;

    constructor() {
        super();
        this.showSpinner = false;
    }

    handleFormSubmit(event) {
        this.showSpinner = true;

        event.preventDefault();
        const fields = event.detail.fields;
        fields.Id = this.recid;
        
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleError(error){
        this.showSpinner = false;
        console.log('-handleError-'+JSON.stringify(error) );
    }

    handleSuccess() {
        this.showSpinner = false;
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Inventory has benn updated successfully.',
                variant: 'success'
            })
        );
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}