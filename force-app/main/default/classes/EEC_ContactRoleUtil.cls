public without sharing class EEC_ContactRoleUtil{

    public static list<Id> upsertContact(list<Contact> contactListtoInsert){
        for(Contact contact : contactListtoInsert){
            //System.debug('contact: ' + contact);
        }
        List<Id> listContacts = new List<Id>();
        Database.UpsertResult[] srList = database.upsert(contactListtoInsert);
        for (Database.UpsertResult sr : srList) {
            if(sr.isSuccess()){
                listContacts.add(sr.getId());
            }
            else{
                listContacts.add('');
                for(Database.Error err : sr.getErrors()) {
                    //System.debug(err.getMessage());
                }
            }
        }
        return listContacts;
    }

    public static list<Id> insertContact(list<Contact> contactListtoInsert){
        for(Contact contact : contactListtoInsert){
            //System.debug('contact: ' + contact);
        }
        List<Id> listContacts = new List<Id>();
        Database.SaveResult[] srList = database.insert(contactListtoInsert);
        for (Database.SaveResult sr : srList) {
            if(sr.isSuccess()){
                listContacts.add(sr.getId());
            }
            else{
                listContacts.add('');
                for(Database.Error err : sr.getErrors()) {
                    //System.debug(err.getMessage());
                }
            }
        }
        return listContacts;
    }
    
    public static list<Id> updateContact(list<Contact> contactListtoUpdate){
        for(Contact contact : contactListtoUpdate){
            //System.debug('contact: ' + contact);
        }
        List<Id> listContacts = new List<Id>();
        Database.SaveResult[] srList = database.update(contactListtoUpdate);
        for (Database.SaveResult sr : srList) {
            if(sr.isSuccess()){
                listContacts.add(sr.getId());
            }
            else{
                listContacts.add('');
                for(Database.Error err : sr.getErrors()) {
                    //System.debug(err.getMessage());
                }
            }
        }
        return listContacts;
    }
    public static list<Contact_Role__c> upsertContactRole(list<Contact_Role__c> listContactRole){
        for(Contact_Role__c ContactRole : listContactRole){
            //System.debug('contact: ' + ContactRole);
        }
        Database.UpsertResult[] srList = database.upsert(listContactRole);
        for (Database.UpsertResult sr : srList) {
            for(Database.Error err : sr.getErrors()) {
                //System.debug(err.getMessage());
            }
        }
        return listContactRole;
    }
    public static list<Contact_Role__c> insertContactRole(list<Contact_Role__c> listContactRole){
        for(Contact_Role__c ContactRole : listContactRole){
            //System.debug('contact: ' + ContactRole);
        }
        Database.SaveResult[] srList = database.insert(listContactRole);
        for (Database.SaveResult sr : srList) {
            for(Database.Error err : sr.getErrors()) {
                //System.debug(err.getMessage());
            }
        }
        return listContactRole;
    }
    public static list<Contact_Role__c> updateContactRole(list<Contact_Role__c> listContactRole){
        for(Contact_Role__c ContactRole : listContactRole){
            //System.debug('contact: ' + ContactRole);
        }
        Database.SaveResult[] srList = database.update(listContactRole);
        for (Database.SaveResult sr : srList) {
            for(Database.Error err : sr.getErrors()) {
                //System.debug(err.getMessage());
            }
        }
        return listContactRole;
    }
    public static void deleteContactRole(list<Contact_Role__c> listContactRole){
        delete listContactRole;
    }
    public static void  upsertTransactionDocument(List<Transaction_Document__c>  listdocs){
        upsert listdocs;
    }
    public static void  updateTransactionDocument(List<Transaction_Document__c>  listdocs){
        update listdocs;
    }
    public static void deleteTransactionDocument(Transaction_Document__c tdocument){
        delete tdocument;
    }
    
    public static void deleteTransactionDocuments(List<Transaction_Document__c> listdocument){
        delete listdocument;
    }
    
    public static Licensing_Transaction__c updateLicensingTransaction(Licensing_Transaction__c licenseTransaction){
        update licenseTransaction;
        return licenseTransaction;
    }
    public static list<Account> getUmbrellaList(string umbrellaName,string cityName)
    {   
        List<Account> queryResults = new List<Account>();
        String queryString = 'select Id, Name, Provider_Address_1__c, Provider_city_text__c, Provider_Zip_Code__c , State__c from Account where RecordType.Name = \'Umbrella\'' ;
        if(String.isNotBlank(umbrellaName) && String.isNotBlank(cityName)){
            queryString = queryString + ' and (Name like '+ umbrellaName+' AND Provider_City__r.Name like '+cityName+')';
        } else if(String.isNotBlank(umbrellaName) && String.isBlank(cityName)){
            queryString = queryString + ' and Name like ' + umbrellaName ; 
        } else if(String.isBlank(umbrellaName) && String.isNotBlank(cityName)){
            queryString = queryString + ' and Provider_City__r.Name like ' + cityName; 
        }
        //System.debug('STDebug: QueryString--->' + queryString);
        
        queryResults = database.query(queryString);
        
        //System.debug('STDebug: queryResults--->' + queryResults);

        return queryResults;
    }
      public static Account getUmbrellaDetails(string selectedUmbrellaId)
    {   //System.debug('SelectedUmbrella:-'+selectedUmbrellaId);
        Account queryResults = new Account();
        String queryString = 'select Id, Name, State__c, Provider_city_text__c,Provider_Address_1__c, Provider_Address_2__c, Provider_City__c, Provider_City__r.Name, Provider_Zip_Code__c from Account where Id=\''+ selectedUmbrellaId +'\'';
        queryResults = database.query(queryString);
                          
        return queryResults;
    }
}