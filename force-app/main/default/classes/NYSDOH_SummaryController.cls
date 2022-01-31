/**
 * Created by arunm on 24-03-2020.
 */

public without sharing class NYSDOH_SummaryController {

    @AuraEnabled
    public static VolunteerAssignmentSummary getVolunteerAssignmentSummary() {
        VolunteerAssignmentSummary volunteerAssignmentSummary = new VolunteerAssignmentSummary();

        User currentUser = NYSDOH_RequestController.getCurrentUser();
        Id contactId = currentUser.ContactId;

        String volunteerAssignmentQuery = 'SELECT COUNT(Id) recordCount, Status__c FROM Volunteer_Assignment__c WHERE Volunteer__r.Contact__c = :contactId ';
        volunteerAssignmentQuery += ' GROUP BY Status__c';

        List<AggregateResult> aggregateResults = Database.query(volunteerAssignmentQuery);
        if(aggregateResults != null && !aggregateResults.isEmpty()) {
            for(AggregateResult aggregateResult : aggregateResults) {
                if((String)aggregateResult.get('Status__c') == 'Active') {
                    volunteerAssignmentSummary.activeAssignments = (Integer)aggregateResult.get('recordCount');
                }
                else if((String)aggregateResult.get('Status__c') == 'Requested') {
                    volunteerAssignmentSummary.scheduledAssignments = (Integer)aggregateResult.get('recordCount');
                }
                else if((String)aggregateResult.get('Status__c') == 'Pending') {
                    volunteerAssignmentSummary.pendingAssignments = (Integer)aggregateResult.get('recordCount');
                }
            }
        }

        return volunteerAssignmentSummary;
    }

    @AuraEnabled
    public static PurchaseRequestSummary getPurchaseRequestSummary() {
        PurchaseRequestSummary purchaseRequestSummary = new PurchaseRequestSummary();
        Id userId = UserInfo.getUserId();

        String purchaseRequestQuery = 'SELECT COUNT(Id) recordCount, Bid_Status__c FROM Bid__c WHERE CreatedById = :userId ';
        purchaseRequestQuery += ' GROUP BY Bid_Status__c';

        List<AggregateResult> aggregateResults = Database.query(purchaseRequestQuery);
        if(aggregateResults != null && !aggregateResults.isEmpty()) {
            for(AggregateResult aggregateResult : aggregateResults) {
                if((String)aggregateResult.get('Bid_Status__c') == 'Active') {
                    purchaseRequestSummary.fulfilledBids = (Integer)aggregateResult.get('recordCount');
                }
                else if((String)aggregateResult.get('Bid_Status__c') == 'Requested') {
                    purchaseRequestSummary.openBids = (Integer)aggregateResult.get('recordCount');
                }
                else if((String)aggregateResult.get('Bid_Status__c') == 'Inactive') {
                    purchaseRequestSummary.outstandingBids = (Integer)aggregateResult.get('recordCount');
                }
            }
        }

        return purchaseRequestSummary;
    }


    public class VolunteerAssignmentSummary {
        @AuraEnabled
        public Integer activeAssignments { get; set; }
        @AuraEnabled
        public Integer scheduledAssignments { get; set; }
        @AuraEnabled
        public Integer pendingAssignments { get; set; }

        public VolunteerAssignmentSummary() {
            this.activeAssignments = 0;
            this.scheduledAssignments = 0;
            this.pendingAssignments = 0;
        }
    }

    public class PurchaseRequestSummary {
        @AuraEnabled
        public Integer fulfilledBids { get; set; }
        @AuraEnabled
        public Integer outstandingBids { get; set; }
        @AuraEnabled
        public Integer openBids { get; set; }

        public PurchaseRequestSummary() {
            this.fulfilledBids = 0;
            this.outstandingBids = 0;
            this.openBids = 0;
        }
    }

}