({
	doInit: function(component, event, helper) {
        // Create the action
        console.log('In the JS');
        var action = component.get("c.updateStatus");
        action.setParams({ appointmentId : component.get("v.recordId") });
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire();
    }
})