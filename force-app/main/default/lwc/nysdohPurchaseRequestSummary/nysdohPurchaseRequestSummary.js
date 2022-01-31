/**
 * Created by arunm on 23-03-2020.
 */

import { LightningElement, track } from 'lwc';
import getPurchaseRequestSummary from '@salesforce/apex/NYSDOH_SummaryController.getPurchaseRequestSummary';
import getCurrentUser from '@salesforce/apex/NYSDOH_RequestController.getCurrentUser';
export default class NysdohPurchaseRequestSummary extends LightningElement {

    @track supplierName = '';
    @track summary;

    constructor() {
        super();
        getCurrentUser()
        .then(result => {
            this.supplierName = result.Name;
        })
        .catch(error => {
            console.log('Error',error);
        });

        getPurchaseRequestSummary()
        .then(result => {
            this.summary = result;
            console.log('this.summary ' + JSON.stringify(this.summary));
        })
        .catch(error => {
            console.log('Error',error);
        });

    }

}