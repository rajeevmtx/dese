/**
 * PSR_InspectionWrapper 
 * Created By : Anand
 */
public class PSR_InspectionWrapper {
    @AuraEnabled public String inspectionId {set;get;}
    @AuraEnabled public String inspectionNumber {set;get;}
    @AuraEnabled public DateTime startDate {set;get;}
    @AuraEnabled public String inspectorName {set;get;}
    @AuraEnabled public DateTime endDate {set;get;}
    @AuraEnabled public String inspectionName {Set;get;}
    @AuraEnabled public String applicationNumber {set;get;}
    @AuraEnabled public List<InspectionItem> inspectionItemsList   {Set;get;}
    @AuraEnabled public List<PSR_PickListWrapper>  categoryList {set;get;}
    
    
    public class InspectionItem {
        @AuraEnabled public String category {set;get;}
        @AuraEnabled public List<Inspection_Item__c> inspectionItems {set;get;}
        @AuraEnabled public String  inspectionItemVariance {Set;get;}
        @AuraEnabled public Boolean hasNonCompliant {Set;get;}
        public InspectionItem(){
            category = '';
            inspectionItems = new List<Inspection_Item__c>();
            inspectionItemVariance = '';
            hasNonCompliant = false;
        }
    }
    public PSR_InspectionWrapper(){
        inspectionId = '';
        inspectionName = '';
        applicationNumber = '' ;
        categoryList = new List<PSR_PickListWrapper>();
        inspectionNumber = '';
        startDate =  null;
        endDate = null;
        inspectorName = '';
        inspectionItemsList = new List<InspectionItem>();
         
    }
    
}