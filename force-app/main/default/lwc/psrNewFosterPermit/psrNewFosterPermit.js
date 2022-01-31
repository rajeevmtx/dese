import {
    LightningElement,
    api,
    track
} from 'lwc';
// import commitPermitApplication from '@salesforce/apex/LP_RenewPermitController.commitPermitApplication';
// import fetchApplicationDetails from '@salesforce/apex/LP_RenewPermitController.fetchApplicationDetails';
// import fetchPermitFee from '@salesforce/apex/LP_RenewPermitController.fetchPermitFee';
// import insertPaymentRecord from '@salesforce/apex/LP_RenewPermitController.insertPaymentRecord';

import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";

export default class PsrNewFosterPermit extends NavigationMixin(LightningElement) {
    @track permit = {};
    @track permitFee;

    @track dataObj = {};
    @track inserData = {};

    @track appObj = {};
    @track appId;

    @track showInstructionPage = "display:none";
    @track showPersonalInfoPage = "display:none";
    @track showQuestionnairePage = "display:none";
    @track showFinancialInfoPage = "display:none";
    @track showReferencesPage = "display:none";
    @track showSubmitPage = "display:none";

    @track showSpinner = false;

    @api currentStep = 1;
    @api originalStep = 1;
    @api applicationInfoHelpText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

    @track errMsg = '';

    get getHeading() {
        return "New Foster Care Application";
    }

    navigateToInstruction(event) {
        this.currentStep = 1;
        this.hideComponents();
        this.showInstructionPage = "display: block";
    }

    navigateToPersonalInfo(event) {

        this.currentStep = 2;
        this.hideComponents();
        this.showPersonalInfoPage = "display: block";


        // var cmp = this.template.querySelector("c-lp_renew_permit_details");
        // console.log('cmp.isValid()>>>' + cmp.isValid());
        // if (cmp.isValid()) {
        //     let reason = cmp.getData();
        //     this.doCommitPermitApplication(reason, 1);
        // }
    }

    navigateToQuestionnaire(event) {
        var cmp = this.template.querySelector("c-psr-foster-personal-information");
        cmp.isValid((response) => {
            if (response.valid) {
                this.currentStep = 3;
                this.hideComponents();
                this.showQuestionnairePage = "display: block";
            }
        });
    }

    navigateToFinancialInfo(event) {
        var cmp = this.template.querySelector("c-psr-foster-questionnaire");
        cmp.isValid((response) => {
            if (response.valid) {
                this.currentStep = 4;
                this.hideComponents();
                this.showFinancialInfoPage = "display: block";
            }
        });
    }

    navigateToReferences(event) {
        var cmp = this.template.querySelector("c-psr-foster-adoption-history");
        cmp.isValid((response) => {
            if (response.valid) {
                this.currentStep = 5;
                this.hideComponents();
                this.showReferencesPage = "display: block";
            }
        });
    }

    navigateToSubmit(event) {
        this.currentStep = 6;
        this.hideComponents();
        this.showSubmitPage = "display: block";
    }

    hideComponents() {
        this.showInstructionPage = "display: none";
        this.showPersonalInfoPage = "display: none";
        this.showQuestionnairePage = "display: none";
        this.showFinancialInfoPage = "display: none";
        this.showReferencesPage = "display: none";
        this.showSubmitPage = "display: none";
    }

    doCommitPermitApplication(reason, step) {
        this.showSpinner = true;
        this.errMsg = '';
        // commitPermitApplication({
        //         permitId: this.permit.Id,
        //         renewalReason: reason
        //     })
        //     .then(response => {
        //         this.showSpinner = false;
        //         if (step == 1) {
        //             this.currentStep = 2;
        //             this.hideComponents();
        //             this.showPayment = "display: block";
        //         }
        //     })
        //     .catch(error => {
        //         this.showSpinner = false;
        //         this.errMsg = error.message || error.body.message;
        //         console.log('error>>' + JSON.stringify(error));
        //     }).finally(() => {
        //         this.showSpinner = false;
        //     });
    }

    connectedCallback() {
        this.showInstructionPage = "display: block";

        //If id exists in the URL that means this application is for edit
        // let params = this.getQueryParameters();
        // this.errMsg = '';
        // this.showSpinner = false;
        // if (params['appId']) {
        //     this.appId = params['appId'];
        //     //this.inserData.appId = this.appId;
        //     fetchApplicationDetails({
        //             applicationId: this.appId
        //         })
        //         .then(response => {
        //             this.permit = response.permit;
        //             this.contactId = response.permit.Contact__c;
        //             this.doNotAllowRenew = !response.allowRenewal;
        //             //this.inserData.contactId = response.permit.Contact__c;
        //             this.permitFee = response.renewalFee;

        //         })
        //         .catch(error => {
        //             this.errMsg = error.message || error.body.message;
        //         }).finally(() => {
        //             this.showSpinner = false;
        //         });
        // }
    }

    /**
     * @author Mahima Aggarwal
     * @email mahima.aggarwal@mtxb2b.com
     * @desc This method extract parameters from url
     */
    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }
        return params;
    }

    handleBack() {
        this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: "/"
                }
            },
            false
        );
        //window.open(`/psr`, "_self");
    }

    navigateToHome() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success!!",
                message: "Application Submitted Successfully!!",
                variant: "success"
            })
        );
        this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: "/"
                }
            },
            false
        );
    }
}