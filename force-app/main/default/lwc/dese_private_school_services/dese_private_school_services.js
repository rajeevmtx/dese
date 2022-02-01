import { api,LightningElement, track } from 'lwc';
import getPSSDetails from '@salesforce/apex/DESE_IntakePPSController.getPSSDetails';
import savePSS from '@salesforce/apex/DESE_IntakePPSController.savePSS';
import getSchools from '@salesforce/apex/DESE_IntakeSchoolController.getSchools';
import deseDesign from '@salesforce/resourceUrl/DESE_Design';


export default class Dese_private_school_services extends LightningElement {

    notebook = deseDesign + '/theme/images/notebook.png';

    @track clickedButtonLabel = 'READ MORE';
    @track readMore = false;

    handleClick(event) {
        const label = event.target.label;
        if (label === 'READ MORE') {
            this.clickedButtonLabel = 'READ LESS';
            this.readMore = true;
        } else if (label === 'READ LESS') {
            this.clickedButtonLabel = 'READ MORE';
            this.readMore = false;
        }
    }
    //radio button
    value = 'Yes';
    title2Consortium = '';
    title3Consortium = '';
    title4Consortium = '';
    title2dae = 0;
    title3dae = 0;
    title4dae = 0;
    schools = [];
    @api projectId='';
    @api readOnly;

    get hasSchools(){
        return this.schools.length;
    }

    get actual1(){
        return this.postflex1;
    }
    get actual2(){
        return this.postflex2 +this.title2dae;
    }
    get actual3(){
        return this.postflex3 +this.title3dae;
    }
    get actual4(){
        return this.postflex4 +this.title4dae;
    }

    get serviceProvidedOptions() {
        return [
            { label: 'Eco Dis', value: 'Eco Dis' },
            { label: 'Free and Reduced Price Lunch/Meals Status', value: 'Free and Reduced Price Lunch/Meals Status' },
            { label: 'Other', value: 'Other' },
        ];
    }

    get impactOfServiceOptions() {
        return [
            {
                label: "Attendance data (educators)",
                value: "Attendance data (educators)"
            },
            {
                label: "Attendance data (students)",
                value: "Attendance data (students)"
            },
            {
                label: "College application, enrollment, and completion data",
                value: "College application, enrollment, and completion data"
            },
            {
                label: "Discipline data",
                value: "Discipline data"
            },
            {
                label: "School-based assessments",
                value: "School-based assessments"
            },
            {
                label: "School-sponsored research",
                value: "School-sponsored research"
            },
            {
                label: "Educator evaluation data",
                value: "Educator evaluation data"
            },
            {
                label: "Learning walks/teacher observations",
                value: "Learning walks/teacher observations"
            },
            {
                label: "Peer-reviewed research",
                value: "Peer-reviewed research"
            },
            {
                label: "Student report cards",
                value: "Student report cards"
            },
            {
                label: "Surveys (student)",
                value: "Surveys (student)"
            },
            {
                label: "Survey (educator)",
                value: "Survey (educator)"
            },
            {
                label: "Surveys (other)",
                value: "Surveys (other)"
            },
            {
                label: "Workforce outcomes data",
                value: "Workforce outcomes data"
            },
            {
                label: "Other",
                value: "Other"
            },
            {
                label: "None",
                value: "None"
            }
        ];
    }

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get isValue() {
        return (this.value == 'Yes')?true:false;
    }

    handleToggleChange(event) {
        const selectedOption = event.detail.value;
        console.log('Option selected with value: ' + selectedOption);
        this.value = selectedOption;
    }

    connectedCallback() {
        window.scrollTo(0, 0);
        this.fetchSchools();
        getPSSDetails({projectId: this.projectId})
            .then(data => {
                console.log(data);
                this.istitle2Consortium = data.istitle2Consortium;
                this.istitle3Consortium = data.istitle3Consortium;
                this.istitle4Consortium = data.istitle4Consortium;
                this.title2Consortium = data.title2Consortium;
                this.title3Consortium = data.title3Consortium;
                this.title4Consortium = data.title4Consortium;
                this.title2dae = data.title2dae;
                this.title3dae = data.title3dae;
                this.title4dae = data.title4dae;
                this.postflex1 = data.postflex1;
                this.postflex2 = data.postflex2;
                this.postflex3 = data.postflex3;
                this.postflex4 = data.postflex4;
                this.serviceProvided = data.serviceProvided;
                this.impactOfService = data.impactOfService;
                this.determineLow = data.determineLow;
                this.contactedAll = data.contactedAll;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
    }

    handleNext() {
        var wrapperString = {
            istitle2Consortium : this.istitle2Consortium,
            istitle3Consortium : this.istitle3Consortium,
            istitle4Consortium : this.istitle4Consortium,
            title2Consortium : this.title2Consortium,
            title3Consortium : this.title3Consortium,
            title4Consortium : this.title4Consortium,
            serviceProvided : this.serviceProvided,
            impactOfService : this.impactOfService,
            title2dae : this.title2dae,
            title3dae : this.title3dae,
            title4dae : this.title4dae,
            determineLow : this.determineLow,
            contactedAll : this.contactedAll
        }
        savePSS({
            proposalId : this.projectId,
            wrapperString : JSON.stringify(wrapperString)
        }).then(result => {
            console.log(result)
        }).catch(error => {
            console.log(error)
        })
        // var wrapperString = {
        // totalAllocationTitleI : this.inputval1,
        // totalAllocationTitleII : this.inputval2,
        // totalAllocationTitleIII : this.inputval3,
        // totalAllocationTitleIV : this.inputval4,
        // postFlexingTitleI : this.totalsum,
        // postFlexingTitleII : this.totalsum2,
        // postFlexingTitleIII : this.totalsum3,
        // postFlexingTitleIV : this.totalsum4,
        // titleIIFundsTitleI : this.T2val2,
        // titleIIFundsTitleIII : this.T2val3,
        // titleIIFundsTitleIV : this.T2val4,
        // titleIVFundsTitleI : this.T4val2,
        // titleIVFundsTitleII : this.T4val3,
        // titleIVFundsTitleIII : this.T4val4
        // }
        // this.showSpinner = true;
        // savePSS({
        //     proposalId : this.projectId,
        //     wrapperString : JSON.stringify(wrapperString)
        // }).then( data => {
        //     if(data == 'SUCCESS'){
        //         this.dispatchEvent(new CustomEvent('next'));
        //     }
        // }).catch(error => {
        //     console.log(JSON.stringify(error));
        // }).finally(() => {
        //     this.showSpinner = false;
        // })

        this.dispatchEvent(new CustomEvent('next'));
    }

    handlePrev() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    genericHandler(event) {
        var inputname = event.currentTarget.dataset.id;
        console.log(event.currentTarget.dataset.id);
        this[inputname] = parseInt(event.target.value ? event.target.value : 0);
    }

    handleChange(event)  {
        var inputname = event.currentTarget.dataset.id;
        console.log(inputname)
        this[inputname] = event.target.value;
    }

    fetchSchools(){
        getSchools({projectId: this.projectId})
            .then(data => {
                this.schools = data;
            })
            .catch(error => {
                console.log(error);
            })
    }

}