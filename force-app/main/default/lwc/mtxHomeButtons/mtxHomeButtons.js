import { LightningElement, track } from 'lwc';
import RequestConsent from '@salesforce/apex/DC_HomeButtonsController.RequestConsent';
import RequestFollowUp from '@salesforce/apex/DC_HomeButtonsController.RequestFollowUp';
import { showSuccessMessage, showAjaxErrorMessage } from 'c/dc_utils';

export default class MtxHomeButtons extends LightningElement {
    @track isShowRequestConsentModal = false;
    @track isShowFollowUpModal = false;

    showRequestConsentConfirmModal(){
        this.isShowRequestConsentModal = true;
    }

    hideRequestConsentConfirmModal(){
        this.isShowRequestConsentModal = false;
    }

    showFollowUpConfirmModal(){
        this.isShowFollowUpModal = true;
    }

    hideFollowUpConfirmModal(){
        this.isShowFollowUpModal = false;
    }

    handleRequestConsent() {
        RequestConsent()
            .then(result => {
                showSuccessMessage(this, 'Job placed successfully.');
                this.hideRequestConsentConfirmModal();
            })
            .catch(error => {
                showAjaxErrorMessage(error);
            });
    }

    handleRequestFollowUp() {
        RequestFollowUp()
            .then(result => {
                showSuccessMessage(this, 'Job placed successfully.');
                this.hideFollowUpConfirmModal();
            })
            .catch(error => {
                showAjaxErrorMessage(error);
            });
    }
}