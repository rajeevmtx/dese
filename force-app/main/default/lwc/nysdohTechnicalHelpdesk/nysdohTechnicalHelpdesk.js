import { LightningElement, track,api } from 'lwc';
import method from '@salesforce/apex/NysdohTechnicalHelpdeskController.createCase';
import Portal_Work_Order_Help_Text from '@salesforce/label/c.Portal_Work_Order_Help_Text';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class NysdohTechnicalHelpdesk extends LightningElement {
    @api Portal_Work_Order_Help_Text= Portal_Work_Order_Help_Text;
   @track subject = '';
   @track priority = 'Low';
   @track description = '';

    changeHandler(event) {
    const field = event.target.name;
    if (field === 'Priority') {
            this.priority = event.target.value;
            console.log("you have selected : ",this.priority);
        } 
    }
    handleFormInputChange(event){
        if( event.target.name == 'Subject' ){
           this.subject = event.target.value;
        }
        if( event.target.name == 'Description' ){
            this.description = event.target.value;
        }
    }
    
   handleClick(){
       console.log('Ín the BED');
       console.log('this.subject>>' + this.subject);
       console.log('tihs.priority>>' + this.priority);
       console.log('this.description>>' + this.description);
    method({subject: this.subject, priority: this.priority, description: this.description})
    .then(result => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Case Created Successfully',
                variant: 'success',
            }),
        );
    })
    .catch(error => {
        this.error = error;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error while Cretaing Case',
                message: error.message,
                variant: 'error',
            }),
        );
        this.accounts = undefined;
    });
    this.clearData();
   }

   clearData(){
    console.log('In Clear Data');
    this.subject = '';
    this.description = '';
    this.priority = 'Low';
   }
}