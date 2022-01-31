import { LightningElement } from 'lwc';
import fetchContactDetails from '@salesforce/apex/DESE_MyProfileController.getContactDetails';
import updateContactDetails from '@salesforce/apex/DESE_MyProfileController.updateContactDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deseDesign from '@salesforce/resourceUrl/DESE_Design';

export default class Dese_my_profile extends LightningElement {

    profileImage = deseDesign + '/theme/images/Profile.png';
    showSpinner = false;
    contact = {};
    connectedCallback(){
        this.fetchDetails();
    }

    genderOptions = [
        {
            label : 'Male',
            value : 'Male'
        },
        {
            label : 'Female',
            value : 'Female'
        },
    ]

    fetchDetails(){
        this.showSpinner = true;
        fetchContactDetails().then(data => {
            //this.showSpinner = false;
            this.contact = JSON.parse(data);
            console.log(JSON.stringify(this.contact));
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
        .finally(()=>{
            this.showSpinner = false;
        })
    }

    handleFirstNameChange(event){
        this.contact.FirstName = event.detail.value;
    }

    handleLastNameChange(event){
        this.contact.LastName = event.detail.value;
    }

    handleEmailChange(event){
        this.contact.Email = event.detail.value;
    }
    handlePhoneChange(event){
        this.contact.Phone = event.detail.value;
    }
    

    addressInputChange( event ) {

        this.contact.MailingStreet = event.target.street;
        this.contact.MailingCity =  event.target.city;
        this.contact.MailingState = event.target.province;
        this.contact.MailingCountry = event.target.country;
        this.contact.MailingPostalCode = event.target.postalCode;

    }

    handleMobilePhoneChange(event){
        this.contact.MobilePhone = event.detail.value;
    }

    handleCancel(){
        window.open('/dese/s/','_self');
    }
    handleSave(){
        this.showSpinner = true;
        updateContactDetails({
            contactJSON : JSON.stringify(this.contact)
        })
        .then(data=>{
            if(data == 'SUCCESS'){
                this.fetchDetails();
                const event = new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Details Updated Successfully !!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            }
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }

    handleDistrictChange(event){
        this.contact.District__c = event.detail.value;
    }

    handleGenderChange(event){
        this.contact.Gender__c = event.detail.value;
    }
}