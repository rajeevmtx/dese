({
    doInit: function(component, event, helper) {
        // component.set("v.showUnderReviewMessage", false);
        // helper.getApplicationDocs(component, event, helper);
        var questionList = [{question:'Did the district complete assessment(s) in all areas related to the suspected disability(ies) including consideration of any needed assistive technology devices and services and/or instruction in Braille?',answer:'Yes',status:'Submitted',notes:''},
                            {question:'Did the student’s record contain documentation of instructional supports, such as remedial instruction, consultative services for teachers, availability of reading instruction, appropriate services for linguistic minority students or behavioral interventions provided prior to the student’s referral for an evaluation to determine eligibility for special education?',answer:'No',status:'Submitted',notes:''},
                            {question:'Were assessments administered and interpreted by trained individuals?',answer:'Yes',status:'Submitted',notes:''},
                            {question:'Was an Educational Assessment by a representative of the school district, including a history of the student’s educational progress in the general curriculum, in the student’s record?',answer:'No',status:'Submitted',notes:''},
                            {question:'Do the assessment summaries define in detail and in educationally relevant and common terms, the student’s needs, offering explicit means of meeting those needs?',answer:'Yes',status:'Submitted',notes:''},
                            {question:'Were summaries of assessments completed prior to discussion by the Team and, upon request, made available to the parent at least two days in advance of the Team discussion?',answer:'No',status:'Submitted',notes:''},
                            {question:'If the student was suspected of having a specific learning disability, was there a written determination as to whether s/he has such a disability?',answer:'Yes',status:'Submitted',notes:''},
                            {question:'Was the written determination signed by all the Team members?',answer:'No',status:'Submitted',notes:''}];
        component.set('v.questionList',questionList);
        var pickOptions = [
                            {label: 'Draft', value: 'Draft'},
                            {label: 'Submitted', value: 'Submitted',selected: true},
                            {label: 'Pending', value: 'Pending'},
                            {label: 'Completion', value: 'Completion'},
                            {label: 'Completed', value: 'Completed'}
                            ];
        component.set('v.pickOptions',pickOptions);
    },
    handleSave: function(component, event, helper) {
        // helper.saveDocsReview(component, event, helper);
        component.set("v.editable", false);
    },
    handleEdit: function(component, event, helper) {
        component.set("v.editable", true);
    },
    handleCancel: function(component, event, helper) {
        // component.set("v.showUnderReviewMessage", false);
        component.set("v.editable", false);
    },
    // handleFileOpen: function(component, event, helper) {
    //     var selectedItem = event.currentTarget.getAttribute("data-record");
    //     $A.get("e.lightning:openFiles").fire({
    //         recordIds: [selectedItem]
    //     });
    // }
})