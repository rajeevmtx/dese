public with sharing class EEC_DifferentialLifecycleFlowController {
    public String provRecordType        {get; set;}
    public String nextDifferentialStep  {get; set;}
    public Boolean isLicensed           {get; set;}
    private Account provider;
    public EEC_DifferentialLifecycleFlowController(ApexPages.StandardController sc) {
        this.provider = (Account)sc.getRecord();
        provider = [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, First_Issue_Date__c, License_Status__c
                , Differential_Licensing_Lifecycle__c, Last_Renewal_Visit_Reason__c
                , Previous_Licensing_Visit_Reason__c
                , is_GSA__c, is_R_P__c
        FROM Account WHERE id =: provider.id];
        this.provRecordType = provider.RecordType.DeveloperName;
        this.isLicensed = provider.License_Status__c == EEC_Constants.PRO_LICENSED;
        if(provider.is_GSA__c){
            this.provRecordType = 'GSA';
        } else if(provider.is_R_P__c){
            this.provRecordType = 'R_P';
        }
        this.nextDifferentialStep = '.defaultNextStep'; //Setting a default value which will then be updated. Qamar
        if(provRecordType == EEC_Constants.PRO_FCC && isLicensed){
            if (provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_RENEWAL_ENHANCED_MONITORING){
                nextDifferentialStep = '.renewalEnhancedMonitoring';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_RENEWAL_FULL_REVIEW){
                nextDifferentialStep = '.renewalFullReview';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_PROGRESS){
                if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_PROGRESS){
                    nextDifferentialStep = '.progress2';
                } else
                        nextDifferentialStep = '.progress1';

            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_MONITORING){
                if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_MONITORING && provider.Last_Renewal_Visit_Reason__c == EEC_Constants.VISIT_TYPE_RENEWAL_FULL_REVIEW){
                    nextDifferentialStep = '.monitoring2';
                } else if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_MONITORING && provider.Last_Renewal_Visit_Reason__c == EEC_Constants.VISIT_TYPE_RENEWAL_ENHANCED_MONITORING){
                    nextDifferentialStep = '.monitoring4';
                } else if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_RENEWAL_FULL_REVIEW){
                    nextDifferentialStep = '.monitoring1';
                } else {
                    nextDifferentialStep = '.monitoring3';
                }
            }
        }

        if(provRecordType == 'GSA' && isLicensed){
            if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_ENHANCED_MONITORING){
                nextDifferentialStep = '.enhancedMonitoring';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_PROVISIONAL_90_DAY_MONITORING){//Modified by KB
                nextDifferentialStep = '.monitoring90day';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_PROVISIONAL_LICENSE_RENEWAL){
                nextDifferentialStep = '.provisional';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_RENEWAL_FULL_REVIEW){
                nextDifferentialStep = '.renewalFullReview';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_RENEWAL_MONITORING){
                if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_ENHANCED_MONITORING){
                    nextDifferentialStep = '.monitoring3';
                } else {
                    nextDifferentialStep = '.monitoring2';
                }
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_MONITORING){
                if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_RENEWAL_FULL_REVIEW
                        || provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_PROVISIONAL_LICENSE_RENEWAL
                        || provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_PRE_LICENSING){
                    nextDifferentialStep = '.monitoring1';
                } else if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_RENEWAL_MONITORING){
                    nextDifferentialStep = '.monitoring4';
                }

            }
        }

        if(provRecordType == 'R_P' && isLicensed){
            if (provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_RENEWAL_ENHANCED_MONITORING){
                nextDifferentialStep = '.renewalEnhancedMonitoring';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_RENEWAL_FULL_REVIEW){
                nextDifferentialStep = '.renewalFullReview';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_PROVISIONAL_LICENSE_RENEWAL){
                nextDifferentialStep = '.provisional';
            } else if(provider.Differential_Licensing_Lifecycle__c == EEC_Constants.VISIT_TYPE_MONITORING){
                if(provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_RENEWAL_FULL_REVIEW
                        || provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_PROVISIONAL_LICENSE_RENEWAL
                        || provider.Previous_Licensing_Visit_Reason__c == EEC_Constants.VISIT_TYPE_PRE_LICENSING){ //Modified by KB
                    nextDifferentialStep = '.monitoring1';
                } else {
                    nextDifferentialStep = '.monitoring2';
                }
            }
        }

    }
}