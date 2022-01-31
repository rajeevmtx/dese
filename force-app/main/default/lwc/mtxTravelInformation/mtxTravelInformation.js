import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTravelInfo from '@salesforce/apex/MtxIntakeFormController.getTravelInfo';
export default class MtxTravelInformation extends LightningElement {
    @track travelerHelpText = "Please answer the following questions regarding the traveler's travel in last 14 days.";
    @track showSpinner = true;
    @api subjectId;
    @track travelId = '';

    // idTravel;
    // @wire(getTravelInfo, { subjectId: this.subjectId })
    // idTravel;

    handleOnLoad() {
        this.showSpinner = false;
        //this.getTravelInformation();

    }
    handleFormSubmit(event) {
        this.showSpinner = true;
    }

    handleFormSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            variant: 'success',
            message: 'Details Successfully saved.',
        });
        this.dispatchEvent(toastEvent);
        this.showSpinner = false;
        this.dispatchEvent(new CustomEvent('next', {
            detail: event.detail.id
        }));
    }

    goBack() {
        this.dispatchEvent(new CustomEvent('prev'));
    }
    handleOnError() {
        this.showSpinner = false;
    }

    renderedCallback() {
        //this.travelId = this.idTravel;
        if (this.travelId === '') {
            this.getTravelInformation();
        }
    }

    getTravelInformation() {
        getTravelInfo({ subjectId: this.subjectId })
            .then(result => {
                console.log('travelIdresult>' + result);
                if (result) {
                    this.travelId = result;
                }
            })
            .catch(error => {
                console.log('error.body.message>>', error.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error getting Travel record',
                        variant: 'error'
                    })
                );
            }).finally(() => {
                this.showSpinner = false;
            });
    }
}