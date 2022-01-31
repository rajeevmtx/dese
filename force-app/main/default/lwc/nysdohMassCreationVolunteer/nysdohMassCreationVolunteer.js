import { LightningElement,api,track,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import VOLUNTEER_ASSIGNEMENT_OBJECT from '@salesforce/schema/Volunteer_Assignment__c';
import Type_FIELD from '@salesforce/schema/Volunteer_Assignment__c.Shift_Type__c';
import { NavigationMixin } from 'lightning/navigation';

import getInitialDetail from '@salesforce/apex/DC_VolunteerMassCreation.getInitialDetail';
import createVolunteerAssignment from '@salesforce/apex/DC_VolunteerMassCreation.createVolunteerAssignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class NysdohMassCreationVolunteer extends NavigationMixin(LightningElement) {

    @api idvalues;
    @track dataValue;
    @track accountName;
    @track options = [];           
    @track shiftList = [];
    @track startDate;
    @track endDate;
    @track selectedvalue;
    @track Portal_Work_Order_Help_Text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';

    @wire(getObjectInfo, { objectApiName: VOLUNTEER_ASSIGNEMENT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Type_FIELD})
    TypePicklistValues;

    connectedCallback() {
        console.log('Id-Values', this.idvalues);
        console.log('TypePicklistValues', JSON.stringify(this.TypePicklistValues));
        this.retrieveAccountInfo();
    }

    retrieveAccountInfo() {
        getInitialDetail({})
        .then(result => {
            console.log('Account_data' + JSON.stringify(result));
            //this.accountName = result.Account.Name;
            this.startDate = result.startDate;
            this.endDate = result.endDate;
            this.accountName = result.accountName;
            result.shift.forEach((data) => {
                var optionValue = new Object();
                optionValue.label = data.label;
                optionValue.value = data.value;
                this.shiftList.push(optionValue);
            });
            this.options = this.shiftList;
        })
        .catch(error => {
            console.log('Error-->', error);
        });
    }

    createAssignment() {
        console.log(this.idvalues+'__'+this.selectedvalue+'____'+this.startDate+'____'+this.endDate)
        createVolunteerAssignment({ volunteers: this.idvalues, shift : this.selectedvalue, startDate: this.startDate, endDate: this.endDate })
            .then(result => {
                console.log('Success-->' + result);
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant: 'success',
                    message: 'Volunteer Assignments got created.',
                });
                this.dispatchEvent(event);
                this.navigateToHome();
            })
            .catch(error => {
                console.log('Error-->' + JSON.stringify(error));
                const event = new ShowToastEvent({
                    title: 'Error!',
                    variant: 'error',
                    message: 'Volunteer Assignments are not created.',
                });
                this.dispatchEvent(event);
            });   
    }

    selectionChangeHandler(event) {
        this.selectedvalue = event.target.value;
    }

    startDateChangeHandler(event) {
        this.startDate = event.target.value;
        var inputCmp = this.template.querySelector(".startdate");
        if (this.startDate > this.endDate) {    
            inputCmp.setCustomValidity("Start date should not be less than end date");
        } else {
            inputCmp.setCustomValidity("");
        }

    }
    endDateChangeHandler(event) {
        this.endDate = event.target.value;
        var inputCmp = this.template.querySelector(".enddate");
        if (this.startDate > this.endDate) {    
            inputCmp.setCustomValidity("End date should greater than end date");
        } else {
            inputCmp.setCustomValidity("");
        }
    }
   
    //dummy
    register(event) {
        var inputCmp = this.template.querySelector(".inputCmp");
        var value = inputCmp.value;
        // is input valid text?
        if (value === "John Doe") {
            inputCmp.setCustomValidity("John Doe is already registered");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
    }

    navigateToHome() {
        console.log('In Navigation Functoin');
        location.href = '/NYSDOH/s/';
    }
}