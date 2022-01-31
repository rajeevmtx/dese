import { LightningElement, api,track } from 'lwc';

export default class FcApplicantInfoEmployment extends LightningElement {
    optionsForEmployment = [
        {'label': 'Employed full time', 'value': 'Employed full time'},
        {'label': 'Employed part time', 'value': 'Employed part time'},
        {'label': 'Not employed', 'value': 'Not employed'},
        {'label': 'Self employed', 'value': 'Self employed'},
        {'label': 'Student not working', 'value': 'Student not working'},
    ];

    showEmploymentInfo = false;
    @api applicationId;
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

    connectedCallback(){
        console.log('=Applicant Employment=applicationId==>', this.applicationId);
    }

    handleChange(event) {
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
        if (selectedOption === 'Employed full time' || selectedOption === 'Employed part time' ||  selectedOption === 'Self employed') {
            this.showEmploymentInfo = true;
        } else{
            this.showEmploymentInfo = false;
        }
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