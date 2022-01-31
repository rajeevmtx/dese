import { LightningElement, api, track } from 'lwc';
import getPrefrences from '@salesforce/apex/FC_ParentPreferenceController.getPrefrencesInternal';
import savePrefrences from '@salesforce/apex/FC_ParentPreferenceController.savePrefrences';
import fetchPicklist from '@salesforce/apex/FC_ParentPreferenceController.fetchPicklistForChild';

export default class FcPreferenceInternal extends LightningElement {
    @api recordId;
    @track dataList = [];
    @track selectedData = {};
    @track selectedObject = {};
    @track isShowModal = false;
    @track showSpinner = false;
    @track showPicklist = false;
    @track caseId;
    @track picklistValues = [];

    getPrefrencesList(){
        this.showSpinner = true;
        getPrefrences({ caseId: this.recordId})
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
        var type = event.currentTarget.dataset.type;
        console.log('type>>>', type);
        fetchPicklist( {type: type} )
        .then(result => {
            console.log('type>>>', result);
            this.picklistValues = result;
            if(result.length != 0){
                this.showPicklist = true;
            }else{
                this.showPicklist = false;
            }
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Error: ' + message);
        });
        
        this.selectedData = {};
        this.selectedObject.preferenceId = event.target.name;
        if( event.target.name ){
            for(let i = 0 ; i < this.dataList.length ; i++ ){
                if( event.target.name == this.dataList[i].Id ){
                    this.selectedData = this.dataList[i];
                    break;
                }
            }
        }
        this.fillCurrentData();
        this.isShowModal = true;
    }
    handleInput(event){
        if( event.target.name === 'value' ){
            this.selectedObject.value = event.target.value;
        }
        else if( event.target.name === 'startDate' ){
            this.selectedObject.startDate = event.target.value;
        }
        else if( event.target.name === 'endDate' ){
            this.selectedObject.endDate = event.target.value;
        }
    }
    handleModalClose(){
        this.isShowModal = false;
    }
    handleSaveRecord(){
        if(this.isValid()){
            this.showSpinner = true;
            savePrefrences({ jsonData : JSON.stringify(this.selectedObject) })
            .then(result => {
                this.selectedData = result;
                this.isShowModal = false;
                this.getPrefrencesList();
                this.showSpinner=false;
            })
            .catch(error => {
                this.erroMsg = error.message || error.body.message;
                this.showSpinner=false; 
            });
        }
    }
    fillCurrentData(){
        this.selectedObject.id = this.selectedData.Id;
        this.selectedObject.type = this.selectedData.Type__c;
        this.selectedObject.value = this.selectedData.Value__c;
        this.selectedObject.startDate = this.selectedData.Start_Date__c;
        this.selectedObject.endDate = this.selectedData.End_Date__c;
        this.selectedObject.durationRequired = this.selectedData.Duration_Required__c;
    }
    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        console.log('Valid Personal Information : ' + valid);
        return valid;
    }
    connectedCallback(){
        this.getPrefrencesList();
    }
}