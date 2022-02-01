({
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    handleFileOpen : function(component, event){
        console.log('---handleFileOpen helper---');
        var docId = component.get('v.docId');
        var fireEvt = $A.get('e.lightning:openFiles');
        alert('Event About to fire');
        fireEvt.fire({
            recordIds: [docId],
            selectedRecordId : docId
        });
    }
    
})