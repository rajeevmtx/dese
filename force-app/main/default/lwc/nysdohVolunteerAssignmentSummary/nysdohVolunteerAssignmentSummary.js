/**
 * Created by arunm on 24-03-2020.
 */

import { LightningElement, track } from 'lwc';
import getVolunteerAssignmentSummary from '@salesforce/apex/NYSDOH_SummaryController.getVolunteerAssignmentSummary';
import getCurrentUser from '@salesforce/apex/NYSDOH_RequestController.getCurrentUser';

export default class NysdohVolunteerAssignmentSummary extends LightningElement {

    @track volunteerName = '';
    @track summary;

    constructor() {
        super();
        getCurrentUser()
        .then(result => {
            this.volunteerName = result.Name;
        })
        .catch(error => {
            console.log('Error',error);
        });

        getVolunteerAssignmentSummary()
        .then(result => {
            this.summary = result;
        })
        .catch(error => {
            console.log('Error',error);
        });

    }
}