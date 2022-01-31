import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentStep from "@salesforce/apex/PSR_ApplicationWorkOrderController.fetchWorkOrder";
import Portal_Add_New_Work_Order_Help_Text from '@salesforce/label/c.Portal_Add_New_Work_Order_Help_Text';

export default class PsrWorkOrder extends LightningElement {
    @track form = {};
    @track headingLabel = "New";
    @api workOrderId = "";
    objectApiName = "Application_Work_Order__c";

    @api Portal_Add_New_Work_Order_Help_Text = Portal_Add_New_Work_Order_Help_Text;

    constructor() {
        super();
        if (this.workOrderId && this.workOrderId !== "") {
            this.headingLabel = "Edit";
        } else {
            this.form.Status__c = 'Not Started';
        }
    }

    connectedCallback() {
        getCurrentStep({ workOrderId: this.workOrderId })
        .then(res => {
            if(res.Status__c){
                this.form.Status__c = res.Status__c;
            } else {
                this.form.Status__c = 'Not Started';
            }
            if (this.workOrderId && this.workOrderId !== "") {
                this.headingLabel = "Edit";
            }
        })
        .catch(err => {
            console.error("error here", JSON.stringify(err));
        });
    }

    handleFormInputs(event) {
        if (event.target.name === 'Status__c') {
            this.form.Status__c = event.target.value;
        }
    }

    get statuses() {
        return [
            { label: 'Not Started', value: 'Not Started' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Ready for Review', value: 'Ready for Review' },
        ];
    }

    handleFormSubmit(event) {
        event.preventDefault();

        const fields = event.detail.fields;
        fields.Status__c = this.form.Status__c;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Work order successfully updated',
                variant: 'success'
            })
        );
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: this.fields }));
    }
}