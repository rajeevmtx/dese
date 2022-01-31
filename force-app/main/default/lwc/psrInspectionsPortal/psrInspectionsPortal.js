/* eslint-disable no-loop-func */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from "lwc";
// Importing Apex Class method
import getInspectionList from "@salesforce/apex/PsrInspectionController.getInpectionsData";
import updateList from "@salesforce/apex/PsrInspectionController.updateInspectionItems";
import { refreshApex } from "@salesforce/apex";
// importing to show toast notifictions
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import Portal_Corrective_Action_Help_Text from "@salesforce/label/c.Portal_Corrective_Action_Help_Text";
import Portal_Corrective_Action_No_Item_Text from "@salesforce/label/c.Portal_Corrective_Action_No_Item_Text";

export default class PsrInspectionsPortal extends NavigationMixin(
  LightningElement
) {
  @track showSpinner;
  @track allRecords;
  @track inspectionRecords = [];
  @track isdata = true;
  @track uploadFileRecId;
  @track openFileModal = false;
  @track hideSubmit = true;
  @api Portal_Corrective_Action_Help_Text = Portal_Corrective_Action_Help_Text;
  @api
  Portal_Corrective_Action_No_Item_Text = Portal_Corrective_Action_No_Item_Text;
  

  @wire(getInspectionList)
  loadRecords(result) {
    this.allRecords = result;
    if (result.data) {
      console.log("data BED", JSON.stringify(result.data));
      this.inspectionRecords = result.data;
      if (this.inspectionRecords.length === 0) {
        this.isdata = false;
      }
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.inspectionRecords = undefined;
    }
  }

  bindCorrectionPlan(event) {
    this.hideSubmit = true;
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
    this.hideSubmit = true;
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
    if (this.inspectionRecords) {
      let errorCount = 0;
      let recs = this.inspectionRecords;
      let keys = Object.keys(recs);
      // eslint-disable-next-line guard-for-in
      for(let key in keys) {
        let parentRec = recs[keys[key]];
        let childRecs = parentRec.items ? parentRec.items : [];
        childRecs.forEach(childRec => {
          
          if ((childRec.dateImplemented && !childRec.correctionPlan)||(!childRec.dateImplemented && childRec.correctionPlan)){
            
            errorCount++;
            
            let errorChildId = childRec.recId; //to find the error inspection item
            if (!childRec.dateImplemented) {
              let errorDateElement = this.template.querySelector(`lightning-input[data-id=${errorChildId}]`);
                            
              //Adding error css to this element
              errorDateElement.classList.add('slds-has-error');
            } else if (!childRec.correctionPlan) {
              let errorTextElement = this.template.querySelector(`lightning-textarea[data-id=${errorChildId}]`);
              
              //Adding error css to this element
              errorTextElement.classList.add('slds-has-error');
              }
          }
        });
      }
      
      if (errorCount) {
        let err = new ShowToastEvent({
          title: "Error",
          message: "Please fill the required fields.",
          variant: "error"
        });
        this.dispatchEvent(err);
        return;
      }
    }

    updateList({
      response: JSON.stringify(this.inspectionRecords),
      isSubmit: true
    })
      .then(result => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Corrective Actions Submitted",
            variant: "success"
          })
        );
        console.log("result", result);
        refreshApex(this.allRecords);
      })
      .catch(error => {
        console.log("error", error);
      });
  }

  handleOnlySave() {
    console.log("save save", JSON.stringify(this.inspectionRecords));
    updateList({
      response: JSON.stringify(this.inspectionRecords),
      isSubmit: false
    })
      .then(result => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Data Saved",
            variant: "success"
          })
        );
        console.log("result", result);
        refreshApex(this.allRecords);
      })
      .catch(error => {
        console.log("error", error);
      });
  }

  handleSaveAndHome() {
    console.log("handleSaveAndHome", JSON.stringify(this.inspectionRecords));
    updateList({
      response: JSON.stringify(this.inspectionRecords),
      isSubmit: false
    })
      .then(result => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Data Saved",
            variant: "success"
          })
        );
        console.log("result", result);
        window.open("/psr/s", "_self");
      })
      .catch(error => {
        console.log("error", error);
      });
  }

  handleFileUpload(event) {
    console.log("In handleFileUpload", event.currentTarget.dataset.recid);
    this.uploadFileRecId = event.currentTarget.dataset.recid;
    this.openFileModal = true;
  }

  cancelFileUploadModal() {
    this.openFileModal = false;
  }

  handleViewFile(event) {
    console.log("In handleViewFile", event.currentTarget.dataset.recid);
    let recordId = event.currentTarget.dataset.recid;
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordRelationshipPage",
      attributes: {
        recordId: recordId,
        objectApiName: "Inspection_Item__c",
        relationshipApiName: "AttachedContentDocuments",
        actionName: "view"
      }
    }).then(url => window.open(url, "_blank"));
  }

  handleExpand(event) {
    let _allRecords = JSON.parse(JSON.stringify(this.inspectionRecords));
    let _parentId = event.target.dataset.pid;
    console.log("_parentId", _parentId);
    if (Object.keys(_allRecords).length > 0) {
      let keys = Object.keys(_allRecords);
      for (let key in keys) {
        let parentRec = _allRecords[keys[key]];
        console.log("parentRec", parentRec);
        console.log("parentRec>>Id", parentRec.parentId);
        if (parentRec.parentId == _parentId) {
          console.log("Found the Hit");
          parentRec.showChilds = true;
        }
      }
      console.log("_allRecords", JSON.stringify(_allRecords));
      this.inspectionRecords = _allRecords;
    }
  }

  handleCollapse(event) {
    let _allRecords = JSON.parse(JSON.stringify(this.inspectionRecords));
    let _parentId = event.target.dataset.pid;
    console.log("_parentId", _parentId);
    if (Object.keys(_allRecords).length > 0) {
      let keys = Object.keys(_allRecords);
      for (let key in keys) {
        let parentRec = _allRecords[keys[key]];
        console.log("parentRec", parentRec);
        console.log("parentRec>>Id", parentRec.parentId);
        if (parentRec.parentId == _parentId) {
          console.log("Found the Hit");
          parentRec.showChilds = false;
        }
      }
      console.log("_allRecords", JSON.stringify(_allRecords));
      this.inspectionRecords = _allRecords;
    }
  }

  getNextSiblings(element) {
    var arraySib = [];
    while (element) {
      arraySib.push(element);
      element = element.nextSibling;
    }
    return arraySib;
  }
}