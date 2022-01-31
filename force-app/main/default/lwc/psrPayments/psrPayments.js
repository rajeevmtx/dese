import { LightningElement,track,api } from 'lwc';
import fetchPicklistValue from "@salesforce/apex/PsrStatusInfo.fetchPicklistValue";
import { utility } from "c/pubsub";
import { updateRecord } from 'lightning/uiRecordApi';
import PAYMENT_MODE_FIELD from '@salesforce/schema/Application__c.Payment_Mode__c';
import ID_FIELD from '@salesforce/schema/Application__c.Id';
import PAYMENT_STATUS_FIELD from '@salesforce/schema/Application__c.Payment_Status__c';
import MONEY_CHEQUE_FIELD from '@salesforce/schema/Application__c.Money_Order_Check_Number__c';

export default class PsrPayments extends LightningElement {
    @track appId ;
    @track value = '';
    @track yesflag = false;
    @track noflag =false;
    @track checkpickvalue = false;
    @track isReadyOnly;

    @api
    get disabledFields() {
        return this.isReadyOnly;
    }
    set disabledFields(value) {
        this.isReadyOnly = value;
    }

    constructor() {
        super();
        this.appId = utility.getUrlParam('appId');
        console.log(this.appId);
        console.log('in con',this.isReadyOnly);
    }
    
    connectedCallback() {
        console.log('in connect',this.isReadyOnly);
        fetchPicklistValue({applicationId :this.appId})
        .then(result => {
            console.log(result);
            if(result === undefined){
                this.checkpickvalue =false;
            }else if(result === 'Money Order/Check'){
                this.value ='Yes'; 
                this.checkpickvalue =false;
                this.yesflag = true;
            }else{
                this.value = 'No';
                this.yesflag = false;
                this.noflag = true;
                //this.checkpickvalue =true;
            }
            
        })
        .catch(error => {
            console.log("**************", error);
            
        });
    }
 

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    get optionscontry() {
        return [
            { label: 'USA', value: 'USA' },
            { label: 'Canada', value: 'Canada' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        if(this.value === 'Yes'){
            this.yesflag = true;
            this.noflag = false;
        }
        else if(this.value === 'No'){
            this.yesflag = false;
            this.noflag = true;
        }

    }
    handleChangeCountry(event) {

    }
    @api submitApplication() {
        
        return new Promise((resolve, reject) => {
            console.log(this.value);
            this.updateApplicationRecord();
            this.updateStep();
            resolve(true);
            
        })
    }
    updateStep() {
        utility.setCurrentStep(6, this.appId);
    }
    updateApplicationRecord(){
            console.log('update form');
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.appId;
            fields[PAYMENT_STATUS_FIELD.fieldApiName] ='Paid';
            if(this.value)
            fields[PAYMENT_MODE_FIELD.fieldApiName] = this.value === 'No' ?'Online':'Money Order/Check';
            if(this.template.querySelector("[data-field='LastName']")!=null)
            fields[MONEY_CHEQUE_FIELD.fieldApiName] = this.template.querySelector("[data-field='LastName']").value;
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    console.log('record inserted');
                })
                .catch(error => {
                    console.log(error);
                });
    }
}