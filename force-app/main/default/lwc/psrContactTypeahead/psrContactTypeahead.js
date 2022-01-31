import { LightningElement, track, api } from 'lwc';
import fetchApplicationContacts from '@salesforce/apex/PSR_ApplicationWorkOrderController.fetchApplicationContacts';
export default class PsrContactTypeahead extends LightningElement {
    @track showDropDown;
    @api showAddNew;
    @api selectedContactId;
    @track appContactList;
    @track selectedGroup;
    @track showIconOnSelection = false;
    @track showNewGroupModal = false
    @api ismobile;
    @api hideModalOverlay = false;
    @track disabledInternal = false;
    @track options = [];
    @track showOptions = false;
    @api appId;
    originalContactList;
    connectedCallback() {
        this.getApplicationContacts();
    }
    //I-16144 dhana Prasad added if condition for SubContractors
    getApplicationContacts() {
        fetchApplicationContacts({ appId : this.appId })
        .then(res => {
            this.appContactList = res;
            this.originalContactList = JSON.parse(JSON.stringify(res));
            let _superThis = this;
            console.log('data here', JSON.stringify(this.appContactList));
            this.originalContactList.forEach(item => {
               // if(item.record.Contact_Type__c === 'Subcontractors')
                _superThis.options.push({
                    label: item.record.Contact__r.Name, value: item.record.Id
                });
            })
            if(this.options.length > 0) {
                this.showOptions = true;
            }
            console.log('options here', JSON.stringify(this.options));
        })
        .catch(err => {
            console.error('error here', err);
        })
    }
    // method to filter group based on input
    filterGroups = event => {
        let value = this.template.querySelector('*[name="group-typeahead-search-input"]').value;
        if(value === '') {
            this.appContactList = this.originalContactList;
        }
        else {
            this.appContactList = [];
            let _superThis = this; 
            this.originalContactList.forEach(item => {
                if(item.record.Contact__r.Name.toLowerCase().includes(value.toLowerCase())) {
                    _superThis.appContactList.push(item);
                }
            })
        }
        this.showDropDown = true;
        return "";
    }
    // passing the selected group info to parent
    dispatchGroupSelectEvent = (appId) => {
        const groupSelectEvent = new CustomEvent('contactselect', {
            detail: appId
        });
        this.dispatchEvent(groupSelectEvent);
    }
    handleGroupSelect(event) {
        console.log('inside group select');
        const appId = event.detail.value;
        // const typeahead = this.template.querySelector('.typeahead-input');
        // typeahead.value = typeahead ? event.currentTarget.dataset.name : '';
        this.dispatchGroupSelectEvent(appId);
        // this.showDropDown = false;
    }
    // handling the focus out event
    handleFocusOut = event => {
        setTimeout(_ => {
            this.showDropDown = false;
        }, 500);
    }
    // handling the input key up event
    inputKeyUp = event => {
        let keycode = event.which;
        if (keycode === 27) {
            this.showDropDown = false;
        }
    }
}