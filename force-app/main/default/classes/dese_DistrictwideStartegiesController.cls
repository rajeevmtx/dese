public with sharing class dese_DistrictwideStartegiesController {
    
    @AuraEnabled
    public static string getDistrictWideStrategiesDetails(String proposalId){
        try {
            Project__c project = [SELECT ID,District_Strategic_Plan_groups__c, ESSA_funds_for_FY21__c,
            Title_I_Districts_plan_description__c,Title_I_Districts_Family_Description__c, Equitable_Access_description__c,
            Equitable_Access_district_required__c, Data_and_Evaluation_description__c FROM Project__c WHERE Id =: proposalId];

            //return '';
            DistrictWideStrategiesWrapper wrapper = new DistrictWideStrategiesWrapper();
            wrapper.DistrictStrategicPlagroups = project.District_Strategic_Plan_groups__c;
            wrapper.ESSAfundsforFY21 =project.ESSA_funds_for_FY21__c;
            wrapper.TitleIDistrictsplandescription = project.Title_I_Districts_plan_description__c;
            wrapper.TitleIDistrictsFamilyDescription = project.Title_I_Districts_Family_Description__c;
            wrapper.EquitableAccessdescription = project.Equitable_Access_description__c;
            wrapper.DataandEvaluationdescription = project.Data_and_Evaluation_description__c;
            wrapper.EquitableAccessdistrictrequired = project.Equitable_Access_district_required__c;
            
            

            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static string saveDistrictWideStrategies(String proposalId, String wrapperString){
        try {
            DistrictWideStrategiesWrapper wrapper = (DistrictWideStrategiesWrapper) JSON.deserialize(wrapperString, DistrictWideStrategiesWrapper.class);
            Project__c project = new Project__c(Id = proposalId);
            project.District_Strategic_Plan_groups__c = (String)wrapper.DistrictStrategicPlagroups;
            project.ESSA_funds_for_FY21__c = (String)wrapper.ESSAfundsforFY21;
            project.Title_I_Districts_plan_description__c = (String)wrapper.TitleIDistrictsplandescription;
            project.Title_I_Districts_Family_Description__c = (String)wrapper.TitleIDistrictsFamilyDescription;
            project.Equitable_Access_description__c = (String)wrapper.EquitableAccessdescription;
            project.Data_and_Evaluation_description__c = (String)wrapper.DataandEvaluationdescription;
            project.Equitable_Access_district_required__c = (Boolean)wrapper.EquitableAccessdistrictrequired;
            
            update project;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DistrictWideStrategiesWrapper{
        @AuraEnabled
        public String DistrictStrategicPlagroups;
        @AuraEnabled
        public String ESSAfundsforFY21;
        @AuraEnabled
        public String TitleIDistrictsplandescription;
        @AuraEnabled
        public String TitleIDistrictsFamilyDescription;
        @AuraEnabled
        public String EquitableAccessdescription;
        @AuraEnabled
        public Boolean EquitableAccessdistrictrequired;
        @AuraEnabled
        public String DataandEvaluationdescription;
    }
}