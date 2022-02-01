({
    loadData : function(component, event, helper) {
        //call apex class method
        var action = component.get('c.initMethod');
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                component.set('v.view', response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
    },
    
    saveData : function(component, event, helper) {
        var action = component.get('c.generateRecords');
        var view = component.get("v.view");
        console.log('view'+JSON.stringify(view));
        action.setParams({ slotRecords : JSON.stringify(view) });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                helper.showSuccessToast(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Your Appointment slots are successfully created',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    }
})