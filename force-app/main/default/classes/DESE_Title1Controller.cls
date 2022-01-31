public class DESE_Title1Controller {

    @AuraEnabled
    public static TitleADWrapper getProposalDetails(String projectId){
        try {
            Project__c project = [SELECT Id,
                                    Title1SpecificActivities__c,
                                    Title1GradeServed__c,
                                    Title1ProgressAttainment__c,
                                    Title1SpecifyOther__c,
                                    Title1FacilityName__c,
                                    Title1ContactName__c,
                                    Title1PhoneNumber__c,
                                    Title1EmailAddress__c,
                                    Title1FormalAgreement__c,
                                    Title1AssessmentNeeds__c,
                                    Title1Districtdetermined__c,
                                    Title1OtherIncomeSource__c,
                                    Title1OtherQualification__c,
                                    Tile1DataPromptedActivity__c,
                                    Title1Agreement_Information__c,
                                    Tile1Equitable_participation__c,
                                    Title1Family_Engagement__c,
                                    Title1ServiceslocalInstitution__c,
                                    Title1Administrative_services__c,
                                    Title1Serviceshomeless__c,
                                    Title1Fostercare__c,
                                    Title1Indirect_costs__c,
                                    Title1MTRS__c,
                                    Title1ReservationOther__c,
                                    Title1LowIncomeChildren__c,
                                    Title1Below35__c,
                                    Title1Above35__c,
                                    Title1At35__c,
                                    Title1LowIncome__c,
                                    Title1OtherQualifyingMethod__c,
                                    Post_flexing_funds_for_use_per_Title_I__c
                                    FROM Project__c WHERE Id =: projectId];

            TitleADWrapper wrapper = new TitleADWrapper();
            wrapper.specificActivities = project.Title1SpecificActivities__c;
            wrapper.grades = project.Title1GradeServed__c;
            wrapper.attainmentGoals = project.Title1ProgressAttainment__c;
            wrapper.specifyOthers = project.Title1SpecifyOther__c;
            wrapper.facilityName = project.Title1FacilityName__c;
            wrapper.contactName = project.Title1ContactName__c;
            wrapper.phone = project.Title1PhoneNumber__c;
            wrapper.email = project.Title1EmailAddress__c;
            wrapper.formalAgreement = project.Title1FormalAgreement__c;
            wrapper.Title1AssessmentNeeds = project.Title1AssessmentNeeds__c;
            wrapper.Title1Districtdetermined = project.Title1Districtdetermined__c;
            wrapper.Title1OtherIncomeSource = project.Title1OtherIncomeSource__c;
            wrapper.Title1OtherQualification = project.Title1OtherQualification__c;
            wrapper.dataActivityValues = project.Tile1DataPromptedActivity__c;
            wrapper.agreementValues = project.Title1Agreement_Information__c ;
            wrapper.Tile1Equitable_participation = project.Tile1Equitable_participation__c;
            wrapper.Title1Family_Engagement = project.Title1Family_Engagement__c;
            wrapper.Title1ServiceslocalInstitution = project.Title1ServiceslocalInstitution__c;
            wrapper.Title1Administrative_services = project.Title1Administrative_services__c;
            wrapper.Title1Serviceshomeless = project.Title1Serviceshomeless__c;
            wrapper.Title1Fostercare = project.Title1Fostercare__c;
            wrapper.Title1Indirect_costs = project.Title1Indirect_costs__c;
            wrapper.Title1MTRS= project.Title1Indirect_costs__c;
            wrapper.Title1ReservationOther = project.Title1ReservationOther__c;
            wrapper.Title1LowIncomeChildren = project.Title1LowIncomeChildren__c;
            wrapper.Title1Below35 = project.Title1Below35__c;
            wrapper.Title1Above35= project.Title1Above35__c;
            wrapper.Title1At35= project.Title1At35__c;
            wrapper.Title1LowIncome = project.Title1LowIncome__c;
            wrapper.Title1OtherQualifyingMethod = project.Title1OtherQualifyingMethod__c;
            wrapper.totalFunding = project.Post_flexing_funds_for_use_per_Title_I__c;
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static string saveProposalDetails(String proposalId, String wrapperString){
        try {
            TitleADWrapper wrapper = (TitleADWrapper) JSON.deserialize(wrapperString, TitleADWrapper.class);
            Project__c project = new Project__c(Id = proposalId);
            project.Title1SpecificActivities__c = (String)wrapper.specificActivities;
            project.Title1GradeServed__c = (String)wrapper.grades;
            project.Title1ProgressAttainment__c = (String)wrapper.attainmentGoals;
            project.Title1SpecifyOther__c = (String)wrapper.specifyOthers;
            project.Title1FacilityName__c = (String) wrapper.facilityName;
            project.Title1ContactName__c = (String) wrapper.contactName;
            project.Title1PhoneNumber__c = (String) wrapper.phone;
            project.Title1EmailAddress__c = (String) wrapper.email;
            project.Title1FormalAgreement__c = (String) wrapper.formalAgreement;
            project.Tile1DataPromptedActivity__c = (String) wrapper.dataActivityValues;
            project.Title1Agreement_Information__c = (String) wrapper.agreementValues;
            
            update project;
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Failed to update project'+e);
            return 'Error';
           // throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static string saveProposalReservationDetails(String proposalId, String wrapperString){
        try {
            TitleADWrapper wrapper = (TitleADWrapper) JSON.deserialize(wrapperString, TitleADWrapper.class);
            Project__c project = new Project__c(Id = proposalId);
            project.Title1AssessmentNeeds__c = (String)wrapper.Title1AssessmentNeeds;
            project.Title1Districtdetermined__c = (String)wrapper.Title1Districtdetermined;
            project.Tile1Equitable_participation__c = (Decimal) wrapper.Tile1Equitable_participation;
            project.Title1Family_Engagement__c=(Decimal) wrapper.Title1Family_Engagement;
            project.Title1ServiceslocalInstitution__c=(Decimal) wrapper.Title1ServiceslocalInstitution;
            project.Title1Administrative_services__c=(Decimal) wrapper.Title1Administrative_services;
            project.Title1Serviceshomeless__c=(Decimal) wrapper.Title1Serviceshomeless;
            project.Title1Fostercare__c=(Decimal) wrapper.Title1Fostercare;
            project.Title1Indirect_costs__c=(Decimal) wrapper.Title1Indirect_costs;
            project.Title1MTRS__c=(Decimal) wrapper.Title1MTRS;
            project.Title1ReservationOther__c=(Decimal) wrapper.Title1ReservationOther;
            project.Title1LowIncomeChildren__c=(Decimal) wrapper.Title1LowIncomeChildren;
            project.Title1Below35__c=(Decimal) wrapper.Title1Below35;
            project.Title1Above35__c=(Decimal) wrapper.Title1Above35;
            project.Title1At35__c=(Decimal) wrapper.Title1At35;

            update project;
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Failed to update project'+e);
            return 'Error';
           // throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string saveProposalSchoolDetails(String proposalId, String wrapperString){
        try {
                TitleADWrapper wrapper = (TitleADWrapper) JSON.deserialize(wrapperString, TitleADWrapper.class);
                Project__c project = new Project__c(Id = proposalId);
                project.Title1OtherIncomeSource__c = (String)wrapper.Title1OtherIncomeSource;
                project.Title1OtherQualification__c = (String)wrapper.Title1OtherQualification;
                project.Title1LowIncome__c =(String) wrapper.Title1LowIncome;
                project.Title1OtherQualifyingMethod__c =(String) wrapper.Title1OtherQualifyingMethod;
            
                update project;
                return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Failed to update project'+e);
            return 'Error';
           // throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static AllocationWrapper getAllocationReservation(String proposalId){
        try {

            Project__c project = [SELECT Id,Total_Allocation_Title_I_Part_A__c,Total_Allocation_Title_II_Part_A__c,
            Total_Allocation_Title_III_Part_A__c,Total_Allocation_Title_IV_Part_A__c,Post_flexing_funds_for_use_per_Title_I__c
            ,Post_flexing_funds_for_use_per_Title_II__c,Post_flexing_funds_for_use_per_Title_III__c,Post_flexing_funds_for_use_per_Title_IV__c,
            Title_II_direct_administrative_expenses__c,Title_III_direct_administrative_expenses__c,Title_IV_direct_administrative_expenses__c
             FROM Project__c WHERE Id =: proposalId];

            AllocationWrapper wrapper = new AllocationWrapper();
            wrapper.tile1Allocation = project.Total_Allocation_Title_I_Part_A__c;
            wrapper.tile2Allocation = project.Total_Allocation_Title_II_Part_A__c;
            wrapper.tile3Allocation = project.Total_Allocation_Title_III_Part_A__c;
            wrapper.tile4Allocation= project.Total_Allocation_Title_IV_Part_A__c;
            wrapper.tile1Reservation= project.Post_flexing_funds_for_use_per_Title_I__c;
            wrapper.tile2Reservation = project.Post_flexing_funds_for_use_per_Title_II__c;
            wrapper.tile3Reservation = project.Post_flexing_funds_for_use_per_Title_III__c;
            wrapper.tile4Reservation = project.Post_flexing_funds_for_use_per_Title_IV__c;
            wrapper.tile2Reservation2 = project.Title_II_direct_administrative_expenses__c;
            wrapper.tile3Reservation3 = project.Title_III_direct_administrative_expenses__c;
            wrapper.tile4Reservation4 = project.Title_IV_direct_administrative_expenses__c;

            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class TitleADWrapper{
        @AuraEnabled
        public String specificActivities;
        @AuraEnabled
        public String grades;
        @AuraEnabled
        public String attainmentGoals;
        @AuraEnabled
        public String specifyOthers;
        @AuraEnabled
        public String facilityName;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String formalAgreement;
        @AuraEnabled
        public String Title1AssessmentNeeds;
        @AuraEnabled
        public String Title1Districtdetermined;
        @AuraEnabled
        public String Title1OtherIncomeSource;
        @AuraEnabled
        public String Title1OtherQualification;
        @AuraEnabled
        public String dataActivityValues;
        @AuraEnabled
        public String agreementValues;
        @AuraEnabled
        public Decimal Tile1Equitable_participation;
        @AuraEnabled
        public Decimal Title1Family_Engagement;
        @AuraEnabled
        public Decimal Title1ServiceslocalInstitution;
        @AuraEnabled
        public Decimal Title1Administrative_services;
        @AuraEnabled
        public Decimal Title1Serviceshomeless;
        @AuraEnabled
        public Decimal Title1Fostercare;
        @AuraEnabled
        public Decimal Title1Indirect_costs;
        @AuraEnabled
        public Decimal Title1MTRS;
        @AuraEnabled
        public Decimal Title1ReservationOther;
        @AuraEnabled
        public Decimal Title1LowIncomeChildren;
        @AuraEnabled
        public Decimal Title1Below35;
        @AuraEnabled
        public Decimal Title1Above35;
        @AuraEnabled
        public Decimal Title1At35;
        @AuraEnabled
        public String Title1LowIncome;
        @AuraEnabled
        public String Title1OtherQualifyingMethod;
        @AuraEnabled
        public Decimal totalFunding;
    }

    public class AllocationWrapper{
        @AuraEnabled
        public Decimal tile1Allocation;
        @AuraEnabled
        public Decimal tile2Allocation;
        @AuraEnabled
        public Decimal tile3Allocation;
        @AuraEnabled
        public Decimal tile4Allocation;
        @AuraEnabled
        public Decimal tile1Reservation;
        @AuraEnabled
        public Decimal tile2Reservation;
        @AuraEnabled
        public Decimal tile3Reservation;
        @AuraEnabled
        public Decimal tile4Reservation;
        @AuraEnabled
        public Decimal tile2Reservation2;
        @AuraEnabled
        public Decimal tile3Reservation3;
        @AuraEnabled
        public Decimal tile4Reservation4;
        
    }
}