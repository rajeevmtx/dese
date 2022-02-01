({
    callApex: function(component, method, params, callback) {
        var action = component.get(method);
        if (params) action.setParams(params);
        action.setCallback(this, function(response) {
            callback.call(this, response);
        });
        $A.enqueueAction(action);
    },

    validateFormFields: function(component, fieldAuraIds) {
        console.log("validateFormFields");
        var _findIn = component;
        var _errorAuraId;
        var _errList = [];
        for (var x = 0; x < fieldAuraIds.length; x++) {
            if (this.validateEmptyField(component, fieldAuraIds[x])) {
                console.log("In Error");
                _errorAuraId = fieldAuraIds[x] + "Error";
                console.log("_errorAuraId", _errorAuraId);
                _errList.push(_errorAuraId);
            }
        }
        return _errList;
    },

    validateEmptyField: function(component, auraId) {
        console.log("validateEmptyField", auraId);
        var findIn = component;
        // Get the field itself
        var inputField = findIn.find(auraId);
        // Get aura validity
        var fieldValue = inputField.get("v.value");
        if (fieldValue == "" || fieldValue == null) {
            return true;
        } else {
            return false;
        }
    },

    hideAllErrorMessages: function(component, auraIds) {
        console.log("hideAllErrorMessages");
        var findIn = component;
        for (var x = 0; x < auraIds.length; x++) {
            var _element = findIn.find(auraIds[x]);
            var _elementParent = findIn.find(auraIds[x].split("Error")[0]);

            $A.util.removeClass(_elementParent, " slds-has-error");
            $A.util.removeClass(_element, "slds-show");
            $A.util.addClass(_element, "slds-hide");
        }
    },

    handleErrorClassToggles: function(component, event, helper, _errorAuraId) {
        console.log("In handleErrorClassToggles");
        var _findIn = component;
        for (var x = 0; x < _errorAuraId.length; x++) {
            console.log("_errorAuraId+++++", _errorAuraId);
            var _errorElement = _findIn.find(_errorAuraId[x]);
            var _errorFieldAuraId = _errorAuraId[x].split("Error")[0];
            var _errorFieldElement = _findIn.find(_errorFieldAuraId);

            $A.util.addClass(_errorFieldElement, " slds-has-error");
            $A.util.addClass(_errorElement, "slds-show");
            $A.util.removeClass(_errorElement, "slds-hide");
        }
    },

    showToast: function(message) {
        console.log("In Toast");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: "error",
            message: message
        });
        toastEvent.fire();
    },

    navigateToPage: function(component, event, urlToNavigate) {
        console.log("In navigateToPage");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: urlToNavigate
        });
        urlEvent.fire();
    },

    formatPhoneNumber: function(input) {
        console.log("In Base formatPhoneNumber");
        var number = input.replace(/[^\d]/g, "");
        if (number.length == 7) {
            number = number.replace(/(\d{3})(\d{4})/, "$1-$2");
        } else if (number.length >= 10) {
            number = number.replace(/(\d{3})(\d{3})(\d{4})/, "($1)-$2-$3");
        }
        console.log("number", number);
        input = number;
        return input;
    },

    validatePhoneNumber: function(phoneNumber) {
        var regExpPhone = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
        var isValid = phoneNumber.match(regExpPhone);
        console.log("isValid", isValid);
        return isValid;
    },

    validateZipCode: function(zipCode) {
        console.log("zipCode", zipCode);
        var regexZip = /^\d{5}(-\d{4})?$/;
        var valid = zipCode.match(regexZip);
        return valid;
    },

    validateSSN: function(ssn) {
        console.log("ssn", ssn);
        var regexSSN = /^\d{4}(-\d{4})?$/;
        var valid = ssn.match(regexSSN);
        return valid;
    },

    validateDateRangeValid: function(
        component,
        startMonthAuraId,
        startYearAuraId,
        endMonthAuraId,
        endYearAuraId
    ) {
        var returnValue = false;
        var startMonth = component.find(startMonthAuraId).get("v.value");
        var startYear = component.find(startYearAuraId).get("v.value");
        var endMonth = component.find(endMonthAuraId).get("v.value");
        var endYear = component.find(endYearAuraId).get("v.value");
        if (
            "" == startMonth ||
            "" == startYear ||
            "" == endMonth ||
            "" == endYear
        ) {
            return false;
        }
        var startDate = new Date(Date.parse(startMonth + " 1, " + startYear));
        var endDate = new Date(Date.parse(endMonth + " 1, " + endYear));
        returnValue = startDate < endDate;
        return returnValue;
    },

    validateMonthYear: function(component, monthAuraId, yearAuraId) {
        var returnValue = false;
        var month = component.find(monthAuraId).get("v.value");
        var year = component.find(yearAuraId).get("v.value");
        if ("" == month && "" == year) {
            returnValue = true;
        } else if ("" != month && "" != year) {
            returnValue = true;
        }
        return returnValue;
    },

    getUrlParam: function(component, helper, name) {
        debugger;
        name = name.replace(/([\[\]])/g, "\\$1");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.href);
        //var results = regex.exec(url);
        if (results == null) return "";
        else return results[1];
    }
});