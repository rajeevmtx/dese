({
    doInit: function(component, event, helper) {
        // component.set("v.showUnderReviewMessage", false);
        helper.getData(component, event, helper);       
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        helper.getData(component, event, helper); 
    },

    editModal: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.editrecordId", event.target.id);
        //alert( event.target.id);
        component.set("v.isNewButton", false);
        component.set("v.isModalOpen", true);
    },
    newButton :function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        
        //alert( event.target.id);
        
        component.set("v.isNewButton", true);
        component.set("v.isModalOpen", true);
    },


})