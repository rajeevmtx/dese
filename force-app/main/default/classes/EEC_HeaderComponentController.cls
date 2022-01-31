public without sharing class EEC_HeaderComponentController {
  	public string providerRecordId;
  	public string licenseRecordId;
  	public string accountId{get;set;}
  	public string unAuthRedirectURL{get;set;}
  	
  	public void initialize(){
  		if(unAuthRedirectURL == null || unAuthRedirectURL ==''){
  			Set<Id> setOfumbrellaMembermembersId = new Set<Id>();
  			licenseRecordId = ApexPages.currentPage().getParameters().get('ltId');
       		providerRecordId = ApexPages.currentPage().getParameters().get('member');
  		// Avoid 15 vs 18 digit issue
	  		Id accountIdVal, providerRecordIdVal;
	  		String recordTypeName;
			List<Account> tempAccount = [Select Id,OwnerID,RecordType.Name From Account Where ID in(Select Accountid From User Where id = :Userinfo.getUserId()) Limit 1];
	        if (tempAccount != null && tempAccount.size() == 1) {
	            accountId = tempAccount.get(0).Id;
	            recordTypeName = tempAccount.get(0).RecordType.Name;
	        } 
	        System.debug('provider id =='+accountId); 
	  		System.debug('accountId =='+providerRecordId);
	  		//system.assert(false,recordTypeName);
	  		accountIdVal = accountId != null? Id.valueOf(accountId) : null;
	  		providerRecordIdVal = providerRecordId != null? Id.valueOf(providerRecordId) : null;
	  		
	  		if(accountIdVal != null && providerRecordIdVal != null && accountIdVal != providerRecordIdVal && recordTypeName != 'Umbrella'){
	  			PageReference pPage = page.EEC_TransactionRoutingPage;
	  			pPage.setRedirect(true);
	  			
	  			unAuthRedirectURL = pPage.getUrl();
	  			
	  		}else if(accountIdVal != null && providerRecordIdVal != null && recordTypeName == 'Umbrella'){
	  			//system.assert(false,'here');
	  			for(Account acc: [SELECT Id,Umbrella_Members__c FROM Account WHERE Umbrella_Members__c =:accountId]){
	  				setOfumbrellaMembermembersId.add(acc.Id);
	  			}
	  			if(!setOfumbrellaMembermembersId.contains(providerRecordIdVal)){
	  				PageReference pPage = page.EEC_TransactionRoutingPage;
		  			pPage.setRedirect(true);
		  			unAuthRedirectURL = pPage.getUrl();
	  			}
	  			
	  		}else{
	  			unAuthRedirectURL = '';
	  		}
  		
  		}  	
  	}
  	
  	public void initializeTransaction(){
  		if(unAuthRedirectURL == null || unAuthRedirectURL ==''){
  			licenseRecordId = ApexPages.currentPage().getParameters().get('ltId');
        	Set<Id> setOfumbrellaMembermembersId = new Set<Id>();
        	providerRecordId = ApexPages.currentPage().getParameters().get('member');
	  		Id accountIdVal, providerRecordIdVal;
	  		String recordTypeName;
			List<Account> tempAccount = [Select Id,OwnerID,RecordType.Name From Account Where ID in(Select Accountid From User Where id = :Userinfo.getUserId()) Limit 1];
	        if (tempAccount != null && tempAccount.size() == 1) {
	            accountId = tempAccount.get(0).Id;
	            recordTypeName = tempAccount.get(0).RecordType.Name;
	        }
	        
	        for(Licensing_Transaction__c licenseTrans:[Select Id,Provider__c FROM Licensing_Transaction__c Where Id =:licenseRecordId]){
	        	providerRecordIdVal = licenseTrans.Provider__c;
	        }
	        accountIdVal = accountId != null? Id.valueOf(accountId) : null;
	  		//system.assert(false,recordTypeName);
	  		
	  		if(accountIdVal != null && providerRecordIdVal != null && accountIdVal != providerRecordIdVal && recordTypeName != 'Umbrella'){
	  			PageReference pPage = page.EEC_TransactionRoutingPage;
	  			pPage.setRedirect(true);
	  			unAuthRedirectURL = pPage.getUrl();
	  			
	  		}else if(accountIdVal != null && providerRecordIdVal != null && recordTypeName == 'Umbrella'){
	  			for(Account acc: [SELECT Id,Umbrella_Members__c FROM Account WHERE Umbrella_Members__c =:accountId]){
	  				setOfumbrellaMembermembersId.add(acc.Id);
	  			}
	  			if(!setOfumbrellaMembermembersId.contains(providerRecordIdVal)){
	  				PageReference pPage = page.EEC_TransactionRoutingPage;
		  			pPage.setRedirect(true);
		  			unAuthRedirectURL = pPage.getUrl();
	  			}
	  		}else{
	  			unAuthRedirectURL = '';
	  		}
	  		
	  		//system.assert(false,unAuthRedirectURL);
  		}
  		//system.assert(false,unAuthRedirectURL);
  	}
  	
  	public EEC_HeaderComponentController(){
  		//unAuthRedirectURL = '';
  		initialize();
  		initializeTransaction();
  		
  	}  
}