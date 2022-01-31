import {
  LightningElement,
  api,
  track
} from 'lwc';
// importing to show toast notifictions
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getContactData from '@salesforce/apex/PsrContactListController.getContact';
import getApplicationContactData from '@salesforce/apex/PsrContactListController.getApplicationContact';
import createApplicationContact from '@salesforce/apex/PsrContactListController.createContact';
import {
  utility
} from "c/pubsub";
import fetchPicklist from '@salesforce/apex/AdultProtectiveServiceController.fetchPicklist';
import createPartiesInvolved from '@salesforce/apex/AdultProtectiveServiceController.createPartiesInvolved';


export default class Aps_new_parties_Involved extends LightningElement {
  @api isOpenModal = false;
  @api contactid;
  @api caseid;
  @api partiesinvolvedid;
  @api type;
  @track contact = {};

  @track dataObj = {};

  get isEdit() {
    if (this.contactid) {
      return true;
    }
    return false;
  }

  @api modalbuttonadd;
  @api modalbuttonedit;

  get genderOptions() {
    return [{
        label: 'Male',
        value: 'Male'
      },
      {
        label: 'Female',
        value: 'Female'
      },
      {
        label: 'Other',
        value: 'Other'
      }
    ];
  }

  get header() {
    return (typeof this.partiesinvolvedid == 'undefined' || this.partiesinvolvedid == '' || this.partiesinvolvedid == null) ? 'Add New Abuser' : 'Edit Abuser';
  }

  @track collateralTypeOptions = [];
  @track resourceTypeOptions = [];
  @track relationtoAVOptions = [];

  connectedCallback() {
    fetchPicklist({
        objectName: 'Parties_Involved__c',
        fieldName: 'Collateral_Type__c'
      })
      .then(result => {
        this.collateralTypeOptions = result;
      })
      .catch(error => {
        let message = error.message || error.body.message;
        console.log(message);
      });

    fetchPicklist({
        objectName: 'Parties_Involved__c',
        fieldName: 'Resource_Type__c'
      })
      .then(result => {
        this.resourceTypeOptions = result;
      })
      .catch(error => {
        let message = error.message || error.body.message;
        console.log(message);
      });

    fetchPicklist({
        objectName: 'Parties_Involved__c',
        fieldName: 'Relation_to_AV__c'
      })
      .then(result => {
        this.relationtoAVOptions = result;
      })
      .catch(error => {
        let message = error.message || error.body.message;
        console.log(message);
      });
  }

  handleInput(event) {
    if (event.target.name === 'FirstName') {
      this.dataObj.FirstName = event.target.value;
    }
    else if (event.target.name === 'LastName') {
      this.dataObj.LastName = event.target.value;
    }
    else if (event.target.name === 'Gender') {
      this.dataObj.Gender = event.target.value;
    }
    else if (event.target.name === 'Relation_to_AV') {
      this.dataObj.Relation_to_AV = event.target.value;
    }
  }

  handleOpenModal() {
    this.isOpenModal = true;
  }
  
  handleSave() {
    console.log('--handleSave--');

    this.dataObj.Type = this.type;
    this.dataObj.caseId = this.caseid;
    
    
    console.log('--this.dataObj--'+JSON.stringify(this.dataObj) );

    createPartiesInvolved({
      JsonData: JSON.stringify(this.dataObj)
      })
      .then(result => {
        this.handleCloseModal();
      })
      .catch(error => {
        let message = error.message || error.body.message;
          console.log(message);
      })
  }

  handleCloseModal() {
    // Creates the event with the data.
    this.dispatchEvent( new CustomEvent("closemodal") );
    this.isOpenModal = false;
  }

  // matchExisting(event) {
  //   this.retrieveContact(event.detail.value);
  // }

  // retrieveContact(email) {
  //   getContactData({
  //       email: email
  //     })
  //     .then(result => {
  //       if (result) {
  //         this.contactId = result.Id;
  //         this.contact.accountId = result.AccountId;
  //         if (this.checkBlank(this.contact.firstName))
  //           this.contact.firstName = result.FirstName;
  //         if (this.checkBlank(this.contact.lastName))
  //           this.contact.lastName = result.LastName;
  //         if (this.checkBlank(this.contact.email))
  //           this.contact.email = result.Email;
  //         if (this.checkBlank(this.contact.phone))
  //           this.contact.phone = result.Phone;
  //         if (this.checkBlank(this.contact.companyName))
  //           this.contact.companyName = result.Account.Name;
  //       }
  //     })
  //     .catch(err => {
  //       console.log('error here', JSON.stringify(err));
  //     })
  // }

  // checkBlank(val) {
  //   if (val != '' && val != null && typeof val != 'undefined') {
  //     return false;
  //   }
  //   return true;
  // }
}