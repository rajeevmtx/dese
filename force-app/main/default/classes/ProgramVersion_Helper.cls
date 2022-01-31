/*
*   Class Name: ProgramVersion_Helper
*   Description: Helper class dealing with Program_Version__c records
*
*  
*                                                             
*/
public with sharing class ProgramVersion_Helper {

    public static String STATUS_OPEN = 'Open';
    public static String STATUS_CLOSED = 'Closed';
    public static final String INVOICE_TYPE_VOUCHER = 'Voucher';
    public static final String INVOICE_TYPE_CONTRACT = 'Contract';
    
    /*
    Method Name: fetchSolicitationAsPerFamily
    Return Type: Program_Version__c
    Params: String solicitationFamilyType ---> family type of solicitation, String programFamilyName ---> name of program family
    Description: fetch solicitaion (program version record) as per program family and family type of solicitation
    */
    public static Program_Version__c fetchSolicitationAsPerFamily(String solicitationFamilyType, String programFamilyName)
    { 
      Program_Version__c solicitation;
    for(Program_Version__c progVersion : [SELECT Id, Name, Program__r.Name
                        FROM Program_Version__c
                        WHERE Family_Type__c = : solicitationFamilyType
                        AND Program__r.Program_Family__c =: programFamilyName
                        AND Status__c =: STATUS_OPEN ])   
    {
      solicitation = progVersion;
    }
      
      return solicitation;
    }


}