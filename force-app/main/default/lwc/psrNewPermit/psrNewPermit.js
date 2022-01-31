import { LightningElement, track, wire, api } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Portal_License_Validation_Help_Text from "@salesforce/label/c.Portal_License_Validation_Help_Text";
import Portal_Instructions_Help_Text from "@salesforce/label/c.Portal_Instructions_Help_Text";
import Portal_Site_Information_Help_Text from "@salesforce/label/c.Portal_Site_Information_Help_Text";
import Portal_Application_Information_Help_Text from "@salesforce/label/c.Portal_Application_Information_Help_Text";
import Portal_Contacts_Help_Text from "@salesforce/label/c.Portal_Contacts_Help_Text";
import Portal_Assign_Work_Order_Help_Text from "@salesforce/label/c.Portal_Assign_Work_Order_Help_Text";
import Portal_Documents_Help_Text from "@salesforce/label/c.Portal_Documents_Help_Text";
import Portal_Payment_Help_Text from "@salesforce/label/c.Portal_Payment_Help_Text";
import Portal_Submission_Help_Text from "@salesforce/label/c.Portal_Submission_Help_Text";
import Portal_Submission_Submission_Message from "@salesforce/label/c.Portal_Submission_Submission_Message";
import {
    registerListener,
    unregisterAllListeners,
    fireEvent,
    utility,
    sharedData,
} from "c/pubsub";
import getCurrentUser from "@salesforce/user/Id";
// Importing Apex Class method
import isLicensedUser from "@salesforce/apex/PsrNewPermitController.isLicensed";
import isProvider from "@salesforce/apex/PsrNewPermitController.isProvider";
import getCurrentStep from "@salesforce/apex/PsrNewPermitController.getCurrentStep";
import submitApp from "@salesforce/apex/PsrNewPermitController.submitApplication";
// importing to show toast notifictions
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import ID from "@salesforce/schema/Account.Id";
import USER_ID from "@salesforce/user/Id";
import CURRENT_STEP from "@salesforce/schema/Application__c.Current_Step__c";
import APP_STATUS from "@salesforce/schema/Application__c.Status__c";

export default class PsrNewPermit extends LightningElement {
    @api applicationType;
    @track staff_help =
        "Please add a sampling of Staff Records as part of your self assessment application and provide necessary details for each of those records";
    @track contact_help =
        "Please add a sampling of Student Records as part of your self assessment application and provide necessary details for each of those records";
    @track assessment_helptext =
        "Please complete the following Self-Assessment Questionnaire and provide necessary information";
    @track submission_helptext = "Application Summary and Submissions Page";
    @track review_help = "Please review application details.";
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
    @track isProvider = false;
    currentUser = getCurrentUser;
    ID = ID;
    preventNext = false;
    @track isRenew = null;
    @track appId = utility.getUrlParam("appId");
    @track currentstepParam = utility.getUrlParam("currentstep");
    @track currentStepValue = 0;
    @track originalStep = 0;
    @track isReadOnly;
    @api Portal_License_Validation_Help_Text =
        Portal_License_Validation_Help_Text;
    @api Portal_Instructions_Help_Text = Portal_Instructions_Help_Text;
    @api Portal_Site_Information_Help_Text = Portal_Site_Information_Help_Text;
    @api Portal_Application_Information_Help_Text =
        Portal_Application_Information_Help_Text;
    @api Portal_Contacts_Help_Text = Portal_Contacts_Help_Text;
    @api Portal_Assign_Work_Order_Help_Text =
        Portal_Assign_Work_Order_Help_Text;
    @api Portal_Documents_Help_Text = Portal_Documents_Help_Text;
    @api Portal_Payment_Help_Text = Portal_Payment_Help_Text;
    @api Portal_Submission_Help_Text = Portal_Submission_Help_Text;
    @api Portal_Submission_Submission_Message =
        Portal_Submission_Submission_Message;
    @track checkbox = false;

    @wire(CurrentPageReference) pageRef;

    @track appRecord;
    @wire(getRecord, { recordId: "$appId", fields: [APP_STATUS] })
    wiredRecord({ error, data }) {
        console.log("In get record method");
        if (error) {
            let message = "Unknown error";
            if (Array.isArray(error.body)) {
                message = error.body.map((e) => e.message).join(", ");
            } else if (typeof error.body.message === "string") {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error loading contact",
                    message: "No contacts fetched",
                    variant: "error",
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
        isLicensedUser()
            .then((res) => {
                this.isLicensedUser = res;

                if (this.originalStep <= this.isLicensedUser) {
                    if (this.isLicensedUser) {
                        this.currentStep = 0;
                    } else {
                        this.currentStep = 1;
                    }
                }

                if (this.currentstepParam === "5") {
                    this.goNext(5);
                }
            })
            .catch((err) => {
                console.error("error here", JSON.stringify(err));
            });

        isProvider()
            .then((res) => {
                this.isProvider = res;
                console.log("this.isProvider" + this.isProvider);
            })
            .catch((err) => {
                console.error("error here", JSON.stringify(err));
            });

        getCurrentStep({ appId: this.appId })
            .then((res) => {
                this.currentStep = 1;
                this.originalStep = 1;
            })
            .catch((err) => {
                console.error("error here", JSON.stringify(err));
            });

        registerListener("handleBack", this.handleBackButton, this);
        registerListener("handleNext", this.handleNextButton, this);
        registerListener("handleSideBarClick", this.handleSideBarClick, this);
        registerListener("stepincrease", this.handleIncreaseCounter, this);
        registerListener("showSpinner", this.showProgress, this);
        registerListener("hideSpinner", this.hideProgress, this);
        registerListener(
            "statusAndStanding",
            this.handleStatusAndStanding,
            this
        );

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
        return "New Self-Assessment Application";
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleSideBarClick(myCurrentStep) {
        this.currentStep = myCurrentStep;

        // if (this.currentStep === 0) {
        //   this.enableLicenseValidation = true;
        // }
        if (this.currentStep === 1) {
            this.enableInstructions = true;
        }
        // if (this.currentStep === 2) {
        //   this.enableAddress = true;
        // }
        if (this.currentStep === 2) {
            this.enableStudent = true;
        }
        if (this.currentStep === 3) {
            this.enableStaff = true;
        }
        if (this.currentStep === 4) {
            this.enableDocuments = true;
        }
        if (this.currentStep === 5) {
            this.enableAssessment = true;
        }
        if (this.currentStep === 5) {
            this.enableReview = true;
        }
        if (this.currentStep === 7) {
            this.enableSubmission = true;
        }
        // if (this.currentStep === 7) {
        //   this.enablePayment = true;
        // }
        // if (this.currentStep === 8) {
        //   this.enableSubmission = true;
        // }
    }

    //Handle Back & Next buttons in parent.
    handleBackButton(event) {
        this.goBack(this.currentStep - 1);
        // if(this.isProvider && this.currentStep == 6) {
        //   this.goBack(this.currentStep - 2);
        // }else{
        //   this.goBack(this.currentStep - 1);
        // }
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
        console.log(this.preventNext);
        if (this.preventNext) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Please upload required documents",
                    variant: "error",
                })
            );
        } else {
            this.goToNext();
        }
        // if (this.currentStep == 0) {
        //   this.template
        //     .querySelector("c-psr-license-validation")
        //     .submitApplication()
        //     .then(data => {
        //       if (data) {
        //         this.goToNext();
        //       }
        //     });
        // } else if (this.currentStep == 2) {
        //   this.template
        //     .querySelector("c-psr-address-site-validation")
        //     .submitApplication()
        //     .then(data => {
        //       if (data) {
        //         this.goToNext();
        //       }
        //     });
        // } else if (this.currentStep == 3) {
        //   this.template
        //     .querySelector("c-psr-application-information")
        //     .submitApplication()
        //     .then(data => {
        //       if (data) {
        //         this.goToNext();
        //       }
        //     });
        // } else if (this.currentStep == 7) {
        //   this.template
        //     .querySelector("c-psr-payments")
        //     .submitApplication()
        //     .then(data => {
        //       if (data) {
        //         this.goToNext();
        //       }
        //     });
        // }else if(this.isProvider && this.currentStep == 4) {
        //   this.goToNext();
        //   this.goToNext();
        // }else {
        //   this.goToNext();
        // }
    }

    goToNext() {
        this.currentStep += 1;
        this.goNext(this.currentStep);

        if (this.originalStep <= this.currentStep) {
            this.originalStep = this.currentStep;
            utility.setCurrentStep(
                this.currentStep,
                utility.getUrlParam("appId")
            );
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

    sendCommunicationToChild() {
        if (this.currentStep === 0) {
            this.template
                .querySelector("c-utha-entity-information")
                .handleNext("");
        } else if (this.currentStep === 1) {
            this.showProgress();
            this.template.querySelector("c-utah-entity-address").handleNext();
        } else if (this.currentStep === 2) {
            this.showProgress();
            this.template
                .querySelector("c-utha-entity-primary-contact")
                .handleNext();
        } else if (this.currentStep === 3) {
            this.showProgress();
            this.template
                .querySelector("c-utha-entity-boundary-information")
                .handleNext();
        } else if (this.currentStep === 4) {
            this.showProgress();
            this.template
                .querySelector("c-utha-entity-board-members")
                .handleNext();
        } else if (this.currentStep === 5) {
            this.showProgress();
            this.template
                .querySelector("c-utha-entity-creation-revenue")
                .handleNext();
        } else if (this.currentStep === 6) {
            this.showProgress();
            this.template.querySelector("c-utha-payment").handleNext();
        }
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
    // get enableLicenseValidation() {
    //   //this.showSpinner = false;
    //   return this.currentStep === 0 ? true : false;
    // }

    get enableInstructions() {
        return this.currentStep === 1 ? true : false;
    }

    // get enableAddress() {
    //   //this.showSpinner = false;
    //   return this.currentStep === 2 ? true : false;
    // }
    get enableStudent() {
        return this.currentStep == 2 ? true : false;
    }
    get enableStaff() {
        return this.currentStep == 3 ? true : false;
    }
    // get enableAppInformation() {
    //   return this.currentStep === 3 ? true : false;
    // }

    get enableMessage() {
        return true; //this.currentStep === 0 ? true : false;
    }
    // get enablePrimaryContact() {
    //   return this.currentStep === 4 ? true : false;
    // }

    // get enableAssignWorkOrder() {
    //   return this.currentStep === 5 && (!this.isProvider) ? true : false;
    // }

    get enableDocuments() {
        return this.currentStep === 4 ? true : false;
    }
    get enableAssessment() {
        return this.currentStep === 5 ? true : false;
    }
    // get enablePayment() {
    //   return this.currentStep === 7 ? true : false;
    // }
    get enableReview() {
        return this.currentStep === 6 ? true : false;
    }
    get enableSubmission() {
        return this.currentStep === 7 ? true : false;
    }

    get enableBackButton() {
        return (this.currentStep > 0 && this.isLicensedUser) ||
            (this.currentStep > 1 && !this.isLicensedUser)
            ? true
            : false;
    }

    get enableNextButton() {
        return this.currentStep < 7 ? true : false;
    }

    get enableSubmitButton() {
        return this.currentStep === 7 && !this.isReadOnly ? true : false;
    }

    handleSaveExit() {
        if (this.currentStep === 0) {
            this.template
                .querySelector("c-utha-entity-information")
                .handleNext("exit");
        } else if (this.currentStep === 1) {
            this.template
                .querySelector("c-utah-entity-address")
                .handleNext("exit");
        } else if (this.currentStep === 2) {
            this.template
                .querySelector("c-utha-entity-primary-contact")
                .handleNext("exit");
        } else if (this.currentStep === 3) {
            this.template
                .querySelector("c-utha-entity-boundary-information")
                .handleNext("exit");
        } else if (this.currentStep === 4) {
            this.template
                .querySelector("c-utha-entity-board-members")
                .handleNext("exit");
        } else if (this.currentStep === 5) {
            this.template
                .querySelector("c-utha-entity-creation-revenue")
                .handleNext("exit");
        } else if (this.currentStep === 6) {
            this.template.querySelector("c-utha-payment").handleNext("exit");
        }
    }

    handleClick() {
        utility.navigateToPage("");
    }

    onAddContact() {
        console.log("add con");
        this.isOpenModal = true;
    }

    handleCloseModal() {
        console.log("close");
        this.isOpenModal = false;
    }
    handleCheckboxChange(event) {
        if (event.detail.checkbox == true) this.checkbox = true;
    }

    handleSubmit() {
        if (this.checkbox == false) {
            alert("Please select the Checbox to proceed");
            return;
        }
        console.log("++++submitApplication++++++++++");
        submitApp({ appId: this.appId })
            .then((result) => {
                window.console.log("success App Submitted ===>");
                // Show success messsage
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success!!",
                        message: "Application Submitted Successfully!!",
                        variant: "success",
                    })
                );
                window.open(`/psr`, "_self");
            })
            .catch((error) => {
                this.error = error.message;
            });
    }

    handleSuccess() {
        console.log("no error");
        this.preventNext = false;
    }

    handleError() {
        console.log("has error");
        this.preventNext = true;
    }
}