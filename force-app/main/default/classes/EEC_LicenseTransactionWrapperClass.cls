public with sharing class EEC_LicenseTransactionWrapperClass {
    public Licensing_Transaction__c transRec    { get; set; }
    public boolean showAddContactsButton        { get; set; }
    public EEC_LicenseTransactionWrapperClass(Licensing_Transaction__c transRec, boolean showAddContactsButton) {
        this.transRec = transRec;
        this.showAddContactsButton = showAddContactsButton;
    }
}