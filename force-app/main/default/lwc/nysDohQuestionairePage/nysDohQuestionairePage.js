/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';

import ID_FIELD from '@salesforce/schema/Contact.Id';
import SYMPTOMPS_FIELD from '@salesforce/schema/Contact.Symptoms__c';
import HEALTHCARE_FIELD from '@salesforce/schema/Contact.Healthcare_or_Emergency_Responder__c';
import CLOSECONTACT_FIELD from '@salesforce/schema/Contact.COVID_Close_Contact__c';
import NURSINGHOME_FIELD from '@salesforce/schema/Contact.Nursing_Home_or_Healthcare__c';
import EXPOSEDTO_FIELD from '@salesforce/schema/Contact.Exposed_to_COVID__c';
import WHOEXPOSED_FIELD from '@salesforce/schema/Contact.Who_Exposed__c';
import X14DAYS_FIELD from '@salesforce/schema/Contact.X14_Day_Return_from_Level_3__c';
import OVER60_FIELD from '@salesforce/schema/Contact.Over_60_years_old__c';
import CHRONIC_FIELD from '@salesforce/schema/Contact.Chronic_Illness__c';
import POINTS_FIELD from '@salesforce/schema/Contact.Points__c';
import WHICH_ILLNESS from '@salesforce/schema/Contact.which_illness__c';
import ILLNESS_OTHER from '@salesforce/schema/Contact.which_symptoms__c';
import SYMPTOMS_OTHER from '@salesforce/schema/Contact.which_symptoms_other__c';
import RESPITORY_VITAL from '@salesforce/schema/Contact.Was_a_Respiratory_Viral_Panel_performed__c';

import { CurrentPageReference } from "lightning/navigation";


export default class 
 extends LightningElement {
    ID_FIELD = ID_FIELD;
    SYMPTOMPS_FIELD = SYMPTOMPS_FIELD;
    HEALTHCARE_FIELD = HEALTHCARE_FIELD;
    CLOSECONTACT_FIELD = CLOSECONTACT_FIELD;
    NURSINGHOME_FIELD = NURSINGHOME_FIELD;
    EXPOSEDTO_FIELD = EXPOSEDTO_FIELD;
    WHOEXPOSED_FIELD = WHOEXPOSED_FIELD;
    X14DAYS_FIELD = X14DAYS_FIELD;
    OVER60_FIELD = OVER60_FIELD;
    CHRONIC_FIELD = CHRONIC_FIELD;
    POINTS_FIELD = POINTS_FIELD;
    WHICH_ILLNESS =WHICH_ILLNESS;
    ILLNESS_OTHER = ILLNESS_OTHER;
    SYMPTOMS_OTHER = SYMPTOMS_OTHER;
    RESPITORY_VITAL = RESPITORY_VITAL;

    @wire(CurrentPageReference) pageRef;

    @api recordId;
    @api instructionsHelpText = "Please complete the below to help NYS Department of Health understand your current condition and background with COVID-19."; 
    @track responseWrapper = {
        points: 0,
        question1: '',
        question2: '',
        question3: '',
        question4: '',
        question5: '',
        question6: '',
        question7: '',
        question8: '',
        question9: '',
        question10b: '',
        question0: '',
        question2b: '',
        question2c: '',
    };
    @track _selected = [];
    @track _chronicDisease = [];
    @track otherfield = false;
    @track allDone = false;

    byWhom = [
        { label: 'Family Member', value: 'Family Member' },
        { label: 'Close Contact', value: 'Close Contact' },
        { label: `Friend's Friend`, value: `Friend's Friend` },
        { label: `Coworker or Friend`, value: `Coworker or Friend` }
    ];
    viralPanel = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
        { label: 'Pending', value: 'Pending' }
    ];

    get chronicillness(){
        return [
        { label: 'Cardiovascular diseases', value: 'Cardiovascular diseases' },
        { label: 'Diabetes', value: 'Diabetes' },
        { label: 'Chronic obstructive pulmonary disease', value: 'Chronic obstructive pulmonary disease' },
        { label: 'Chronic  kidney diseases', value: 'Chronic  kidney diseases' },
        { label: 'Cancer', value: 'Cancer' },
        ];
    }
    
    get symptomsOptions() {
        return [
            { label: 'Cough', value: 'Cough' },
            { label: 'Fever', value: 'Fever' },
            { label: 'Shortness of breath', value: 'Shortness of breath' },
            { label: 'Pneumonia', value: 'Pneumonia' },
            { label: 'ARDS', value: 'ARDS' },
            { label: 'Other', value: 'Other' },
        ];
    }

    get respiratoryViralPanelOpts() {
        return [
            { label: 'Yes', value: 'true' },
            { label: 'No', value: 'false' },
            { label: 'Pending', value: 'Pending' },
        ];
    }

    get yesNoOptions() {
        return [
            { label: 'Yes', value: 'true' },
            { label: 'No', value: 'false' }
        ];
    }

    @track points = 0;

    isYes = 'true';
    isNo = 'false';
    isPending = 'Pending'
    get isQuestion1True() {
        return this.responseWrapper.question1 === 'true';
    }

    get isQuestion1False() {
        return this.responseWrapper.question1 === 'false';
    }

    get isQuestion2True() {
        return this.responseWrapper.question2 === 'true';
    }

    get isQuestion2False() {
        return this.responseWrapper.question2 === 'false';
    }

    get isQuestion3True() {
        return this.responseWrapper.question3 === 'true' || this.responseWrapper.question3 === 'false';
    }

    get isQuestion5True() {
        return this.responseWrapper.question5 === 'true';
    }

    get isQuestion5False() {
        return this.responseWrapper.question5 === 'false';
    }

    get isQuestion7False() {
        return this.responseWrapper.question7 === 'false';
    }

    get isQuestion8False() {
        return this.responseWrapper.question8 === 'false';
    }

    get isQuestion9True() {
        return this.responseWrapper.question9 === 'true';
    }

    // @track answerQuestion1;

    handleResponseChange(event) {
        this.responseWrapper[event.target.name] = event.target.value;
        // console.log('question: ', event.target.name + ' ' + typeof event.target.name + ' ' + event.target.value + ' ' + typeof event.target.value);
        if (event.target.name === 'question1') {
            this.responseWrapper.question1 = event.target.value;
            if (this.responseWrapper.question1 === 'false') {
                this.responseWrapper.question2 = '';
                this.responseWrapper.question4 = '';
                this.allDone = false;
            } else if (this.responseWrapper.question1 === 'true') {
                // this.responseWrapper.points = this.responseWrapper.points + 3;
                this.responseWrapper.question3 = '';
                this.responseWrapper.question5 = '';
                this.responseWrapper.question6 = '';
                this.responseWrapper.question7 = '';
                this.responseWrapper.question8 = '';
                this.responseWrapper.question9 = '';
                this.allDone = false;
            }
        }

        if (event.target.name === 'question2') {
            this.responseWrapper.question2 = event.target.value;
            if (this.responseWrapper.question2 === 'true') {
                this.allDone = true;
                this.responseWrapper.question4 = '';
            } else {
                this.allDone = false;
            }
        }
        if (event.target.name === 'question4') {
            this.responseWrapper.question4 = event.target.value;
            this.allDone = true;
        }
        if (event.target.name === 'question3') {
            this.responseWrapper.question3 = event.target.value;
            if (this.responseWrapper.question3 === 'true') {
                this.responseWrapper.question2 = '';
                this.responseWrapper.question4 = '';
            }
        }
        if (event.target.name === 'question5') {
            this.responseWrapper.question5 = event.target.value;
            if (this.responseWrapper.question5 === 'true') {
                this.responseWrapper.question7 = '';
                this.responseWrapper.question8 = '';
                this.responseWrapper.question9 = '';
            } else if (this.responseWrapper.question5 === 'false') {
                this.responseWrapper.question6 = '';
                this.allDone = false;
            }
        }
        if (event.target.name === 'question7') {
            this.responseWrapper.question7 = event.target.value;
            if (this.responseWrapper.question7 === 'true') {
                this.responseWrapper.question8 = '';
                this.responseWrapper.question9 = '';
                this.allDone = true;
            } else if (this.responseWrapper.question7 === 'false') {
                this.allDone = false;
            }
        }
        if (event.target.name === 'question8') {
            this.responseWrapper.question8 = event.target.value;
            if (this.responseWrapper.question8 === 'true') {
                this.responseWrapper.question9 = '';
                this.allDone = true;
            } else if (this.responseWrapper.question8 === 'false') {
                this.allDone = false;
            }
        }
        if (event.target.name === 'question9') {
            this.responseWrapper.question9 = event.target.value;
            this.allDone = true;
        }   
        
        console.log('--this.responseWrapper-'+JSON.stringify(this.responseWrapper) );
    }


    handleWhomChange(event) {
        this.responseWrapper.question6 = event.target.value;
        if (!event.target.value || event.target.value !== '') {
            this.allDone = true;
        } else {
            this.allDone = false;
        }
    }

    @api
    isValid(){
        let valid = false;

        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        isAllValid &= [...this.template.querySelectorAll('lightning-checkbox-group')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        isAllValid &= [...this.template.querySelectorAll('lightning-radio-group')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        
        valid = isAllValid

        return valid;
    }

    @api
    getPoints(){
        let fields = this.getData();

        let points = 0;
        if( fields.Symptoms__c && fields.Healthcare_or_Emergency_Responder__c ){
            console.log('--Points Criteria 1-');
            points = 5;
        }
        else if( fields.Symptoms__c && !fields.Healthcare_or_Emergency_Responder__c && fields.COVID_Close_Contact__c ){
            console.log('--Points Criteria 2-');
            points = 5;
        }
        else if( fields.Symptoms__c && !fields.Healthcare_or_Emergency_Responder__c && !fields.COVID_Close_Contact__c ){
            console.log('--Points Criteria 3-');
            points = 5;
        }
        else if( !fields.Symptoms__c && fields.Nursing_Home_or_Healthcare__c && fields.Exposed_to_COVID__c ){
            console.log('--Points Criteria 4-');
            points = 4;
        }
        else if( !fields.Symptoms__c && !fields.Nursing_Home_or_Healthcare__c && fields.Exposed_to_COVID__c ){
            console.log('--Points Criteria 5-');
            points = 4;
        }

        console.log('getPoints: '+points);

        return points;
    }

    @api
    getFlowBreakMessage(){
        let fields = this.getData();
        
        console.log('-getFlowBreakMessage fields-'+ JSON.stringify(fields) );

        let flowBreakMsg = 0;
        if ( fields.X14_Day_Return_from_Level_3__c ){
            flowBreakMsg = 1;
        }
        else if (fields.Over_60_years_old__c || fields.Symptoms__c ){
            flowBreakMsg = 2;
        }

        console.log('-flowBreakMsg--'+flowBreakMsg);

        return flowBreakMsg;
    }

    @api
    getData(){
        let fields = {};
        fields[SYMPTOMPS_FIELD.fieldApiName] = (this.responseWrapper.question1 === "true");
        fields[HEALTHCARE_FIELD.fieldApiName] = (this.responseWrapper.question2 === "true");
        fields[NURSINGHOME_FIELD.fieldApiName] = (this.responseWrapper.question3 === "true");
        fields[CLOSECONTACT_FIELD.fieldApiName] = (this.responseWrapper.question4 === "true");
        fields[EXPOSEDTO_FIELD.fieldApiName] = (this.responseWrapper.question5 === "true");
        fields[WHOEXPOSED_FIELD.fieldApiName] = this.responseWrapper.question6;
        fields[X14DAYS_FIELD.fieldApiName] = (this.responseWrapper.question7 === "true");
        fields[OVER60_FIELD.fieldApiName] = (this.responseWrapper.question8 === "true");
        fields[CHRONIC_FIELD.fieldApiName] = (this.responseWrapper.question9 === "true");

        return fields;
    }

    // @api
    // handleNext() {
    //     if (this.allDone) {
    //         if (this.responseWrapper.question1 === 'true' &&
    //             (this.responseWrapper.question2 === 'true' ||
    //                 !this.responseWrapper.question4 || this.responseWrapper.question4 !== '')) {
    //             this.responseWrapper.points = 5;
    //         } else if (this.responseWrapper.question1 === 'false' &&
    //             this.responseWrapper.question3 === 'true' &&
    //             this.responseWrapper.question5 === 'true') {
    //             this.responseWrapper.points = 4;
    //         }

    //         console.log('questions data: ', JSON.stringify(this.responseWrapper));


    //         // if (this.responseWrapper.points < 4) {
    //         //     alert('Thank you page placeholder');
    //         // } else {
    //             fireEvent(this.pageRef, 'showSpinner', null);
    //             let fields = {};
    //             fields[ID_FIELD.fieldApiName] = this.recordId;
    //             fields[SYMPTOMPS_FIELD.fieldApiName] = this.responseWrapper.question1 !== '' ? true : false;
    //             fields[HEALTHCARE_FIELD.fieldApiName] = this.responseWrapper.question2 !== '' ? true : false;
    //             fields[NURSINGHOME_FIELD.fieldApiName] = this.responseWrapper.question3 !== '' ? true : false;
    //             fields[CLOSECONTACT_FIELD.fieldApiName] = this.responseWrapper.question4 !== '' ? true : false;
    //             fields[EXPOSEDTO_FIELD.fieldApiName] = this.responseWrapper.question5 !== '' ? true : false;
    //             fields[WHOEXPOSED_FIELD.fieldApiName] = this.responseWrapper.question6;
    //             fields[X14DAYS_FIELD.fieldApiName] = this.responseWrapper.question7 !== '' ? true : false;
    //             fields[OVER60_FIELD.fieldApiName] = this.responseWrapper.question8 !== '' ? true : false;
    //             fields[CHRONIC_FIELD.fieldApiName] = this.responseWrapper.question9 !== '' ? true : false;
    //             fields[CHRONIC_FIELD.fieldApiName] = this.responseWrapper.question9 !== '' ? true : false;
    //             // fields[POINTS_FIELD.fieldApiName] = this.responseWrapper.points !== '' ? true : false;

    //             console.log('fields - ', JSON.stringify(fields));
                
    //             saveQuestionAnswersNow({ objData: fields })
    //                 .then(() => {
    //                     // this.dispatchEvent(new CustomEvent('increasestep'));
    //                     fireEvent(this.pageRef, 'increaseStep', this.responseWrapper.points);
    //                 })
    //                 .catch(error => {
    //                     console.log('error in questions page: ', JSON.stringify(error));
    //                     fireEvent(this.pageRef, 'hideSpinner', null);
    //                 });
    //         // }
    //     } else {
    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Please fill the required information to proceed.',
    //             variant: 'error'
    //         }));
    //     }
    // }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChange(e) {
        this._selected = e.detail.value;
        this.responseWrapper.question2b = e.detail.value;
        if(this._selected.includes('Other')){
            this.otherfield = true;
        }else{
            this.otherfield = false;
        }
    }

    
    handlechronicChange(e){
        this._chronicDisease = e.detail.value;
        this.responseWrapper.question10b = e.detail.value;
    }
    @track otherSymptomValue;
    otherFieldChange(e){
        this.otherSymptomValue = e.target.value;
        this.responseWrapper.question2c = e.target.value;
    }
}