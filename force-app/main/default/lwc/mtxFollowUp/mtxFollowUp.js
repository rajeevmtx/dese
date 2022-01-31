import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

import createSymptoms from '@salesforce/apex/DC_FollowUpController.createSymptoms';

export default class MtxFollowUp extends LightningElement {

    @track temprature = '';
    @track medicineValue = '';
    @track thermometer = '';
    @track subjectId = '';
    @track tempratureInput = 'border margin-top';
    @track show_data = true;
    @track thankYou = false;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.currentPageReference = currentPageReference;
        }
    }
    
    get thermometerType() {
        return [{
                label: 'Fahrenheit',
                value: 'Fahrenheit'
            },
            {
                label: 'Celsius',
                value: 'Celsius'
            },
        ];
    }

    get medicine() {
        return [{
                label: 'Yes',
                value: true
            },
            {
                label: 'No',
                value: false
            },
        ];
    }

    thermometerChange(event) {
        this.thermometer = event.target.value;
    }
    tempratureChange(event) {
        this.temprature = event.target.value;
    }
    medicineValueChange(event) {
        this.medicineValue = event.target.value;
    }

    handleSubmit() {
        this.subjectId = this.currentPageReference.state.id;

        if (this.temprature != '') {

            var newSymptom = {};
            newSymptom.Subject__c = this.subjectId;
            
            this.temprature = parseInt(this.temprature);

            //Convert temparature in Fahrenheit
            if( this.thermometer === 'Celsius'){
                this.temprature = (this.temprature * 9/5) + 32;
            }

            newSymptom.Fever__c = 'Yes';
            newSymptom.Temperature__c = this.temprature;
            newSymptom.Did_you_take_any_anti_fever_medicine__c = this.medicineValue;


            createSymptoms({newSymptoms: JSON.stringify(newSymptom)})
            .then(result => {
                this.show_data = false;
                this.thankYou = true;
            })
            .catch(error => {
                this.error = error;
            });
        }
        else {
            this.tempratureInput = 'border margin-top slds-has-error';
        }
    }
}