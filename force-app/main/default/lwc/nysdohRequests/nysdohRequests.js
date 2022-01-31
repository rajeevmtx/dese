/**
 * Created by arunm on 22-03-2020.
 */

import { LightningElement, track, api} from 'lwc';
import fetchRequests from '@salesforce/apex/NYSDOH_RequestController.fetchRequests';
import getCurrentUser from '@salesforce/apex/NYSDOH_RequestController.getCurrentUser';
import Portal_Work_Order_Help_Text from '@salesforce/label/c.Portal_Work_Order_Help_Text';

export default class NysdohRequests extends LightningElement {

    @track isEditModalOpel = false;
    @track isViewBidsModalOpen = false;
    @track isNewRequestModalOpen = false;
    @track requests = [];
    @track requestId = "";
    @track isSupplier = false;
    @track isHospital = false;

    @api Portal_Work_Order_Help_Text= Portal_Work_Order_Help_Text;

    constructor() {
        super();
        this.setRequests();
        this.setUserType();
    }

    setRequests() {
        fetchRequests()
            .then(res => {
                this.requests = res;
                this.requests.forEach((request) => {
                    if(request.Hospital__r) {
                        request.HospitalName = request.Hospital__r.Name;
                    }
                });
            });
    }

    setUserType() {
        getCurrentUser()
            .then(res => {
                if(res.Profile.Name == 'DOH Supplier User') {
                    this.isSupplier = true;
                }
                else if(res.Profile.Name == 'DOH Hospital User') {
                    this.isHospital = true;
                }
            });
    }

    setupNewRequest() {
        this.isNewRequestModalOpen = true;
    }

    applyBid(event) {
        this.requestId = event.target.dataset.requestId;
        this.isEditModalOpel = true;
    }

    viewBids(event) {
        this.requestId = event.target.dataset.requestId;
        this.isViewBidsModalOpen = true;
    }

    closeModal() {
        this.setRequests();
        this.isEditModalOpel = false;
        this.isViewBidsModalOpen = false;
        this.isNewRequestModalOpen = false;
    }

    handleCloseModal() {
        this.requestId = undefined;
    }
}