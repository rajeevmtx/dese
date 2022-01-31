/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NysDohSchedular extends LightningElement {
    agreement = `Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Convallis aenean et tortor at risus viverra. Leo vel fringilla est ullamcorper eget. Quisque sagittis purus sit amet volutpat consequat mauris nunc. Velit ut tortor pretium viverra suspendisse. Morbi tincidunt augue interdum velit euismod in. Nunc lobortis mattis aliquam faucibus purus in massa tempor nec. Quis viverra nibh cras pulvinar mattis nunc sed blandit libero. Etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus. Pharetra diam sit amet nisl suscipit adipiscing bibendum est. Euismod nisi porta lorem mollis aliquam ut porttitor leo. Risus at ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Vulputate ut pharetra sit amet aliquam id.`;

    @track reviewCheck;
    @track showThankYou = false;

    @api points;
    @api recordId;


    handleReviewCheck() {
        this.reviewCheck = true;
    }

    connectedCallback() {
        console.log('points: ', this.points);
        
    }


    @api
    handleNext() {
        if (!this.reviewCheck) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please acknowledge the terms & conditions to submit the application.',
                variant: 'error'
            }));
        } else {
            this.showThankYou = true;
        }
    }
}