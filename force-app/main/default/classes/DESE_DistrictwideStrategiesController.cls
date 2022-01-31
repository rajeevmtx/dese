public with sharing class DESE_DistrictwideStrategiesController {
    
    @AuraEnabled
    public static string getDistrictWideStrategiesDetails(String proposalId){
        try {
            Project__c project = [SELECT ID,District_Strategic_Plan_groups__c, ESSA_funds_for_FY21__c,
            Title_I_Districts_plan_description__c,Title_I_Districts_Family_Description__c,Equitable_Access_description__c,Data_and_Evaluation_description__c,Equitable_Access_district_required__c,
            All_District_Principal_Data__c,All_District_Principal_Sources__c FROM Project__c WHERE Id =: proposalId];
            //return '';
            DistrictWideStrategiesWrapper wrapper = new DistrictWideStrategiesWrapper();
            wrapper.DistrictStrategicPlagroups = project.District_Strategic_Plan_groups__c == null ? new List<String>() : project.District_Strategic_Plan_groups__c.split(';');
            wrapper.AllDistrictPrincipalData = project.All_District_Principal_Data__c == null ? new List<String>() : project.All_District_Principal_Data__c.split(';');
            wrapper.AllDistrictPrincipalSources = project.All_District_Principal_Sources__c == null ? new List<String>() : project.All_District_Principal_Sources__c.split(';');
            
            wrapper.ESSAfundsforFY21 =project.ESSA_funds_for_FY21__c == null ? '' : project.ESSA_funds_for_FY21__c;
            wrapper.TitleIDistrictsplandescription = project.Title_I_Districts_plan_description__c == null ? '' : project.Title_I_Districts_plan_description__c;
            wrapper.TitleIDistrictsFamilyDescription = project.Title_I_Districts_Family_Description__c == null ? '' : project.Title_I_Districts_Family_Description__c;
            wrapper.EquitableAccessDescription = project.Equitable_Access_description__c == null ? '' : project.Equitable_Access_description__c;
            wrapper.DataEvaluationDescription = project.Data_and_Evaluation_description__c == null ? '' : project.Data_and_Evaluation_description__c;
            wrapper.EquitableAccessDistrictRequired = project.Equitable_Access_district_required__c == true ? 'true' : 'false';
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
            system.debug('wrapperString---'+ wrapper.EquitableAccessDistrictRequired);
            String str1='';String str2='';String str3='';
            if(wrapper.DistrictStrategicPlagroups != NULL){
                str1= String.join(wrapper.DistrictStrategicPlagroups,';');
            }if(wrapper.AllDistrictPrincipalData != NULL){
                str2= String.join(wrapper.AllDistrictPrincipalData,';');
            }if(wrapper.AllDistrictPrincipalSources != NULL){
                str3= String.join(wrapper.AllDistrictPrincipalSources,';');
            }

            project.District_Strategic_Plan_groups__c = str1;
            project.All_District_Principal_Data__c=str2;
            project.All_District_Principal_Sources__c=str3;
            project.ESSA_funds_for_FY21__c = (String)wrapper.ESSAfundsforFY21;
            project.Title_I_Districts_plan_description__c = (String)wrapper.TitleIDistrictsplandescription;
            project.Title_I_Districts_Family_Description__c = (String)wrapper.TitleIDistrictsFamilyDescription;
            project.Equitable_Access_description__c=(String)wrapper.EquitableAccessDescription;
            project.Data_and_Evaluation_description__c=(String)wrapper.DataEvaluationDescription;
            project.Equitable_Access_district_required__c=(String)wrapper.EquitableAccessDistrictRequired == 'true'?true:false;
            update project;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DistrictWideStrategiesWrapper{
        @AuraEnabled
        public List<String> AllDistrictPrincipalData;
        @AuraEnabled
        public List<String> AllDistrictPrincipalSources;
        @AuraEnabled
        public List<String> DistrictStrategicPlagroups;
        @AuraEnabled
        public String ESSAfundsforFY21;
        @AuraEnabled
        public String TitleIDistrictsplandescription;
        @AuraEnabled
        public String TitleIDistrictsFamilyDescription;
        @AuraEnabled
        public String EquitableAccessDescription;
        @AuraEnabled
        public String DataEvaluationDescription;
        @AuraEnabled
        public String EquitableAccessDistrictRequired;

    }

    @AuraEnabled
    public static List<Project_Content__c> getProjectInitiative(Id proposalId){
        try {

            return [SELECT ID,Initiative_Name__c, Initiative_Strategies_Activities__c,
                Initiative_activity_explicitly_Connected__c,Project__c
                FROM Project_Content__c WHERE Project__c =: proposalId AND recordTypeId='012030000000kUUAAY'];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string saveProjectInitiative(String proposalId, String wrapperString){
        try {
            ProjectContentInitiativeWrapper wrapper = (ProjectContentInitiativeWrapper) JSON.deserialize(wrapperString, ProjectContentInitiativeWrapper.class);
            Project_Content__c projectContent = new Project_Content__c(Project__c=proposalId);
            projectContent.recordtypeid='012030000000kUUAAY';
            projectContent.Initiative_Name__c = (String)wrapper.InitiativeName;
            projectContent.Initiative_Strategies_Activities__c = (String)wrapper.InitiativeStrategiesActivities;
            projectContent.Initiative_activity_explicitly_Connected__c = (String)wrapper.InitiativeactivityexplicitlyConnected == 'true'?true:false;
            String str='';
            
            if(wrapper.InitiativeFundingSource != NULL){
                str= String.join(wrapper.InitiativeFundingSource,';');
            }
            projectContent.Initiative_Funding_Source__c = str;
            insert projectContent;
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class ProjectContentInitiativeWrapper{
        @AuraEnabled
        public String InitiativeName;
        @AuraEnabled
        public List<String> InitiativeFundingSource;
        @AuraEnabled
        public String InitiativeStrategiesActivities;
        @AuraEnabled
        public String InitiativeactivityexplicitlyConnected;

    }

}