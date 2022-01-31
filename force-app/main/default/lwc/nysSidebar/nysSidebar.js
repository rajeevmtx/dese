/**
 * Created by arunm on 22-03-2020.
 */

import { LightningElement,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import footerText from '@salesforce/label/c.Portal_Footer_Text';

export default class NysSidebar extends LightningElement {
    @api showFooter;
    @api footerText = footerText;

    navigateToPage(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: event.target.dataset.navigatepage
            }
        });
    }
}