import { LightningElement, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import font_awesome_css from "@salesforce/resourceUrl/font_awesome_css";
import EntitiesLogo from "@salesforce/resourceUrl/MtxLogo";
import { NavigationMixin } from "lightning/navigation";

import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";
import USER_ID from "@salesforce/user/Id";
import { utility } from "c/pubsub";
import Portal_Dashboard_Header_Help_Text from "@salesforce/label/c.Portal_Dashboard_Header_Help_Text";
import Portal_Dashboard_Application_Component_Header_Help_Text from "@salesforce/label/c.Portal_Dashboard_Application_Component_Header_Help_Text";
import getStatusInfo from "@salesforce/apex/DashboardController.getStatusInfo";

export default class DeseDashboardDuo extends NavigationMixin(
    LightningElement
) {
    @track showSpinner;
    @track showStatus;
    @track var81 = true;
    @track Portal_Dashboard_Header_Help_Text =
        Portal_Dashboard_Header_Help_Text;
    @track Portal_Dashboard_Application_Component_Header_Help_Text =
        Portal_Dashboard_Application_Component_Header_Help_Text;
    @track pendingStatus = 0;
    @track completedStatus = 0;
    @track approvedStatus = 0;
    @track underReviewStatus = 0;
    @track submittedStatus = 0;
    @track createdStatus = 0;
    @track var1 = "active";
    @track var2 = "";
    @track var3 = "";
    @track var4 = "";
    @track var5 = "";
    @track var6 = "";
    @track draft = false;
    @track submitted = false;
    @track underReview = false;
    @track approved = false;
    @track created = false;
    @track completed = false;
    @track pending = false;
    @track pendingButtonClass = "";
    @track completedButtonClass = "";
    @track approvedButtonClass = "";
    @track underReviewButtonClass = "";
    @track submittedButtonClass = "";
    @track createdButtonClass = "";
    @track statusButtonClass =
        "tab-button slds-col slds-size_1-of-1 slds-medium-size_2-of-12 slds-large-size_2-of-12";

    connectedCallback() {
        this.createdButtonClass = this.statusButtonClass + " active";
        this.var1 = "active";
            this.draft = true;
        this.showSpinner = true;
        Promise.all([
            // loadScript(this, bootstrap_js +'/bootstrapjs/bootstrap.js'),
            loadStyle(this, font_awesome_css + "/fontawesome.css"),
            loadStyle(this, font_awesome_css + "/fontawesome.min.css"),
            // loadStyle(this, bootstrap_Css + '/bootstrapCss/bootstrap-theme.css'),
            // loadStyle(this, bootstrap_Css + '/bootstrapCss/bootstrap-theme.min.css'),
        ]).then(() => {
            // alert('Files loaded.');
        });
        if (USER_ID == undefined || USER_ID == null || USER_ID == "") {
            this.showStatus = false;
        } else {
            this.showStatus = true;
        }
        getStatusInfo()
            .then((result) => {
                console.log("getStatusInfo Result: ", JSON.stringify(result));
                for (let key in result) {
                    if (key == "Submitted") this.submittedStatus = result[key];
                    if (key == "Completed") this.completedStatus = result[key];
                    if (key == "Under Review")
                        this.underReviewStatus = result[key];
                    if (key == "Draft") this.createdStatus = result[key];
                    if (key == "Awarded") this.approvedStatus = result[key];
                    if (key == "Pending Approval")
                        this.pendingStatus = result[key];
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log("getStatusInfo Error: ", error);
                this.showSpinner = false;
            });
    }

    openTab(event) {
        let buttonValue = event.currentTarget.dataset.state;
        console.log("OpenTab clicked: ", buttonValue);
        this.var1 = "";
        this.var2 = "";
        this.var3 = "";
        this.var4 = "";
        this.var5 = "";
        this.var6 = "";
        this.draft = false;
        this.submitted = false;
        this.underReview = false;
        this.approved = false;
        this.pending = false;
        this.completed = false;
        this.pendingButtonClass = this.statusButtonClass;
        this.completedButtonClass = this.statusButtonClass;
        this.approvedButtonClass = this.statusButtonClass;
        this.underReviewButtonClass = this.statusButtonClass;
        this.submittedButtonClass = this.statusButtonClass;
        this.createdButtonClass = this.statusButtonClass;
        if (buttonValue == "Draft") {
            this.var1 = "active";
            this.draft = true;
            this.createdButtonClass = this.statusButtonClass + " active";
        } else if (buttonValue == "Submitted") {
            this.var2 = "active";
            this.submitted = true;
            this.submittedButtonClass = this.statusButtonClass + " active";
        } else if (buttonValue == "underReview") {
            this.var3 = "active";
            this.underReview = true;
            this.underReviewButtonClass = this.statusButtonClass + " active";
        } else if (buttonValue == "Approved") {
            this.var4 = "active";
            this.approved = true;
            this.approvedButtonClass = this.statusButtonClass + " active";
        } else if (buttonValue == "Completed") {
            this.var5 = "active";
            this.completed = true;
            this.completedButtonClass = this.statusButtonClass + " active";
        } else if (buttonValue == "Pending") {
            this.var6 = "active";
            this.pending = true;
            this.pendingButtonClass = this.statusButtonClass + " active";
        }
    }
}