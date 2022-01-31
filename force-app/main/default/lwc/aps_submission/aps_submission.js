import { LightningElement,track, api } from 'lwc';

export default class Aps_submission extends LightningElement {
    @track dataObj = {};

    connectedCallback(){

        // fetchPicklist( {objectName : 'Case', fieldName : 'Abuse_Resulted_In__c' } )
        // .then(result => {
        //     this.abuseResultedInOptions = result;
        // })
        // .catch(error => {
        //     let message = error.message || error.body.message;
        //     console.log(message);
        // });

    }

    handleInput(event){        
        if( event.target.name === 'firstCheck' ){
            this.dataObj.firstCheck = event.target.checked;
        }
        else if( event.target.name === 'secondCheck' ){
            this.dataObj.secondCheck = event.target.checked;
        }
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