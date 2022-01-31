/**
 * @author Vishnu Kumar
 * @email vishnu.kumar@mtxb2b.com
*/
import { LightningElement, track, api } from 'lwc';

export default class Aps_thank_you_screen extends LightningElement {
    
    @track travelerHelpText = 'Thank you for submitting your case. Your application has been received and will be processed as soon as possible.	';
    @track website = '' ;
    @track claimNumberMsg = '';
    @api caseRec = {};

    handleDone(){
        location.reload();
    }
}