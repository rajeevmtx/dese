import { LightningElement, track, api } from 'lwc';
import lmsModule from '@salesforce/resourceUrl/ModuleIcon';
// import allcourseCompleted from '@salesforce/apex/LMS_Controller.allcourseCompleted';
// import validateCertitficateGenrated from '@salesforce/apex/LMS_Controller.validateCertitficateGenrated';
// import generatCertificate from '@salesforce/apex/LMS_Controller.generatCertificate';
export default class Lms_course_certificate extends LightningElement {
    onlineinc = lmsModule + '/certificatebackground.jpg';



    @track _userEnroll;
    @track certificate;
    @track overview;
    @track error; // to show error message from apex controller.
    @track success; // to show succes message in ui.
    @track validateButton;
    @track validateCertificate;
    @track genratedCertificate;
    @api courseid;
    @api scheduledid;
    @track userEnroll;


    @api
    set userEnrollment(value) {
        this.userEnroll = value;
        this.validateCertitifcation();
    }

    get userEnrollment() {
        return {};
    }


    redirectCert() {

        let navgateURL = 'https://' + window.location.host + '/apex/LMS_CertificateDownload?enrollmentId=' + this.userEnroll;
        window.open(navgateURL);
    }

    validateCertitifcation() {
        this.certificate = { "CourseName": "", "genratedDate": "", "isCertificateGenrated": false, "isCourseCompleted": false, "Message": "", "UserName": "", "$serId$": 22 };
        if (this.certificate.isCertificateGenrated === true) {
            this.validateButton = false;
        } else {
            this.validateModules();
        }
        //console.log('result : ' + JSON.stringify(result));
        this.error = undefined;

        // validateCertitficateGenrated({ userEnroll: this.userEnroll })
        //     .then(result => {
        //         this.certificate = result;
        //         if (this.certificate.isCertificateGenrated === true) {
        //             this.validateButton = false;
        //         } else {
        //             this.validateModules();
        //         }
        //         //console.log('result : ' + JSON.stringify(result));
        //         this.error = undefined;
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         this.certificate = undefined;
        //     });
    }

    validateModules() {
        this.validateButton = false;

        // allcourseCompleted({ userEnroll: this.userEnroll })
        //     .then(result => {
        //         this.validateButton = result;
        //         this.error = undefined;
        //     })
        //     .catch(error => {
        //         this.error = error;
        //         this.certificate = undefined;
        //     });
    }

    genrateNewCertitifcate() {
        generatCertificate({ userEnroll: this.userEnroll })
            .then(result => {
                this.certificate = result;
                this.error = undefined;
                this.validateButton = false;
            })
            .catch(error => {
                this.error = error;
                this.certificate = undefined;
            });
    }

    download() {
        var prtContent = this.template.querySelector(".capture");
        var WinPrint = window.open('', '', 'left=0,top=0,width=800,height=900,toolbar=0,scrollbars=0,status=0');
        WinPrint.document.write(prtContent.element.textContent);
        WinPrint.document.close();
        WinPrint.focus();
        WinPrint.print();
        WinPrint.close();


    }
}