/*
*   Class Name: NYSUN_APPINTAKE_Review_Service
*   Description: Purpose to Review application through NYSUN_CHANGEMOD_Controller and NYSUN_APPINTAKE_Controller classes
*                                                      
*/
public with sharing class NYSUN_APPINTAKE_Review_Service{
     
    /*
    * Method Name: getApplicationReviewDetails
    * Description: Return records of application review on the basis of projectId
    * @param: Id projectId
    * @return: ApplicationReviewWrapper                                                      
    */
    public static ApplicationReviewWrapper getApplicationReviewDetails(Id projectId){
          
        ApplicationReviewWrapper applicationReview = new ApplicationReviewWrapper();
          
       /* for(Project__c project : [SELECT Id, Name, GJGNY_Participant_Sector__c, CESIR__c ,Remote_Net_Metering__c, Statement__c, Current_Block_Rate__c,
                                  New_or_Existing_Meter__c, Purchase_Type__c, Expansion_of_Completed_System__c, RecordType.developerName,
                                  Customers_Preferred_Loan_Option__c, Customers_Preferred_Loan_Term__c, Strategic_Location__c,
                                  Battery_Storage_Integration__c,Commercial_Solar_Application_Track__c,Annual_Electrical_Offset__c ,
                                  Energy_Efficiency_Integration__c,PBI_Rate__c ,Historical_Annual_Energy_Consumption__c ,
                                  Loan_Amount__c,Program_Version__r.program__r.Name,Expected_Interconnection_Date__c, Payment_Assignment__c,
                                  Application_Number__c,
                                  (SELECT Id, Program__r.Name FROM Project_Templates__r),
                                  (SELECT Id, Address_1__c, City__c,  Affordable_Solar__c,
                                   County__c, Utility_Sector__c, Metering_Method__c, 
                                   Utility_Company__c, Utility_Subsector__c, NYPA__c,
                                   State__c, Zip__c FROM Project_Site__r)
                                  FROM Project__c WHERE Id =: CORE_Helper.doEscapeSingleQuotes(projectId)]){
            
            for(Wizard_Template__c proTemp : project.Project_Templates__r){
                
                applicationReview.program = proTemp.Program__r.Name;
            } 
            
            applicationReview.project = project;
            
            String statement = project.Statement__c;
            
            applicationReview.project.Statement__c = '';
            
            for(Project_Site__c proSite : project.Project_Site__r){
                
                applicationReview.site = proSite;
                
                if(statement != null){
                  
                  applicationReview.project.Statement__c = statement.substringBetween(NYSUN_Helper.GENERIC_START_TAG, 
                                                    NYSUN_Helper.GENERIC_END_TAG);
                }
                
                if(applicationReview.project.Statement__c == null){
                  
                  applicationReview.project.Statement__c = '';
                }
                
                if(statement != null && project.RecordType.developerName == NYSUN_Helper.RESIDENTIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME){
                  
                  if(proSite.Utility_Sector__c == NYSUN_Helper.NON_RESIDENTIAL_UTILITY_SECTOR){
                    
                    applicationReview.project.Statement__c += statement.substringBetween(NYSUN_Helper.NON_RESIDENTIAL_START_TAG, 
                                                      NYSUN_Helper.NON_RESIDENTIAL_END_TAG);
                  }else if((proSite.Utility_Sector__c == NYSUN_Helper.RESIDENTIAL_UTILITY_SECTOR) &&
                           (!proSite.Affordable_Solar__c)){
                             
                    applicationReview.project.Statement__c += statement.substringBetween(NYSUN_Helper.RESIDENTIAL_START_TAG, 
                                                      NYSUN_Helper.RESIDENTIAL_END_TAG);
                  }else if((proSite.Utility_Sector__c == NYSUN_Helper.RESIDENTIAL_UTILITY_SECTOR) &&
                           (proSite.Affordable_Solar__c)){
                              
                    applicationReview.project.Statement__c += statement.substringBetween(NYSUN_Helper.AFFORDABLE_SOLAR_START_TAG, 
                                                      NYSUN_Helper.AFFORDABLE_SOLAR_END_TAG);
                  }
                }else if(statement != null && project.RecordType.developerName == NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME){
                  
                  if(project.Commercial_Solar_Application_Track__c == NYSUN_Helper.APPLICATION_TRACK1){
                    
                    applicationReview.project.Statement__c += statement.substringBetween(NYSUN_Helper.TRACK1_START_TAG, 
                                                      NYSUN_Helper.TRACK1_END_TAG);
                  }else if(project.Commercial_Solar_Application_Track__c == NYSUN_Helper.APPLICATION_TRACK2){
                    
                    applicationReview.project.Statement__c += statement.substringBetween(NYSUN_Helper.TRACK2_START_TAG, 
                                                      NYSUN_Helper.TRACK2_END_TAG);
                  }
                  
                  if(project.Payment_Assignment__c){
                     
                    if(applicationReview.project.Statement__c == null){
                       applicationReview.project.Statement__c = '';
                    }
                    
                    applicationReview.project.Statement__c += statement.substringBetween(NYSUN_Helper.PAYMENT_ASSIGNMENT_START_TAG, 
                                                       NYSUN_Helper.PAYMENT_ASSIGNMENT_END_TAG);
                  }
                }
            }
             
            if(project.New_or_Existing_Meter__c == 'New Meter'){
                
                applicationReview.isNewBuildingType = true;
            }else{
                
                applicationReview.isExistingBuildingType = false;
            }
        }
        
        List<Project_Role__c> customerList = NYSUN_APPINTAKE_CustomerContacts_Service.getCustomerProjectRoleList(projectId);
        for(Project_Role__c customer : customerList) {
          
            if(customer.Primary_Customer_Contact__c) {
                applicationReview.primaryCustomer = customer.FirstName__c + ' ' + customer.LastName__c;
                applicationReview.companyName = customer.Company_Name__c;
                break;  
            }  
        }
        */ 
        return applicationReview; 
    }
    
    /*
    * Method Name: getCaseReviewDetails
    * Description: get case review details
    * @param: Id caseIdcase 
    * @param: Id projectId
    * @return: ApplicationReviewWrapper                                                      
    */
    public static ApplicationReviewWrapper getCaseReviewDetails(Id caseId, Id projectId){
          
        ApplicationReviewWrapper applicationReview = new ApplicationReviewWrapper();
       /*  
        for(Case tempCase : [SELECT Id, GJGNY_Participant_Sector__c, CESIR__c ,Remote_Net_Metering__c, Statement__c, Current_Block_Rate__c,
                              New_or_Existing_Meter__c, Purchase_Type__c, Expansion_of_Completed_System__c,Annual_Electrical_Offset__c ,
                              Customers_Preferred_Loan_Option__c, Customers_Preferred_Loan_Term__c, Strategic_Location__c,
                              Battery_Storage_Integration__c,Commercial_Solar_Application_Track__c,Estimated_Annual_Energy_Production__c ,
                              Energy_Efficiency_Integration__c,PBI_Rate__c ,Historical_Annual_Energy_Consumption__c ,
                              Loan_Amount__c,Program_Version__r.program__r.Name,Expected_Interconnection_Date__c,
                              Project__r.Application_Number__c, RecordType.developerName, Payment_Assignment__c,
                              (SELECT Id, Program__r.Name FROM Wizard_Templates__r)
                              FROM Case WHERE Id =: CORE_Helper.doEscapeSingleQuotes(caseId)]){
            
            for(Wizard_Template__c proTemp : tempCase.Wizard_Templates__r){
                
                applicationReview.program = proTemp.Program__r.Name;
            }
            
            applicationReview.caseRecord = tempCase;
            
            if(tempCase.New_or_Existing_Meter__c == 'New Meter'){
                
                applicationReview.isNewBuildingType = true;
            }else{
                
                applicationReview.isExistingBuildingType = false;
            }
            
            String statement = tempCase.Statement__c;
            
            applicationReview.caseRecord.Statement__c = '';
            
            if(statement != null){
                  
              applicationReview.caseRecord.Statement__c = statement.substringBetween(NYSUN_Helper.GENERIC_START_TAG, 
                                                   NYSUN_Helper.GENERIC_END_TAG);
            }
            
            if(applicationReview.caseRecord.Statement__c == null){
              
              applicationReview.caseRecord.Statement__c = '';
            }
            
            if(statement != null && tempCase.RecordType.developerName == NYSUN_Helper.COMMERCIAL_PROJECT_RECORD_TYPE_DEVELOPER_NAME){
                  
              if(tempCase.Commercial_Solar_Application_Track__c == NYSUN_Helper.APPLICATION_TRACK1){
                
                applicationReview.caseRecord.Statement__c += statement.substringBetween(NYSUN_Helper.TRACK1_START_TAG, 
                                                    NYSUN_Helper.TRACK1_END_TAG);
              }else if(tempCase.Commercial_Solar_Application_Track__c == NYSUN_Helper.APPLICATION_TRACK2){
                
                applicationReview.caseRecord.Statement__c += statement.substringBetween(NYSUN_Helper.TRACK2_START_TAG, 
                                                    NYSUN_Helper.TRACK2_END_TAG);
              }
              
              if(tempCase.Payment_Assignment__c){ 
                
                if(applicationReview.caseRecord.Statement__c == null){
                   applicationReview.caseRecord.Statement__c = '';
                }
                
                applicationReview.caseRecord.Statement__c += statement.substringBetween(NYSUN_Helper.PAYMENT_ASSIGNMENT_START_TAG, 
                                                     NYSUN_Helper.PAYMENT_ASSIGNMENT_END_TAG);
              }
            }
        }
        
        List<Project_Role__c> customerList = NYSUN_APPINTAKE_CustomerContacts_Service.getCustomerProjectRoleList(projectId);
        for(Project_Role__c customer : customerList) {
            if(customer.Primary_Customer_Contact__c) {
                applicationReview.primaryCustomer = customer.FirstName__c + ' ' + customer.LastName__c;
                break;
            }
        }
        
        for(Project_Site__c site : [SELECT Id, Address_1__c, City__c,
                                  County__c, Utility_Sector__c, Metering_Method__c,
                                  Utility_Company__c, Utility_Subsector__c,
                                  State__c, Zip__c FROM Project_Site__c
                                  WHERE Project__c =: CORE_Helper.doEscapeSingleQuotes(projectId)]){
                
            applicationReview.site = site;
        }
        */
        return applicationReview;
    }
    
    
    public class ApplicationReviewWrapper{
        
        public String program{get; set;}
        
        public Project__c project{get; set;}
        
        public Project_Site__c site{get; set;}
        
        public boolean isNewBuildingType{get; set;}
        
        public boolean isExistingBuildingType{get; set;}
        public String primaryCustomer {get; set;}
        
        public String companyName {get; set;}
        
        public Case caseRecord{get; set;}
        
        public ApplicationReviewWrapper(){
            
            project = new Project__c();
            
            site = new Project_Site__c();
            
            caseRecord = new Case();
            
            program = '';
            
            isExistingBuildingType = false;
            
            isNewBuildingType = false;
            primaryCustomer = '';
            companyName = '';
        }
    }
}