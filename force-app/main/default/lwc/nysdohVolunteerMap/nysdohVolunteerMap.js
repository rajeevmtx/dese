/**
 * Created by arunm on 22-03-2020.
 */

import { LightningElement, track } from 'lwc';
import getVolunteers from '@salesforce/apex/NYSDOH_VolunteerController.getVolunteers';

export default class NysdohVolunteerMap extends LightningElement {

    @track selectedCounty = '';
    @track selectedFieldService = '';
    @track selectedStatus = '';
    @track selectedSpeciality = '';
    @track countyOptions = [];
    @track fieldServiceOptions = [];
    @track statusOptions = [ {'label': 'Retired', value:'Retired'}, {'label': 'Active', value:'Active'}, {'label':'N/A', 'value':'N/A'}];
    @track specialityOptions = [ {'label': 'Speciality 1', value:'Speciality 1'}, {'label': 'Speciality 2', value:'Speciality 2'}, {'label':'Speciality 3', 'value':'Speciality 3'}];
    @track mapMarkers = [];
    @track filteredMarkers = [];
    @track isLoaded = false;
    @track center = {
        location: {
            State: 'NY',
        },
    };
    @track zoomLevel = 10;
    @track markersTitle = 'Volunteer Locations';
    @track showFooter = true;
    @track listView = 'hidden';
    @track error;

    connectedCallback() {
        this.handleLoad();
    }

    handleLoad() {
        getVolunteers()
            .then(result => {
                let counties = new Set();
                let fieldServices = new Set();
                let _mapMarkers = [];
                let _countyOptions = [];
                let _fieldServiceOptions = [];

                result.forEach((mapMarker) => {
                    if(mapMarker.location.Latitude && mapMarker.location.Longitude) {
                        mapMarker.location.Latitude = parseFloat(mapMarker.location.Latitude);
                        mapMarker.location.Longitude = parseFloat(mapMarker.location.Longitude);
                        _mapMarkers.push(mapMarker);
                        counties.add(mapMarker.location.County);
                        fieldServices.add(mapMarker.fieldService);
                    }
                });

                counties.forEach((county) => {
                   _countyOptions.push({
                        'label': county,
                        'value': county
                   });
                });
                fieldServices.forEach((fieldService) => {
                   _fieldServiceOptions.push({
                        'label': fieldService,
                        'value': fieldService
                   });
                });

                if(_mapMarkers) {
                    this.mapMarkers = JSON.parse(JSON.stringify(_mapMarkers));
                    this.filteredMarkers = JSON.parse(JSON.stringify(_mapMarkers));
                }

                this.countyOptions = _countyOptions;
                this.fieldServiceOptions = _fieldServiceOptions;
                this.isLoaded = true;
            })
            .catch(error => {
                this.error = error;
                this.isLoaded = false;
            });
    }

    handleCountyChange(event) {
        this.isLoaded = false;
        this.selectedCounty = event.detail.value;
        let markers = this.mapMarkers.filter(function(mapMarker){
            return mapMarker.location.County.localeCompare(event.detail.value) == 0;
        });
        this.filteredMarkers = markers;
        this.isLoaded = true;
    }

    handleFieldServiceChange(event) {
        this.isLoaded = false;
        this.selectedFieldService = event.detail.value;
        let markers = this.mapMarkers.filter(function(mapMarker){
            return mapMarker.fieldService.localeCompare(event.detail.value) == 0;
        });
        this.filteredMarkers = markers;
        this.isLoaded = true;
    }

    handleStatusChange(event) {

    }

    handleSpecialityChange(event) {

    }
}