import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import saveMinorChildrenInformation from '@salesforce/apex/FcHouseholdInformationController.saveMinorChildrenInformation';

export default class FcHouseholdInfoHomeMinorChildren extends LightningElement {

    @api applicationId;

    @track dataObj = {};
    @track isMinorChildrenInFamilty = false;
    @track openAddMinorChildren;
    @track newMinorChildren;
    @track minorChildArray = [];
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';


    resetNewMinorChildren() {
        this.newMinorChildren = {};
        this.newMinorChildren.nameMinorChild = "";
        this.newMinorChildren.gender = "";
        this.newMinorChildren.dob = null;
        this.newMinorChildren.relationship = "";
        this.newMinorChildren.finantiallySupport = null;
        this.newMinorChildren.heading = "";
        this.newMinorChildren.key = "";
        this.newMinorChildren.isDelete = false;
    }

    handleAddAnotherChildren() {
        this.resetNewMinorChildren();
        this.openAddMinorChildren = true;
    }

    handleSaveAction() {
        let isValid = true;
        // const allValidInputs = [...this.template.querySelectorAll('lightning-input')]
        //     .reduce((validSoFar, inputElement) => {
        //         inputElement.reportValidity();
        //                 return validSoFar && inputElement.checkValidity();
        //     }, true);
        // if (! allValidInputs) {
        //     isValid = false;
        // }
        // const allValidRadioInputs = [...this.template.querySelectorAll('lightning-radio-group')]
        //     .reduce((validSoFar, inputElement) => {
        //         inputElement.reportValidity();
        //                 return validSoFar && inputElement.checkValidity();
        //     }, true);
        // if (! allValidRadioInputs) {
        //     isValid = false;
        // }

        // const allValidSelectInputs = [...this.template.querySelectorAll('lightning-combobox')]
        //     .reduce((validSoFar, inputElement) => {
        //         inputElement.reportValidity();
        //                 return validSoFar && inputElement.checkValidity();
        //     }, true);
        // if (! allValidSelectInputs) {
        //     isValid = false;
        // }

        if(isValid) {
            this.newMinorChildren.key = this.minorChildArray.length;
            this.minorChildArray.push(this.newMinorChildren);
            this.resetNewMinorChildren();
            this.openAddMinorChildren = false;
        }
    }

    closeMinorChildModal() {
        this.resetNewMinorChildren();
        this.openAddMinorChildren = false;
    }

    handleRemoveMinorChild(event) {
        let delIndex = event.currentTarget.dataset.recordId;
        let allChilds = [];
        if(delIndex || delIndex === 0) {
            for(let i = 0; i < this.minorChildArray.length; i ++ ) {
                if(i != delIndex) {
                    this.minorChildArray[i].key = i;
                    allChilds.push(this.minorChildArray[i]);
                }
            }
            this.minorChildArray = allChilds;
        }
    }

    handleAddRow = () => {
        let temparr = [...this.minorChildArray];

        if (temparr.length > 0) {
            this.minorChildArray.push({
                "nameMinorChild": "",
                "gender": "",
                "dob": "",
                "relationship": "",
                "finantiallySupport": "",
                "heading": "Minor Child " + (temparr.length + 1),
                "key": temparr.length,
                "isDelete": false
            });
        } else {
            this.minorChildArray.push({
                "nameMinorChild": "",
                "gender": "",
                "dob": "",
                "relationship": "",
                "finantiallySupport": "",
                "heading": "Minor Child 1",
                "key": 1,
                "isDelete": false
            });
        }

    }

    handleRemove(event) {
        if (this.minorChildArray.length == 1) {
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
        // if (this.minorChildArray[delIndex]) {
        //     this.minorChildArray[delIndex].isDelete = true;
        //     return;
        // }

        this.minorChildArray.splice(delIndex, 1);
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
        // this.showSpinner = true;

        // this.showSpinner = false;

        // callback({
        //     applicationId: this.applicationId,
        //     valid: true
        // });


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

        // this.dataObj.minorChildArray = this.minorChildArray;

        // if (valid) {
        //     saveMinorChildrenInformation({
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

    get maleFemaleOption() {
        return [{
                label: 'Male',
                value: 'Male'
            },
            {
                label: 'Female',
                value: 'Female'
            }

        ];
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

    setMinorChildDetail(event) {
        if (event.target.name === 'nameMinorChild') {
            this.newMinorChildren.nameMinorChild = event.currentTarget.value;
        } else if (event.target.name === 'gender') {
            this.newMinorChildren.gender = event.currentTarget.value;
        } else if (event.target.name === 'dob') {
            this.newMinorChildren.dob = event.currentTarget.value;
        } else if (event.target.name === 'relationship') {
            this.newMinorChildren.relationship = event.currentTarget.value;
        } else if (event.target.name === 'finantiallySupport') {
            this.newMinorChildren.finantiallySupport = event.currentTarget.value;
        }
    }

    handleInputChange(event) {
        if (event.target.name === 'minorChildrenInFamilty') {
            this.dataObj.minorChildrenInFamilty = event.target.value;
            if (event.target.value == 'Yes') {
                this.isMinorChildrenInFamilty = true;
            } else {
                this.isMinorChildrenInFamilty = false;
            }
        } else if (event.target.name === 'nameMinorChild') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].nameMinorChild = event.currentTarget.value;
        } else if (event.target.name === 'gender') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].gender = event.currentTarget.value;
        } else if (event.target.name === 'dob') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].dob = event.currentTarget.value;
        } else if (event.target.name === 'relationship') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].relationship = event.currentTarget.value;
        } else if (event.target.name === 'finantiallySupport') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].finantiallySupport = event.currentTarget.value;
        }

        console.log('minorChildArray>>' + JSON.stringify(this.minorChildArray));
    }


}