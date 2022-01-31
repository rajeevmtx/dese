import { LightningElement, track } from 'lwc';
import getAccountName from '@salesforce/apex/UserInfoDetails.getAccountName';
import getStatus from '@salesforce/apex/UserInfoDetails.getStatus';

export default class NysdohAuthenticatedHome extends LightningElement {

    @track accountName;
    @track StatusObject;
    constructor() {
        super();
        getAccountName()
        .then(result => {
            this.accountName = result;
        })
        .catch(error => {
            console.log('Error',error);
        });

        getStatus()
        .then(result => {
            this.StatusObject = result;
            console.log('this.StatusObject ' + JSON.stringify(this.StatusObject));
        })
        .catch(error => {
            console.log('Error',error);
        });
        
    }
}