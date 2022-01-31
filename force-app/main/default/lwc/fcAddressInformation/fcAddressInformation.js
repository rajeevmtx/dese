import { LightningElement,api,track } from 'lwc'; 

export default class FcAddressInformation extends LightningElement {
    @track dataObj = {};
    @track helpTextVerification = 'Please enter the home address of the child, guardian or someone who is legally responsible for the child.';
    @track cityValidation = 'Enter a Valid City Name';
    @track zipCodeValidation = 'Enter a Valid Zip Code';
    handleInput(event){
        if( event.target.name === 'streetaddressline1' ){
            event.target.value = event.target.value.trim();
            this.dataObj.streetaddressline1 = event.target.value;
        }
        else if( event.target.name === 'streetaddressline2' ){
            event.target.value = event.target.value.trim();
            this.dataObj.streetaddressline2 = event.target.value;
        }
        else if( event.target.name === 'city' ){
            event.target.value = event.target.value.trim();
            this.dataObj.city = event.target.value;
        }
        else if( event.target.name === 'state' ){
            this.dataObj.state = event.target.value;
        }
        else if( event.target.name === 'zipcode' ){
            event.target.value = event.target.value.trim();
            this.dataObj.zipcode = event.target.value;
        }
    }

    @api
    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        return valid;
    }

    @api
    getData(){ 
        return this.dataObj;
    }
}