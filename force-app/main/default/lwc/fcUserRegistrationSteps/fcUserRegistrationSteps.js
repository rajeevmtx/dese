import { LightningElement, api, track } from 'lwc';

export default class FcUserRegistrationSteps extends LightningElement {
    @track onLoadStep;
    @track isNewEntity;
    @track activeCss = 'event active';
    @track completedCss = 'event completed';
    @track step1CSS;
    @track step2CSS;
    @track step3CSS;
    @track step4CSS;
    @api originalStep = 0;
    @api isLicensedUser = false;
    @api isProvider = false;

    connectedCallback() {
        this.onLoadStep = this.currentStep;
        // this.isNewEntity = sharedData.isNewEntity;
    }


    @api
    get currentStep() {
        return this.currentStep2;
    }
    set currentStep(value) {
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
        this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
    }

    @api
    handleCurrentStep(value) {
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
    }
    @api
    handlePaidValue(value) {
        this.isNewEntity = this.isNewEntity || value;
    }
}