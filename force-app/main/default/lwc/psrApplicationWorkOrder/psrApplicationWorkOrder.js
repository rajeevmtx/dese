import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchApplicationWorkOrder from '@salesforce/apex/PSR_ApplicationWorkOrderController.fetchApplicationWorkOrder';
import deleteApplicationWorkOrderRecord from '@salesforce/apex/PSR_ApplicationWorkOrderController.deleteApplicationWorkOrderRecord';
import updateNotifiedField from '@salesforce/apex/PSR_ApplicationWorkOrderController.updateNotifiedField';
import fetchApplicationWorkOrderInfo from '@salesforce/apex/PsrStatusInfo.fetchApplicationWorkOrderInfo';
import createInspectionRecords from '@salesforce/apex/PsrStatusInfo.createInspectionRecords';
import APPLICATIONWORKORDER_OBJECT from '@salesforce/schema/Application_Work_Order__c';
import STATUS_FIELD from '@salesforce/schema/Application_Work_Order__c.Status__c';
import CONTACT_FIELD from '@salesforce/schema/Application_Work_Order__c.Application_Contact__c';
import NOTIFIED_DATE_FIELD from '@salesforce/schema/Application_Work_Order__c.Last_Notified_Date__c';
import TYPE_FIELD from '@salesforce/schema/Application_Work_Order__c.Work_Order_Type__c';
import NOTIFY_FIELD from '@salesforce/schema/Application_Work_Order__c.Notify_Subcontractor__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Application_Work_Order__c.Description__c';
import Portal_Add_New_Work_Order_Help_Text from '@salesforce/label/c.Portal_Add_New_Work_Order_Help_Text';
export default class PsrApplicationWorkOrder extends LightningElement { 
    @api recordId;
    @api addNewRecord = false;
    @api isReadyOnly;
    @api Portal_Add_New_Work_Order_Help_Text = Portal_Add_New_Work_Order_Help_Text;
    @track columnConfiguration;
    @track workOrders;
    @track showEditModal = false;
    @track showConfirmation = false;
    @track WORK_ORDER_OBJECT = APPLICATIONWORKORDER_OBJECT;
    @track STATUS_FIELD = STATUS_FIELD;
    @track CONTACT_FIELD = CONTACT_FIELD;
    @track NOTIFIED_DATE_FIELD = NOTIFIED_DATE_FIELD;
    @track TYPE_FIELD = TYPE_FIELD;
    @track NOTIFY_FIELD = NOTIFY_FIELD;
    @track DESCRIPTION_FIELD = DESCRIPTION_FIELD;
    @track workOrderId;
    @track statusValue;
    @track isEdit = false;
    @track isEditModal = false;
    @track showMessage = true;
    @track isShowSpinner = false;
    @track isShowInspectionModal = false;
    @track applicationContactId;
    @track showRequestInspection =true;

    connectedCallback() {
        console.log('schema here', this.WORK_ORDER_OBJECT, this.STATUS_FIELD, this.CONTACT_FIELD, this.NOTIFIED_DATE_FIELD);
        this.loadColumns();
        this.loadData();
        this.getApplicationWorkOrderInfo();
    }

    renderedCallback(){
        this.getApplicationWorkOrderInfo();
    }

    getApplicationWorkOrderInfo(){
        console.log('in get application work order info');
        fetchApplicationWorkOrderInfo({ applicationId: this.recordId })
        .then(res => {
            console.log('fetchApplicationWorkOrderInfo'+res);
            this.showRequestInspection =res;
        })
        .catch(err => {
            console.log('error here', JSON.stringify(err));
        })


    }

    loadColumns() {
        this.columnConfiguration = [];
        this.columnConfiguration.push({
            heading: 'WO NUMBER',
            fieldApiName: 'Name'
        });
        this.columnConfiguration.push({ 
            heading: 'WORK ORDER TYPE',
            fieldApiName: 'Work_Order_Type__c'
        });
        this.columnConfiguration.push({
            heading: 'STATUS',
            fieldApiName: 'Status__c'
        });
        this.columnConfiguration.push({
            heading: 'SUBCONTRACTOR',
            fieldApiName: 'Application_Contact__r.Contact__r.Name'
        });
        this.columnConfiguration.push({
            heading: 'LAST NOTIFIED DATE',
            fieldApiName: 'Last_Notified_Date__c'
        });
    }
    loadData() {
        console.log('inside load data');
        fetchApplicationWorkOrder({ appId: this.recordId })
            .then(res => {
                let workOrdersArray = JSON.parse(JSON.stringify(res));
                console.log('PG : ', JSON.stringify(res));
                if(workOrdersArray.length < 1) {
                    this.workOrders = [];
                    this.showMessage = true;
                } else {  
                    console.log('inside false');
                    this.showMessage = false;
                    this.workOrders = [];
                    workOrdersArray.forEach(value => {
                        this.workOrders.push({
                            workOrder: value,
                            showNotifyIcon: value.record.Status__c === 'Not Started' && value.record.Application__r.Status__c === 'Approved'
                        });
                    });
                }
            })
    }
    deleteWorkOrder() {
        deleteApplicationWorkOrderRecord({ appWorkOrderId: this.workOrderId })
            .then(res => {
                console.log('res here', JSON.stringify(res));
                this.loadData();
                this.showConfirmation = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: res,
                        variant: 'success'
                    })
                );
            })
            .catch(err => {
                console.log('error here', JSON.stringify(err));
            })
    }
    handleEdit(event) {
        this.isEdit = true;
        const actionName = event.currentTarget.dataset.value;
        this.workOrderId = event.currentTarget.dataset.id;
        console.log('action name here', actionName, this.workOrderId);
        if (actionName === 'delete') {
            this.showConfirmation = true;
        } else if (actionName === 'notify') {
            this.updateNotificationField();
        } else if (actionName === 'edit') {
            this.isShowSpinner = true;
            this.isEditModal = true;
            this.statusValue = event.currentTarget.dataset.status;
            this.showEditModal = true;
            this.applicationContactId = event.currentTarget.dataset.subcontractorid;
            setTimeout(() => {
                this.isShowSpinner = false;
            }, 500)
        }
    }
    closeDeleteConfirmationModal() {
        this.showConfirmation = false;
    }
    closeEditModal() {
        this.showEditModal = false;
    }
    handleFormSubmit(event) {
        event.preventDefault();
        let fields = JSON.parse(JSON.stringify(event.detail.fields));
        let fieldsValues = Object.values(fields);
        let nullFound = false;
        fieldsValues.forEach(value => {
            if(value === null || value === "" || value === undefined) {
                nullFound = true;
            }
        });
        if(nullFound) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all the fields',
                    variant: 'error'
                })
            );
            return;
        }
        if(!this.isEditModal) {
            fields['Status__c'] = 'Not Started';
        }
        console.log('fields here before modification', JSON.stringify(fields));
        fields['Application_Contact__c'] = this.applicationContactId;
        fields['Application__c'] = this.recordId;
        console.log('fields here', JSON.stringify(fields));
        this.template.querySelector("lightning-record-edit-form").submit(fields);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record successfully updated',
                variant: 'success'
            })
        );
        this.loadData();
        this.showEditModal = false;
    }
    refreshTableData() {
        this.loadData();
    }
    updateNotificationField() {
        this.isShowSpinner = true;
        console.log(this.workOrderId);
        updateNotifiedField({ workOrderId: this.workOrderId })
            .then(res => {
                console.log('res here', JSON.stringify(res));
                this.loadData();
                this.isShowSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact has been successfully notified.',
                        variant: 'success'
                    })
                );
            })
            .catch(err => {
                console.error('error here', JSON.stringify(err));
            })
    }
    handleAddNewWorkOrder() {
        this.isShowSpinner = true;
        this.isEdit = false;
        this.isEditModal = false;
        this.workOrderId = undefined;
        this.statusValue = 'Not Started';
        this.addNewRecord = true;
        this.showEditModal = true;
        setTimeout(() => {
            this.isShowSpinner = false;
        }, 200)
    }
    handleContactSelect(event) {
        console.log('inside contact select', event.detail);
        this.applicationContactId = event.detail;
    }
    get getRecordId() {
        return this.isEdit ? this.workOrderId : '';
    }
    handleInspectionModal(event) {
        this.workOrderId = event.currentTarget.dataset.id;
        this.isShowInspectionModal = true;
    }
    handleCloseModal() {
        this.workOrderId = undefined;
        this.isShowInspectionModal = false;
    }

    handleAddInspection() {
        //var recordid = event.currentTarget.getAttribute('data-id');
        //var indexClicked = event.currentTarget.getAttribute('data-index');
        createInspectionRecords({applicationId:this.recordId})
            .then(result => {
                 this.showRequestInspection =true;
                let vari,message = '';
                if (result === 'Inspection has been requested successfully') {
                    this.vari = 'success';
                    message = result;
                    this.refreshTableData();
                    //this.ecr[indexClicked].showRequestInspection = false;
                    //this.showRequestInspection = false;
                } else if (result === 'No Application Work Order are available') {
                    message = result;
                    this.vari = 'error';
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: result,
                        message,
                        variant: this.vari
                    }),
                );
            })
            .catch(error => {
                this.error = error;
                console.log('URL Error: ' + JSON.stringify(error));
            });

        
    }
}