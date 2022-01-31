public class NysdohTechnicalHelpdeskController {
    @AuraEnabled
    public static String createCase(String subject, String priority, String description){
        User user = [SELECT Id,FirstName,LastName,Email FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1];
        try{
            Case caseRec= new Case();
            caseRec.First_Name__c = user.FirstName;
            caseRec.Last_Name__c = user.LastName;
            caseRec.Email__c = user.Email;
            caseRec.Status = 'New';
            caseRec.Subject = subject;
            caseRec.Description = description;
            caseRec.priority = priority;
            
            if(caseRec != null){
                insert caseRec;
                System.debug('case>>>' + caseRec);
                return 'Success';
            }   
        }
        catch(Exception e){
            System.debug('Exception :-' + e);
        }   
        return 'Fail';
    }
}