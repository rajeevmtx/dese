import { LightningElement, track, api} from 'lwc';
import fetchMyWorkOrders from '@salesforce/apex/PSR_ApplicationWorkOrderController.fetchMyWorkOrders';
import Portal_Work_Order_Help_Text from '@salesforce/label/c.Portal_Work_Order_Help_Text';

export default class PsrMyWorkOrders extends LightningElement {
    @track isEditModalOpel = false;
    @track isChatterModalOpen = false;
    @track cases = [];
    @track workOrders = [];
    @track workOrderId = "";
    @track isShowInspectionModal = false;
    @api Portal_Work_Order_Help_Text= Portal_Work_Order_Help_Text;
    
    constructor() {
        super();
        this.setWorkOrders(); 
    }
    setWorkOrders() {
        fetchMyWorkOrders()
            .then(res => {
                this.workOrders = res;
            });
    }
    editWorkOrder(event) {
        this.workOrderId = event.target.dataset.workOrderId;
        this.isEditModalOpel = true;
    }
    closeModal() {
        this.setWorkOrders();
        this.isEditModalOpel = false;
        this.isChatterModalOpen = false;
    }
    openChatter(event) {
        console.log("das;lkjdaslkdlasjdsa");
        this.workOrderId = event.target.dataset.workOrderId;
        this.isChatterModalOpen = true;
    }
    openApplication(event) {
        //
        let applicationId = event.target.dataset.applicationId;
        let url0 = window.location.protocol+'//'+window.location.hostname;
        let url = '/psr/s/psrnewpermit?currentstep=5&appId=';
        //The following comment out was before fixing issue
        //var url = 'https://demo-lp.force.com/psr/s/psrnewpermit?currentstep=5&appId=';

        window.open(`${url0}${url}${applicationId}`, '_self');
    }
    handleInspectionModal(event) {
        this.workOrderId = event.currentTarget.dataset.id;
        this.isShowInspectionModal = true;
    }
    handleCloseModal() {
        this.workOrderId = undefined;
        this.isShowInspectionModal = false;
    }
}