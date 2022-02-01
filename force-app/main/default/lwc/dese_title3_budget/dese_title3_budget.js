import { LightningElement,api ,track } from 'lwc';
import deseDesign from '@salesforce/resourceUrl/DESE_Design';
import getAllocationReservation from '@salesforce/apex/DESE_Title1Controller.getAllocationReservation';

export default class Dese_title3_budget extends LightningElement {
    notebook = deseDesign + '/theme/images/notebook.png';
    @api readOnly;
    @api projectId;
    @track clickedButtonLabel = 'READ MORE';
    @track readMore = false;
     @track showSpinner = false;


    @track totalAllocation = 0;
    @track totalReservation = 0;

    connectedCallback(){
        this.showSpinner = true;
        getAllocationReservation({proposalId: this.projectId})
            .then(data => {
                console.log('Response for Budget ',data);
                this.totalAllocation = data.tile3Allocation;
                this.totalReservation = data.tile3Reservation && data.tile3Reservation3 ? data.tile3Reservation + data.tile3Reservation3 : 0;
                 this.showSpinner = false;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
                 this.showSpinner = false;
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