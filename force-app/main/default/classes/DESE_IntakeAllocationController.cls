public class DESE_IntakeAllocationController {


    @AuraEnabled
    public static string getAllocationAndFlexingDetails(String proposalId){
        try {
            Project__c project = [SELECT ID,Post_flexing_funds_for_use_per_Title_I__c,Post_flexing_funds_for_use_per_Title_II__c,
                                Post_flexing_funds_for_use_per_Title_III__c,Post_flexing_funds_for_use_per_Title_IV__c,Total_Allocation_Title_I_Part_A__c,
                                Total_Allocation_Title_II_Part_A__c,Total_Allocation_Title_III_Part_A__c,Total_Allocation_Title_IV_Part_A__c,
                                Title_II_funds_flexed_into_Title_I__c,Title_II_funds_flexed_into_Title_III__c,Title_II_funds_flexed_into_Title_IV__c,
                                Title_IV_funds_flexed_into_Title_I__c,Title_IV_funds_flexed_into_Title_II__c,Title_IV_funds_flexed_into_Title_III__c  FROM Project__c WHERE Id =: proposalId];

            //return '';
            AllocationWrapper wrapper = new AllocationWrapper();
            wrapper.totalAllocationTitleI = project.Total_Allocation_Title_I_Part_A__c == null ? 0 : project.Total_Allocation_Title_I_Part_A__c;
            wrapper.totalAllocationTitleII =project.Total_Allocation_Title_II_Part_A__c == null ? 0 : project.Total_Allocation_Title_II_Part_A__c;
            wrapper.totalAllocationTitleIII = project.Total_Allocation_Title_III_Part_A__c == null ? 0 : project.Total_Allocation_Title_III_Part_A__c;
            wrapper.totalAllocationTitleIV = project.Total_Allocation_Title_IV_Part_A__c == null ? 0 : project.Total_Allocation_Title_IV_Part_A__c;
            wrapper.postFlexingTitleI = project.Post_flexing_funds_for_use_per_Title_I__c == null ? 0 : project.Post_flexing_funds_for_use_per_Title_I__c;
            wrapper.postFlexingTitleII = project.Post_flexing_funds_for_use_per_Title_II__c == null ? 0 : project.Post_flexing_funds_for_use_per_Title_II__c;
            wrapper.postFlexingTitleIII = project.Post_flexing_funds_for_use_per_Title_III__c == null ? 0 : project.Post_flexing_funds_for_use_per_Title_III__c;
            wrapper.postFlexingTitleIV = project.Post_flexing_funds_for_use_per_Title_IV__c == null ? 0 : project.Post_flexing_funds_for_use_per_Title_IV__c;
            wrapper.titleIIFundsTitleI = project.Title_II_funds_flexed_into_Title_I__c == null ? 0 : project.Title_II_funds_flexed_into_Title_I__c;
            wrapper.titleIIFundsTitleIII = project.Title_II_funds_flexed_into_Title_III__c == null ? 0 : project.Title_II_funds_flexed_into_Title_III__c;
            wrapper.titleIIFundsTitleIV = project.Title_II_funds_flexed_into_Title_IV__c == null ? 0 : project.Title_II_funds_flexed_into_Title_IV__c;
            wrapper.titleIVFundsTitleI = project.Title_IV_funds_flexed_into_Title_I__c == null ? 0 : project.Title_IV_funds_flexed_into_Title_I__c;
            wrapper.titleIVFundsTitleII = project.Title_IV_funds_flexed_into_Title_II__c == null ? 0 : project.Title_IV_funds_flexed_into_Title_II__c;
            wrapper.titleIVFundsTitleIII = project.Title_IV_funds_flexed_into_Title_III__c == null ? 0 : project.Title_IV_funds_flexed_into_Title_III__c;

            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static string saveAllocationAndFlexing(String proposalId, String wrapperString){
        try {
            AllocationWrapper wrapper = (AllocationWrapper) JSON.deserialize(wrapperString, AllocationWrapper.class);
            Project__c project = new Project__c(Id = proposalId);
            project.Post_flexing_funds_for_use_per_Title_I__c = (Decimal)wrapper.postFlexingTitleI;
            project.Post_flexing_funds_for_use_per_Title_II__c = (Decimal)wrapper.postFlexingTitleII;
            project.Post_flexing_funds_for_use_per_Title_III__c = (Decimal)wrapper.postFlexingTitleIII;
            project.Post_flexing_funds_for_use_per_Title_IV__c = (Decimal)wrapper.postFlexingTitleIV;
            project.Total_Allocation_Title_I_Part_A__c = (Decimal) wrapper.totalAllocationTitleI;
            project.Total_Allocation_Title_II_Part_A__c = (Decimal) wrapper.totalAllocationTitleII;
            project.Total_Allocation_Title_III_Part_A__c = (Decimal) wrapper.totalAllocationTitleIII;
            project.Total_Allocation_Title_IV_Part_A__c = (Decimal) wrapper.totalAllocationTitleIV;
            project.Title_II_funds_flexed_into_Title_I__c = (Decimal) wrapper.titleIIFundsTitleI;
            project.Title_II_funds_flexed_into_Title_III__c = (Decimal) wrapper.titleIIFundsTitleIII;
            project.Title_II_funds_flexed_into_Title_IV__c = (Decimal) wrapper.titleIIFundsTitleIV;
            project.Title_IV_funds_flexed_into_Title_I__c = (Decimal) wrapper.titleIVFundsTitleI;
            project.Title_IV_funds_flexed_into_Title_II__c = (Decimal) wrapper.titleIVFundsTitleII;
            project.Title_IV_funds_flexed_into_Title_III__c = (Decimal) wrapper.titleIVFundsTitleIII;
            project.Proposed_NYSERDA_Cost__c = project.Total_Allocation_Title_I_Part_A__c + project.Total_Allocation_Title_II_Part_A__c + project.Total_Allocation_Title_III_Part_A__c + project.Total_Allocation_Title_IV_Part_A__c;
            update project;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class AllocationWrapper{
        @AuraEnabled
        public Decimal totalAllocationTitleI;
        @AuraEnabled
        public Decimal totalAllocationTitleII;
        @AuraEnabled
        public Decimal totalAllocationTitleIII;
        @AuraEnabled
        public Decimal totalAllocationTitleIV;
        @AuraEnabled
        public Decimal postFlexingTitleI;
        @AuraEnabled
        public Decimal postFlexingTitleII;
        @AuraEnabled
        public Decimal postFlexingTitleIII;
        @AuraEnabled
        public Decimal postFlexingTitleIV;
        @AuraEnabled
        public Decimal titleIIFundsTitleI;
        @AuraEnabled
        public Decimal titleIIFundsTitleIII;
        @AuraEnabled
        public Decimal titleIIFundsTitleIV;
        @AuraEnabled
        public Decimal titleIVFundsTitleI;
        @AuraEnabled
        public Decimal titleIVFundsTitleII;
        @AuraEnabled
        public Decimal titleIVFundsTitleIII;
    }

}