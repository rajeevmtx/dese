/**
 * Created by arunm on 24-03-2020.
 */

import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateAssignmentStatus from '@salesforce/apex/NYSDOH_VolunteerController.updateAssignmentStatus';

export default class NysdohVolunteerAssignmentConfirmation extends LightningElement {

    @api volunteerAssignmentId = "";
    @track showSpinner = false;

    constructor() {
        super();
        this.showSpinner = false;
    }

    acceptRequest() {
        console.log(this.volunteerAssignmentId);
        this.processStatus(true);
    }

    rejectRequest() {
        this.processStatus(false);
    }

    processStatus(status) {

        this.showSpinner = true;
        updateAssignmentStatus( {'volunteerAssignmentId' : this.volunteerAssignmentId, 'status' : status })
        .then(result => {
            if(result) {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Assignment updated successfully',
                        variant: 'success'
                    })
                );
                this.closeModal();
            }
        })
        .catch(error => {
            this.closeModal();
            console.log('Error',error);
        });
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: this.fields }));
    }
}