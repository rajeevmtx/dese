/**
 * Created by hardikranjan on 22/03/20.
 */

import { LightningElement , track, wire, api} from 'lwc';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import STATE from '@salesforce/schema/Contact.State_Global_Picklist__c';
import PHONETYPE from '@salesforce/schema/Contact.Phone_Type__c';
import Phone from '@salesforce/schema/Contact.Phone';
import COUNTYRES from '@salesforce/schema/Contact.County_of_Residence__c';
import BirthDate from '@salesforce/schema/Contact.BirthDate';

import GENDER from '@salesforce/schema/Contact.Sex__c';
import FIRSTNAME from '@salesforce/schema/Contact.FirstName';
import LASTNAME from '@salesforce/schema/Contact.LastName';
import MAILINGSTATE from '@salesforce/schema/Contact.MailingState';
import MAILINGCITY from '@salesforce/schema/Contact.MailingCity';
import POSTALCODE from '@salesforce/schema/Contact.MailingPostalCode';
import MAILINGSTREET from '@salesforce/schema/Contact.MailingStreet';
import EMAIL from '@salesforce/schema/Contact.Email';
import MIDDLENAME from '@salesforce/schema/Contact.Middle_Name__c';
import COMMENTS from '@salesforce/schema/Contact.Comments__c';
import APTSUITE from '@salesforce/schema/Contact.Apartment_Suite__c';
import NEWEMP from '@salesforce/schema/Contact.Are_you_a_New_York_State_employee__c';
import FACILITYRES from '@salesforce/schema/Contact.Facility_of_Residence_If_applicable__c';
import OCCUPATION from '@salesforce/schema/Contact.Occupation__c';


import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class NysdohDemographics extends LightningElement {
    @track dataObj = {};
    @api state = [];
    @api instructionsHelpText = "Please complete the below information based on your personal details. This will help the NYS Department of Health prepare for any future scheduled testing."; 
    @track zipError = 'Zip is not valid';
    @track telephoneError = 'Telephone Number is not valid';
    @track emailError = 'Email is not valid';
    @track ssnError = 'SSN is not valid';

    @track ssnErrorMsg = '';
    @track dobError = false;

    get genderOptions() {
        return [
            { label: 'Male', value: 'Male' },
            { label: 'Female', value: 'Female' },
            { label: 'Others', value: 'Others' },
        ];
    }

    get yesNoOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    applicationInfo;

    @wire(getPicklistValues, { recordTypeId: '$applicationInfo.data.defaultRecordTypeId', fieldApiName: STATE })
    stateOfInformationFieldInfo;

    @wire(getPicklistValues, { recordTypeId: '$applicationInfo.data.defaultRecordTypeId', fieldApiName: PHONETYPE })
    phoneTypeFieldInfo;

    @wire(getPicklistValues, { recordTypeId: '$applicationInfo.data.defaultRecordTypeId', fieldApiName: COUNTYRES })
    countyResFieldInfo;

    @wire(getPicklistValues, { recordTypeId: '$applicationInfo.data.defaultRecordTypeId', fieldApiName: OCCUPATION })
    OccupationFieldInfo;

    handleInput(event) {
        if( event.target.name === 'telephoneNumber' ){
             this.formatPhone(event.currentTarget);
             this.dataObj[event.target.name] = event.target.value;
        }
        else if ( event.target.name === 'dob' ) {
            this.dataObj.dob = event.target.value;
            var myDate = new Date(this.dataObj.dob);
            var today = new Date();
            if ( myDate > today ) {
                this.dobError = true;
            }
            else{
                this.dobError = false;
            }
        }
        else if(event.target.name === 'phoneType') {
            this.dataObj.phoneType = event.target.value;
        }
        else {
             this.dataObj[event.currentTarget.name] = event.currentTarget.value;
        }
    }

    @api    
    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        console.log('Demo isAllValid 1-'+isAllValid);

        isAllValid &= [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        console.log('Demo isAllValid 2-'+isAllValid);

        isAllValid &= [...this.template.querySelectorAll('lightning-radio-group')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);


        console.log('Demo isAllValid 3-'+isAllValid);

        valid = isAllValid;

        if(this.dobError){
            valid = false;
        }
        
        return valid;
    }

    @api
    getData(){
        let fields = {};
        fields[GENDER.fieldApiName] = this.dataObj.gender;
        fields[LASTNAME.fieldApiName] = this.dataObj.lastName;
        fields[MAILINGSTATE.fieldApiName] = this.dataObj.state;
        fields[FIRSTNAME.fieldApiName] = this.dataObj.firstName;
        fields[MAILINGSTREET.fieldApiName] = this.dataObj.street;
        fields[EMAIL.fieldApiName] = this.dataObj.email;
        fields[MIDDLENAME.fieldApiName] = this.dataObj.middleName;
        fields[COMMENTS.fieldApiName] = this.dataObj.comments;
        fields[MAILINGCITY.fieldApiName] = this.dataObj.city;
        fields[APTSUITE.fieldApiName] = this.dataObj.apartmentSuite;
        fields[PHONETYPE.fieldApiName] = this.dataObj.phoneType;
        fields[Phone.fieldApiName] = this.dataObj.telephoneNumber;
        fields[NEWEMP.fieldApiName] = (this.dataObj.newyorkEmp === 'yes');
        fields[FACILITYRES.fieldApiName] = this.dataObj.facilityofResidence;
        fields[COUNTYRES.fieldApiName] = this.dataObj.countyRes;
        fields[OCCUPATION.fieldApiName] = this.dataObj.occupation;
        fields[POSTALCODE.fieldApiName] = this.dataObj.zip;
        fields[BirthDate.fieldApiName] = this.dataObj.dob;
        
        return fields;
    }


    formatPhone(obj) {
        var numbers = obj.value.replace(/\D/g, ''),
            char = {0:'(',3:') ',6:'-'};
        obj.value = '';
        for (var i = 0; i < numbers.length; i++) {
            obj.value += (char[i]||'') + numbers[i];
        }
    }

    connectedCallback(){
        this.dataObj.state = 'New York';
    }
}