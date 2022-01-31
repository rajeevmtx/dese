import { LightningElement,api } from 'lwc';

export default class Aps_help_text extends LightningElement {

    @api
    helpTextForModelWindow=false;
    @api helpText;
}