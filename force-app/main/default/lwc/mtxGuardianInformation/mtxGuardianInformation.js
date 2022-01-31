import { LightningElement, track, api } from 'lwc';
import intakeGuardianMessage from '@salesforce/label/c.MTX_Intake_Guardian_Message';
import isGuardianMandatory from '@salesforce/apex/MtxGuardianInformationController.isGuardianMandatory';
import getAllGuardian from '@salesforce/apex/MtxGuardianInformationController.getAllGuardian';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MtxGuardianInformation extends LightningElement {
    @api subjectId;
    @api guardianHelpText = "Please provide your personal details below with accurate information in case we need to contact you.";
    @track showAddGuardianModal = false;
    @track guardianData = [];
    @track guardianEmptyMessage = intakeGuardianMessage;
    @track guardianId;

    handleAddGuardian() {
        this.guardianId = '';
        this.showAddGuardianModal = true;
        // show Guardian dialog box
    }

    handleGuardianEdit(event) {
        this.guardianId = event.currentTarget.dataset.id;
        this.showAddGuardianModal = true;
    }

    hideAddGuardianModal() {
        this.showAddGuardianModal = false;
    }

    hideModalAndUpdateData() {
        this.showAddGuardianModal = false;
        this.refreshTableData();
    }

    connectedCallback() {
        this.refreshTableData();
    }

    refreshTableData() {
        console.log('subjectidguardian>' + this.subjectId);
        getAllGuardian({ subjectId: this.subjectId })
            .then(result => {
                console.log(result);
                this.guardianData = [];
                let i;
                for (i = 0; i < result.length; i++) {
                    this.guardianData.push(result[i]);
                }
            })
            .catch(error => {
                console.log('error.body.message>>', error.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error getting Guardian record',
                        variant: 'error'
                    })
                );
            });
    }

    goNext() {
        if (!this.guardianData.length) {
            isGuardianMandatory({ subjectId: this.subjectId })
                .then(result => {
                    cons
                    if (result) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Adding Guardian is mandatory when traveler\'s age is less than 18 ',
                                variant: 'error'
                            })
                        );
                    }
                    else {
                        this.dispatchEvent(new CustomEvent('next'));
                    }
                })
                .catch(error => {
                    console.log('error.body.message>>', error.message);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating Subject record',
                            message: error.message,
                            variant: 'error'
                        })
                    );
                });
        }
        else {
            this.dispatchEvent(new CustomEvent('next'));
        }
    }

    goPrev() {
        this.dispatchEvent(new CustomEvent('prev'));
    }
}