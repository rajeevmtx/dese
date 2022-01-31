import { LightningElement, api, track } from 'lwc';

export default class FcFosterInfoAgency extends LightningElement {
    
    @api applicationId;
    @track helpText = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

    connectedCallback(){
        console.log('=County / Agency Name=applicationId==>', this.applicationId);
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