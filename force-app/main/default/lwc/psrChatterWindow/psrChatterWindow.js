import { LightningElement, api } from 'lwc';
import psrCommunityApexBaseUrl from '@salesforce/label/c.Portal_vfpage_url';

export default class PsrChatterWindow extends LightningElement {
    @api recordId = "";
    @api headingLabel = "";

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    get fullUrl() {
        return psrCommunityApexBaseUrl+ 'PsrChatterPage?id=' + this.recordId;
    }


}