import {
    LightningElement,
    track,
    api
} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getConsentInfo from '@salesforce/apex/MtxIntakeFormController.getConsentInfo';
import requestConsent from '@salesforce/apex/DC_SendOutboundMessageController.requestConsent';

export default class MtxConsentForm extends LightningElement {
    radioButtonValueSelected = false;
    @track travelerHelpText = "Please answer the following questions for us to be able to follow up via text or automated phone calls every 12 hours. The automated message will ask if you are noticing any symptoms.";
    @track consentValue;
    @track showSpinner = true;
    @track date;
    @api subjectId;
    @api consentId;
    connectedCallback() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        this.date = mm + '/' + dd + '/' + yyyy;
        getConsentInfo({ subjectId: this.subjectId })
            .then(result => {
                if (result) {
                    this.consentValue = result;
                    this.value = result;
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
            });
    }
    get options() {
        return [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        },
        ];
    }
    handleRadioButtonOnChange(event) {
        this.consentValue = event.detail.value;
        this.radioButtonValueSelected = true;
    }
    handleOnLoad() {
        this.showSpinner = false;

    }
    handleFormSubmit(event) {
        if (this.radioButtonValueSelected === true) {
            this.showSpinner = true;
        }
    }

    handleFormSuccess(event) {
        if (this.radioButtonValueSelected === true) {

            const toastEvent = new ShowToastEvent({
                title: 'Success',
                variant: 'success',
                message: 'Details Successfully saved.',
            });
            this.dispatchEvent(toastEvent);
            this.showSpinner = false;
            console.log('calling twilio');
            requestConsent({ subjectId: this.subjectId })
                .then(result => {
                    console.log('called twilio');
                })
                .catch(error => {
                    console.log('error.body.message>>', error.message);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error sending consent.',
                            variant: 'error'
                        })
                    );
                });
            this.dispatchEvent(new CustomEvent('next', {
                detail: event.detail.id
            }));
        } else {
            const toastEvent = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Consent is required',
            });
            this.dispatchEvent(toastEvent);
        }
    }
    handleOnError() {
        this.showSpinner = false;
    }
    goBack() {
        this.dispatchEvent(new CustomEvent('prev'));
    }
}