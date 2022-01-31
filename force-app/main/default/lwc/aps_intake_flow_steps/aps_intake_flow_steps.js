import { LightningElement, api, track  } from 'lwc';

export default class Aps_intake_flow_steps extends LightningElement {
    //New Application Functionality
    @track onLoadStep;
    @track isNewEntity;
    @track activeCss = 'event active';
    @track completedCss = 'event completed';
    @track step0CSS;
    @track step1CSS;
    @track step2CSS;
    @track step3CSS;
    @track step4CSS;
    @track step5CSS;
    @track step6CSS;
    @track step7CSS;
    @track step8CSS;
    @track step9CSS;
    @track step10CSS;
    @api originalStep = 0;
    @api isLicensedUser = false;
    @api isProvider = false;

    connectedCallback() {
        this.onLoadStep = this.currentStep;
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
        this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        this.step5CSS = 'event ' + (_currentStep == 5 ? 'active ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '');
        this.step6CSS = 'event ' + (_currentStep == 6 ? 'active ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '');
    }

    @api
    handleCurrentStep(value) {
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
        this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
        this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        this.step5CSS = 'event ' + (_currentStep == 5 ? 'active ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '');
        this.step6CSS = 'event ' + (_currentStep == 6 ? 'active ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '');
    }

    @api
    handlePaidValue(value) {
        this.isNewEntity = this.isNewEntity || value;
    }
}