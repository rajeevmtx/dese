import { LightningElement, track, api } from 'lwc';
import checkDuplicateSubject from '@salesforce/apex/MtxTravelerInfoController.checkDuplicateSubject';
import { updateRecord } from 'lightning/uiRecordApi';
export default class MtxTravelerInfo extends LightningElement {
    @api travelerHelpText = "Please provide your personal details below with accurate information in case we need to contact you.";
    @track showSpinner = true;
    @track age = "";
    @api subjectId;

    @track errorClass;
    @track invalidTelephone = false;
    @track showDuplicateSubjectModal = false;

    submittedFields;
    duplicateRecordId;

    @track raceOptions = [
        { label: 'White', value: 'White' },
        { label: 'Black', value: 'Black' },
        { label: 'American Indian/Alaskan', value: 'American Indian/Alaskan' },
        { label: 'Asian', value: 'Asian' },
        { label: 'Native Hawaiian/Pacific Islander', value: 'Native Hawaiian/Pacific Islander' },
        { label: 'Other', value: 'Other' },
        { label: 'Unknown', value: 'Unknown' },
    ];

    @track ethnicityOptions = [
        { label: 'Hispanic/Latino', value: 'Hispanic/Latino' },
        { label: 'Not Hispanic/Latino', value: 'Not Hispanic/Latino' },
        { label: 'Unknown', value: 'Unknown' },
    ];

    renderedCallback() {
        // setTimeout(() => {
        //     this.showSpinner = false;
        // }, 1000);
    }

    handleDOBChange(event) {
        console.log('value here', event.detail.value);
        // const dateSelected = new Date(event.detail.value);
        // const todaysDate = new Date();
        // const ageToDisplay = Date.gettodaysDate - dateSelected
    }

    handleFormSubmit(event) {
        event.preventDefault();
        console.log('formSubmit');
        //this.showSpinner = true;

        this.submittedFields = event.detail.fields;

        if (!this.subjectId) {

            checkDuplicateSubject({
                fname: this.submittedFields.First_Name__c, lname: this.submittedFields.Last_Name__c,
                dob: this.submittedFields.Date_of_Birth__c, phone: this.submittedFields.Primary_Cell_Number__c
            })
                .then(result => {
                    console.log('result>>' + result);
                    if (result) {
                        this.showDuplicateSubjectModal = true;
                        this.duplicateRecordId = result;
                    }
                    else {
                        this.template.querySelector('lightning-record-edit-form').submit(this.submittedFields);
                    }
                })
                .catch(error => {
                    console.log('error.body.message>>', error);

                });
        }
        else {
            this.template.querySelector('lightning-record-edit-form').submit(this.submittedFields);
        }

        // console.log('formSubmit');
        // this.showSpinner = true;
        //  event.preventDefault();
        //  const fields = event.detail.fields;
        //  console.log(JSON.stringify(fields));

        //  if(this.telephoneCheck(fields.Primary_Cell_Number__c)){
        //     this.template.querySelector('lightning-record-edit-form').submit(fields);
        //  }else{
        //      this.errorClass = 'slds-has-error';
        //      this.invalidTelephone = true;
        //      return;
        //  }
    }

    handleUpdateExisting() {
        console.log('this.duplicateRecordId>>' + this.duplicateRecordId);
        this.showDuplicateSubjectModal = false;
        let fields = this.submittedFields;
        this.showSpinner = true;
        fields['Id'] = this.duplicateRecordId;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                console.log('rewcord updae');
                this.dispatchEvent(new CustomEvent('next', {
                    detail: this.duplicateRecordId
                }));

                this.dispatchEvent(new CustomEvent('updateexisting', {
                    detail: this.duplicateRecordId
                }));
            })
            .catch(error => {
                console.log(error);
            });
        this.showSpinner = false;
    }

    handleCreateNew() {
        this.showDuplicateSubjectModal = false;
        this.showSpinner = true;
        this.template.querySelector('lightning-record-edit-form').submit(this.submittedFields);
    }

    handleFormSuccess(event) {
        console.log('formSuccess');
        this.showSpinner = false;
        this.dispatchEvent(new CustomEvent('next', {
            detail: event.detail.id
        }));
        console.log('event.detail.id>>' + event.detail.id);
    }

    goBack() {
        this.dispatchEvent(new CustomEvent('prev'));
    }

    handleFormLoad() {
        console.log('form loaded');
        this.showSpinner = false;
    }

    telephoneCheck(str) {
        var patt = new RegExp(/^\s*(?:\+?(\d{0,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4,5})(?: *x(\d+))?\s*$/);
        return patt.test(str);
    }

    checkValidity(event){
        console.log('---checkvalidity---'+event.detail.value);
        console.log('---dataset id---'+JSON.stringify(event.target.dataset));
        var pattern = /^\s+$/;
        var valueEntered = event.detail.value;
        var inputField = event.target.dataset.id;
        var patternMatch = pattern.test(valueEntered);
        console.log('---result---'+pattern.test(valueEntered));
        console.log('---patternMatch---'+patternMatch);
        if(patternMatch == true){
            console.log('---inputField---'+inputField);
            if(inputField == 'firstName'){
                var fieldName = this.template.querySelector(".inputFirstName");
                console.log('---fieldName---'+JSON.stringify(fieldName));
                fieldName.setCustomValidity("Please enter a valid input.");
                fieldName.reportValidity();
            }
            else {
                fieldName.setCustomValidity('');
                fieldName.reportValidity(); 
            }
        }
    }
}