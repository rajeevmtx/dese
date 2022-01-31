import { LightningElement, api } from 'lwc';

export default class EachLookup extends LightningElement {
    @api index;
    @api label;
    @api selectedSet;

    get hideSelectedPicklist() {
        return this.selectedSet.has(this.label) ? 'pointer-events:none !important; opacity:0.3 !important;' : null;
    }

    handleSelectPicklist(event) {
        try {
            let selection = event.currentTarget.getAttribute('data-index');
            const eventNow = new CustomEvent('thispicklist', {
                detail: { selection }
            });
            this.dispatchEvent(eventNow);
        } catch (error) {
            console.log('error in child: ', error);
        }

    }
}