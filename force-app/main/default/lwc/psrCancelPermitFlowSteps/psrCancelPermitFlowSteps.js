import { LightningElement, api, track  } from 'lwc';
import { fireEvent,sharedData } from "c/pubsub"; 


export default class PsrCancelPermitFlowSteps extends LightningElement {

    //New Application Functionality
    @track onLoadStep;
    @track isNewEntity;
    @track activeCss = 'event active';
    @track completedCss = 'event completed';
    @track step0CSS;
    @track step1CSS;
    @api originalStep = 0;
    @api isLicensedUser = false;

    connectedCallback() {
        this.onLoadStep = this.currentStep;
        this.isNewEntity=sharedData.isNewEntity;
    }

    
    @api
    get currentStep() {
        return this.currentStep2;
    }
    set currentStep(value) {
        console.log('steps2');
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step0CSS = 'event ' + (_currentStep == 0 ? 'active ' : '') +  (_currentStep == 1 ? 'completed' : '');
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') +  (_currentStep == 2 ? 'completed' : '');
    }

    @api
    handleCurrentStep(value) {
        console.log('steps2');
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step0CSS = 'event ' + (_currentStep == 0 ? 'active ' : '') +  (_currentStep == 1 ? 'completed' : '');
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') +  (_currentStep == 2 ? 'completed' : '');
    }

    @api
    handlePaidValue(value) {
        this.isNewEntity =this.isNewEntity  || value ;
    }

    handleUserClicks(event) {
        let _currentStep = event.target.value;
        if (_currentStep <= this.originalStep) {
            fireEvent(this.pageRef, 'handleSideBarClick', _currentStep);
        }
    }
}