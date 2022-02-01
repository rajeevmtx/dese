({
	fetchProgramsUnderTheUmbrella : function(component, event, helper) {
        component.set("v.loaded",false);
		var action = component.get("c.getProgramsUnderTheUmbrella");
        var recId= component.get("v.recordId");
        action.setParams({recordId:recId});
        action.setCallback(this, function (response) {
            var Data = response.getReturnValue();
            var arr=[];
            Data.forEach(element=>{
                element.isSelected=false;
                if(element.Id==recId){
                	component.set("v.CurrentAccount",element);
                } else {
                    arr.push(element);
                }
            });
            component.set("v.AccountsList",arr);
            component.set("v.loaded",true);
        });
        $A.enqueueAction(action);
	},
    cancelTheRequest : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onSelectedHandler: function(component, event, helper) {
        var accList = component.get("v.AccountsList");
        var itemId = event.getSource().get("v.name");
        accList.forEach(element=>{if(element.Id!=itemId){element.isSelected=false;}});
        component.set("v.AccountsList",accList);
    },
    saveData : function(component, event, helper) {
        component.set("v.loaded",false);
        var accList = component.get("v.AccountsList");
        var isAccSelected = false;
        var child;
        accList.forEach(element=>{
            if(element.isSelected){
            	isAccSelected = true;
            	child = element;
        	}
        });
        if(!isAccSelected) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please select a Program to merge.",
                "type":"error"
            });
            toastEvent.fire();
            component.set("v.loaded",true);
            return;
        }
        var currentRec = component.get("v.CurrentAccount");
        var lst=[];
        lst.push({Id:'1',FieldLabel:'Name',Current:true,CurrentValue:currentRec.Name,Child:false,ChildValue:child.Name});
        lst.push({Id:'2',FieldLabel:'Website',Current:true,CurrentValue:currentRec.Website?currentRec.Website:'[empty]',Child:false,ChildValue:child.Website?child.Website:'[empty]'});
        lst.push({Id:'3',FieldLabel:'Account Type',Current:true,CurrentValue:currentRec.Account_Type__c?currentRec.Account_Type__c:'[empty]',Child:false,ChildValue:child.Account_Type__c?child.Account_Type__c:'[empty]'});
        lst.push({Id:'4',FieldLabel:'Enrollment',Current:true,CurrentValue:currentRec.Enrollment__c?currentRec.Enrollment__c:'[empty]',Child:false,ChildValue:child.Enrollment__c?child.Enrollment__c:'[empty]'});
        lst.push({Id:'5',FieldLabel:'Grade Served',Current:true,CurrentValue:currentRec.Grade_Served__c?currentRec.Grade_Served__c:'[empty]',Child:false,ChildValue:child.Grade_Served__c?child.Grade_Served__c:'[empty]'});
        lst.push({Id:'6',FieldLabel:'School Code',Current:true,CurrentValue:currentRec.School_Code__c?currentRec.School_Code__c:'[empty]',Child:false,ChildValue:child.School_Code__c?child.School_Code__c:'[empty]'});
        component.set("v.FieldsList",lst);
        component.set("v.showSecondStep",true);
        component.set("v.SelectedChild",child);
        component.set("v.loaded",true);
        /*var action = component.get("c.sendDataToServer");
        action.setParams({recordId:component.get("v.recordId"),childId:childId});
        action.setCallback(this, function (response) {
            component.set("v.loaded",true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Successfully Merged both programs.",
                "type":"success"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);*/
    },
    onSelectedHandler2: function(component, event, helper) {
    	var accList = component.get("v.FieldsList");
        var item = event.getSource().get("v.name");
        var itemname = item.split(';')[0];
        var itemlabel = item.split(';')[1];
        var isChecked = event.getSource().get("v.checked");
        accList.forEach(element=>{
            if(element.FieldLabel==itemname){
                if(itemlabel=='current'){
                	element.Child = !isChecked;
        		} else {
                    element.Current = !isChecked;    
                }
        	}
        });
        component.set("v.FieldsList",accList);                
    },
    backToStepOne: function(component, event, helper) {
        component.set("v.showSecondStep",false);
    },
    saveDataFinal : function(component, event, helper) {
        var fieldsList = component.get("v.FieldsList");
        var updateCurrentRec={};
        updateCurrentRec.Id=component.get("v.recordId");
        updateCurrentRec.Name=fieldsList[0].Current?fieldsList[0].CurrentValue:fieldsList[0].ChildValue;
        updateCurrentRec.Website=fieldsList[1].Current?fieldsList[1].CurrentValue:fieldsList[1].ChildValue;
        updateCurrentRec.Account_Type__c=fieldsList[2].Current?fieldsList[2].CurrentValue:fieldsList[2].ChildValue;
        updateCurrentRec.Enrollment__c=fieldsList[3].Current?fieldsList[3].CurrentValue:fieldsList[3].ChildValue;
        updateCurrentRec.Grade_Served__c=fieldsList[4].Current?fieldsList[4].CurrentValue:fieldsList[4].ChildValue;
        updateCurrentRec.School_Code__c=fieldsList[5].Current?fieldsList[5].CurrentValue:fieldsList[5].ChildValue;
        
        if(updateCurrentRec.Website=='[empty]') {
            updateCurrentRec.Website=null;
        }
        if(updateCurrentRec.Account_Type__c=='[empty]') {
            updateCurrentRec.Account_Type__c=null;
        }
        if(updateCurrentRec.Enrollment__c=='[empty]') {
            updateCurrentRec.Enrollment__c=null;
        }
        if(updateCurrentRec.Grade_Served__c=='[empty]') {
            updateCurrentRec.Grade_Served__c=null;
        }
        if(updateCurrentRec.School_Code__c=='[empty]') {
            updateCurrentRec.School_Code__c=null;
        }
       	var child = component.get("v.SelectedChild");
        var action = component.get("c.sendDataToServer");
        action.setParams({updateCurrentRec:updateCurrentRec,child:child});
        action.setCallback(this, function (response) {
            component.set("v.loaded",true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Successfully Merged both programs.",
                "type":"success"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})