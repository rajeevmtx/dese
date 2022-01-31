import { LightningElement, track } from "lwc";

export default class PsrSubmitNotification extends LightningElement {
    @track step1 = true;
    @track step2 = false;

    get options() {
        return [
            { label: "New", value: "new" },
            { label: "In Progress", value: "inProgress" },
            { label: "Finished", value: "finished" },
        ];
    }
    goToStep2() {
        this.step1 = false;
        this.step2 = true;
    }
    goToStep1() {
        this.step1 = true;
        this.step2 = false;
    }
    goToHome() {
        window.open("/psr/s/", "_self");
    }
}