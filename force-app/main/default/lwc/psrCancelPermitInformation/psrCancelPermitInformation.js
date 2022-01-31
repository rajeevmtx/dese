import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class PsrCancelPermitInformation extends LightningElement {
  objectApiName = "Application__c";
  @track licenseNo = "";
  @api isReadyOnly;

  @api
  get disabledFields() {
    return this.isReadyOnly;
  }
  set disabledFields(value) { 
    this.isReadyOnly = value;
  }

  constructor() {
    super();
    console.log('here');
  }

  handleSuccess(event) {}


  checkLicenseNo(event) {
    this.licenseNo = event.target.value;
  }

  showError(message) {
    const evt = new ShowToastEvent({
      title: "Error",
      message: message,
      variant: "error"
    });
    this.dispatchEvent(evt);
  }
}