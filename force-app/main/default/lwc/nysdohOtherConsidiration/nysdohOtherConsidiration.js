import { LightningElement,track,api } from 'lwc';
import fetchPicklist from '@salesforce/apex/NYSDOH_RegistrationController.fetchPicklist';
import Other from '@salesforce/label/c.NYS_DOH_Other_Consideration';
export default class NysdohOtherConsidiration extends LightningElement {
    @track showSpinner = false;
    @track distance = [];
    @track travel = [];
    @track child = [];
    @track showOther = Other;
    @api volunteer;
    connectedCallback() {
        
        fetchPicklist( {objectName : 'Volunteer__c', fieldName : 'Distance_Willing_To_Travel__c' } )
        .then(result => {
            this.distance = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Volunteer__c', fieldName : 'Travel_Lodging_Reimbursement_Needed__c' } )
        .then(result => {
            this.travel = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Volunteer__c', fieldName : 'Child_Care_Assistance_Needed__c' } )
        .then(result => {
            this.child = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });
    }

    goNext() {
        this.dispatchEvent(new CustomEvent('next', {
            detail: this.volunteer
        }));
    }

    goBack(){
        this.dispatchEvent(new CustomEvent('prev', {
            detail: this.volunteer
        }));
    }
}