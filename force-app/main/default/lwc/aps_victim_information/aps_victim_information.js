import { LightningElement,track,api } from 'lwc';
import fetchPicklist from '@salesforce/apex/AdultProtectiveServiceController.fetchPicklist';

export default class Aps_victim_information extends LightningElement {
    @track dataObj = {};
    @track contact = {};
    @track vulnerabilitiesOptions = [];
    @track vulnerabilitiesOptionsSelected = [];

    get genderOptions() {
        return [{
            label: 'Male',
            value: 'Male'
          },
          {
            label: 'Female',
            value: 'Female'
          },
        ];
      }

      get stateOptions() {
        return [{
            label: 'Alabama',
            value: 'Alabama'
          },
          {
            label: 'Alaska',
            value: 'Alaska'
          },
        ];
      }
      
    connectedCallback(){

        fetchPicklist( {objectName : 'Case', fieldName : 'Vulnerabilities__c' } )
        .then(result => {
            this.vulnerabilitiesOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

    }

    handleInput(event){ 
        if( event.target.name === 'firstName') {
            this.contact.FirstName = event.target.value;
        } else if( event.target.name === 'lastName') {
            this.contact.LastName = event.target.value;
        } else if( event.target.name === 'dob') {
            this.contact.Birthdate = event.target.value;
        } else if( event.target.name === 'gender') {
            this.contact.Sex__c = event.target.value;
        } else if( event.target.name === 'telephoneNumber') {
            this.contact.Phone = event.target.value;
        } else if( event.target.name === 'mailingAddress') {
            this.contact.MailingStreet = event.target.value;
        } else if( event.target.name === 'city') {
            this.contact.MailingCity = event.target.value;
        } else if( event.target.name === 'state') {
            this.contact.MailingState = event.target.value;
        } else if( event.target.name === 'zip') {
            this.contact.MailingPostalCode = event.target.value;
        } else if( event.target.name === 'Vulnerabilities') {
            this.dataObj.vulnerabilities = event.target.value.join(';');
        }
        this.dataObj.contact = this.contact;
    }

    @api
    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        //Temp using true: Use valid variable
        return true;
    }

    @api
    getData(){
        return this.dataObj;
    }
}