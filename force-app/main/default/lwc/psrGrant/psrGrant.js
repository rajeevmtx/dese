import { LightningElement, track } from 'lwc';
import fetchGrants from '@salesforce/apex/PSR_CaseController.fetchGrants';
import Portal_Helpdesk_Help_Text from '@salesforce/label/c.Portal_Helpdesk_Help_Text';

export default class PsrGrant extends LightningElement {
    Portal_Helpdesk_Help_Text = Portal_Helpdesk_Help_Text;
    @track grants;
    @track isChatterModalOpen = false;
    constructor() {
        super();
        this.setCases(); 
    }

    setCases() {
        fetchGrants()
            .then(res => {
                //this.cases = JSON.parse(JSON.stringify(res));
                this.grants = JSON.parse(JSON.stringify(res));               
            });

    }
    openChatter(event) {
        console.log('In Open Chatter', event.target.dataset.caseid);
        // this.caseId = event.target.dataset.caseid; 
        this.isChatterModalOpen = true;
    }
    closeModal() {
        this.isChatterModalOpen = false;
    }
}