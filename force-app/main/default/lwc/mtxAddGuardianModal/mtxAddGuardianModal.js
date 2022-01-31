import { LightningElement, track, api } from 'lwc';

export default class MtxAddGuardianModal extends LightningElement {
    @api subjectId;
    @api guardianId;
    @track recordTypeId;
    guardianData;

    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('hidemodal'));
    }

    handleAddGuardian(event) {
        console.log('In function');
        event.preventDefault();
        const fields = event.detail.fields;
        console.log('Out of if>>', fields['First_Name__c']);
        fields['Subject__c'] = this.subjectId;
        console.log('fields here', JSON.parse(JSON.stringify(fields)));

        this.guardianData = JSON.parse(JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);

    }

    handleSuccess(event) {
        console.log('Guardian added', event);
        this.dispatchEvent(new CustomEvent('hidemodalwithdata'));
    }
}