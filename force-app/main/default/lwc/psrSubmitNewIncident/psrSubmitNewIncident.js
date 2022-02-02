import { LightningElement, track, api} from 'lwc';
import fetchCases from '@salesforce/apex/PSR_CaseController.fetchCases';
import { updateRecord } from 'lightning/uiRecordApi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import ID_FIELD from '@salesforce/schema/Case.Id';
import Portal_Helpdesk_Help_Text from '@salesforce/label/c.Portal_Helpdesk_Help_Text';


export default class PsrSubmitNewIncident extends LightningElement { 
    @track show1 = false;
    @track show2 = false;
    @track num = 3;
    @track currentEvId = "a0a03000000FPZyAAO";
    @track isEmailOpen = false;
    @track isChatterOpen = false;
    @track uploadedFileNames='';
    @track isIncidentOpen=false;
    @track isNewCase = false;
    @track cases = [];
    @track currentCase = {
        Id : '3',
        TypeOfCase : 'Supervision concern',
        InjuryCategory : 'Child Injury/Major',
        Description : 'Child transported to hospital for treatment',
        Transported : 'Yes',
        CreatedDate : '2020-09-13',
        Show : false,
    };
    @track caseId;
    @track isChatterModalOpen = false;
    @api Portal_Helpdesk_Help_Text = Portal_Helpdesk_Help_Text;
    get fetchTodayDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, "0");
        var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
        var yyyy = today.getFullYear();
    
        var todayValue = yyyy + "-" + mm + "-" + dd;
        return todayValue;
      }
    get InjuryCategoryPicklistValues() {
        return [
        { label: 'Child Incident/Minor', value: 'Child Injury/Minor' },
        { label: 'Child Incident/Major', value: 'Child Injury/Major' },
        { label: 'Hospital or Ambulance Call', value: 'Hospital or Ambulance Call' },
        { label: 'Serious Incident', value: 'Serious Injury' },
    ];
}

get YesNoPicklistValues() {
    return [
    { label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' },
];
}

connectedCallback(){
    
}

    openModalIncident() {
        this.isIncidentOpen = true;
    }
    closeModalIncident() {
        this.isIncidentOpen = false;
    }
    submitDetailsIncident() {
        this.currentCase['Id'] = 'show' + this.num ;
        this.currentCase['CreatedDate'] =  this.fetchTodayDate ;
        this.cases.push(this.currentCase);
        this.isIncidentOpen = false;
        this.currentCase = {} ;
        this.num = this.num + 1;
    }

    handleInputChange(event) {
        this.currentCase[event.target.name] = event.target.value;
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.uploadedFileNames = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            if(i==uploadedFiles.length-1)
            this.uploadedFileNames += uploadedFiles[i].name ;
            else
            this.uploadedFileNames += uploadedFiles[i].name + ', ';
        }
    }

    openModalChatter(event) {
       
        //this.currentEvId = event.currentTarget.getAttribute("data-id");
        this.isChatterOpen = true;
    }

    closeModalChatter() {
        this.isChatterOpen = false;
    }

    get fullUrl() {
        let url0 = window.location.protocol+'//'+window.location.hostname;
            let url = '/psr/apex/PsrChatterPage?id=';
            let completeURL = url0+url+this.currentEvId;
             //"https://demo-lp.force.com/psr/apex/PsrChatterPage?id=" + this.currentEvId
        return (
            completeURL 
        );
    }

    
    openModalEmail() {
        this.isEmailOpen = true;
    }
    closeModalEmail() {
        this.isEmailOpen = false;
    }
    submitDetailsEmail() {
        this.isEmailOpen = false;
    }

    viewDiv1(event) {
        let temp = event.target.type;
        console.log(temp);
        //let substr = temp.substring(4, temp.length);
          //  console.log(substr);
        if (temp.indexOf('show1') > -1)
        this.show1 = !this.show1;
        else if (temp.indexOf('show2') > -1)
        this.show2 = !this.show2;
        else{
            console.log('element');
            this.cases.forEach(element => {
                console.log(element);
                if(element.Id==temp){
                    element['Show'] = !element['Show'] ;
                }
            });
        }

    }

}