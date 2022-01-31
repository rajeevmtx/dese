import { LightningElement,track, api } from 'lwc';
import lmsModule from '@salesforce/resourceUrl/ModuleIcon';
// import fetchCourseModulesAttachments from '@salesforce/apex/LMS_Controller.fetchCourseModulesAttachments';

export default class Lms_download_course_content extends LightningElement {
    @track recordsToDisplay;
    @track error; // to show error message from apex controller.
    @track success; // to show succes message in ui.
    @track attachmentlist;
    //courseId;
    @track showtable = false;
    @track _courseId;
    nodownloads = lmsModule + '/nodownloads.svg';
    @api 
    set courseid(value) {
        this._courseId = value;
        // this.getallData();
    }
    
    get courseid(){
        return{};
    }

    @api scheduledid;
    @api userEnrollment;

    //constructor(){
    //     super();
    //     let url = new URL(window.location.href);
    //     this.courseid = url.searchParams.get("courseid");
    //     console.log('courseid>>',this.courseid);
    //     this.scheduledid = url.searchParams.get("scheduleid");
    //     this.userEnrollment = url.searchParams.get("enrollid");
    //     this.getallData(); 
    //     //this.getList();

    // }
    
    downloadfile(event){
        window.location.href = event.target.value;

    }
    getallData() {
        
        fetchCourseModulesAttachments({coursecatalogId : this._courseId})
            .then(result => {
                this.recordsToDisplay = result;
                if(this.recordsToDisplay.length !== 0){
                    this.showtable = true;
                }
                this.error = undefined;
                console.log('result: ' + JSON.stringify(result));
            })
            .catch(error => {
                this.error = error;
                console.log('error: ' + JSON.stringify(error));
                this.recordsToDisplay = undefined;
            });       
    } 


    navigateToCourse() {
        let navgateURL = '/connect/s/course-module?courseid='+this._courseId+'&scheduleid='+this.scheduledid+'&enrollid='+this.userEnrollment;
        window.open(navgateURL,"_self");
    }
}