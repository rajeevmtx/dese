import { LightningElement } from 'lwc';
import createUser from '@salesforce/apex/DESE_UserRegistrationController.createPortalUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import desetheme from '@salesforce/resourceUrl/DESE_Design';

export default class Dese_user_registration extends LightningElement {
    MailingCity;
    MailingCountry;
    MailingPostalCode;
    MailingState;
    MailingStreet;
    FirstName;
    LastName;
    Phone;
    Email;
    orgName;
    loginImages = desetheme + '/theme/images/loginBg.png';
    faceBook = desetheme + '/theme/images/faceBook-Icon.jpg';
    gmail = desetheme + '/theme/images/gmail-Icon.jpg';
    google = desetheme + '/theme/images/google-icon.jpg';
    showSpinner = false;
    handleGenericChange(event){
        let changeName = event.target.name;

        if(changeName == 'FirstName'){
            this.FirstName = event.detail.value;
        }
        if(changeName == 'LastName'){
            this.LastName = event.detail.value;
        }
        if(changeName == 'Phone'){
            this.Phone = event.detail.value;
        }
        if(changeName == 'Email'){
            this.Email = event.detail.value;
        }
        if(changeName == 'orgName'){
            this.orgName = event.detail.value;
        }

        
        
    }

    addressInputChange( event ) {

        this.MailingStreet = event.target.street;
        this.MailingCity =  event.target.city;
        this.MailingState = event.target.province;
        this.MailingCountry = event.target.country;
        this.MailingPostalCode = event.target.postalCode;

    }

    handleSubmit(){
        this.showSpinner = true;
        var wrapper = {
            firstName : this.FirstName,
            lastName : this.LastName,
            email : this.Email,
            phone : this.phone,
            street : this.MailingStreet,
            city : this.MailingCity,
            state : this.MailingState,
            country : this.MailingCountry,
            postalcode : this.MailingPostalCode,
            orgName : this.orgName,
        };
        createUser({
            wrapperJSON : JSON.stringify(wrapper)
        })
        .then( data => {
            if(data != ''){
                const event = new ShowToastEvent({
                    title: 'Error !!',
                    variant : 'error',
                    message: data,
                });
                this.dispatchEvent(event);
            } else{
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant : 'success',
                    message: 'User Successfully Created in the system.',
                });
                this.dispatchEvent(event);
                window.open('/dese/s/login','_self');
            }
        })
        .catch( error => {
            console.log(JSON.stringify(error));
            const event = new ShowToastEvent({
                title: 'Error!!',
                variant : 'error',
                message: error.body.message,
            });
            this.dispatchEvent(event);
        })
        .finally(()=>{
            this.showSpinner = false;
        })
    }
}