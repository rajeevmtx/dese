import { LightningElement, track, api } from "lwc";
import { utility } from "c/pubsub";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import submitApp from "@salesforce/apex/PsrNewPermitController.submitApplication";
import getAppNo from "@salesforce/apex/PsrNewPermitController.getAppNumber";
import Portal_Submission_Submission_Message from "@salesforce/label/c.Portal_Submission_Submission_Message";
import checkbox from "@salesforce/resourceUrl/checkbox";

export default class PsrSubmission extends LightningElement {
    @track checkbox;
    @track appId = "";
    @track appNo;
    @api Portal_Submission_Submission_Message =
        Portal_Submission_Submission_Message;
    @track submit_message =
        "I have read and understood the questions in this application. I have reviewed my answers to the application questions, and, to the best of my knowledge, the information I have provided and the responses I have given are true.<br/><br/>" +
        "I understand that furnishing or making any misleading or false statements or reports anywhere in this application is grounds to revoke, suspend, refuse to issue or refuse to renew a license.<br/><br/>";

    constructor() {
        super();
        this.appId = utility.getUrlParam("appId");
    }
    get attestation_text() {
        return "I attest, under penalty of perjury, that all information provided on this form is true and accurate.";
    }
    handleCheckbox(event) {
        if (event.target.checked) {
            this.checkbox = true;
            const event = new CustomEvent("checkboxchange", {
                detail: {
                    checkbox: true,
                },
            });
            this.dispatchEvent(event);
        }
    }
    @api submitApplication() {
        return new Promise((resolve, reject) => {
            this.updateStep();
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
            resolve(true);
        });
    }

    connectedCallback() {
        getAppNo({ appId: this.appId })
            .then((res) => {
                this.appNo = res;
            })
            .catch((err) => {
                console.error("error here", JSON.stringify(err));
            });
    }
}