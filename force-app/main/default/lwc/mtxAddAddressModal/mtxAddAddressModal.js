import { LightningElement, track, api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Address_Information from '@salesforce/schema/Address_Information__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class MtxAddAddressModal extends LightningElement {
    @api recordId;
    @api subjectId;
    @api addressData;//Added by Sajal for I-17475    
    @track showSpinner = false;
    @track recordTypeId;
    @track showLocalFields = true;
    @track showEmergencyFields = false;
    @track showPermanentFields = false;
    @track showLocationFields = false;
    @track showHealthcareFields = false;
    @track errorClass;
    @track invalidTelephone = false;
    @track recordTypeName = 'Local address';
    @api objectApiName;
    @track objectInfo;
    

    @wire(getObjectInfo, { objectApiName: Address_Information })
    objectInfo;

    getrecordTypeId(recordTypeNmae) {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === recordTypeNmae);
    }


    // @track typeOptions = [
    //     { label : 'Emergency address', value : '0123F000001hFI7' },
    //     { label : 'Permanent address', value : '0123F000001hFICQA2' }, 
    //     { label : 'Local address', value : '0123F000001hFIHQA2' }, 
    //     { label : 'Health Care Facility', value : '0123F000001hFIMQA2' }, 
    //     { label : 'Location', value : '0123F000001hFIRQA2' },
    // ];
   
    @track typeOptions = [
        { label : 'Emergency address', value : 'Emergency address' },
        { label : 'Permanent address', value : 'Permanent address' }, 
        { label : 'Local address', value : 'Local address' }, 
        { label : 'Health Care Facility', value : 'Health Care Facility' }, 
        { label : 'Location', value : 'Location' },
    ];

    handleTypeChange(event) {
        //this.recordTypeId = event.detail.value;
        this.recordTypeName = event.detail.value;
        this.recordTypeId = this.getrecordTypeId(this.recordTypeName);

        console.log('this.recordTypeId--',this.recordTypeId);
        this.hideFields();
        if (this.recordTypeName === 'Emergency address') {
            this.showEmergencyFields = true;
        }
        else if (this.recordTypeName === 'Permanent address') {
            this.showPermanentFields = true;
        }
        else if (this.recordTypeName === 'Local address') {
            this.showLocalFields = true;
        }
        else if (this.recordTypeName === 'Health Care Facility') {
            this.showHealthcareFields = true;
        }
        else if (this.recordTypeName === 'Location') {
            this.showLocationFields = true;
        }
    }

    hideFields() {
        this.showLocalFields = false
        this.showEmergencyFields = false
        this.showPermanentFields = false
        this.showLocationFields = false
        this.showHealthcareFields = false
    }

    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('modalclose'));
    }

    handleFormSubmit(event) {
        var allowInsertion = true;
        this.showSpinner = true;
        const fields = event.detail.fields;
        this.recordTypeId = this.getrecordTypeId(this.recordTypeName);  
        //START: Modified by Sajal for I-17475 
        for(var item in this.addressData.data){
            var itemRecordType = this.addressData.data[item].RecordType.Name;
            if(itemRecordType === this.recordTypeName){
                const event = new ShowToastEvent({
                    title: 'Invalid Address Type',
                    message: 'A record of this Address Type already exists. Kindly update the same if needed.',
                    variant: 'error'
                });
                this.dispatchEvent(event);
                allowInsertion = false;
            }
        }
        if(allowInsertion){
            if(this.recordTypeName === 'Emergency address' || this.recordTypeName === 'Health Care Facility'){
                if(this.telephoneCheck(fields.Contact_Number__c)){
                    fields['Subject__c'] = this.subjectId;
                    fields['RecordTypeId'] = this.recordTypeId;
                    console.log('fields here', JSON.parse(JSON.stringify(event.detail.fields)));
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                }else{
                    this.errorClass = 'slds-has-error';
                    this.invalidTelephone = true;
                    console.log('Has error');
                    return;
                }
            }else{
                fields['Subject__c'] = this.subjectId;
                fields['RecordTypeId'] = this.recordTypeId;
                console.log('fields here', JSON.parse(JSON.stringify(event.detail.fields)));
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }
        //END : Modified by Sajal for I-17475    

    }

    handleFormSuccess(event) {
        this.handleCloseModal();
        this.showSpinner = false;
    }

    handleError(event) {
        console.log('error', event);
        console.log('error here', event.message, event.detail.output.fieldErrors);
        this.showSpinner = false;
    }

    telephoneCheck(str) {
        var patt = new RegExp(/^\s*(?:\+?(\d{0,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4,5})(?: *x(\d+))?\s*$/);;
        return patt.test(str);
    }
}