public without sharing class DESE_ProposalController {

    @AuraEnabled
    public static ProposalWrapper getAllProposals(String grantId){
        try {

            Id userId = UserInfo.getUserId();
            //system.assert(false, grantId);
            ProposalWrapper wrapper = new ProposalWrapper();
            wrapper.projectList = new List<Project__c>();
            List<Project__c> projectList =  [SELECT  Id,Status__c, Concept_Paper_Result__c, Concept_Paper__c, Proposal__c,Recommendation__c,
                            Name, Proposed_Total_Cost__c, CreatedBy.Name,
                            Program_Version__c, Program_Version__r.Solicitation_Type__c,
                            Solicitation_Round__c,Solicitation_Round__r.Name,
                            Solicitation_Round__r.Due_Date__c,Solicitation_Round__r.Concept_Paper_Due_Date__c,
                            Solicitation_Round__r.Status__c,
                            (SELECT FirstName__c, LastName__c from Project_Roles__r where Primary_Customer_Contact__c = true limit 1),
                            (Select Concept_Paper__c, Proposal__c,Status__c From Projects__r WHERE Proposal__c = true LIMIT 1)
                    FROM    Project__c WHERE REcordType.DeveloperName = 'Solicitation_Submission' AND CreatedById=: userId AND Program_Version__c = : grantId ORDER By Name DESC];
            Program_Version__c program = [SELECT ID,Name, Solicitation_Number__c FROM Program_Version__c WHERE Id =: grantId];
            Map<Id, String> projectIds = new Map<Id, String>();
            for(Project__c pr: projectList){
                projectIds.put(pr.Id, '');
            }
            List<Final_Report__c> reports = new List<Final_Report__c>([
                SELECT Id, Proposal__c FROM Final_Report__c WHERE Proposal__c IN: projectIds.keySet()
            ]);
            for(Final_Report__c rp: reports){
                projectIds.remove(rp.Proposal__c);
                projectIds.put(rp.Proposal__c, rp.Id);
            }
            wrapper.projectList = projectList;
            wrapper.fundingName = program.Name + ' ( ' + program.Solicitation_Number__c + ' )';
            wrapper.proposalToFinalReport = projectIds;
            return wrapper;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ProposalWrapper{
        @AuraEnabled
        public String fundingName;
        @AuraEnabled
        public List<Project__c> projectList;
        @AuraEnabled public Map<Id, String> proposalToFinalReport;
    }

    @AuraEnabled
    public static string getAllGrants(){
        try{
            List<Program_Version__c> programVersionList = [SELECT ID,Solicitation_Number__c,Name, Short_Description__c,Due_Date__c FROM Program_Version__c WHERE Status__c = 'Open' ];
            return JSON.serialize(programVersionList);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Program_Version__c getGrantDetails(Id grantId){
        try {
            //System.assert(false, grantId);
            return [SELECT Name, Concept_Paper__c, Concept_Paper_Pass_Score__c, Description__c, Short_Description__c,Solicitation_Beta_Review__c,
                        Submission_Outside_Salesforce__c, External_Link__c, NY_Green_Bank_RFP__c,
                        Display_Instructions_and_Portal_Guide__c, Manual_Submission_Only__c,Solicitation_Type__c,
                        Solicitation_Number__c, Due_Date__c
                        // ,
                        // ( SELECT  Due_Date__c, Concept_Paper_Due_Date__c
                        // FROM    Solicitation__r
                        // WHERE   Status__c = 'Open' Order BY Concept_Paper_Due_Date__c, Due_Date__c),
                        // (SELECT Id FROM Program_Contents__r)
                        FROM Program_Version__c WHERE Id =: grantId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createNewProposal(String grantId){
        try {
            Id contactId = [SELECT ID,ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            String accName = [SELECT ID,Account.Name FROM Contact WHERE ID =: contactId].Account?.Name;
            Program_Version__c pversion = [SELECT ID,Program__c FROM Program_Version__c WHERE Id =: grantId];
            Id solicitationRoundId = [SELECT Name, Id FROM Solicitation_Round__c WHERE Solicitation__c = :grantId ORDER BY Name LIMIT 1][0]?.Id;
            Project__c newProject = new Project__c();
            newProject.Program_Version__c = grantId;
            newProject.Program__c = pversion.Program__c;
            newProject.Solicitation_Round__c = solicitationRoundId;
            insert newProject;

            for(Project__c pro : [SELECT Id,Name,Application_Number__c FROM Project__c where id=: newProject.Id]){
                newProject.Name = accName+' - ' + pro.Application_Number__c;
            }
            newProject.Status__c = 'Draft';
            update newProject;

            return newProject.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean isProposalExist(String grantId){
        try {
            //Id userId = UserInfo.getUserId();AND CreatedById=: userId
            List<Project__c> projectList  = [SELECT ID FROM Project__c WHERE REcordType.DeveloperName = 'Solicitation_Submission'  AND Program_Version__c = : grantId];
            if(projectList.isEmpty()){
                return false;
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Program_Version__c getParentGrantDetails(Id projectId){
        return getGrantDetails([SELECT Program_Version__c from Project__c WHERE Id = :projectId]?.Program_Version__c);
    }

    //Abel's Code:
    @AuraEnabled
    public static string submitFinalReport(String data){
        try {
            FinalReportWrapper frw = (FinalReportWrapper)JSON.deserialize(data, FinalReportWrapper.class);
            Final_Report__c fr = new Final_Report__c();
            fr.Approved_Budget_Other__c = frw.approvedBudgetOther;
            fr.Approved_Budget_Project_Coordinator__c = frw.approvedBudgetPC;
            fr.Approved_Budget_Stipend__c = frw.approvedBudgetStipend;
            fr.Approved_Budget_Supervisor_Director__c = frw.approvedBudgetSupervisor;
            fr.Balance_Unexpended_Other__c = frw.balanceUnexpendedOther;
            fr.Balance_Unexpended_Project_Coordinator__c = frw.balanceUnexpendedPC;
            fr.Balance_Unexpended_Stipend__c = frw.balanceUnexpendedStipend;
            fr.Balance_Unexpended_Supervisor_Director__c = frw.balanceUnexpendedSupervisor;
            fr.Funds_Expended_Other__c = frw.fundsExpendedOther;
            fr.Funds_Expended_Project_Coordinator__c = frw.fundsExpendedPC;
            fr.Funds_Expended_Stipend__c = frw.fundsExpendedStipend;
            fr.Funds_Expended_Supervisor_Director__c = frw.fundsExpendedSupervisor;
            fr.Check_Enclosed_Amount__c = frw.checkEnclosedAmount;
            fr.Email_of_person_completing_this_report__c = frw.userEmail;
            fr.Name_of_person_completing_this_report__c = frw.userName;
            fr.Title_of_person_completing_this_report__c = frw.userTitle;
            fr.Proposal__c = frw.projectId;
            fr.Id = frw.reportId;

            upsert fr;
            return 'Successfull Submission';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FinalReportWrapper{
        @AuraEnabled public Integer approvedBudgetSupervisor;
        @AuraEnabled public Integer approvedBudgetPC;
        @AuraEnabled public Integer approvedBudgetStipend;
        @AuraEnabled public Integer approvedBudgetOther;
        @AuraEnabled public Integer fundsExpendedSupervisor;
        @AuraEnabled public Integer fundsExpendedPC;
        @AuraEnabled public Integer fundsExpendedStipend;
        @AuraEnabled public Integer fundsExpendedOther;
        @AuraEnabled public Integer balanceUnexpendedSupervisor;
        @AuraEnabled public Integer balanceUnexpendedPC;
        @AuraEnabled public Integer balanceUnexpendedStipend;
        @AuraEnabled public Integer balanceUnexpendedOther;
        @AuraEnabled public Integer checkEnclosedAmount;
        @AuraEnabled public String userName;
        @AuraEnabled public String userTitle;
        @AuraEnabled public String userEmail;
        @AuraEnabled public String projectId;
        @AuraEnabled public String reportId;
    }

    @AuraEnabled
    public static string getFinalReport(String proposalID){
        try {
            List<Final_Report__c> finalReports = new List<Final_Report__c>([SELECT Id, Approved_Budget_Other__c, Approved_Budget_Project_Coordinator__c, Approved_Budget_Stipend__c,
                                                Approved_Budget_Supervisor_Director__c, Funds_Expended_Other__c, Funds_Expended_Project_Coordinator__c,
                                                Funds_Expended_Stipend__c, Funds_Expended_Supervisor_Director__c, Balance_Unexpended_Other__c,
                                                Balance_Unexpended_Project_Coordinator__c, Balance_Unexpended_Stipend__c, Balance_Unexpended_Supervisor_Director__c,
                                                Check_Enclosed_Amount__c FROM Final_Report__c WHERE Proposal__c =: proposalID LIMIT 1]);
            if(finalReports.size()>0)
                return JSON.serialize(finalReports[0]);
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}