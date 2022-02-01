({
    getData : function(component, event, helper) {
        var action = component.get("c.getProgramContent");
        action.setParams({ pcRecordID :  component.get('v.recordId')});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()>',JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                var list1=[];
                var list2=[];
                result.forEach(row=>{
                    if(row.RecordType.Name =='Project Milestones'){
                        list1.push(row);
                    } else{
                        list2.push(row);
                    }
                });
                component.set('v.contenList',list1);
                component.set('v.contenList1',list2);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})