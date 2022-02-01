({
    doInit : function(component, event, helper) {
        var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.userName", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    openHome : function(component,event, helper){
        location.href = 'https://dev-demo-lp.cs92.force.com/NYSDOH/s/';
    },

    myprofile : function(component, event, helper){
        var loggedInUser;
        var state;
        var navEvt;
        
        var action = component.get("c.fetchUserId");
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") {
                console.log('SUCEESS ' , response.getReturnValue());
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/profile/'+response.getReturnValue(),
                    "isredirect" :false
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    logout : function(component, event, helper){
        //window.location.replace("/secur/logout.jsp?retUrl=https://mtxlicensingpermit--dev.preview.salesforce-communities.com/NYSDOH/s/");
    }

    
})