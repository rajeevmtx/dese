import { LightningElement,track } from 'lwc';

export default class PsrPayment extends LightningElement {
    @track value = 'inProgress';
    @track yesflag = false;
    @track noflag =false;

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        if(this.value === 'Yes'){
            this.yesflag = true;
            this.noflag = false;
        }
        else if(this.value === 'No'){
            this.yesflag = false;
            this.noflag = true;
        }

    }
}