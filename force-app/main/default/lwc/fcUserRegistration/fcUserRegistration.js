import {
    LightningElement, 
    track,
    api
} from 'lwc';
import {
    loadStyle
} from 'lightning/platformResourceLoader';
import customSR from '@salesforce/resourceUrl/NM_FormStyles';
import createData from '@salesforce/apex/fc_SelfRegistrationController.createUserData';
import createUser from '@salesforce/apex/fc_SelfRegistrationController.createUserAction';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class FcUserRegistration extends NavigationMixin(LightningElement) {

    @api currentStep = 1; 
    @api originalStep = 1;

    @track title = 'Registration';

    //Track Variables
    @track showSpinner = false;
    @track showRegistrationInformation = true;
    @track showAdditionalInformation = false;
    @track showLoginInformation = false;
    @track passwordMatch = true;
    @track passwordShort = false;
    @track userData = { 'ApplicantType' : 'Single Applicant' };
    @track caseId = undefined;

    get applicantOptions() {
        return [
            { label: 'Single Applicant', value: 'Single Applicant' },
            { label: 'Two Applicants', value: 'Two Applicants' },
        ];
    }
    
    get sourceOptions() {
        return [
            { label: 'Advertisement', value: 'Advertisement' },
            { label: 'Event', value: 'Event' },
            { label: 'Internet Search', value: 'Internet Search' },
            { label: 'I\'m a relative or family friend of a child involved with the foster care system', value: 'I\'m a relative or family friend of a child involved with the foster care system' },
            { label: 'Social Media', value: 'Social Media' },
            { label: 'Transferred from another agency', value: 'Transferred from another agency' },
            { label: 'Word of mouth', value: 'Word of mouth' },
            { label: 'Other', value: 'Other' },
            { label: 'I\'m not sure', value: 'I\'m not sure' },
        ];
    }

    get isSingle() {
        return this.userData.ApplicantType == 'Single Applicant';
    }

    //Non-active variable

    //Custom Labels

    handelInput(event) {

        if(event.target.name === 'applicantType'){
            this.applicantType = event.target.value;
            this.userData.ApplicantType = event.target.value;
        } else if(event.target.name === 'lastName'){
            this.userData.LastName = event.target.value;
        } else if(event.target.name === 'firstName'){
            this.userData.FirstName = event.target.value;
        } else if(event.target.name === 'username'){
            this.userData.Username = event.target.value;
        } else if(event.target.name === 'email'){
            this.userData.Email = event.target.value;
        } else if(event.target.name === 'password'){
            this.userData.Password = event.target.value;
        } else if(event.target.name === 're-password'){
            this.userData.Repassword = event.target.value;
        } else if(event.target.name === 'phoneNumber'){
            this.userData.Phone = event.target.value;
        } else if(event.target.name === 'applicantFirstName'){
            this.userData.ApplicantFirstName = event.target.value;
        } else if(event.target.name === 'applicantLastName'){
            this.userData.ApplicantLastName = event.target.value;
        } else if(event.target.name === 'applicantEmail'){
            this.userData.ApplicantEmail = event.target.value;
        } else if(event.target.name === 'source'){
            this.userData.Source = event.target.value;
        }
    }


    //Hide Component on LWC
    hideComponents() {
        this.showRegistrationInformation = false;
        this.showAdditionalInformation = false;
        this.showLoginInformation = false;
    }

    //Navigate to Additional Information
    navigateToRegistrationInfo(event) {
        this.erroMsg = undefined;
        this.currentStep = 1;
        this.hideComponents();
        this.showRegistrationInformation = true;
    }

    //Navigate to Verification
    navigateToAdditionalInfo(event) {
        if (this.isValid()) {
            this.erroMsg = undefined;
            this.currentStep = 2;
            this.hideComponents();
            this.showAdditionalInformation = true;
        }
    }

    //Navigation to Thank You Page
    navigateToLoginInformation(event) {
        if (this.isValid()) {
            this.erroMsg = undefined;
            this.currentStep = 3;
            this.hideComponents();
            this.showLoginInformation = true;
        }
    }

    saveUser() {
        if (this.isValid()) {
            this.showSpinner = true;
            createData({
                userAttributes: this.userData
                })
                .then(data => {

                    createUser({
                        userAttributes: data
                        })
                        .then(res => {
                            this.erroMsg = undefined;
                            this.showSpinner = false;
        
                            const event = new ShowToastEvent({
                                "title": "Success!",
                                "message": "Registration Successful. Please check you inbox for passowrd.",
                                "variant": "success"
                            });
                            this.dispatchEvent(event);
                            
                            this[NavigationMixin.Navigate]({
                                "type": "standard__webPage",
                                "attributes": {
                                    "url": "/fc/s/login/"
                                }
                            });
        
                        })
                        .catch(error => {
                            this.erroMsg = error.message || error.body.message;
                            this.showSpinner = false;
                        });

                })
                .catch(error => {
                    this.erroMsg = error.message || error.body.message;
                    this.showSpinner = false;
                });
        } else {
            console.log('Validation failed on Screen');
        }
    }

    valid(componentName) {
        return this.template.querySelector(componentName).isValid()
    }

    //Rendered Callback
    renderedCallback() {
        Promise.all([
                loadStyle(this, customSR),
            ])
            .then(() => {
                console.log('Files Loaded');
            })
            .catch(error => {
                console.log('Error Loaded ' + error.body.message);
            });
    }


    @api
    isValid(){
        let valid = false;
        let isAllValidFields = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        let isAllValidRadio = [...this.template.querySelectorAll('lightning-radio-group')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        let isAllValidCombobox = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        this.passwordMatch = true;
        this.passwordShort = false;

        if(this.userData.Password) {
            if(this.userData.Password.length < 8) {
                this.passwordShort = true;
            }
        }

        if(this.userData.Password && this.userData.Repassword) {
            if(this.userData.Password != this.userData.Repassword) {
                this.passwordMatch = false;
            }
        }
        
        valid = isAllValidFields && isAllValidRadio && isAllValidCombobox && !this.passwordShort && this.passwordMatch;
        return valid;
    }

}