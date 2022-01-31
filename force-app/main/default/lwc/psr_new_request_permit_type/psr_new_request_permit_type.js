import { LightningElement, track,api } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import Request_Permit_Type__c from '@salesforce/schema/Case.Request_Permit_Type__c';
import Description from '@salesforce/schema/Case.Description';
import saveRequestPermitType from '@salesforce/apex/PSR_RequestPermitTypeController.saveRequestPermitType';
import { showMessage } from 'c/util';
import Portal_New_Request_Permit_Type_Help_Text from '@salesforce/label/c.Portal_New_Request_Permit_Type_Help_Text';


export default class Psr_new_request_permit_type extends LightningElement {
    @api Portal_New_Request_Permit_Type_Help_Text = Portal_New_Request_Permit_Type_Help_Text;
    @track form = {};
    CASE_OBJECT = CASE_OBJECT;

    Description = Description;
    Request_Permit_Type = Request_Permit_Type__c;

    @api validPermitTypes;
    @track permitTypes = [];

    handleFormInputs(event) {
        if (event.target.name === 'Request_Permit_Type__c') {
            this.form.Request_Permit_Type__c = event.target.value;
        }
        else if (event.target.name === 'Description') {
            this.form.Description = event.target.value;
        }
    }

    closeDeleteConfirmationModal(){
        this.dispatchEvent( new CustomEvent('close') );
    }

    handleSave(){
        saveRequestPermitType({ jsonData: JSON.stringify(this.form) })
        .then( () => {
            this.dispatchEvent( new CustomEvent('success') );
        })
        .catch(error => {
            let message = error.message || error.body.message;
            showMessage(this, { message: message, messageType: 'error', mode: 'pester' });
        });        
    }

    connectedCallback(){
        for( let i =0 ;i < this.validPermitTypes.length ; i++){
            this.permitTypes.push({
                label: this.validPermitTypes[i],
                value: this.validPermitTypes[i]
            })
        }
    }
}