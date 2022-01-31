import { LightningElement, track, api } from 'lwc';
import getProjectInitiative from '@salesforce/apex/DESE_DistrictwideStrategiesController.getProjectInitiative';
import saveProjectInitiative from '@salesforce/apex/DESE_DistrictwideStrategiesController.saveProjectInitiative';
var itemset = new Set();
export default class InitiativeModalWindow extends LightningElement {

  @api projectId = ''
  @track isModalOpen = false;

  @track initiativeName = '';
  @track initiativeStrategies = '';
  @track initiativeActivityConnected = false;
  @track items = [];
  showSpinner = false;
  @api readOnly;

  get options() {
    return [
      { label: 'Yes', value: true },
      { label: 'No', value: false }
    ];
  }
  get fsoptions() {
    return [
      { label: 'Title I, Part A', value: 'Title I, Part A' },
      { label: 'Title II, Part A', value: 'Title II, Part A' },
      { label: 'Title III, Part A', value: 'Title III, Part A' },
      { label: 'Title IV, Part A', value: 'Title IV, Part A' },
      { label: 'Title V-B (REAP Grant)', value: 'Title V-B (REAP Grant)' },
      { label: 'School Redesign (Level 4 and 5 schools)', value: 'School Redesign (Level 4 and 5 schools)' },
      { label: 'IDEA', value: 'IDEA' },
      { label: 'Perkins', value: 'Perkins' },
      { label: 'Other Federal', value: 'Other Federal' },
      { label: 'State and/or Local', value: 'State and/or Local' },
      { label: 'Private Funding', value: 'Private Funding' }
    ];
  }


  showModal() {
    console.log('Inside show modal')
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
    this.resetFields();
  }

  get modalClass() {
    return `slds-modal ${this.isModalOpen ? "slds-fade-in-open" : ""}`;
  }
  get modalBackdropClass() {
    return `slds-backdrop ${this.isModalOpen ? "slds-backdrop_open" : ""}`;
  }
  handleToggleChange(event) {
    const selectedOption = event.detail.value;
    console.log('Option selected with value: ' + selectedOption);
    this.initiativeActivityConnected = selectedOption;
  } 
  handleChange(event) {
    if (event.target.name == "initiativeName") {
      this.initiativeName = event.target.value;
    } else if (event.target.name == "initiativeStrategies") {
      this.initiativeStrategies = event.target.value;
    }
    // else if (event.target.name == "initiativeActivityConnected") {
    //   this.initiativeActivityConnected = event.target.value;
    // } 
    if (event.target.name == "fsoptions") {
      this.items.push({ label: event.target.value });
    }
  }
  handleItemRemove(event) {
    const name = event.detail.item.name;
    //alert(name + ' pill was removed!');
    const index = event.detail.index;
    this.items.splice(index, 1);
  }
  handleSave(event) {
    this.items.forEach(item => {
      itemset.add(item.label);
    });
    console.log('bool--'+this.initiativeActivityConnected);
    var wrapperInitiativeString = {
      InitiativeName: this.initiativeName,
      InitiativeStrategiesActivities: this.initiativeStrategies,
      InitiativeactivityexplicitlyConnected: this.initiativeActivityConnected,
      InitiativeFundingSource: Array.from(itemset)
    }
    this.showSpinner = true;
    saveProjectInitiative({

      proposalId: this.projectId,
      wrapperString: JSON.stringify(wrapperInitiativeString)
    }).then(data => {
      if (data == 'SUCCESS') {
        this.dispatchEvent(new CustomEvent('fetch'));
        this.closeModal();
        this.resetFields();
      }
    }).catch(error => {
      console.log(JSON.stringify(error));
    }).finally(() => {
      this.showSpinner = false;
    })
  }
  resetFields(){
    initiativeName = '';
    initiativeStrategies = '';
    initiativeActivityConnected = false;
    items = [];
  }
}