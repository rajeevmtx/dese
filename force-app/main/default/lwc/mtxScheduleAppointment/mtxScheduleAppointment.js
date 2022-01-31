import { LightningElement, api, track } from 'lwc';
import getSiteAccounts from '@salesforce/apex/DC_ScheduleAppointment.getSiteAccounts';
import getAccountSlots from '@salesforce/apex/DC_ScheduleAppointment.getAccountSlots';
import updateAppointmentrec from '@salesforce/apex/DC_ScheduleAppointment.updateAppointment';
import createAppointmentrec from '@salesforce/apex/DC_ScheduleAppointment.createAppointment';
import getAppointmentDetailrec from '@salesforce/apex/DC_ScheduleAppointment.getAppointmentDetail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class MtxScheduleAppointment extends LightningElement {
    @api recordid;
	@track options = [];
	@track selectedOption;
	@track isAttributeRequired = false;
	@api fieldName;
	@track contactid;
	@api objectName;
    @track fieldLabelName;
    @track accountList = [];
    @track isSiteSelected = false;
    @track selectValue;
    @track slotId;
    @track showSchedule = false;

	connectedCallback() {
        if(this.recordid.substring(0, 3) == '003') {
            this.contactid = this.recordid;
            this.retrieveTestingSites();
        } else {
            getAppointmentDetailrec({appointmentId: this.recordid})
            .then(data => {
                let appointment = data.appointment;
                this.contactid = appointment.Patient__c;
                this.selectValue = appointment.Testing_Site__c;
                if(appointment.Status__c == 'Scheduled' || appointment.Status__c == 'To Be Scheduled' || appointment.Status__c == null || typeof appointment.Status__c == 'undefined') {
                    this.retrieveTestingSites();
                    this.isSiteSelected = true;
                } else {
                    this.dispatchEvent(new CustomEvent('close', {}));
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        variant: 'error',
                        message: 'You are not allowed to update this appointment.',
                    });
                    this.dispatchEvent(event);
                }
			})
			.catch(error => {
                console.log('Error-->' + error);
			});
        }
		
    }
    
    retrieveTestingSites() {
        getSiteAccounts({})
        .then(data => {
            data.forEach((account) => {
                var optionValue = new Object();
                optionValue.label = account.Name;
                optionValue.value = account.Id;
                this.accountList.push(optionValue);
            });
            this.options = this.accountList;
        })
        .catch(error => {
            console.log('Error-->', error);
        });
    }

    selectionChangeHandler(event) {
        this.isSiteSelected = true;
        this.selectValue = event.target.value;
    }
    setId(event) {
        this.showSchedule = true;
        this.slotId = event.detail;
    }
    createAppointmentRecord() {
        
        if(this.recordid.substring(0, 3) == '003') {
            createAppointmentrec({ accountId : this.selectValue, contactId : this.contactid, slotId : this.slotId}).then(result => {
            // this.createCalendar(result);
                this.dispatchEvent(new CustomEvent('close', {}));
            })
            .catch(error => {
                console.log('Error-->' + JSON.stringify(error));
            });
            const event = new ShowToastEvent({
                title: 'Success!',
                variant: 'success',
                message: 'Your appointment has been scheduled.',
            });
            this.dispatchEvent(event);
    
        } else {
            updateAppointmentrec({ accountId : this.selectValue, appointmentId : this.recordid, slotId : this.slotId}).then(result => {
            // this.createCalendar(result);
                this.dispatchEvent(new CustomEvent('close', {}));
            })
            .catch(error => {
                console.log('Error-->' + JSON.stringify(error));
            });
            const event = new ShowToastEvent({
                title: 'Success!',
                variant: 'success',
                message: 'Your appointment has been scheduled.',
            });
            this.dispatchEvent(event);
            
        }
    }
    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('close', {
        }));
    }
    justCloseModal(){
        this.dispatchEvent(new CustomEvent('close', {
        }));
    }
}