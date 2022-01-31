import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAssignments from '@salesforce/apex/NYSDOH_VolunteerController.getVolunteerAssignments';
import getCurrentUser from '@salesforce/apex/NYSDOH_RequestController.getCurrentUser';
import Portal_Work_Order_Help_Text from '@salesforce/label/c.Portal_Work_Order_Help_Text';;

export default class NysdohVolunteerAssignment extends NavigationMixin(LightningElement) {

    pageSize = 10;
    navItemCount = 5;
    @track pages = [];
    @track page = 1;

    @track volunteerAssignmentId = '';
    @track showConfirmationModal = false;
    @track volunteerAssignments = [];
    @track filteredVolunteerAssignments = [];
    @track isVolunteer = false;
    @track isHospital = false;
    @track selectedStatus = '';
    @track statusOptions = [];
    @track Portal_Work_Order_Help_Text= Portal_Work_Order_Help_Text;

    renderedCallback() {
        this.renderButtons();
    }

    connectedCallback() {
        this.setUserType();
    }

    renderButtons = () => {
        this.template.querySelectorAll('button').forEach((but) => {
            but.style.backgroundColor = this.page === parseInt(but.dataset.id, 10) ? 'dodgerblue' : 'white';
            but.style.color = this.page === parseInt(but.dataset.id, 10) ? 'white' : 'black';
        });
    }

    get pagesList() {
        let mid = Math.floor(this.navItemCount / 2) + 1;
        if (this.page > mid) {
            return this.pages.slice(this.page - mid, this.page + mid - 1);
        }
        return this.pages.slice(0, this.navItemCount);
    }

    pageData = () => {
        let page = this.page;
        let pageSize = this.pageSize;
        let startIndex = (page * pageSize) - pageSize;
        let endIndex = (page * pageSize);
        return this.filteredVolunteerAssignments.slice(startIndex, endIndex);
    }

    setPages = (filteredVolunteerAssignments) => {
        let numberOfPages = Math.ceil(filteredVolunteerAssignments.length / this.pageSize);
        this.pages = [];
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }

    get hasPrevious() {
        return this.page > 1;
    }

    get hasNext() {
        return this.page < this.pages.length
    }

    onNext = () => {
        ++this.page;
    }

    onPrev = () => {
        --this.page;
    }

    onPageClick = (e) => {
        this.page = parseInt(e.target.dataset.id, 10);
    }

    get currentPageData() {
        return this.pageData();
    }

    setupVolunteerAssignments() {

        getAssignments()
            .then(res => {
                let _statusOptionsSet = new Set();
                let _statusOptions = [];

                this.volunteerAssignments = res;
                this.filteredVolunteerAssignments = res;

                res.forEach((volunteerAssignment) => {
                    volunteerAssignment.disableConfirmation = (volunteerAssignment.status == 'Accepted') ||
                        (volunteerAssignment.status == 'Rejected') || (volunteerAssignment.status == 'Pending');
                    if(volunteerAssignment.status) {
                        _statusOptionsSet.add(volunteerAssignment.status);
                    }
                });

                _statusOptionsSet.forEach((status) => {
                   _statusOptions.push({
                        'label': status,
                        'value': status
                   });
                });

                this.statusOptions = _statusOptions;
                this.setPages(this.filteredVolunteerAssignments);
            });
    }

    setUserType() {
        getCurrentUser()
            .then(res => {
                if(res.Profile.Name == 'DOH Volunteer User') {
                    this.isVolunteer = true;
                }
                else if(res.Profile.Name == 'DOH Hospital User') {
                    this.isHospital = true;
                }
                this.setupVolunteerAssignments();
            });
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        let _filteredVolunteerAssignments = this.volunteerAssignments.filter(function(volunteerAssignment){
            return volunteerAssignment.status.localeCompare(event.detail.value) == 0;
        });
        this.filteredVolunteerAssignments = _filteredVolunteerAssignments;
        this.setPages(this.filteredVolunteerAssignments);
    }

    navigateToVolunteerDetail(event) {
        let volunteerId = event.target.dataset.volunteerId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: volunteerId,
                actionName: 'view'
            }
        });
    }

    confirm(event) {
        this.volunteerAssignmentId = event.target.dataset.volunteerAssignmentId;
        this.showConfirmationModal = true;
    }

    closeModal() {
        this.setupVolunteerAssignments();
        this.showConfirmationModal = false;
    }

}