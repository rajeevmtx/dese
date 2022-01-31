public with sharing class DC_HomeButtonsController {
    @AuraEnabled
    public static void RequestConsent() {
        System.debug('Request Consent');
        Database.executebatch(new DC_SendConsentMessagesBatch(), 5);
    }

    @AuraEnabled
    public static void RequestFollowUp() {
        System.debug('Request Followup');
        Database.executebatch(new DC_SendFollowUpMessagesBatch(), 5);
    }
}