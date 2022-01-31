import { LightningElement, track, api } from 'lwc';

export default class FcApplicationSidebar extends LightningElement {

    activeSections = ['Applicant_Information'];

    @track activeCss = 'event active';
    @track completedCss = 'event completed';

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
    @track step11CSS;
    @track step12CSS;
    @track step13CSS;
    @track step14CSS;
    @track step15CSS;
    @track step16CSS;
    @track step17CSS;
    @track step18CSS;
    @track step19CSS;

    @track onLoadStep;
    @api originalStep = 0;
    @api isMultipleApplicant;

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
        console.log('current step here', _currentStep, this.originalStep);
        // handling the opening and closing of accordion sections here
        switch(_currentStep) {
            case 3: {
                this.activeSections = ['Applicant_Information'];
                break;
            }
            case 7: {
                this.activeSections = ['Applicant_Information'];
                break;
            }
            case 8: {
                this.activeSections = ['Household_Information'];
                break;
            }
            case 11: {
                this.activeSections = ['Household_Information'];
                break;
            }
            case 12: {
                this.activeSections = ['Foster/Adoption_Information'];
                break;
            }
            case 15: {
                this.activeSections = ['Foster/Adoption_Information'];
                break;
            }
            case 16: {
                this.activeSections = ['References'];
                break;
            }
            case 17: {
                this.activeSections = ['Background_Consent'];
                break;
            }
            case 18: {
                this.activeSections = ['Documents'];
                break;
            }
            case 19: {
                this.activeSections = ['Review_and_Submit'];
                break;
            }
        }
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
        this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
        this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        // if(!this.isMultipleApplicant) {
        //     if(_currentStep == 2){
        //         this.activeSections = ['Applicant_Information'];
        //     }
        // } else {
        //     if(_currentStep == 4){
        //         this.activeSections = ['Applicant_Information'];
        //     }
        // }

        this.step5CSS = 'event ' + (_currentStep == 5 ? 'active ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '');
        // if(_currentStep == 5){
        //     this.activeSections = ['Household_Information'];
        // }
        // this.step6CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        this.step6CSS = 'event ' + (_currentStep == 6 ? 'active ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '');
        // this.step7CSS = 'event ' + (_currentStep == 5 ? 'active ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '');
        this.step7CSS = 'event ' + (_currentStep == 7 ? 'active ' : '') + (_currentStep > 7 || this.originalStep >= 7 ? ' completed' : '');
        // this.step8CSS = 'event ' + (_currentStep == 6 ? 'active ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '');
        this.step8CSS = 'event ' + (_currentStep == 8 ? 'active ' : '') + (_currentStep > 8 || this.originalStep >= 8 ? ' completed' : '');
        // if(_currentStep == 8){
        //     this.activeSections = ['Household_Information'];
        // }
        this.step9CSS = 'event ' + (_currentStep == 9 ? 'active ' : '') + (_currentStep > 9 || this.originalStep >= 9 ? ' completed' : '');
        // if(_currentStep == 9){
        //     this.activeSections = ['Foster/Adoption_Information'];
        // }
        this.step10CSS = 'event ' + (_currentStep == 10 ? 'active ' : '') + (_currentStep > 10 || this.originalStep >= 10 ? ' completed' : '');
        this.step11CSS = 'event ' + (_currentStep == 11 ? 'active ' : '') + (_currentStep > 11 || this.originalStep >= 11 ? ' completed' : '');
        this.step12CSS = 'event ' + (_currentStep == 12 ? 'active ' : '') + (_currentStep > 12 || this.originalStep >= 12 ? ' completed' : '');
        this.step13CSS = 'event ' + (_currentStep == 13 ? 'active ' : '') + (_currentStep > 13 || this.originalStep >= 13 ? ' completed' : '');
        this.step14CSS = 'event ' + (_currentStep == 14 ? 'active ' : '') + (_currentStep > 14 || this.originalStep >= 14 ? ' completed' : '');
        this.step15CSS = 'event ' + (_currentStep == 15 ? 'active ' : '') + (_currentStep > 15 || this.originalStep >= 15 ? ' completed' : '');
        this.step16CSS = 'event ' + (_currentStep == 16 ? 'active ' : '') + (_currentStep > 16 || this.originalStep >= 16 ? ' completed' : '');
        this.step17CSS = 'event ' + (_currentStep == 17 ? 'active ' : '') + (_currentStep > 17 || this.originalStep >= 17 ? ' completed' : '');
        this.step18CSS = 'event ' + (_currentStep == 18 ? 'active ' : '') + (_currentStep > 18 || this.originalStep >= 18 ? ' completed' : '');
        this.step19CSS = 'event ' + (_currentStep == 19 ? 'active ' : '') + (_currentStep > 19 || this.originalStep >= 19 ? ' completed' : '');

        /*this.step10CSS = 'event ' + (_currentStep == 10 ? 'active ' : '') + (_currentStep > 10 || this.originalStep >= 10 ? ' completed' : '');
        this.step11CSS = 'event ' + (_currentStep == 11 ? 'active ' : '') + (_currentStep > 11 || this.originalStep >= 11 ? ' completed' : '');
        this.step12CSS = 'event ' + (_currentStep == 12 ? 'active ' : '') + (_currentStep > 12 || this.originalStep >= 12 ? ' completed' : '');
        this.step13CSS = 'event ' + (_currentStep == 13 ? 'active ' : '') + (_currentStep > 13 || this.originalStep >= 13 ? ' completed' : '');*/
    }

    @api
    handleCurrentStep(value) {
        console.log('steps2');
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
        this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
        this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        this.step5CSS = 'event ' + (_currentStep == 5 ? 'active ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '');
        this.step6CSS = 'event ' + (_currentStep == 6 ? 'active ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '');
        this.step7CSS = 'event ' + (_currentStep == 7 ? 'active ' : '') + (_currentStep > 7 || this.originalStep >= 7 ? ' completed' : '');
        this.step8CSS = 'event ' + (_currentStep == 8 ? 'active ' : '') + (_currentStep > 8 || this.originalStep >= 8 ? ' completed' : '');
        this.step9CSS = 'event ' + (_currentStep == 9 ? 'active ' : '') + (_currentStep > 9 || this.originalStep >= 9 ? ' completed' : '');
        this.step10CSS = 'event ' + (_currentStep == 10 ? 'active ' : '') + (_currentStep > 10 || this.originalStep >= 10 ? ' completed' : '');
        this.step11CSS = 'event ' + (_currentStep == 11 ? 'active ' : '') + (_currentStep > 11 || this.originalStep >= 11 ? ' completed' : '');
        this.step12CSS = 'event ' + (_currentStep == 12 ? 'active ' : '') + (_currentStep > 12 || this.originalStep >= 12 ? ' completed' : '');
        this.step13CSS = 'event ' + (_currentStep == 13 ? 'active ' : '') + (_currentStep > 13 || this.originalStep >= 13 ? ' completed' : '');
        this.step14CSS = 'event ' + (_currentStep == 14 ? 'active ' : '') + (_currentStep > 14 || this.originalStep >= 14 ? ' completed' : '');
        this.step15CSS = 'event ' + (_currentStep == 15 ? 'active ' : '') + (_currentStep > 15 || this.originalStep >= 15 ? ' completed' : '');
        this.step16CSS = 'event ' + (_currentStep == 16 ? 'active ' : '') + (_currentStep > 16 || this.originalStep >= 16 ? ' completed' : '');
        this.step17CSS = 'event ' + (_currentStep == 17 ? 'active ' : '') + (_currentStep > 17 || this.originalStep >= 17 ? ' completed' : '');
        this.step18CSS = 'event ' + (_currentStep == 18 ? 'active ' : '') + (_currentStep > 18 || this.originalStep >= 18 ? ' completed' : '');
        this.step19CSS = 'event ' + (_currentStep == 19 ? 'active ' : '') + (_currentStep > 19 || this.originalStep >= 19 ? ' completed' : '');


        /*this.step10CSS = 'event ' + (_currentStep == 10 ? 'active ' : '') + (_currentStep > 10 || this.originalStep >= 10 ? ' completed' : '');
        this.step11CSS = 'event ' + (_currentStep == 11 ? 'active ' : '') + (_currentStep > 11 || this.originalStep >= 11 ? ' completed' : '');
        this.step12CSS = 'event ' + (_currentStep == 12 ? 'active ' : '') + (_currentStep > 12 || this.originalStep >= 12 ? ' completed' : '');
        this.step13CSS = 'event ' + (_currentStep == 13 ? 'active ' : '') + (_currentStep > 13 || this.originalStep >= 13 ? ' completed' : '');*/
    }

    handleUserClicks(event) {
        let _currentStep = event.target.value;
        if (_currentStep <= this.originalStep) {
            fireEvent(this.pageRef, 'handleSideBarClick', _currentStep);
        }
    }

}