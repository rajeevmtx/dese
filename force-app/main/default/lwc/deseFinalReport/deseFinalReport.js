import { LightningElement, track, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { CurrentPageReference } from "lightning/navigation";
import Id from "@salesforce/user/Id";
import UserName from "@salesforce/schema/User.Name";
import UserTitle from "@salesforce/schema/User.Title";
import UserEmail from "@salesforce/schema/User.Email";
import submitFinalReport from "@salesforce/apex/DESE_ProposalController.submitFinalReport";
import getFinalReport from "@salesforce/apex/DESE_ProposalController.getFinalReport";
import deseDesign from '@salesforce/resourceUrl/DESE_Design';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEnvelope from "@salesforce/apex/EmbeddedSigningController.sendEnvelope";
import getEmbeddedSigningUrl from "@salesforce/apex/EmbeddedSigningController.getEmbeddedSigningUrl";


export default class DeseFinalReport extends LightningElement {
    notebook = deseDesign + '/theme/images/notebook.png';

    @track approvedBudgetSupervisor = 0;
    @track approvedBudgetPC = 0;
    @track approvedBudgetStipend = 0;
    @track approvedBudgetOther = 0;
    @track fundsExpendedSupervisor = 0;
    @track fundsExpendedPC = 0;
    @track fundsExpendedStipend = 0;
    @track fundsExpendedOther = 0;
    @track balanceUnexpendedSupervisor = 0;
    @track balanceUnexpendedPC = 0;
    @track balanceUnexpendedStipend = 0;
    @track balanceUnexpendedOther = 0;
    @track checkEnclosedAmount = 0;
    @track userName = "";
    @track userTitle = "";
    @track userEmail = "";
    @track showSpinner = true;
    @track projectId = "";
    @track disableSubmit = true;
    template = "29dba4bc-a627-4819-9613-62c856a24974";
    description = "Embedded Signing";

    get balanceUnexpendedSubTotal() {
        return (
            this.balanceUnexpendedOther +
            this.balanceUnexpendedPC +
            this.balanceUnexpendedStipend +
            this.balanceUnexpendedSupervisor
        );
    }
    get fundsExpendedSubTotal() {
        return (
            this.fundsExpendedOther +
            this.fundsExpendedPC +
            this.fundsExpendedStipend +
            this.fundsExpendedSupervisor
        );
    }
    get approvedBudgetSubTotal() {
        return (
            this.approvedBudgetOther +
            this.approvedBudgetPC +
            this.approvedBudgetStipend +
            this.approvedBudgetSupervisor
        );
    }
    get options() {
        return [
            { label: "Check Enclosed", value: "Check Enclosed" },
            { label: "Funds Not Requested", value: "Funds Not Requested" },
        ];
    }

    @wire(CurrentPageReference)
    getProjectId(currentPageReference) {
        if (currentPageReference) {
            console.log(
                "Project/Proposal Id: ",
                currentPageReference.state.projectId
            );
            this.projectId = currentPageReference.state.projectId;
            if(currentPageReference.state.event){
                this.disableSubmit = false;
            }
        }
    }
    @wire(getRecord, { recordId: Id, fields: [UserName, UserTitle, UserEmail] })
    userDetails({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.userTitle = data.fields.Title.value;
            this.userEmail = data.fields.Email.value;
            this.showSpinner = false;
        } else if (error) {
            console.log("Wire method error: ", error);
            this.showSpinner = false;
        }
    }
    connectedCallback() {
        this.showSpinner = true;
        getFinalReport({
            proposalID: this.projectId,
        })
            .then((result) => {
                console.log("getFinalReport Result: ", result);
                if (result != null) {
                    const data = JSON.parse(result);
                    this.approvedBudgetOther = data.Approved_Budget_Other__c ? data.Approved_Budget_Other__c : 0;
                    this.approvedBudgetPC =
                        data.Approved_Budget_Project_Coordinator__c ? data.Approved_Budget_Project_Coordinator__c : 0;
                    this.approvedBudgetStipend =
                        data.Approved_Budget_Stipend__c ? data.Approved_Budget_Stipend__c : 0;
                    this.approvedBudgetSupervisor =
                        data.Approved_Budget_Supervisor_Director__c ? data.Approved_Budget_Supervisor_Director__c : 0;
                    this.fundsExpendedOther = data.Funds_Expended_Other__c ? data.Funds_Expended_Other__c : 0;
                    this.fundsExpendedPC =
                        data.Funds_Expended_Project_Coordinator__c ? data.Funds_Expended_Project_Coordinator__c : 0;
                    this.fundsExpendedStipend = 
                        data.Funds_Expended_Stipend__c ? data.Funds_Expended_Stipend__c : 0;
                    this.fundsExpendedSupervisor =
                        data.Funds_Expended_Supervisor_Director__c ? data.Funds_Expended_Supervisor_Director__c : 0;
                    this.balanceUnexpendedOther =
                        data.Balance_Unexpended_Other__c ? data.Balance_Unexpended_Other__c : 0;
                    this.balanceUnexpendedPC =
                        data.Balance_Unexpended_Project_Coordinator__c ? data.Balance_Unexpended_Project_Coordinator__c : 0;
                    this.balanceUnexpendedStipend =
                        data.Balance_Unexpended_Stipend__c ? data.Balance_Unexpended_Stipend__c : 0;
                    this.balanceUnexpendedSupervisor =
                        data.Balance_Unexpended_Supervisor_Director__c ? data.Balance_Unexpended_Supervisor_Director__c : 0;
                    this.checkEnclosedAmount = data.Check_Enclosed_Amount__c ? data.Check_Enclosed_Amount__c : 0;
                }

                this.showSpinner = false;
            })
            .catch((error) => {
                console.log("getFinalReport Error: ", error);
                this.showSpinner = false;
            });
    }
    handleTableFields(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        this[fieldName] = parseInt(value);
    }
    handleToggleChange(event) {}
    handleSubmit() {
        this.showSpinner = true;
        let data = {
            approvedBudgetSupervisor: this.approvedBudgetSupervisor,
            approvedBudgetPC: this.approvedBudgetPC,
            approvedBudgetStipend: this.approvedBudgetStipend,
            approvedBudgetOther: this.approvedBudgetOther,
            fundsExpendedSupervisor: this.fundsExpendedSupervisor,
            fundsExpendedPC: this.fundsExpendedPC,
            fundsExpendedStipend: this.fundsExpendedStipend,
            fundsExpendedOther: this.fundsExpendedOther,
            balanceUnexpendedSupervisor: this.balanceUnexpendedSupervisor,
            balanceUnexpendedPC: this.balanceUnexpendedPC,
            balanceUnexpendedStipend: this.balanceUnexpendedStipend,
            balanceUnexpendedOther: this.balanceUnexpendedOther,
            checkEnclosedAmount: this.checkEnclosedAmount,
            userName: this.userName,
            userTitle: this.userTitle,
            userEmail: this.userEmail,
            reportId: this.projectId,
            status : 'Draft'
        };
        submitFinalReport({
            data: JSON.stringify(data),
        })
            .then((result) => {
                // console.log("SubmitFinalReport result: ", result);
                // const toastevent = new ShowToastEvent({
                //     title: 'Success',
                //     message:
                //         'Final Report Submitted Successfully.',
                //     variant : 'success',
                // });
                // this.dispatchEvent(toastevent);
                //window.open("/dese/s/grants-dashboard", "_self");
                sendEnvelope({
                    template: this.template,
                    description: this.description,
                    recordId: this.projectId,
                })
                    .then((envelopeId) =>
                        getEmbeddedSigningUrl({
                            envId: envelopeId,
                            url: window.location.href,
                        })
                    )
                    .then((signingUrl) => {
                        console.log(signingUrl);
                        window.location.href = signingUrl;
                        this.showSpinner = false;
                    })
                    .catch((error) => {
                        console.log("Error:");
                        console.log(error);
                        this.showSpinner = false;
                    });
            })
            .catch((error) => {
                console.log("SubmitFinalReport error: ", error);
            })
            .finally(()=>{
                this.showSpinner = false;
            });
    }
    handleCancel() {
        window.open("/dese/s", "_self");
    }
    redirectToInfo() {
        window.open(
            "https://mtxlicensingpermit--desedemo--c.documentforce.com/sfc/servlet.shepherd/version/download/06803000001rYpt?asPdf=false&operationContext=CHATTER",
            "_blank"
        );
    }

    // handleClick() {
    //     this.showSpinner = true;
    //     //console.log(this.recordId);
    //     this.handleSubmit();
        
    // }

    handleFinalSubmit(){
        this.showSpinner = true;
        let data = {
            approvedBudgetSupervisor: this.approvedBudgetSupervisor,
            approvedBudgetPC: this.approvedBudgetPC,
            approvedBudgetStipend: this.approvedBudgetStipend,
            approvedBudgetOther: this.approvedBudgetOther,
            fundsExpendedSupervisor: this.fundsExpendedSupervisor,
            fundsExpendedPC: this.fundsExpendedPC,
            fundsExpendedStipend: this.fundsExpendedStipend,
            fundsExpendedOther: this.fundsExpendedOther,
            balanceUnexpendedSupervisor: this.balanceUnexpendedSupervisor,
            balanceUnexpendedPC: this.balanceUnexpendedPC,
            balanceUnexpendedStipend: this.balanceUnexpendedStipend,
            balanceUnexpendedOther: this.balanceUnexpendedOther,
            checkEnclosedAmount: this.checkEnclosedAmount,
            userName: this.userName,
            userTitle: this.userTitle,
            userEmail: this.userEmail,
            reportId: this.projectId,
            status : 'Submitted'
        };
        submitFinalReport({
            data: JSON.stringify(data),
        })
            .then((result) => {
                console.log("SubmitFinalReport result: ", result);
                const toastevent = new ShowToastEvent({
                    title: 'Success',
                    message:
                        'Final Report Submitted Successfully.',
                    variant : 'success',
                });
                this.dispatchEvent(toastevent);
                window.open("/dese/s/grants-dashboard", "_self");
               
            })
            .catch((error) => {
                console.log("SubmitFinalReport error: ", error);
            })
            .finally(()=>{
                this.showSpinner = false;
            });
    }
}