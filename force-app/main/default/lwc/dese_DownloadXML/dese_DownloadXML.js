import { LightningElement,wire } from 'lwc';
import getApprovedXMLFile from '@salesforce/apex/XMLDownloadController.getApprovedXMLFile';

export default class Dese_DownloadXML extends LightningElement {
   xmlDownloadLink;

    connectedCallback(){
        getApprovedXMLFile()
        .then(data => {
            
            console.log('Connected Callback: ' + data);
        
            const sitePrefix = window.location.origin;
            window.open(sitePrefix + ('/' + data));

            //window.open(sitePrefix + ('/sfc/servlet.shepherd/document/download/' + data));

            console('Downloaded via ',sitePrefix + ('/sfc/servlet.shepherd/document/download/' + data));
        })
        .catch(error => {
            console.log('error: ', error);
        })
    }
}