public class DESE_ProgramMergeCmpController {
	@AuraEnabled
    public static List<Account> getProgramsUnderTheUmbrella(String recordId){
        List<Account> lstToReturn = new List<Account>();
        try{
            Account objAcc = [Select Id,Umbrella__c from Account where Id=:recordId];
            if(objAcc.Umbrella__c == null){
                return lstToReturn;
            }
            lstToReturn = [Select Id,Umbrella__c,Name, Website, Account_Type__c, Enrollment__c, Grade_Served__c, School_Code__c from Account where Umbrella__c=:objAcc.Umbrella__c];
            return lstToReturn;
        } catch(Exception exp) {
            return lstToReturn;
        }
    }
    @AuraEnabled
    public static void sendDataToServer(Account updateCurrentRec,Account child) {
        List<Account> lstToUpdate = new List<Account>();
        updateCurrentRec.ParentId = child.Id;
        updateCurrentRec.IsMerged__c = true;
        updateCurrentRec.Umbrella__c = null;
        lstToUpdate.add(updateCurrentRec);
        //lstToUpdate.add(new Account(Id=child.Id,ParentId=updateCurrentRec.Id,IsMerged__c=true,Umbrella__c=null));
        update lstToUpdate;
    }
}