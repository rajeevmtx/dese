import { LightningElement, track } from 'lwc';

export default class AllocationInstructions extends LightningElement {
    @track clickedButtonLabel = 'READ MORE';
    @track readMore = false;

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
}