import { LightningElement, track, wire, api } from "lwc"; 
// Importing Apex Class method
import getInspectionList from "@salesforce/apex/PsrInspectionController.getInpectionsData";
import updateList from "@salesforce/apex/PsrInspectionController.updateInspectionItems";
import { refreshApex } from "@salesforce/apex";
// importing to show toast notifictions
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class SampleComponentToBeDeleted extends LightningElement {
  @track showSpinner;
  @track allRecords;
  @track inspectionRecords = [];
  @track uploadFileRecId;
  @track openFileModal = false;

  @wire(getInspectionList)
  loadRecords( result ) {
    this.allRecords = result;
    if (result.data) {
      console.log("data BED", JSON.stringify(result.data));
      this.inspectionRecords = result.data;
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.inspectionRecords = undefined;
    }
  }

  bindCorrectionPlan(event) {
    let _allRecords = JSON.parse(JSON.stringify(this.inspectionRecords));
    let childId = event.target.dataset.id;
    console.log("childId++", childId);

    if (Object.keys(_allRecords).length > 0) {
      let keys = Object.keys(_allRecords);
      for (let key in keys) {
        let parentRec = _allRecords[keys[key]];
        let childRecs = parentRec.items ? parentRec.items : [];

        childRecs.forEach(function(childRec) {
          if (childRec.recId == childId) {
            childRec.correctionPlan = event.target.value;
          }
        });
      }
      console.log("_allRecords", JSON.stringify(_allRecords));
      this.inspectionRecords = _allRecords;
    }
  }

  bindDateImplemented(event) {
    let _allRecords = JSON.parse(JSON.stringify(this.inspectionRecords));
    let childId = event.target.dataset.id;

    if (Object.keys(_allRecords).length > 0) {
      let keys = Object.keys(_allRecords);
      for (let key in keys) {
        let parentRec = _allRecords[keys[key]];
        let childRecs = parentRec.items ? parentRec.items : [];

        childRecs.forEach(function(childRec) {
          if (childRec.recId == childId) {
            childRec.dateImplemented = event.target.value;
          }
        });
      }
      console.log("_allRecords", JSON.stringify(_allRecords));
      this.inspectionRecords = _allRecords;
    }
  }

  handleSave() {
    console.log("save save", JSON.stringify(this.inspectionRecords));
    updateList({ response: JSON.stringify(this.inspectionRecords), isSubmit: true })
      .then(result => {
        console.log("result", result);
        refreshApex(this.allRecords);
      })
      .catch(error => {
        console.log("error", error);
      });
  }

  handleOnlySave() {
    console.log("save save", JSON.stringify(this.inspectionRecords));
    updateList({ response: JSON.stringify(this.inspectionRecords), isSubmit: false })
      .then(result => {
        console.log("result", result);
        refreshApex(this.allRecords);
      })
      .catch(error => {
        console.log("error", error);
      });
  }

  handleHome(){
    window.open("/psr/s", '_self');
  }

  handleFileUpload(event){
    console.log('In handleFileUpload', event.currentTarget.dataset.recid);
    this.uploadFileRecId = event.currentTarget.dataset.recid;
    this.openFileModal = true;
  } 

  cancelFileUploadModal(){
    this.openFileModal = false;
  } 

  handleViewFile(event) {
    //this[NavigationMixin.GenerateUrl] Navigate
    let recordId = event.currentTarget.dataset.recid;
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordRelationshipPage',
        attributes: {
            recordId: recordId,
            objectApiName: 'Inspection_Item__c',
            relationshipApiName: 'AttachedContentDocuments',
            actionName: 'view'
        }
    }).then(url => window.open(url, '_blank'));
  }
}