import { LightningElement,track, api  } from 'lwc';

export default class Aps_perpetrate_information extends LightningElement {
    @track dataObj = {};
    @api caseid;
    
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
        if( event.target.name === 'DateTimeIncident' ){
            //this.dataObj.Date_and_Time_of_Incident = event.target.value;
        }
        else if( event.target.name === 'Street' ){
            //this.dataObj.Street = event.target.value;
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