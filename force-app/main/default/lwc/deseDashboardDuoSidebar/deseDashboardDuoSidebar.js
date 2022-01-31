import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class DeseDashboardDuoSidebar extends NavigationMixin(
    LightningElement
) {
    @api selectedTab;
    @api showFooter;
    @api footerText =
        "Copyright © 2020 Massachusetts Department of Elementary & Secondary Education - All rights reserved.";

    navigateToPage(event) {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                pageName: event.target.dataset.navigatepage,
            },
        });
    }
}