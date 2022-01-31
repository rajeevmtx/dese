import { LightningElement, track, api} from 'lwc';
import { showMessage } from 'c/util';
import fetchRequestPermitType from '@salesforce/apex/PSRContractorInformationController.getAccountInformation';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_TYPE_FIELD from '@salesforce/schema/Account.Account_Type__c';
import CITY_FIELD from '@salesforce/schema/Account.City_Formula__c';
import PROVDER_AD1_FIELD from '@salesforce/schema/Account.Provider_Address_1__c';
import STATE_FIELD from '@salesforce/schema/Account.State__c';
import ZIP_FIELD from '@salesforce/schema/Account.Provider_Zip_Code__c';

export default class PsrContractorInformation extends LightningElement {
    @track accountInformation = {};
    @track obj1 = {
        name:'Devereux CARES Day Program',
        city:'New York',
        phone:'999999999'
    };
    @track obj2 = {
        name:'Devereux Residential Program',
        city:'New York',
        phone:'999999999'
    };
    @track obj3 = {
        name:'Devereux Day Program',
        city:'New York',
        phone:'999999999'
    };

    tableRecord = [
         {
            name:'Devereux CARES Day Program',
            city:'MA',
            phone:'9087654321'
        },
        {
            name:'Devereux Residential Program',
            city:'MA',
            phone:'9807654323'
        },
        {
            name:'Devereux Day Program',
            city:'MA',
            phone:'8907651234'
        }
    ];
    myFields = [NAME_FIELD, ACCOUNT_TYPE_FIELD, PROVDER_AD1_FIELD, CITY_FIELD, STATE_FIELD, ZIP_FIELD];

    loadData(){
        fetchRequestPermitType()
        .then(result => {
            this.accountInformation = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            showMessage(this, { message: message, messageType: 'error', mode: 'pester' });
        });
    }

    connectedCallback(){
        this.loadData();
    }

    handleSubmit(event) {
        console.log(event.detail);
    }
    handleSuccess(event) {
    }
}