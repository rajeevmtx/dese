({
    doInit : function(cmp) {
        
    },

    handleClick : function (cmp, event, helper) {
        var action = cmp.get("c.changeStatus");
        action.setParams({ appId : cmp.get("v.recordId") });
 
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire(); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "variant": "success"
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                $A.get("e.force:closeQuickAction").fire(); 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})