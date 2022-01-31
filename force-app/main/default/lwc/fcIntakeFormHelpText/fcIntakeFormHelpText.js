import { LightningElement, api } from 'lwc';

export default class FcIntakeFormHelpText extends LightningElement {
    @api
    helpTextForModelWindow=false;
    @api helpText;
}