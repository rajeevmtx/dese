import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTools from '@salesforce/apex/DESE_SwitchController.getToolsList';
import updateInspection from '@salesforce/apex/DESE_SwitchController.updateInspectionTool';

export default class Dese_switch_tool extends LightningElement {

    @api recordId;
    @api mode;

    @track spinner;
    @track errorMessage;
    @track inspectionRecord;
    @track isOtherToolsAvailable = false;
    @track isOtherToolSelected = false;
    @track justificationText;
    @track otherToolSelection=[];
    @track selectedTool;
    @track typeOfVisit;

    connectedCallback(){
        this.spinner = true;
        getTools({recordId : this.recordId})
        .then(data=>{
            var response = JSON.parse(data);
            this.inspectionRecord = response.inspectionRecord;
            if(response.toolList.length >0 ){
                this.isOtherToolsAvailable = true;
                var tools = response.toolList;
                tools.forEach( row=>{
                    this.otherToolSelection.push({label : row.Name, value:row.Id});
                })
            } else{
                this.isOtherToolsAvailable = false;
            }
            this.spinner = false;
        })
        .catch(error=>{
            let message = error.message || error.body.message;
            console.log('error in get visit tool >>> '+JSON.stringify(error));
            this.spinner = false;
        })
    }

    handleOnChange(event){
        this.isOtherToolSelected = true;
        this.selectedTool = event.target.value;
        console.log('  this.selectedTool >> '+  this.selectedTool)
    }


    addJustification(event){
        this.justificationText = event.target.value;
    }

    validationCheck(){
        //alert(this.justificationText);
        if(this.selectedTool == 'none' && this.inspectionRecord.Status__c == 'Closed'){
            this.showToast('Tool cannot be removed when visit is completed','error','Info');
        }
        else if(this.selectedTool !== undefined && this.selectedTool !== null && this.selectedTool !== ''){
            if(!this.isOtherToolSelected){
                this.saveChanges();
            }else{
                if(this.isOtherToolSelected && this.justificationText !== '' && this.justificationText != undefined){
                    this.saveChanges();
                }else{
                    this.showToast('Please add Justification','error','Error!');
                }
            }
        }else{
            this.showToast('Please select a tool.','error','Error!');
        }
    }

    saveChanges(){
        this.spinner = true;
        updateInspection({
            recordId : this.recordId,
            toolId : this.selectedTool,
            justify : this.justificationText
        }).then(data=>{
            if(data == 'SUCCESS'){
                const refreshComponent = new CustomEvent(
                    'refreshcomponent',{});
                this.dispatchEvent(refreshComponent);
                this.showToast(result.SUCCESS,'success','Success!');
            }
        }).catch(error => {
            let message = error.message || error.body.message;
            console.log('error in get visit tool >>> '+JSON.stringify(error));
            this.spinner = false;
        })
        
    }

    showToast(message,toastType,title) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: toastType
        });
        this.dispatchEvent(event);
    }

}