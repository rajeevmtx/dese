import { LightningElement,track,api } from 'lwc';

import instructionsHelpText from '@salesforce/label/c.NYS_DOH_Instruction_Help_Text';
import instructionsText from '@salesforce/label/c.NYS_DOH_Instruction_Detail';

export default class NysdohInstructionsPage extends LightningElement {

    @track instructionsHelpText = instructionsHelpText;
    @track instructionsText = instructionsText;
    @api volunteer = {};
    goNext(event) {
        this.dispatchEvent(new CustomEvent('next', {
            detail: this.volunteer
        }));
    }
}