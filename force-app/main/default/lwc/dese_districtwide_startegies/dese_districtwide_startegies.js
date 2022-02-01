import { LightningElement,track,api} from 'lwc';
import saveDistrictWideStrategies from '@salesforce/apex/DESE_DistrictwideStrategiesController.saveDistrictWideStrategies';
import getDistrictWideStrategiesDetails from '@salesforce/apex/DESE_DistrictwideStrategiesController.getDistrictWideStrategiesDetails';
import getProjectInitiative from '@salesforce/apex/DESE_DistrictwideStrategiesController.getProjectInitiative';
import saveProjectInitiative from '@salesforce/apex/DESE_DistrictwideStrategiesController.saveProjectInitiative';
import deseDesign from '@salesforce/resourceUrl/DESE_Design';
var sourceset=new Set();
var dataset=new Set();
export default class Dese_districtwide_startegy_and_planning extends LightningElement {
    notebook = deseDesign + '/theme/images/notebook.png';
    value = 'Yes';
    @api readOnly;
    @track DistrictStrategicPlagroups='';
    @track AllDistrictPrincipalData=''
    @track AllDistrictPrincipalSources='';
    @track ESSAFundsFY21='';
    @track planDescription='';
    @track familyDescription='';
    @track equitableAccessDescription='';
    @track dataEvaluationDescription='';
    @track equitableAccessDistrictRequired = false;
    @track initiativeName='';
    @track initiativeStrategies='';
    @track initiativeActivityConnected = false;
    @track showModal = false;
    showSpinner = false;
     result2=[];
     @track result3=[];
     essavalue=[];
     AllDistrictPrincipalDataValue=[];
     @track items11=[];
     @track items22=[];
     AllDistrictPrincipalSourcesValue=[];
     initiative = [];
    @api projectId;

    get hasinitiative(){
        
        return this.initiative.length;
    }
    get AllDistrictPrincipalDataOptions(){
        return [
            { label: 'ACCESS data', value: 'ACCESS data' },
            { label: 'Attendance data (educators)', value: 'Attendance data (educators)' },
            
        ];
    }
    get AllDistrictPrincipalSourcesOptions(){
        return [
            { label: 'ACCESS data', value: 'ACCESS data' },
            { label: 'Attendance data (educators)', value: 'Attendance data (educators)' },
            { label: 'Attendance data (students)', value: 'Attendance data (students)' },
            { label: 'CHART reports', value: 'CHART reports' },
            { label: 'College application,enrollment and completion data', value: 'College application,enrollment and completion data' },
            { label: 'DART reports', value: 'DART reports' },
            { label: 'Discipline data', value: 'Discipline data' },
            { label: 'District assessments', value: 'District assessments' },
            { label: 'District -sponsored research', value: 'District -sponsored research' },
            { label: 'Educator evaluation data', value: 'Educator evaluation data' },
            { label: 'Early warning Indicator System (EWIS) data', value: 'Early warning Indicator System (EWIS) data' },
            { label: 'Learning walks/teacher observation', value: 'Learning walks/teacher observation' },
            { label: 'MCAS data', value: 'MCAS data'},
            { label: 'Peer-reviewed research', value: 'Peer-reviewed research'},
            { label: 'RADAR reports', value: 'RADAR reports'},
            { label: 'Student report cards', value: 'Student report cards'},
            { label: 'Student accountability data', value: 'Student accountability data'},
            { label: 'Student Learning Experience reports', value: 'Student Learning Experience reports'},
            { label: 'Survey - School Climate (student)', value: 'Survey - School Climate (student)'},
            { label: 'Survey - Other', value: 'Survey - Other'},
            { label: 'Workforce outcomes data', value: 'Workforce outcomes data'},
            { label: 'Other', value: 'Other'},
            { label: 'None', value: 'None'}
        ];
    }
    get essaOptions(){
        return [
            { label: 'Community Partners and Members', value: 'Community Partners and Members' },
            { label: 'Families', value: 'Families' },
            { label: 'Paraprofessionals', value: 'Paraprofessionals' },
            { label: 'Principals/Other School Leaders', value: 'Principals/Other School Leaders' },
            { label: 'Teachers', value: 'Teachers' }
        ];
    }

    get options() {
        return [
            { label: 'Yes', value: true },
            { label: 'No', value: false }
        ];
    }
   handleChange(event)
    {   
        console.log('event---'+event.detail.value);
        if(event.target.name== "AllDistrictPrincipalData"){
            this.items11.push({label:event.target.value});
        }if(event.target.name== "AllDistrictPrincipalSources"){
            this.items22.push({label:event.target.value});
        }
        if(event.target.name== "essaOptions"){
            this.essavalue = event.target.value;
        }
        if(event.target.name== "ESSAFundsFY21"){
            this.ESSAFundsFY21 = event.target.value;
        }else if(event.target.name== "planDescription"){
            this.planDescription = event.target.value;
        }else if(event.target.name== "familyDescription"){
            this.familyDescription = event.target.value;
        }else if(event.target.name== "equitableAccessDescription"){
            this.equitableAccessDescription = event.target.value;
        }else if(event.target.name== "dataEvaluationDescription"){
            this.dataEvaluationDescription = event.target.value;
        }else if(event.target.name== "equitableAccessDistrictRequired"){
            this.equitableAccessDistrictRequired = event.target.value;
        }else if(event.target.name== "initiativeName"){
            this.initiativeName = event.target.value;
        }else if(event.target.name== "initiativeStrategies"){
            this.initiativeStrategies = event.target.value;
        }else if(event.target.name== "initiativeActivityConnected"){
            this.initiativeActivityConnected = event.target.value;
        }
        
    }

    handleClick(event){
       this.showModal = true;
    }
    connectedCallback(){
        window.scrollTo(0, 0);
        this.fetchInitiative();
        getDistrictWideStrategiesDetails({
            proposalId : this.projectId
        })
        .then(data => {
            let result = JSON.parse(data);
            console.log('result -',result);
            if(result.AllDistrictPrincipalData != null){
                result.AllDistrictPrincipalData.forEach(item => {
                    this.items11.push({label:item});
                })
            }
            if(result.AllDistrictPrincipalSources != null){
                result.AllDistrictPrincipalSources.forEach(item => {
                    this.items22.push({label:item});
                })
            }
            // this.AllDistrictPrincipalDataValue= result.AllDistrictPrincipalData,
            // this.AllDistrictPrincipalSourcesValue= result.AllDistrictPrincipalSources,
            this.essavalue = result.DistrictStrategicPlagroups ;
            this.ESSAFundsFY21 = result.ESSAfundsforFY21 ;
            this.planDescription = result.TitleIDistrictsplandescription ;
            this.familyDescription = result.TitleIDistrictsFamilyDescription ;
            this.equitableAccessDescription = result.EquitableAccessDescription ;
            this.dataEvaluationDescription = result.DataEvaluationDescription ;
            this.equitableAccessDistrictRequired = result.EquitableAccessDistrictRequired == 'true'?true:false; 
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
        
        
    }

    fetchInitiative(){
        getProjectInitiative({
            proposalId : this.projectId
        })
        .then(data => {
            this.initiative= data;
            console.log('data--',this.initiative);
            console.log('data--',this.initiative.length);
            // let result1 = JSON.parse(data);
            // // result2 = JSON.parse(data);
            // // result3.push(JSON.parse(data));
            // this.initiativeName= result1.InitiativeName;
            // this.initiativeStrategies = result1.InitiativeStrategiesActivities;
            // this.initiativeActivityConnected = result1.InitiativeactivityexplicitlyConnected == 'true'?true:false; 

        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }
    handleItemRemove1(event) {
        const name = event.detail.item.name;
        //alert(name + ' pill was removed!');
        const index = event.detail.index;
        this.items11.splice(index, 1);
    }
    handleItemRemove2(event) {
        const name = event.detail.item.name;
        //alert(name + ' pill was removed!');
        const index = event.detail.index;
        this.items22.splice(index, 1);
    }
    handleNext() {
        this.items11.forEach(item => {
            console.log(item.label);
            sourceset.add(item.label);
        })
        this.items22.forEach(item => {
            console.log(item.label);
            dataset.add(item.label);
        })
        console.log('wrap--'+Array.from(sourceset)        );
        var wrapperString = {
            AllDistrictPrincipalData: Array.from(sourceset),
            AllDistrictPrincipalSources: Array.from(dataset),
            DistrictStrategicPlagroups: this.essavalue,
            ESSAfundsforFY21: this.ESSAFundsFY21,
            TitleIDistrictsplandescription: this.planDescription,
            TitleIDistrictsFamilyDescription: this.familyDescription,
            EquitableAccessDescription: this.equitableAccessDescription,
            DataEvaluationDescription : this.dataEvaluationDescription,
            EquitableAccessDistrictRequired: this.equitableAccessDistrictRequired

        } 
        this.showSpinner = true;
        saveDistrictWideStrategies({
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

    }
    handlePrev() {
        this.dispatchEvent(new CustomEvent('previous'));
    }
    closeModal(event){
        this.showModal=false;
    }
    get modalClass() {
        return `slds-modal ${this.showModal ? "slds-fade-in-open" : ""}`;
      }
      get modalBackdropClass() {
        return `slds-backdrop ${this.showModal ? "slds-backdrop_open" : ""}`;
      }
}