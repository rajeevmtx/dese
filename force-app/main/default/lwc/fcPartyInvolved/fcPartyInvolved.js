import { LightningElement, api, track } from 'lwc';
import fetchPartiesInvolved from '@salesforce/apex/FC_ChildIntakeFormController.fetchPartiesInvolved';
// import deletePatientExposure from '@salesforce/apex/FC_ChildIntakeFormController.deletePatientExposure';

export default class FcPartyInvolved extends LightningElement {
    @api caseId;
    @api wizardData;
    @track isShowModal = false;
    @track showSpinner = false;
    @api isInternal = false;
    @api intId;
    @track dataList = [];
    @track tempData = [];
    @track recId = undefined;
    @track helpTextContacts = 'Please enter as much contact info as you are able, including or all those involved, including parents, family members, school staff, medical professionals, and the person believed responsible for the abuse:';

    //@api
    fetchPartiesInvolvedList(){
        this.showSpinner = true;
        console.log('this.caseId>>>', this.caseId);
        console.log('this.tempData>>>', JSON.stringify(this.tempData));
        fetchPartiesInvolved( {caseId : this.caseId, wizardData: JSON.stringify(this.tempData)} )
        .then(result => {
            this.dataList = result;
            console.log('this.dataList>>>' + JSON.stringify(this.dataList));
            this.showSpinner=false;
        })
        .catch(error => {
            this.erroMsg = error.message || error.body.message;
            this.showSpinner=false; 
        });
    }

    openModal(event){
        this.selectedData = {};
        console.log('event.target.name>>>',event.target.name);
        if( event.target.name ){
            for(let i = 0 ; i < this.dataList.length ; i++ ){
                if( event.target.name == this.dataList[i].partyInvolvedId ){
                    this.selectedData = this.dataList[i];
                    break;
                }
            }
        }

        this.isShowModal = true;
    }

    openPatientContact(event){
        window.location.href = '/Patient_Contacts__c/'+event.currentTarget.getAttribute('data-id')+'/view';
    }

    deleteRow(event){
        this.showSpinner = true;
        deletePatientExposure( {patientContactId : event.target.name} )
        .then(patientExposureRecord => {
            this.erroMsg = undefined;
            this.showSpinner=false;
            this.fetchPartiesInvolvedList();
        })
        .catch(error => {
            this.erroMsg = error.message || error.body.message + 'Contact Information Page';
            this.showSpinner=false; 
            console.log('Error ' + this.erroMsg);
        });
    }

    @api
    isValid(){
        return (this.dataList.length > 0);
    }  

    refreshData(){
        this.isShowModal = false;
        this.fetchPartiesInvolvedList();
    }

    afterSave(event){
        var detail = event.detail;
        console.log('partyFirstName>>>', detail.partyFirstName);
        console.log('partyLastName>>>', detail.partyLastName);
        this.tempData.partyFirstName = detail.partyFirstName;
        this.tempData.partyLastName = detail.partyLastName;
        console.log('this.tempData>>>', JSON.stringify(this.tempData));
        this.refreshData();
    }

    connectedCallback(){
    }
}