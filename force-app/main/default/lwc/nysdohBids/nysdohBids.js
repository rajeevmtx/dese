/**
 * Created by arunm on 22-03-2020.
 */

import { LightningElement, track, api} from 'lwc';
import fetchBids from '@salesforce/apex/NYSDOH_RequestController.fetchBids';
import Portal_Work_Order_Help_Text from '@salesforce/label/c.Portal_Work_Order_Help_Text';

export default class NysdohBids extends LightningElement {

    @api requestId = "";
    @track bids = [];
    @api Portal_Work_Order_Help_Text= Portal_Work_Order_Help_Text;

    constructor() {
        super();
        this.setBids();
    }

    setBids() {
        fetchBids({ requestId: this.requestId }).then(res => {
            this.bids = res;
        });
    }

    handleCloseModal() {
        const selectedEvent = new CustomEvent("closemodal", {
            detail: ""
        });
        this.dispatchEvent(selectedEvent);
    }
}