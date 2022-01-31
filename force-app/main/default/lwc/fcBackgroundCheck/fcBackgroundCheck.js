import { LightningElement,api, track } from 'lwc';
import Portal_Submission_Submission_Message from '@salesforce/label/c.Portal_Submission_Submission_Message'; 
export default class FcBackgroundCheck extends LightningElement {
    @api Portal_Submission_Submission_Message = Portal_Submission_Submission_Message;
    @track helpText = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
    handleChange(){

    }
}