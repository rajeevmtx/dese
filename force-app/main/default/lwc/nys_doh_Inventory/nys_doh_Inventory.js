import { LightningElement, track, api} from 'lwc';
import fetchInventory from '@salesforce/apex/NYSDOH_InventoryController.fetchInventory';
import saveInventory from '@salesforce/apex/NYSDOH_InventoryController.updateInventory';
import Portal_Work_Order_Help_Text from '@salesforce/label/c.Portal_Work_Order_Help_Text';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Nys_doh_Inventory extends LightningElement {
    @track isEditModalOpel = false;
    @track isEditall = false;
    @track inventories = [];
    inventoriesCopy = [];
    @track inventoryId = '';
    @track invname = '';

    Portal_Work_Order_Help_Text= Portal_Work_Order_Help_Text;

    fetchInventory() {
        this.inventories = [];

        fetchInventory()
        .then(res => {
            res.forEach((item) => {
                item.isShowIndicator = ( item.Used_Quantity__c >= 70 );
                this.inventories.push(item);
            });
            this.inventoriesCopy = JSON.parse(JSON.stringify(this.inventories));

        });
    }
    updateQuantity(event) {
        let total = parseInt(event.target.dataset.total);
        let usage = parseInt(event.target.value);
        
        if(usage < 0) {
            event.target.value = 0;
            this.inventories[event.target.dataset.index].Usage_Quantity__c = 0;
        } else if(usage > total) {
            event.target.value = total;
            this.inventories[event.target.dataset.index].Usage_Quantity__c = total;
        }else {
            this.inventories[event.target.dataset.index].Usage_Quantity__c = usage;
            this.inventories[event.target.dataset.index].Available_Quantity__c = total - usage;
        }
        this.inventories[event.target.dataset.index].Used_Quantity__c = ((parseInt(event.target.value)/total)*100).toFixed(2);
        this.inventories[event.target.dataset.index].isShowIndicator = parseInt((parseInt(event.target.value)/total)*100) >= 70;
    }
    saveInventory() {
        let inventoriesToUpdate = [];
        let inventoriesCopy = this.inventoriesCopy;
        this.inventories.forEach(function(item,ind){
            if(item.Usage_Quantity__c != inventoriesCopy[ind].Usage_Quantity__c) {
                inventoriesCopy[ind].Usage_Quantity__c = item.Usage_Quantity__c;
                inventoriesToUpdate.push(inventoriesCopy[ind]);
            }
        });
        saveInventory({equipmentList: inventoriesToUpdate})
        .then(res => {
            let message = {};
            if(res == 'success') {
                message.title = 'Success!';
                message.message = 'Updated successfully.';
                message.variant = 'success';
                this.cancelClick();
            }
            else {
                message.title = 'Error!';
                message.message = res;
                message.variant = 'error';
            }
            const event = new ShowToastEvent(message);
            this.dispatchEvent(event);
            
        })
        .catch(error => {
            this.error = error;
            console.log('error-->' + JSON.stringify(error));
        });
    }
    editAll() {
        this.isEditall = true;
    }
    cancelClick() {
        this.fetchInventory();
        this.isEditall = false;
    }

    openEditModal(event){
        this.inventoryId = event.target.dataset.recid;
        this.invname = event.target.dataset.invname;
        this.isEditModalOpel = true;
    }

    closeModal() {
        this.fetchInventory();
        this.inventoryId = '';
        this.invname = '';
        this.isEditModalOpel = false;
    }

    connectedCallback(){
        this.fetchInventory();
    }
}