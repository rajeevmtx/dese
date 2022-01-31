import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllTestAccounts from '@salesforce/apex/NysDohGetAllAccounts.getAllTestAccounts';

export default class NysDohAcknoledgmentPage extends LightningElement {
    @api location;
    @api timeslot;
    @track isOpenModal = false;
    @track accounts;
    @track displaySchedulerButton =false;
    @track reviewCheck;
    @track showThankYou = false;
    @track accountvalue;
    @track items = []; //this will hold key, value pair
    @track value = ''; //initialize combo box value
    @track chosenValue = '';
    @api points;
    @api isShowSchedulingOption;
    
    agreement = `Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Convallis aenean et tortor at risus viverra. Leo vel fringilla est ullamcorper eget. Quisque sagittis purus sit amet volutpat consequat mauris nunc. Velit ut tortor pretium viverra suspendisse. Morbi tincidunt augue interdum velit euismod in. Nunc lobortis mattis aliquam faucibus purus in massa tempor nec. Quis viverra nibh cras pulvinar mattis nunc sed blandit libero. Etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus. Pharetra diam sit amet nisl suscipit adipiscing bibendum est. Euismod nisi porta lorem mollis aliquam ut porttitor leo. Risus at ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Vulputate ut pharetra sit amet aliquam id.`;

    @wire(getAllTestAccounts)
    wiredUserRoles({ error, data }) {
        let i = 0;
        
        if (data) {
            console.log('data=>', JSON.stringify(data));
            for(i=0; i<data.length; i++)  {
                this.items = [...this.items ,{value: data[i].Id , label: data[i].Name} ];                                   
            }                
        } else if (error) {
            console.log('error>>'+JSON.stringify(error));
            //this.error = error;
        }
    }
    get accountOption() {
        return this.items;
    }


    // connectedCallback() {
    //     console.log('inside connected callback');
    //     this.getAccounts();
    // }
    handleChange(event){
        this.accountvalue = event.target.value;

        if(this.accountvalue){
            this.displaySchedulerButton =true;
        }
    }

    handleReviewCheck() {
        this.reviewCheck = true;
    }
    handleOpenModal() {
        this.isOpenModal = true;
    }

    @track timeslot = '';
    @track slotId = '';
    handleslotselect(event){
        console.log('==timeslot='+JSON.stringify(event.detail.slotTime) );
        console.log('==slotId='+JSON.stringify(event.detail.slotId) );

        this.timeslot = event.detail.slotTime;
        this.slotId = event.detail.slotId;
    }

    justCloseModal(){
        this.isOpenModal = false;
    }
   
    handleCloseModal() {
        this.slotTime = '';
        this.slotId = '';
        this.isOpenModal = false;
    }

    // getAccounts(){
    //     getAllTestAccounts()
    //     .then(result =>{
    //         console.log('accounts=>', JSON.stringify(result));
    //         // this.accounts = result];
    //         // this.accounts.map(el => {
    //         //     return {
    //         //         label: el.Name,
    //         //         value: el.Id
    //         //     }
    //         // })
    //         if(result){
    //             let i=0;
    //             for(i=0; i<result.length; i++)  {
    //                 this.accounts = [...this.items ,{value: result[i].Id , label: result[i].Name} ];                                   
    //             }   
    //         }
    //         console.log('account options=>', JSON.stringify(this.accounts));
    //     }).catch(error =>{
    //         console.log('error: ', error);
    //     })
    // }
    

    @api
    handleNext() {
        if (this.reviewCheck) {
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