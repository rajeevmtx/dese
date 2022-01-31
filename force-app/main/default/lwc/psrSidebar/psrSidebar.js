import {
    LightningElement,api
} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import footerText from '@salesforce/label/c.Portal_Footer_Text';

export default class PsrSidebar extends NavigationMixin(LightningElement) {
    @api showFooter;
    @api footerText = 'Copyright © 2020 Massachusetts Department of Elementary & Secondary Education - All rights reserved.';

    navigateToPage(event) {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                pageName: event.target.dataset.navigatepage
            }
        });
    }
}