import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FcPlacementChecklistTable extends LightningElement {
    // @track placementChecklists = [
    //     {
    //         name: 'Verify medical history',
    //         status: 'Complete',
    //         completedDate: '7-22-2020',
    //         allowEdit: true,
    //         pending: false,
    //         complete: true
    //     }, {
    //         name: 'Verify financial status and documentation',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }, {
    //         name: 'Verify references',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }, {
    //         name: 'Conduct home inspection',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }, {
    //         name: 'Verify legal paperwork',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }, {
    //         name: 'Complete documentation review',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }, {
    //         name: 'Request supervisor approval',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }, {
    //         name: 'Supervisor approval',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }, {
    //         name: 'Generate, print and Mail License certification',
    //         status: 'Pending',
    //         completedDate: null,
    //         allowEdit: true,
    //         pending: true,
    //         complete: false
    //     }
    // ]
    @track enableSave;
    @track changedIndex;

    @api fosterParentDetails;
    
    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('closechecklistmodal'));
    }

    get today() {
        let today = new Date();
        return today.getMonth() + 1 + '-' + today.getDate() + '-' + today.getFullYear();
    }

    handleStatusChange(event) {
        this.changedIndex = event.target.getAttribute(`data-index`);
        this.enableSave = true;
        let changedIndex = parseInt(this.changedIndex, 10);
        let today = new Date();

        if (this.placementChecklists[changedIndex].status === 'Pending') {
            this.placementChecklists[changedIndex].status = 'Complete';
            this.placementChecklists[changedIndex].completedDate = today.getMonth() + 1 + '-' + today.getDate() + '-' + today.getFullYear();
            this.placementChecklists[changedIndex].pending = false;
            this.placementChecklists[changedIndex].complete = true;
        } else {
            this.placementChecklists[changedIndex].status = 'Pending';
            this.placementChecklists[changedIndex].completedDate = null;
            this.placementChecklists[changedIndex].pending = true;
            this.placementChecklists[changedIndex].complete = false;
        }
    }

    handleSaveList() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Checklist(s) updated successfully',
            variant: 'success'
        }));
    }
}