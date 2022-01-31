public with sharing class PSR_PickListWrapper {
    @AuraEnabled public String label {set;get;}
    @AuraEnabled public String value {set;get;}
    public PSR_PickListWrapper(String label,String value) {
      this.label = label;
      this.value = value;  
    }
}