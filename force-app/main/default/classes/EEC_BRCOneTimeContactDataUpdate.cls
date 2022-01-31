global class EEC_BRCOneTimeContactDataUpdate implements Database.Batchable<sobject> {
     public string query;

    global EEC_BRCOneTimeContactDataUpdate() {
        query ='SELECT id,BRC_Id__c FROM Contact WHERE BRC_Id__c != null AND BRC_Renewal_Date__c != null';
    }

    global Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQuerylocator(query);
    }

    global void execute(Database.BatchableContext bc,List<Contact> listOfContacts){

            system.debug(listOfContacts);
            Set<Id> setOfContactIdsWithExistingBRCIds = new Set<Id>();
            Set<String> setOfrcIds = new Set<String>();
            Set<Id> setOfContactIdWithoutBrcID = new Set<Id>();
            List<Contact> listOfContactWithoutBRCRenewalDate = new List<Contact>();
            Map<String,List<Contact>> brcIdToContactsMap = new Map<String,List<Contact>>();

            for(Contact con:listOfContacts){
                setOfContactIdsWithExistingBRCIds.add(con.id);
                setOfrcIds.add(con.BRC_Id__c);
            }

            for(Contact con:[SELECT Id,BRC_Id__c FROM Contact WHERE BRC_Id__c IN:setOfrcIds AND ID NOT IN:setOfContactIdsWithExistingBRCIds AND BRC_Renewal_Date__c = null]){
                listOfContactWithoutBRCRenewalDate.add(con);
                brcIdToContactsMap.put(con.BRC_Id__c,listOfContactWithoutBRCRenewalDate);
                
            }



    }

     global Void finish(Database.BatchableContext bc){}
    

}