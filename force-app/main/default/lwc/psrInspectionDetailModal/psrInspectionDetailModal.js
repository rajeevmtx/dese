/* eslint-disable no-console */

import { LightningElement, api, track } from "lwc";
import fetchInspectionList from "@salesforce/apex/PSR_InspectionDetailController.fetchInspectionDetails";

export default class PsrInspectionDetailModal extends LightningElement {
  @api workId;
  @track inspectionList = [];
  @track columnConfiguration;
  @track childColumnConfiguration;
  @track showMessage = false;
  @track accordianCheck = false;

  connectedCallback() {
    this.loadColumns();
    this.loadData();
    this.loadChildColumns();
  }
  loadColumns() {
    this.columnConfiguration = [];
    this.columnConfiguration.push({
      heading: "Inspection Number"
    });
    this.columnConfiguration.push({
      heading: "Application Number"
    });
    this.columnConfiguration.push({
      heading: "Start Date Time"
    });
    this.columnConfiguration.push({
      heading: "End Date Time"
    });
    this.columnConfiguration.push({
      heading: "Inspector Name"
    });
  }
  loadChildColumns() {
    this.childColumnConfiguration = [];
    this.childColumnConfiguration.push({
      heading: "Domain Category"
    });
    this.childColumnConfiguration.push({
      heading: "Level of Compliance"
    });
    this.childColumnConfiguration.push({
      heading: "Indicator"
    });
  }
  loadData() {
    fetchInspectionList({ applicationWorkOrderId: this.workId }).then(res => {
      let inspectionArray = JSON.parse(JSON.stringify(res));
      let count;
      if (inspectionArray.length < 1) {
        this.inspectionList = [];
        this.showMessage = true;
      } else {
        inspectionArray.forEach(element => {
          count = 0;
          element.showChilds = false;
          if (element.inspectionItemsList.length === 0) {
            element.showNoInspectionItemError = true;
          } else {
            element.showNoInspectionItemError = false;
          }
          element.inspectionItemsList.forEach(element1 => {
            count = 0;
            element1.showItems = false;
            element1.inspectionItems.forEach(element2 => {
              if (element2.Result__c === "Compliant") {
                count++;
                element2.isCompliant = true;
              }
              if (element2.Result__c === "Non-Compliant") {
                element2.isNonCompliant = true;
                count++;
              }
            });
            console.log("count" + count);
            if (count === 0) {
              element1.showMessage = true;
            } else {
              element1.showMessage = false;
            }
          });
        });
        this.inspectionList = inspectionArray;
      }
    });
  }
  handleCloseModal() {
    // Creates the event with the data.
    const selectedEvent = new CustomEvent("closemodal", {
      detail: ""
    });
    this.dispatchEvent(selectedEvent);
  }
  handleExpand(event) {
    let _parentId = event.target.dataset.pid;
    this.inspectionList.forEach(element => {
      if (element.inspectionId === _parentId) {
        element.showChilds = true;
      }
    });
    // console.log('this.inspectionList EXPAND: ',JSON.stringify(this.inspectionList));
  }
  handleCollapse(event) {
    let _parentId = event.target.dataset.pid;
    this.inspectionList.forEach(element => {
      if (element.inspectionId === _parentId) {
        element.showChilds = false;
      }
    });
    // console.log('this.inspectionList COLLAPSE: ',JSON.stringify(this.inspectionList));
  }
  handleExpandCategory(event) {
    let _parentId = event.target.dataset.pid;
    this.inspectionList.forEach(element => {
      element.inspectionItemsList.forEach(element1 => {
        if (element1.category === _parentId) {
          element1.showItems = true;
        }
      });
    });
  }
  handleCollapseCategory(event) {
    let _parentId = event.target.dataset.pid;
    this.inspectionList.forEach(element => {
      element.inspectionItemsList.forEach(element1 => {
        if (element1.category === _parentId) {
          element1.showItems = false;
        }
      });
    });
  }
}