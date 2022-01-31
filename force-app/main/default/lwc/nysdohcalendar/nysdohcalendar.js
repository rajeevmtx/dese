import { LightningElement, track ,api} from 'lwc';
import getAppintments from '@salesforce/apex/DC_ScheduleAppointment.getAccountSlots';

export default class Nysdohcalendar extends LightningElement {
    @track recid;
    @api
    get accountid(){
        return this.recid;
    }
    set accountid(val){
       this.recid = val;
       this.callApex();
    }
    
    @track data = {};
    currentSelRecordId = '';

    connectedCallback(){
        this.callApex();
    }

    callApex() {
        getAppintments({ accountId: this.recid }).then(result => {
            this.createCalendar(result);
        })
        .catch(error => {
            this.error = error;
        });
    }

    createCalendar(result) {

        this.data = {};
        let weekDays = ['SUN','MON','TUE','WED','THU','FRI','SAT'];

        let dates = [];
        let weeks = [];
        let todayDate = new Date();

        for(let count = 0; count < 7 ;count++) {
            todayDate.setDate(todayDate.getDate() + 1);
            dates.push((todayDate.getMonth() + 1) + '/' + todayDate.getDate());
            weeks.push(weekDays[todayDate.getDay()]);
        }

        this.data.rows = [];
        
        if(result.timeSlots.length > 0) {
            result.timeSlots.forEach(element => {
                
                this.addSlots(element);
            });
        } else {
            this.bulkSlot(7, 'AM');
            this.bulkSlot(8, 'AM');
            this.bulkSlot(9, 'AM');
            this.bulkSlot(10, 'AM');
            this.bulkSlot(11, 'AM');
            this.bulkSlot(12, 'AM');
            this.bulkSlot(1, 'PM');
            this.bulkSlot(2, 'PM');
            this.bulkSlot(3, 'PM');
            this.bulkSlot(4, 'PM');
            this.bulkSlot(5, 'PM');
            this.bulkSlot(6, 'PM');
            this.bulkSlot(7, 'PM');
            this.bulkSlot(8, 'PM');
        }
        
        this.data.dates = dates;
        this.data.weeks = weeks;

        let columnCount = 0;
        for (var m in result.records){
            let recds = result.records[m];
            let rowCount = 0;
            result.timeSlots.forEach(element => {
                if(typeof recds[element] != 'undefined' && recds[element] != null && recds[element].length > 0) {
                    this.data.rows[rowCount].cols[columnCount].isAvailable = true;
                    this.data.rows[rowCount].cols[columnCount].availableSlots = recds[element].length;
                    this.data.rows[rowCount].cols[columnCount].slotId = recds[element][0].Id;
                }
                rowCount++;
            });
            columnCount++;
        } 

    }

    bulkSlot(time, amPM){
        for( let i = 0 ; i< 6 ; i++){
            this.addSlots( time+':'+ (i*10)+ (i==0?'0':'') +' '+amPM);
        }
    }

    addSlots( timeStr ){
        let cols = [];
        cols.push({
            availableSlots : 0,
            availableSlots : 0,
            isAvailable : false,
            isSelected : false, 
            slotId : this.makeid(18)
        });
        cols.push({
            availableSlots : 0,
            isAvailable : false,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            availableSlots : 0,
            isAvailable : false,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            availableSlots : 0,
            isAvailable : false,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            availableSlots : 0,
            isAvailable : false,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            availableSlots : 0,
            isAvailable : false,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            availableSlots : 0,
            isAvailable : false,
            isSelected : false,
            slotId : this.makeid(18)
        });

        this.data.rows.push({
            timeSt : timeStr,
            cols : cols
        });
    }

    handleSelectedSlots(event){
        this.currentSelRecordId = event.target.dataset.recid;
        let tempSlotid = event.target.dataset.slotid;
        let slotTime = event.target.dataset.slottime;

        this.dispatchEvent(new CustomEvent('select', {
            detail: this.currentSelRecordId
        }));

        for( let i = 0 ; i < this.data.rows.length ; i++ ){

            for( let j = 0 ; j < this.data.rows[i].cols.length ; j++ ){
                if( this.data.rows[i].cols[j].slotId == tempSlotid ){
                    this.data.rows[i].cols[j].isSelected = true;
                }
                else{
                    if( this.data.rows[i].cols[j].isAvailable ){
                        this.data.rows[i].cols[j].isSelected = false;
                    }
                }
            }
        }
    }

    makeid(length) {
        var result = '';
        var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < length; i++ ) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
    }
}