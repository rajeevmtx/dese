public class PsrCalendarController {
    
    @AuraEnabled
    public static list<InspectionWrapper> fetchInspections(){
        List<InspectionWrapper> inspectionWrapperList = new List<InspectionWrapper>();
        User usrRec = [SELECT Id, Username, LastName, IsPortalEnabled ,FirstName, Name,contactId FROM User where Id =: userinfo.getuserid()];
        if(usrRec.IsPortalEnabled){
            for(Application_Work_Order__c appWorkOrderRec : [SELECT ID,Name,Work_Order_Name__c,Application__c,Application__r.Name,Application__r.City__c,Application__r.State__c,Application__r.Street__c,Application__r.Zip__c,
                                                             (SELECT ID,Name,Inspection_Start_Date__c ,Inspection_End_Date__c ,Inspection_Status__c, Inspector__r.FirstName, Inspector__r.LastName FROM Inspections__r WHERE Inspection_Start_Date__c != null AND Inspection_End_Date__c != null LIMIT 1) 
                                                             FROM Application_Work_Order__c 
                                                             WHERE CreatedById =: UserInfo.getUserId() 
                                                             OR Application_Contact__r.Contact__c =:  usrRec.contactId])
            												{
                                                                 if(appWorkOrderRec.Inspections__r.size() > 0){
                                                                     inspectionWrapperList.add(new InspectionWrapper(appWorkOrderRec,appWorkOrderRec.Inspections__r.get(0)));
                                                                 }
                                                             }  
        }
        else{
            system.debug('**'+ 'From other loop');
            for(Application_Work_Order__c appWorkOrderRec : [SELECT ID,Name,Work_Order_Name__c,Application__c,Application__r.Name,Application__r.City__c,Application__r.State__c,Application__r.Street__c,Application__r.Zip__c,
                                                             (SELECT ID,Name, Inspection_Start_Date__c ,Inspection_End_Date__c ,Inspection_Status__c, Inspector__r.FirstName, Inspector__r.LastName FROM Inspections__r WHERE Inspection_Start_Date__c != null AND Inspection_End_Date__c != null AND Inspector__c =: userinfo.getuserid() LIMIT 1) 
                                                             FROM Application_Work_Order__c]){
                                                                 if(appWorkOrderRec.Inspections__r.size() > 0){
                                                                     inspectionWrapperList.add(new InspectionWrapper(appWorkOrderRec,appWorkOrderRec.Inspections__r.get(0)));
                                                                 }
                                                             }  
            system.debug('**'+ 'From other loop');
        }
        system.debug('**'+inspectionWrapperList);
        return inspectionWrapperList;
    }
    
    @AuraEnabled
    public static boolean blockCalender(String inspectionId,Datetime inspectionStartDate ,Datetime inspectionEndDate){
        System.debug('inspectionStartDate-->'+inspectionStartDate+'----'+inspectionEndDate);
        boolean updateSuccess = true;
        
        //try{
            Inspection__c inspRec = (new Inspection__c(Id= inspectionId, Inspection_Status__c  = 'Scheduled',Inspection_Start_Date__c = inspectionStartDate , Inspection_End_Date__c = inspectionEndDate));            
            update inspRec;
        /*}catch(Exception e){
            updateSuccess = false;
        }*/
        return updateSuccess;
    }
    
    @AuraEnabled
    public static Inspection__c fetchInspectionsToSchedule(String inspectionId){
        Inspection__c inspection = [Select id,Name,Application_Work_Order__r.Name,Application_Work_Order__r.Work_Order_Name__c,Application_Work_Order__r.Work_Order_Type__c,Inspection_Start_Date__c ,Inspection_End_Date__c, Inspection_Status__c 
                                            FROM Inspection__c 
                                            WHERE Id =:inspectionId  Order By Createddate desc limit 1 ];
        return inspection;
    }
    
    public class InspectionWrapper {
        
        @AuraEnabled public ID inspectionId;
        @AuraEnabled public ID workOrderId;
        @AuraEnabled public ID applicationId;
        @AuraEnabled public String inspectorName;
        @AuraEnabled public String inspectionDate;
        @AuraEnabled public String inspectionStatus; 
        @AuraEnabled public String location; 
        @AuraEnabled public String inspectionName; 
        @AuraEnabled public String workOrderName;
        @AuraEnabled public Datetime inspectionStartDate;
        @AuraEnabled public Datetime inspectionEndDate;
        @AuraEnabled public String permitName;
        
        public InspectionWrapper(Application_Work_Order__c appWorkOrderRec,Inspection__c inspectionRec) {
            this.inspectionId = inspectionRec.Id;
            this.workOrderId = appWorkOrderRec.Id;
            this.applicationId = appWorkOrderRec.Application__c;
            this.workOrderName = appWorkOrderRec.Name;
            this.permitName = appWorkOrderRec.Application__r.Name;
            this.inspectionName = inspectionRec.Name;
            this.inspectorName = inspectionRec.Inspector__r.FirstName +' '+ inspectionRec.Inspector__r.LastName;
            this.inspectionStatus = inspectionRec.Inspection_Status__c;
            this.location = appWorkOrderRec.Application__r.Street__c + ' ' + appWorkOrderRec.Application__r.City__c + ' ' + appWorkOrderRec.Application__r.State__c + ' ' + appWorkOrderRec.Application__r.Zip__c;
            this.inspectionStartDate = inspectionRec.Inspection_Start_Date__c.addHours(-8);
            this.inspectionEndDate = inspectionRec.Inspection_End_Date__c.addHours(-8);
        }
    }
}