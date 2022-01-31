import { LightningElement, track } from 'lwc';

export default class MtxThankYouScreen extends LightningElement {
    @track travelerHelpText = "We will review your Information momentarily. In case of any additional information needed, we will be reaching out to you via text or voice call.";
    handleDone(){
        location.reload();
    }
}