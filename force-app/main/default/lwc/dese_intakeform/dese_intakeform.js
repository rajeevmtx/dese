import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getParentGrantDetails from '@salesforce/apex/DESE_ProposalController.getParentGrantDetails'


export default class Dese_intakeform extends LightningElement {

    currentPageReference = null; 
    projectName = '';
    projectDate ='';
    currentStep = 1;
    isStep1 = true;
    projectId = '';
    @track wrapper = {
        contacts : [],
        allocations : {},
        pss : {}
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference.state.projectId,this.docusignEvent = currentPageReference.state.event)
          this.projectId = currentPageReference.state.projectId
          getParentGrantDetails({projectId: this.projectId})
          .then( result => {
              console.log(result)
              this.projectName = result.Name + ' ( ' + result.Solicitation_Number__c + ' )';
              this.projectDate = result.Due_Date__c;
          })
          .catch(error => {
              console.log(error)
          })
          this.docusignEvent = currentPageReference.state.event;
          if(this.docusignEvent == 'signing_complete'){
            this['isStep1'] = false;
            this.currentStep = 11;
            this['isStep'+this.currentStep] = true;
          }
       }
    }

    handleNext() {
        console.log('event handeled')
        this['isStep'+this.currentStep] = false;
        this.currentStep = this.currentStep + 1;
        this['isStep'+this.currentStep] = true;
        console.log(this.isStep1,this.isStep2,this.isStep3)
    }

    handlePrev() {
        if (this.currentStep > 1) {
            this['isStep'+this.currentStep] = false;
            this.currentStep = this.currentStep - 1;
            this['isStep'+this.currentStep] = true;
        }
    }

    handleStepChange(event) {
        // console.log(event.detail, event.target);
        // for (let i = 1; i < 12 ; i++) {
        //     this['isStep'+i] = false;
        // }
        // this.currentStep = parseInt(event.detai)
        // this['isStep'+this.currentStep] = true;


        this['isStep'+this.currentStep] = false;
        this.currentStep = parseInt(event.detail);
        this['isStep'+this.currentStep] = true;
    }
}