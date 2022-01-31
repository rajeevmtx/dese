import { LightningElement,api } from 'lwc';

export default class PsrHelpText extends LightningElement {

    @api
    helpTextForModelWindow=false;
    @api helpText;
}