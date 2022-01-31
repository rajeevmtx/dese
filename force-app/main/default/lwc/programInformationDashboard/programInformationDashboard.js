import { LightningElement, track } from 'lwc';
import desetheme from '@salesforce/resourceUrl/DESE_Design';

export default class ProgramInformationDashboard extends LightningElement {

    grantImages = desetheme + '/theme/images/grants-img.svg';
    monitoringImage = desetheme + '/theme/images/monitoring-img.svg';

    handleMonitoring(){
        window.open('https://desedemo-demo-lp.cs196.force.com/psr/s/','_self');
    }

    handleGrants(){
        window.open('/dese/s/','_self');
    }
}