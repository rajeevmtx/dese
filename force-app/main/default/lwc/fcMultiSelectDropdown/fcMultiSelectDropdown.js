/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';

// import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import { getObjectInfo } from 'lightning/uiObjectInfoApi';

// import CONTACT_OBJECT from "@salesforce/schema/Contact";
// import STATE_FIELD from "@salesforce/schema/Contact.MailingStateCode";

export default class FcMultiSelectDropdown extends LightningElement {
    @track showPicklist;
    @track statePicklistValues;
    @track selectedStatesArray = new Set();
    @track selectedStates = '';
    @api pastStates;

    @api picklistLabel;

    @api keyNow;
    @track abusePageDataNew;
    @api
    get abusePageData() {
        return this.abusePageDataNew;
    }
    set abusePageData(value) {
        this.abusePageDataNew = value;
    }

    // connectedCallback() {
    //     console.log('pastStates: ', JSON.stringify(this.pastStates));
    // }

    // CONTACT_OBJECT = CONTACT_OBJECT;


    // @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    // objectInfo;

    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATE_FIELD })
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

    //         this.statePicklistValues = picklists;
    //         //console.log('statePicklistValues --> '+JSON.stringify(this.statePicklistValues));

    //     }
    // }

    handleShowPicklist() {
        // alert('show');
        this.showPicklist = !this.showPicklist;
    }

    handleSelectPicklist(event) {

        try {
            console.log('log in parent: ', JSON.stringify(event.detail.selection));

            let selection = event.detail.selection;
            this.showPicklist = false;

            // console.log('log in parent: ', selection);


            //console.log('selected picklist --> ' + this.selectedStates.length);

            if (this.selectedStates.length === 0) {
                this.selectedStates = this.selectedStates + this.pastStates[selection].label;
                //console.log('this.selectedStates ---> '+this.selectedStates);

            } else if (this.selectedStates.length > 0) {
                this.selectedStates = this.selectedStates + ';' + this.pastStates[selection].label;
            }
            //console.log('this.selectedStates --- ' + this.selectedStates);

            this.selectedStatesArray.add(this.pastStates[selection].label);
            //console.log('this.selectedStatesArray --- ' + JSON.stringify(this.selectedStatesArray));

            let picklistArrayTo = Array.from(this.selectedStatesArray);
            let finalString = '';
            for (let key in picklistArrayTo) {
                if (picklistArrayTo.hasOwnProperty(key)) {
                    finalString = finalString + picklistArrayTo[key] + ';';
                }
            }
            let abusePageDataNew = { ...this.abusePageDataNew };
            abusePageDataNew[this.keyNow] = finalString;
            const eventNow = new CustomEvent('abusepagedata', {
                detail: { ...abusePageDataNew }
            });
            this.dispatchEvent(eventNow);

        } catch (error) {
            console.log('error in parent: ', error);
        }


    }

    handlePicklistRemove(event) {
        let toRemove = event.currentTarget.getAttribute('data-picklist');
        this.selectedStatesArray.delete(toRemove);
        this.showPicklist = false;

        let picklistArrayTo = Array.from(this.selectedStatesArray);
        let finalString = '';
        for (let key in picklistArrayTo) {
            if (picklistArrayTo.hasOwnProperty(key)) {
                finalString = finalString + picklistArrayTo[key] + ';';
            }
        }
        let abusePageDataNew = { ...this.abusePageDataNew };
        abusePageDataNew[this.keyNow] = finalString;
        const eventNow = new CustomEvent('abusepagedata', {
            detail: { ...abusePageDataNew }
        });
        this.dispatchEvent(eventNow);
    }
}