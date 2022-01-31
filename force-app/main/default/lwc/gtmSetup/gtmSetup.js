import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import createNewGTMEvent from '@salesforce/apex/GTMSetupController.createMeeting';
//import initialInfo from '@salesforce/apex/GTMSetupController.getInitialInfo';
import startTheMeeting from '@salesforce/apex/GTMSetupController.startMeeting';
import getAttendees from '@salesforce/apex/GTMSetupController.getAttendees';
import EVENT_OBJECT from '@salesforce/schema/Event';
import SUBJECT_FIELD from '@salesforce/schema/Event.Subject';
import {
    showMessage
} from 'c/util';

const attendeeColumns = [{
        label: 'Attendee Name',
        fieldName: 'attendeeName'
    },
    {
        label: 'Email',
        fieldName: 'attendeeEmail',
        type: 'email'
    },
    {
        label: 'Join Time',
        fieldName: 'joinTime',
        type: 'date',
        typeAttributes: {
            year: "2-digit",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    {
        label: 'Leave Time',
        fieldName: 'leaveTime',
        type: 'date',
        typeAttributes: {
            year: "2-digit",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
];

export default class GtmSetup extends LightningElement {
    startDateTime;
    meetingIdFieldExist;
    @track isError;
    @track errorMessage;
    @api recordId;
    @api showEventCreateButton;
    @api showStartMeetingButton;
    @api showGetAttendeesButton;
    @track listOfAttendees = [];
    @track columns = attendeeColumns;
    @track tableLoadingState = true;
    selectedAttendees;
    eventData = {};

    eventObject = EVENT_OBJECT;
    eventFields = [SUBJECT_FIELD];



    changeStartDateTime(event) {
        this.startDateTime = event.target.value;
    }
    createGTMMeeting() {
        let createMeetingSuccess = result => {
            showMessage(this, {
                message: 'Meeting Created Successfully',
                messageType: 'success',
                mode: 'pester'
            });
            this.closeModal('.create-meeting-modal');
        }

        let createMeetingFailure = error => {
            this.isError = true;
            this.errorMessage = error.body.message;
        }

        let startTime = new Date(Date.parse(this.startDateTime));
        let endTime = new Date();

        endTime.setTime(startTime.getTime() + (30 * 60 * 1000));

        this.eventData.recordId = this.recordId;
        this.eventData['subject'] = 'Covid-19 Telemedic Call';
        this.eventData['meetingType'] = 'hm';
        this.eventData['description'] = 'Covid-19 Telemedic Call';
        let params = {
            eventData: this.eventData
        }
        createNewGTMEvent(params).then(createMeetingSuccess).catch(createMeetingFailure);
    }

    // @wire(initialInfo, {
    //     recordId: '$recordId'
    // })
    // setInitialInfo({
    //     error,
    //     data
    // }) {
    //     if (data) {
    //         console.log('success');
    //     } else if (error) {
    //         this.isError = true;
    //         this.errorMessage = error.body.message;
    //     }
    // }

    get meetingOptions() {
        return [{
                label: 'Hangout Meet',
                value: 'hm'
            }
        ];
    }

    startMeeting() {
        let startTheMeetingSuccess = result => {
            window.open(result);
        }

        let startTheMeetingError = error => {
            showMessage(this, {
                message: 'Error while starting meeting',
                messageType: 'error',
                mode: 'pester'
            });
        }
        startTheMeeting({
            eventId: this.recordId
        }).then(startTheMeetingSuccess).catch(startTheMeetingError);
    }

    fetchAttendees() {
        this.openModal('.show-attendees-modal');
        let getAttendeesSuccess = result => {
            this.listOfAttendees = result;
            this.tableLoadingState = false;
        }

        let getAttendeesError = error => {
            showMessage(this, {
                message: 'Error while fetching attendees',
                messageType: 'error',
                mode: 'pester'
            });
            this.tableLoadingState = false;
        }
        getAttendees({
            eventId: this.recordId
        }).then(getAttendeesSuccess).catch(getAttendeesError);
    }

    getSelectedAttendees(event) {
        //alert(1);
        const selectedRows = event.detail.selectedRows;
        this.selectedAttendees = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            if(selectedRows[i].attendeeEmail.trim().length > 0)
                this.selectedAttendees.push(selectedRows[i].attendeeEmail);
        }
    }


    createEventData(event) {
        this.eventData[event.target.name] = event.detail.value;
    }

    openModal(modalClass) {
        this.template.querySelector(modalClass).classList.add('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
    }

    closeModal(modalClass) {
        this.template.querySelector(modalClass).classList.remove('slds-fade-in-open');
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
    }

    openCreateMeetingModal() {
        this.openModal('.create-meeting-modal');
    }

    closeCreateMeetingModal() {
        this.closeModal('.create-meeting-modal');
    }

    closeAttendeesModal() {
        this.closeModal('.show-attendees-modal');
    }

    // constructor(){
    //     super();
    //     let initialInfoSuccess = result => {

    //     }
    //     let initialInfoError = error => {
    //         this.isError = true;
    //         this.errorMessage = error.body.message;
    //     }
    //     alert(this.recordId);
    //     initialInfo({recordId : this.recordId}).then(initialInfoSuccess).catch(initialInfoError);
    // }
}