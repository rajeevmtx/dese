({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    verifyForm: function(component){
        let error = false;
        let userName = component.find("username").get("v.value");
        let password = component.find("passwordInput").get("v.value");
        
        if(!userName || userName.trim().length == 0){
            component.find("username").setCustomValidity('Complete this field');
            this.error = true;
        }else{
            component.find("username").setCustomValidity('');
        }
        component.find("username").reportValidity();
        
        if(!password || password.trim().length == 0){
            component.find("passwordInput").setCustomValidity('Complete this field');
            this.error = true;
        }else{
            component.find("passwordInput").setCustomValidity('');
        }
        component.find("passwordInput").reportValidity();
        
        return this.error;
    },
    
    handleLogin: function (component, event, helper) {
        var username = component.find("username").get("v.value");
        var password = component.find("passwordInput").get("v.value");
        if(component.find("remember").get("v.checked")){
            window.localStorage.setItem('uname', username);
            window.localStorage.setItem('pass', password);
        }
        let error = this.verifyForm(component);
        if(!error){
            var action = component.get("c.login");
            var startUrl = component.get("v.startUrl");
            
            startUrl = decodeURIComponent(startUrl);
            
            action.setParams({username:username, password:password, startUrl:startUrl});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    redirectToBusinessManagement();
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.errorMessage",errors[0].message);
                            component.set("v.showError",true);
                            
                        }
                    }
                    
                }
                
            });
            $A.enqueueAction(action);
        } 
        
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helper) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helper) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helper) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helper) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    setBrandingCookie: function (component, event, helper) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },
    
    redirectToSelfRegister : function(component, event, helper) {
        window.open(component.get("v.communitySelfRegisterUrl"), '_self');
    }
})