import { LightningElement, track } from 'lwc';
import getCurrentUser from '@salesforce/apex/NYSDOH_RequestController.getCurrentUser';

import Supplier_Portal_Home_page_Header from '@salesforce/label/c.Supplier_Portal_Home_page_Header';
import Supplier_Portal_Home_Page_Help_Text from '@salesforce/label/c.Supplier_Portal_Home_Page_Help_Text';




export default class NysdohAutorizedSideBar extends LightningElement {
    Supplier_Portal_Home_page_Header = Supplier_Portal_Home_page_Header;
    Supplier_Portal_Home_Page_Help_Text = Supplier_Portal_Home_Page_Help_Text;

    @track isRequest = false;
    @track isAssignment = false;
    @track isDemand = false;
    @track isMap = false;
    @track isVolunteer = false;
    @track isInventory = false;
    @track home = true;
    @track work = false;
    @track helpdesk = false;
    @track mass = false;

    @track isVolunteerUser = false;
    @track isSupplierUser = false;
    @track isHospitalUser = false;

    @track showPurchaseRequestSummaryTab = false;
    @track showVolunteerAssignmentTab = false;
    @track showVolunteerAssignmentSummaryTab = false;
    @track showPurchaseRequestTab = false;
    @track showInventoryTab = false;
    @track showWorkOrderTab = false;
    @track showTechnicalHelpDeskTab = false;
    @track showMyAssignmentTab = false;
    @track idValues = '';


    constructor(){
        super();
        var url_string = window.location.href;
        var url = new URL(url_string);
        console.log('URL --> ' + url);
        this.idValues = url.searchParams.get("id");
        console.log('Id ---- > ' + this.idValues);
        if(this.idValues != null){
            this.isAssignment = false;
            this.isRequest = false;
            this.isDemand = false;
            this.isMap = false;
            this.isVolunteer = false;
            this.home = false;
            this.work= false;
            this.helpDesk = false;
            this.mass = true;
        }
    }


    connectedCallback() {
        getCurrentUser().then(res => {
            if(res.Profile.Name == 'DOH Supplier User') {
                this.isSupplierUser = true;
            }
            else if(res.Profile.Name == 'DOH Hospital User') {
                this.isHospitalUser = true;
            }
            else if(res.Profile.Name == 'DOH Volunteer User') {
                this.isVolunteerUser = true;
            }
            this.showMyAssignmentTab = this.isVolunteerUser;
            this.showVolunteerAssignmentSummaryTab = this.isVolunteerUser;
            this.showVolunteerAssignmentTab = this.isHospitalUser;
            this.showPurchaseRequestSummaryTab = this.isSupplierUser;
            this.showPurchaseRequestTab = this.isSupplierUser;
            this.showInventoryTab = this.isSupplierUser;
            this.showWorkOrderTab = this.isSupplierUser || this.isHospitalUser;
            this.showTechnicalHelpDeskTab = this.isSupplierUser || this.isHospitalUser;
        });
    }
    
    hideAll(){
        this.isAssignment = false;
        this.isRequest = false;
        this.isDemand = false;
        this.isMap = false;
        this.isVolunteer = false;
        this.home = false;
        this.work= false;
        this.helpDesk = false;
        this.mass = false;
        this.isInventory = false;
    }

    openHome() {
        this.hideAll();
        this.home = true;
    }

    openAssignment() {
        this.hideAll();
        this.isAssignment = true;
    }

    openRequest(){
        this.hideAll();
        this.isRequest = true;
    }

    openDemand(){
        this.hideAll();
        this.isDemand = true;
    }

    openMap(){
        this.hideAll();
        this.isMap = true;
    }

    openVolunteer(){
        this.hideAll();
        this.isVolunteer = true;
    }

    openInventory(){
        this.hideAll();
        this.isInventory = true;
    }

    openWork(){
        this.hideAll();
        this.work = true;
    }

    openHelpDesk(){
        this.hideAll();
        this.helpDesk = true;
    }
}