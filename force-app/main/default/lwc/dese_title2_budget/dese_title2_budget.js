import { LightningElement, api, track } from "lwc";
import deseDesign from '@salesforce/resourceUrl/DESE_Design';
import getAllocationReservation from '@salesforce/apex/DESE_Title1Controller.getAllocationReservation';

export default class Dese_title2_budget extends LightningElement {

    notebook = deseDesign + '/theme/images/notebook.png';
    @api readOnly;
    @api projectId;
    @track clickedButtonLabel = 'READ MORE';
    @track readMore = false;

    @track totalAllocation = 0;
    @track totalReservation = 0;
   
     connectedCallback(){
        getAllocationReservation({proposalId: this.projectId})
            .then(data => {
                console.log('Response for Budget ',data);
                this.totalAllocation = data.tile2Allocation;
                this.totalReservation = data.tile2Reservation + data.tile2Reservation2;
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