import { LightningElement, track, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import Portal_Instructions_Help_Text from '@salesforce/label/c.Portal_Instructions_Help_Text';
import {
  registerListener,
  unregisterAllListeners,
  utility,
} from "c/pubsub";
import getCurrentUser from "@salesforce/user/Id";
import psrCommunityName from '@salesforce/label/c.PSR_Community_Name';

// Importing Apex Class method
// importing to show toast notifictions
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import ID from "@salesforce/schema/Account.Id";
import USER_ID from "@salesforce/user/Id";
import APP_STATUS from "@salesforce/schema/Application__c.Status__c";

export default class PsrRequestDuplicatePermit extends LightningElement {
  @api Portal_Instructions_Help_Text = Portal_Instructions_Help_Text;
  @api applicationType;
  @track currentStep = 0;
  @track activeCss = "slds-progress__item slds-is-active";
  @track show = "slds-show";
  @track hide = "slds-hide";
  @track entityId;
  @track ecrId;
  @track quote;
  @track shippingstate;
  @track tabIndex;
  @track missingDocs;
  @track entityIdFromRandomClick;
  @track pricebookId;
  @track contact;
  @track showSpinner = false;
  @track showSaveAndExitButtons = true;
  @track status;
  @track standing;
  @track isOpenModal = false;
  @track isLicensedUser = false;
  currentUser = getCurrentUser;
  ID = ID;
  @track isRenew = null;
  @track appId = utility.getUrlParam("appId");
  @track currentstepParam = utility.getUrlParam("currentstep");
  @track currentStepValue = 0;
  @track originalStep = 0;
  @track isReadOnly;

  @wire(CurrentPageReference) pageRef;

  @track appRecord;
  @wire(getRecord, { recordId: "$appId", fields: [APP_STATUS] })
  wiredRecord({ error, data }) {
    console.log("In get record method");
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map(e => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading contact",
          message,
          variant: "error"
        })
      );
    } else if (data) {
      console.log("In get record success", data);
      this.appRecord = data;
      console.log(
        "this.Application__c.fields.Status__c.value",
        this.appRecord.fields.Status__c.value
      );
      if (this.appRecord.fields.Status__c.value != "Draft") {
        this.isReadOnly = true;
      }
    }
  }

  connectedCallback() {
        this.currentStep = 0;
        this.originalStep = 0;
     
    registerListener("handleBack", this.handleBackButton, this);
    registerListener("handleNext", this.handleNextButton, this);
    registerListener("handleSideBarClick", this.handleSideBarClick, this);
    registerListener("stepincrease", this.handleIncreaseCounter, this);
    registerListener("showSpinner", this.showProgress, this);
    registerListener("hideSpinner", this.hideProgress, this);
    registerListener("statusAndStanding", this.handleStatusAndStanding, this);

    this.currentStep = 0;
    let _pageUrl = window.location.href;
    let _recordId = new URL(_pageUrl).searchParams.get("appId");
    console.log("@@@@" + _recordId);
  }

  handleStatusAndStanding(data) {
    this.status = data.status;
    this.standing = data.standing;
    this.siteId = data.siteId;
  }

  renderedCallback() {
    if (USER_ID == undefined || USER_ID == null || USER_ID == "") {
      this.showSaveAndExitButtons = false;
    } else {
      this.showSaveAndExitButtons = true;
    }
  }

  get getHeading() {
    return "Request Duplicate Permit";
  }

  disconnectedCallback() {
    unregisterAllListeners(this);
  }

  handleSideBarClick(myCurrentStep) {
    this.currentStep = myCurrentStep;

    if (this.currentStep === 0) {
        this.enableInstructions = true;
    }
    if (this.currentStep === 1) {
      this.enableAppInformation = true;
    }
  }

  //Handle Back & Next buttons in parent.
  handleBackButton(event) {
    this.goBack(this.currentStep - 1);
  }

  showProgress() {
    console.log("//////showProgress");
    this.showSpinner = true;
    console.log("//////////////////" + this.showSpinner);
  }

  hideProgress() {
    console.log("//////hideProgress");
    this.showSpinner = false;
    console.log("//////////////////" + this.showSpinner);
  }

  handleNextButton() {
      this.goToNext();
  }

  goToNext() {
    this.currentStep += 1;
    this.goNext(this.currentStep);

    if (this.originalStep <= this.currentStep) {
      this.originalStep = this.currentStep;
      utility.setCurrentStep(this.currentStep, null);
    }
  }

  handleIncreaseCounter(data) {
    console.log("handle sel Licensed data::" + data);
    this.entityIdFromRandomClick = data;
    this.goNext(this.currentStep + 1);
  }

  handleDecreaseCounter() {
    this.goNext(this.currentStep - 1);
  }

  //Back Button
  goBack(currentStepNumber) {
    this.currentStep = currentStepNumber;
  }

  //Next Button
  goNext(currentStepNumber) {
    this.currentStep = currentStepNumber;
  }

  //Show data according to current step
  get enableInstructions() {
    //this.showSpinner = false;
    return this.currentStep === 0 ? true : false;
  }

  get enableAppInformation() {
    return this.currentStep === 1 ? true : false;
  }

  get enableBackButton() {
    return this.currentStep > 0 ? true : false;
  }
 
  get enableNextButton() {
    return this.currentStep < 1 ? true : false;
  }

  get enableSubmitButton() {
    return this.currentStep === 1 ? true : false;
  }

  handleSaveExit() {
    console.log('here saved')
  }

  handleClick() {
    utility.navigateToPage("");
  }

  handleSubmit() {
    console.log("++++submitApplication++++++++++");
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success!!",
            message: "Your request for duplicate permit has been successfully submitted !!",
            variant: "success"
          })
        );
        setTimeout(function(){window.open(`/`+psrCommunityName, "_self");}, 2000);

        
  }
}