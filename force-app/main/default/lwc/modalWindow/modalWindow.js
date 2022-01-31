import { api, LightningElement, track } from 'lwc';
import upsertSchool from '@salesforce/apex/DESE_IntakeSchoolController.upsertSchool'

const NUM_FIELDS = ['PSS_Amount_per_Low_Income_Student__c','Estimate_participant_in_Title_I__c',
        'No_Children_with_low_income__c','No_Children_in_Title_I_area__c','Grades_Served__c','Allocation_per_School_for_Service__c']
export default class ModalWindow extends LightningElement {
  @api schoolId = '' 
  @api projectId = ''
  @api readOnly;
  @track isModalOpen = false;
  @track school = {
    //Id: '',
    PSS_School_Name__c: '',
    PSS_School_Town__c: '',
    Participate_in_Title_I__c: '',
    Allocation_per_School_for_Service__c: '',
    Grades_Served__c: '',
    No_Children_in_Title_I_area__c: '',
    No_Children_with_low_income__c: '',
    Estimate_participant_in_Title_I__c: '',
    PSS_Amount_per_Low_Income_Student__c: ''
  }

  genericHandler(event) {
    var inputname = event.currentTarget.dataset.id;

    this.school[inputname] = (NUM_FIELDS.includes(inputname)) ? parseInt(event.target.value ? event.target.value : 0) : event.target.value;
  }

  connectedCallback() {

  }
  showModal() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
  }
  get modalClass() {
    return `slds-modal ${this.isModalOpen ? "slds-fade-in-open" : ""}`;
  }
  get modalBackdropClass() {
    return `slds-backdrop ${this.isModalOpen ? "slds-backdrop_open" : ""}`;
  }
  value = 'Yes';

  get options() {
    return [
      { label: 'Yes', value: 'Yes' },
      { label: 'No', value: 'No' },
    ];
  }

  handleSave() {
    console.log(JSON.parse(JSON.stringify(this.school)),this.projectId);
    upsertSchool({ sch: this.school, projectId: this.projectId })
      .then((result => {
        console.log(result)

        if(result == 'Success'){
          this.dispatchEvent(new CustomEvent('fetch'));
          this.closeModal();
        }
      }))
      .catch(error => {
        console.log(error)
      })
  }
}