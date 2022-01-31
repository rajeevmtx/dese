import { LightningElement,wire,track } from 'lwc';
import getContactdata from '@salesforce/apex/PsrContactListController.getAllContacts';
import getStaffdata from '@salesforce/apex/PsrContactListController.getAllContacts';
import getApplicationDocument from "@salesforce/apex/PsrStatusInfo.fetchApplicationDocuments";
import { utility } from "c/pubsub";
import { refreshApex } from '@salesforce/apex';
export default class PsrApplicationReview extends LightningElement {
    @track data = [];
    @track dataStaff = [];
    @track showSpinner = false;

    get questions(){
        return [
        {
            label:'Did the district complete assessment(s) in all areas related to the suspected disability(ies) including consideration of any needed assistive technology devices and services and/or instruction in Braille?',
            radio:true,
            picklist:false,
            text:false,
            date:false,
            value:true
        },
        {
            label:'Did the student’s record contain documentation of instructional supports, such as remedial instruction, consultative services for teachers, availability of reading instruction, appropriate services for linguistic minority students or behavioral interventions provided prior to the student’s referral for an evaluation to determine eligibility for special education?',
            radio:false,
            picklist:true,
            text:false,
            date:false,
            value:'Yes'
        },
        {
            label:'How were assessments administered and interpreted by trained individuals?',
            radio:false,
            picklist:false,
            text:true,
            date:false,
            value:'Assessment were checked on an online portal.'
        },
        {
            label:'When was an Educational Assessment by a representative of the school district, including a history of the student’s educational progress in the general curriculum, in the student’s record?',
            radio:false,
            picklist:false,
            text:false,
            date:true,
            value:'09/09/2020'
        },
        {
            label:'Do the assessment summaries define in detail and in educationally relevant and common terms, the student’s needs, offering explicit means of meeting those needs?',
            radio:true,
            picklist:false,
            text:false,
            date:false,
            value:false
        },
        {
            label:'When were summaries of assessments completed prior to discussion by the Team and, upon request, made available to the parent at least two days in advance of the Team discussion?',
            radio:false,
            picklist:false,
            text:false,
            date:true,
            value:'03/09/2020'
        },
        {
            label:'If the student was suspected of having a specific learning disability, was there a written determination as to whether s/he has such a disability?',
            radio:false,
            picklist:true,
            text:false,
            date:false,
            value:'Yes'
        },
        {
            label:'How was the written determination signed by all the Team members?',
            radio:false,
            picklist:false,
            text:true,
            date:false,
            value:'It was signed digitally.'
        },]
    }
    get yesNoOption() {
        return [{
                label: 'Yes',
                value: true
            },
            {
                label: 'No',
                value: false
            }
        ];
    }
    get pickOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }
    connectedCallback() {
        this.showSpinner = true;
        this.fetchdocuments();
    }
    fetchdocuments(){
        getApplicationDocument({applicationId :utility.getUrlParam('appId')})
        .then(result => {
            console.log(result);
            this.uploadedFiles =result;
            console.log(result);
            this.showSpinner = false;
        })
        .catch(error => {
            console.log("**************", error);
            
        });
    }
    @wire(getContactdata,{applicationId:utility.getUrlParam('appId'),recordTypeName:'Applicant'})
    stu(result) {
        if (result.data) {
            this.data = result.data;
        } else if (result.error) {
            window.console.log(result.error);
        }
    }
    @wire(getStaffdata,{applicationId:utility.getUrlParam('appId'),recordTypeName:'Staff'})
    con(result) {
        if (result.data) {
            this.dataStaff = result.data;
        } else if (result.error) {
            window.console.log(result.error);
        }
    }
}