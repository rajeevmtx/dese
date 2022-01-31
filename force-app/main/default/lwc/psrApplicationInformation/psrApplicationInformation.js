import { LightningElement, api, track } from "lwc";
import { utility } from "c/pubsub";

export default class PsrApplicationInformation extends LightningElement {
  @track appId;
  @api recordId;
  @api isReadyOnly;

  @api
  get disabledFields() {
    return this.isReadyOnly;
  }
  set disabledFields(value) {
    this.isReadyOnly = value;
  }

  handleSubmit(event) {
    console.log("onsubmit: " + event.detail.fields);
  }
  handleSuccess(event) {
    const updatedRecord = event.detail.id;
    console.log("onsuccess: ", updatedRecord);
  }

  connectedCallback() {
    console.log("inAddress");
    this.appId = utility.getUrlParam("appId");
    console.log("appId-->" + this.appId);
  }

  @api submitApplication() {
    return new Promise((resolve, reject) => {
      console.log(this.template.querySelector("lightning-record-edit-form"));
      this.template.querySelector("lightning-record-edit-form").submit();
      resolve(true);
    });
  }
}