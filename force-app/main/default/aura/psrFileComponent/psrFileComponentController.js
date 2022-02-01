({
    doInit : function(component, event, helper) {
        var url = window.location.href;
        var idData = url.split('=');
        //set the src param value to my src attribute
        component.set("v.docId", idData[1]);
        $A.get('e.lightning:openFiles').fire({
            recordIds: [idData[1]]
        });
    },
    
})