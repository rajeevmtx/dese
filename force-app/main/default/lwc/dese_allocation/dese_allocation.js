import { LightningElement, api } from 'lwc';
import saveAllocationAndFlexing from '@salesforce/apex/DESE_IntakeAllocationController.saveAllocationAndFlexing';
import getAllocationAndFlexingDetails from '@salesforce/apex/DESE_IntakeAllocationController.getAllocationAndFlexingDetails';

export default class Dese_allocation extends LightningElement {
    @api allocations;
    @api projectId;
    @api readOnly;
    activeSections = ['A','B','C','D'];
    inputval1 = 0;
    inputval2 = 0;
    inputval3 = 0;
    inputval4 = 0;
    total = 0;
    total2 = 0;
    total3 = 0;
    total4 = 0;
    T2val1 = 0;
    T2val2 = 0;
    T2val3 = 0;
    T2val4 = 0;
    T3val1 = 0;
    T4val1 = 0;
    T4val2 = 0;
    T4val3 = 0;
    T4val4 = 0;
    errormsg = '';
    errormsg1 = '';
    showSpinner = false;
    genericHandler(event) {
        //this.val1=event.target.value;
        var inputname = event.currentTarget.dataset.id;
        //console.log(event.currentTarget.dataset.id);
        this[inputname] = parseInt(event.target.value ? event.target.value : 0);
    }

    //total sum of Table1
    get totalsum() {
        return this.total = this.inputval1 + this.T2val2 + this.T4val2;
    }
    //total sum of Table2
    get totalsum2() {
        //console.log(this.total2);
        this.total2 = this.inputval2 + this.T4val3 - (this.T2val2 + this.T2val3 + this.T2val4);
        return this.total2;
    }
    //total sum of Table3
    get totalsum3() {
        return this.total3 = this.inputval3 + this.T2val3 + this.T4val4;
    }
    //total sum of Table4
    get totalsum4() {
        this.total4 = this.inputval4 + this.T2val4 - (this.T4val2 + this.T4val3 + this.T4val4);
        return this.total4;
    }
    get negativeVar1() {
        return (this.total2 < 0);
    }
    get negativeVar2() {
        return (this.total4 < 0);
    }
    handlePrev() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    connectedCallback(){
        window.scrollTo(0, 0);
        getAllocationAndFlexingDetails({
            proposalId : this.projectId
        })
        .then(data => {
            let result = JSON.parse(data);
            console.log(data);
            this.inputval1 = result.totalAllocationTitleI ;
            this.inputval2 = result.totalAllocationTitleII; 
            this.inputval3 = result.totalAllocationTitleIII; 
            this.inputval4 = result.totalAllocationTitleIV; 
            // this.totalsum = result.postFlexingTitleI; 
            // this.totalsum2 = result.postFlexingTitleII; 
            // this.totalsum3 = result.postFlexingTitleIII; 
            // this.totalsum4 = result.postFlexingTitleIV ;
            this.T2val2 = result.titleIIFundsTitleI ;
            this.T2val3 = result.titleIIFundsTitleIII; 
            this.T2val4 = result.titleIIFundsTitleIV ;
            this.T4val2 = result.titleIVFundsTitleI ;
            this.T4val3 = result.titleIVFundsTitleII ;
            this.T4val4 = result.titleIVFundsTitleIII;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }

    // renderedCallback(){
    //     if(this.readOnly == true){
    //         getAllocationAndFlexingDetails({
    //             proposalId : this.projectId
    //         })
    //         .then(data => {
    //             let result = JSON.parse(data);
    //             console.log(data);
    //             this.inputval1 = result.totalAllocationTitleI ;
    //             this.inputval2 = result.totalAllocationTitleII; 
    //             this.inputval3 = result.totalAllocationTitleIII; 
    //             this.inputval4 = result.totalAllocationTitleIV; 
    //             // this.totalsum = result.postFlexingTitleI; 
    //             // this.totalsum2 = result.postFlexingTitleII; 
    //             // this.totalsum3 = result.postFlexingTitleIII; 
    //             // this.totalsum4 = result.postFlexingTitleIV ;
    //             this.T2val2 = result.titleIIFundsTitleI ;
    //             this.T2val3 = result.titleIIFundsTitleIII; 
    //             this.T2val4 = result.titleIIFundsTitleIV ;
    //             this.T4val2 = result.titleIVFundsTitleI ;
    //             this.T4val3 = result.titleIVFundsTitleII ;
    //             this.T4val4 = result.titleIVFundsTitleIII;
    //         })
    //         .catch(error => {
    //             console.log(JSON.stringify(error));
    //         })
    //     }
    // }


    activeSection = 'A';
    handleNext() {
        var wrapperString = {
        totalAllocationTitleI : this.inputval1,
        totalAllocationTitleII : this.inputval2,
        totalAllocationTitleIII : this.inputval3,
        totalAllocationTitleIV : this.inputval4,
        postFlexingTitleI : this.totalsum,
        postFlexingTitleII : this.totalsum2,
        postFlexingTitleIII : this.totalsum3,
        postFlexingTitleIV : this.totalsum4,
        titleIIFundsTitleI : this.T2val2,
        titleIIFundsTitleIII : this.T2val3,
        titleIIFundsTitleIV : this.T2val4,
        titleIVFundsTitleI : this.T4val2,
        titleIVFundsTitleII : this.T4val3,
        titleIVFundsTitleIII : this.T4val4
        }
        const accordion = this.template.querySelector('.example-accordion');
        if(this.activeSection == 'A'){
            this.activeSection = 'B';
            accordion.activeSectionName = 'B';
            return;
        }
        if(this.activeSection == 'B'){
            this.activeSection = 'C';
            accordion.activeSectionName = 'C';
            return;
        }
        if(this.activeSection == 'C'){
            this.activeSection = 'D';
            accordion.activeSectionName = 'D';
            return;
        }
        this.showSpinner = true;
        saveAllocationAndFlexing({
            proposalId : this.projectId,
            wrapperString : JSON.stringify(wrapperString)
        }).then( data => {
            if(data == 'SUCCESS'){
                this.dispatchEvent(new CustomEvent('next'));
            }
        }).catch(error => {
            console.log(JSON.stringify(error));
        }).finally(() => {
            this.showSpinner = false;
        })

        //this.dispatchEvent(new CustomEvent('next'));
    }
    handleToggleSection(event) {
        this.activeSection = event.detail.openSections;
    }
}