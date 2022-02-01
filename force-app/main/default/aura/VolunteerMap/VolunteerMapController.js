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
                response.getReturnValue().forEach(function(mapMarker){
                    if(mapMarker.location.Latitude && mapMarker.location.Longitude) {
                        mapMarker.location.Latitude = parseFloat(mapMarker.location.Latitude);
                        mapMarker.location.Longitude = parseFloat(mapMarker.location.Longitude);
                        mapMarkers.push(mapMarker);
                    }
                });
                component.set('v.center', {
                    location: {
                        State: 'NY'
                    }
                });
                component.set('v.mapMarkers',mapMarkers);
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
    }
});