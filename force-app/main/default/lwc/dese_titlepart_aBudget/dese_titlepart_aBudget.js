import { LightningElement ,track,api } from 'lwc';
import deseDesign from '@salesforce/resourceUrl/DESE_Design';
import getAllocationReservation from '@salesforce/apex/DESE_Title1Controller.getAllocationReservation';

export default class Dese_titlepart_aBudget extends LightningElement {
    @api projectId;
    
    notebook = deseDesign + '/theme/images/notebook.png';
    @track totalAllocation = 0;
    @track totalReservation = 0;
    
    @track clickedButtonLabel = 'READ MORE';
    @track readMore = false;

    connectedCallback(){
        getAllocationReservation({proposalId: this.projectId})
            .then(data => {
                console.log('Response for Budget ',data);
                this.totalAllocation = data.tile1Allocation;
                this.totalReservation = data.tile1Reservation;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
    }

    handleClick(event) {
        const label = event.target.label;
        if (label === 'READ MORE') {
            this.clickedButtonLabel = 'READ LESS';
            this.readMore = true;
        } else if (label === 'READ LESS') {
            this.clickedButtonLabel = 'READ MORE';
            this.readMore = false;
        }
    }
}