import {LightningElement,track,wire,api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { utility } from "c/pubsub";
import { refreshApex } from '@salesforce/apex';
// importing Apex Class
import getAllAbusers from '@salesforce/apex/AdultProtectiveServiceController.getAllAbusers';
export default class Aps_abuserList extends LightningElement {
    freshData;
    @api buttonlabel;
    @api modalbuttonadd;
    @api modalbuttonedit;
    @api type;
    @api caseid;

    @track data;
    @track isOpenModal = false;
    @track selectedContactId = '';
    @track applicationContactId = '';
    
    get showMessage() {
        return (typeof this.data == 'undefined' ||  this.data.length < 1 );
    }

    connectedCallback(){
        this.fetchData();
    }

    fetchData(){
        this.data = [];
        // this.caseid = utility.getUrlParam('id');

        getAllAbusers({caseId : this.caseid, type : this.type })
          .then(result => {
            this.data = result;
          })
          .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
          });
    }

    handleRowAction(event) {
        // const actionName = event.currentTarget.dataset.value;
        // const row = event.currentTarget.dataset;
        // switch (actionName) {
        //     case 'edit':
        //         this.edidRecord(row);
        //         break;
        //     default:
        // }
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
        this.fetchData();
    }

    edidRecord(row) {
        // this.selectedContactId = row.contactid;
        // this.applicationContactId = row.id;
        // this.isOpenModal = true;
       // this.record = row;
    }
}