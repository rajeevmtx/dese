import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, createRecord } from "lightning/uiRecordApi";
import fetchRequestPermitType from '@salesforce/apex/PSRContractorInformationController.getAccountInformation';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import USER_ID from "@salesforce/user/Id";
import CASE_OBJECT from '@salesforce/schema/Case';
import Portal_New_Case_Help_Text from '@salesforce/label/c.Portal_New_Case_Help_Text';

export default class PsrNewCase extends LightningElement {
    objectApiName = "Case";
    @track CASE_OBJECT = CASE_OBJECT;
    @track accountInformation = {};
    @api Portal_New_Case_Help_Text = Portal_New_Case_Help_Text;
    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user;

    @track fields = {};
    get contactId() {
        return getFieldValue(this.user.data, CONTACT_ID);
    }

    constructor() {
        super();
        this.loadData();
    }

    loadData() {
        fetchRequestPermitType()
            .then(result => {
                this.accountInformation = result;
                console.log(JSON.stringify(this.accountInformation));

            });
    }

    handleFormSubmit(event) {
        event.preventDefault();
        let fields = JSON.parse(JSON.stringify(event.detail.fields));
        fields.ContactId = this.contactId;
        fields.AccountId = this.accountInformation.Id;
        fields.Origin = 'Web';
        fields.Status = 'New';
        this.fields = fields;

        this.template.querySelector("lightning-record-edit-form").submit(fields);
    }

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Case successfully created',
                variant: 'success'
            })
        );
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: this.fields }));
    }

    handleSave(event) {
        this.template.querySelector('lightning-record-edit-form').submit();
    }
}