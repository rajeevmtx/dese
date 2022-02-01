import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import chatterLogo from "@salesforce/resourceUrl/chatterLogo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { utility } from "c/pubsub";

import getProposalRecords from "@salesforce/apex/DashboardController.getProposalRecords";

export default class DeseStatusCard extends NavigationMixin(LightningElement) {
    @api status;
    @track isChatterLogo = false;
    @track showReUploadDocs = false;
    @track divCss;
    @track ecr;
    @track isChatter = false;
    @track currentEvId = "";
    @track isLoading = false;
    @track response;

    connectedCallback() {
        this.loadRecords();
        if (this.status == "Draft") {
            this.divCss = "slds-col card-sidecolor-orange";
        } else if (this.status == "Under Review") {
            this.divCss = "slds-col card-sidecolor-pink";
            this.isChatterLogo = true;
            this.showReUploadDocs = true;
        } else if (this.status == "Approved" || this.status == "Completed") {
            this.divCss = "slds-col card-sidecolor-blue";
            this.isChatterLogo = true;
        } else if (this.status == "Pending Approval") {
            this.divCss = "slds-col card-sidecolor-purple";
            this.isChatterLogo = true;
        } else if (this.status == "Submitted") {
            this.divCss = "slds-col card-sidecolor-green";
            this.isChatterLogo = true;
            this.showReUploadDocs = true;
        }
    }
    loadRecords() {
        this.isLoading = true;
        getProposalRecords({
            status: this.status,
        })
            .then((result) => {
                console.log("getProposalRecods Result: ", result);
                this.ecr = JSON.parse(result);
                this.isLoading = false;
            })
            .catch((error) => {
                console.log("getProposalRecords Error: ", error);
                this.isLoading = false;
            });
    }
    get fullUrl() {
        let url0 = window.location.protocol + "//" + window.location.hostname;
        let url = "/psr/apex/PsrChatterPage?id=";
        let completeURL = url0 + url + this.currentEvId;
        //"https://demo-lp.force.com/psr/apex/PsrChatterPage?id=" + this.currentEvId
        return completeURL;
    }
    redirectToChatter(event) {
        console.log(
            "redirectToChatter: " + event.currentTarget.getAttribute("data-id")
        );
        this.currentEvId = event.currentTarget.getAttribute("data-id");
        this.isChatter = true;
        //this.fullurl= 'https://mtxlicensingpermit--c.visualforce.com/apex/PsrChatterPage?id='+event.currentTarget.getAttribute('data-id');
        console.log("URL: " + this.fullurl);
    }

    redirectToPermit(event) {
        console.log(
            "redirectToPermit: " + event.currentTarget.getAttribute("data-id")
        );

        this.response = event.currentTarget.getAttribute("data-id");
        window.open(
            "/dese/s/grant-application?projectId=" +
                this.response,
            "_self"
        );
    }

    redirectToGrant(event){
        console.log(
            "redirectToPermit: " + event.currentTarget.getAttribute("data-id")
        );

        let grantId = event.currentTarget.getAttribute("data-id");
        window.open(
            "/dese/s/grants-detail?grantId=" +grantId,
            "_self"
        );
    }

   
    handleCloseModal() {
        this.isChatter = false;
        this.currentEvId = "";
    }
}