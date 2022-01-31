import { LightningElement, track, api } from 'lwc';

export default class FcApplicantRelationship extends LightningElement {
    @track obj = {};
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
    @track relationshipOptions = [
        { label: 'Married', value: 'Married' },
        { label: 'Domestic partnership', value: 'Domestic partnership' },
        { label: 'Related (family member)', value: 'Related (family member)' },
        { label: 'Cohabitants', value: 'Cohabitants' },
        { label: 'Other', value: 'Other' },
    ];
    @track isPreviouslyApproved = false;
    @track isRelationshipSpecified = false;
    @track isOtherRelationship = false;

    @api
    isValid(callback) {

        let valid = true;
        this.showSpinner = true;
 
        // let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
        //     input.reportValidity();
        //     return validSoFar && input.checkValidity();
        // }, true);

        // isAllValid &= [
        //     ...this.template.querySelectorAll("lightning-radio-group")
        // ].reduce((validSoFar, input) => {
        //     input.reportValidity();
        //     return validSoFar && input.checkValidity();
        // }, true);

        // if (isAllValid) {
        //     valid = true;
        // } else {
        //     valid = false;
        // }

        this.showSpinner = false;
        callback({
            applicationId: this.applicationId,
            valid: valid
        });             
    }

    handleInputChange(event) {
        switch(event.target.name) {
            case 'relationship': {
                this.obj.relationship = event.target.value;
                this.hideComponents();
                switch(this.obj.relationship) {
                    case 'Married': {
                        this.isPreviouslyApproved = true;
                        this.isRelationshipSpecified = true;
                        break;
                    }
                    case 'Domestic partnership': {
                        this.isPreviouslyApproved = true;
                        this.isRelationshipSpecified = true;
                        break;
                    }
                    case 'Other': {
                        this.isPreviouslyApproved = true;
                        this.isOtherRelationship = true;
                        break;
                    }
                    default: {
                        this.isPreviouslyApproved = false;
                    }
                }
                break;
            }
            case 'date': {
                this.obj.date = event.target.value;
                break;
            }
            case 'placePartnership': {
                this.obj.placePartnership = event.target.value;
                break;
            }
            case 'otherRelationship': {
                this.obj.otherRelationship = event.target.value;
                break;
            }
        }
    }

    hideComponents() {
        this.isPreviouslyApproved = false;
        this.isRelationshipSpecified = false;
        this.isOtherRelationship = false;
    }
}