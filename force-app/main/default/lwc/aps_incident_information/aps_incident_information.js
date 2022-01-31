import { LightningElement,track,api } from 'lwc';
import fetchPicklist from '@salesforce/apex/AdultProtectiveServiceController.fetchPicklist';

export default class Aps_incident_information extends LightningElement {
    @track dataObj = {};
    @track abuseResultedInOptions = [];
    @track abuseResultedInSelected = [];
    @track abusePerpetratedOthersOptions = [];
    @track abusePerpetratedOthersOptionsSelected = [];
    @track physicalAbuseOptions = [];
    @track physicalAbuseOptionsSelected = [];
    @track countyOptions = [];
    @track incidentOccurredAtOptions = [];
    @track institutionReportingFacilityOptions = [];
    @track incidentTypeOptions = [];

    connectedCallback(){
        fetchPicklist( {objectName : 'Case', fieldName : 'Incident_Type__c' } )
        .then(result => {
            this.incidentTypeOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Case', fieldName : 'Abuse_Resulted_In__c' } )
        .then(result => {
            this.abuseResultedInOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Case', fieldName : 'Abuse_Perpetrated_by_Others__c' } )
        .then(result => {
            this.abusePerpetratedOthersOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Case', fieldName : 'Physical_Abuse__c' } )
        .then(result => {
            this.physicalAbuseOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Case', fieldName : 'County__c' } )
        .then(result => {
            this.countyOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Case', fieldName : 'Incident_Occurred_At__c' } )
        .then(result => {
            this.incidentOccurredAtOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });

        fetchPicklist( {objectName : 'Case', fieldName : 'Institution_Reporting_Facility__c' } )
        .then(result => {
            this.institutionReportingFacilityOptions = result;
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log(message);
        });
    }

    handleInput(event){        
        if( event.target.name === 'DateTimeIncident' ){
            this.dataObj.Date_and_Time_of_Incident = event.target.value;
        }
        else if( event.target.name === 'Street' ){
            this.dataObj.Street = event.target.value;
        }
        else if( event.target.name === 'City' ){
            this.dataObj.City = event.target.value;
        }
        else if( event.target.name === 'County' ){
            this.dataObj.County = event.target.value;
        }
        else if( event.target.name === 'ZipCode' ){
            this.dataObj.Zip_Code = event.target.value;
        }
        else if( event.target.name === 'IncidentOccurredAt' ){
            this.dataObj.Incident_Occurred_At = event.target.value;
        }
        else if( event.target.name === 'IncidentOther' ){
            this.dataObj.Incident_Other = event.target.value;
        }
        else if( event.target.name === 'Facility' ){
            this.dataObj.Institution_Reporting_Facility = event.target.value;
        }
        else if( event.target.name === 'AbuseResultedIn' ){
            this.dataObj.Abuse_Resulted_In = event.target.value.join(';');
        }
        else if( event.target.name === 'AbusePerpetratedOthers' ){
            this.dataObj.Abuse_Perpetrated_by_Others = event.target.value.join(';');
        }
        else if( event.target.name === 'PhysicalAbuse' ){
            this.dataObj.Physical_Abuse = event.target.value.join(';');
        }
    }

    @api
    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        //Temp using true: Use valid variable
        return true;
    }

    @api
    getData(){
        return this.dataObj;
    }
}