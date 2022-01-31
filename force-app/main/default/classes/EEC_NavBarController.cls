public class EEC_NavBarController {
    
  public Account acc;
    
  public Account getAcc() {
    try {  
    List<Account> listAcc = [SELECT Id, Name, OwnerId FROM Account 
                   WHERE ID in (SELECT AccountId FROM USER WHERE id = :Userinfo.getUserId())];
      
      if(listAcc.size() > 0)
      	return listAcc[0];
      else
      	return null;
    }    
    catch(Exception e) {
      return acc;
    }
  }  
    
  public String getLicensorEmail() {
    try {
      //System.debug('----> Account: ' + acc);
      if (acc != null) {
        return processAccount(acc);   
      }
      
      acc = getAcc();
      return processAccount(acc);   
    } catch(Exception e) {
      return '';  
    }
  }
    
  private String processAccount(Account acc) {
    if (acc <> null ){       
         User licensor = [Select Id, Name, Email From User Where Id = :acc.OwnerId Limit 1];     
        return licensor.Email;
     }
    return '';
  }

}