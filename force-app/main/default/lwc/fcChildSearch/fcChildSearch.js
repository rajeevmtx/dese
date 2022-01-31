import { LightningElement, track } from 'lwc';

export default class FcChildSearch extends LightningElement {
    @track interestedInChild1;
    @track interestedInChild2;


    handleInterestInChild1() {
        this.interestedInChild1 = true;
    }

    handleNotInterestInChild1() {
        this.interestedInChild1 = false;
    }

    handleInterestInChild2() {
        this.interestedInChild2 = true;
    }

    handleNotInterestInChild2() {
        this.interestedInChild2 = false;
    }
}