import { LightningElement, track, api } from 'lwc';

export default class MtxInstructionsPage extends LightningElement {
    // @api instructionsHelpText = "Passengers arriving from travel to China in the prior 14 days are being screened by the Centers for Disease Control and Prevention (CDC) at the airport to ensure they do not have any symptoms consistent with the 2019 novel coronavirus (2019-nCoV) at the time of arrival at the airport. If individuals do not have symptoms consistent with 2019-nCoV, they will be released to their final destination, under the monitoring of local health.";
    @api instructionsHelpText = 'Velit ut tortor pretium viverra suspendisse. Morbi tincidunt augue interdum velit euismod in. Nunc lobortis mattis aliquam faucibus purus in massa tempor nec. Quis viverra nibh cras pulvinar mattis nunc sed blandit libero. Etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus. Pharetra diam sit amet nisl suscipit adipiscing bibendum est. Euismod nisi porta lorem mollis aliquam ut porttitor leo. Risus at ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Vulputate ut pharetra sit amet aliquam id.';

    goNext(event) {
        this.dispatchEvent(new CustomEvent('next'));
    }
}