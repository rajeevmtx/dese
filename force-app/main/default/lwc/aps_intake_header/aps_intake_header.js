import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import font_awesome_css from '@salesforce/resourceUrl/font_awesome_css';
import Oklahomalogo from '@salesforce/resourceUrl/Oklahomalogo';

export default class Aps_intake_header extends LightningElement {
    logo = Oklahomalogo;
    connectedCallback() {
        Promise.all([
            loadStyle(this, font_awesome_css + '/font_awesome_css/fontawesome.css'),
            loadStyle(this, font_awesome_css + '/font_awesome_css/fontawesome.min.css'),
        ])
        .then(() => {
            // alert('Files loaded.');
        })
        .catch(error => {
            alert(error.body.message);
        });
    }
}