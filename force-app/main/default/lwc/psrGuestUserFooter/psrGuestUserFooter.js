import {
    LightningElement,api
} from 'lwc';
import footerText from '@salesforce/label/c.Portal_Footer_Text';

export default class PsrGuestUserFooter extends LightningElement {
    @api footerText = footerText;
}