({
    callApex: function(component, method, params, callback) {
        var action = component.get(method);
        if (params) action.setParams(params);
        action.setCallback(this, function(response) {
            callback.call(this, response);
        });
        $A.enqueueAction(action);
    }
});