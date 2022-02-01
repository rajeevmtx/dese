({
	doInit : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var nameSpace = (url.searchParams.get("ns")) ? url.searchParams.get("ns") : "c";
        var cName = url.searchParams.get("source");        
        $A.createComponent(
            nameSpace+":"+cName,{},
            function(newcomponent){
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);             
                }
            }            
        );
    }
})