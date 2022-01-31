import { LightningElement , api} from 'lwc';

export default class PsrModal extends LightningElement {
    @api hideFooter = false;
    @api hideHeader = false;
    @api headerclass = "slds-modal__header";
    @api bodyclass= "slds-modal__content slds-p-around_medium";
    @api footerclass ="slds-modal__footer";
    @api backdropClass = "slds-backdrop slds-backdrop_open zindex9001";
    @api modalStyle;
    @api isDarkMode;
    
    @api classes = 'slds-modal newModal slds-fade-in-open zindex9002';
}