import { LightningElement, api, track } from 'lwc';
import fetchPicklist from '@salesforce/apex/FC_ChildIntakeFormController.fetchPicklist';

export default class FcChildInformation extends LightningElement {
    @track dataObj = {};
    @track ageGroupOptions = [];
    @track helpTextVerification = `<p>When you submit a report, DCYF may contact you for some information You 
    may not have all the answers. It would be helpful if you can provide the following in the description area of your report:</p>
    <p>-The full nature and extent of the child's injuries, maltreatment, or neglect. 
    <p>-Any information about previous injuries, abuse, maltreatment or neglect.</p>
    <p>-How great a risk you believe this may be to the child.<p> 
    <p>-How you learned of this situation.</p>
    <p>-Any action that has been taken to treat or assist the child.</p>
    <p>-Family's strengths and resources.</p>
    <p>-Any other information that could be helpful in determining the cause of the injuries.</p>
    <p>A written report may be requested by DCYF within 48 hours. Sometimes, people are unsure if a situation is abusive. Even if you're in doubt, submit a report. DCYF has extensive experience in child protection. DCYF may find no abuse or neglect has taken place but may still offer assistance to the family.</p>
    `;

    handelInput(event) {
        if (event.target.name === 'firstName') {
            this.dataObj.firstName = event.target.value;
        }
        else if (event.target.name === 'lastName') {
            this.dataObj.lastName = event.target.value;
        }
        else if (event.target.name === 'ageGroup') {
            this.dataObj.ageGroup = event.target.value;
        }
    }

    @api
    isValid() {
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        return valid;
    }

    @api
    getData() {
        return this.dataObj;
    }

    connectedCallback() {
        fetchPicklist({ objectName: 'Case', fieldName: 'Child_Age_Group__c' })
            .then(result => {
                this.ageGroupOptions = result;
            })
            .catch(error => {
                let message = error.message || error.body.message;
                console.log('Error: ' + message);
            });
    }
}