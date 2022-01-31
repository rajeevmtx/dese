import { LightningElement, track, api } from "lwc";
import { utility } from "c/pubsub";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import submitApp from "@salesforce/apex/fcNewLicenseController.submitApplication";
import getAppNo from "@salesforce/apex/fcNewLicenseController.getAppNumber";
import Portal_Submission_Submission_Message from '@salesforce/label/c.Portal_Submission_Submission_Message'; 

export default class FcSubmission extends LightningElement {
    @track appId = "";
    @track appNo;
    @api Portal_Submission_Submission_Message = Portal_Submission_Submission_Message;
    @track helpText = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
  
    constructor() {
      super();
      this.appId = utility.getUrlParam("appId");
    }

    get todayDate(){
      let today = new Date();
      var dd = today.getDate();
      var mm = today.getMonth() + 1;
      var yyyy = today.getFullYear();
  
      if (dd < 10) dd = '0' + dd;
      if (mm < 10) mm = '0' + mm;
      return (yyyy + '-' + mm + '-' + dd);
  }
  
    @api submitApplication() {
      return new Promise((resolve, reject) => {
        this.updateStep();
        console.log("++++submitApplication++++++++++");
        submitApp({ appId: this.appId })
          .then(result => {
            window.console.log("success App Submitted ===>");
            // Show success messsage
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success!!",
                message: "Application Submitted Successfully!!",
                variant: "success"
              })
            );
            window.open(`/fc`, "_self");
          })
          .catch(error => {
            this.error = error.message;
          });
        resolve(true);
      });
    }
  
    connectedCallback() {
      getAppNo({ appId: this.appId })
        .then(res => {
          this.appNo = res;
        })
        .catch(err => {
          console.error("error here", JSON.stringify(err));
        });
    }
}