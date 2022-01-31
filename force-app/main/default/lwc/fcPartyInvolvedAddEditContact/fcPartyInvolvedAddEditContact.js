import { LightningElement, api, track } from 'lwc';
import saveData from '@salesforce/apex/FC_ChildIntakeFormController.saveData';
import fetchPicklist from '@salesforce/apex/FC_ChildIntakeFormController.fetchPicklist';

export default class FcPartyInvolvedAddEditContact extends LightningElement {
    @api selectedObj;
    @api caseId;
    @track showSpinner = false;
    @track futureDateExp = false;
    @track futureDateBirth = false;
    @track erroMsg;
    @track modalName;
    @track allSet = true;
    @track selectedObject = {};

    @track partyInvolvedTypeOptions = [];
    @track collateralTypeOptions = [];
    @track relationToAVOptions = [];
    @track resourceTypeOptions = [];

    handleInput(event){
        if( event.target.name === 'partyFirstName' ){
            this.selectedObject.partyFirstName = event.target.value.trim();
        }
        else if( event.target.name === 'partyLastName' ){
            this.selectedObject.partyLastName = event.target.value.trim();
        }
        else if( event.target.name === 'partyInvolvedType' ){
            this.selectedObject.partyInvolvedType = event.target.value.trim();
        }
        else if( event.target.name === 'collateralType' ){
            this.selectedObject.collateralType = event.target.value.trim();
        }
        else if( event.target.name === 'relationToAV' ){
            this.selectedObject.relationToAV = event.target.value.trim();
        }
        else if( event.target.name === 'resourceType' ){
            this.selectedObject.resourceType = event.target.value.trim();
        }
    }

    handleSaveRecord(){
        this.showSpinner = true;
        this.erroMsg=undefined;
        if(this.isValid()){
            console.log('selectedObject>>>',JSON.stringify(this.selectedObject));
            console.log('caseId>>>',this.caseId);
            saveData( {jsondata: JSON.stringify(this.selectedObject), caseId: this.caseId} )
            .then(result => {
                console.log('result>>>', JSON.stringify(result));
                const selectedEvent = new CustomEvent("aftersave", {
                    detail: this.selectedObject
                  });
                this.dispatchEvent(selectedEvent);

                this.showSpinner = false;
                this.dispatchEventRefresh('save');
            })
            .catch(error => {
                this.showSpinner = false;
                this.erroMsg = error.message || error.body.message;
            });
        }
        else{
            this.showSpinner = false;
            this.erroMsg = 'Please fill all required fields.';
        }
    }


    handleModalClose(){
        this.dispatchEventRefresh('close');
    }

    dispatchEventRefresh = eventName => { 
        const modalEvent = new CustomEvent(eventName, {});
        this.dispatchEvent(modalEvent);
    };

    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        isAllValid &= [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        valid = isAllValid;
        console.log('Valid Address ' + valid);
        return valid;
    }

    connectedCallback(){
        fetchPicklist( {objectName : 'Parties_Involved__c', fieldName : 'Party_Involved_Type__c' } )
        .then(result => {
            this.partyInvolvedTypeOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Error: ' + message);
        });

        fetchPicklist( {objectName : 'Parties_Involved__c', fieldName : 'Collateral_Type__c' } )
        .then(result => {
            this.collateralTypeOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Error: ' + message);
        });

        fetchPicklist( {objectName : 'Parties_Involved__c', fieldName : 'Relation_to_AV__c' } )
        .then(result => {
            this.relationToAVOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Error: ' + message);
        });


        fetchPicklist( {objectName : 'Parties_Involved__c', fieldName : 'Resource_Type__c' } )
        .then(result => {
            this.resourceTypeOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Error: ' + message);
        });

        console.log('this.selectedObj>>>', JSON.stringify(this.selectedObj));
        this.selectedObject.partyFirstName = this.selectedObj.partyFirstName;
        this.selectedObject.partyLastName =this.selectedObj.partyLastName;
        this.selectedObject.partyInvolvedType =this.selectedObj.partyInvolvedType;
        this.selectedObject.collateralType = this.selectedObj.collateralType;
        this.selectedObject.relationToAV =this.selectedObj.relationToAV;
        this.selectedObject.resourceType = this.selectedObj.resourceType;
        this.selectedObject.partyInvolvedId = this.selectedObj.partyInvolvedId;
        this.selectedObject.contactId = this.selectedObj.contactId;

        if( this.selectedObj.partyInvolvedId ){
            this.modalName = 'Update';
        }
        else{
            this.modalName = 'Add';
        }
    }
}