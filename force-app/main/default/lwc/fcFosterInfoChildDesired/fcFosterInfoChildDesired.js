import {
    LightningElement,
    api,
    track
} from 'lwc';

import saveChildDesireInformation from '@salesforce/apex/FcAdoptionInformationController.saveChildDesireInformation';

export default class FcFosterInfoChildDesired extends LightningElement {

    @api applicationId;

    @track dataObj = {};
    @track dependentAnswered;
    @track showChildModal;
    @track childData = [];
    @track helpText = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

    connectedCallback() {
        this.dataObj = {};
        this.dataObj.permitId = this.applicationId;
        // this.valueForDependents = 'No';
    }

    // connectedCallback(){
    //     console.log('=Child / Nonminor Dependent Desired=applicationId==>', this.applicationId);
    // }

    genderOptions = [
        { label: 'Male', value: 'Male' },
        { label: 'Female', value: 'Female' },
    ];

    optionsforYesNo = [{
            'label': 'Yes',
            'value': 'Yes'
        },
        {
            'label': 'No',
            'value': 'No'
        },
    ];

    optionsforChildPreferences = [{
            'label': '0 to 2 years',
            'value': '0 to 2 years'
        },
        {
            'label': '3 to 7 years',
            'value': '3 to 7 years'
        },
        {
            'label': '8 to 12 years',
            'value': '8 to 12 years'
        },
        {
            'label': '13 to 15 years',
            'value': '13 to 15 years'
        },
        {
            'label': '16 to 17 years',
            'value': '16 to 17 years'
        },
        {
            'label': '18 to 20 years',
            'value': '18 to 20 years'
        },
        {
            'label': 'No Preference',
            'value': 'No Preference'
        },
    ];

    optionsforSibling = [{
            'label': 'Not Open to sibling groups',
            'value': 'Not Open to sibling groups'
        },
        {
            'label': '2',
            'value': '2'
        },
        {
            'label': '3',
            'value': '3'
        },
        {
            'label': '4',
            'value': '4'
        },
        {
            'label': '5 or more',
            'value': '5 or more'
        },

    ];

    valueChildPreferences = [];
    valueSiblings = [];


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

        // this.dataObj.minorChildArray = this.minorChildArray;

        // if (valid) {
        //     saveChildDesireInformation({
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
    @track isDependentIdentified = false;
    @track valueForDependents;
    handleChangeForDependents(event) {
        const selectedOption = event.detail.value;
        this.dataObj.dependent = event.target.value;
        console.log(`Option selected with value: ${selectedOption}`);
        if (selectedOption === 'Yes') {
            this.isDependentIdentified = true;
        } else {
            this.isDependentIdentified = false;
        }
        this.dependentAnswered = true;
    }

    handleChangeforChildPreferences(event) {
        //const changeValue = event.detail.value;
        this.dataObj.childPreferences = event.detail.value;
    }

    handleChangeforSiblings(event) {
        //const changeValue = event.detail.value;
        this.dataObj.siblings = event.detail.value;
    }
    //////////////////////////////////////

    @track minorChildArray = [{
        "name": "",
        "gender": "",
        "dob": "",
        "relationship": "",
        "dop": "",
        "county": "",
        "heading": "Child/NMD 1",
        "key": 1,
        "isDelete": false
    }];

    handleAddRow = () => {
        let temparr = [...this.minorChildArray];

        if (temparr.length > 0) {
            this.minorChildArray.push({
                "name": "",
                "gender": "",
                "dob": "",
                "relationship": "",
                "dop": "",
                "county": "",
                "heading": "Child/NMD " + (temparr.length + 1),
                "key": temparr.length,
                "isDelete": false
            });
        } else {
            this.bulletsarr.push({
                "name": "",
                "gender": "",
                "dob": "",
                "relationship": "",
                "dop": "",
                "county": "",
                "heading": "Child/NMD 1",
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

    handleInputChange(event) {
        // if (event.target.name === 'minorChildrenInFamilty') {
        //     this.dataObj.minorChildrenInFamilty = event.target.value;
        //     if (event.target.value == 'Yes') {
        //         this.isMinorChildrenInFamilty = true;
        //     } else {
        //         this.isMinorChildrenInFamilty = false;
        //     }
        // } else
        if (event.target.name === 'name') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].name = event.currentTarget.value;
        } else if (event.target.name === 'gender') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].gender = event.currentTarget.value;
        } else if (event.target.name === 'dob') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].dob = event.currentTarget.value;
        } else if (event.target.name === 'relationship') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].relationship = event.currentTarget.value;
        } else if (event.target.name === 'dop') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].dop = event.currentTarget.value;
        } else if (event.target.name === 'county') {
            let changeIndex = event.currentTarget.dataset.recordId;
            this.minorChildArray[changeIndex].county = event.currentTarget.value;
        }

        console.log('minorChildArray>>' + JSON.stringify(this.minorChildArray));
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

    onAddChild() {
        this.showChildModal = true;
    }

    handleCloseModal() {
        this.showChildModal = false;
    }

    handleAddChild() {
        console.log('inside add');
        const childToAdd = {};
        this.template.querySelectorAll('.modalInput').forEach(input => {
            switch(input.name) {
                case 'name': {
                    childToAdd.name = input.value;
                    break;
                }
                case 'dob': {
                    childToAdd.dob = input.value;
                    break;
                }
                case 'gender': {
                    childToAdd.gender = input.value;
                    break;
                }
                case 'relationship': {
                    childToAdd.relationship = input.value;
                    break;
                }
                case 'dateOfPlacement': {
                    childToAdd.dateOfPlacement = input.value;
                    break;
                }
                case 'county': {
                    childToAdd.county = input.value;
                    break;
                }
            }
        });
        console.log('child data here', childToAdd);
        this.childData.push(childToAdd);
        this.showChildModal = false;
    }

    removeChild(event) {
        console.log('index here', event.target.dataset.index);
        const indexToRemove = event.target.dataset.index;
        this.childData.splice(indexToRemove, 1);
    }
}