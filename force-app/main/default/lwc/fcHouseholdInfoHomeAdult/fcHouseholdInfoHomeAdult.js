import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import saveAdultInformation from '@salesforce/apex/FcHouseholdInformationController.saveAdultInformation';

export default class FcHouseholdInfoHomeAdult extends LightningElement {
    @api applicationId;
    @track isOpenModal = false;
    @track dataObj = {};
    @track isMinorChildrenInFamilty = false;
    @track adultArray = [];
    @track otherHelpText = 'List all other adults, including adult children of Applicant(s), that are residing  or regularly present in the home. (Please identify Nonminor Dependents placed in your home in the Child / Nonminor Dependent Desired section.)';
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

    @track adultRecord = {
        "name": "",
        "dob": "",
        "relationship": "",
        "residing": "",
        "heading": "Other Adult 1",
        "key": 0,
        "isDelete": false
    }

    handleAddRow = () => {
        let temparr = [...this.adultArray];

        if (temparr.length > 0) {
            this.adultArray.push({
                "name": "",
                "dob": "",
                "relationship": "",
                "residing": "",
                "heading": "Other Adult " + (temparr.length + 1),
                "key": temparr.length,
                "isDelete": false
            });
        } else {
            this.bulletsarr.push({
                "name": "",
                "dob": "",
                "relationship": "",
                "residing": "",
                "heading": "Other Adult 1",
                "key": 1,
                "isDelete": false
            });
        }

    }

    handleRemove(event) {
        if (this.adultArray.length == 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error!!",
                    message: "Atleast one child is required",
                    messageType: 'error',
                })
            );
            return;
        }
        let delIndex = event.currentTarget.dataset.recordId;
        // if (this.adultArray[delIndex]) {
        //     this.adultArray[delIndex].isDelete = true;
        //     return;
        // }

        this.adultArray.splice(delIndex, 1);
    }

    connectedCallback() {
        this.dataObj = {};
        this.dataObj.permitId = this.applicationId;
    }

    @api
    isValid(callback) {
        callback({
            valid: true
        });
        // let valid = false;
        // let isAllValid = false;
        // isAllValid = [
        //     ...this.template.querySelectorAll("lightning-input")
        // ].reduce((validSoFar, input) => {
        //     input.reportValidity();
        //     return validSoFar && input.checkValidity();
        // }, true);

        // isAllValid &= [
        //     ...this.template.querySelectorAll("lightning-radio-group")
        // ].reduce((validSoFar, input) => {
        //     input.reportValidity();
        //     return validSoFar && input.checkValidity();
        // }, true);

        // isAllValid &= [
        //     ...this.template.querySelectorAll("lightning-combobox")
        // ].reduce((validSoFar, input) => {
        //     input.reportValidity();
        //     return validSoFar && input.checkValidity();
        // }, true);


        // valid = isAllValid;
        // console.log("isValid : " + valid);

        // this.dataObj.adultArray = this.adultArray;

        // if (valid) {
        //     saveAdultInformation({
        //             jsonString: JSON.stringify(this.dataObj)
        //         })
        //         .then((result) => {
        //             callback({
        //                 valid: true
        //             });
        //         })
        //         .catch(error => {
        //             console.log('error>>' + JSON.stringify(error));
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     message: JSON.stringify(error),
        //                     variant: "error"
        //                 })
        //             );
        //             callback({
        //                 valid: false
        //             });
        //         });
        // } else {
        //     callback({
        //         valid: false
        //     });
        // }



        // let valid = false;
        // this.showSpinner = true;

        // this.showSpinner = false;
        // callback({
        //     applicationId: this.applicationId,
        //     valid: true
        // });
    }

    get yesNoOption() {
        return [{
                label: 'Yes',
                value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            }

        ];
    }

    onAddOther(){
            this.isOpenModal = true;
    }

    
    handleCloseModal() {
        this.isOpenModal = false;
    }
    handleAddOther(){
        let isValid = true;
        const allValidInputs = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputElement) => {
                inputElement.reportValidity();
                        return validSoFar && inputElement.checkValidity();
            }, true);
        if (! allValidInputs) {
            isValid = false;
        }
        const allValidRadioInputs = [...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((validSoFar, inputElement) => {
                inputElement.reportValidity();
                        return validSoFar && inputElement.checkValidity();
            }, true);
        if (! allValidRadioInputs) {
            isValid = false;
        }

        const allValidSelectInputs = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputElement) => {
                inputElement.reportValidity();
                        return validSoFar && inputElement.checkValidity();
            }, true);
        if (! allValidSelectInputs) {
            isValid = false;
        }

        if(isValid) {
            this.adultArray.push(this.adultRecord);
            this.adultRecord = {
                "name": "",
                "dob": "",
                "relationship": "",
                "residing": "",
                "heading": "Other Adult 1",
                "key": 0,
                "isDelete": false
            }
            this.isOpenModal = false;
        }
    }

    handleModelInput(event){
       
        const otherToAdd = {};
        if (event.target.name === 'name') {
            this.adultRecord.name = event.target.value;
            console.log('inside Name' +  this.adultRecord.name );
        } else if (event.target.name === 'dob') {
            this.adultRecord.dob = event.target.value;
            console.log('inside dob' +  this.adultRecord.dob );
        } else if (event.target.name === 'relationship') {
            this.adultRecord.relationship = event.target.value;
            console.log('inside relationship' +  this.adultRecord.relationship );
        } else if (event.target.name === 'residing') {
            this.adultRecord.residing = event.target.value;
            console.log('inside residing' +  this.adultRecord.residing );
        }
    }

    
    get residingOption() {
        return [{
                label: 'Residing',
                value: 'Residing'
            },
            {
                label: 'Regularly Present',
                value: 'Regularly Present'
            }

        ];
    }

    deleteAdult(event){
        let delIndex = event.currentTarget.dataset.recordId;
        this.adultArray.splice(delIndex, 1);
    }

    get relationShipOptions() {
        return [{
                label: 'Biological Child',
                value: 'Biological Child'
            },
            {
                label: 'No Relation',
                value: 'No Relation'
            },
            // {
            //     label: 'Male',
            //     value: 'Male'
            // }, {
            //     label: 'Male',
            //     value: 'Male'
            // }, {
            //     label: 'Male',
            //     value: 'Male'
            // }, {
            //     label: 'Male',
            //     value: 'Male'
            // }, {
            //     label: 'Male',
            //     value: 'Male'
            // }, {
            //     label: 'Male',
            //     value: 'Male'
            // }, {
            //     label: 'Male',
            //     value: 'Male'
            // }

        ];
    }

    handleInputChange(event) {
        if (event.target.name === 'minorChildrenInFamilty') {
            this.dataObj.minorChildrenInFamilty = event.target.value;
            if (event.target.value == 'Yes') {
                this.isMinorChildrenInFamilty = true;
            } else {
                this.isMinorChildrenInFamilty = false;
            }
        } else if (event.target.name === 'name') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.adultArray[changeIndex].name = event.currentTarget.value;
        } else if (event.target.name === 'dob') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.adultArray[changeIndex].dob = event.currentTarget.value;
        } else if (event.target.name === 'relationship') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.adultArray[changeIndex].relationship = event.currentTarget.value;
        } else if (event.target.name === 'residing') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.adultArray[changeIndex].residing = event.currentTarget.value;
        }
    }





    // @api applicationId;

    // connectedCallback(){
    //     console.log('=Other Adults / Adult Children=applicationId==>', this.applicationId);
    // }

    // @api
    // isValid(callback) {
    //     let valid = false;
    //     this.showSpinner = true;

    //     this.showSpinner = false;
    //     callback({
    //         applicationId: this.applicationId,
    //         valid: true
    //     });             
    // }
}