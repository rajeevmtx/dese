/**
 * Created by hardikranjan on 22/03/20.
 */

import { LightningElement, track, wire, api } from 'lwc';

export default class NycDohIntakeRequestInstructions extends LightningElement {

    // @api instructionsHelpText = "Passengers arriving from travel to China in the prior 14 days are being screened by the Centers for Disease Control and Prevention (CDC) at the airport to ensure they do not have any symptoms consistent with the 2019 novel coronavirus (2019-nCoV) at the time of arrival at the airport. If individuals do not have symptoms consistent with 2019-nCoV, they will be released to their final destination, under the monitoring of local health.";

    // @api instructionsHelpText = 'Velit ut tortor pretium viverra suspendisse. Morbi tincidunt augue interdum velit euismod in. Nunc lobortis mattis aliquam faucibus purus in massa tempor nec. Quis viverra nibh cras pulvinar mattis nunc sed blandit libero. Etiam dignissim diam quis enim lobortis scelerisque fermentum dui faucibus. Pharetra diam sit amet nisl suscipit adipiscing bibendum est. Euismod nisi porta lorem mollis aliquam ut porttitor leo. Risus at ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Vulputate ut pharetra sit amet aliquam id.';
    @api instructionsHelpText = 'New York State has established COVID-19 testing sites for high risk populations to be tested. Please fill out the brief questionnaire and as testing becomes available in your area you will be contacted and scheduled at a testing site. Please note, New York State is prioritizing testing for symptomatic health care workers, individuals associated with a nursing home and adult care facilities and those who have been in close contact with a confirmed positive case. For more information regarding COVID-19 please visit https://coronavirus.health.ny.gov/home.';
}