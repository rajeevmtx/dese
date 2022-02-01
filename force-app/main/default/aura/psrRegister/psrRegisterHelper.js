({
    qsToEventMap: {
        startURL: "e.c:setStartUrl"
    },
    
    qsToEventMap2: {
        expid: "e.c:setExpId"
    },
    
    getCommunityLoginUrl : function (component, event, helper) {
        var action = component.get("c.getLoginUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.loginUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    validateEmail : function(email) {
        var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(email).toLowerCase());
    },
    
    handleRequiredEntities: function (component, event, helper) {
        let error = false;
        
        var checkBox = component.find("acceptTerms").get("v.value");
        if (checkBox === false) {
            error = true;
        } else {
            error = false;
        }
        
        component.find('inputField').forEach(function(field){
            let value = field.get("v.value");
            if(typeof value === "undefined" || value.trim().length==0){
                field.setCustomValidity('Complete this field');
                
                error = true; 
            }else{
                field.setCustomValidity('');
            }
            field.reportValidity();
        });
        
        let emailField = component.find('inputField')[2];
        if(!this.validateEmail(component.get("v.email"))){
            error = true; 
            emailField.setCustomValidity('Invalid Email Address');
        }else{
            emailField.setCustomValidity('');
        }
        emailField.reportValidity();
        
        if(error){
            // I-16166 by hari
            if (checkBox === false)
            component.set("v.showErrorMessage", true);
        }else{
            component.set("v.showErrorMessage", false);
        }
    },
    
    handleSelfRegister: function (component, event, helper) {
        this.handleRequiredEntities(component, event, helper);
        var showError = component.get("v.showErrorMessage");
        if (showError === false) {
            var regConfirmUrl = component.get("v.regConfirmUrl");
            var firstname = component.get("v.firstName");
            var lastname = component.get("v.lastName");
            var email = component.get("v.email");
            var includePassword = component.get("v.includePasswordField");
            var password = component.get("v.password");
            var confirmPassword = component.get("v.confirmPassword");
            var action = component.get("c.selfRegister");
            var extraFields = JSON.stringify(component.get("v.extraFields")); // somehow apex controllers refuse to deal with list of maps
            var startUrl = component.get("v.startUrl");
            
            startUrl = decodeURIComponent(startUrl);
            //var accountId = component.get("v.accountRecordId");
            //console.log("Check:AccountId::" + accountId);
            
            action.setParams({
                firstname: firstname,
                lastname: lastname,
                email: email,
                password: password,
                confirmPassword: confirmPassword,
                //accountId: accountId,
                regConfirmUrl: regConfirmUrl,
                extraFields: extraFields,
                startUrl: '/s/settings?signup=true', 
                includePassword: includePassword
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    redirectToBusinessManagement();
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("---------------My Error:: "+errors[0].message);
                            component.set("v.errorMessage",errors[0].message);
                            component.set("v.showError",true);
                            
                        }
                    }
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getExtraFields: function (component, event, helper) {
        var action = component.get("c.getExtraFields");
        action.setParam(
            "extraFieldsFieldSet",
            component.get("v.extraFieldsFieldSet")
        );
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.extraFields", rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    setBrandingCookie: function (component, event, helper) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({
                expId: expId
            });
            action.setCallback(this, function (a) {});
            $A.enqueueAction(action);
        }
    },
    redirectToLogin : function(component, event, helper) {
        window.open(component.get('v.loginUrl'), '_self');
    },
    redirectToBusinessManagement: function (component, event, helper) {
        window.open('/s/settings?signup=true', '_self');
        $A.enqueueAction(action);
    }
});