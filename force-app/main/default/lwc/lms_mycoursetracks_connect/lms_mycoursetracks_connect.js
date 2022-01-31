import { LightningElement, track } from 'lwc';
import lmsModule from '@salesforce/resourceUrl/ModuleIcon';
// import getCourseTracksData from '@salesforce/apex/LMS_Controller.getAllCoursesAndTracks';
// import getTrackCourseCatalogs from '@salesforce/apex/LMS_Controller.getTrackCourseCatalogs';
// import fetchPicklist from '@salesforce/apex/LMS_Controller.fetchPicklist';


export default class Lms_mycoursetracks_connect extends LightningElement {
    @track value = '';
    @track nameValue = '';
    @track valSize = '5';
    @track valueWrapper = {
        'value': '',
        'nameValue': ''
    }
    @track mycategories;
    @track categories;
    @track trackWrapper;
    @track pill = [];
    @track showListValue = false;
    @track picklistValues;
    @track picklistValuesList = [];
    @track selectedTab = 'mycourse';
    @track isMyCourse = true;
    @track isAllCourse = false;
    @track isMyTracks = false;
    @track isAllTracks = false;
    @track courseTracksWrapper;
    @track courselist;
    @track isfilter = false;
    @track i;
    @track userguidelink;
    @track courselistafterfilter;
    @track mycourselistafterfilter;
    @track error; // to show error message from apex controller.
    @track success; // to show succes message in ui.
    @track isempty = true;
    @track showtable = false;
    @track showtableall = false;
    @track showtabletrack = false;
    @track showtablealltrack = false;
    @track enrolledTrack;
    @track tracklistafterfilter;
    @track mytracklistafterfilter;
    @track allTrack;

    //For Pagination
    @track showPaginationBar = true;
    @track clientData = [];
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track isDisabled = false;
    @track pageList;
    @track currentPageNumber = 1;
    @track totalPages = 0;
    @track isTotal = false;
    @track pageSize = 5;
    //@track item;
    @track firstSelected = 'selected';
    @track lastSelected = '';
    @track isListValue = false;
    @track showFirst = false;

    nocourses = lmsModule + '/nocourses.svg';
    // method for get  accounts.
    constructor() {
        super();
        this.getallData();
        // this.getTrack();
        //this.fetchPicklistValues();
    }
    // fetchPicklistValues(){
    //     fetchPicklist()
    //     .then(result => {
    //         this.picklistValues = result;
    //         this.error = undefined;
    //         //console.log('result[0].courseName : ' + result[0].courseName);
    //         //console.log('result: ' + JSON.stringify(this.picklistValues));
    //     })
    //     .catch(error => {
    //         this.error = error;
    //         //console.log('error: ' + JSON.stringify(error));
    //         this.picklistValues = undefined;
    //     });
    // }

    clearFilter(event) {
        this.valueWrapper = {
            'value': '',
            'nameValue': ''
        }
        //document.getElementsByClassName("example").value("");
        // this.value = undefined;
        // this.nameValue = undefined;
        this.isfilter = false;
        this.getallData();
    }

    getallData() {
        let result = {
            courseCatalogsList: [
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fostercare",
                        "adoption",
                        "foster",
                        "fosterlove",
                        "thisisfostercare",
                    ],
                    "courseLevel": "",
                    "courseName": "Orientation",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BXNBQA4",
                        "courseCatalogName": "CC-0016",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002XN6EQAW",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hmtZQAQ",
                            "status": "Planned",
                            "totalModules": 11,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002XN6EQAW",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-06-10T13:44:45.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam efficitur sem a tortor consectetur tincidunt. Proin tincidunt ac lectus nec cursus. Phasellus vulputate sem volutpat leo pretium sollicitudin. Curabitur sagittis nulla nec dui volutpat pharetra. Nam a molestie orci. Fusce tincidunt tortor augue, a posuere leo congue et. Vestibulum interdum erat ipsum, sit amet eleifend sem sollicitudin non. Vivamus non placerat sem. Quisque tempus non nibh at vehicula. Vivamus condimentum sollicitudin orci, in iaculis augue viverra ac. Integer molestie velit eget ipsum blandit interdum. Fusce mattis placerat ultrices. Integer laoreet, mauris vitae euismod sodales, urna velit iaculis sapien, ut semper nisi arcu ac orci. Nam vitae ullamcorper quam. Nulla mattis quis nisi in eleifend.",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BXNBQA4",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>The objective of this training is to provide all the consultants with an end-to-end overview of the entire delivery processes &amp; best practices that are followed day-in day-out at MTX in order to deliver successful projects for all our clients.</p><p><br></p>",
                    "overview": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    "publishDate": "2019-06-10",
                    "shortSummary": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam efficitur sem a tortor consectetur tincidunt. Proin tincidunt ac lectus nec cursus. Phasellus vulputate sem volutpat leo pretium sollicitudin. Curabitur sagittis nulla nec dui volutpat pharetra. Nam a molestie orci...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Apex",
                        "API Testing",
                        "Business Analysis",
                        "Business Process Management",
                        "Consulting",
                        "Developer",
                        "Quality Analyst"
                    ],
                    "totalEnrollment": 466,
                    "totalLikes": 4,
                    "totalModule": 11
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fostercare",
                        "fosterparents",
                        "fostercareawareness",
                        "fosterfamily",
                        "fostertoadopt",
                        "fostermom",
                        "fostering",
                    ],
                    "courseLevel": "",
                    "courseName": "Regulations",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BW8UQAW",
                        "courseCatalogName": "CC-0015",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002X8nOQAS",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hjlYQAQ",
                            "status": "Planned",
                            "totalModules": 1,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002X8nOQAS",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-04-19T08:52:40.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Vivamus sit amet blandit tellus. Nam tincidunt massa vestibulum purus porttitor, nec pharetra lorem rhoncus. Praesent eu placerat purus, non vulputate sapien. Duis sed tortor sit amet justo auctor auctor. Proin elementum dolor id ante vulputate, interdum porta lorem ultricies. Fusce porttitor ipsum et pulvinar vestibulum. Aenean nec rhoncus ante. Nullam vel convallis orci. Praesent laoreet laoreet risus, vitae aliquam nunc pellentesque facilisis. Praesent pretium, ligula nec elementum dapibus, ipsum nunc convallis lacus, quis malesuada velit eros sed purus. Cras massa magna, hendrerit in velit eget, vehicula malesuada orci. Etiam blandit sagittis mi eget convallis. Ut sit amet hendrerit risus, ac convallis dolor. </p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BW8UQAW",
                    "isEnrolled": false,
                    "liked": false,
                    "lockButtons": false,
                    "objectives": "<p>MTX believes in quality output with clearly defined success metrics. In an effort to consistently meet all necessary customer success metrics, along with quality deliverables, we are inclining our customer success team with all our valued clients.</p>",
                    "overview": "<p>Praesent vitae odio quis diam accumsan scelerisque. </p>",
                    "publishDate": "2019-04-19",
                    "shortSummary": "Vivamus sit amet blandit tellus. Nam tincidunt massa vestibulum purus porttitor, nec pharetra lorem rhoncus. Praesent eu placerat purus, non vulputate sapien. Duis sed tortor sit amet justo auctor auctor. Proin elementum dolor id ante vulputate, interdum porta lorem ultricies...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Customer Success"
                    ],
                    "totalEnrollment": 459,
                    "totalLikes": 2,
                    "totalModule": 1
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fostering",
                        "fosterkids",
                        "love",
                        "fosteringsaveslives",
                    ],
                    "courseLevel": "",
                    "courseName": "The Developing Child",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BW2qQAG",
                        "courseCatalogName": "CC-0012",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002X8nKQAS",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hjlUQAQ",
                            "status": "Planned",
                            "totalModules": 1,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002X8nKQAS",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-04-19T04:00:04.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Morbi lacinia feugiat justo, cursus elementum erat. Suspendisse pulvinar tellus sed nisl accumsan commodo. Suspendisse vel rutrum augue. Vivamus sit amet odio sit amet elit tempus tempor. Vivamus tincidunt laoreet felis, nec vulputate tortor luctus vehicula. Curabitur finibus urna vel lectus efficitur, et commodo nisl condimentum. Nunc id placerat nisl, a ornare nibh. Aliquam erat volutpat. Donec sollicitudin diam ligula, quis ullamcorper magna facilisis sed. Curabitur tincidunt odio eget commodo eleifend. Nulla facilisi. Vestibulum aliquam pretium tortor viverra finibus. Vivamus ultricies tellus ut dignissim consequat. Ut mollis ipsum eu sapien ultrices, nec tincidunt lectus ultrices.</p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BW2qQAG",
                    "isEnrolled": false,
                    "liked": false,
                    "lockButtons": false,
                    "objectives": "<p>Expensify makes reimbursement an ease! It assigns expenses to specific clients and projects. It helps tracking report, receipt tracking, and business travel providing a good user interface, which saves hours of manual entry.</p>",
                    "overview": "<p>Mauris suscipit mi nec nibh pretium, in auctor arcu rutrum.</p>",
                    "publishDate": "2019-04-19",
                    "shortSummary": "Morbi lacinia feugiat justo, cursus elementum erat. Suspendisse pulvinar tellus sed nisl accumsan commodo. Suspendisse vel rutrum augue. Vivamus sit amet odio sit amet elit tempus tempor. Vivamus tincidunt laoreet felis, nec vulputate tortor luctus vehicula. Curabitur finibus urna vel lectus efficitur...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Human Resources"
                    ],
                    "totalEnrollment": 459,
                    "totalLikes": 3,
                    "totalModule": 1
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fostercareadoption",
                        "children",
                        "family",
                        "nonprofit",
                        "fosteryouth",
                    ],
                    "courseLevel": "",
                    "courseName": "The Effects of Childhood Trauma",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BW2lQAG",
                        "courseCatalogName": "CC-0011",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002X8nMQAS",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hjlWQAQ",
                            "status": "Planned",
                            "totalModules": 2,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002X8nMQAS",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-04-19T04:00:04.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Vivamus quis elit euismod, consequat nunc id, pulvinar sem. Quisque hendrerit ipsum ut velit efficitur pellentesque. Etiam facilisis diam vitae varius fermentum. Integer vehicula, nunc in blandit mollis, velit arcu ornare tortor, a dapibus magna ante a lorem. Mauris maximus sit amet velit ac auctor. Fusce nunc orci, imperdiet ac dui id, scelerisque convallis neque. Donec consequat pretium dapibus.</p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BW2lQAG",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>It allows businesses to maintain summaries of different accounts along with calendars so that transparency can be obtained and different ratios such as debt-to-income ratios can be balanced at the right time, preventing any crisis or undesirable situation.</p>",
                    "overview": "<p>In elementum dolor vitae magna gravida, sit amet pretium arcu congue.</p>",
                    "publishDate": "2019-04-19",
                    "shortSummary": "Vivamus quis elit euismod, consequat nunc id, pulvinar sem. Quisque hendrerit ipsum ut velit efficitur pellentesque. Etiam facilisis diam vitae varius fermentum. Integer vehicula, nunc in blandit mollis, velit arcu ornare tortor, a dapibus magna ante a lorem...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Human Resources"
                    ],
                    "totalEnrollment": 459,
                    "totalLikes": 6,
                    "totalModule": 2
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "adoptionjourney",
                        "adoptdontshop",
                        "adoptionrocks",
                        "youth",
                        "adoptionislove",
                        "adopt",
                    ],
                    "courseLevel": "",
                    "courseName": "Experiencing Grief and Loss",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BYJFQA4",
                        "courseCatalogName": "CC-0017",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002XPuqQAG",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hnY4QAI",
                            "status": "Planned",
                            "totalModules": 1,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002XPuqQAG",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-07-01T11:20:02.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Suspendisse potenti. Cras elit tortor, tincidunt at ex in, elementum suscipit arcu. In eu odio vitae arcu ornare venenatis. Ut nec orci mollis, auctor lorem nec, pulvinar nisl. Pellentesque vel ullamcorper risus. Quisque sit amet sapien vitae erat malesuada pellentesque. Sed semper enim metus, at porta justo fermentum a. Maecenas condimentum mauris mi, et convallis felis aliquet sed. Fusce eget lacinia diam.</p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BYJFQA4",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p><span style=\"font-family: Roboto, sans-serif; color: rgb(38, 50, 56);\">The overarching goal of the platform is to make efforts of MTX Family members count by rewarding them and making the experience of rewarding fun and engaging.</span></p>",
                    "overview": "<p>Fusce id lacus imperdiet dui finibus aliquam.</p>",
                    "publishDate": "2019-07-01",
                    "shortSummary": "Suspendisse potenti. Cras elit tortor, tincidunt at ex in, elementum suscipit arcu. In eu odio vitae arcu ornare venenatis. Ut nec orci mollis, auctor lorem nec, pulvinar nisl. Pellentesque vel ullamcorper risus. Quisque sit amet sapien vitae erat malesuada pellentesque...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Human Resources"
                    ],
                    "totalEnrollment": 454,
                    "totalLikes": 1,
                    "totalModule": 1
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "covid",
                        "fosterparenting",
                        "community",
                        "fosterchildren",
                        "bhfyp",
                    ],
                    "courseLevel": "",
                    "courseName": "Promoting Positive Behavior",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BXNBQA4",
                        "courseCatalogName": "CC-0016",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002XN6EQAW",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hmtZQAQ",
                            "status": "Planned",
                            "totalModules": 11,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002XN6EQAW",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-06-10T13:44:45.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Aenean tincidunt at felis nec venenatis. Cras porta ultrices magna quis condimentum. Etiam in tortor feugiat, porttitor leo eu, tincidunt sapien. Cras felis ante, fermentum id ante sed, tempor vehicula ex: </p><ol><li>Mauris congue est a augue vestibulum, sit amet aliquet dolor tempor.</li><li>Phasellus eu sapien vel ligula mattis condimentum.</li><li>Praesent vitae odio quis diam accumsan scelerisque.</li><li>Fusce id lacus imperdiet dui finibus aliquam.</li></ol><p><br></p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BXNBQA4",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>The objective of this training is to provide all the consultants with an end-to-end overview of the entire delivery processes &amp; best practices that are followed day-in day-out at MTX in order to deliver successful projects for all our clients.</p><p><br></p>",
                    "overview": "<p>Aenean tincidunt at felis nec venenatis. Cras porta ultrices magna quis condimentum. Etiam in tortor feugiat, porttitor leo eu, tincidunt sapien. Cras felis ante, fermentum id ante sed, tempor vehicula ex: </p><ol><li>Mauris congue est a augue vestibulum, sit amet aliquet dolor tempor.</li><li>Phasellus eu sapien vel ligula mattis condimentum.</li><li>Praesent vitae odio quis diam accumsan scelerisque.</li><li>Fusce id lacus imperdiet dui finibus aliquam.</li></ol><p><br></p>",
                    "publishDate": "2019-06-10",
                    "shortSummary": "Aenean tincidunt at felis nec venenatis. Cras porta ultrices magna quis condimentum. Etiam in tortor feugiat, porttitor leo eu, tincidunt sapien. Cras felis ante, fermentum id ante sed, tempor vehicula ex...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Apex",
                        "API Testing",
                        "Business Analysis",
                        "Business Process Management",
                        "Consulting",
                        "Developer",
                        "Quality Analyst"
                    ],
                    "totalEnrollment": 466,
                    "totalLikes": 4,
                    "totalModule": 11
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fosterparenting",
                        "community",
                        "fosterchildren",
                        "bhfyp",
                        "adoptiveparents",
                        "parenting",
                        "fostercarejourney"
                    ],
                    "courseLevel": "",
                    "courseName": "Lifelong Connections",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BW2lQAG",
                        "courseCatalogName": "CC-0011",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002X8nMQAS",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hjlWQAQ",
                            "status": "Planned",
                            "totalModules": 2,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002X8nMQAS",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-04-19T04:00:04.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Sed ut molestie turpis. Sed et tellus ac velit auctor ultricies sed commodo metus. Pellentesque id porta lectus. Vestibulum non libero sit amet eros finibus rutrum. Suspendisse a ligula a justo convallis aliquet. Donec condimentum luctus leo. Vivamus lacinia pharetra aliquet. Nulla ornare, lorem ut mollis tincidunt, lorem justo pretium dolor, id interdum nibh leo ut tellus. Sed tempor commodo imperdiet.</p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BW2lQAG",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>It allows businesses to maintain summaries of different accounts along with calendars so that transparency can be obtained and different ratios such as debt-to-income ratios can be balanced at the right time, preventing any crisis or undesirable situation.</p>",
                    "overview": "<p>Mauris congue est a augue vestibulum, sit amet aliquet dolor tempor.</p>",
                    "publishDate": "2019-04-19",
                    "shortSummary": "Sed ut molestie turpis. Sed et tellus ac velit auctor ultricies sed commodo metus. Pellentesque id porta lectus. Vestibulum non libero sit amet eros finibus rutrum. Suspendisse a ligula a justo convallis aliquet. Donec condimentum luctus leo. Vivamus lacinia pharetra aliquet. Nulla ornare, lorem ut mollis tincidunt, lorem justo pretium dolor, id interdum nibh leo ut tellus. Sed tempor commodo imperdiet...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Human Resources"
                    ],
                    "totalEnrollment": 459,
                    "totalLikes": 6,
                    "totalModule": 2
                }
            ],
            currentUserId: '',
            myCourseCatalogsList: [
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fostercare",
                        "adoption",
                        "foster",
                        "fosterlove",
                        "thisisfostercare",
                    ],
                    "courseLevel": "",
                    "courseName": "Orientation",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BXNBQA4",
                        "courseCatalogName": "CC-0016",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002XN6EQAW",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hmtZQAQ",
                            "status": "Planned",
                            "totalModules": 11,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002XN6EQAW",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-06-10T13:44:45.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam efficitur sem a tortor consectetur tincidunt. Proin tincidunt ac lectus nec cursus. Phasellus vulputate sem volutpat leo pretium sollicitudin. Curabitur sagittis nulla nec dui volutpat pharetra. Nam a molestie orci. Fusce tincidunt tortor augue, a posuere leo congue et. Vestibulum interdum erat ipsum, sit amet eleifend sem sollicitudin non. Vivamus non placerat sem. Quisque tempus non nibh at vehicula. Vivamus condimentum sollicitudin orci, in iaculis augue viverra ac. Integer molestie velit eget ipsum blandit interdum. Fusce mattis placerat ultrices. Integer laoreet, mauris vitae euismod sodales, urna velit iaculis sapien, ut semper nisi arcu ac orci. Nam vitae ullamcorper quam. Nulla mattis quis nisi in eleifend.",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BXNBQA4",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>The objective of this training is to provide all the consultants with an end-to-end overview of the entire delivery processes &amp; best practices that are followed day-in day-out at MTX in order to deliver successful projects for all our clients.</p><p><br></p>",
                    "overview": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    "publishDate": "2019-06-10",
                    "shortSummary": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam efficitur sem a tortor consectetur tincidunt. Proin tincidunt ac lectus nec cursus. Phasellus vulputate sem volutpat leo pretium sollicitudin. Curabitur sagittis nulla nec dui volutpat pharetra. Nam a molestie orci...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Apex",
                        "API Testing",
                        "Business Analysis",
                        "Business Process Management",
                        "Consulting",
                        "Developer",
                        "Quality Analyst"
                    ],
                    "totalEnrollment": 466,
                    "totalLikes": 4,
                    "totalModule": 11
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fostercareadoption",
                        "children",
                        "family",
                        "nonprofit",
                        "fosteryouth",
                    ],
                    "courseLevel": "",
                    "courseName": "The Effects of Childhood Trauma",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BW2lQAG",
                        "courseCatalogName": "CC-0011",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002X8nMQAS",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hjlWQAQ",
                            "status": "Planned",
                            "totalModules": 2,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002X8nMQAS",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-04-19T04:00:04.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Vivamus quis elit euismod, consequat nunc id, pulvinar sem. Quisque hendrerit ipsum ut velit efficitur pellentesque. Etiam facilisis diam vitae varius fermentum. Integer vehicula, nunc in blandit mollis, velit arcu ornare tortor, a dapibus magna ante a lorem. Mauris maximus sit amet velit ac auctor. Fusce nunc orci, imperdiet ac dui id, scelerisque convallis neque. Donec consequat pretium dapibus.</p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BW2lQAG",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>It allows businesses to maintain summaries of different accounts along with calendars so that transparency can be obtained and different ratios such as debt-to-income ratios can be balanced at the right time, preventing any crisis or undesirable situation.</p>",
                    "overview": "<p>In elementum dolor vitae magna gravida, sit amet pretium arcu congue.</p>",
                    "publishDate": "2019-04-19",
                    "shortSummary": "Vivamus quis elit euismod, consequat nunc id, pulvinar sem. Quisque hendrerit ipsum ut velit efficitur pellentesque. Etiam facilisis diam vitae varius fermentum. Integer vehicula, nunc in blandit mollis, velit arcu ornare tortor, a dapibus magna ante a lorem...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Human Resources"
                    ],
                    "totalEnrollment": 459,
                    "totalLikes": 6,
                    "totalModule": 2
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "adoptionjourney",
                        "adoptdontshop",
                        "adoptionrocks",
                        "youth",
                        "adoptionislove",
                        "adopt",
                    ],
                    "courseLevel": "",
                    "courseName": "Experiencing Grief and Loss",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BYJFQA4",
                        "courseCatalogName": "CC-0017",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002XPuqQAG",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hnY4QAI",
                            "status": "Planned",
                            "totalModules": 1,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002XPuqQAG",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-07-01T11:20:02.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Suspendisse potenti. Cras elit tortor, tincidunt at ex in, elementum suscipit arcu. In eu odio vitae arcu ornare venenatis. Ut nec orci mollis, auctor lorem nec, pulvinar nisl. Pellentesque vel ullamcorper risus. Quisque sit amet sapien vitae erat malesuada pellentesque. Sed semper enim metus, at porta justo fermentum a. Maecenas condimentum mauris mi, et convallis felis aliquet sed. Fusce eget lacinia diam.</p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BYJFQA4",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p><span style=\"font-family: Roboto, sans-serif; color: rgb(38, 50, 56);\">The overarching goal of the platform is to make efforts of MTX Family members count by rewarding them and making the experience of rewarding fun and engaging.</span></p>",
                    "overview": "<p>Fusce id lacus imperdiet dui finibus aliquam.</p>",
                    "publishDate": "2019-07-01",
                    "shortSummary": "Suspendisse potenti. Cras elit tortor, tincidunt at ex in, elementum suscipit arcu. In eu odio vitae arcu ornare venenatis. Ut nec orci mollis, auctor lorem nec, pulvinar nisl. Pellentesque vel ullamcorper risus. Quisque sit amet sapien vitae erat malesuada pellentesque...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Human Resources"
                    ],
                    "totalEnrollment": 454,
                    "totalLikes": 1,
                    "totalModule": 1
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "covid",
                        "fosterparenting",
                        "community",
                        "fosterchildren",
                        "bhfyp",
                    ],
                    "courseLevel": "",
                    "courseName": "Promoting Positive Behavior",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BXNBQA4",
                        "courseCatalogName": "CC-0016",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002XN6EQAW",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hmtZQAQ",
                            "status": "Planned",
                            "totalModules": 11,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002XN6EQAW",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-06-10T13:44:45.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Aenean tincidunt at felis nec venenatis. Cras porta ultrices magna quis condimentum. Etiam in tortor feugiat, porttitor leo eu, tincidunt sapien. Cras felis ante, fermentum id ante sed, tempor vehicula ex: </p><ol><li>Mauris congue est a augue vestibulum, sit amet aliquet dolor tempor.</li><li>Phasellus eu sapien vel ligula mattis condimentum.</li><li>Praesent vitae odio quis diam accumsan scelerisque.</li><li>Fusce id lacus imperdiet dui finibus aliquam.</li></ol><p><br></p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BXNBQA4",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>The objective of this training is to provide all the consultants with an end-to-end overview of the entire delivery processes &amp; best practices that are followed day-in day-out at MTX in order to deliver successful projects for all our clients.</p><p><br></p>",
                    "overview": "<p>Aenean tincidunt at felis nec venenatis. Cras porta ultrices magna quis condimentum. Etiam in tortor feugiat, porttitor leo eu, tincidunt sapien. Cras felis ante, fermentum id ante sed, tempor vehicula ex: </p><ol><li>Mauris congue est a augue vestibulum, sit amet aliquet dolor tempor.</li><li>Phasellus eu sapien vel ligula mattis condimentum.</li><li>Praesent vitae odio quis diam accumsan scelerisque.</li><li>Fusce id lacus imperdiet dui finibus aliquam.</li></ol><p><br></p>",
                    "publishDate": "2019-06-10",
                    "shortSummary": "Aenean tincidunt at felis nec venenatis. Cras porta ultrices magna quis condimentum. Etiam in tortor feugiat, porttitor leo eu, tincidunt sapien. Cras felis ante, fermentum id ante sed, tempor vehicula ex...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Apex",
                        "API Testing",
                        "Business Analysis",
                        "Business Process Management",
                        "Consulting",
                        "Developer",
                        "Quality Analyst"
                    ],
                    "totalEnrollment": 466,
                    "totalLikes": 4,
                    "totalModule": 11
                },
                {
                    "attachmentWrapperList": [

                    ],
                    "subCategory": [
                        "fosterparenting",
                        "community",
                        "fosterchildren",
                        "bhfyp",
                        "adoptiveparents",
                        "parenting",
                        "fostercarejourney"
                    ],
                    "courseLevel": "",
                    "courseName": "Lifelong Connections",
                    "courseScheduleObject": {
                        "avRequirments": "",
                        "computerRequired": false,
                        "contactID": "",
                        "courseCatalogId": "a1f2L000003BW2lQAG",
                        "courseCatalogName": "CC-0011",
                        "courseScheduleStatus": false,
                        "courseUserEnrollment": {
                            "certificateGenrated": false,
                            "completed": false,
                            "completionPercentage": 0,
                            "courseCatalogId": "",
                            "courseScheduleId": "a1i2L000002X8nMQAS",
                            "courseUserModuleList": [

                            ],
                            "enrollmentStatus": "",
                            "id": "a1j2L000007hjlWQAQ",
                            "status": "Planned",
                            "totalModules": 2,
                            "totalModulesCompleted": 0,
                            "userId": "0052L000003D9sZQAS"
                        },
                        "id": "a1i2L000002X8nMQAS",
                        "otherRequirment": "",
                        "passingGrade": 0,
                        "resourceRequestStatus": "",
                        "roomCapacity": 0,
                        "seatingRequirment": "",
                        "startDate": "2019-04-19T04:00:04.000Z",
                        "totalParticipantsAllowed": 0,
                        "totalWaitlistParticipants": 0
                    },
                    "courseSummary": "<p>Sed ut molestie turpis. Sed et tellus ac velit auctor ultricies sed commodo metus. Pellentesque id porta lectus. Vestibulum non libero sit amet eros finibus rutrum. Suspendisse a ligula a justo convallis aliquet. Donec condimentum luctus leo. Vivamus lacinia pharetra aliquet. Nulla ornare, lorem ut mollis tincidunt, lorem justo pretium dolor, id interdum nibh leo ut tellus. Sed tempor commodo imperdiet.</p>",
                    "currentStudents": 0,
                    "duration": 3,
                    "id": "a1f2L000003BW2lQAG",
                    "isEnrolled": true,
                    "liked": false,
                    "lockButtons": true,
                    "objectives": "<p>It allows businesses to maintain summaries of different accounts along with calendars so that transparency can be obtained and different ratios such as debt-to-income ratios can be balanced at the right time, preventing any crisis or undesirable situation.</p>",
                    "overview": "<p>Mauris congue est a augue vestibulum, sit amet aliquet dolor tempor.</p>",
                    "publishDate": "2019-04-19",
                    "shortSummary": "Sed ut molestie turpis. Sed et tellus ac velit auctor ultricies sed commodo metus. Pellentesque id porta lectus. Vestibulum non libero sit amet eros finibus rutrum. Suspendisse a ligula a justo convallis aliquet. Donec condimentum luctus leo. Vivamus lacinia pharetra aliquet. Nulla ornare, lorem ut mollis tincidunt, lorem justo pretium dolor, id interdum nibh leo ut tellus. Sed tempor commodo imperdiet...",
                    "showReadMore": true,
                    "status": "Published",
                    "category": [
                        "Human Resources"
                    ],
                    "totalEnrollment": 459,
                    "totalLikes": 6,
                    "totalModule": 2
                }
            ],
            myPicklistWrapperList: [
            { "label": "adoption", "value": "adoption" },
            { "label": "foster", "value": "foster" },
            { "label": "fosterlove", "value": "fosterlove" },
            { "label": "thisisfostercare", "value": "thisisfostercare" },
            { "label": "fostercareadoption", "value": "fostercareadoption" },
            { "label": "children", "value": "children" },
            { "label": "family", "value": "family" },
            { "label": "nonprofit", "value": "nonprofit" },
            { "label": "fosteryouth", "value": "fosteryouth" },
            { "label": "adoptionjourney", "value": "adoptionjourney" },
            { "label": "adoptdontshop", "value": "adoptdontshop" },
            { "label": "adoptionrocks", "value": "adoptionrocks" },
            { "label": "youth", "value": "youth" },
            { "label": "adoptionislove", "value": "adoptionislove" },
            { "label": "adopt", "value": "adopt" },
            { "label": "covid", "value": "covid" },
            { "label": "fosterparenting", "value": "fosterparenting" },
            { "label": "community", "value": "community" },
            { "label": "fosterchildren", "value": "fosterchildren" },
            { "label": "bhfyp", "value": "bhfyp" },
            { "label": "adoptiveparents", "value": "adoptiveparents" },
            { "label": "parenting", "value": "parenting" },
            { "label": "fostercarejourney", "value": "fostercarejourney" }],
            picklistWrapperList: [{ "label": "fostercare", "value": "fostercare" },
            { "label": "adoption", "value": "adoption" },
            { "label": "foster", "value": "foster" },
            { "label": "fosterlove", "value": "fosterlove" },
            { "label": "thisisfostercare", "value": "thisisfostercare" },
            { "label": "fosterparents", "value": "fosterparents" },
            { "label": "fostercareawareness", "value": "fostercareawareness" },
            { "label": "fosterfamily", "value": "fosterfamily" },
            { "label": "fostertoadopt", "value": "fostertoadopt" },
            { "label": "fostermom", "value": "fostermom" },
            { "label": "fostering", "value": "fostering" },
            { "label": "fosterkids", "value": "fosterkids" },
            { "label": "love", "value": "love" },
            { "label": "fosteringsaveslives", "value": "fosteringsaveslives" },
            { "label": "fostercareadoption", "value": "fostercareadoption" },
            { "label": "children", "value": "children" },
            { "label": "family", "value": "family" },
            { "label": "nonprofit", "value": "nonprofit" },
            { "label": "fosteryouth", "value": "fosteryouth" },
            { "label": "adoptionjourney", "value": "adoptionjourney" },
            { "label": "adoptdontshop", "value": "adoptdontshop" },
            { "label": "adoptionrocks", "value": "adoptionrocks" },
            { "label": "youth", "value": "youth" },
            { "label": "adoptionislove", "value": "adoptionislove" },
            { "label": "adopt", "value": "adopt" },
            { "label": "covid", "value": "covid" },
            { "label": "fosterparenting", "value": "fosterparenting" },
            { "label": "community", "value": "community" },
            { "label": "fosterchildren", "value": "fosterchildren" },
            { "label": "bhfyp", "value": "bhfyp" },
            { "label": "adoptiveparents", "value": "adoptiveparents" },
            { "label": "parenting", "value": "parenting" },
            { "label": "fostercarejourney", "value": "fostercarejourney" }]
        };
        this.courseTracksWrapper = result;
        this.error = undefined;
        this.courselist = result.courseCatalogsList;
        if (this.courselist.length !== 0) {
            this.showtableall = true;
        }
        this.mycourselist = result.myCourseCatalogsList;
        if (this.mycourselist.length !== 0) {
            this.showtable = true;
        }
        this.categories = result.picklistWrapperList;
        this.mycategories = result.myPicklistWrapperList;
        //console.log('Course result: ' + JSON.stringify(result));
        this.getPaginatedData(true);

        // getCourseTracksData()
        //     .then(result => {
        //         this.courseTracksWrapper = result;
        //         this.error = undefined;
        //         this.courselist = result.courseCatalogsList;
        //         if (this.courselist.length !== 0) {
        //             this.showtableall = true;
        //         }
        //         this.mycourselist = result.myCourseCatalogsList;
        //         if (this.mycourselist.length !== 0) {
        //             this.showtable = true;
        //         }
        //         this.categories = result.picklistWrapperList;
        //         this.mycategories = result.myPicklistWrapperList;
        //         //console.log('Course result: ' + JSON.stringify(result));
        //         this.getPaginatedData(true);
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         //console.log('error: ' + JSON.stringify(error));
        //         this.courseTracksWrapper = undefined;
        //     });
    }

    // getTrack() {
    //     getTrackCourseCatalogs()
    //         .then(result => {
    //             this.trackWrapper = result;

    //             this.enrolledTrack = result.trackWrapperListEnrolled;
    //             if (this.enrolledTrack.length !== 0) {
    //                 this.showtabletrack = true;
    //             } else {
    //                 this.showtabletrack = false;
    //             }
    //             this.allTrack = result.allTrackWrapperList;
    //             if (this.allTrack.length !== 0) {
    //                 this.showtablealltrack = true;
    //             }
    //             else {
    //                 this.showtablealltrack = false;
    //             }
    //             //console.log('Track Result : ' + JSON.stringify(result));               
    //             this.error = undefined;



    //             this.getPaginatedData(true);
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             //console.log('Track Error: ' + error);
    //             this.trackWrapper = undefined;
    //         });
    // }


    handleSubCategoryChange(event) {

        var select = event.detail.value;
        var i;
        var listofcourses = [];
        var mylistofcourses = [];
        this.isfilter = false;
        this.isempty = true;

        if (select === 'All Categories') {
            this.getallData();
            // this.getTrack();
            this.isfilter = false;

        } else {
            //console.log('In Else --> ' + this.isMyCourse + ' ---> ' + this.isAllCourse);
            if (this.isMyCourse) {
                for (i = 0; i < this.mycourselist.length; i++) {
                    let mysubCategories = JSON.stringify(this.mycourselist[i].subCategory);
                    this.isfilter = true;
                    //console.log('Category');
                    if (mysubCategories.includes(select)) {
                        mylistofcourses.push(this.mycourselist[i]);
                    }
                }
            }
            if (this.isAllCourse) {
                for (i = 0; i < this.courselist.length; i++) {
                    let subCategories = JSON.stringify(this.courselist[i].subCategory);
                    this.isfilter = true;
                    if (subCategories.includes(select)) {
                        listofcourses.push(this.courselist[i]);
                    }
                }
            }
        }


        if (listofcourses.length > 0) {
            this.handlePagination(listofcourses, true);
            this.buildData(listofcourses);
            this.courselistafterfilter = listofcourses;
            this.isempty = false;
        }
        if (mylistofcourses.length > 0) {
            this.handlePagination(mylistofcourses, true);
            this.buildData(mylistofcourses);
            this.mycourselistafterfilter = mylistofcourses;
            this.isempty = false;
        }
    }

    handleInputChnage(event) {
        var listofcourses = [];
        var mylistofcourses = [];
        var trackAllListfilter = [];
        var trackMyListfilter = [];

        var i;
        var name
        var myName;
        var select = event.detail.value;
        this.isfilter = false;
        this.select = select.toLowerCase();
        this.isempty = true;

        //console.log('--> ' + this.select);
        if (this.isAllCourse) {
            for (i = 0; i < this.courselist.length; i++) {
                name = JSON.stringify(this.courselist[i].courseName);
                name = name.replace(/["]+/g, '').toLowerCase();
                //console.log('name>>',name);     
                this.isfilter = true;
                if (name.includes(this.select)) {
                    listofcourses.push(this.courselist[i]);
                }
            }
        }
        if (this.isMyCourse) {
            for (i = 0; i < this.mycourselist.length; i++) {
                myName = JSON.stringify(this.mycourselist[i].courseName).toString();
                this.isfilter = true;
                myName = myName.replace(/["]+/g, '').toLowerCase();
                //console.log('name>>',name);        
                if (myName.includes(select)) {
                    mylistofcourses.push(this.mycourselist[i]);
                }
            }
        }

        // if(this.isMyTracks){
        //     for(i=0;i<this.enrolledTrack.length;i++) {
        //         myName = JSON.stringify(this.enrolledTrack[i].name).toString();            
        //         this.isfilter = true;
        //         myName = myName.replace(/["]+/g, '').toLowerCase();

        //         if(myName.includes(select)){               
        //             trackMyListfilter.push(this.enrolledTrack[i]);
        //         }             
        //      }
        // }

        // if(this.isAllTracks){
        //     for(i=0;i<this.allTrack.length;i++) {
        //         myName = JSON.stringify(this.allTrack[i].name).toString();            
        //         this.isfilter = true;
        //         myName = myName.replace(/["]+/g, '').toLowerCase();       
        //         if(myName.includes(select)){               
        //             trackAllListfilter.push(this.allTrack[i]);
        //         }             
        //      }
        // }

        if (trackAllListfilter.length > 0) {

            // this.handlePagination(trackAllListfilter, true);
            // this.buildData(trackAllListfilter);

            this.tracklistafterfilter = trackAllListfilter;
            this.getPaginatedData(true);
            this.isempty = false;
        }

        if (trackMyListfilter.length > 0) {
            // this.handlePagination(trackMyListfilter, true);
            // this.buildData(trackMyListfilter);

            this.mytracklistafterfilter = trackMyListfilter;
            this.getPaginatedData(true);
            this.isempty = false;
        }

        if (listofcourses.length > 0) {
            // this.handlePagination(listofcourses, true);
            // this.buildData(listofcourses);

            this.courselistafterfilter = listofcourses;
            this.getPaginatedData(true);
            this.isempty = false;
        }
        if (mylistofcourses.length > 0) {
            //console.log('In My Course --> ' + mylistofcourses);
            // this.handlePagination(mylistofcourses, true);
            // this.buildData(mylistofcourses);

            this.mycourselistafterfilter = mylistofcourses;
            this.getPaginatedData(true);
            this.isempty = false;
        }
    }

    onTabChangeHandler(event) {
        this.isfilter = false;
        // this.getTrack();
        this.selectedTab = event.currentTarget.getAttribute('data-id');
        this.getallData();

        console.log('this.selectedTab: ', this.selectedTab);
        this.isMyCourse = (this.selectedTab === 'mycourse');
        this.isAllCourse = (this.selectedTab === 'allcourse');
        // this.isMyTracks = (this.selectedTab === 'mytracks');
        // this.isAllTracks = (this.selectedTab === 'alltracks');
        //console.log('Selected Tab : ' + this.selectedTab + ' --- My Course ---' + this.isMyCourse + ' ---- All Course ---- '+this.isAllCourse+' ---- My Tracks ---- ' + this.isMyTracks + ' ---- All Tracks ---- '+ this.isAllTracks);
        this.template.querySelector('.slds-is-active').classList.remove('slds-is-active');
        this.template.querySelector('.' + event.currentTarget.getAttribute('data-id')).classList.add('slds-is-active');

    }

    showlist(event) {
        let i;
        let subCat;
        let select = event.detail.value;
        this.picklistValuesList = [];
        //console.log('select : ' + select);
        if (event.detail.value === undefined || event.detail.value === null || event.detail.value === '') {

            this.showListValue = false;
        } else {
            for (i = 0; i < this.picklistValues.length; i++) {
                subCat = JSON.stringify(this.picklistValues[i]).toString();
                this.isfilter = false;
                subCat = subCat.replace(/["]+/g, '').toLowerCase();
                if (subCat.includes(select.toLowerCase())) {
                    this.showListValue = true;
                    //console.log('subCat : ' + subCat);  
                    this.picklistValuesList.push(this.picklistValues[i]);
                }
            }
        }



    }

    fillPill(event) {
        //console.log(event.currentTarget.getAttribute('data-value'));
        this.pill.push(event.currentTarget.getAttribute('data-value'));
    }

    getPaginatedData(doReset) {
        var records = [];
        console.log('Filter : ' + this.isfilter);
        console.log('selectedTab : ' + this.selectedTab);

        if (this.isfilter === false) {
            if (this.selectedTab === 'mycourse') {
                records = this.mycourselist;
            } else if (this.selectedTab === 'allcourse') {
                records = this.courselist;
            }
            // else if (this.selectedTab === 'mytracks') {
            //     records = this.enrolledTrack;
            // } else if (this.selectedTab === 'alltracks') {
            //     records = this.allTrack;
            // }

        } else {
            if (this.selectedTab === 'mycourse') {
                records = this.mycourselistafterfilter;
            } else if (this.selectedTab === 'allcourse') {
                records = this.courselistafterfilter;
            }
            // else if (this.selectedTab === 'mytracks') {
            //     records = this.mytracklistafterfilter;
            // } else if (this.selectedTab === 'alltracks') {
            //     records = this.tracklistafterfilter;
            // }
        }
        if (records.length > 0) this.isempty = false;
        this.handlePagination(records, doReset);
        this.buildData(records);
    }

    handlePagination(records, doReset) {
        if (doReset === true) {
            this.currentPageNumber = 1;
            this.totalRecords = records.length;
            this.totalPages = Math.ceil(records.length / this.pageSize);
            this.showPaginationBar = this.totalPages > 0;
        }
        this.firstpage();
    }
    generatePageList(pageNumber) {
        this.pageNumber = pageNumber;
        let pageList = [];
        let totalPages = this.totalPages;
        //console.log('Total Page -->' + this.totalPages);
        if (totalPages > 1) {
            if (totalPages <= 10) {
                let counter = 1;
                for (; counter <= (totalPages); counter++) {
                    pageList.push(counter);
                }
            } else {
                if (pageNumber < 5) {
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if (pageNumber > (totalPages - 5)) {
                        pageList.push(totalPages - 5, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1);
                    } else {
                        pageList.push(pageNumber - 2, pageNumber - 1, pageNumber, pageNumber + 1, pageNumber + 2);
                    }
                }
            }
        }
        this.pageList = pageList;
        //console.log('Length of Page List --> ' + this.pageList.length);
        //console.log('Page List --> ' + this.pageList);
        if (this.pageList.length > 1) {
            this.isListValue = true;
            this.showFirst = false;
        } else {
            this.isListValue = false;
            this.showFirst = true;
        }
        // if (totalPages >= 1) {
        //     this.showFirst = true;
        // } else {
        //     this.showFirst = false;
        // }
    }

    buildData(allData) {
        var data = [];
        var pageNumber = this.currentPageNumber;
        var pageSize = this.pageSize;
        var x = (pageNumber - 1) * pageSize;
        //creating data-table data
        for (; x < (pageNumber) * pageSize; x++) {
            if (allData[x]) {
                let currentData = allData[x];
                data.push(currentData);
            }
        }
        this.clientData = data;
        this.generatePageList(pageNumber);
    }

    onNext() {
        var pageNumber = this.currentPageNumber;
        this.currentPageNumber = pageNumber + 1;
        this.getPaginatedData(false);
    }

    onPrev() {
        var pageNumber = this.currentPageNumber;
        this.currentPageNumber = pageNumber - 1;
        this.getPaginatedData(false);
    }

    processMe(event) {
        this.currentPageNumber = parseInt(event.target.name);
        this.getPaginatedData(false);
    }

    onFirst() {
        this.currentPageNumber = 1;
        this.getPaginatedData(false);
    }

    onLast() {
        this.currentPageNumber = this.totalPages;
        this.getPaginatedData(false);
    }

    firstpage() {
        if (this.currentPageNumber === 1) {
            this.isDisabled = true;
            this.firstSelected = 'selected';
        } else {
            this.firstSelected = '';
            this.isDisabled = false;
        }
        if (this.currentPageNumber === this.totalPages) {
            this.isTotal = true;
            this.lastSelected = 'selected';
        } else {
            this.isTotal = false;
            this.lastSelected = '';
        }
        if (this.totalPages === 0) {
            this.isTotal = true;
            this.isDisabled = true;
        }
    }

    get optionsSize() {
        return [
            { label: '5', value: '5' },
            { label: '10', value: '10' },
            { label: '15', value: '15' },
        ];
    }

    handleChange(event) {
        //console.log(parseInt(event.detail.value,10));
        this.pageSize = parseInt(event.detail.value, 10);
        this.getallData();
        // this.getTrack();
    }

    handleCourseEnroll(event) {
        let courseid = event.detail.courseid;
        console.log('courseid: ', courseid);
        let alldata = [];
        alldata = this.courselist;
        let save;
        alldata.forEach(element => {
            if (element.id === courseid) {
                element.isEnrolled = true;
                element.lockButtons = true;
                save = element;
            }
        });
        this.courselist = alldata;

        let mydata = [];
        mydata = this.mycourselist;
        mydata.push(save);
        this.mycourselist = mydata;

        this.getPaginatedData(true);

    }
}