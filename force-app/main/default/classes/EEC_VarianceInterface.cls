public interface EEC_VarianceInterface {
  // Variables
  Licensing_Transaction__c getBaseLicenseTransaction();
  String getBaseLicenseRecordTypeName();
  // Methods
  void updateVarianceWrapperList(List<EEC_VarianceListCtrl.VarianceInfoWrap> varianceInfoWrappers);
}