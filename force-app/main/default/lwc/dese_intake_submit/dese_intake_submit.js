import { api, LightningElement } from 'lwc'; 
import updateProjectStatus from '@salesforce/apex/DESE_IntakeSubmitController.updateProjectStatus'

export default class Dese_intake_submit extends LightningElement {
    @api projectId='';
    showModal = false;
    applicationName;
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