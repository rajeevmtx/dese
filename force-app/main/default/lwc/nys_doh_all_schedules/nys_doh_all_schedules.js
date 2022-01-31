import { LightningElement, track ,api} from 'lwc';

export default class Nys_doh_all_schedules extends LightningElement {
    @api accountid;
    @track data = {};
    currentSelRecordId = '';

    connectedCallback(){
        

        this.data = {};

        let dates = [];
        dates.push('3/24');
        dates.push('3/25');
        dates.push('3/26');
        dates.push('3/27');
        dates.push('3/28');
        dates.push('3/29');
        dates.push('3/30');

        let weeks = [];
        weeks.push('Mon');
        weeks.push('Tue');
        weeks.push('Wed');
        weeks.push('Thu');
        weeks.push('Fri');
        weeks.push('Sat');
        weeks.push('Sun');

        // let rows = [];

        // let cols = [];
        // cols.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols.push({
        //     isAvailable : false,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        

        // let cols1 = [];
        // cols1.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols1.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols1.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols1.push({
        //     isAvailable : false,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols1.push({
        //     isAvailable : true,
        //     isSelected : true,
        //     slotId : this.makeid(18)
        // });
        // cols1.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols1.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols2 = [];
        // cols2.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols2.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols2.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols2.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols2.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols2.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols2.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols3 = [];
        // cols3.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols3.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols3.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols3.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols3.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols3.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols3.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols4 = [];
        // cols4.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols4.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols4.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols4.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols4.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols4.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols4.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols5 = [];
        // cols5.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols5.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols5.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols5.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols5.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols5.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols5.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols6 = [];
        // cols6.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols6.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols6.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols6.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols6.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols6.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols6.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols7 = [];
        // cols7.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols7.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols7.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols7.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols7.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols7.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols7.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols8 = [];
        // cols8.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols8.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols8.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols8.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols8.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols8.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols8.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols9 = [];
        // cols9.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols9.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols9.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols9.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols9.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols9.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols9.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // let cols10 = [];
        // cols10.push({
        //     isAvailable : true,
        //     isSelected : false, 
        //     slotId : this.makeid(18)
        // });
        // cols10.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols10.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols10.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols10.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols10.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });
        // cols10.push({
        //     isAvailable : true,
        //     isSelected : false,
        //     slotId : this.makeid(18)
        // });

        // rows.push({
        //     timeSt : '7:00 AM',
        //     cols : cols
        // });
        
        // rows.push({
        //     timeSt : '7:10 AM',
        //     cols : cols1
        // });

        // rows.push({
        //     timeSt : '7:20 AM',
        //     cols : cols2
        // });

        // rows.push({
        //     timeSt : '7:30 AM',
        //     cols : cols3
        // });

        // rows.push({
        //     timeSt : '7:40 AM',
        //     cols : cols4
        // });

        // rows.push({
        //     timeSt : '7:50 AM',
        //     cols : cols5
        // });

        // rows.push({
        //     timeSt : '8:00 AM',
        //     cols : cols6
        // });

        // rows.push({
        //     timeSt : '8:10 AM',
        //     cols : cols7
        // });

        // rows.push({
        //     timeSt : '8:20 AM',
        //     cols : cols8
        // });

        // rows.push({
        //     timeSt : '8:30 AM',
        //     cols : cols9
        // });

        // rows.push({
        //     timeSt : '8:40 AM',
        //     cols : cols10
        // });

        this.data.rows = [];
        
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
        
        
        this.data.rows[2].cols[4].isAvailable = false;
        this.data.rows[6].cols[3].isAvailable = false;
        this.data.rows[10].cols[4].isAvailable = false;
        this.data.rows[2].cols[1].isAvailable = false;
        this.data.rows[1].cols[2].isAvailable = false;
        this.data.rows[4].cols[5].isAvailable = false;
        this.data.rows[12].cols[3].isAvailable = false;
        this.data.rows[7].cols[5].isAvailable = false;
        this.data.rows[20].cols[2].isAvailable = false;
        this.data.rows[25].cols[3].isAvailable = false;
        this.data.rows[30].cols[4].isAvailable = false;
        this.data.rows[28].cols[1].isAvailable = false;

        this.data.dates = dates;
        this.data.weeks = weeks;
       // this.data.rows = rows;
        


    }

    bulkSlot(time, amPM){
        for( let i = 0 ; i< 6 ; i++){
            this.addSlots( time+':'+ (i*10)+ (i==0?'0':'') +' '+amPM);
        }
    }

    addSlots( timeStr ){
        let cols = [];
        cols.push({
            isAvailable : true,
            isSelected : false, 
            slotId : this.makeid(18)
        });
        cols.push({
            isAvailable : true,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            isAvailable : true,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            isAvailable : true,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            isAvailable : true,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            isAvailable : true,
            isSelected : false,
            slotId : this.makeid(18)
        });
        cols.push({
            isAvailable : true,
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

        console.log('--recordId-'+this.currentSelRecordId);

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

        //temp
        this.currentSelRecordId = 'a2Z3F000000XPfJUAW';

        const dateRangeChangeEvent = new CustomEvent('slotselect', {
            detail: {
                slotId: this.currentSelRecordId,
                slotTime: '3/22/2020 '+ slotTime
            }
        });
        this.dispatchEvent(dateRangeChangeEvent);
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