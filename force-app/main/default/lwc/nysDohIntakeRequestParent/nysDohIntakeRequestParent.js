/* eslint-disable no-console */
/**
 * Created by hardikranjan on 22/03/20.
 */

import { LightningElement, track, api } from 'lwc';
import saveContactInfo from '@salesforce/apex/NYCDOH_IntakeRequestTestCenter.saveContactInformation';
import isCommunity from '@salesforce/apex/NYCDOH_IntakeRequestTestCenter.isCommunity';
import NYS_DOH_External_Thank_You from '@salesforce/label/c.NYS_DOH_External_Thank_You';
import { loadStyle } from 'lightning/platformResourceLoader';
import NYSDOHIntakeFormCSS from '@salesforce/resourceUrl/NYSDOHIntakeFormCSS';

export default class NysDohIntakeRequestParent extends LightningElement {
    @track currentStep = 1;
    @track isAllValid;
    @track contactInfo;
    @track originalStep = 0;

    @track showSpinner = false;
    @track contactId;
    @track points;

    @api internalUse = false;
    @track isInstructionsPage = 'slds-hide';
    @track isQuestionsPage = 'slds-hide';
    @track isContactDetailPage = 'slds-hide';
    @track isAckPage = 'slds-hide';
    @track isThankYouPage = false;
    @track isCommunity = false;
    @track isShowSchedulingOption = false;
    @track isPointsCalculated = false;
    @track isShowFlowTerminateMessage = false;
    @track errorMsg = '';

    NYS_DOH_External_Thank_You = NYS_DOH_External_Thank_You;

    connectedCallback() {
        loadStyle(this, NYSDOHIntakeFormCSS);

        isCommunity()
        .then(result => {
            this.isCommunity = result;

            if( result ){
                this.goToInstructionsPage();
            }
            else{
                this.goToQuestionsPage();
            }
        })
        .catch(error => {
            console.log('error in contactinfo page: ', JSON.stringify(error));
        });
    }

    goToInstructionsPage(){
        this.hideAll();
        this.isInstructionsPage = 'slds-show';
        this.currentStep =1;
    }

    goToQuestionsPage(){
        this.isPointsCalculated = false;

        this.hideAll();
        this.isQuestionsPage = 'slds-show';
        this.currentStep =2;
    }

    @track isShowFlowBreakMsg_1 = false;
    @track isShowFlowBreakMsg_2 = false;

    goToContactDetailPage(){
        this.isShowSchedulingOption = false;
        this.isShowFlowTerminateMessage = false;
        this.isPointsCalculated = true;
        this.isShowFlowBreakMsg_1 = false;
        this.isShowFlowBreakMsg_2 = false;

        let questionPage = this.template.querySelector('c-nys-doh-questionaire-page');
       
        if( questionPage.isValid() ){
            this.hideAll();

            this.points = questionPage.getPoints();
            //Temp
            // this.points = 3;

            if( this.points >= 4 ){
                this.isShowSchedulingOption = true;
                this.isContactDetailPage = 'slds-show';
                this.currentStep =3;
            }
            else{
                this.isShowFlowTerminateMessage = true;

                if( questionPage.getFlowBreakMessage() == 1 ){
                    this.isShowFlowBreakMsg_1 = true;
                }
                else if( questionPage.getFlowBreakMessage() == 2 ){
                    this.isShowFlowBreakMsg_2 = true;
                }
            }

            console.log('----Points--'+this.points);
        }
    }

    goToAckPage(){
        let contactDetailPage = this.template.querySelector('c-nysdoh-demographics');

        console.log('--Step 2 Valid-'+contactDetailPage.isValid());

        if( contactDetailPage.isValid() ){
            this.hideAll();
            this.isAckPage = 'slds-show';
            this.currentStep =4;
        }
    }

    goToThankYouPage(){
        let acknoledgmentPage = this.template.querySelector('c-nys-doh-acknoledgment-page-external');

        console.log('--Step 3 Valid-'+acknoledgmentPage.isValid());

        if( acknoledgmentPage.isValid() ){
            this.hideAll();
            this.isThankYouPage = true;
        }
    }

    saveAllData(){
        let contactObject = {};

        let questionPage = this.template.querySelector('c-nys-doh-questionaire-page');
        let contactDetailPage = this.template.querySelector('c-nysdoh-demographics');
        let acknoledgmentPage = this.template.querySelector('c-nys-doh-acknoledgment-page-external');
    
        //If acknoledgment is invalid
        if( !acknoledgmentPage.isValid() ){
            return;
        }

        let questionsObj = questionPage.getData();
        let contactObj = contactDetailPage.getData();
        let acknoledgmentObj = acknoledgmentPage.getData();

        let keys = Object.keys(questionsObj);
        for (const key of keys) {
            contactObject[key] = questionsObj[key];
        }

        keys = Object.keys(contactObj);
        for (const key of keys) {
            contactObject[key] = contactObj[key];
        }

        keys = Object.keys(acknoledgmentObj);
        for (const key of keys) {
            contactObject[key] = acknoledgmentObj[key];
        }

        console.log('--contactObject--'+JSON.stringify(contactObject) );
            
        this.showSpinner = true;
        saveContactInfo( {objData : JSON.stringify(contactObject) })
        .then(result => {
            this.goToThankYouPage();
            this.showSpinner = false;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Save Error: '+message);
            this.errorMsg = message;
            this.showSpinner = false;
        });
    }

    hideAll(){
        this.isInstructionsPage = 'slds-hide';
        this.isQuestionsPage = 'slds-hide';
        this.isContactDetailPage = 'slds-hide';
        this.isAckPage = 'slds-hide';
        this.isThankYouPage = false;
    }

    goBack(){
        location.reload();
    }
}