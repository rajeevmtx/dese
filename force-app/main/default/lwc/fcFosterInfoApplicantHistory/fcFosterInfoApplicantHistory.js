import { LightningElement, api, track } from 'lwc';

export default class FcFosterInfoApplicantHistory extends LightningElement {

    @api applicationId;
    @track helpText = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

    optionsforYesNo = [
        {'label': 'Yes', 'value': 'Yes'},
        {'label': 'No', 'value': 'No'},
    ];
    isPreviouslyApproved = false;
    isPreviouslyLicensedToOperate = false;
    isCurrentlyEmployedChildCare = false;
    isPreviouslyDenied = false;
    isPreviouslyLicenseRevoked = false;
    valueForApproved;
    valueForPendingComplaints;
	valueForLicensedtoOperate;
	valueForEmployed;
	valueForPreviousDenial;
	valueForLicenseRevoked;
	valueForExclusion;

    connectedCallback(){
        console.log('Applicant Foster/Adoption History=applicationId==>', this.applicationId);
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

    handleChangeForExclusion(event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
    }

    handleChangeForLicenseRevoked(event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
        if (selectedOption === 'Yes') {
            this.isPreviouslyLicenseRevoked=true;
        }else{
            this.isPreviouslyLicenseRevoked=false;
        }
    }

    handleChangeForPreviousDenial(event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
        if (selectedOption === 'Yes') {
            this.isPreviouslyDenied=true;
        }else{
            this.isPreviouslyDenied=false;
        }
    }

    handleChangeForEmployed(event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
        if (selectedOption === 'Yes') {
            this.isCurrentlyEmployedChildCare=true;
        }else{
            this.isCurrentlyEmployedChildCare=false;
        }
    }

    handleChangeForLicensedtoOperate(event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
        if (selectedOption === 'Yes') {
            this.isPreviouslyLicensedToOperate=true;
            this.valueForLicensedtoOperate='Yes';
        }else{
            this.isPreviouslyLicensedToOperate=false;
            this.valueForLicensedtoOperate = 'No';
        }
    }

    handleChangeForApproved(event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
        if (selectedOption === 'Yes') {
            this.isPreviouslyApproved=true;
            this.valueForApproved='Yes';
        }else{
            this.isPreviouslyApproved=false;
            this.valueForApproved='No';
        }
    }

    handleChangeForPendingComplaints(event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
    }


}