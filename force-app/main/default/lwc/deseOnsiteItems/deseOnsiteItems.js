import { LightningElement ,api,track } from 'lwc';
import fetchOnsiteItems from '@salesforce/apex/DESE_OnsiteController.fetchOnsiteItems';
import generateAgenda from '@salesforce/apex/DESE_OnsiteController.generateItems';
import createNewAgenda from '@salesforce/apex/DESE_OnsiteController.createNewOnsiteItem';
import updateRecords from '@salesforce/apex/DESE_OnsiteController.updateRecords';
import getPrograms from '@salesforce/apex/DESE_OnsiteController.getPrograms';
import sendEmailToUsers from '@salesforce/apex/DESE_OnsiteController.sendEmailToUsers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DeseOnsiteItems extends LightningElement {
    @api recordId;
    showSpinner = false;
    @track data = [];
    @track showCreateAgendaModal = false;
    @track agendaName;
    @track agendaNotes;
    @track showTransferModal = false;
    @track showGenerateAgendaModal = false;
    @track generateAgendaFor = [];
    @track checkboxvalues = [];
    @track statusOptions=[
        {
            label:'Not Started',
            value : 'Not Started'
        },
        {
            label:'In Progress',
            value : 'In Progress'
        },
        {
            label:'Submit For Approval',
            value : 'Submit For Approval'
        }
    ];
    @track statusOptions1=[
        {
            label:'Not Started',
            value : 'Not Started'
        },
        {
            label:'In Progress',
            value : 'In Progress'
        },
        {
            label:'Submit For Approval',
            value : 'Submit For Approval'
        },
        {
            label:'Submitted For Approval',
            value : 'Submitted For Approval'
        },
        {
            label:'Approved',
            value : 'Approved'
        },
        {
            label:'Rejected',
            value : 'Rejected'
        }
    ]

    connectedCallback(){
        this.showSpinner = true;
        this.fetchOnsiteItems();
    }

    get isGenerateAgendaDisabled(){
        return this.data.length > 0 ? true : false;
    }

    handleCreateAgenda(){
        this.showCreateAgendaModal = true;
    }

    handleGenerateAgenda(){
        generateAgenda({
            VisitId : this.recordId
        })
        .then(data=>{
            window.location.reload();
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
    }

    handleNotesChange(event){
        let recId = event.currentTarget.dataset.recid;
        this.data.forEach(row=>{
            if(row.Id == recId){
                row.Follow_up_notes__c = event.detail.value;
            }
        })
        
    }



    closeModal(){
        this.showCreateAgendaModal = false;
    }

    submitDetails(){
        // this.modalSpinner = true;
        createNewAgenda({
            VisitId : this.recordId,
            name: this.agendaName,
            notes : this.agendaNotes
        })
        .then(data => {
            // this.modalSpinner = false;
            this.showCreateAgendaModal = false;
            this.fetchOnsiteItems();
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }

    handleAgendaNameChange(event){
        this.agendaName = event.detail.value;
    }

    handleAgendaNotesChange(event){
        this.agendaNotes = event.detail.value;
    }

    handleStatusChange(event){
        let recId = event.currentTarget.dataset.recid;
        this.data.forEach(row=>{
            if(row.Id == recId){
                row.Status__c = event.detail.value;
            }
        })
    }

    handleSaveData(){
        var dataList = [];
        this.data.forEach(row=>{
            dataList.push({Id : row.Id, Status__c: row.Status__c, Visitation__c: row.Visitation__c, Follow_up_notes__c:row.Follow_up_notes__c});
        })
        this.showSpinner = true;
        updateRecords({
            jsonData : JSON.stringify(dataList)
        })
        .then(result=>{
            this.fetchOnsiteItems();
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
    }


    fetchOnsiteItems(){
        fetchOnsiteItems({
            VisitId : this.recordId
        })
        .then(data=>{
            var response  = data;
            response.forEach(row=>{
                if(row.Status__c == 'Submitted For Approval' || row.Status__c == 'Approved' || row.Status__c == 'Rejected'){
                    row.StatusDisabled = true;
                    row.statusOptions = this.statusOptions1;
                    row.disableNotes = true;
                } else{
                    row.StatusDisabled = false;
                    row.statusOptions = this.statusOptions;
                    row.disableNotes = false;
                }
            });
            this.data = response;
            this.showSpinner = false;
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
    }
    showTransferError = false;
    
    handleTransfer(){
        this.showSpinner = true;
        getPrograms({
            AccountId : this.recordId
        })
        .then(data =>{
            var result = data;
            if(result.length>0){
                result.forEach(row=>{
                    this.checkboxoptions.push({label:row.Name, value:row.Id});
                });
            } else{
                this.showTransferError = true;
            }
            
            this.showSpinner = false;
            this.showTransferModal = true;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
        
    }

    closeTransferModal(){
        this.checkboxoptions = [];
        this.showTransferModal = false;
    }

    @track checkboxoptions = [];

    get selectedValues() {
        return this.checkboxvalues.join(',');
    }

    handlecheckboxChange(e) {
        this.checkboxvalues = e.detail.value;
    }

    handleTransferAccount(){
        this.showTransferModal = false;
        this.checkboxoptions = [];
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Transfered To New Program',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        window.location.reload();
        
    }

    sendToSupervisor(){
        var dataList = [];
        this.data.forEach(row=>{
            dataList.push({Id : row.Id, Status__c: 'Submit For Approval', Visitation__c: row.Visitation__c, Follow_up_notes__c:row.Follow_up_notes__c});
        })
        this.showSpinner = true;
        updateRecords({
            jsonData : JSON.stringify(dataList)
        })
        .then(result=>{
            this.fetchOnsiteItems();
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
    }

    handleGenerateOrientationAgenda(){
        var arr=[];
        this.data.forEach(agenda=>{
            if(agenda.Status__c=='Approved'){
                arr.push({Id:agenda.Id,Name:agenda.Name});
            }
        });
        this.generateAgendaFor = arr;
        this.showGenerateAgendaModal = true;
    }
    hideGenerateOrientationAgenda(){
        this.showGenerateAgendaModal = false;
    }
    sendGenerateOrientationAgenda(){
        this.showSpinner = true;
        sendEmailToUsers({recordId:this.recordId}).then(result=>{
            this.showSpinner = false;
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Orientation Agenda Generated Successfully and Emailed Successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.showGenerateAgendaModal = false;
        }).catch(error=>{
            this.showSpinner = false;
            console.log(JSON.stringify(error));
            this.showGenerateAgendaModal = false;
        })
    }
}