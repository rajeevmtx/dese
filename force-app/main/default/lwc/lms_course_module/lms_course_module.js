import { LightningElement, track, api } from 'lwc';
import lmsDesgin from '@salesforce/resourceUrl/LMS_Design';
// import getModulesAndContent from '@salesforce/apex/LMS_Controller.getModulesAndModulesContent';
import lmsModule from '@salesforce/resourceUrl/ModuleIcon';
// import enrollUserInCourse from '@salesforce/apex/LMS_Controller.enrollUserInCourseFromModule';
// import dropUserInCourse from '@salesforce/apex/LMS_Controller.dropUserFromCourseFromModule';
// import updateStatusUserContent from '@salesforce/apex/LMS_Controller.updateUserModuleContentStatus';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//import { NavigationMixin } from 'lightning/navigation';
//import Lms_course_module_assignment from 'c/lms_course_module_assignment';

export default class Lms_course_module extends NavigationMixin(LightningElement) {


    enrolledIcon = lmsDesgin + '/images/arrow-back.svg';

    audioinc = lmsModule + '/audio.svg';
    assignmentinc = lmsModule + '/assignment.svg';
    videoinc = lmsModule + '/video.svg';
    pdfinc = lmsModule + '/pdf.svg';
    confirmationinc = lmsModule + '/confiramtion.svg';
    launchinc = lmsModule + '/launch.svg';

    @track url;
    @track openmodel = false;
    @track moduleName;
    @track catagory;

    @track courseModuleList;
    @track isEnrolled;

    @track courseUserModuleContent = '';
    @track courseUserModule = '';



    @track isObjective = false;
    @track isOverview = false;
    @track isDownloads = false;
    @track isConversations = false;
    @track isCertification = false;
    @track isModule = true;




    //Modal Var.
    @track pdflink;
    @track audioId;
    @track videofilelink;
    @track pdfDiv = false;
    @track audio = false;
    @track videofile = false;
    @track assessment = false;
    @track other = false;
    @track assignment = false;
    @track moduleElement;
    @track contentSummary;
    @track confirmation;
    @track selectedModuleId;
    @track openConfirm = false;
    @track showComplete = true;
    @track hideSummary = true;

    @track openModalVideo = false;
    @track openModalAudio = false;
    @track openModalConfirmation = false;

    @track courseName;
    @track courseObjective;

    _courseId;
    _EnrolledId = '';
    connectedCallback() {
        // super();
        let url = new URL(window.location.href);
        this.courseId = url.searchParams.get("c__courseid");
        this.courseScheduleIdCourse = url.searchParams.get("c__scheduleid");
        if (this._EnrolledId == '' || this._EnrolledId == null) {
            this._EnrolledId = url.searchParams.get("c__enrollid");
        }
        this.courseName = url.searchParams.get("c__courseName");
        this.courseObjective = url.searchParams.get("c__courseObjective");

        console.log('ConstructorEnrollId::::' + this._EnrolledId);
        this.getModulesAndConetentAsPerCourse();
    }

    onTabChangeHandler(event) {
        this.selectedTab = event.currentTarget.getAttribute('data-id');
        // console.log('selectedTab : ',this.selectedTab);
        this.isObjective = (this.selectedTab === 'objecive');
        this.isOverview = (this.selectedTab === 'overview');
        this.isDownloads = (this.selectedTab === 'attachments');
        this.isConversations = (this.selectedTab === 'conversations');
        this.isCertification = (this.selectedTab === 'certificate');
        this.isModule = (this.selectedTab === 'modules');

        this.template.querySelector('.slds-is-active').classList.remove('slds-is-active');
        this.template.querySelector('.' + event.currentTarget.getAttribute('data-id')).classList.add('slds-is-active');
    }



    openModuleContent(event) {
        this.moduleName = event.currentTarget.getAttribute('data-module-name');
        this.courseUserModuleContent = event.currentTarget.getAttribute('data-user-content');
        this.courseUserModule = event.currentTarget.getAttribute('data-user-module');
        // if (event.currentTarget.getAttribute('data-user-status-module') === 'Completed') {
        //     this.showComplete = false;
        // } else {
        //     this.showComplete = true;
        //     updateStatusUserContent({ contentUserId: event.currentTarget.getAttribute('data-user-content'), courseId: this.courseId, userModuleId: event.currentTarget.getAttribute('data-user-module'), newStatus: 'In Progress', userEnrollmetId: this._EnrolledId })
        //         .then(result => {
        //             this.courseModuleList = result;
        //             this.error = undefined;
        //         })
        //         .catch(error => {
        //             this.error = error;
        //             this.courseModuleList = undefined;
        //         });
        // }


        //     let ispdf = event.currentTarget.getAttribute('data-is-pdf');
        //     let isaudio = event.currentTarget.getAttribute('data-is-audio');
        let isvideo = event.currentTarget.getAttribute('data-is-video');
        console.log('isvideo: ', isvideo);
        //     let isassessment = event.currentTarget.getAttribute('data-is-assessment');
        //     let isother= event.currentTarget.getAttribute('data-is-other');
        //     let isAssignment = event.currentTarget.getAttribute('data-module-type');


        //     if(ispdf === 'true'){
        //         this.pdflink="https://resources.docs.salesforce.com/198/0/en-us/sfdc/pdf/basics.pdf";//event.currentTarget.getAttribute('data-pdf');
        //         this.contentSummary = event.currentTarget.getAttribute('data-summary');
        //         // let navgateURL = '/connect/s/show-pdf-content?courseid='+this.courseId+'&scheduleid='+ this.courseScheduleIdCourse + '&enrollid='+this._EnrolledId + '&usermodule=' + this.courseUserModule +'&usercontent=' + this.courseUserModuleContent;
        //         // window.open(navgateURL,"_self");
        //         this[NavigationMixin.Navigate]({
        //             type: 'standard__component',
        //             attributes: {
        //                 componentName: 'c__MXC_Interns_lmsPDFContent'
        //             },
        //             state: {

        //                 c__courseid : this.courseId,
        //                 c__scheduleid : this.courseScheduleIdCourse,
        //                 c__enrollid : this._EnrolledId,
        //                 c__usermodule : this.courseUserModule,
        //                 c__usercontent : this.courseUserModuleContent
        //             }
        //         })
        //     }
        //     if(isaudio === 'true'){
        //         this.openModalAudio= true;
        //         this.audioId=event.currentTarget.getAttribute('data-audio');
        //         this.contentSummary = event.currentTarget.getAttribute('data-summary');
        //     }
        if (isvideo === 'true') {
            this.openModalVideo = true;
            if (event.currentTarget.getAttribute('data-isyoutube') === 'Youtube') {
                this.videofilelink = 'https://www.youtube.com/embed/' + event.currentTarget.getAttribute('data-video');
            } else if (event.currentTarget.getAttribute('data-isyoutube') === 'Youtube') {
                this.videofilelink = 'https://drive.google.com/file/d/' + event.currentTarget.getAttribute('data-video') + '/preview';
            } else {
                this.videofilelink = 'https://player.vimeo.com/video/' + event.currentTarget.getAttribute('data-video');
            }
            this.contentSummary = event.currentTarget.getAttribute('data-summary');
        }
        //     if(isother === 'true' && isAssignment !== 'Assignment'){
        //         this.openModalConfirmation = true;
        //         this.contentSummary = event.currentTarget.getAttribute('data-online-ins');
        //         this.confirmation = event.currentTarget.getAttribute('data-confirm');

        //     }
        //     if(isAssignment === 'Assignment'){
        //         // let navgateURL = '/connect/s/module-contents?moduleid='+ event.currentTarget.getAttribute('data-module-id') + '&courseid='+this.courseId+'&scheduleid='+ this.courseScheduleIdCourse + '&enrollid='+this._EnrolledId +'&contentid='+event.currentTarget.getAttribute('data-user-content')+'&usermoduleid='+event.currentTarget.getAttribute('data-user-module')+'&usermodulestatus='+event.currentTarget.getAttribute('data-user-status-module');

        //         // //let navgateURL = '/connect/s/module-contents?moduleid='+ event.currentTarget.getAttribute('data-module-id') + '&courseid='+this.courseId+'&scheduleid='+ this.courseScheduleIdCourse + '&enrollid='+this._EnrolledId;
        //         // window.open(navgateURL,"_self");
        //         this[NavigationMixin.Navigate]({
        //             type: 'standard__component',
        //             attributes: {
        //                 componentName: 'c__MXC_Internal_Course_Module_Assignment'
        //             },
        //             state: {
        //                 c__moduleid : event.currentTarget.getAttribute('data-module-id'),
        //                 c__courseid : this.courseId,
        //                 c__scheduleid : this.courseScheduleIdCourse,
        //                 c__enrollid : this._EnrolledId,
        //                 c__contentid : event.currentTarget.getAttribute('data-user-content'),
        //                 c__usermoduleid : event.currentTarget.getAttribute('data-user-module'),
        //                 c__usermodulestatus : event.currentTarget.getAttribute('data-user-status-module'),
        //             }
        //         })
        //     }

    }





    getModulesAndConetentAsPerCourse() {
        this.courseModuleList = {
            "courseId": "a1f2L000003BXNBQA4",
            "courseName": "Consulting 101 Onboarding",
            "courseSummary": "",
            "enrolId": "",
            "isComplete": false,
            "isEnrolled": true,
            "lockButtons": true,
            "moduleAndUserModuleList": [
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3927
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klaWQAQ",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmQQAQ",
                                    "status": "Planned",
                                    "$serId$": 3928
                                }
                            ],
                            "id": "a1g2L00000FKVqAQAX",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 1",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3926
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "7/21/2020",
                    "moduleId": "a1h2L000007klaWQAQ",
                    "moduleType": "Video",
                    "moduleUserStatus": "Completed",
                    "name": "Module 1",
                    "sequence": 1,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T0xQAE",
                    "userScore": 0,
                    "$serId$": 3925
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3931
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klabQAA",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmPQAQ",
                                    "status": "Planned",
                                    "$serId$": 3932
                                }
                            ],
                            "id": "a1g2L00000FKVqFQAX",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 2",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3930
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klabQAA",
                    "moduleType": "Video",
                    "moduleUserStatus": "In Progress",
                    "name": "Module 2",
                    "sequence": 2,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T0wQAE",
                    "userScore": 0,
                    "$serId$": 3929
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3935
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klagQAA",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmWQAQ",
                                    "status": "Planned",
                                    "$serId$": 3936
                                }
                            ],
                            "id": "a1g2L00000FKVqKQAX",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 3",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3934
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klagQAA",
                    "moduleType": "Video",
                    "moduleUserStatus": "In Progress",
                    "name": "Module 3",
                    "sequence": 3,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T12QAE",
                    "userScore": 0,
                    "$serId$": 3933
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3939
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klb5QAA",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmaQAA",
                                    "status": "Planned",
                                    "$serId$": 3940
                                }
                            ],
                            "id": "a1g2L00000FKVr8QAH",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 4",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3938
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klb5QAA",
                    "moduleType": "Video",
                    "moduleUserStatus": "Not Started",
                    "name": "Module 4",
                    "sequence": 4,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T16QAE",
                    "userScore": 0,
                    "$serId$": 3937
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3943
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klb0QAA",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmXQAQ",
                                    "status": "Planned",
                                    "$serId$": 3944
                                }
                            ],
                            "id": "a1g2L00000FKVqeQAH",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 5",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3942
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klb0QAA",
                    "moduleType": "Video",
                    "moduleUserStatus": "Not Started",
                    "name": "Module 5",
                    "sequence": 5,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T13QAE",
                    "userScore": 0,
                    "$serId$": 3941
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3947
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klalQAA",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmTQAQ",
                                    "status": "Planned",
                                    "$serId$": 3948
                                }
                            ],
                            "id": "a1g2L00000FKVqPQAX",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 6",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3946
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klalQAA",
                    "moduleType": "Video",
                    "moduleUserStatus": "Not Started",
                    "name": "Module 6",
                    "sequence": 6,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T0zQAE",
                    "userScore": 0,
                    "$serId$": 3945
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3951
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klamQAA",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmUQAQ",
                                    "status": "Planned",
                                    "$serId$": 3952
                                }
                            ],
                            "id": "a1g2L00000FKVqUQAX",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 7",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3950
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klamQAA",
                    "moduleType": "Video",
                    "moduleUserStatus": "Not Started",
                    "name": "Module 7",
                    "sequence": 7,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T10QAE",
                    "userScore": 0,
                    "$serId$": 3949
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3955
                            },
                            "contentType": "Video",
                            "courseModuleId": "a1h2L000007klaqQAA",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmYQAQ",
                                    "status": "Planned",
                                    "$serId$": 3956
                                }
                            ],
                            "id": "a1g2L00000FKVrNQAX",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": false,
                            "isVideo": true,
                            "name": "Module 8",
                            "sequenece": 1,
                            "videoId": "L7OLY4HCctQ",
                            "videoType": "Youtube",
                            "$serId$": 3954
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": false,
                    "iconVideo": true,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klaqQAA",
                    "moduleType": "Video",
                    "moduleUserStatus": "Not Started",
                    "name": "Module 8",
                    "sequence": 8,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T14QAE",
                    "userScore": 0,
                    "$serId$": 3953
                },
                {
                    "courseAssignemntList": [

                    ],
                    "courseCatalogId": "a1f2L000003BXNBQA4",
                    "courseModuleContentList": [
                        {
                            "attachmentObject": {
                                "contentDocumentId": "",
                                "docType": "",
                                "documentURL": "",
                                "fileName": "",
                                "$serId$": 3959
                            },
                            "contentType": "PDF",
                            "courseModuleId": "a1h2L000007klbAQAQ",
                            "courseUserModuleContentWrapperList": [
                                {
                                    "id": "a1l2L000001qrmRQAQ",
                                    "status": "Planned",
                                    "$serId$": 3960
                                }
                            ],
                            "id": "a1g2L00000FKVqjQAH",
                            "isAssessment": false,
                            "isAudio": false,
                            "isOther": false,
                            "isPDF": true,
                            "isVideo": false,
                            "name": "Module 9",
                            "sequenece": 1,
                            "$serId$": 3958
                        }
                    ],
                    "dueDate": "2019-06-10",
                    "externalSource": "",
                    "iconAssignment": false,
                    "iconAudio": false,
                    "iconConfirmation": false,
                    "iconPDF": true,
                    "iconVideo": false,
                    "moduleCompletdDate": "",
                    "moduleId": "a1h2L000007klbAQAQ",
                    "moduleType": "PDF",
                    "moduleUserStatus": "Not Started",
                    "name": "Module 9",
                    "sequence": 9,
                    "userEnrolledId": "a1j2L000007hmtZQAQ",
                    "userModuleId": "a1m2L0000023T0yQAE",
                    "userScore": 0,
                    "$serId$": 3957
                }
            ],
            "scheduledId": "a1f2L000003BXNBQA4",
            "shortCourseSummery": ""
        }
        this.error = undefined;

        // getModulesAndContent({courseCatalogId : this.courseId})
        //     .then(result => {
        //         this.courseModuleList = result;
        //         this.error = undefined;
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         this.courseModuleList = undefined;
        //     });
    }

    navigateToCourse() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'mycoursetracks'
            },
            state: {

            }
        })
    }

    openDocument() {
        let navgateURL = '/connect/s/show-pdf-content?courseid=' + this.courseId + '&scheduleid=' + this.courseScheduleIdCourse + '&enrollid=' + this._EnrolledId;
        window.open(navgateURL, "_self");
    }
    closeModal() {
        this.openModalVideo = false;
        this.openModalAudio = false;
        this.openModalConfirmation = false;
    }
    // completedModule(event) {
    //     //alert('save method invoked');
    //     updateStatusUserContent({contentUserId : event.currentTarget.getAttribute('data-user-content'),courseId : this.courseId, userModuleId :  event.currentTarget.getAttribute('data-user-module'), newStatus : 'Completed', userEnrollmetId : this._EnrolledId})
    //         .then(result => {
    //             this.courseModuleList = result;
    //             this.error = undefined;
    //             const toastEvnt = new  ShowToastEvent( {
    //                 title: 'Success!' ,
    //                 message: 'You Have Successfully completed the Module.' ,
    //                 variant: 'success' ,
    //             });
    //             this.dispatchEvent (toastEvnt); 
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             this.courseModuleList = undefined;
    //         });  
    //     this.closeModal();
    // }

    // enrollUser(event){
    //     let _courseId = event.currentTarget.getAttribute('data-courseid');
    //     let _courseScheduleId = event.currentTarget.getAttribute('data-schedule');


    //     enrollUserInCourse({courseId : _courseId, courseScheduleId : this.courseScheduleIdCourse})
    //         .then(result => {
    //             this.courseModuleList = result;
    //             this._EnrolledId = result.enrolId;
    //             console.log('EnrollId::::'+result.enrolId);
    //             console.log('EnrollIdDD::::'+this._EnrolledId);
    //             this.error = undefined;
    //             this.isEnrolled = true;
    //             const toastEvnt = new  ShowToastEvent( {
    //                 title: 'Success' ,
    //                 message: 'You have successfully enrolled for this Course.' ,
    //                 variant: 'success' ,
    //             });
    //             this.dispatchEvent (toastEvnt);
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             this.courseModuleList = undefined;

    //             const toastEvnt = new  ShowToastEvent( {
    //                 title: 'Error' ,
    //                 message: 'User Not Enrolled' ,
    //                 variant: 'error' ,
    //             });
    //             this.dispatchEvent (toastEvnt);
    //         });
    // }

    // dropUser(){
    //     //this._courseId = event.currentTarget.getAttribute('data-courseid');
    //     //this._courseScheduleId = event.currentTarget.getAttribute('data-schedule');
    //     //console.log('Event Called : ' + _courseId + ' --> Schedule Id : ' + _courseScheduleId);

    //     dropUserInCourse({courseId : this._courseId, courseScheduleId : this._courseScheduleId})
    //         .then(result => {
    //             this.courseModuleList = result;
    //             this.error = undefined;
    //             this.isEnrolled = false;
    //             const toastEvnt = new  ShowToastEvent( {
    //                 title: 'Success' ,
    //                 message: 'Successfully Dropped!' ,
    //                 variant: 'success' ,
    //             });
    //             this.dispatchEvent (toastEvnt);
    //             this.openConfirm = false;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             // console.log('error: ' + JSON.stringify(error));
    //             this.courseModuleList = undefined;
    //             const toastEvnt = new  ShowToastEvent( {
    //                 title: 'Error' ,
    //                 message: 'You are not able to drop course' ,
    //                 variant: 'error' ,
    //             });
    //             this.dispatchEvent (toastEvnt);
    //         });
    // }

    showConfirmation(event) {
        this._courseId = event.currentTarget.getAttribute('data-courseid');
        this._courseScheduleId = event.currentTarget.getAttribute('data-schedule');
        this.openConfirm = true;
    }

    closeConfirmation() {
        this.openConfirm = false;
    }

    hideLessSummary() {
        this.hideSummary = false;
    }

    hideCourseSummary() {
        this.hideSummary = true;
    }

    getSelectedvalue(event) {
        let navgateURL = '/connect/s/' + event.currentTarget.getAttribute("data-id") + '?courseid=' + this.courseId + '&scheduleid=' + this.courseScheduleIdCourse + '&enrollid=' + this._EnrolledId;
        window.open(navgateURL, "_self");
    }

}