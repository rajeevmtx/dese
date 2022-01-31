import { LightningElement } from 'lwc';

export default class PsrAssessmentQuestionaire extends LightningElement {
    get yesNoOption() {
        return [{
                label: 'Yes',
                value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            }
        ];
    }
    get pickOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }
    get questions(){
        return [
        {
            label:'Did the district complete assessment(s) in all areas related to the suspected disability(ies) including consideration of any needed assistive technology devices and services and/or instruction in Braille?',
            radio:true,
            picklist:false,
            text:false,
            date:false
        },
        {
            label:'Did the student’s record contain documentation of instructional supports, such as remedial instruction, consultative services for teachers, availability of reading instruction, appropriate services for linguistic minority students or behavioral interventions provided prior to the student’s referral for an evaluation to determine eligibility for special education?',
            radio:false,
            picklist:true,
            text:false,
            date:false
        },
        {
            label:'How were assessments administered and interpreted by trained individuals?',
            radio:false,
            picklist:false,
            text:true,
            date:false
        },
        {
            label:'When was an Educational Assessment by a representative of the school district, including a history of the student’s educational progress in the general curriculum, in the student’s record?',
            radio:false,
            picklist:false,
            text:false,
            date:true
        },
        {
            label:'Do the assessment summaries define in detail and in educationally relevant and common terms, the student’s needs, offering explicit means of meeting those needs?',
            radio:true,
            picklist:false,
            text:false,
            date:false
        },
        {
            label:'When were summaries of assessments completed prior to discussion by the Team and, upon request, made available to the parent at least two days in advance of the Team discussion?',
            radio:false,
            picklist:false,
            text:false,
            date:true
        },
        {
            label:'If the student was suspected of having a specific learning disability, was there a written determination as to whether s/he has such a disability?',
            radio:false,
            picklist:true,
            text:false,
            date:false
        },
        {
            label:'How was the written determination signed by all the Team members?',
            radio:false,
            picklist:false,
            text:true,
            date:false
        },]
    }
}