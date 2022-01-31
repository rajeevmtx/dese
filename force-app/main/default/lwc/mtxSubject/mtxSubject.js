import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
 
const FIELDS = [
    'Subject__c.Gender__c',
    'Subject__c.Primary_Cell_Number__c',
    'Subject__c.Email_Address__c',
    'Subject__c.County__c',
    'Subject__c.Date_of_Birth__c',    
    'Subject__c.Monitoring_End_Date__c',
    'Subject__c.Disposition__c',
];
 

export default class MtxSubject extends LightningElement {
    @api recordId;
        @wire(getRecord, {
            recordId: '$recordId',
            fields : FIELDS
        })
        subject;
     
        get gender() {
            return this.subject.data.fields.Gender__c.value;
        }
     
        get mobilePhone() {
            return this.subject.data.fields.Primary_Cell_Number__c.value;
        }
     
        get email() {
            return this.subject.data.fields.Email_Address__c.value;
        }
     
        get county() {
            return this.subject.data.fields.County__c.value;
        }
        get dob() {
            return this.subject.data.fields.Date_of_Birth__c.value;
        }
     
        get monitoringEndDate() {
            return this.subject.data.fields.Monitoring_End_Date__c.value;
        }
    
        get disposition() {
            return this.subject.data.fields.Disposition__c.value;
        }
}