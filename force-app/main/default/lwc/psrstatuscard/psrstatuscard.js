/* eslint-disable no-console */
import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import chatterLogo from "@salesforce/resourceUrl/chatterLogo";
import ecrList from "@salesforce/apex/PsrStatusInfo.statusList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import downloadPermitFile from "@salesforce/apex/PsrStatusInfo.downloadPermitFile";
import createInspectionRecords from "@salesforce/apex/PsrStatusInfo.createInspectionRecords";
import { utility } from "c/pubsub";

export default class Psrstatuscard extends NavigationMixin(LightningElement) {
    chatterLogo = chatterLogo;
    @track ecr;
    //@track fullurl = 'https://mtxlicensingpermit--c.visualforce.com/apex/PsrChatterPage';
    @api isReloaded = false;
    @track isChatter = false;
    @track currentEvId = "";
    @api status;
    @track closedCheck = false;
    @track divCss; 
    theIframe;
    @track showResumeApplication = false;
    @track showResubmitApplication = false;
    @track isChatterLogo = false;
    @track showNonComplaint = false;
    //@track showRequestInspection = true;
    @track showReUploadDocs = false;

    connectedCallback() {
        this.loadEcr();
        if (this.status == "Draft") {
            this.divCss = "slds-col card-sidecolor-orange";
            this.showResumeApplication = true;
            this.showResubmitApplication = false;
            this.showNonComplaint = false;
            this.closedCheck = false;
        } else if (this.status == "Under Review") {
            this.divCss = "slds-col card-sidecolor-pink";
            this.showResubmitApplication = false;
            this.showResumeApplication = true;
            this.showNonComplaint = false;
            this.isChatterLogo = true;
            this.closedCheck = false;
            this.showReUploadDocs = true;
        } else if (this.status == "Approved") {
            this.divCss = "slds-col card-sidecolor-blue";
            this.showResubmitApplication = true;
            this.showResumeApplication = false;
            this.showNonComplaint = true;
            this.isChatterLogo = true;
            this.closedCheck = false;
        } else if (this.status == "Closed") {
            this.divCss = "slds-col card-sidecolor-purple";
            this.showResumeApplication = false;
            this.showResubmitApplication = false;
            this.showNonComplaint = false;
            this.isChatterLogo = true;
            this.closedCheck = true;
        } else if (this.status == "Submitted") {
            this.divCss = "slds-col card-sidecolor-green";
            this.showResumeApplication = false;
            this.showResubmitApplication = false;
            this.showNonComplaint = false;
            this.isChatterLogo = true;
            this.closedCheck = false;
            this.showReUploadDocs = true;
        }
    }
    loadEcr() {
        ecrList({ status: this.status })
            .then(result => {
                //fireEvent(this.pageRef, "hideSpinner",this );
                this.ecr = result;
                //     console.log('ecr result>>>>>',JSON.stringify(this.ecr));
                //     let i;
                //    for(i=0;i<result.length;i++){
                //         this.ecr[i].showRequestInspection = true;
                //    }
            })
            .catch(error => {
                this.error = error;
                console.log("33333");
                console.log(this.error);
            });
    }
    get fullUrl() {
        let url0 = window.location.protocol+'//'+window.location.hostname;
            let url = '/psr/apex/PsrChatterPage?id=';
            let completeURL = url0+url+this.currentEvId;
             //"https://demo-lp.force.com/psr/apex/PsrChatterPage?id=" + this.currentEvId
        return (
            completeURL 
        );
    }
    renderedCallback() {
        console.log("rendred callback called" + this.theIframe);
        if (this.theIframe == undefined) {
            let url0 = window.location.protocol+'//'+window.location.hostname;
            let url = '/psr/apex/PsrChatterPage?id=';
            this.fullurl = url0+url+this.currentEvId;
        }
    }

    handleResumeApplication(event) {
        var applicationId = event.target.dataset.id;
        //var applicationId = '0011700000pgIImAAM';
        console.log(JSON.stringify(event.target.dataset.name));
        if (event.target.dataset.name == "Initial_Registration")
            utility.navigateToPage("entityregistration", "id=" + applicationId);
        else if (event.target.dataset.name == "Name_Change_Certification")
            utility.navigateToPage("update-entity-name", "id=" + applicationId);
        else if (event.target.dataset.name == "New_Entity_Request")
            utility.navigateToPage(
                "report-non-registered",
                "ecrId=" + event.target.dataset.ecrid
            );
        else if (event.target.dataset.name == "Registration_Renewal")
            utility.navigateToPage("renew-registration", "id=" + applicationId);
        else if (event.target.dataset.name == "Primary_Contact_Change")
            utility.navigateToPage("update-primary-contact", "id=" + applicationId);
        else if (event.target.dataset.name == "Boundary_Action")
            utility.navigateToPage("boundary-actions", "id=" + applicationId);
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
    downloadFile(event) {
        var recordid = event.currentTarget.getAttribute("data-id");
        console.log("ID -->  + " + recordid);
        downloadPermitFile({ recordId: recordid })
            .then(result => {
                var downloadurl = result;
               /* this[NavigationMixin.Navigate]({
                    type: 'standard__webPage', 
                    attributes: {
                        url: downloadurl
                    },
                    /*state : {
                        id: recordid,
                        //selectedRecordId:recordid
                    }*/
                    
               // });
               window.open(downloadurl, "_blank");
                //window.location.reload(); 
            })
            .catch(error => {
                this.error = error;
                console.log("URL Error: " + JSON.stringify(error));
            });
    }
    redirectToPermit(event) {
        console.log("redirectToChatter");
        var target = event.currentTarget;
        let appId = target.getAttribute("data-id");
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: "/psrnewpermit?appId=" + appId
                }
            },
            true
        );
    }

    openNotification() {
        console.log("In Notify");

        this.template.querySelector("#notify").classList.toggle("slds-hidden");
    }

    handleCloseModal() {
        this.isChatter = false;
    }
    handleInspections(event) {
        var recordid = event.currentTarget.getAttribute("data-id");
        var indexClicked = event.currentTarget.getAttribute("data-index");
        createInspectionRecords({ applicationId: recordid })
            .then(result => {
                let vari,
                    message = "";
                if (result === "Inspection has been requested successfully") {
                    this.vari = "success";
                    message = result;
                    this.ecr[indexClicked].showRequestInspection = false;
                    //this.showRequestInspection = false;
                } else if (result === "No Application Work Order are available") {
                    message = result;
                    this.vari = "error";
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: result,
                        message,
                        variant: this.vari
                    })
                );
            })
            .catch(error => {
                this.error = error;
                console.log("URL Error: " + JSON.stringify(error));
            });
    }

    handleReUpload(event) {
        let applicationId = event.currentTarget.getAttribute("data-id");
        utility.setCurrentStep(6, applicationId);
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: "/psrnewpermit?appId=" + applicationId
                }
            },
            true
        );
    }
}