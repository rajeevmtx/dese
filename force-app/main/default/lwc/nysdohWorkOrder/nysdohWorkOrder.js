import { LightningElement, api } from 'lwc';
import Portal_Work_Order_Help_Text from '@salesforce/label/c.Portal_Work_Order_Help_Text';
export default class NysdohWorkOrder extends LightningElement {
    @api Portal_Work_Order_Help_Text= Portal_Work_Order_Help_Text;
}