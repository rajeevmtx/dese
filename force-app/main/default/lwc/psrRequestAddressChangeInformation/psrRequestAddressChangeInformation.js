import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class PsrRequestAddressChangeInformation extends LightningElement {
  objectApiName = "Application__c";
  @track licenseNo = "";
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