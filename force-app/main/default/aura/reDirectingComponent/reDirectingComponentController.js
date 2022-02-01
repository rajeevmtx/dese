({
    navigateToAppointmentCmp : function(component, event, helper) {
      
        var evt = $A.get("e.force:navigateToURL");
         var name = helper.getBaseURL(component,helper);
        var address = "n/Schedule_Appointment";
       console.log('test---'+component.get("v.pageReference"));
            console.log('Base URL = ',name + address);
        evt.setParams({
           // componentDef : "c:NYSDOH_Schedular_Component",
           "url":  name + address
         /*   componentAttributes: {
               // recordId : component.get("v.recordId"),
               // sObjectName : component.get('v.sObjectName')
            } */
           
        });
        evt.fire();
    
  
},
    //Call by aura:waiting event  
    handleShowSpinner: function(component, event, helper) {
        component.set("v.showSpinner", true); 
    },
     
    //Call by aura:doneWaiting event 
    handleHideSpinner : function(component,event,helper){
        component.set("v.showSpinner", false);
    }
       
})