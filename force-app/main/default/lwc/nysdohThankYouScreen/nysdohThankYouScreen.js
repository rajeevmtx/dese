import { LightningElement, track } from 'lwc';

import personalInfoHelpText from '@salesforce/label/c.NYS_DOH_Thank_You_Message';
export default class MtxThankYouScreen extends LightningElement {
    @track personalInfoHelpText = personalInfoHelpText;
    @track travelerHelpText = "We will review your Information momentarily. In case of any additional information needed, we will be reaching out to you via text or voice call.";
    handleDone(){
        location.href = '/NYSDOH/s/';
    }
}