import { LightningElement, api,track } from 'lwc';

export default class FcApplicantInfo extends LightningElement {

    @api applicationId;
    @track isEducationSelected = false;
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
    @track isMarried = false;
    @track isPrevMarried = false;
    @track educationObj = { "eighth": false, "highSchool": false, "highSchoolEquivalent": false, "trainingBeyond": false, "collegeLevelCourse": false, "collegeGraduate": false, "postGratuation": false };
    @track applicantData = {};

    connectedCallback(){
        console.log('=Applicant Info=applicationId==>', this.applicationId);
    }

    @api
    isValid(callback) {
        console.log('In Applicant info check');

        let valid = true;
        this.showSpinner = true;
 
        // let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
        //     input.reportValidity();
        //     return validSoFar && input.checkValidity();
        // }, true);

        // isAllValid &= [
        //     ...this.template.querySelectorAll("lightning-radio-group")
        // ].reduce((validSoFar, input) => {
        //     input.reportValidity();
        //     return validSoFar && input.checkValidity();
        // }, true);

        // isAllValid &= [...this.template.querySelectorAll('lightning-combobox')]
        //     .reduce((validSoFar, inputCmp) => {
        //         inputCmp.reportValidity();
        //         return validSoFar && inputCmp.checkValidity();
        //     }, true);

        // console.log('educationObj-->', this.educationObj);
        // let educationValid = true;
        // if (this.showDeliveryDays == false) {
        //     educationValid = false;
        //     this.isEducationSelected = true;
        //     Object.keys(this.educationObj).forEach((key, index) => {
        //         if (this.educationObj[key] == true) {
        //             educationValid = true;
        //             this.isEducationSelected = false;
        //         }
        //     });
        // }

        // if (isAllValid && educationValid) {
        //     valid = true;
        // } else {
        //     valid = false;
        // }

        this.showSpinner = false;
        callback({
            applicationId: this.applicationId,
            valid: valid
        });             
    }

    get raceOptions() {
        return [
            { label: 'African American', value: 'African American' },
            { label: 'Asian Indian', value: 'Asian Indian' },
            { label: 'Cambodian', value: 'Cambodian' },
            { label: 'Caribean', value: 'Caribean' },
            { label: 'Caucasian', value: 'new' },
            { label: 'Central American', value: 'Central American' },
            { label: 'Chinese', value: 'Chinese' },
            { label: 'Ethiopian', value: 'Ethiopian' },
            { label: 'Filipino', value: 'Filipino' },
            { label: 'Guamenian', value: 'Guamenian' },
            { label: 'Hispanic or Latino', value: 'Hispanic or Latino' },
            { label: 'Japanese', value: 'Japanese' },
            { label: 'Korean', value: 'Korean' },
            { label: 'Mexican', value: 'Mexican' },
            { label: 'Native American', value: 'Native American' },
            { label: 'Other Asian', value: 'Other Asian' },
            { label: 'Other Pacific Islander', value: 'Other Pacific Islander' },
            { label: 'Samoan', value: 'Samoan' },
            { label: 'Vietnamese', value: 'Vietnamese' },
            { label: 'Other', value: 'Other' }
        ];
    }

    get genderOptions() {
        return [
            { label: 'Male', value: 'Male' },
            { label: 'Female', value: 'Female' }
        ];
    }

    get educationOptions() {
        return [
            { label: 'Eighth grade or less', value: 'Eighth grade or less' },
            { label: 'Some high school', value: 'Some high school' },
            { label: 'High school or equivalent', value: 'High school or equivalent' },
            { label: 'Technical training beyond high school', value: 'Technical training beyond high school' },
            { label: 'Some college or college level courses', value: 'Some college or college level courses' },
            { label: 'College graduate', value: 'College graduate' },
            { label: 'Post-graduate education', value: 'Post-graduate education' }
        ];
    }

    get martialOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            { label: 'N/A', value: 'N/A' }
        ];
    }

    get partnershipOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    educationCheckBoxhandler(event) {

        console.log("Check Value : " + event.target.name + '--' + event.detail.checked);
        this.isEducationSelected = false;

        if (event.target.name === 'eighth') {
            this.applicantData.eighth = event.detail.checked;
            this.educationObj.eighth = event.detail.checked;

        } else if (event.target.name === 'highSchool') {
            this.applicantData.highSchool = event.detail.checked;
            this.educationObj.highSchool = event.detail.checked;

        } else if (event.target.name === 'highSchoolEquivalent') {
            this.applicantData.highSchoolEquivalent = event.detail.checked;
            this.educationObj.highSchoolEquivalent = event.detail.checked;

        } else if (event.target.name === 'trainingBeyond') {
            this.applicantData.trainingBeyond = event.detail.checked;
            this.educationObj.trainingBeyond = event.detail.checked;

        } else if (event.target.name === 'collegeLevelCourse') {
            this.applicantData.collegeLevelCourse = event.detail.checked;
            this.educationObj.collegeLevelCourse = event.detail.checked;

        } else if (event.target.name === 'collegeGraduate') {
            this.applicantData.collegeGraduate = event.detail.checked;
            this.educationObj.collegeGraduate = event.detail.checked;

        } else if (event.target.name === 'postGratuation') {
            this.applicantData.postGratuation = event.detail.checked;
            this.educationObj.postGratuation = event.detail.checked;
        }
    }

    handleInput(event) {

        if (event.target.name === 'firstname') {
            event.target.value = event.target.value.trim();
            this.applicantData.firstname = event.target.value;
        }
        else if (event.target.name === 'middlename') {
            event.target.value = event.target.value.trim();
            this.applicantData.middlename = event.target.value;
        }
        else if (event.target.name === 'lastname') {
            event.target.value = event.target.value.trim();
            this.applicantData.lastname = event.target.value;
        }
        else if (event.target.name === 'previousname') {
            event.target.value = event.target.value.trim();
            this.applicantData.previousname = event.target.value;
        }
        else if (event.target.name === 'emailAddress') {
            event.target.value = event.target.value.trim();
            this.applicantData.emailAddress = event.target.value;
        }
        else if (event.target.name === 'cellphonenumer') {
            event.target.value = event.target.value.trim();
            this.applicantData.cellphonenumer = event.target.value;
        }
        else if (event.target.name === 'dateofbirth') {
            event.target.value = event.target.value.trim();
            this.applicantData.dateofbirth = event.target.value;
        }
        else if (event.target.name === 'genderStatus') {
            event.target.value = event.target.value.trim();
            this.applicantData.genderStatus = event.target.value;
        }
        else if (event.target.name === 'licensenumber') {
            event.target.value = event.target.value.trim();
            this.applicantData.licensenumber = event.target.value;
        }    
        else if (event.target.name === 'maritalStatus') {
            event.target.value = event.target.value.trim();
            this.applicantData.maritalStatus = event.target.value;
            if (event.target.value == 'Yes') {
                this.isMarried = true;
            } else {
                this.isMarried = false;
            }
        }
        else if (event.target.name === 'dateofmarriage') {
            event.target.value = event.target.value.trim();
            this.applicantData.dateofmarriage = event.target.value;
        } 
        else if (event.target.name === 'place') {
            event.target.value = event.target.value.trim();
            this.applicantData.place = event.target.value;
        } 
        else if (event.target.name === 'prevMaritalStatus') {
            event.target.value = event.target.value.trim();
            this.applicantData.prevMaritalStatus = event.target.value;
            if (event.target.value == 'Yes') {
                this.isPrevMarried = true;
            } else {
                this.isPrevMarried = false;
            }
        }
        else if (event.target.name === 'howManyMarital') {
            event.target.value = event.target.value.trim();
            this.applicantData.howManyMarital = event.target.value;
        }
       
    }
}