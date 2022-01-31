import { LightningElement,api } from 'lwc';

export default class Dese_intake_modal extends LightningElement {
    @api applicationName;
    isModalOpen = true;

    // showModal() {
    //     this.isModalOpen = true;
    //   }
      closeModal() {
        this.isModalOpen = false;
      }
      get modalClass() {
        return `slds-modal ${this.isModalOpen ? "slds-fade-in-open" : ""}`;
      }
      get modalBackdropClass() {
        return `slds-backdrop ${this.isModalOpen ? "slds-backdrop_open" : ""}`;
      }

      handleSave(){
        window.open('/dese/s/grants-dashboard','_self');
      }
}