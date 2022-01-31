import { LightningElement, track, api, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";
import getInvestigationItemsRecords from "@salesforce/apex/APS_InvestigationModeController.getInvestigationItemsRecords";
import updateInvestigationItemsRecords from "@salesforce/apex/APS_InvestigationModeController.updateInvestigationItemsRecords";
import filterInvestigationItemsRecords from "@salesforce/apex/APS_InvestigationModeController.filterInvestigationItemsRecords";
import investigationComplete from "@salesforce/apex/APS_InvestigationModeController.investigationComplete";
import Internal_Bulk_Update_Help_Text from "@salesforce/label/c.APS_Bulk_Update_Help_Text";

import { NavigationMixin } from "lightning/navigation";

import OBJECT_NAME from "@salesforce/schema/Investigation_Item__c";
import RESULT_FIELD from "@salesforce/schema/Investigation_Item__c.Result__c";
import CATEGORY_FIELD from "@salesforce/schema/Investigation_Item__c.Category__c";

export default class Aps_Investigation_Mode extends NavigationMixin(
    LightningElement
) {
    @api recordId;
    @api Internal_Bulk_Update_Help_Text = Internal_Bulk_Update_Help_Text;

    @track data = [];
    @track jsObject = [];
    @track showSpinner = false;
    @track showBulkUpdateModal = false;
    @track bulkCategory;
    @track bulkResult;
    @track bulkObservation;
    @track openFileModal = false;
    @track viewFileModal = false;
    @track uploadFileRecId;
    @track resultOptions;
    @track categoryOptions;
    @track isTableEmpty = false;
    @track isInvestigationComplete = false;
    @track isValid = false;
    @track observationClass = "observationClass";

    @wire(getObjectInfo, { objectApiName: OBJECT_NAME })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: RESULT_FIELD
    })
    wiredResultOptions({ data, error }) {
        if (data) {
            this.resultOptions = data.values;
        }
        if (error) {
            console.log("test");
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: CATEGORY_FIELD
    })
    wiredCategoryOptions({ data, error }) {
        if (data) {
            this.categoryOptions = data.values;
        }
        if (error) {
            console.log("test");
        }
    }

    handleInvestigationCompleteClick() {
        this.showSpinner = true;
        investigationComplete({
                idField: this.recordId
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Investigation Completed",
                        variant: "success"
                    })
                );
                setTimeout(() => {
                    this.showSpinner = false;
                    location.reload(true);
                }, 600);
                location.reload(true);
            })
            .catch(error => {
                console.log("error occured>> " + JSON.stringify(error));
            });
    }

    handleNavItemSelection(event) {
        this.showSpinner = true;
        console.log("data name here", event.detail.type);
        switch (event.detail.type) {
            case "result":
                {
                    filterInvestigationItemsRecords({
                        category: "",
                        result: event.detail.name,
                        type: "result",
                        idField: this.recordId
                    })
                    .then(result => {
                        this.data = result;
                        if (result.length > 0) {
                            if (
                                this.data[0].Investigation__r.Status__c ==
                                "Investigation Conducted"
                            ) {
                                this.isInvestigationComplete = true;
                            }
                        }
                        console.log("data" + JSON.stringify(this.data));
                        setTimeout(() => {
                            this.showSpinner = false;
                        }, 500);
                        this.isTableEmpty = this.data.length === 0 ? true : false;
                    })
                    .catch(error => {
                        console.log("error occured>> " + error);
                    });
                    break;
                }
            case "category":
                {
                    filterInvestigationItemsRecords({
                        category: event.detail.name,
                        result: "",
                        type: "category",
                        idField: this.recordId
                    })
                    .then(result => {
                        this.data = result;
                        if (result.length > 0) {
                            if (
                                this.data[0].Investigation__r.Status__c ==
                                "Investigation Conducted"
                            ) {
                                this.isInvestigationComplete = true;
                            }
                        }
                        console.log("data" + JSON.stringify(this.data));
                        setTimeout(() => {
                            this.showSpinner = false;
                        }, 500);
                        this.isTableEmpty = this.data.length === 0 ? true : false;
                    })
                    .catch(error => {
                        console.log("error occured>> " + error);
                    });
                    break;
                }
            case "All":
                {
                    this.refreshTableData();
                    setTimeout(() => {
                        this.showSpinner = false;
                    }, 500);
                    break;
                }
            default:
                {
                    console.error("cannot find the case");
                    break;
                }
        }
    }

    handleFileUpload(event) {
        this.uploadFileRecId = event.currentTarget.dataset.recid;
        this.openFileModal = true;
    }

    cancelFileUploadModal() {
        this.openFileModal = false;
    }

    handleViewFile(event) {
        //this[NavigationMixin.GenerateUrl] Navigate
        let recordId = event.currentTarget.dataset.recid;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: recordId,
                objectApiName: "Investigation_Item__c",
                relationshipApiName: "AttachedContentDocuments",
                actionName: "view"
            }
        }).then(url => window.open(url, "_blank"));
    }

    handleCategoryChange(event) {
        this.bulkCategory = event.target.value;
    }

    handleResultChange(event) {
        this.bulkResult = event.target.value;
    }

    handleObservationChange(event) {
        this.bulkObservation = event.target.value;
    }

    handleBulkUpdateClick() {
        this.showBulkUpdateModal = true;
    }

    cancelConfirmationModal() {
        this.showBulkUpdateModal = false;
    }

    handleConfirm() {
        updateInvestigationItemsRecords({
                category: this.bulkCategory,
                result: this.bulkResult,
                observation: this.bulkObservation,
                idField: this.recordId
            })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Bulk records updated",
                        variant: "success"
                    })
                );
                this.refreshTableData();
                this.showBulkUpdateModal = false;
            })
            .catch(error => {
                console.log("error occured>> " + error);
            });
    }

    handleSave(event) {
        let fields;
        this.showSpinner = true;

        console.log("this.showSpinner>>initial>" + this.showSpinner);
        if (event.target.name === "result") {
            fields = {
                Id: event.currentTarget.dataset.recid,
                Result__c: event.target.value
            };
            console.log("event.target.value>" + event.target.value);
            if (event.target.value == "Unsubstantiated") {
                this.isNonComplaint = true;
            }
        } else if (event.target.name === "observation") {
            fields = {
                Id: event.currentTarget.dataset.recid,
                Observations__c: event.target.value
            };
        }
        console.log("Fields::" + JSON.stringify(fields));
        let obs, res, investigationName;
        //Validate data
        if (this.data.length > 0) {
            for (let i = 0; i < this.data.length; i++) {
                if (this.data[i].Id == event.currentTarget.dataset.recid) {
                    investigationName = this.data[i].Name;
                    if (event.target.name === "result") {
                        //capture obs
                        obs = this.data[i].Observations__c;
                    } else if (event.target.name === "observation") {
                        //capture res
                        res = this.data[i].Result__c;
                    }
                    console.log("Observation::" + this.data[i].Observations__c);
                    console.log("Result::" + this.data[i].Result__c);
                }
            }
        }
        if (event.target.name === "result") {
            if (event.target.value === "Unsubstantiated" && obs === undefined) {
                console.log("Fill observation");
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Please fill Observations for " + investigationName,
                        variant: "error"
                    })
                );
                //this.refreshTableData();
                this.showSpinner = false;
                return;
            }
        } else if (event.target.name === "observation") {
            console.log("Value::" + event.target.value);
            if (event.target.value === "" && res === "Unsubstantiated") {
                console.log("Fill Result");
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Observations cannot be empty for " + investigationName,
                        variant: "error"
                    })
                );
                this.refreshTableData();
                this.showSpinner = false;
                return;
            }
        }

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                /*this.dispatchEvent(
                                                                                                                                                                                                                                                                                                                                                                                                                    new ShowToastEvent({
                                                                                                                                                                                                                                                                                                                                                                                                                        title: 'Success',
                                                                                                                                                                                                                                                                                                                                                                                                                        message: 'Record updated',
                                                                                                                                                                                                                                                                                                                                                                                                                        variant: 'success'
                                                                                                                                                                                                                                                                                                                                                                                                                    })
                                                                                                                                                                                                                                                                                                                                                                                                                );*/
                this.refreshTableData();
                setTimeout(() => {
                    this.showSpinner = false;
                }, 500);
            })
            .catch(error => {
                console.log("error>>" + JSON.stringify(error));
                /*this.dispatchEvent(
                                                                                                                                                                                                                                                                                                                                                                                                                    new ShowToastEvent({
                                                                                                                                                                                                                                                                                                                                                                                                                        title: JSON.stringify(error),
                                                                                                                                                                                                                                                                                                                                                                                                                        message: 'error',
                                                                                                                                                                                                                                                                                                                                                                                                                        variant: 'error'
                                                                                                                                                                                                                                                                                                                                                                                                                    })
                                                                                                                                                                                                                                                                                                                                                                                                                );*/
                setTimeout(() => {
                    this.showSpinner = false;
                }, 500);
            });

        //this.refreshTableData();
        //this.showSpinner=false;
        console.log("this.showSpinner>>final>" + this.showSpinner);
    }

    connectedCallback() {
        this.loadColumns();
        this.refreshTableData();
        console.log("result picklist>>>" + JSON.stringify(this.resultOptions));
    }

    setCorrectionPlanHeight() {}

    loadColumns() {
        this.columnConfiguration = [];

        this.columnConfiguration.push({
            heading: "Investigation NUMBER",
            fieldApiName: "Name",
            style: "width:110px;"
        });
        this.columnConfiguration.push({
            heading: "Investigation NAME",
            fieldApiName: "Investigation_Item_Name__c",
            class: "investigationNumber",
            style: "width:110px;"
        });
        this.columnConfiguration.push({
            heading: "CATEGORY",
            fieldApiName: "Category__c",
            style: "width:80px;"
        });
        this.columnConfiguration.push({
            heading: "RESULT",
            fieldApiName: "Result__c",
            style: "width:80px;"
        });
        this.columnConfiguration.push({
            heading: "OBSERVATIONS",
            fieldApiName: "Observations__c",
            style: "width:300px !important;"
        });
        this.columnConfiguration.push({
            heading: "ACTIONS",
            fieldApiName: "actions",
            style: "width:30px;"
        });
    }

    refreshTableData() {
        console.log("refreshTableDataCalled>>" + this.recordId);
        this.data = [];
        getInvestigationItemsRecords({
                idField: this.recordId
            })
            .then(result => {
                this.data = result;
                console.log("data" + JSON.stringify(this.data));
                this.isTableEmpty = this.data.length === 0 ? true : false;
                if (result.length > 0) {
                    if (
                        this.data[0].Investigation__r.Status__c ==
                        "Investigation Conducted"
                    ) {
                        this.isInvestigationComplete = true;
                    }
                }
            })
            .catch(error => {
                console.log("error occured>> " + error);
            });
    }
}