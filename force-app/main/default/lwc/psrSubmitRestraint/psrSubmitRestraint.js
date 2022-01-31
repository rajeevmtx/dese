import { LightningElement } from "lwc";

export default class PsrSubmitRestraint extends LightningElement {
    get options() {
        return [
            { label: "New", value: "new" },
            { label: "In Progress", value: "inProgress" },
            { label: "Finished", value: "finished" },
        ];
    }
    goToHome() {
        window.open("/psr/s/", "_self");
    }
}