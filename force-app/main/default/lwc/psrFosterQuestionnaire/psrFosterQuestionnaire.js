import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    utility
} from "c/pubsub";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";

import saveQuestionnaire from '@salesforce/apex/PsrNewFosterPermitController.saveQuestionnaire';

export default class PsrFosterQuestionnaire extends LightningElement {

    @track applicationId;

    @track dataObj = {};
    @track otherTextRequired = false;

    connectedCallback() {
        this.dataObj = {};
        this.applicationId = utility.getUrlParam("appId");
        this.dataObj.permitId = this.applicationId;
    }

    handleChange(event) {
        if (event.target.name == 'motherfather') {
            this.dataObj.motherfather = event.target.checked;
        } else if (event.target.name == 'mother') {
            this.dataObj.mother = event.target.checked;
        } else if (event.target.name == 'father') {
            this.dataObj.father = event.target.checked;
        } else if (event.target.name == 'motherstepparent') {
            this.dataObj.motherstepparent = event.target.checked;
        } else if (event.target.name == 'fatherstepparent') {
            this.dataObj.fatherstepparent = event.target.checked;
        } else if (event.target.name == 'stepmother') {
            this.dataObj.stepmother = event.target.checked;
        } else if (event.target.name == 'stepfather') {
            this.dataObj.stepfather = event.target.checked;
        } else if (event.target.name == 'maternalgrandparent') {
            this.dataObj.maternalgrandparent = event.target.checked;
        } else if (event.target.name == 'paternalgrandparent') {
            this.dataObj.paternalgrandparent = event.target.checked;
        } else if (event.target.name == 'auntuncle') {
            this.dataObj.auntuncle = event.target.checked;
        } else if (event.target.name == 'mothermother') {
            this.dataObj.mothermother = event.target.checked;
        } else if (event.target.name == 'fatherfather') {
            this.dataObj.fatherfather = event.target.checked;
        } else if (event.target.name == 'oldersibling') {
            this.dataObj.oldersibling = event.target.checked;
        } else if (event.target.name == 'adoptiveparent') {
            this.dataObj.adoptiveparent = event.target.checked;
        } else if (event.target.name == 'fosterparent') {
            this.dataObj.fosterparent = event.target.checked;
        } else if (event.target.name == 'institutionalcaretaker') {
            this.dataObj.institutionalcaretaker = event.target.checked;
        } else if (event.target.name == 'legalgardian') {
            this.dataObj.legalgardian = event.target.checked;
        } else if (event.target.name == 'other') {
            this.dataObj.other = event.target.checked;
            this.otherTextRequired = event.target.checked;
        } else if (event.target.name == 'otherText') {
            this.dataObj.otherText = event.target.value;
        }
        console.log('dataObj' + JSON.stringify(this.dataObj));
    }

    @api
    isValid(callback) {
        let valid = false;
        let isAllValid = false;
        isAllValid = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        console.log("isValid : " + valid);


        if (valid) {
            saveQuestionnaire({
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