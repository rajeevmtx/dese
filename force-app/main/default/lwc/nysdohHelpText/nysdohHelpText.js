import { LightningElement, api } from 'lwc';

export default class NysdohHelpText extends LightningElement {
    @api
    helpTextForModelWindow=false;
    @api helpText;
}