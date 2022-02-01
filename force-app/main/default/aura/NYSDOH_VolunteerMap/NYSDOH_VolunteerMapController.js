/**
 * Created by arunm on 21-03-2020.
 */

({
    handleInit : function(component, event, helper) {
        var action = component.get("c.getVolunteers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mapMarkers = [];
                var countyOptions = [];
                let counties = new Set();
                response.getReturnValue().forEach(function(mapMarker){
                    if(mapMarker.location.Latitude && mapMarker.location.Longitude) {
                        mapMarker.location.Latitude = parseFloat(mapMarker.location.Latitude);
                        mapMarker.location.Longitude = parseFloat(mapMarker.location.Longitude);
                        mapMarkers.push(mapMarker);
                        counties.add(mapMarker.location.County);
                    }
                });
                component.set('v.center', {
                    location: {
                        State: 'NY'
                    }
                });

               counties.forEach(function(county){
                   countyOptions.push({
                        'label': county,
                        'value': county
                   });
               });

                component.set('v.mapMarkers',mapMarkers);
                component.set('v.filteredMapMarkers', mapMarkers);
                component.set('v.countyOptions',countyOptions);
                component.set('v.markersTitle', 'Volunteer locations.');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleCountyChange: function(component, event, helper) {
        var mapMarkers = component.get('v.mapMarkers');
        var selectedCounty = component.get('v.selectedCounty');
        var filteredMapMarkers = mapMarkers.filter(function(mapMarker){
            return mapMarker.location.County == selectedCounty;
        });
        component.set('v.filteredMapMarkers', filteredMapMarkers);
    }
});