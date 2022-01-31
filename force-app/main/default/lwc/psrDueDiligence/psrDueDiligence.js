import { LightningElement , track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDueDiligenceRecords from '@salesforce/apex/DueDiligenceController.getDueDiligenceRecords';
import updateDueDiligenceRecords from '@salesforce/apex/DueDiligenceController.updateDueDiligenceRecords';

export default class PsrDueDiligence extends LightningElement {
    @api recordId;

    @track data=[];
    @track urlValue;
    @track openVModal = false;
    @track showEdit=true;
    //@track newStatusValue;
    @track dataMapToUpdate = new Map();
    //@track dataMap = new Map();

    get statusOptions() {
        return [
            { label: 'Scheduled', value: 'Scheduled' },
            { label: 'In Process', value: 'In Process' },
            { label: 'Completed', value: 'Completed' },
        ];
    }

    handleCancelClick(){
        this.showEdit=true;
    }

    handleEditClick(){
        this.showEdit=false;
    }

    handleSaveClick(event){
        let jsObject = [];
        this.showEdit=true;
    
        for (const [key, value] of this.dataMapToUpdate) {
            jsObject.push({
                Status: value,
                Recid: key,
            });
        }

        console.log("map>> "+ JSON.stringify(jsObject));

        updateDueDiligenceRecords({
            jsonMap : JSON.stringify(jsObject)
        })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Status Updated',
                    variant: 'success'
                })
            );
            this.refreshTableData();
        })
        .catch(error => {
            console.log("error occured>> "+ JSON.stringify(error));
        });
    }

    handleChange(event){
        //let idvalue=event.currentTarget.dataset.id;
        //console.log('event.currentTarget.dataset.recid'+event.currentTarget.dataset.recid);
        //this.newStatusValue = event.detail.value;
        this.dataMapToUpdate.set(event.currentTarget.dataset.recid, event.detail.value);
        //event.currentTarget.dataset.id;

        //console.log(this.dataMapToUpdate);
    }

    connectedCallback(){
        this.loadColumns();
        this.refreshTableData();
    }

    loadColumns(){
        this.columnConfiguration = [];

        this.columnConfiguration.push({
            heading: 'DUE DILLIGENCE',
            fieldApiName: 'Due_Diligence_Name__c"',
            style: 'width:300px;'
        });
        this.columnConfiguration.push({
            heading: 'RESPONSIBLE PARTY',
            fieldApiName: 'Responsible_Party__c',
            style: 'width:100px;'
        });
        this.columnConfiguration.push({
            heading: 'STATUS',
            fieldApiName: 'Status__c',
            style: 'width:80px;'
        });
        this.columnConfiguration.push({
            heading: 'COMPLETED DATE',
            fieldApiName: 'Completed_Date__c',
            style: 'width:100px;'
        });
        this.columnConfiguration.push({
            heading: 'COMPLETED BY',
            fieldApiName: 'LastModifiedBy.Name',
            style: 'width:100px;'
        });
    }

    refreshTableData(){
        console.log('refreshTableDataCalled>>'+this.recordId);
        this.data=[];
        getDueDiligenceRecords({
            idField : this.recordId
        })
        .then(result => {
            this.data = result; 
            let i;
            for(i=0; i<result.length; i++){
                if(this.data[i].Status__c == 'Pending' || this.data[i].Status__c == '' || this.data[i].Status__c == null){
                    this.data[i].LastModifiedBy.Name = '';
                }
            }
            console.log('data'+JSON.stringify(this.data));
        })
        .catch(error => {
            console.log("error occured>> "+ error);
        });
    }

    openVideoModal(event){
        this.urlValue = event.currentTarget.getAttribute('data-url');
        this.openVModal = true;
    }

    closeVideoModal(){
        this.openVModal = false;
    }
}