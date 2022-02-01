({
    doInit: function(component, event, helper) {
        component.set("v.showUnderReviewMessage", false);
        helper.getApplicationDocs(component, event, helper);
    },
    handleSave: function(component, event, helper) {
        debugger;
        helper.saveDocsReview(component, event, helper);
    },
    handleEdit: function(component, event, helper) {
        component.set("v.editable", true);
    },
    handleCancel: function(component, event, helper) {
        component.set("v.showUnderReviewMessage", false);
        component.set("v.editable", false);
    },
    handleFileOpen: function(component, event, helper) {
        var selectedItem = event.currentTarget.getAttribute("data-record");
        $A.get("e.lightning:openFiles").fire({
            recordIds: [selectedItem]
        });
    }
});