import { LightningElement, api } from "lwc";
import deseDesign from '@salesforce/resourceUrl/DESE_Design';

export default class Dese_title_narrative extends LightningElement {
    notebook = deseDesign + '/theme/images/notebook.png';
    @api projectId;
    @api readOnly;
    value = [];

    get options() {
        return [
            { label: "Formal Agreement", value: "option1" },
            {
                label: "Budget showing how Title I Part D-2 funds will be spent",
                value: "option2",
            },
        ];
    }

    connectedCallback() {
        window.scrollTo(0, 0);
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent("next"));
        this.template.querySelector("c-dese_titlepart_ad").submitRecord();
        this.template
            .querySelector("c-dese_titlepart_a-reservation")
            .submitRecord();
        this.template
            .querySelector("c-dese_titlepart_a-school-funding")
            .submitRecord();
    }

    handlePrev() {
        this.dispatchEvent(new CustomEvent("previous"));
    }
}