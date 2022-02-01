({
    doInit : function(component, event, helper) {
       
    },
    onPageReferenceChanged: function(cmp, event, helper) {
        var myPageRef = cmp.get("v.pageReference");
        $A.get('e.force:refreshView').fire();
    }
})