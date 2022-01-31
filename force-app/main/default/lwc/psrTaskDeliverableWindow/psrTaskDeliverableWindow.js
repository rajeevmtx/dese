import { LightningElement,api } from 'lwc';
import psrCommunityApexBaseUrl from '@salesforce/label/c.Portal_vfpage_url';

export default class PsrTaskDeliverableWindow extends LightningElement {
    @api recordId ;
    @api headingLabel = "";

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    get fullUrl() {
        console.log('Record Id in TD' + this.recordId);
        // return psrCommunityApexBaseUrl+ 'CORE_Deliverables_Page?id=a3i030000008Qev';
        //return 'https://desedemo-demo-lp.cs196.force.com/psr/apex/CORE_Deliverables_Page?id=a3i030000008Qev';
        return 'https://desedemo-demo-lp.cs196.force.com/psr/apex/CORE_Deliverables_Page?id='+this.recordId;
    }
}