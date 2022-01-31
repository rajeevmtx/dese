import { api, LightningElement } from 'lwc';

export default class Dese_overview extends LightningElement {
    @api projectId=''

    @api readOnly;
    handleNext(){
        this.dispatchEvent(new CustomEvent('next'));
    }

    handleClick(event){
        window.history.back();
    }
}