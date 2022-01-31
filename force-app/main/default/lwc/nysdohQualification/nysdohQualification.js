import { LightningElement, track, api} from 'lwc';
import fetchPicklist from '@salesforce/apex/NYSDOH_RegistrationController.fetchPicklist';
import Qualification from '@salesforce/label/c.Qualification';
export default class NysdohQualification extends LightningElement {

    @track showSpinner = false;
    @track healthCare = true;
    @track other = false;
    @track medicalProfesionals = [];
    @track licenses = [];
    @track skills = [];
    @track showQualification = Qualification;
    @api volunteer = {};

    handlesubmit(event) {
        event.preventDefault(event);
        const fields = event.detail.fields;
        let vol = JSON.parse(JSON.stringify(this.volunteer));
        vol.Current_Status_In_The_Field__c = fields.Current_Status_In_The_Field__c;
        vol.I_Practiced_Most_Recently_As__c = fields.I_Practiced_Most_Recently_As__c;
        vol.Last_Practice_Date__c = fields.Last_Practice_Date__c;
        vol.State__c = fields.State__c;
        vol.Speciality__c = fields.Speciality__c;
        vol.Licenses_Certifications__c = fields.Licenses_Certifications__c;
        vol.Other_Services__c = fields.Other_Services__c;
        fields.Status__c = 'Submitted';
        this.volunteer = vol;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.dispatchEvent(new CustomEvent('next', {
            detail: this.volunteer
        }));
    }

    handleCHKBK1Change(event) {
        this.other = false;
        this.healthCare = event.target.checked;
    }
    handleCHKBK2Change(event) {
        this.healthCare = false;
        this.other = event.target.checked;
    }

    goBack(){
        this.dispatchEvent(new CustomEvent('prev', {
            detail: this.volunteer
        }));
    }

}