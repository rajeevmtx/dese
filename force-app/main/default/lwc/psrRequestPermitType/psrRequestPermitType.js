import { LightningElement, track, api } from 'lwc';
import { showMessage } from 'c/util';
import fetchRequestPermitType from '@salesforce/apex/PSR_RequestPermitTypeController.fetchRequestPermitType';
import Portal_Request_Permit_Type_Help_Text from '@salesforce/label/c.Portal_Request_Permit_Type_Help_Text';

export default class PsrRequestPermitType extends LightningElement {
    @api Portal_Request_Permit_Type_Help_Text = Portal_Request_Permit_Type_Help_Text;
    @track cases = [];
    @track isShowNewRequestPermit = false;
    @track permitTypes = [];
    @track validPermitTypes = [];

    loadData(){
        this.cases = [];
        this.validPermitTypes = ['Foundation', 'Installation', 'Mechanical', 'Electrical', 'Repair', 'Refurbished'];

        fetchRequestPermitType()
        .then(result => {
            this.cases = result;

            for( let i =0 ; i < result.length ; i++ ){
                if( result[i].record.Status === 'Pending Approval' || result[i].record.Status === 'Approved' ) {

                    console.log('--result[i].record.Request_Permit_Type__c-'+result[i].record.Request_Permit_Type__c);
                    this.validPermitTypes = this.validPermitTypes.filter(e => e !== result[i].record.Request_Permit_Type__c );
                }
            }

            console.log('--validPermitTypes 00--'+JSON.stringify(this.validPermitTypes) );
        })
        .catch(error => {
            let message = error.message || error.body.message;
            showMessage(this, { message: message, messageType: 'error', mode: 'pester' });
        });
        

        console.log('--validPermitTypes--'+JSON.stringify(this.validPermitTypes) );
    }

    handleNewPermitType(){
        this.isShowNewRequestPermit = true;
    }

    closeNewPermitType(){
        this.isShowNewRequestPermit = false;
    }

    refreshAndCloseNewPermitType(){
        this.closeNewPermitType();
        this.loadData();
    }

    connectedCallback(){
        this.loadData();
    }
}