import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import APS_IntakeFormCSS from '@salesforce/resourceUrl/APS_IntakeFormCSS';
import createCase from '@salesforce/apex/AdultProtectiveServiceController.createCase';
import createVictim from '@salesforce/apex/AdultProtectiveServiceController.createVictim';

export default class Aps_intake_form extends LightningElement {
    @track saveError = '';
    @track currentStep;
    @track originalStep = 1;
    @track showInstructionsPage = 'display: none';
    @track showIncidentInformation = 'display: none';
    @track showVictimInformation = 'display: none';
    @track showPerpetrateInformation = 'display: none';
    @track showReportingPartiesInformation = 'display: none';
    @track showSubmission = 'display: none';
    @track showThankYouScreen = false;
    @track caseRecId;
    @track showSpinner = false;

    connectedCallback() {
        var pageUrl = window.location.href;
        // this.caseRecId = new URL(pageUrl).searchParams.get("id");        
        loadStyle(this, APS_IntakeFormCSS);

        this.navigateToInstructionsPage();
    }

    hideComponents() {
        this.showInstructionsPage = 'display: none';
        this.showIncidentInformation = 'display: none';
        this.showVictimInformation = 'display: none';
        this.showPerpetrateInformation = 'display: none';
        this.showReportingPartiesInformation = 'display: none';
        this.showSubmission = 'display: none';
        this.showThankYouScreen = false;
    }

    navigateToInstructionsPage() {
        this.currentStep = 1;
        this.hideComponents();
        this.showInstructionsPage = 'display: block';
    }

    navigateToIncidentInformation() {
        this.currentStep = 2;
        this.hideComponents();
        this.showIncidentInformation = 'display: block';
    }

    navigateToVictimInformation() {
        let incident_information = this.template.querySelector('c-aps_incident_information');
        if( incident_information.isValid() ){
            let incidentInformationData = incident_information.getData();

            let isNewCase = false;
            if( this.caseRecId ){
                incidentInformationData.Id = this.caseRecId;
            }
            else{
                isNewCase = true;
            }

            this.showSpinner = true;
            createCase( {JsonData : JSON.stringify(incidentInformationData) } )
            .then(result => {
                this.caseRecId = result.Id;

                this.currentStep = 3;
                this.hideComponents();
                this.showVictimInformation = 'display: block';
                
                if( isNewCase ){
                    window.history.pushState('page2', 'Title', window.location + '?id='+this.caseRecId);
                }

                this.showSpinner = false;
            })
            .catch(error => {
                let message = error.message || error.body.message;
                console.log(message);

                this.showSpinner = false;
            });
        }
    }

    navigateToPerpetrateInformation() {
        let victim_information = this.template.querySelector('c-aps_victim_information');
        if( victim_information.isValid() ){
            let incidentInformationData = victim_information.getData();
            this.showSpinner = true;
            let caserec = {Id : this.caseRecId, Vulnerabilities__c : incidentInformationData.vulnerabilities};
            createVictim( {contact : incidentInformationData.contact, caserec : caserec } )
            .then(result => {
                this.currentStep = 4;
                this.hideComponents();
                this.showPerpetrateInformation = 'display: block';
                this.showSpinner = false;
            })
            .catch(error => {
                let message = error.message || error.body.message;
                console.log(message);

                this.showSpinner = false;
            });
        }
    }

    navigateToReportingPartiesInformation() {
        this.currentStep = 5;
        this.hideComponents();
        this.showReportingPartiesInformation = 'display: block';
    }

    navigateToSubmission() {
        this.currentStep = 6;
        this.hideComponents();
        this.showSubmission = 'display: block';
    }

    navigateToThankYou(){
        this.hideComponents();
        this.showThankYouScreen = true;
    }

    saveRecord(){
        this.saveError = '';
        let wizardData = {};
        // wizardData.applicantInformation = this.template.querySelector('c-unemployment-claim-applicant-information').getData();
        // wizardData.employmentHistory = this.template.querySelector('c-unemployment-claim-employment-history').getData();
        // wizardData.citizenship = this.template.querySelector('c-unemployment-claim-citizenship').getData();
        // wizardData.monetoryInformation = this.template.querySelector('c-unemployment-claim-monetory-information').getData();
           
        this.showSpinner = true;

        console.log( JSON.stringify( wizardData ) );
          
        this.navigateToThankYou();

        this.showSpinner = false;

        // createCaseAndContact( {JsonData : JSON.stringify( wizardData ) } )
        // .then(result => {
        //     this.caseObj = result;
        //     this.showSpinner=false;
        //     this.navigateToThankYou();
        // })
        // .catch(error => {
        //     let message = error.message || error.body.message;
        //     this.saveError = message;
        //     this.showSpinner=false; 
        //     console.log(message);
        // });
    }
}