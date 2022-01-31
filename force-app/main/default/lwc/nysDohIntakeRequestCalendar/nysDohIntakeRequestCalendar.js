import { LightningElement, track, api } from 'lwc';
import getAppointmentsCal from '@salesforce/apex/NYCDOH_IntakeRequestTestCenter.getAppointmentSlots';
export default class NysDohIntakeRequestCalendar extends LightningElement {

    @track slotWrappers;

    connectedCallback(){
        this.fetchAppointmentSlots();
    }

    fetchAppointmentSlots() {

        let configAttr = {
            contactId: null,
            accountId: '0013F00000WrFAcQAN',
            isPriority: false
        }

        getAppointmentsCal(configAttr)
            .then(result => {
                this.slotWrappers = []
                let count = 0;
                let _this = this;
                console.log('--res--- ' + JSON.stringify(result));
                
                result.slotWrappers.forEach(function(eachSlot, index){
                    _this.slotWrappers.push({
                        "uId": count,
                        "slotData": eachSlot
                    });
                    ++count;
                });
                console.log(JSON.parse(JSON.stringify(this.slotWrappers)));
            })
            .catch(error => {
                console.error('HG: ', JSON.stringify(error));
            });


    }
}