import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import getSymptomInfo from '@salesforce/apex/MtxIntakeFormController.getSymptomInfo';
export default class MtxSymptomsInformation extends LightningElement {
    @api symptomsHelpText = "Please provide your personal details below with accurate information in case we need to contact you.";
    @track showSpinner = true;
    @api subjectId;
    @track symptomsId;

    connectedCallback() {
        this.getSymptomInformation();
    }

    getSymptomInformation() {
        getSymptomInfo({ subjectId: this.subjectId })
            .then(result => {
                if (result) {
                    this.symptomsId = result;
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

    handleOnLoad() {
        this.showSpinner = false;
        console.log('handleOnLoad')
    }
    handleFormSubmit(event) {
        this.showSpinner = true;
        console.log('handleFormSubmit');

        let anySymptomPresent = event.detail.fields.Abdominal_Pain__c || event.detail.fields.Chills__c ||
            event.detail.fields.Cough__c || event.detail.fields.Fever__c ||
            event.detail.fields.Headache__c || event.detail.fields.Muscle_Aches__c ||
            event.detail.fields.Sore_Throat__c || event.detail.fields.Vomiting__c ||
            event.detail.fields.Fever__c || event.detail.fields.Difficulty_Breathing__c;

        console.log('anySymptomPresent>>' + anySymptomPresent);

        const fields = {};
        fields['Id'] = this.subjectId;
        if (anySymptomPresent) {
            fields['Symptom__c'] = true;
        }
        else {
            fields['Symptom__c'] = false;
        }
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => { })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Subject record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });


    }

    handleFormSuccess(event) {
        console.log('handleFormSuccess');
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
        console.log('handleOnError');
        this.showSpinner = false;
    }
}