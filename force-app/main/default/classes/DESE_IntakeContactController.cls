public without sharing class DESE_IntakeContactController {

    @AuraEnabled
    public static string saveContact(List<Contact> contacts, Id projectId){
        try {
            List<String> roles = new List<String>{'Title I','Title II','Title III','Title IV','System'};
            Database.UpsertResult[] srList = Database.upsert(contacts,false);
            List<Id> contactIds = new List<Id>();
            Map<String,Id> roleIdMap = new Map<String,Id>();
            for(Integer i=0;i<srList.size();i++){
                if (srList.get(i).isSuccess()){
                    roleIdMap.put(roles[i],srList.get(i).getId());
                }else if (!srList.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = srList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    contacts.get(i);//failed record from the list
                    system.debug('Failed ID'+contacts.get(i).Id);
                 }
            
            }
            List<Project_Role__c> prs = [SELECT Id,Contact__c,Project__c,Role__c FROM Project_Role__c WHERE Project__c = :projectId AND Contact__c= :roleIdMap.values()];
            for(String role:roleIdMap.keySet()){
                if(roleIdMap.get(role) != null){
                    Boolean isNew = true;
                    for(Project_Role__c pr:prs){
                        if(pr.Contact__c == roleIdMap.get(role))
                            isNew = false;
                    }
                    if(isNew == true){
                        prs.add(new Project_Role__c(Primary_Customer_Contact__c=true,Role__c=role,Project__c=projectId,Contact__c=roleIdMap.get(role)));
                    }
                }
            }
            upsert prs;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Contact> fetchContacts(Id projectId){
        try {
            List<String> roles = new List<String>{'Title I','Title II','Title III','Title IV','System'};
            List<Project_Role__c> prs = [SELECT Contact__c,Role__c FROM Project_Role__c WHERE Project__c = :projectId and Role__c in :roles];
            Map<String, Id> roleMap = new Map<String, Id>();
            for(Project_Role__c pr:prs){
                roleMap.put(pr.Role__c, pr.Contact__c);
            }
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,FirstName,LastName,Title,Phone,Email FROM Contact WHERE Id IN :roleMap.values()]);

            Map<String,Contact> result = new Map<String,Contact>();
            for(Integer i=0;i<roles.size();i++){
                if(roleMap.containsKey(roles[i]) && roleMap.get(roles[i]) != null){
                    result.put(roles[i],contactMap.get(roleMap.get(roles[i])));
                }
            }
            System.debug(result);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

}