angular.module('eecApp')
  .factory('Util', function() {
	 return {
	   convertDateToString: function(dateStr) {
         var d = new Date(dateStr);
         // Format the date in English standard. Increment the month by one due to Date returning 0-11.
         var formattedDate = d.getUTCDate() + '/' + (d.getUTCMonth() + 1) + '/' + d.getUTCFullYear();
         return formattedDate;
	   },

     generateWizardElements: function(licenseType, activeStep) {
       var elements = [];
       var elementDefinitions = {
         "fcc_new_license": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Individuals Regularly on Premise",
             "Licensing/Capacity Info",
             "Assistant Info",
             "Involvement & Professional Experience",
             "Background Information",
             "Training Information",
             "Indoor/Outdoor Space Info",
             "Daily Routine/Tech Assistance",
             "Attachments",
             "Review & Submission"
           ]
         },
         "fcc_license_upgrade": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Individuals Regularly on Premise",
             "Licensing/Capacity Info",
             "Assistant Info",
             "Background Information",
             "Training Information",
             "Indoor/Outdoor Space Info",
             "Daily Routine/Tech Assistance",
             "Attachments",
             "Review & Submission"
           ]
         },
         "change_of_address": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Individuals Regularly on Premise",
             "Indoor/Outdoor Space Info",
             "Daily Routine/Tech Assistance",
             "Review & Submission"
           ]
         },
         "fcc_change_room_floor_level": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Indoor/Outdoor Space Info",
             "Daily Routine/Tech Assistance",
             "Review & Submission"
           ]
         },
         "fcc_change_of_household": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Individuals Regularly on Premise",
             "Daily Routine/Tech Assistance",
             "Review & Submission"
           ]
         },
         "fcc_renewal": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Individuals Regularly on Premise",
             "Licensing/Capacity Info",
             "Assistant Info",
             "Background Information",
             "Training Information",
             "Indoor/Outdoor Space Info",
             "Daily Routine/Tech Assistance",
             "Attachments",
             "Review & Submission"
           ]
         },
         "fcc_assistant_license_upgrade": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Involvement & Professional Experience",
             "Background Information",
             "Training Information",
             "Review & Submission"
           ]
         },
         "fcc_assistant_new_license": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Involvement & Professional Experience",
             "Daily Routine & Activities",
             "Background Information",
             "Training Information",
             "Review & Submission"
           ]
         },
         "fcc_assistant_renewal": {
           "labels": [
             "Instruction",
             "Transaction/Provider Info",
             "Involvement & Professional Experience",
             "Daily Routine & Activities",
             "Background Information",
             "Training Information",
             "Review & Submission"
           ]
         },
       };
       // Get the definition for the current license type.
       var typeObj = elementDefinitions[licenseType.toLowerCase()];
       if (typeof typeObj != "undefined") {
         var activeStepPassed = false;
         // Loop through the labels. Add them to the elements and verify which one is active.
         for (i=0; i < typeObj.labels.length; i++) {
           var selected = false;
           // If the current label is the active step then set the selected flag.
           if (typeObj.labels[i] === activeStep) {
             activeStepPassed = true;
             selected = true;
           }

           elements.push({
             "label": typeObj.labels[i],
             "selected": selected,
             "icon": (activeStepPassed ? 'info_outline' : 'check')
           });
         }
       }
       // Return the wizard elements.
       return elements;
     }
 	 }
});
