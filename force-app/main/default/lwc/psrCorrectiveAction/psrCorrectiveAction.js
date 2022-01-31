/* eslint-disable no-console */
import { LightningElement, track, api, wire } from "lwc";
import getInspectionItems from "@salesforce/apex/PsrInspectionController.getInspectionItems";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveInspectionRecord from "@salesforce/apex/PsrInspectionController.saveInspectionRecord";
import getPublishedRecords from "@salesforce/apex/PsrInspectionController.getPublishedRecords";
import getAcceptCorrectiveRecords from "@salesforce/apex/PsrInspectionController.getAcceptCorrectiveRecords";
import { NavigationMixin } from "lightning/navigation";

const COLS = [
    { label: "Inspection Item Name", fieldName: "Inspection_Item_Name__c" },
    { label: "Inspection Item Number", fieldName: "Name" },
    { label: "Observation", fieldName: "Observations__c" },
    { label: "Correction Plan", fieldName: "Correction_Plan__c", editable: true },
    { label: "Status ", fieldName: "Correction_Plan_Status__c", editable: true },
    {
        label: "Date Implemented",
        fieldName: "Date_Implemented__c",
        type: "Date",
        editable: true
    },
    {
        label: "Corrective Action Feedback",
        fieldName: "Corrective_Action_Feedback__c",
        editable: true
    }
];

export default class PsrCorrectiveAction extends NavigationMixin(
    LightningElement
) {
    @track error;
    @track columns = COLS;
    @api recordId;
    @track allRecords;
    @track showEdit = true;
    @track inspectionData;
    @track allSelectedFlag = false;
    @track selectedAllCheckBoxes = [];
    @track selectedCheckedRecords = [];
    @track openFileModal = false;
    @track disableButtons = true;

    @wire(getInspectionItems, { parentId: "$recordId" })
    inspectionItem(result) {
        this.allRecords = result;
        if (result.data) {
            console.log("data BED", JSON.stringify(result.data));
            this.inspectionData = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.inspectionData = undefined;
        }
    }
    connectedCallback() {
        console.log("RecordId::" + this.recordId);
    }

    // Select the all rows
    allSelected(event) {
        this.allSelectedFlag = true;
        let selectedRows = this.template.querySelectorAll("lightning-input");
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === "checkbox") {
                selectedRows[i].checked = event.target.checked;
                //I-16160 - Chandana -Start
                if (selectedRows[i].checked) {
                    this.disableButtons = false;
                } else {
                    this.disableButtons = true;
                }
                //I-16160 - Chandana -End
                this.selectedAllCheckBoxes.push({
                    Id: selectedRows[i].dataset.id
                });
            }
        }
    }

    handleCheckboxes(event) {
        this.allSelectedFlag = false;
        if (event.target.checked === true) {
            this.selectedCheckedRecords.push({
                Id: event.target.getAttribute("data-id")
            });
            //I-16160 - Chandana -Start
            this.disableButtons = false;
            //I-16160 - Chandana -End
        } else if (event.target.checked === false) {
            //I-16160 - Chandana -Start
            this.disableButtons = true;
            //I-16160 - Chandana -End
            if (this.selectedCheckedRecords.length > 0) {
                for (let i = 0; this.selectedCheckedRecords.length; i++) {
                    if (
                        JSON.stringify(this.selectedCheckedRecords[i].Id).replace(
                            /"/g,
                            ""
                        ) == event.target.getAttribute("data-id")
                    ) {
                        this.selectedCheckedRecords.splice(i, 1);
                        return;
                    }
                }
            }
        }
    }

    //I-16160 - Chandana -Start
    get isVisible() {
            return this.disableButtons;
        }
        //I-16160 - Chandana -End

    handlePublishBackToPortal() {
        console.log("inside portal click");
        saveInspectionRecord({ response: JSON.stringify(this.inspectionData) })
            .then(result => {
                getPublishedRecords({
                        publishedResponse: this.allSelectedFlag ?
                            JSON.stringify(this.selectedAllCheckBoxes) :
                            JSON.stringify(this.selectedCheckedRecords)
                    })
                    .then(result => {
                        refreshApex(this.allRecords);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: "Successfully published",
                                variant: "success"
                            })
                        );
                    })
                    .catch(error => {
                        // TODO Error handling
                        console.log("error", error);
                    });
                refreshApex(this.allRecords);
            })
            .catch(error => {
                // TODO Error handling
                console.log("error", error);
            });
    }

    handleAcceptCorrectiveActions() {
        console.log("inside accept corrective actions");
        saveInspectionRecord({ response: JSON.stringify(this.inspectionData) })
            .then(result => {
                getAcceptCorrectiveRecords({
                        acceptCorrectiveResponse: this.allSelectedFlag ?
                            JSON.stringify(this.selectedAllCheckBoxes) :
                            JSON.stringify(this.selectedCheckedRecords)
                    })
                    .then(result => {
                        refreshApex(this.allRecords);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: "Successfully accepted",
                                variant: "success"
                            })
                        );
                    })
                    .catch(error => {
                        // TODO Error handling
                        console.log("error", error);
                    });
                refreshApex(this.allRecords);
            })
            .catch(error => {
                // TODO Error handling
                console.log("error", error);
            });
    }

    bindObservations(event) {
        let _recId = event.target.dataset.id;
        let _allRecords = JSON.parse(JSON.stringify(this.inspectionData));
        console.log("_allRecords", JSON.stringify(_allRecords));
        for (const key in _allRecords) {
            let _rec = _allRecords[key];
            if (_recId == _rec.Id) {
                console.log("In MAtch found");
                _rec.Observations__c = event.target.value;
                console.log("In MAtch found");
            }
        }
        this.inspectionData = _allRecords;
        console.log("_allRecords+++++", JSON.stringify(_allRecords));
    }

    bindCorrectionPlan(event) {
        let _recId = event.target.dataset.id;
        let _allRecords = JSON.parse(JSON.stringify(this.inspectionData));
        console.log("_allRecords", JSON.stringify(_allRecords));
        for (const key in _allRecords) {
            let _rec = _allRecords[key];
            if (_recId == _rec.Id) {
                console.log("In MAtch found");
                _rec.Correction_Plan__c = event.target.value;
                console.log("In MAtch found");
            }
        }
        this.inspectionData = _allRecords;
        console.log("_allRecords+++++", JSON.stringify(_allRecords));
    }

    bindCorrectionFeedBack(event) {
        console.log("in feedback");
        let _recId = event.target.dataset.id;
        let _allRecords = JSON.parse(JSON.stringify(this.inspectionData));
        console.log("_allRecords", JSON.stringify(_allRecords));
        for (const key in _allRecords) {
            let _rec = _allRecords[key];
            if (_recId == _rec.Id) {
                console.log("In MAtch found");
                _rec.Corrective_Action_Feedback__c = event.target.value;
                console.log("In MAtch found");
            }
        }
        this.inspectionData = _allRecords;
        console.log("_allRecords+++++", JSON.stringify(_allRecords));
    }

    bindDateImplemented(event) {
        let _recId = event.target.dataset.id;
        let _allRecords = JSON.parse(JSON.stringify(this.inspectionData));
        console.log("_allRecords", JSON.stringify(_allRecords));
        for (const key in _allRecords) {
            let _rec = _allRecords[key];
            if (_recId == _rec.Id) {
                console.log("In MAtch found");
                _rec.Date_Implemented__c = event.target.value;
                console.log("In MAtch found");
            }
        }
        this.inspectionData = _allRecords;
        console.log("_allRecords+++++", JSON.stringify(_allRecords));
    }

    handleSaveClick() {
        console.log("save save", JSON.stringify(this.inspectionData));
        saveInspectionRecord({ response: JSON.stringify(this.inspectionData) })
            .then(result => {
                console.log("result", result);
                refreshApex(this.allRecords);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Successfully updated",
                        variant: "success"
                    })
                );
            })
            .catch(error => {
                // TODO Error handling
                console.log("error", error);
            });
    }

    handleFileUpload(event) {
        this.uploadFileRecId = event.currentTarget.dataset.recid;
        this.openFileModal = true;
    }

    cancelFileUploadModal() {
        this.openFileModal = false;
    }

    handleViewFile(event) {
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
}