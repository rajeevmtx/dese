import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getGrantDetails from '@salesforce/apex/DESE_ProposalController.getGrantDetails';
import createNewProposal from '@salesforce/apex/DESE_ProposalController.createNewProposal'
import desetheme from '@salesforce/resourceUrl/DESE_Design';
import checkIfProposal from '@salesforce/apex/DESE_ProposalController.isProposalExist';
import isGuestU from '@salesforce/user/isGuest';

export default class DeseGrantsDetail extends LightningElement {
    grantId
    @track grant = {};
    showSpinner = true;
    isGuestUser = isGuestU;
    @track grantsdashboard = desetheme + '/theme/images/grant.png';
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference.state.grantId)
            this.grantId = currentPageReference.state.grantId
            this.getInfo();
        }
    }

    getInfo() {
        console.log('getInfo');
        this.showSpinner = true;
        if (!this.grantId) return;
        getGrantDetails({ grantId: this.grantId })
            .then(result => {
                this.grant = result
                this.showSpinner = false;
            })
            .catch(error => {
                console.log(error)
                this.showSpinner = false;
            })
    }

    
    handleApplyOnline(){
        this.showSpinner = true;
        //lert(this.isGuestUser);
        // if(this.isGuestUser){
        //     window.open('/dese/s/login','_self');
        // } else{
            window.open('/dese/s/proposal-list?grantId='+this.grantId,'_self');
            // checkIfProposal({
            //     grantId : this.grantId
            // })
            // .then( data => {
            //     if(data == true){
            //         window.open('/dese/s/proposal-list?grantId='+this.grantId,'_self');
            //     } else{
            //         createNewProposal({
            //             grantId : this.grantId
            //         })
            //         .then( response => {
            //             window.open('/dese/s/grant-application?projectId='+response,'_self');
            //         })
            //         .catch(error => {
            //             console.log(JSON.stringify(error));
            //         }).finally(()=>{
            //             this.showSpinner = false;
            //         });
            //     }
            // })
        //}
    }

    get grantName(){
        return  this.grant && this.grant.Name  ? this.grant.Name + ' ( ' + this.grant.Solicitation_Number__c + ' )' : '';
    }
    handleback(){
        window.history.back();
    }
}