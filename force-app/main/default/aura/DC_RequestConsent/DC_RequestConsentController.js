({
    doInit : function(component, event, helper) {
        var action = component.get('c.requestConsent');
        
        action.setParams({
            'subjectId' : component.get('v.recordId')
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();

            if(state == 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "Message sent successfully."
                });
                toastEvent.fire();
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                let erMsg = '';
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        erMsg += errors[0].message + ' ';
                    }
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error!",
                    "message": erMsg
                });
                toastEvent.fire();
            }
            else if (status === "INCOMPLETE") {                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error!",
                    "message": 'No response from server or client is offline.'
                });
                toastEvent.fire();
            }
            
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    }
})