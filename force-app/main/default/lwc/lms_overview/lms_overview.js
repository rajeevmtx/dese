import { LightningElement, track, api } from 'lwc';
// import getCourseCurrentOverview from '@salesforce/apex/LMS_Controller.getCourseCurrentOverview';
export default class Lms_overview extends LightningElement {

    @track overview;
    @track error; // to show error message from apex controller.
    @track success; // to show succes message in ui.
    @track _courseId;




    @api
    set courseid(value) {
        this._courseId = value;
        this.getCourseOverview();
    }

    get courseid() {
        return {};
    }

    @api scheduledid;
    @api userEnrollment;
    // method for get  accounts.
    // constructor(){
    //     super();
    //     let url = new URL(window.location.href);
    //     this.courseid = url.searchParams.get("courseid");
    //     this.scheduledid = url.searchParams.get("scheduleid");
    //     this.userEnrollment = url.searchParams.get("enrollid");
    //     this.getCourseOverview();
    // }
    getCourseOverview() {
        this.overview = '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. In porta consequat orci sit amet ultricies. Ut efficitur augue lacus, id feugiat tellus mattis at. Donec ut leo eget tortor tristique rutrum sit amet et lacus. Integer sodales, nunc eget maximus sollicitudin, ex sem gravida lectus, quis rhoncus felis felis ut odio: </p><ol><li>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</li><li>Donec in arcu sed odio venenatis lobortis et eget mauris.</li><li>Sed non ex fermentum, finibus arcu eget, ultricies sem.</li><li>Nulla venenatis metus semper, imperdiet tellus nec, sagittis nisi.</li><li>Curabitur a sem quis massa venenatis vestibulum.</li><li>Maecenas dictum magna ac elit dignissim, eget pretium diam auctor.</li><li>Nunc pellentesque eros molestie dolor bibendum, venenatis cursus lacus mollis.</li></ol><p><br></p>';
        // console.log(result + ' OverView');
        this.error = undefined;
        // getCourseCurrentOverview({ courseID: this._courseId })
        //     .then(result => {
        //         this.overview = result;
        //         console.log(result + ' OverView');
        //         this.error = undefined;
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         this.overview = undefined;
        //     });
    }
    navigateToCourse() {
        let navgateURL = '/connect/s/course-module?courseid=' + this._courseId + '&scheduleid=' + this.scheduledid + '&enrollid=' + this.userEnrollment;
        window.open(navgateURL, "_self");
    }
}