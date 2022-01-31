import { LightningElement,api,wire,track } from 'lwc';
import getSymptomsFollowUpRecords from '@salesforce/apex/DC_FollowUpController.getSymptomsFollowUpRecords';

export default class MtxSubjectFollowUp extends LightningElement {

    @api recordId;
    @track followUpList = [];
        
    connectedCallback() {
        this.fetchSymptomsData();
    }

    fetchSymptomsData() {
       
        if (this.temprature != '') {
            getSymptomsFollowUpRecords({
                subjectId: this.recordId
                })
                .then(result => {
                    console.log(result);
                    this.followUpList = result;
                })
                .catch(error => {
                    console.log(error);
                });
        } else {
            console.log('Record Id not defined');
        }
    }
}