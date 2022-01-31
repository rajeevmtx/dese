import { LightningElement, track, api } from "lwc";
import { utility } from "c/pubsub";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LICENSE_TYPE from "@salesforce/schema/Application__c.License_Type__c";
import LICENSE_NO from "@salesforce/schema/Application__c.License__c";
export default class PsrLicenseValidation extends LightningElement {
  @track appId = "";
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
    this.appId = utility.getUrlParam("appId");
  }
  fields = [LICENSE_TYPE, LICENSE_NO];

  handleSuccess(event) {}

  @api submitApplication() {
    return new Promise((resolve, reject) => {
      if (this.licenseNo === "") {
        // this.showError('Please enter license number');
        resolve(true);
      } else {
        this.template.querySelector("lightning-record-edit-form").submit();
        resolve(true);
      }
    });
  }

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