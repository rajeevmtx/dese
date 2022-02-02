import { api,LightningElement, track,wire } from 'lwc';
import updateProjectStatus from '@salesforce/apex/DESE_IntakeSubmitController.updateProjectStatus';
import sendEnvelope from '@salesforce/apex/EmbeddedSigningController.sendEnvelope';
import getEmbeddedSigningUrl from '@salesforce/apex/EmbeddedSigningController.getEmbeddedSigningUrl';
import { CurrentPageReference } from 'lightning/navigation';


export default class Dese_signature extends LightningElement {
    @api projectId='';
    showModal = false;
    showSpinner = false;
    applicationName;
    template = '29dba4bc-a627-4819-9613-62c856a24974';
    description = 'Embedded Signing';
    currentPageReference = null;
    readonly = false;
    disabledSubmit = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          if(currentPageReference.state.event  == 'signing_complete'){
              this.readonly = true;
              this.disabledSubmit = false;
          }
       }
    }

    connectedCallback() {
        window.scrollTo(0, 0);
    }

    handleClick() {
        this.showSpinner = true;
        console.log(this.projectId)
        sendEnvelope({ template: this.template, description: this.description, recordId: this.projectId })
            .then((envelopeId) => (
                getEmbeddedSigningUrl({
                    envId: envelopeId,
                    url: window.location.href
                    //url: new URL('http://www.docusign.com')
                })
            ))
            .then((signingUrl) => {
                console.log(signingUrl)
                window.location.href = signingUrl;
                //window.open(signingUrl);
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log('Error:');
                console.log(error);
                this.showSpinner = false;
            });
    }
    handleSubmit() {
        updateProjectStatus({projectId:this.projectId})
        .then(result => {
            this.applicationName = result;
            this.showModal = true;

            //window.open('/dese/s/dashboard','_self');
        }).catch(error => {

        })
    }
    handlePrev() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    
    handleOkayModal(){
        window.open('/dese/s','_self');
    }
}