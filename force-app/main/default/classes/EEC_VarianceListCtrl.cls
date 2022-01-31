/**
 * EEC_VarianceListCtrl
 *
 * @author Latha Davuluri
 * @description A view model controller for all view logic retaining to the Variance Information for a given Transaction.
 * @created 17 Jan 2017
*/
public class EEC_VarianceListCtrl {


  public EEC_VarianceInterface vif { get; set; }
  public Account mAccount { get; set; }
  public Regulation__c mRegulation {get; set;}
  public string programRecordType  { get; set; }
  public id providerId {get;set;}
  public String introText { get;set; }
  public string queryString{get;set;}
  public string providerRecordType{get;set;}
  public boolean showError{get;set;}
  public Boolean mPopulateUsingAccount { get; set; }
  public string varianceQueryString{get;set;}
  public Licensing_Transaction__c licTransRec {get;set;}
  public String selectedRegulationIds{get; set;}
  //public List<VarianceInfoWrap> VariancesList {get;set;}
   
  //private List<Variance_on_Regulation__c> varianceRegs { get; set; }
  private List<VarianceInfoWrap> varianceInfoWrappers { get; set; }
  private Licensing_Transaction__c mNewestTransaction { get; set; }

  public EEC_VarianceListCtrl() {
    
    String ltId = ApexPages.currentPage().getParameters().get('ltId');
    system.debug('**'+ ltId);
    system.debug('----> EEC_VarianceListCtrl Enter');
    if(ltId != null){
        for(Licensing_Transaction__c lt: [SELECT Id,Name,Provider__c,Provider__r.RecordType.Name
                                            FROM Licensing_Transaction__c
                                            WHERE Id =: ltId]){
            providerRecordType = lt.Provider__r.RecordType.Name;
            licTransRec = lt;
        }
    }
    showError = false;
  }

  /**
   * getVariancesList
   *
   * @description This function will gather the variances for the view based on the current transaction.
   * @author Latha Davuluri
   * @created 17 Jan 2017
   * @return List<Variance_on_Regulation__c> 
   */
  public List<VarianceInfoWrap> getVariancesList() {
    if(mPopulateUsingAccount == null)
        mPopulateUsingAccount = false;
        system.debug('****mPopulateUsingAccount ****'+mPopulateUsingAccount);
    // If the provider variances already have been populated then simply return them.
    if (varianceInfoWrappers != null && varianceInfoWrappers.size() > 0) {
      // Update the upper class list.
      if (vif != null) {
        vif.updateVarianceWrapperList(varianceInfoWrappers);
        system.debug('****varianceInfoWrappers****'+varianceInfoWrappers);
        programRecordType = vif.getBaseLicenseRecordTypeName();
        providerId = vif.getBaseLicenseTransaction().Provider__c;
        system.debug('****programRecordType****'+programRecordType);
      }
      return varianceInfoWrappers;
     
    } else {
      varianceInfoWrappers = new List<VarianceInfoWrap> ();
      // Fetch the provider assistants for the current provider.
      // If the Assistant Interface is present then use the shared transaction object.
      if (vif != null && vif.getBaseLicenseTransaction() != null) {
        populateVariancesListWithTransaction();
        // Update the upper class list.
        vif.updateVarianceWrapperList(varianceInfoWrappers);
        programRecordType = vif.getBaseLicenseRecordTypeName();
        providerId = vif.getBaseLicenseTransaction().Provider__c;
      } 
      else if (mPopulateUsingAccount) {
        populateVariancesListUsingAccount();
        system.debug('****programRecordType****'+programRecordType);
      }
      else {
          if(mAccount!=null){
              populateVariancesList();
              system.debug('****programRecordType****'+programRecordType);
          }
      }
    }
    system.debug('----> varianceInfoWrappers: ' + varianceInfoWrappers);
    // Return to the page.
    return varianceInfoWrappers;
  }

    
  @TestVisible   
  private void populateVariancesListWithTransaction() {
    try {
    //system.assert(false,vif.getBaseLicenseTransaction().Id);
      List<Variance_on_Regulation__c> varianceRegs = 
          [SELECT Id, Associated_Regulation__r.Name, Associated_Regulation__r.Regulation_Number__c, ProviderType__c, Associated_Regulation__r.Article__c, Provider_Alternative_Method_to_Comply__c, Provider_Understanding_of_Regulation__c,isCopied__c  
           From Variance_on_Regulation__c 
           Where Provider__c = :vif.getBaseLicenseTransaction().Provider__c AND 
           Source_Transaction__c = :vif.getBaseLicenseTransaction().Id 
           ];
      // If the license type is NOT New License or Change of Admin Authority we need to copy over the lastest new transactions items. 
      system.debug('#########recordtype##########'+ vif.getBaseLicenseRecordTypeName());
      if ((vif.getBaseLicenseRecordTypeName().toLowerCase().contains('new_license') == false) && (vif.getBaseLicenseRecordTypeName().toLowerCase().contains('change_of_admin') == false)){
            Boolean variancesAlreadyTransferred = false;
            // Loop through the existing items and see if one has already been copied for the transaction.
            for (Variance_on_Regulation__c variance : varianceRegs) {
              if (variance.isCopied__c) {
                variancesAlreadyTransferred = true;
                break;
              }
            }
            // If none have been transfered.
            /*if (!variancesAlreadyTransferred) {
              List<Variance_on_Regulation__c> latestNewTransVariancesList = [SELECT Id, Associated_Regulation__r.Name, Associated_Regulation__r.Regulation_Number__c, Associated_Regulation__r.Article__c, ProviderType__c, Provider_Alternative_Method_to_Comply__c, Provider_Understanding_of_Regulation__c, isCopied__c  
                                                                               From Variance_on_Regulation__c 
                                                                               Where Provider__c = :vif.getBaseLicenseTransaction().Provider__c 
                                                                            ]; 
                                                                              // ORDER BY Start_Date__c DESC NULLS FIRST];
              for (Variance_on_Regulation__c variance : latestNewTransVariancesList) {
                variance.isCopied__c = true;
                varianceInfoWrappers.add(new VarianceInfoWrap(variance, false));
              }
            }*/
          }
          
          
          // Place the ones specific to the transaction in this wrapper.  
          for (Variance_on_Regulation__c varianceReg : varianceRegs) {
            varianceInfoWrappers.add(new VarianceInfoWrap(varianceReg, false));
          }
        } catch(DMLException e) {
            system.debug('-----> Error with getVariancesList => populateVariancesListWithTransaction: ' + e.getMessage());
        }
  }
  
  private void populateVariancesList() {
    try {
      List<Variance_on_Regulation__c> varianceRegs = [Select Id, Associated_Regulation__r.Name, Associated_Regulation__r.Regulation_Number__c, Associated_Regulation__r.Article__c, ProviderType__c,Provider_Alternative_Method_to_Comply__c, Provider_Understanding_of_Regulation__c 
                                                             From Variance_on_Regulation__c
                                                             Where Provider__c = :mAccount.Id
                                                           
                                                             ];
      // Place the ones specific to the transaction in this wrapper.  
      for (Variance_on_Regulation__c varianceReg : varianceRegs) {
        varianceInfoWrappers.add(new VarianceInfoWrap(varianceReg, false));
      }
      programRecordType = mAccount.Record_Type_Name__c;
    } catch(DMLException e) {
      System.debug('-----> Error with getVariancesList: ' + e.getMessage());
    }
  }

  private void populateVariancesListUsingAccount() {
    try {
      List<Variance_on_Regulation__c> varianceRegs = [Select Id, Associated_Regulation__r.Name, Associated_Regulation__r.Regulation_Number__c, Associated_Regulation__r.Article__c, ProviderType__c,Provider_Alternative_Method_to_Comply__c, Provider_Understanding_of_Regulation__c,
                                                             Decision__c, Decision_Rationale__c, Brief_explanation_for_license__c
                                                             From Variance_on_Regulation__c
                                                             Where Provider__c = :mAccount.Id
                                                            
                                                             ];
      // Place the ones specific to the transaction in this wrapper.  
      for (Variance_on_Regulation__c varianceReg : varianceRegs) {
        varianceInfoWrappers.add(new VarianceInfoWrap(varianceReg, false));
      }
      if (varianceRegs.size() > 0){
         programRecordType = varianceRegs[0].ProviderType__c;
      }
    } catch(DMLException e) {
      System.debug('-----> Error with getVariancesList: ' + e.getMessage());
    }
  }

  /**
   * getAssistantsListCount
   *
   * @description This function will determine if the assistant list has more than 0 rows. 
   * @author Darkis
   * @created 27 Jan 2016
   * @return Boolean 
   */
  public Boolean getVariancesListCount() {
    system.debug('----> List count Enter');
    if (varianceInfoWrappers != null) {
        system.debug('****1*****');
      return(varianceInfoWrappers.size() > 0 ? true : false);
    } else {
        system.debug('****2*****');
      // IF the Interface is provided then proceed.
      if (vif != null && vif.getBaseLicenseTransaction() != null) {
        system.debug('****3*****');
        if ([SELECT Count() FROM Variance_on_Regulation__c 
             WHERE Provider__c = :vif.getBaseLicenseTransaction().Provider__c 
             AND Source_Transaction__c = :vif.getBaseLicenseTransaction().Id] > 0) {
                system.debug('****4*****');
          return true;
        } else if ([SELECT Count() FROM Variance_on_Regulation__c 
                    WHERE Provider__c = :vif.getBaseLicenseTransaction().Provider__c 
                    
                    ] > 0) {
                        system.debug('****4*****');
          return true;
        }
        system.debug('****5*****');
        programRecordType = vif.getBaseLicenseRecordTypeName();
        system.debug('****programRecordType****'+programRecordType);
        providerId = vif.getBaseLicenseTransaction().Provider__c;
        system.debug('****providerId****'+providerId);
      } else {
        system.debug('****6*****');
        if ([SELECT Count() FROM Variance_on_Regulation__c WHERE Provider__c = :mAccount.Id 
       
        ] > 0) {
            
          return true;
        }
      }
    }
    return false;
  }

  /**
   * removeAddedVariance
   *
   * @description This function will remove from the wrapper list the passed in object id. This is only intended for newly added objects.
   * @author Latha Davuluri
   * @created 19 Jan 2017
   */
  public void removeAddedVariance() {
    String wrapperId = ApexPages.currentPage().getParameters().get('wrapperId');
    system.debug('----> wrapperId: ' + wrapperId);
    system.debug('----> varianceInfoWrappers: ' + varianceInfoWrappers);
    Integer wrapperIndex;

    for (Integer i = 0; i < varianceInfoWrappers.size(); i++) {
      VarianceInfoWrap varianceWrap = varianceInfoWrappers.get(i);

      if (wrapperId.equalsIgnoreCase(String.valueOf(varianceWrap.wrapperId))) {
        wrapperIndex = i;
        break;
      }
    }

    if (wrapperIndex != null) {
      try {
        varianceInfoWrappers.remove(wrapperIndex);
      } catch(Exception e) {
        system.debug('----> Could not remove index from Variance varianceInfoWrappers: ' + e.getMessage());
      }
    }
  }
  

  /**
   * addVariancesToList
   *
   * @description This function will add the new variance from the popup to the list.
   * @author Latha Davuluri
   * @created 18 Jan 2017
   * @return PageReference 
   */
  public PageReference addVarianceToList() {
    String regulationId = ApexPages.currentPage().getParameters().get('regulationId');
    
    List<String> tempList = new List<String>();

    if(String.isNotBlank(selectedRegulationIds)){
        tempList.addAll(selectedRegulationIds.split(';'));
    }
    
    // This will retrieve the assistant information needed for the view. Sadly we have no way of attaching this to the object directly without inserting.
    // TODO: Ensure that the assistant has an VIF before attempting to use it. 
    
    for(Regulation__c regInfo : [Select Id, Name, Regulation_Number__c, Article__c  From Regulation__c Where Id IN :tempList]){
         // Create the new wrapper. 
        Variance_on_Regulation__c tempVarianceReg = new Variance_on_Regulation__c(Associated_Regulation__c = regInfo.Id);
    
        if (vif != null && vif.getBaseLicenseTransaction() != null) {
          tempVarianceReg.Provider__c = vif.getBaseLicenseTransaction().Provider__c;
          tempVarianceReg.Source_Transaction__c = vif.getBaseLicenseTransaction().Id;
        } else {
          tempVarianceReg.Provider__c = mAccount.Id;
        }
        
        VarianceInfoWrap newVarianceWrapper = new VarianceInfoWrap(tempVarianceReg, true, regInfo);
        newVarianceWrapper.varianceReg.recalculateFormulas();
        
        Integer counter = 0;
        if (varianceInfoWrappers != null && varianceInfoWrappers.size() > 0) {
          // Determine the new wrapper ID to set for this new entry.
          for (VarianceInfoWrap wrapper : varianceInfoWrappers) {
            if (wrapper.isNew) {
              counter++;
            }
          }
        }
        newVarianceWrapper.wrapperId = counter + 1;
    
        if (varianceInfoWrappers == null) {
          varianceInfoWrappers = new List<VarianceInfoWrap> ();
        }
        varianceInfoWrappers.add(newVarianceWrapper);
    }

    return null;
  }


  /**
   * getNewestTransaction
   *
   * @description This function will get the newest transaction based on criteia to copy over any exisiting variances for upgrades. 
   * @author Latha Davuluri
   * @created 18 Jan 2017
   * @return Licensing_Transaction__c 
   */
  public Licensing_Transaction__c getNewestTransaction() {
    if (mNewestTransaction != null) {
      return mNewestTransaction;
    } else {
      List<Licensing_Transaction__c> tempTrans =
      [
      Select
      Id, Name, RecordType.DeveloperName, Provider__c, Status__c, LastModifiedDate
      From Licensing_Transaction__c
      Where Provider__c = :vif.getBaseLicenseTransaction().Provider__c
      AND Status__c IN('Submitted', 'Unsubmitted', 'Under Review')
      ORDER BY LastModifiedDate DESC LIMIT 1
      ];
      mNewestTransaction = (tempTrans != null && tempTrans.size() == 1 ? tempTrans.get(0) : null);
    }
    system.debug('----> mNewestTransaction: ' + mNewestTransaction);
    return mNewestTransaction;
  }

    public Class SearchVarianceWrapper{
        public boolean isChecked{get;set;}
        public Regulation__c regRec {get;set;}
        
        public SearchVarianceWrapper(Regulation__c regRec){
            isChecked = false;
            this.regRec = regRec;
        }
        
    }
  /**
   * VarianceInfoWrap
   * 
   * @description This wrapper class will allow us to know which variances have just been added vs pre-populated.
   * @author Latha Davuluri
   * @created 18 Jan 2017
   */
  public class VarianceInfoWrap implements Comparable {

    public Variance_on_Regulation__c varianceReg { get; set; }
    public Regulation__c regInfo { get; set; }
    public Boolean isNew { get; set; }
    public Integer wrapperId { get; set; }

    public VarianceInfoWrap(Variance_on_Regulation__c varianceReg, Boolean isNew) {
      this.varianceReg = varianceReg;
      this.isNew = isNew;
    }

    public VarianceInfoWrap(Variance_on_Regulation__c varianceReg, Boolean isNew, Regulation__c regInfo) {
      this.varianceReg = varianceReg;
      this.isNew = isNew;
      this.regInfo = regInfo;
    }

   
    // Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      VarianceInfoWrap compareToObj = (VarianceInfoWrap) compareTo;

      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (varianceReg.Associated_Regulation__r.Regulation_Number__c == compareToObj.varianceReg.Associated_Regulation__r.Regulation_Number__c) {
        return 0;
      } else if (varianceReg.Associated_Regulation__r.Regulation_Number__c == null && compareToObj.varianceReg.Associated_Regulation__r.Regulation_Number__c != null) {
        returnValue = 1;
      } else if (varianceReg.Associated_Regulation__r.Regulation_Number__c != null && compareToObj.varianceReg.Associated_Regulation__r.Regulation_Number__c == null) {
        returnValue = - 1;
      } 
      return returnValue;
    }
   
  }
}