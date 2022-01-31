public interface EEC_AssistantInterface {
  // Variables
  Licensing_Transaction__c getBaseLicenseTransaction();
  String getBaseLicenseRecordTypeName();
  // Methods
  void updateAssistantWrapperList(List<EEC_AssistantListCtrl.AssistantInfoWrap> providerAssistantWrappers);
}