/**
 * Created by arunm on 22-03-2020.
 */

import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentUser from '@salesforce/apex/NYSDOH_RequestController.getCurrentUser';
import Portal_Add_New_Work_Order_Help_Text from '@salesforce/label/c.Portal_Add_New_Work_Order_Help_Text';

export default class NysdohRequest extends LightningElement {
    @track form = {};
    @track headingLabel = "New";
    @track showSpinner = true;
    @track accountId = "";
    objectApiName = "Request__c";

    @api Portal_Add_New_Work_Order_Help_Text = Portal_Add_New_Work_Order_Help_Text;

    constructor() {
        super();
        this.showSpinner = false;
        this.setAccountId();
    }

    setAccountId() {
        getCurrentUser()
            .then(res => {
                this.accountId = res.AccountId;
            });
    }

    handleFormSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Hospital__c = this.accountId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Request submitted successfully',
                variant: 'success'
            })
        );
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: this.fields }));
    }
}