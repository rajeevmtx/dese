import { LightningElement, track, wire, api } from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import SIGN_EMOTIONAL from '@salesforce/schema/Case.Signs_of_Emotional_Injury__c';
import SIGN_NEGLECT from '@salesforce/schema/Case.Signs_of_Neglect__c';
import SIGN_PHYSICAL from '@salesforce/schema/Case.Signs_of_Physical_Abuse__c';
import SIGN_SEXUAL from '@salesforce/schema/Case.Signs_of_Sexual_Abuse__c';

import CASE_OBJECT from "@salesforce/schema/Case";


export default class FcNeglectAndAbuse extends LightningElement {
    @track helpTextVerification = 'Please indicate if you are aware of any of the following signs of abuse:';

    @track abusePageData = {
        signsPhysicalAbuse: '',
        signsEmotionalInjury: '',
        signsSexualAbuse: '',
        singsNeglect: '',
        description: ''
    };

    @track signsPhysicalAbuse
        = [
            { label: "Wounds that can't be explained", value: "Wounds that can't be explained" },
            { label: "Injuries on the back, neck, face", value: "Injuries on the back, neck, face" },
            { label: "Repeated injuries", value: "Repeated injuries" },
            { label: "Withdrawn, fearful or extreme behaviour", value: "Withdrawn, fearful or extreme behaviour" }
        ]

    @track signsEmotionalInjury
        = [
            { label: "Inability to play as most children do", value: "Inability to play as most children do" },
            { label: "Sleep problems", value: "Sleep problems" },
            { label: "Antisocial behaviour", value: "Antisocial behaviour" },
            { label: "behavioural extremes", value: "behavioural extremes" },
            { label: "Lags in emotional/intellectual growth", value: "Lags in emotional/intellectual growth" },
            { label: "Self destructive feelings or behaviour", value: "Self destructive feelings or behaviour" }
        ]

    @track signsSexualAbuse
        = [
            { label: "Difficulty walking or sitting", value: "Difficulty walking or sitting" },
            { label: "Pain or itching in the genital area", value: "Pain or itching in the genital area" },
            { label: "Torn, stained or bloody underclothing", value: "Torn, stained or bloody underclothing" },
            { label: "Complaints of stomachaches/headaches", value: "Complaints of stomachaches/headaches" },
            { label: "Chronic depression", value: "Chronic depression" },
            { label: "Withdrawal", value: "Withdrawal" },
            { label: "Feeling threatened by physical contact", value: "Feeling threatened by physical contact" },
            { label: "Premature understanding of sex", value: "Premature understanding of sex" },
            { label: "Running away from home", value: "Running away from home" }
        ]

    @track singsNeglect
        = [
            { label: "Chronically dirty", value: "Chronically dirty" },
            { label: "Chronic school absences", value: "Chronic school absences" },
            { label: "Dress inadequate for weather", value: "Dress inadequate for weather" },
            { label: "Left alone at home/without supervision", value: "Left alone at home/without supervision" },
            { label: "Left in the care of siblings too young", value: "Left in the care of siblings too young" },
            { label: "Often fatigued/falling asleep in school", value: "Often fatigued/falling asleep in school" },
            { label: "Hunger", value: "Hunger" },
            { label: "Self destructive feelings or behaviour", value: "Self destructive feelings or behaviour" },
        ]


    // @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    // objectInfo;

    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SIGN_EMOTIONAL })
    // statePicklistWired({ error, data }) {
    //     if (error) {
    //         console.log('Error while loading state picklist values --> ' + JSON.stringify(error));
    //     } else if (data) {
    //         let result = data;
    //         let picklists = [];
    //         for (let val in result.values) {
    //             if (result.values.hasOwnProperty(val)) {
    //                 picklists.push({ label: result.values[val].label, value: result.values[val].value })
    //             }
    //         }
    //         this.signsEmotionalInjury = picklists;
    //         //console.log('statePicklistValues --> '+JSON.stringify(this.statePicklistValues));
    //         console.log('SIGN_EMOTIONAL ---> '+JSON.stringify(picklists));

    //     }
    // }

    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SIGN_NEGLECT })
    // statePicklistWired({ error, data }) {
    //     if (error) {
    //         console.log('Error while loading state picklist values --> ' + JSON.stringify(error));
    //     } else if (data) {
    //         //console.log('State Picklist values ---> '+JSON.stringify(data));
    //         let result = data;
    //         let picklists = [];
    //         for (let val in result.values) {
    //             if (result.values.hasOwnProperty(val)) {
    //                 picklists.push({ label: result.values[val].label, value: result.values[val].value })
    //             }
    //         }
    //         this.singsNeglect = picklists;
    //         //console.log('statePicklistValues --> '+JSON.stringify(this.statePicklistValues));
    //         console.log('SIGN_NEGLECT ---> '+JSON.stringify(picklists));

    //     }
    // }

    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SIGN_SEXUAL })
    // statePicklistWired({ error, data }) {
    //     if (error) {
    //         console.log('Error while loading state picklist values --> ' + JSON.stringify(error));
    //     } else if (data) {
    //         let result = data;
    //         let picklists = [];
    //         for (let val in result.values) {
    //             if (result.values.hasOwnProperty(val)) {
    //                 picklists.push({ label: result.values[val].label, value: result.values[val].value })
    //             }
    //         }
    //         this.signsSexualAbuse = picklists;
    //         console.log('SIGN_SEXUAL ---> '+JSON.stringify(picklists));
    //         //console.log('statePicklistValues --> '+JSON.stringify(this.statePicklistValues));
    //     }
    // }

    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SIGN_PHYSICAL })
    // statePicklistWired({ error, data }) {
    //     if (error) {
    //         console.log('Error while loading state picklist values --> ' + JSON.stringify(error));
    //     } else if (data) {
    //         //console.log('State Picklist values ---> '+JSON.stringify(data));
    //         let result = data;
    //         let picklists = [];
    //         for (let val in result.values) {
    //             if (result.values.hasOwnProperty(val)) {
    //                 picklists.push({ label: result.values[val].label, value: result.values[val].value })
    //             }
    //         }
    //         this.signsPhysicalAbuse = picklists;
    //         //console.log('statePicklistValues --> '+JSON.stringify(this.statePicklistValues));
    //         console.log('SIGN_PHYSICAL ---> '+JSON.stringify(picklists));

    //     }
    // }

    handleIncomingData(event) {
        // console.log('check in parent --> ', JSON.stringify(event.detail));
        this.abusePageData = { ...event.detail };
        this.toParent();
    }

    handleDescription(event) {
        this.abusePageData[event.target.dataset.field] = event.target.value;
        this.toParent();
    }

    toParent() {
        const eventNow = new CustomEvent('abusedata', {
            detail: { ...this.abusePageData }
        });
        this.dispatchEvent(eventNow);
    }
}