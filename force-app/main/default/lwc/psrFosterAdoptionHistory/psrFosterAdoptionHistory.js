import {
    LightningElement,
    track,
    api
} from 'lwc';
import saveFosterAdoptionHistory from '@salesforce/apex/PsrNewFosterPermitController.saveFosterAdoptionHistory';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
    utility
} from "c/pubsub";

export default class PsrFosterAdoptionHistory extends LightningElement {
    @track applicationId;

    @track dataObj = {};

    connectedCallback() {
        this.dataObj = {};
        this.applicationId = utility.getUrlParam("appId");
        this.dataObj.permitId = this.applicationId;
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
        if (event.target.name === 'radio1') {
            this.dataObj.radio1 = event.target.value;
        } else if (event.target.name === 'radio2') {
            this.dataObj.radio2 = event.target.value;
        } else if (event.target.name === 'radio3') {
            this.dataObj.radio3 = event.target.value;
        } else if (event.target.name === 'radio4') {
            this.dataObj.radio4 = event.target.value;
        } else if (event.target.name === 'radio5') {
            this.dataObj.radio5 = event.target.value;
        }
        console.log('dataObj' + JSON.stringify(this.dataObj));
    }

    @api
    isValid(callback) {
        let valid = false;
        let isAllValid = false;
        isAllValid = [
            ...this.template.querySelectorAll('lightning-radio-group')
        ].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        console.log("isValid : " + valid);


        if (valid) {
            saveFosterAdoptionHistory({
                    jsonString: JSON.stringify(this.dataObj)
                })
                .then((result) => {
                    callback({
                        valid: true
                    });
                })
                .catch(error => {
                    console.log('error>>' + JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: JSON.stringify(error),
                            variant: "error"
                        })
                    );
                    callback({
                        valid: false
                    });
                });
        } else {
            callback({
                valid: false
            });
        }

    }

}