({
    loadData: function(component, event, helper) {
        helper.loadData(component, event, helper);
        
        
    },
    addNewDate : function(component, event, helper) {
        var view = component.get("v.view");
        var newRecord = {
            "scheduleDate" : "",
            "lane" : "0",
            "duration" : "",
            "startTime" : "",
            "endTime" : "",
        };
        view.timeSlots.push(newRecord);
        component.set("v.view",view);
        
    },
    saveData : function(component, event, helper) {
        helper.saveData(component, event, helper);
        
    }
})