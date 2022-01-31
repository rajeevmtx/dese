import { LightningElement,track ,api } from "lwc";
import deseDesign from '@salesforce/resourceUrl/DESE_Design';

export default class Dese_title4_narrative extends LightningElement {

    notebook = deseDesign + '/theme/images/notebook.png';

    @track clickedButtonLabel = 'READ MORE';
    @track readMore = false;
    @api readOnly;
    @api projectId;

    handleClick(event) {
        const label = event.target.label;
        if (label === 'READ MORE') {
            this.clickedButtonLabel = 'READ LESS';
            this.readMore = true;
        } else if (label === 'READ LESS') {
            this.clickedButtonLabel = 'READ MORE';
            this.readMore = false;
        }
    }
    get radioOptions() {
        return [
            { label: "Yes", value: "Yes" },
            { label: "No", value: "No" },
        ];
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent("next"));
    }

    handlePrev() {
        this.dispatchEvent(new CustomEvent("previous"));
    }
}