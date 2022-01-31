import { LightningElement, track } from 'lwc';
import getGrants from '@salesforce/apex/DESE_ProposalController.getAllGrants';
import { NavigationMixin } from 'lightning/navigation';
import deseDesign from '@salesforce/resourceUrl/DESE_Design';

export default class DeseGrantsDashboard extends NavigationMixin(LightningElement) {
    @track grantsList;

    grantImage = deseDesign + '/theme/images/grant.png';

    connectedCallback(){
        this.fetchAllGrants();
    }

    fetchAllGrants(){
        getGrants().then(data => {
            console.log(data);
            this.grantsList = JSON.parse(data);

            this.grantsList.forEach(grant => {
                grant.Name = grant.Name + ' ( ' + grant.Solicitation_Number__c + ' ) ';
            });
        }).catch(error => {console.log(error)});
    }

    handleViewDetails(event){
        var grantid = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://desedemo-demo-lp.cs196.force.com/dese/s/grants-detail?grantId=' + grantid
            }
        });
    }
}