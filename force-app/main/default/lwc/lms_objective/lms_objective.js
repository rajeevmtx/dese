import { LightningElement,track,api } from 'lwc';
// import getCourseCurrentObjective from '@salesforce/apex/LMS_Controller.getCourseCurrentObjective';
export default class Lms_objective extends LightningElement {
    @track objective;
    @track error; // to show error message from apex controller.
    @track success;
    @track _courseId; // to show succes message in ui.
    @api 
    set courseid(value) {
        this._courseId = value;
        // this.getCourseObjective();
    }
    
    get courseid(){
        return{};
    }

    @api courseObjective;

    @api scheduledid;
    @api userEnrollment;
    // method for get  accounts.
    // constructor(){
    //     super();
    //     let url = new URL(window.location.href);
    //     this.courseid = url.searchParams.get("courseid");
    //     this.scheduledid = url.searchParams.get("scheduleid");
    //     this.userEnrollment = url.searchParams.get("enrollid");
    //     this.getCourseObjective();
    //}
    getCourseObjective() {
        // getCourseCurrentObjective({courseID : this._courseId})
        //     .then(result => {
        //         this.objective = result;
        //         this.error = undefined;
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         this.objective = undefined;
        //     });
    } 
    navigateToCourse() {
        let navgateURL = '/connect/s/course-module?courseid='+this._courseId+'&scheduleid='+this.scheduledid+'&enrollid='+this.userEnrollment;
        window.open(navgateURL,"_self");
    }
}