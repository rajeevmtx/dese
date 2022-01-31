import { LightningElement, track, api} from 'lwc';
import fetchCases from '@salesforce/apex/PSR_CaseController.fetchCases';
import { updateRecord } from 'lightning/uiRecordApi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ID_FIELD from '@salesforce/schema/Case.Id';
import Portal_Helpdesk_Help_Text from '@salesforce/label/c.Portal_Helpdesk_Help_Text';


export default class PsrTechnicalSupport extends LightningElement { 
    @track isNewCase = false;
    @track cases = [];
    @track caseId;
    @track isChatterModalOpen = false;
    @api Portal_Helpdesk_Help_Text = Portal_Helpdesk_Help_Text;

    constructor() {
        super();
        this.setCases(); 
    }

    setCases() {
        fetchCases()
            .then(res => {
                //this.cases = JSON.parse(JSON.stringify(res));
                let _cases = JSON.parse(JSON.stringify(res));
                let _modifiedCases = [];
                if(res.length > 0){
                    _cases.forEach(element => {
                       if(element.Status == 'Closed'){
                           element.isClosed = true;
                       }else{
                           element.isClosed = false;
                       } 
                       _modifiedCases.push(element);
                    });
                }
                this.cases = _modifiedCases;
            });

    }

    closeModal() {
        this.setCases();
        this.isNewCase = false;
        this.isChatterModalOpen = false;
    }

    openModal() {
        this.isNewCase = true;
    }
    
    closeCase(event) {
        console.log('In Close Case', event.target.dataset.caseid);
        let caseId = event.target.dataset.caseid;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = caseId;
        fields[STATUS_FIELD.fieldApiName] = 'Closed';
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case Closed',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                this.setCases();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in closing case record',
                        message: 'Error while updating the case record',
                        variant: 'error'
                    })
                );
            });
    }

    openChatter(event) {
        console.log('In Open Chatter', event.target.dataset.caseid);
        this.caseId = event.target.dataset.caseid; 
        this.isChatterModalOpen = true;
    }
}