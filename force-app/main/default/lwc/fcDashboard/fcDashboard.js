import { LightningElement, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import font_awesome_css from "@salesforce/resourceUrl/font_awesome_css";
import EntitiesLogo from "@salesforce/resourceUrl/MtxLogo";
import { NavigationMixin } from "lightning/navigation";
import getStatusInfo from "@salesforce/apex/PsrStatusInfo.getStatusInfo";
import { createRecord } from "lightning/uiRecordApi";
import { registerListener, unregisterAllListeners, fireEvent } from "c/pubsub";
import USER_ID from "@salesforce/user/Id";
import { utility } from "c/pubsub";
import Portal_Dashboard_Header_Help_Text from '@salesforce/label/c.Portal_Dashboard_Header_Help_Text';
import Portal_Dashboard_Application_Component_Header_Help_Text from '@salesforce/label/c.Portal_Dashboard_Application_Component_Header_Help_Text';


export default class FcDashboard extends LightningElement {
    @track var8 = "active";
    @track mapData= [];
    @track var2;
    @track var3;
    @track var4;
    @track var5;
    @track var81 = true;
    @track submitted = false;
    @track inProgress = false;
    @track complete = false;
    @track deficient = false;
    @track createdstatus = 0;
    @track submittedstatus = 0;
    @track inProgressstatus = 0;
    @track completestatus = 0;
    @track deficiencystatus = 0;
    @track showSpinner = false;
    @track userLoggedIn = false;
    @track userLoggedOut = false;
    @track successModal = false;
    @track statusButtonClass =
        "tab-button slds-col slds-size_1-of-1 slds-medium-size_2-of-12 slds-large-size_2-of-12";
    @track createdButtonClass = this.statusButtonClass + " active";
    @track submittedButtonClass = this.statusButtonClass;
    @track inProgressButtonClass = this.statusButtonClass;
    @track processedButtonClass = this.statusButtonClass;
    @track deficientButtonClass = this.statusButtonClass;
    @track showStatus;
    @track Portal_Dashboard_Header_Help_Text = Portal_Dashboard_Header_Help_Text;
    @track Portal_Dashboard_Application_Component_Header_Help_Text = Portal_Dashboard_Application_Component_Header_Help_Text;

    modalValues = {
        registerEntity: {
            title: "Initial Registration ",
            entityCondition: "EntityStatus__c =  'Pending Initial Registration'",
            nextPage: "entityregistration",
            errorMessage: "Your entity has already submitted their initial registration. If you feel this is incorrect please reach out via the question button or if you are looking to renew your entities registration please select the Renew Reistration button. Thank you!"
        },
        renewRegistration: {
            title: "Renewal",
            entityCondition: "Open_for_Renewal__c =true and  EntityStatus__c =  'Pending Renewal'",
            nextPage: "renew-registration",
            errorMessage: "You cannot submit an entity renewal until 90 days before your registration anniversary date. Please check back later to submit your renewal!"
        },
        updateContact: {
            title: "Update Primary Contact",
            entityCondition: "EntityStatus__c =  'Compliant'",
            nextPage: "update-primary-contact",
            errorMessage: "Your entity has already submitted their initial registration. If you feel this is incorrect please reach out via the question button or if you are looking to renew your entities registration please select the Renew Reistration button. Thank you!"
        },
        updateEntityName: {
            title: "Entity Name Change",
            entityCondition: "EntityStatus__c =  'Compliant'",
            nextPage: "update-entity-name",
            errorMessage: "Your entity has already submitted their initial registration. If you feel this is incorrect please reach out via the question button or if you are looking to renew your entities registration please select the Renew Reistration button. Thank you!"
        },
        boundaryActions: {
            title: "Boundary Actions",
            entityCondition: "EntityStatus__c =  'Compliant'",
            nextPage: "boundary-actions",
            errorMessage: "Your entity has already submitted their initial registration. If you feel this is incorrect please reach out via the question button or if you are looking to renew your entities registration please select the Renew Reistration button. Thank you!"
        }
    };
    buttonValue;
    logo = EntitiesLogo;

    openSelectionModal(event) {
        // navigateToPage: (pageName, urlParams = "") => {
        //     window.open(`/s/${pageName}?${urlParams}`, "_self");
        // }
        window.open(`/psr/s/psrlicenseselection`, "_self");
    }

    openRegisterEntityModel(event) {
        var modal = event.target.dataset.modal;
        console.log(event);
        console.log(JSON.stringify(event.target.dataset));
        console.log(this.modalValues[modal]);
        if (
            (USER_ID == undefined || USER_ID == null || USER_ID == "") &&
            (modal == "registerEntity" ||
                modal == "renewRegistration" ||
                modal == "updateContact" ||
                modal == "updateEntityName")
        ) {
            utility.navigateToPage("login");
        } else {
            this.template
                .querySelector("c-utha-register-entity-model")
                .setValues(this.modalValues[modal]);
            this.template.querySelector("c-utha-register-entity-model").openmodal();
        }
    }

    redirectToBoundaryAction(event) {
        var modal = event.target.dataset.modal;

        if (USER_ID == undefined || USER_ID == null || USER_ID == "") {
            utility.navigateToPage("boundary-action-guest");
        } else {
            this.template
                .querySelector("c-utha-register-entity-model")
                .setValues(this.modalValues[modal]);
            this.template.querySelector("c-utha-register-entity-model").openmodal();
        }
    }
    navigateNext() {
        var tempEvent = {
            target: {
                dataset: {
                    navigatepage: "er_registry"
                }
            }
        };
        this.navigateToPage(tempEvent);
    }

    navigateToFindEntity() {
        console.log("here");
        var tempEvent = {
            target: {
                dataset: {
                    navigatepage: "search-entity"
                }
            }
        };
        this.navigateToPage(tempEvent);
    }

    navigateToReportNewEntity() {
        var tempEvent = {
            target: {
                dataset: {
                    navigatepage: "report-non-registered"
                }
            }
        };
        this.navigateToPage(tempEvent);
    }
    navigateToPage(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: event.target.dataset.navigatepage
            }
        });
    }
    navigateToPageExternal(event) {
        if (USER_ID == undefined || USER_ID == null || USER_ID == "") {
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: event.target.dataset.navigatepage
                }
            });
        }
    }

    getStatus() {
    console.log("/////////////");
    this.showSpinner = true;
    getStatusInfo()
        .then(result => {
            var conts = result;
            console.log("============" + result);
            if (result) {
                console.log("============12334444");
                for (let key in conts) {
                    //this.mapData.push({value:conts[key], key:key}); //Here we are creating the array to show on UI.
                    //this.key1 = key;
                    //this.value1 = conts[key];
                    if (key == "Draft") {
                        this.createdstatus = conts[key];
                    } else if (key == "Submitted") {
                        this.submittedstatus = conts[key];
                    } else if (key == "Under Review") {
                        this.inProgressstatus = conts[key];
                    } else if (key == "Closed") {
                        this.completestatus = conts[key];
                    } else if (key == "Approved") {
                        this.deficiencystatus = conts[key];

                        console.log("ssssss" + this.deficiency);
                    }
                }
            }
            this.showSpinner = false;
        })
        .catch(error => {
            console.log("**************");
            this.error = error;
            this.accounts = undefined;
            this.showSpinner = false;
        });
    }

    connectedCallback() {
        // load element
        this.getStatus();
        Promise.all([
            // loadScript(this, bootstrap_js +'/bootstrapjs/bootstrap.js'),
            loadStyle(this, font_awesome_css + "/font_awesome_css/fontawesome.css"),
            loadStyle(
                this,
                font_awesome_css + "/font_awesome_css/fontawesome.min.css"
            )
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
        //this.getStatus();
        console.log("///UserId:" + USER_ID);
        registerListener("showSpinner", this.showSpinner, this);
        registerListener("hideSpinner", this.hideSpinner, this);
        registerListener("showSuccessModal", this.showSuccessModal, this);
        registerListener("hodeSuccessModal", this.hideSuccessModal, this);
    }

    openTab(event) {
        this.getStatus();
        this.buttonValue = event.currentTarget.dataset.state;
        //console.log(this.buttonValue);
        if (this.buttonValue === "draft") {
            this.var8 = "active";
            this.var2 = "";
            this.var3 = "";
            this.var4 = "";
            this.var81 = true;
            this.submitted = false;
            this.inProgress = false;
            this.complete = false;
            this.deficient = false;
            this.createdButtonClass = this.statusButtonClass + " active";
            this.submittedButtonClass = this.statusButtonClass;
            this.inProgressButtonClass = this.statusButtonClass;
            this.processedButtonClass = this.statusButtonClass;
            this.deficientButtonClass = this.statusButtonClass;
        } else if (this.buttonValue === "Submitted") {
            this.var2 = "active";
            this.var8 = "";
            this.var3 = "";
            this.var4 = "";
            this.submitted = true;
            this.var81 = false;
            this.inProgress = false;
            this.complete = false;
            this.deficient = false;
            this.createdButtonClass = this.statusButtonClass;
            this.submittedButtonClass = this.statusButtonClass + " active";
            this.inProgressButtonClass = this.statusButtonClass;
            this.processedButtonClass = this.statusButtonClass;
            this.deficientButtonClass = this.statusButtonClass;
        } else if (this.buttonValue === "underReview") {
            this.var3 = "active";
            this.var2 = "";
            this.var8 = "";
            this.var4 = "";
            this.inProgress = true;
            this.submitted = false;
            this.var81 = false;
            this.complete = false;
            this.deficient = false;
            this.createdButtonClass = this.statusButtonClass;
            this.submittedButtonClass = this.statusButtonClass;
            this.inProgressButtonClass = this.statusButtonClass + " active";
            this.processedButtonClass = this.statusButtonClass;
            this.deficientButtonClass = this.statusButtonClass;
        } else if (this.buttonValue === "Closed") {
            this.var4 = "active";
            this.var2 = "";
            this.var3 = "";
            this.var8 = "";
            this.complete = true;
            this.submitted = false;
            this.inProgress = false;
            this.var81 = false;
            this.deficient = false;
            this.createdButtonClass = this.statusButtonClass;
            this.submittedButtonClass = this.statusButtonClass;
            this.inProgressButtonClass = this.statusButtonClass;
            this.processedButtonClass = this.statusButtonClass + " active";
            this.deficientButtonClass = this.statusButtonClass;
        } else if (this.buttonValue === "Approved") {
            this.var5 = "active";
            this.var4 = "";
            this.var2 = "";
            this.var3 = "";
            this.var8 = "";
            this.complete = false;
            this.submitted = false;
            this.inProgress = false;
            this.var81 = false;
            this.deficient = true;
            this.createdButtonClass = this.statusButtonClass;
            this.submittedButtonClass = this.statusButtonClass;
            this.inProgressButtonClass = this.statusButtonClass;
            this.processedButtonClass = this.statusButtonClass;
            this.deficientButtonClass = this.statusButtonClass + " active";
        }
    }
    showSpinner() {
        console.log("//////showProgress");
        this.showSpinner = true;
        console.log("//////////////////" + this.showSpinner);
    }

    hideSpinner() {
        console.log("//////hideProgress");
        this.showSpinner = false;
        console.log("//////////////////" + this.showSpinner);
    }
    handleQuestionRequestAccess() {
        if (USER_ID == undefined || USER_ID == null || USER_ID == "") {
            this.userLoggedIn = false;
            this.userLoggedOut = true;
        } else {
            this.userLoggedIn = true;
            this.userLoggedOut = false;
        }
        console.log("ccc" + this.userLoggedIn);
        console.log("ccc" + this.userLoggedOut);
    }
    closeModal() {
            this.userLoggedIn = false;
            this.userLoggedOut = false;
            console.log("ccc" + this.userLoggedIn);
            console.log("ccc" + this.userLoggedOut);
        }
        // hideSuccessModal(){
        //     this.successModal = false;
        //     console.log('hidingSuccessModal');
        // }
    showSuccessModal() {
        this.successModal = true;
        console.log("showingSuccessModal");
    }
    closeSuccessModal() {
        this.successModal = false;
        console.log("closeSuccessModal");
    }
    gotoLogInScreen() {
        utility.navigateToPage("login");
    }
    handleSearchEntity() {
        console.log("hre");
        utility.navigateToPage("search-entity");
    }
}