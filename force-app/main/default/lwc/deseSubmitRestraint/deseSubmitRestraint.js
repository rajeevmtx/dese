import { LightningElement } from 'lwc';

export default class DeseSubmitRestraint extends LightningElement {
    get options() {
        return [
            { label: "New", value: "new" },
            { label: "In Progress", value: "inProgress" },
            { label: "Finished", value: "finished" },
        ];
    }
    goToHome() {
        window.open("/dese/s/", "_self");
    }
}