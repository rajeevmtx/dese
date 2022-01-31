import { LightningElement, api,track } from 'lwc';

export default class FcHouseholdInfoHomeInfo extends LightningElement {

    @api applicationId;
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

    connectedCallback(){
        console.log('=Household Info Home Info=applicationId==>', this.applicationId);
    }

    optionsforResidence = [
        {'label': 'Own', 'value': 'Own'},
        {'label': 'Rent', 'value': 'Rent'},
        {'label': 'Lease', 'value': 'Lease'}
    ];

    optionsforYesNo = [
        {'label': 'Yes', 'value': 'Yes'},
        {'label': 'No', 'value': 'No'},
    ];

    handleChangeForResidence (event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
    }

    handleChangeForWeapons (event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
    }

    handleChangeForWater (event){
        const selectedOption = event.detail.value;
        console.log(`Option selected with value: ${selectedOption}`);
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