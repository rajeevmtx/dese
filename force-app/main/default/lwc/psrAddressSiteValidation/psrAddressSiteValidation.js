import { LightningElement, api, track } from "lwc";

import { utility } from "c/pubsub";

export default class PsrAddressSiteValidation extends LightningElement {
  @track appId;
  @api recordId;
  @api isReadyOnly;
  @api isLocationFetched = false;
  @track addressFromGoogle = {};

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

  // handleSubmit(event) {
  //     console.log('onsubmit: '+ event.detail.fields);
  //     event.preventDefault(); // stop the form from submitting
  //     const fields = event.detail.fields;
  //     console.log(JSON.stringify(fields));

  //     this.template.querySelector('lightning-record-edit-form').submit(fields);

  // }
  // handleSuccess(event) {
  //     let payload = event.detail;
  //     console.log(JSON.stringify(payload));

  //     const updatedRecord = event.detail.id;
  //     console.log('onsuccess: ', updatedRecord);
  // }

  connectedCallback() {
    this.appId = utility.getUrlParam("appId");
  }

  @api submitApplication() {
    return new Promise((resolve, reject) => {
      this.template.querySelector("lightning-record-edit-form").submit();
      resolve(true);
    });
  }
  //fetchinglocation
  locationFetched(event) {
    let selectedlocation = event.detail;
    selectedlocation.forEach(element => {
      switch (true) {
        case element.types.includes("postal_code"):
          this.addressFromGoogle.postalCode = element.long_name;
          break;
        case element.types.includes("administrative_area_level_1"):
          this.addressFromGoogle.state = element.long_name;
          break;
        case element.types.includes("locality"):
          this.addressFromGoogle.city = element.long_name;
          break;
        case element.types.includes("street_number"):
          this.addressFromGoogle.street = element.long_name;
          break;
        case element.types.includes("route"):
            if(this.addressFromGoogle.street != undefined){
                this.addressFromGoogle.route =
                this.addressFromGoogle.street + " " + element.long_name;
            }else{
                this.addressFromGoogle.route = element.long_name;
            }
        
          break;

        default:
      }
    });
    this.isLocationFetched = true;
  }
}