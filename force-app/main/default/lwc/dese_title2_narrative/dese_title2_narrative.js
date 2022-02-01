import { LightningElement, api } from "lwc";
import deseDesign from '@salesforce/resourceUrl/DESE_Design';

export default class Dese_title2_narrative extends LightningElement {
    notebook = deseDesign + '/theme/images/notebook.png';
    @api readOnly;
    @api projectId;
    get radioOptions() {
        return [
            { label: "Yes", value: "Yes" },
            { label: "No", value: "No" },
        ];
    }
    connectedCallback() {
        window.scrollTo(0, 0);
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent("next"));
    }

    handlePrev() {
        this.dispatchEvent(new CustomEvent("previous"));
    }
}