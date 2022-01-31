import { LightningElement, api, track } from "lwc";
import getProposalDetails from "@salesforce/apex/DESE_Title1Controller.getProposalDetails";
import saveProposalReservationDetails from "@salesforce/apex/DESE_Title1Controller.saveProposalReservationDetails";

export default class Dese_titlepart_aReservation extends LightningElement {
    @api projectId;
    @api readOnly;

    @track Title1AssessmentNeeds;
    @track Title1Districtdetermined;
   
    @track value1 = 0;
    @track value2 = 0;
    @track value3 = 0;
    @track value4 = 0;
    @track value5 = 0;
    @track value6 = 0;
    @track value7 = 0;
    @track value8 = 0;
    @track value9 = 0;
    @track total = 0;
    @track percent = 0;
    @track totalFunding;
    @track totalAllocation;

    @track t2Value1 = 0;
    @track t2Value2 = 0;
    @track t2Value3 = 0;
    @track t2Value4 = 0;
    @track t2R1 = 0;
    @track t2R2 = 0;
    @track t2R3 = 0;
    @track t2R4 = 0;

    genericHandler(event) {
        var inputname = event.target.name;
        this[inputname] = parseInt(event.target.value ? event.target.value : 0);
    }

    get totalsum() {
        return (this.total=
            this.value1 +
            this.value2 +
            this.value3 +
            this.value4 +
            this.value5 +
            this.value6 +
            this.value7 +
            this.value8 +
            this.value9);   
    }

    get totalpercent() {
        if (this.total != 0) {
            return (this.round((this.totalsum / this.totalFunding) * 100));
        }else{
            return 0;
        }
    }

    get r1(){
        return this.round(this.value1 / this.totalFunding * 100);
    }

    get r2(){
        return this.round(this.value2 / this.totalFunding * 100);
    }
    get r3(){
        return this.round(this.value3 / this.totalFunding * 100);
    }
    get r4(){
        return this.round(this.value4 / this.totalFunding * 100);
    }
    get r5(){
        return this.round(this.value5 / this.totalFunding * 100);
    }
    get r6(){
        return this.round(this.value6 / this.totalFunding * 100);
    }
    get r7(){
        return this.round(this.value7 / this.totalFunding * 100);
    }
    get r8(){
        return this.round(this.value8 / this.totalFunding * 100);
    }
    get r9(){
        return this.round(this.value9 / this.totalFunding * 100);
    }

    get balanceR(){
        return this.totalFunding - this.totalsum;
    }

    round(value) {
        var multiplier = Math.pow(10, 1 || 0);
        return parseInt(Math.round(value * multiplier) / multiplier ? Math.round(value * multiplier) / multiplier : 0);
    }

    handledataChange(event) {
        switch (event.target.name) {
            case "Title1AssessmentNeeds":
                this.Title1AssessmentNeeds = event.target.value;
                break;
            case "Title1Districtdetermined":
                this.Title1Districtdetermined = event.target.value;
                break;
        }
    }

    connectedCallback() {
        getProposalDetails({ projectId: this.projectId })
            .then((data) => {
                console.log("Currency Value ", data);
                this.Title1AssessmentNeeds = data.Title1AssessmentNeeds;
                this.Title1Districtdetermined = data.Title1Districtdetermined;
                this.value1 = parseInt(data.Tile1Equitable_participation ? data.Tile1Equitable_participation : 0);
                this.value2 = parseInt(data.Title1Family_Engagement ? data.Title1Family_Engagement : 0);
                this.value3 = parseInt(data.Title1ServiceslocalInstitution ? data.Title1ServiceslocalInstitution : 0);
                this.value4 = parseInt(data.Title1Administrative_services ? data.Title1Administrative_services : 0);
                this.value5 = parseInt(data.Title1Serviceshomeless ? data.Title1Serviceshomeless : 0);
                this.value6 = parseInt(data.Title1Fostercare ? data.Title1Fostercare : 0);
                this.value7 = parseInt(data.Title1Indirect_costs ? data.Title1Indirect_costs : 0);
                this.value8 = parseInt(data.Title1MTRS ? data.Title1MTRS : 0);
                this.value9 = parseInt(data.Title1ReservationOther ? data.Title1ReservationOther : 0);
                this.t2Value1 = data.Title1LowIncomeChildren;
                this.t2Value2 = data.Title1Below35;
                this.t2Value3 = data.Title1Above35;
                this.t2Value4 = data.Title1At35;
                this.totalFunding = data.totalFunding;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }

    @api submitRecord() {
        console.log("Submitting Reservations");
        var wrapperString = {
            Title1AssessmentNeeds: this.Title1AssessmentNeeds,
            Title1Districtdetermined: this.Title1Districtdetermined,
            Tile1Equitable_participation: this.value1,
            Title1Family_Engagement: this.value2,
            Title1ServiceslocalInstitution: this.value3,
            Title1Administrative_services: this.value4,
            Title1Serviceshomeless: this.value5,
            Title1Fostercare: this.value6,
            Title1Indirect_costs: this.value7,
            Title1MTRS: this.value8,
            Title1ReservationOther: this.value9,
            Title1LowIncomeChildren: this.t2Value1,
            Title1Below35: this.t2Value2,
            Title1Above35: this.t2Value3,
            Title1At35: this.t2Value4,
        };

        console.log("Wrapper String ", JSON.stringify(wrapperString));

        saveProposalReservationDetails({
            proposalId: this.projectId,
            wrapperString: JSON.stringify(wrapperString),
        })
            .then((data) => {
                if (data == "SUCCESS") {
                    console.log(JSON.stringify(data));
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }
}