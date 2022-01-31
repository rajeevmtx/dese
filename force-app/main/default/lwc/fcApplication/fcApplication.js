import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveHomeInfo from '@salesforce/apex/fcNewLicenseController.saveHomeInfo';

import {
    registerListener,
    unregisterAllListeners,
    fireEvent
} from "c/fcbase";

export default class FcApplication extends NavigationMixin(LightningElement) {

    @track applicationId;
    @api currentStep = 1;
    @api originalStep = 1;
    @api isMultipleApplicant;
    @track showSpinner = false;
    @track showForm = true;
    @track homeContactInfo;

    @track showApplicantInfo = true;
    @track showApplicantInfoEmployment = false;
    @track showApplicantRelationship;
    @track showApplicantFinancial;
    @track showHouseholdInfoHomeContactInfo;
    @track showHouseholdInfoHomeInfo;
    @track showHouseholdInfoHomeMinorChildren;
    @track showHouseholdInfoHomeAdult;
    @track showFosterInfoAgency;
    @track showFosterInfoApplicantHistory;
    @track showFosterInfoChildDesired;
    @track showReferences;
    @track showBackgroundConsent;
    @track showDocuments;
    @track showReviewAndSubmit;

    sidebarMap = {
        'Applicant Info': { singleStep: 1,  multiStep: 4 },
        'Applicant Employment': { singleStep: 2,  multiStep: 6 },
        'Applicant Relationship': { singleStep: 5 },
        'Financial Information': { singleStep: 3,  multiStep: 7 },
        'Home Contact Info': { singleStep: 8 },
        'Home Information': { singleStep: 9 },
        'Minor Children': { singleStep: 10 },
        'Other Adults / Adult Children': { singleStep: 11 },
        'County / Agency Name': { singleStep: 12 },
        'Applicant Foster/Adoption History': { singleStep: 13,  multiStep: 14 },
        'Child / Nonminor Dependent Desired': { singleStep: 15 },
        'References': { singleStep: 16 },
        'Background Consent': { singleStep: 17 },
        'Documents': { singleStep: 18 },
        'Review and Submit': { singleStep: 19 },
    }

    hideComponents(){
        this.showApplicantInfo = false;
        this.showApplicantInfoEmployment = false;
        this.showApplicantRelationship = false;
        this.showApplicantFinancial = false;
        this.showHouseholdInfoHomeContactInfo = false;
        this.showHouseholdInfoHomeInfo = false;
        this.showHouseholdInfoHomeMinorChildren = false;
        this.showHouseholdInfoHomeAdult = false;
        this.showFosterInfoAgency = false;
        this.showFosterInfoApplicantHistory = false;
        this.showFosterInfoChildDesired = false;
        this.showReferences = false;
        this.showBackgroundConsent = false;
        this.showDocuments = false;
        this.showReviewAndSubmit = false;
    }

    get showBackButtonOnInfo() {
        return this.currentStep === 4 ? true : false;
    }

    connectedCallback() {
        registerListener("handleSideBarClick", this.handleSideBarClick, this);

        // this.showSpinner = true;
        let fullUrl = window.location.href;
        let newURL = new URL(fullUrl).searchParams;
        this.applicationId = newURL.get('appId');
        console.log('==applicationId==>', this.applicationId);
        this.isMultipleApplicant = true;
        console.log('multiple appplications here', this.isMultipleApplicant);
        //this.navigateToApplicantInformation();
        this.showSpinner = false;
    }

    navigateApplicantInfo() {
        let component = this.template.querySelector("c-fc-applicant-info");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                // _this.currentStep = _this.currentStep === 1 ? 2 : 4;
                // _this.hideComponents();
                // if(_this.currentStep === 2) {
                //     _this.showApplicantInfoEmployment = true;
                // }
                // else if(_this.currentStep === 4) {
                //     _this.showApplicantRelationship = true;
                // }
                const { singleStep, multiStep } = _this.sidebarMap['Applicant Info'];
                _this.hideComponents();
                if(_this.currentStep === singleStep) {
                    _this.currentStep = _this.sidebarMap['Applicant Employment'].singleStep;
                    _this.showApplicantInfoEmployment = true;
                }
                else if(_this.currentStep === multiStep) {
                    _this.currentStep = _this.sidebarMap['Applicant Relationship'].singleStep;
                    _this.showApplicantRelationship = true;
                }
                _this.moveToTop();
            }
        });
    }

    previousApplicantInfo() {
        // this.currentStep = 2;
        // this.hideComponents();
        // this.showApplicantInfoEmployment = true;
        const { singleStep, multiStep } = this.sidebarMap['Applicant Info'];
        if(this.currentStep === multiStep) {
            this.currentStep = this.sidebarMap['Financial Information'].singleStep;
        }
        this.hideComponents();
        this.showApplicantFinancial = true;
        this.moveToTop();
    }

    previousApplicantEmployment() {
        // this.currentStep = this.currentStep === 5 ? 4 : 1;
        // this.hideComponents();
        // if(this.currentStep === 4) {
        //     this.showApplicantRelationship = true;
        // }
        // else if(this.currentStep === 1) {
        //     this.showApplicantInfo = true;
        // }
        const { singleStep, multiStep } = this.sidebarMap['Applicant Employment'];
        this.hideComponents();
        if(this.currentStep === singleStep) {
            this.currentStep = this.sidebarMap['Applicant Info'].singleStep;
            this.showApplicantInfo = true;
        }
        else if(this.currentStep === multiStep) {
            this.currentStep = this.sidebarMap['Applicant Relationship'].singleStep;
            this.showApplicantRelationship = true;
        }
        this.moveToTop();
    }

    navigateApplicantEmployment() {
        let component = this.template.querySelector("c-fc-applicant-info-employment");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                // _this.currentStep = _this.currentStep === 5 ? 6 : _this.isMultipleApplicant ? 3 : 6;
                // _this.hideComponents();
                // if(_this.currentStep === 3) {
                //     _this.showApplicantInfo = true;
                // }
                // else if(_this.currentStep === 6) {
                //     _this.showHouseholdInfoHomeContactInfo = true;
                // }
                const { singleStep, multiStep } = _this.sidebarMap['Applicant Employment'];
                _this.hideComponents();
                if(_this.currentStep === singleStep) {
                    _this.currentStep = _this.sidebarMap['Financial Information'].singleStep;
                }
                else if(_this.currentStep === multiStep) {
                    _this.currentStep = _this.sidebarMap['Financial Information'].multiStep;
                }
                _this.hideComponents();
                _this.showApplicantFinancial = true;
                _this.moveToTop();
            }
        });
    }

    
    navigateApplicantBInfo() {
        let component = this.template.querySelector("c-fc-applicant-info");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                _this.currentStep = 4;
                _this.hideComponents();
                _this.showApplicantInfoEmployment = true;
                _this.moveToTop();
            }
        });
    }

    previousApplicantBEmployment() {
        this.currentStep = 3;
        this.hideComponents();
        this.showApplicantInfo = true;
        this.moveToTop();
    }

    navigateApplicantBEmployment() {
        let component = this.template.querySelector("c-fc-applicant-info-employment");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                _this.currentStep = 6;
                _this.hideComponents();
                _this.showHouseholdInfoHomeContactInfo = true;
                _this.moveToTop();
            }
        });
    }

    navigateApplicantFinancial() {
        // component code here
        const { singleStep, multiStep } = this.sidebarMap['Financial Information'];
        console.log('steps here', singleStep, multiStep);
        console.log('current step here', this.currentStep);
        this.hideComponents(); 
        if(this.currentStep === singleStep) {
            this.currentStep = this.sidebarMap['Applicant Info'].multiStep;
            this.showApplicantInfo = true;
        }
        else if(this.currentStep === multiStep) {
            this.currentStep = this.sidebarMap['Home Contact Info'].singleStep;
            this.showHouseholdInfoHomeContactInfo = true;
        }
        this.moveToTop();
    }

    previousApplicantFinancial() {
        const { singleStep, multiStep } = this.sidebarMap['Financial Information'];
        if(this.currentStep === singleStep) {
            this.currentStep = this.sidebarMap['Applicant Employment'].singleStep;
        }
        else if(this.currentStep === multiStep) {
            this.currentStep = this.sidebarMap['Applicant Employment'].multiStep;
        }
        this.hideComponents();
        this.showApplicantInfoEmployment = true;
        this.moveToTop();
    }

    navigateApplicantRelationship() {
        // component code here
        let component = this.template.querySelector("c-fc-applicant-relationship");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                _this.currentStep = _this.sidebarMap['Applicant Employment'].multiStep;
                _this.hideComponents();
                _this.showApplicantInfoEmployment = true;
                _this.moveToTop();
            }
        });
    }

    previousApplicantRelationship() {
        this.currentStep = this.sidebarMap['Applicant Info'].multiStep;
        this.hideComponents();
        this.showApplicantInfo = true;
        this.moveToTop();
    }

    previousHouseholdInfoHomeContactInfo(){
        // this.currentStep = this.isMultipleApplicant ? 5 : 2;
        this.currentStep = this.isMultipleApplicant ? this.sidebarMap['Financial Information'].multiStep : this.sidebarMap['Financial Information'].singleStep;
        this.hideComponents();
        this.showApplicantFinancial = true;
        this.moveToTop();
    }

    
    navigateHouseholdInfoHomeContactInfo(){
        //let component = this.template.querySelector("c-fc-household-info-home-contact-info");
        //var _this = this;

    
        console.log('Till');
        this.homeContactInfo = this.template.querySelector("c-fc-household-info-home-contact-info").getData();
        console.log('homeContactJson',this.homeContactInfo);
        saveHomeInfo({ applicationId : this.applicationId ,homeContactJson : JSON.stringify(this.homeContactInfo)}).then(
            result => {
                console.log('result','Saved');
            }
            ).catch(
            error => {
                console.log('result','error');
                //this.showToastMessage("Error!", error, "error");
            }
        );
        this.currentStep = this.sidebarMap['Home Information'].singleStep;
        this.hideComponents();
        this.showHouseholdInfoHomeInfo = true;
        this.moveToTop();
        
        /*
        component.isValid(function (response) {
            if (response.valid) {
                // _this.currentStep = 7;
                console.log('Till');
                this.homeContactInfo = this.template.querySelector("c-fc-household-info-home-contact-info").getData();
                console.log('homeContactJson',this.homeContactInfo);
                saveHomeInfo({ applicationId : this.applicationId ,homeContactJson : JSON.stringify(this.homeContactInfo)}).then(
                    result => {
                      console.log('result','Saved');
                    }
                  ).catch(
                    error => {
                      this.showToastMessage("Error!", error, "error");
                    }
                );
                _this.currentStep = _this.sidebarMap['Home Information'].singleStep;
                _this.hideComponents();
                _this.showHouseholdInfoHomeInfo = true;
                _this.moveToTop();
            }
        });*/
    }

    previousHouseholdInfoHomeInfo(){
        // this.currentStep = 6;
        this.currentStep = this.sidebarMap['Home Contact Info'].singleStep;
        this.hideComponents();
        this.showHouseholdInfoHomeContactInfo = true;
        this.moveToTop();
    }

    navigateHouseholdInfoHomeInfo(){
        let component = this.template.querySelector("c-fc-household-info-home-info");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                // _this.currentStep = 8;
                _this.currentStep = _this.sidebarMap['Minor Children'].singleStep;
                _this.hideComponents();
                _this.showHouseholdInfoHomeMinorChildren = true;
                _this.moveToTop();
            }
        });
    }

    previousHouseholdInfoHomeMinorChildren(){
        // this.currentStep = 7;
        this.currentStep = this.sidebarMap['Home Information'].singleStep;
        this.hideComponents();
        this.showHouseholdInfoHomeInfo = true;
        this.moveToTop();
    }

    navigateHouseholdInfoHomeMinorChildren(){
        let component = this.template.querySelector("c-fc-household-info-home-minor-children");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                // _this.currentStep = 9;
                _this.currentStep = _this.sidebarMap['Other Adults / Adult Children'].singleStep;
                _this.hideComponents();
                _this.showHouseholdInfoHomeAdult = true;
                _this.moveToTop();
            }
        });
    }

    previousHouseholdInfoHomeAdult(){
        // this.currentStep = 8;
        this.currentStep = this.sidebarMap['Minor Children'].singleStep;
        this.hideComponents();
        this.showHouseholdInfoHomeMinorChildren = true;
        this.moveToTop();
    }

    navigateHouseholdInfoHomeAdult(){
        let component = this.template.querySelector("c-fc-household-info-home-adult");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                // _this.currentStep = 10;
                _this.currentStep = _this.sidebarMap['County / Agency Name'].singleStep;
                _this.hideComponents();
                _this.showFosterInfoAgency = true;
                _this.moveToTop();
            }
        });
    }

    previousFosterInfoAgency(){
        // this.currentStep = 9;
        this.currentStep = this.sidebarMap['Other Adults / Adult Children'].singleStep;
        this.hideComponents();
        this.showHouseholdInfoHomeAdult = true;
        this.moveToTop();
    }

    navigateFosterInfoAgency(){
        let component = this.template.querySelector("c-fc-foster-info-agency");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                // _this.currentStep = 11;
                const { singleStep, multiStep } = _this.sidebarMap['Applicant Foster/Adoption History'];
                console.log('step value here', singleStep);
                _this.currentStep = singleStep;
                _this.hideComponents();
                _this.showFosterInfoApplicantHistory = true;
                _this.moveToTop();
            }
        });
    }

    previousFosterInfoApplicantHistory(){
        // this.currentStep = this.currentStep === 12 ? 11 : 10;
        // this.hideComponents();
        // if(this.currentStep === 11) {
        //     this.showFosterInfoApplicantHistory = true;
        // }
        // else if(this.currentStep === 10) {
        //     this.showFosterInfoAgency = true;
        // }
        const { singleStep, multiStep } = this.sidebarMap['Applicant Foster/Adoption History'];
        // this.currentStep = this.currentStep === 12 ? 11 : 10;
        this.hideComponents();
        if(this.currentStep === singleStep) {
            this.currentStep = this.sidebarMap['County / Agency Name'].singleStep;
            this.showFosterInfoAgency = true;
        }
        else if(this.currentStep === multiStep) {
            this.currentStep = this.sidebarMap['Applicant Foster/Adoption History'].singleStep;
            this.showFosterInfoApplicantHistory = true;
        }
        this.moveToTop();
    }

    navigateFosterInfoApplicantHistory(){
        let component = this.template.querySelector("c-fc-foster-info-applicant-history");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {

                // _this.currentStep = _this.currentStep === 12 ? 13 : _this.isMultipleApplicant ? 12 : 13;
                // _this.hideComponents();
                // if(_this.currentStep === 12){
                //     _this.showFosterInfoApplicantHistory = true;
                // }
                // else if(_this.currentStep === 13){ 
                //     _this.showFosterInfoChildDesired = true;
                // }
                const { singleStep, multiStep } = _this.sidebarMap['Applicant Foster/Adoption History'];
                console.log('step value here', singleStep, multiStep);
                // _this.currentStep = _this.isMultipleApplicant ? multiStep : _this.sidebarMap['Child / Nonminor Dependent Desired'].singleStep;
                _this.hideComponents();
                if(_this.currentStep === singleStep){
                    _this.currentStep = multiStep;
                    _this.showFosterInfoApplicantHistory = true;
                }
                else if(_this.currentStep === multiStep){ 
                    _this.currentStep = _this.sidebarMap['Child / Nonminor Dependent Desired'].singleStep;
                    _this.showFosterInfoChildDesired = true;
                }
                _this.moveToTop();
            }
        });
    }

    previousFosterBInfoApplicantHistory(){
        this.currentStep = 10;
        this.hideComponents();
        this.showFosterInfoApplicantHistory = true;
        this.moveToTop();
    }

    navigateFosterInfoBApplicantHistory(){
        let component = this.template.querySelector("c-fc-foster-info-applicant-history");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                _this.currentStep = 11;
                _this.hideComponents();
                _this.showFosterInfoChildDesired = true;
                _this.moveToTop();
            }
        });
    }

    previousFosterInfoChildDesired(){
        // if(this.isMultipleApplicant){
        //     this.currentStep = 12;
        //     this.hideComponents();
        //     this.showFosterInfoApplicantHistory = true;
        // }else{
        //     this.currentStep = 11;
        //     this.hideComponents();
        //     this.showFosterInfoApplicantHistory = true;
        // }
        const { singleStep, multiStep } = this.sidebarMap['Applicant Foster/Adoption History'];
        this.currentStep = this.isMultipleApplicant ? multiStep : singleStep;
        this.hideComponents();
        this.showFosterInfoApplicantHistory = true;
        this.moveToTop();
    }

    navigateFosterInfoChildDesired(){
        let component = this.template.querySelector("c-fc-foster-info-child-desired");
        var _this = this;
        component.isValid(function (response) {
            if (response.valid) {
                // console.log('==SUBMITTED==');
                _this.currentStep = _this.sidebarMap['References'].singleStep;
                _this.hideComponents();
                _this.showReferences = true;
                _this.moveToTop();
            }
        });
    }

    previousReferences() {
        this.currentStep = this.sidebarMap['Child / Nonminor Dependent Desired'].singleStep;
        this.hideComponents();
        this.showFosterInfoChildDesired = true;
        this.moveToTop();
    }

    navigateReferences() {
        // component code here
        this.currentStep = this.sidebarMap['Background Consent'].singleStep;
        this.hideComponents();
        this.showBackgroundConsent = true;
        this.moveToTop();
    }

    previousBackgroundConsent() {
        this.currentStep = this.sidebarMap['References'].singleStep;
        this.hideComponents();
        this.showReferences = true;
        this.moveToTop();
    }

    navigateBackgroundConsent() {
        // component code here
        this.currentStep = this.sidebarMap['Documents'].singleStep;
        this.hideComponents();
        this.showDocuments = true;
        this.moveToTop();
    }


    previousDocuments() {
        this.currentStep = this.sidebarMap['Background Consent'].singleStep;
        this.hideComponents();
        this.showBackgroundConsent = true;
        this.moveToTop();
    }

    navigateDocuments() {
        // component code here
        this.currentStep = this.sidebarMap['Review and Submit'].singleStep;
        this.hideComponents();
        this.showReviewAndSubmit = true;
        this.moveToTop();
    }

    previousReviewAndSubmit() {
        this.currentStep = this.sidebarMap['Documents'].singleStep;
        this.hideComponents();
        this.showDocuments = true;
        this.moveToTop();
    }

    navigateReviewAndSubmit() {
        console.log('submitted');
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: "Application Submitted!",
                variant: "success"
            })
        );
        setTimeout(() => {
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: 'fchome'
                }
            })
        }, 500);
    }

    moveToTop() {
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

}