/**
* @author Vishnu Kumar
* @email vishnu.kumar@mtxb2b.com
* @desc Full Calendar JS - Lightning Web Components
*/
import {
  LightningElement,
  track,
  api
} from 'lwc';
import {
  loadScript,
  loadStyle
} from 'lightning/platformResourceLoader';
import fetchAppointmens from '@salesforce/apex/DC_CalendarController.fetchAppointmens';
import fetchAppointmenToSchedule from '@salesforce/apex/DC_CalendarController.fetchAppointmenToSchedule';
import blockCalender from '@salesforce/apex/DC_CalendarController.blockCalender';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';

export default class DC_AppointmentCalendar extends LightningElement {

  @api recordId;
  fullCalendarJsInitialised = false;
  @track eventList = [];
  @track todayValue;
  @track appointmentObj = {};
  @track startDateValue;
  @track endDateValue;
  @track calendarView;
  @track detailModal = false;
  @track appointmentDetail = {};
  @track isToBeSchedule = false;
  @track openmodel = false;

  handleOpenModal() {
    this.openmodel = true;
  }
  closeModal() {
    this.openmodel = false;
  }
  closeDetailModal() {
    this.detailModal = false;
  }

  startDateChange(event) {
    this.startDateValue = event.target.value;
  }

  endDateChange(event) {
    this.endDateValue = event.target.value;
  }

  scheduleAppointment() {
    blockCalender({
      appointmentId: this.recordId,
      appointmentStartDate: this.startDateValue,
      appointmentEndDate: this.endDateValue
      }).then(result => {
        this.closeModal();
        window.location.href = window.location.href;
      })
      .catch(error => {
        this.error = error;
        console.log('error-->' + JSON.stringify(error));
      });
  }
  
  fetchAppointmentDetail(id) {
    fetchAppointmenToSchedule({ appointmentId: id }).then(result => {
      this.appointmentDetail = result;
      this.detailModal = true;
    })
    .catch(error => {
      this.error = error;
    });
  }

  /**
  * @author Vishnu Kumar
  * @email vishnu.kumar@mtxb2b.com
  * @desc Load initial data from server for appoitments.
  */
  handleLoad() {
    fetchAppointmens().then(result => {
        console.log('resp--->' + JSON.stringify(result));
        
        for (let i = 0; i < result.length; i++) {
          let descriptions = {
            title: result[i].appointmentName,
            description: 'Description for All Day Event',
            id: result[i].appointmentId,
            start: result[i].appointmentStartDate,
            end: result[i].appointmentEndDate
          };
          
          this.eventList.push(descriptions);
        }

        this.fetchTodayDate();
        this.initialiseFullCalendarJs();
      })
      .catch(error => {
        this.error = error;
      });
  }

  connectedCallback() {
    if (this.recordId) {
      this.calendarView = 'timeGridWeek';
    }
    else {
      this.calendarView = 'dayGridMonth';
    }
  }

  /**
  * @author Vishnu Kumar
  * @email vishnu.kumar@mtxb2b.com
  * @desc get today's date
  */
  fetchTodayDate() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();

    this.todayValue = yyyy + '-' + mm + '-' + dd;
  }

  /**
  * @author Vishnu Kumar
  * @email vishnu.kumar@mtxb2b.com
  * @desc Standard lifecyle method 'renderedCallback'
  *              Ensures that the page loads and renders the 
  *              container before doing anything else
  */
  renderedCallback() {
    // Performs this operation only on first render
    if (this.fullCalendarJsInitialised) {
      return;
    }
    this.fullCalendarJsInitialised = true;

    
    Promise.all([
        loadStyle(this, FullCalendarJS + '/fullcalendar/packages/core/main.css'),
        loadScript(this, FullCalendarJS + '/fullcalendar/packages/core/main.js')
      ])
      .then(() => {

        Promise.all([
            loadStyle(this, FullCalendarJS + '/fullcalendar/packages/daygrid/main.css'),
            loadStyle(this, FullCalendarJS + '/fullcalendar/packages/timegrid/main.css'),
            loadScript(this, FullCalendarJS + '/fullcalendar/packages/daygrid/main.js'),
            loadScript(this, FullCalendarJS + '/fullcalendar/packages/timegrid/main.js'),
            loadScript(this, FullCalendarJS + '/fullcalendar/packages/interaction/main.js'),
            loadScript(this, FullCalendarJS + '/fullcalendar/packages/list/main.js'),
            loadScript(this, FullCalendarJS + '/fullcalendar/packages/moment/main.js'),
            loadScript(this, FullCalendarJS + '/fullcalendar/packages/moment-timezone/main.js')

          ]).then(() => {
            this.handleLoad();
          })
          .catch(error => {
            // eslint-disable-next-line no-console
            console.error({
              message: 'Error occured on FullCalendarJS',
              error
            });
          })
      })
      .catch(error => {
        // eslint-disable-next-line no-console
        console.error({
          message: 'Error occured on FullCalendarJS',
          error
        });
      })
  }

  /**
  * @author Vishnu Kumar
  * @email vishnu.kumar@mtxb2b.com
  * @desc Initialise the calendar configuration
  *              This is where we configure the available options for the calendar.
  *              This is also where we load the Events data.
  */
  initialiseFullCalendarJs() {
    let _self = this;

    const ele = this.template.querySelector('div.fullcalendarjs');

    let calendarEvents = [];

    // eslint-disable-next-line no-undef
    let calendar = new FullCalendar.Calendar(ele, {
      plugins: ['interaction', 'dayGrid', 'timeGrid', 'list', 'momentTimezone'],
      timeZone: 'UTC',
      defaultView: this.calendarView,
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay'
      },
      height: 650,
      editable: true,
      navLinks: true,
      weekNumbers: true,
      weekNumbersWithinDays: true,
      weekNumberCalculation: 'ISO',
      eventLimit: true,
      selectable: true,
      select: function (arg) {
        var title = prompt('Event Title:');
        if (title) {
          calendar.addEvent({
            title: title,
            start: arg.start,
            end: arg.end,
            allDay: arg.allDay
          })
        }
        calendar.unselect()
      },
      selectMirror: true,

      eventRender: function (info) {
        info.el.setAttribute('data-tooltip', info.event.title);
        info.el.classList.add('tooltip');

        function handler() {
          //alert( info.event.title );
          console.log('tool');
          _self.fetchAppointmentDetail(info.event.id);
        }
        info.el.addEventListener("click", handler);
      },
      dateClick: function (info) {
        // eslint-disable-next-line no-console
        console.log('dateClec : ', info);
      },
      eventClick: function (info) {
        // eslint-disable-next-line no-console
        console.log('eventClick : ', info);
      },
      events: this.eventList
    });

    calendar.render();
  }
}