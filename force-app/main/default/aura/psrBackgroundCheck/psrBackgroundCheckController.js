({
	doInit : function(component, event, helper) {
        let records = [];
        records.push({incidentDate : 'January 15, 2003', city : 'San Diego', state : 'California', county : 'San Diego', incidentType : 'Felony', uploadedDocumentList : [{Title:'Charges Dismissal document',Id: '0693F000000iBr9QAE'}]});
        records.push({incidentDate : 'October 24, 2011', city : 'Austin', state : 'Texas', county : 'Travis', incidentType : 'Misdemeanors', uploadedDocumentList : [{Title:'Arrest charges',Id: '0693F000000iBrEQAU'}]});
        records.push({incidentDate : 'February 18, 2015', city : 'Albany', state : 'New York', county : 'Alameda', incidentType : 'Infraction', uploadedDocumentList : [{Title:'Speeding ticket',Id: '0693F000000iBrKQAU'}]});
        records.push({incidentDate : 'August 25, 2018', city : 'Davis', state : 'California', county : 'Yolo', incidentType : 'Infraction', uploadedDocumentList : [{Title:'Parking ticket',Id: '0693F000000iBrJQAU'}]});
        component.set('v.records',records);          
	},
    handleFileOpen : function(component, event, helper) {
        var selectedItem = event.currentTarget.getAttribute("data-record");
        $A.get("e.lightning:openFiles").fire({
            recordIds: [selectedItem]
        });
    }
})