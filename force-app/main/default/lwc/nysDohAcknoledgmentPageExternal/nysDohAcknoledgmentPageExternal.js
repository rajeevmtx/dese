/**
 * @author Vishnu Kumar
 * @email vishnu.kummar@mtxb2b.com
 * @desc This component is part of intake form for Community only.
*/
import { LightningElement, api, track,wire } from 'lwc';
import getAllTestAccounts from '@salesforce/apex/NysDohGetAllAccounts.getAllTestAccounts';
import NYS_DOH_Agreement from '@salesforce/label/c.NYS_DOH_Agreement';

export default class NysDohAcknoledgmentPageExternal extends LightningElement {
    agreement = NYS_DOH_Agreement;
    @track dataObj = {};
    @track items = [];
    @api isCommunity;

    get preferredTimeslots(){
        return [
            { label: 'Morning', value: 'Morning' },
            { label: 'Afternoon', value: 'Afternoon' },
            { label: 'Evening', value: 'Evening' }
        ];
    }

    get accountOption() {
        return this.items;
    }

    @wire(getAllTestAccounts)
    wiredUserRoles({ error, data }) {
        let i = 0;
        if (data) {
            for( let i=0 ; i < data.length ; i++ )  {
                this.items = [...this.items ,{value: data[i].Id , label: data[i].Name} ];                                   
            }                
        }
        else if (error) {
            console.log('error>>'+JSON.stringify(error));
        }
    }

    handleInput(event){
        if( event.target.name === 'Preferred_Timing__c' || event.target.name === 'Preferred_Testing_Site__c' ){
            this.dataObj[event.target.name] = event.target.value;
        }
        else if( event.target.name === 'Opt_in_for_SMS_Updates__c' || event.target.name === 'Agree_to_the_Terms__c' ){
            this.dataObj[event.target.name] = event.target.checked;
        }
    }

    @api
    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        isAllValid &= [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        valid = isAllValid;

        if(this.dobError){
            valid = false;
        }
        return valid;
    }

    @api
    getData(){
        return this.dataObj;
    }
}