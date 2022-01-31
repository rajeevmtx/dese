import { LightningElement, api,track } from 'lwc';

export default class FcHouseholdInfoHomeContactInfo extends LightningElement {
    
    @api applicationId;
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
    @track homeContactInfo = {physicalStreet : '', physicalCity : '' ,physicalCounty : '' , physicalState : '', physicalZipCode : '' ,
                              mailingAddress : '', mailingCity : '',mailingState : '', mailingZip : '', homePhoneNumber: '', physicalSameAsMailing : false};

    connectedCallback(){
        console.log('=Home Contact Info==>', this.applicationId);
    }

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }
    
    @api
    getData(){
        return this.homeContactInfo;
    }

   isMailingAddDiff = false;  

   handleChange(event) {
       if(event.target.name === 'radioGroup' ){
            const selectedOption = event.detail.value;
            console.log(`Option selected with value: ${selectedOption}`);
            if (selectedOption === 'Yes'){
                this.isMailingAddDiff =false;
                this.homeContactInfo.physicalSameAsMailing = true;
            }else {
                this.isMailingAddDiff =true;
                this.homeContactInfo.physicalSameAsMailing = false;
            }
       }else if(event.target.name === 'physicalStreet'){
        this.homeContactInfo.physicalStreet = event.detail.value;
       }else if(event.target.name === 'physicalCity'){
        this.homeContactInfo.physicalCity = event.detail.value;
       }else if(event.target.name === 'physicalCounty'){
        this.homeContactInfo.physicalCounty = event.detail.value;
       }else if(event.target.name === 'physicalState'){
        this.homeContactInfo.physicalState = event.detail.value;
       }else if(event.target.name === 'physicalZipCode'){
        this.homeContactInfo.physicalZipCode = event.detail.value;
       }else if(event.target.name === 'mailingAddress'){
        this.homeContactInfo.mailingAddress = event.detail.value;
       }else if(event.target.name === 'mailingCity'){
        this.homeContactInfo.mailingCity = event.detail.value;
       }else if(event.target.name === 'mailingState'){
        this.homeContactInfo.mailingState = event.detail.value;
       }else if(event.target.name === 'mailingZip'){
        this.homeContactInfo.mailingZip = event.detail.value;
       }else if(event.target.name === 'homePhoneNumber'){
        this.homeContactInfo.homePhoneNumber = event.detail.value;
       }
        
    }

    @api
    isValidInput(){
        let valid = false;
       
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        valid = isAllValid;
        console.log('Valid Input : ' + valid);
        return valid;
    }

    @api
    isValid(callback) {
        let valid = false;
        this.showSpinner = true;
        
        this.showSpinner = false;
        callback({
            applicationId: this.applicationId,
            valid: true
        });             
    }

}