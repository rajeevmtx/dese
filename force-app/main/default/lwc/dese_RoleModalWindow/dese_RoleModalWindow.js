import { LightningElement, api, track } from 'lwc';

export default class Dese_RoleModalWindow extends LightningElement {

    @api projectId;
    @track isModalOpen = false;

    genericHandler(event) {
        var inputname = event.currentTarget.dataset.id;
        this.school[inputname] = (NUM_FIELDS.includes(inputname)) ? parseInt(event.target.value ? event.target.value : 0) : event.target.value;
    }

    showModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    genericHandler(){
        
    }

    get modalClass() {
        return `slds-modal ${this.isModalOpen ? "slds-fade-in-open" : ""}`;
    }

    get modalBackdropClass() {
        return `slds-backdrop ${this.isModalOpen ? "slds-backdrop_open" : ""}`;
    }

    handleSave() {
        this.isModalOpen = false;
    }
}