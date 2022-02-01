({
    initialize: function(component, event, helper) {
        component.set("v.showErrorMessage", false);
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
        component.set('v.extraFields', helper.getExtraFields(component, event, helper));
    },
    
    handleSelfRegister: function (component, event, helper) {
        component.set("v.showErrorMessage",false);       
        helper.handleSelfRegister(component, event, helper);
    },

    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    }, // I-16166 by hari
    redirectToSupportPage : function(cmp, event, helper) {
        window.open('/psr/s/permitting-support', '_self');
    }, // I-16166 by hari
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helper){
        component.set("v.showErrorMessage",false);
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleSelfRegister(component, event, helper);
        }
    },
    
    handleLogin : function(component, event, helper) {
        helper.redirectToLogin(component, event, helper);
    }
})