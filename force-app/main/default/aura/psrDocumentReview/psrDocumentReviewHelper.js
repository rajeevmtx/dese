({
    getApplicationDocs: function(component, event, helper) {
        debugger;
        var appId = component.get("v.recordId");
        helper.callApex(
            component,
            "c.getApplicationDocumnets", { applicationId: appId },
            function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var results = response.getReturnValue();
                    console.log("results", JSON.stringify(results));

                    for (var i = 0; i < results.length; i++) {
                        if (
                            results[i].status == "Unsubmitted" ||
                            results[i].status == "Submitted"
                        ) {
                            results[i].notes = "";
                        }
                    }
                    if (results.length > 0) {
                        if (
                            results[0].applicationStatus == "Under Review" ||
                            results[0].applicationStatus == "Submitted" ||
                            results[0].applicationStatus == "Missing Information"
                        ) {
                            component.set("v.isEditEnabled", true);
                        }
                        component.set("v.applicationStatus", results[0].applicationStatus);
                    }
                    component.set("v.applicationDocList", results);
                    //   component.set("v.documentList",results[0].uploadedDocumentList);
                } else {
                    console.log("Error thrown", JSON.stringify(response.getError()));
                }
            }
        );
    },

    saveDocsReview: function(component, event, helper) {
        debugger;
        var applicationStatus = component.get("v.applicationStatus");
        if (
            applicationStatus == "Submitted" ||
            applicationStatus == "Missing Information"
        ) {
            component.set("v.showUnderReviewMessage", true);
        } else {
            component.set("v.editable", false);
            var docs = component.get("v.applicationDocList");
            for (var i = 0; i < docs.length; i++) {
                if (docs[i].selectedValue !== "") {
                    docs[i].status = docs[i].selectedValue;
                }
            }
            helper.callApex(
                component,
                "c.updateReviewedDocuments", { docValues: JSON.stringify(docs) },
                function(response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        var results = response.getReturnValue();
                        console.log("results", JSON.stringify(results));

                        for (var i = 0; i < results.length; i++) {
                            if (
                                results[i].status == "Unsubmitted" ||
                                results[i].status == "Submitted"
                            ) {
                                results[i].notes = "";
                            }
                        }
                        component.set("v.applicationDocList", results);
                    } else {
                        console.log("Error thrown", JSON.stringify(response.getError()));
                    }
                }
            );
        }
    }
});