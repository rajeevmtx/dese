import {
    LightningElement,
    track,
    wire,
    api
} from "lwc";

import saveApp from '@salesforce/apex/PsrNewPermitController.addNewApplication';
import saveAppl from '@salesforce/apex/fcNewLicenseController.addNewApplication';
import isFosterCare from '@salesforce/apex/PsrNewPermitController.isFosterCare';
import Portal_Installation_Help_Text from '@salesforce/label/c.Portal_Installation_Help_Text';
import Portal_Foundation_Help_Text from '@salesforce/label/c.Portal_Foundation_Help_Text';
import Portal_Machanical_Help_Text from '@salesforce/label/c.Portal_Machanical_Help_Text';
import Portal_Electrical_Help_Text from '@salesforce/label/c.Portal_Electrical_Help_Text';
import Portal_Repair_Help_Text from '@salesforce/label/c.Portal_Repair_Help_Text';
import Portal_Refurbish_Help_Text from '@salesforce/label/c.Portal_Refurbish_Help_Text';
import Portal_Cancel_Permit_Help_Text from '@salesforce/label/c.Portal_Cancel_Permit_Help_Text';
import Portal_Request_Change_of_Address_Help_Text from '@salesforce/label/c.Portal_Request_Change_of_Address_Help_Text';
import Portal_Request_Duplicate_Permit_Help_Text from '@salesforce/label/c.Portal_Request_Duplicate_Permit_Help_Text';
export default class FcLicenseSelection extends LightningElement {
    @track showFosterPermit;

    @api Portal_Installation_Help_Text = Portal_Installation_Help_Text;
    @api Portal_Foundation_Help_Text = Portal_Foundation_Help_Text;
    @api Portal_Machanical_Help_Text = Portal_Machanical_Help_Text;
    @api Portal_Electrical_Help_Text = Portal_Electrical_Help_Text;
    @api Portal_Repair_Help_Text = Portal_Repair_Help_Text;
    @api Portal_Refurbish_Help_Text = Portal_Refurbish_Help_Text;
    @api Portal_Cancel_Permit_Help_Text = Portal_Cancel_Permit_Help_Text;
    @api Portal_Request_Duplicate_Permit_Help_Text = Portal_Request_Duplicate_Permit_Help_Text;
    @api Portal_Request_Change_of_Address_Help_Text = Portal_Request_Change_of_Address_Help_Text;

    handleNewApplication(event) {
        let _appId;
        // let permitType = event.currentTarget.dataset.permitType;
        let permitType = 'Foster Care';

        saveAppl({})
            .then(result => {
                window.console.log('result ===> ' + result);
                _appId = result;
                window.open(`/fc/s/fc-application?appId=${_appId}`, "_self");
                // Show success messsage
                // this.dispatchEvent(new ShowToastEvent({
                //     title: 'Success!!',
                //     message: 'New Application Created Successfully!!',
                //     variant: 'success'
                // }),);
            })
            .catch(error => {
                this.error = error.message;
            });
    }


    handleBackgroundRecordCheck(){

    }
    // cancelPermit() {
    //     window.open(`/psr/s/cancel-permit`, "_self");
    // }

    // requestDuplicatePermit() {
    //     window.open(`/psr/s/request-duplicate-permit`, "_self");
    // }

    // requestChangeOfAddress() {
    //     window.open(`/psr/s/request-address-change`, "_self");
    // }

    // handleFosterNewPermit(event) {
    //     let _appId;
    //     let permitType = event.currentTarget.dataset.permitType;

    //     saveApp({
    //             permitType: permitType
    //         })
    //         .then(result => {
    //             window.console.log('result ===> ' + result);
    //             _appId = result;
    //             window.open(`/psr/s/psrfosternewpermit?appId=${_appId}`, "_self");
    //         })
    //         .catch(error => {
    //             this.error = error.message;
    //         });
    // }

    connectedCallback() {
        isFosterCare()
            .then(result => {
                this.showFosterPermit = result;
                console.log('this.showFosterPermit>' + this.showFosterPermit);
            })
            .catch(error => {
                JSON.stringify('ERROR>' + error);
                this.error = error.message;
            });
    }

}