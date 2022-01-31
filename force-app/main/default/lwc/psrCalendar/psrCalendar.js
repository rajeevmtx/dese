import { LightningElement, track } from "lwc";
import FullCalendarJS from "@salesforce/resourceUrl/FullCalendarJS";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import fetchInspections from "@salesforce/apex/PsrCalendarController.fetchInspections";
import fetchInspectionsToSchedule from "@salesforce/apex/PsrCalendarController.fetchInspectionsToSchedule";

/**
 * FullCalendarJs
 * @description Full Calendar JS - Lightning Web Components
 */
export default class PsrCalendar extends LightningElement {
  fullCalendarJsInitialised = false;
  @track eventList = [];
  @track todayValue;
  @track detailModal = false;
  @track inspectionDetail = {};

  closeDetailModal() {
    this.detailModal = false;
  }

  fetchInspectionDetail(id) {
    console.log("IDS--->", id);
    fetchInspectionsToSchedule({ inspectionId: id })
      .then(result => {
        console.log(
          "fetchInspectionDetail__result-->" + JSON.stringify(result)
        );
        this.inspectionDetail = result;
        this.detailModal = true;
      })
      .catch(error => {
        this.error = error;
        console.log("fetchInspectionDetail___error-->" + JSON.stringify(error));
      });
  }

  handleLoad() {
    fetchInspections()
      .then(result => {
        console.log("resp--->" + JSON.stringify(result));
        for (let i = 0; i < result.length; i++) {
          let descriptions = {
            title: result[i].inspectionName + "/" + result[i].workOrderName,
            description: "All Day Event",
            id: result[i].inspectionId,
            start: result[i].inspectionStartDate,
            end: result[i].inspectionEndDate
          };
          this.eventList.push(descriptions);
        }
        console.log("eventList-->" + JSON.stringify(this.eventList));
        this.fetchTodayDate();
        this.initialiseFullCalendarJs();
      })
      .catch(error => {
        this.error = error;
        console.log("error-->" + error);
      });
  }

  fetchTodayDate() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
    var yyyy = today.getFullYear();

    this.todayValue = yyyy + "-" + mm + "-" + dd;
    console.log("todayValue-->" + this.todayValue);
  }

  /**
   * @description Standard lifecyle method 'renderedCallback'
   *              Ensures that the page loads and renders the
   *              container before doing anything else
   */
  renderedCallback() {
    // Performs this operation only on first render
    if (this.fullCalendarJsInitialised) {
      return;
    }
    this.fullCalendarJsInitialised = true;

    // Executes all loadScript and loadStyle promises
    // and only resolves them once all promises are done
    Promise.all([
      loadStyle(this, FullCalendarJS + "/fullcalendar/packages/core/main.css"),
      loadScript(this, FullCalendarJS + "/fullcalendar/packages/core/main.js")
    ])
      .then(() => {
        Promise.all([
          loadStyle(
            this,
            FullCalendarJS + "/fullcalendar/packages/daygrid/main.css"
          ),
          loadStyle(
            this,
            FullCalendarJS + "/fullcalendar/packages/timegrid/main.css"
          ),
          loadScript(
            this,
            FullCalendarJS + "/fullcalendar/packages/daygrid/main.js"
          ),
          loadScript(
            this,
            FullCalendarJS + "/fullcalendar/packages/timegrid/main.js"
          ),
          loadScript(
            this,
            FullCalendarJS + "/fullcalendar/packages/interaction/main.js"
          ),
          loadScript(
            this,
            FullCalendarJS + "/fullcalendar/packages/moment/main.js"
          )
        ])
          .then(() => {
            this.handleLoad();
          })
          .catch(error => {
            // eslint-disable-next-line no-console
            console.error({
              message: "Error occured on FullCalendarJS",
              error
            });
          });
      })
      .catch(error => {
        // eslint-disable-next-line no-console
        console.error({
          message: "Error occured on FullCalendarJS",
          error
        });
      });
  }

  /**
   * @description Initialise the calendar configuration
   *              This is where we configure the available options for the calendar.
   *              This is also where we load the Events data.
   */

  initialiseFullCalendarJs() {
    let _self = this;
    console.log("--thiEvent-->" + this.eventList);
    const ele = this.template.querySelector("div.fullcalendarjs");

    // eslint-disable-next-line no-undef
    let calendar = new FullCalendar.Calendar(ele, {
      plugins: ["interaction", "dayGrid", "timeGrid", "moment"],
      defaultView: "dayGridMonth",
      header: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay"
      },
      height: 650,
      editable: true,
      navLinks: true,
      weekNumbers: true,
      weekNumbersWithinDays: true,
      weekNumberCalculation: "ISO",
      eventLimit: true,
      selectable: true,
      //B-16151 VV Code Start
      timeZone: "UTC",
      //B-16151 VV Code End
      select: function(arg) {
        var title = prompt("Event Title:");
        if (title) {
          calendar.addEvent({
            title: title,
            start: arg.start,
            end: arg.end,
            allDay: arg.allDay
          });
        }
        calendar.unselect();
      },
      selectMirror: true,

      // eventRender: function(info) {
      //   var tooltip = new Tooltip(info.el, {
      //     title: info.event.extendedProps.description,
      //     placement: 'top',
      //     trigger: 'hover',
      //     container: 'body'
      //   });
      // },
      eventRender: function(info) {
        info.el.setAttribute("data-tooltip", info.event.title);
        info.el.classList.add("tooltip");
        function handler() {
          //alert( info.event.title );
          console.log("--detailEvent--");
          _self.fetchInspectionDetail(info.event.id);
        }
        info.el.addEventListener("click", handler);
      },
      // dateClick: function(info) {
      //     // eslint-disable-next-line no-console
      //     console.log('dateClec : ', info);
      // },
      eventClick: function(info) {
        // eslint-disable-next-line no-console
        console.log("eventClick : ", info);
      },
      events: this.eventList
    });

    calendar.render();
  }
}