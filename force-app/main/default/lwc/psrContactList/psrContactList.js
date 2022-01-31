/**
 * Created by AshishP on 22-01-2020.
 */
import {LightningElement,track,wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { utility } from "c/pubsub";
import { refreshApex } from '@salesforce/apex';
// importing Apex Class
import getContactdata from '@salesforce/apex/PsrContactListController.getAllContacts';
// Datatable Columns
const actions = [
    { label: 'Edit', name: 'edit' },
];
const columns = [{
    label: 'Name',
    fieldName: 'name',
    type: 'text',
}, {
    label: 'Email',
    fieldName: 'email',
    type: 'text'
},{
    label: 'Company Name',
    fieldName: 'companyName',
    type: 'text'
},{
    label: 'Company Type',
    fieldName: 'type',
    type: 'text'
},{
    type: 'action',
    typeAttributes: { rowActions: actions },
}];
export default class PsrContactList extends LightningElement {
    freshData;
    @track data = [];
    @track isOpenModal = false;
    @track columns = columns;
    @track selectedContactId = '';
    @track applicationContactId = '';
    get showMessage() {
        return (typeof this.data == 'undefined' ||  this.data.length < 1 );
    }
    @wire(getContactdata,{applicationId:utility.getUrlParam('appId'),recordTypeName:'Applicant'})
    con(result) {
        this.freshData = result;
        if (result.data) {
            this.data = result.data;
        } else if (result.error) {
            window.console.log(result.error);
        }
    }
    handleRowAction(event) {
        const actionName = event.currentTarget.dataset.value;
        const row = event.currentTarget.dataset;
        switch (actionName) {
            case 'edit':
                this.edidRecord(row);
                break;
            default:
        }
    }
    onAddContact() {
        console.log('add con');
        this.isOpenModal = true;
        this.selectedContactId = '';
        this.applicationContactId = '';
    }
    handleCloseModal() {
        console.log('close');
        this.isOpenModal = false; 
        this.selectedContactId = '';
        this.applicationContactId = '';
        return refreshApex(this.freshData);
    }
    edidRecord(row) {
        this.selectedContactId = row.contactid;
        this.applicationContactId = row.id;
        this.isOpenModal = true;
       // this.record = row;
    }
}