/* eslint-disable no-console */
import { LightningElement, track, api, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";
import getInspectionItemsRecords from "@salesforce/apex/InspectionItemsController.getInspectionItemsRecords";
import updateInspectionItemsRecords from "@salesforce/apex/InspectionItemsController.updateInspectionItemsRecords";
import filterInspectionItemsRecords from "@salesforce/apex/InspectionItemsController.filterInspectionItemsRecords";
import inspectionComplete from "@salesforce/apex/InspectionItemsController.inspectionComplete";
import Internal_Bulk_Update_Help_Text from "@salesforce/label/c.Internal_Bulk_Update_Help_Text";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getregDetails from "@salesforce/apex/InspectionItemsController.getregulationDetails";

import { NavigationMixin } from "lightning/navigation";

import OBJECT_NAME from "@salesforce/schema/Inspection_Item__c";
import RESULT_FIELD from "@salesforce/schema/Inspection_Item__c.Result__c";
import CATEGORY_FIELD from "@salesforce/schema/Inspection_Item__c.Category__c";

export default class PsrInspectionItems extends NavigationMixin(
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
    @track regulation;
    // @track resultOptions;
    @track categoryOptions;
    @track isTableEmpty = false;
    @track isInspectionComplete = false;
    @track isValid = false;
    @track observationClass = "observationClass";
    value = '';
    @wire(getObjectInfo, { objectApiName: OBJECT_NAME })
    objectInfo;

    // @wire(getPicklistValues, {
    //     recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    //     fieldApiName: RESULT_FIELD
    // })
    // wiredResultOptions({ data, error }) {
    //     if (data) {
    //         this.resultOptions = data.values;
    //     }
    //     if (error) {
    //         console.log("test");
    //     }
    // }
    get resultOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Implemented', value: 'Compliant' },
            { label: 'Not Implemented', value: 'Non-Compliant' },
            { label: 'Partially Implemented', value: 'Not Applicable' },
            { label: 'Not Assessed', value: 'Not Assessed' },
        ];
    }
    get progTypeOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Devereux Advanced Behavioral Health', value: 'Devereux Advanced Behavioral Health' },
            { label: 'Devereux CARES Day', value: 'Devereux CARES Day' },
            { label: 'Devereux Residential', value: 'Devereux Residential' },
            { label: 'Devereux Day', value: 'Devereux Day' },
        ];
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

    handleInspectionCompleteClick() {
        this.showSpinner = true;
        inspectionComplete({
                idField: this.recordId
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Inspection Completed",
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
                    filterInspectionItemsRecords({
                        category: "",
                        result: event.detail.name,
                        type: "result",
                        idField: this.recordId
                    })
                    .then(result => {
                        this.data = result;
                        if (result.length > 0) {
                            if (
                                this.data[0].Inspection__r.Inspection_Status_Reason__c ==
                                "Inspection Conducted"
                            ) {
                                this.isInspectionComplete = true;
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
                    filterInspectionItemsRecords({
                        category: event.detail.name,
                        result: "",
                        type: "category",
                        idField: this.recordId
                    })
                    .then(result => {
                        this.data = result;
                        if (result.length > 0) {
                            if (
                                this.data[0].Inspection__r.Inspection_Status_Reason__c ==
                                "Inspection Conducted"
                            ) {
                                this.isInspectionComplete = true;
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

    /*get resultOptions() {
                                                                                                        return [
                                                                                                            { label: '--None--', value: '' },
                                                                                                            { label: 'Compliant', value: 'Compliant' },
                                                                                                            { label: 'Non-Compliant', value: 'Non-Compliant' },
                                                                                                            { label: 'Not Applicable', value: 'Not Applicable' },
                                                                                                            { label: 'Not Assessed', value: 'Not Assessed' },
                                                                                                        ];
                                                                                                    }

                                                                                                    get categoryOptions() {
                                                                                                        return [
                                                                                                            { label: '--None--', value: '' },
                                                                                                            { label: 'Transportation', value: 'Transportation' },
                                                                                                            { label: 'Administration', value: 'Administration' },
                                                                                                            { label: 'Care of Children', value: 'Care of Children' },
                                                                                                        ];
                                                                                                    }*/

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
                objectApiName: "Inspection_Item__c",
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
        updateInspectionItemsRecords({
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

    reloadWindow(){
        window.location.reload();
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
            if (event.target.value == "Non-Compliant") {
                this.isNonComplaint = true;
            }
        } else if (event.target.name === "observation") {
            fields = {
                Id: event.currentTarget.dataset.recid,
                Observations__c: event.target.value
            };
        }
        console.log("Fields::" + JSON.stringify(fields));
        let obs, res, inspectionName;
        //Validate data
        if (this.data.length > 0) {
            for (let i = 0; i < this.data.length; i++) {
                if (this.data[i].Id == event.currentTarget.dataset.recid) {
                    inspectionName = this.data[i].Name;
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
            if (event.target.value === "Non-Compliant" && obs === undefined) {
                console.log("Fill observation");
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Please fill Observations for " + inspectionName,
                        variant: "error"
                    })
                );
                //this.refreshTableData();
                this.showSpinner = false;
                return;
            }
        } else if (event.target.name === "observation") {
            console.log("Value::" + event.target.value);
            if (event.target.value === "" && res === "Non-Compliant") {
                console.log("Fill Result");
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Observations cannot be empty for " + inspectionName,
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

    /*handleChange(event){
                                                                                                        this.jsObject = [];
                                                                                                        if(event.target.name === 'result'){
                                                                                                            this.jsObject.push({
                                                                                                                Result : event.detail.value,
                                                                                                                Recid: event.currentTarget.dataset.recid,
                                                                                                                Name : 'result',
                                                                                                            });
                                                                                                        }
                                                                                                        else if(event.target.name === 'observation'){
                                                                                                            this.jsObject.push({
                                                                                                                Observation : event.target.value,
                                                                                                                Recid: event.currentTarget.dataset.recid,
                                                                                                                Name : 'observation',
                                                                                                            });
                                                                                                        }
                                                                                                        else if(event.target.name === 'techAssistance'){
                                                                                                            this.jsObject.push({
                                                                                                                TechAssistance : event.target.value,
                                                                                                                Recid: event.currentTarget.dataset.recid,
                                                                                                                Name : 'techAssistance',
                                                                                                            });
                                                                                                        }
                                                                                                    }*/

    connectedCallback() {
        this.loadColumns();
        this.refreshTableData();
        console.log("result picklist>>>" + JSON.stringify(this.resultOptions));
    }

    setCorrectionPlanHeight() {}

    loadColumns() {
        this.columnConfiguration = [];

        this.columnConfiguration.push({
            heading: "CRITERION NUMBER",
            fieldApiName: "Name",
            style: "width:90px;"
        });
        this.columnConfiguration.push({
            heading: "CRITERION NAME",
            fieldApiName: "Inspection_Item_Name__c",
            class: "inspectionNumber",
            style: "width:110px;"
        });
        this.columnConfiguration.push({
            heading: "AREA",
            fieldApiName: "Category__c",
            style: "width:40px;"
        });
        this.columnConfiguration.push({
            heading: "RESULT",
            fieldApiName: "Result__c",
            style: "width:50px;"
        });
        this.columnConfiguration.push({
            heading: "PROGRAM TYPE",
            fieldApiName: "",
            style: "width:90px;"
        });
        this.columnConfiguration.push({
            heading: "OBSERVATIONS",
            fieldApiName: "Observations__c",
            style: "width:150px !important;"
        });
        this.columnConfiguration.push({
            heading: "TECHNICAL ASSISTANCE",
            fieldApiName: "",
            style: "width:150px !important;"
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
        getInspectionItemsRecords({
                idField: this.recordId
            })
            .then(result => {
                this.data = result;
                console.log("data" + JSON.stringify(this.data));
                this.isTableEmpty = this.data.length === 0 ? true : false;
                if (result.length > 0) {
                    if (
                        this.data[0].Inspection__r.Inspection_Status_Reason__c ==
                        "Inspection Conducted"
                    ) {
                        this.isInspectionComplete = true;
                    }
                }
            })
            .catch(error => {
                console.log("error occured>> " + error);
            });
    }

    handleNewVisitItem(event){

        const defaultValues = encodeDefaultFieldValues({
            Inspection__c : this.recordId
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Inspection_Item__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }
    isModalOpen = false;

    closeModal(){
        this.isModalOpen = false;
    }

    handleRegulationClick(event){
        let regId = event.currentTarget.dataset.regid;
        getregDetails({
            regid : regId
        })
        .then(data=>{
            this.regulation = JSON.parse(data);
            this.isModalOpen = true;
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
    }
}