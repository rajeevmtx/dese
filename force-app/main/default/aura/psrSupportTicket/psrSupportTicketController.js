({
    handleSuccess: function(cmp, event, helper) {
        cmp.set("v.showForm",false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Support ticket submited successfully.",
            "type":"success"
        });
        toastEvent.fire();
        cmp.set("v.showForm",true);
    },
    
    //START: Modified by Sajal for BI-16168
    handleSubmit: function(cmp, event, helper){
        debugger;
        event.preventDefault();
        var eventFields = event.getParam('fields');
        var firstName = eventFields['First_Name__c'];
        var lastName = eventFields['Last_Name__c'];
        var subject = eventFields['Subject'];
        var showValidationError = false;
        var vaildationFailReason = '';
        var message = '';
        var firstNameParaCmp = cmp.find("firstNamePara");
        var firstNameCmp = cmp.find("firstName");
        var lastNameParaCmp = cmp.find("lastNamePara");
        var lastNameCmp = cmp.find("lastName");
        var subjectParaCmp = cmp.find("subjectPara");
        var subjectCmp = cmp.find("subject");
        
        if(firstName.replace(/\s/g, '').length < 1){
            showValidationError = true;
            $A.util.addClass(firstNameParaCmp, "show_para");
            $A.util.removeClass(firstNameParaCmp, "hide_para");
            $A.util.addClass(firstNameCmp, 'slds-has-error');
        }
        else{
            $A.util.removeClass(firstNameParaCmp, "show_para");
            $A.util.addClass(firstNameParaCmp, "hide_para");
            $A.util.removeClass(firstNameCmp, 'slds-has-error');
        }
        
        if(lastName.replace(/\s/g, '').length < 1){
            showValidationError = true;
            $A.util.addClass(lastNameParaCmp, "show_para");
            $A.util.removeClass(lastNameParaCmp, "hide_para");
            $A.util.addClass(lastNameCmp, 'slds-has-error');
        }
        else{
            $A.util.removeClass(lastNameParaCmp, "show_para");
            $A.util.addClass(lastNameParaCmp, "hide_para");
            $A.util.removeClass(lastNameCmp, 'slds-has-error');
        }
        
        if(subject.replace(/\s/g, '').length < 1){
            showValidationError = true;
            $A.util.addClass(subjectParaCmp, "show_para");
            $A.util.removeClass(subjectParaCmp, "hide_para");
            $A.util.addClass(subjectCmp, 'slds-has-error');
        }
        else{
            $A.util.removeClass(subjectParaCmp, "show_para");
            $A.util.addClass(subjectParaCmp, "hide_para");
            $A.util.removeClass(subjectCmp, 'slds-has-error');
        }
        
        if(!showValidationError){
            cmp.find('caseEditForm').submit(eventFields);
        }
    }
    //END: Modified by Sajal for BI-16168
})