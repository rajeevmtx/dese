public with sharing class DESE_IntakePPSController {

    @AuraEnabled
    public static PSSWrapper getPSSDetails(String projectId){
        try {
            Project__c project = [SELECT Id,
                                Title_II_Lead_for_Schedule_A_Consortium__c,Title_III_Lead_for_Schedule_A_Consortium__c,Title_IV_Lead_for_Schedule_A_Consortium__c,
                                Title_II_Total_Consortium_Enrollment__c,Title_III_Total_Consortium_EL_Enrollment__c,Title_IV_Total_Consortium_Enrollment__c,
                                PSS_Title_I_Services_provided__c,PSS_Impact_of_service_assessed_based_on__c,PSS_Determine_Low_Income_Private_School__c,PSS_Contacted_all_private_schools__c,
                                Title_II_direct_administrative_expenses__c,Title_III_direct_administrative_expenses__c,Title_IV_direct_administrative_expenses__c,
                                Post_flexing_funds_for_use_per_Title_I__c,Post_flexing_funds_for_use_per_Title_II__c,Post_flexing_funds_for_use_per_Title_III__c,Post_flexing_funds_for_use_per_Title_IV__c
                                    FROM Project__c WHERE Id =: projectId];

            PSSWrapper wrapper = new PSSWrapper();
            wrapper.istitle2Consortium = project.Title_II_Lead_for_Schedule_A_Consortium__c;
            wrapper.istitle3Consortium = project.Title_III_Lead_for_Schedule_A_Consortium__c;
            wrapper.istitle4Consortium = project.Title_IV_Lead_for_Schedule_A_Consortium__c;
            wrapper.title2Consortium = project.Title_II_Total_Consortium_Enrollment__c;
            wrapper.title3Consortium = project.Title_III_Total_Consortium_EL_Enrollment__c;
            wrapper.title4Consortium = project.Title_IV_Total_Consortium_Enrollment__c;
            wrapper.serviceProvided = project.PSS_Title_I_Services_provided__c;
            wrapper.impactOfService = project.PSS_Impact_of_service_assessed_based_on__c;
            wrapper.determineLow = project.PSS_Determine_Low_Income_Private_School__c;
            wrapper.contactedAll = project.PSS_Contacted_all_private_schools__c;
            wrapper.title2dae = project.Title_II_direct_administrative_expenses__c;
            wrapper.title3dae = project.Title_III_direct_administrative_expenses__c;
            wrapper.title4dae = project.Title_IV_direct_administrative_expenses__c;
            wrapper.postflex1 = project.Post_flexing_funds_for_use_per_Title_I__c;
            wrapper.postflex2 = project.Post_flexing_funds_for_use_per_Title_II__c;
            wrapper.postflex3 = project.Post_flexing_funds_for_use_per_Title_III__c;
            wrapper.postflex4 = project.Post_flexing_funds_for_use_per_Title_IV__c;

            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string savePSS(String proposalId, String wrapperString){
        try {
            PSSWrapper wrapper = (PSSWrapper) JSON.deserialize(wrapperString, PSSWrapper.class);
            Project__c project = new Project__c(Id = proposalId);
            project.Title_II_Lead_for_Schedule_A_Consortium__c = wrapper.istitle2Consortium;
            project.Title_III_Lead_for_Schedule_A_Consortium__c = wrapper.istitle3Consortium;
            project.Title_IV_Lead_for_Schedule_A_Consortium__c = wrapper.istitle4Consortium;
            project.Title_II_Total_Consortium_Enrollment__c = wrapper.title2Consortium;
            project.Title_III_Total_Consortium_EL_Enrollment__c = wrapper.title3Consortium;
            project.Title_IV_Total_Consortium_Enrollment__c = wrapper.title4Consortium;
            project.PSS_Title_I_Services_provided__c = wrapper.serviceProvided;
            project.PSS_Impact_of_service_assessed_based_on__c = wrapper.impactOfService;
            project.PSS_Determine_Low_Income_Private_School__c = wrapper.determineLow;
            project.PSS_Contacted_all_private_schools__c = wrapper.contactedAll;
            project.Title_II_direct_administrative_expenses__c = wrapper.title2dae;
            project.Title_III_direct_administrative_expenses__c = wrapper.title3dae;
            project.Title_IV_direct_administrative_expenses__c = wrapper.title4dae;
            update project;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class PSSWrapper{
        @AuraEnabled
        public String istitle2Consortium;
        @AuraEnabled
        public String istitle3Consortium;
        @AuraEnabled
        public String istitle4Consortium;
        @AuraEnabled
        public Decimal title2Consortium;
        @AuraEnabled
        public Decimal title3Consortium;
        @AuraEnabled
        public Decimal title4Consortium;
        @AuraEnabled
        public String serviceProvided;
        @AuraEnabled
        public String impactOfService;
        @AuraEnabled
        public String determineLow;
        @AuraEnabled
        public String contactedAll;
        @AuraEnabled
        public Decimal title2dae;
        @AuraEnabled
        public Decimal title3dae;
        @AuraEnabled
        public Decimal title4dae;
        @AuraEnabled
        public Decimal postflex1;
        @AuraEnabled
        public Decimal postflex2;
        @AuraEnabled
        public Decimal postflex3;
        @AuraEnabled
        public Decimal postflex4;
    }
}