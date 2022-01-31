import { LightningElement,api,track } from 'lwc';
import getProposalDetails from '@salesforce/apex/DESE_Title1Controller.getProposalDetails';
import saveProposalSchoolDetails from '@salesforce/apex/DESE_Title1Controller.saveProposalSchoolDetails';
import getSchools from '@salesforce/apex/DESE_IntakeSchoolController.getSchools';

export default class Dese_titlepart_aSchoolFunding extends LightningElement {
    @api projectId;
    @track value1;
    @track value2;
    @track Title1OtherIncomeSource;
    @track Title1OtherQualification;	

    get options() {
        return [
            { label: 'March Eco Dis', value: 'March Eco Dis' },
            { label: 'March Eco Dis x 1.6', value: 'March Eco Dis x 1.6' },
            { label: 'Others', value: 'Others' }
        ];
    }
    get incomeOptions(){
        return [
            { label: 'District-wide low income percentage', value: 'District-wide low income percentage' },
            { label: 'Grade span grouping and district wide percentage', value: 'Grade span grouping and district wide percentage' },
            { label: '35% rule', value: '35% rule' },
            { label: 'Grade span grouping and 35% rule', value: 'Grade span grouping and 35% rule' },
            { label: 'Grade span grouping and group wide percentage', value: 'Grade span grouping and group wide percentage' },
            { label: 'One school per grade span', value: 'One school per grade span' },
            { label: 'Total Enrollment of less than 1000 students', value: 'Total Enrollment of less than 1000 students' }
        ];
    }

    handleChange(event) {
        console.log(event.target.name ,' ==> ',event.target.value);
        if(event.target.name == 'income'){
            this.value1 = event.target.value;
        }
        if(event.target.name == 'qualify'){
            this.value2 = event.target.value;
        }
        console.log('Picklist Values ',this.value1 ,' ==> ',this.value2);
    }

    handledataChange(event){
        switch (event.target.name) {
            case 'Title1OtherIncomeSource':
              this.Title1OtherIncomeSource = event.target.value;
              break;
            case 'Title1OtherQualification':
              this.Title1OtherQualification = event.target.value;
              break;
          }
    }


    connectedCallback(){
        this.fetchSchools();
        getProposalDetails({projectId: this.projectId})
        .then(data => {
            console.log('School Data ',data);
            this.Title1OtherIncomeSource = data.Title1OtherIncomeSource;
            this.Title1OtherQualification =data.Title1OtherQualification;
            this.value1 = data.Title1LowIncome;
            this.value2 = data.Title1OtherQualifyingMethod;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }

    @api submitRecord(){
            console.log('Submitting School ');

            var wrapperString = {
                Title1OtherIncomeSource : this.Title1OtherIncomeSource,
                Title1OtherQualification : this.Title1OtherQualification,
                Title1LowIncome : this.value1,
                Title1OtherQualifyingMethod:this.value2
            }

            console.log('School Funding ',JSON.stringify(wrapperString));

            saveProposalSchoolDetails({
                proposalId : this.projectId,
                wrapperString : JSON.stringify(wrapperString)
            }).then( data => {
                if(data == 'SUCCESS'){
                    console.log(JSON.stringify(data));
                }
            }).catch(error => {
                console.log(JSON.stringify(error));
            });
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