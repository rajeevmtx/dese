/* eslint-disable no-console */
import {
        LightningElement,
        track,
        api,
        wire
} from 'lwc';

export default class NysdohStepsComponent extends LightningElement {
        @track onLoadStep;
        @track isNewEntity;
        @track activeCss = 'event active';
        @track completedCss = 'event completed';
        @track step1CSS = 'event';
        @track step2CSS = 'event';
        @track step3CSS = 'event';
        @track step4CSS = 'event';
        @api originalStep = 0;
        @api isLicensedUser = false;
        @api isProvider = false;
        @api isCommunity;
        @api isShowSchedulingOption;
        @api isPointsCalculated;

        connectedCallback() {
                this.onLoadStep = this.currentStep;
                // this.isNewEntity = sharedData.isNewEntity;
                console.log("currentstep-", this.currentStep);
        }
        @api
        get currentStep() {
                console.log('inside current step--');
                return this.currentStep2;
        }
        set currentStep(value) {
                this.currentStep2 = value;
                var _currentStep = parseInt(value);
                this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
                this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
                this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
                this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        }
        @api
        handleCurrentStep(value) {
                this.currentStep2 = value;
                var _currentStep = parseInt(value);
                this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
                this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
                this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
                this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        }
        @api
        handlePaidValue(value) {
                this.isNewEntity = this.isNewEntity || value;
        }

        handleUserClicks(event) {
                let _currentStep = event.target.value;
                const dateRangeChangeEvent = new CustomEvent('stepclick', {
                        detail: {
                                currentStep: _currentStep
                        }
                });
                this.dispatchEvent(dateRangeChangeEvent);
        }
}