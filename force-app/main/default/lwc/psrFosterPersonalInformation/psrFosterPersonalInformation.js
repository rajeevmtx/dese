import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    utility
} from "c/pubsub";
import getPersonalInfo from "@salesforce/apex/PsrNewFosterPermitController.getPersonalInfo";
import savePersonalInfo from "@salesforce/apex/PsrNewFosterPermitController.savePersonalInfo";
export default class PsrFosterPersonalInformation extends LightningElement {
    @track applicationId;

    @track myVal;
    @track rem = 1000;
    @track textdis = false;
    @track showSpinner = false;
    @track commentsLabel = "";

    @track dataObj = {};
    connectedCallback() {
        this.commentsLabel = 'COMMENTS:(REMAINING CHARACTERS: ' + this.rem + ')';
        this.dataObj = {};
        this.applicationId = utility.getUrlParam("appId");
        this.dataObj.permitId = this.applicationId;
        this.getPersonalInfoData();


    }
    getPersonalInfoData() {
        this.showSpinner = true;
        getPersonalInfo({
            applicationId: this.applicationId
        }).then((result) => {

            //this.dataObj = result;

        }).catch((error) => {
            console.log(JSON.stringify(error));
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    get city() {
        return [{
                label: 'Manchester',
                value: 'Manchester'
            },
            {
                label: 'Nashua',
                value: 'Nashua'
            },
            {
                label: 'Concord',
                value: 'Concord'
            },

            {
                label: 'Bedford',
                value: 'Bedford'
            },
            {
                label: 'Hampton',
                value: 'Hampton'
            },
            {
                label: 'Pelham',
                value: 'Pelham'
            },
            {
                label: 'Claremont',
                value: 'Claremont'
            },
        ];
    }



    get state() {
        return [{
                label: 'Belknap',
                value: 'Belknap'
            },
            {
                label: 'Carroll',
                value: 'Carroll'
            },
            {
                label: 'Cheshire',
                value: 'Cheshire Coos'
            },
            {
                label: 'Coos',
                value: 'Coos'
            },
            {
                label: 'Grafton',
                value: 'Grafton'
            },
            {
                label: 'Merrimack',
                value: 'Merrimack'
            },
            {
                label: 'Rockingham',
                value: 'Rockingham'
            },
        ];
    }


    get interestOption() {
        return [{
                label: 'Fostering',
                value: 'Fostering'
            },
            {
                label: 'Adopting',
                value: 'Adopting'
            },
            {
                label: 'Both',
                value: 'Both'
            },
            {
                label: 'Not Sure',
                value: 'Not Sure'
            }

        ];
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


    handleInput(event) {

        if (event.target.name == 'firstName') {
            this.dataObj.firstName = event.target.value;
        } else if (event.target.name == 'mi') {
            this.dataObj.mi = event.target.value;
        } else if (event.target.name == 'lastName') {
            this.dataObj.lastName = event.target.value;
        } else if (event.target.name == 'street') {
            this.dataObj.street = event.target.value;
        } else if (event.target.name == 'unit') {
            this.dataObj.unit = event.target.value;
        } else if (event.target.name == 'city') {
            this.dataObj.city = event.target.value;
        } else if (event.target.name == 'state') {
            this.dataObj.state = event.target.value;
        } else if (event.target.name == 'zipcode') {
            this.dataObj.zipcode = event.target.value;
        } else if (event.target.name == 'email') {
            this.dataObj.email = event.target.value;
        } else if (event.target.name == 'phoneNumber') {
            this.dataObj.phoneNumber = event.target.value;
        } else if (event.target.name == 'ext') {
            this.dataObj.ext = event.target.value;
        } else if (event.target.name == 'years') {
            this.dataObj.years = event.target.value;
        } else if (event.target.name == 'interest') {
            this.dataObj.interest = event.target.value;
        } else if (event.target.name == 'adoptingInterest') {
            this.dataObj.adoptingInterest = event.target.value;
        } else if (event.target.name == 'married') {
            this.dataObj.married = event.target.value;
        } else if (event.target.name == 'anyOtherHousehold') {
            this.dataObj.anyOtherHousehold = event.target.value;
        } else if (event.target.name == 'textArea') {
            this.myVal = event.detail.value;
            this.rem = 1000 - this.myVal.length;
            this.commentsLabel = 'COMMENTS:(REMAINING CHARACTERS: ' + this.rem + ')';
        }
    }
    @api
    isValid(callback) {
        console.log('isValid called');
        this.showSpinner = true;
        let isAllValid = false;
        isAllValid = [...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }, true);

        isAllValid &= [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        isAllValid &= [...this.template.querySelectorAll('lightning-textarea')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        console.log('isAllValid>' + isAllValid);

        if (isAllValid) {
            let dataval = JSON.stringify(this.dataObj);
            savePersonalInfo({
                jsonData: dataval

            }).then((result) => {

                callback({
                    valid: true
                });
                this.showSpinner = false;

            }).catch((error) => {
                let message = error.message || error.body.message;

                this.showSpinner = false;
                callback({
                    valid: false
                });
                console.log(message);
            });


        } else {
            this.showSpinner = false;
            callback({
                valid: false
            });
        }
    }



}