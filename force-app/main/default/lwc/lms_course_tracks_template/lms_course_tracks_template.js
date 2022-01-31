import {
    LightningElement,
    api,
    track
} from 'lwc';
import lmsStaticResource from '@salesforce/resourceUrl/LMS_Design';
import lmsModule from '@salesforce/resourceUrl/ModuleIcon';
// import enrollUserInCourse from '@salesforce/apex/LMS_Controller.enrollUserInCourse';
// import increaseLikesOnCourse from '@salesforce/apex/LMS_Controller.increaseLikesOnCourse';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
// import decreaseLikesOnCourse from '@salesforce/apex/LMS_Controller.decreaseLikesOnCourse';
import { NavigationMixin } from 'lightning/navigation';


export default class Lms_course_tracks_template extends NavigationMixin(LightningElement) {

    enrolledIcon = lmsStaticResource + '/images/enrolled.svg';
    thumbup = lmsModule + '/like-default.svg';
    thumbblue = lmsModule + '/liked.svg';

    @api isempty;
    @api myCourse;
    @track flag = false;
    @track courseTracks;
    @track showSummary = false;
    @track hideSummary = true;
    nocourses = lmsModule + '/nocourses.svg';


    @api
    set courseTracksWrapper(value) {
        this.courseTracks = value;
        // console.log('vatsalll::', JSON.stringify(this.courseTracks));
    }

    get courseTracksWrapper() {
        return {};
    }



    navigateNext(event) {
        // let navgateURL = '/connect/s/course-module?courseid='+ event.currentTarget.getAttribute('data-id') + '&scheduleid='+ event.currentTarget.getAttribute('data-schedule') + '&enrollid=' +event.currentTarget.getAttribute('data-enroll');
        // window.open(navgateURL,"_self");
        try {
            // console.log('log: ', JSON.stringify(this.courseTracks));
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'myinternalcoursemodule'
                },
                state: {
                    c__courseid : this.courseTracks.id,
                    c__enrollid : this.courseTracks.courseScheduleObject.courseUserEnrollment.id,
                    c__scheduleid : this.courseTracks.courseScheduleObject.id,
                    c__courseName: this.courseTracks.courseName,
                    c__courseObjective: this.courseTracks.courseSummary
                }
            })
        } catch (error) {
            console.log('error : ', error);
        }

    }

    enrollUser(event) {
        let _courseId = event.currentTarget.getAttribute('data-courseid');
        let _courseScheduleId = event.currentTarget.getAttribute('data-course-schedule-id');
        console.log('Event Called : ' + _courseId + ' --> Schedule Id : ' + _courseScheduleId);

        const toastEvnt = new ShowToastEvent({
            title: 'Success',
            message: 'You have successfully enrolled for this Course.',
            variant: 'success',
        });
        this.dispatchEvent(toastEvnt);

        const eventMessage = new CustomEvent('enrollcourse', {
            detail: { courseid: _courseId }
        });
        this.dispatchEvent(eventMessage);

        // enrollUserInCourse({
        //         courseId: _courseId,
        //         courseScheduleId: _courseScheduleId,
        //         isMyCourse: this.myCourse
        //     })
        //     .then(result => {
        //         this.courseTracks = result;
        //         this.error = undefined;
        //         const toastEvnt = new ShowToastEvent({
        //             title: 'Success',
        //             message: 'You have successfully enrolled for this Course.',
        //             variant: 'success',
        //         });
        //         this.dispatchEvent(toastEvnt);
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         console.log('error: ' + JSON.stringify(error));
        //         this.courseTracks = undefined;
        //         const toastEvnt = new ShowToastEvent({
        //             title: 'Error',
        //             message: 'User Not Enrolled',
        //             variant: 'error',
        //         });
        //         this.dispatchEvent(toastEvnt);
        //     });
    }

    // increaseLike(event) {
    //     increaseLikesOnCourse({
    //             courseId: event.currentTarget.getAttribute('data-courseid'),
    //             isMyCourse: this.myCourse
    //         })
    //         .then(result => {
    //             this.courseTracks = result;
    //             this.error = undefined;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             console.log('error: ' + JSON.stringify(error));
    //             this.coursedata = undefined;

    //         });
    // }

    // decreaseLike(event) {
    //     decreaseLikesOnCourse({
    //             courseId: event.currentTarget.getAttribute('data-courseid'),
    //             isMyCourse: this.myCourse
    //         })
    //         .then(result => {
    //             this.courseTracks = result;
    //             this.error = undefined;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             console.log('error: ' + JSON.stringify(error));
    //             this.coursedata = undefined;

    //         });
    // }

    showDetail() {
        this.showSummary = true;
        this.hideSummary = false;
    }

    hideDetail() {
        this.showSummary = false;
        this.hideSummary = true;

    }
}