/**
 * Created by arunm on 22-03-2020.
 */

import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Portal_Add_New_Work_Order_Help_Text from '@salesforce/label/c.Portal_Add_New_Work_Order_Help_Text';

export default class NysdohBid extends LightningElement {
    @track form = {};
    @track headingLabel = "New";
    @api requestId = "";
    @track showSpinner = true;
    objectApiName = "Bid__c";

    @api Portal_Add_New_Work_Order_Help_Text = Portal_Add_New_Work_Order_Help_Text;

    constructor() {
        super();
        this.showSpinner = false;
    }

    handleFormSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Request__c = this.requestId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Bid placed successfully',
                variant: 'success'
            })
        );
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: this.fields }));
    }
}