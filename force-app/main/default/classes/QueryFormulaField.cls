public class QueryFormulaField {
    public Appointment__c selectedAccount {get; set;}
    public String brandImage {get; set;}
    public String renderr {get; set;}
    public QueryFormulaField(){
        selectedAccount = [SELECT Id, QR_Code__c FROM Appointment__c WHERE Id= 'a2X3F000000N6DmUAK' LIMIT 1 ]; 
        brandImage = selectedAccount.QR_Code__c.substringBetween('src="','" alt=');
        Integer start = System.Now().millisecond();
        while(System.Now().millisecond()< start+100){ 
            
        }
        renderr= 'pdf';
    }
}