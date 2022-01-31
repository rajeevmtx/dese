/*
* Class Name:  ProjectContract_Helper
* Description: Helper class dealing with Project_Contract__c records
*                                                            
*/
 
public class ProjectContract_Helper {

  public static final String STATUS_O = 'O';
  public static final String STATUS_A = 'A';
  public static final String STATUS_OPEN = 'Open';
  public static final String STATUS_APPROVED = 'Approved';
  public static final String STATUS_ONHOLD = 'On-Hold';


  public static final String CATEGORY_PGRM = 'PGRM';

  public static final String AGREEMENT_CODE_B = 'B';
  public static final String AGREEMENT_CODE_A = 'A';


  public static final String PROCUREMENT_CONTRACT_N = 'N';

  public static final String LINE_DESCRIPTION_PREFIX = 'NY Sun Assignment (Vendor #';
  public static final String LINE_DESCRIPTION_SUFFIX = ')';

  
  /*
  * Method Name: prepareLineDescription
  * Description: prepare Line Description
  * @return:  String
  * @param:  String supplierId 
  */
  
  public static String prepareLineDescription(String supplierId) {
    if(String.isBlank(supplierId)) {
      supplierId = '';
    }
    return LINE_DESCRIPTION_PREFIX + supplierId + LINE_DESCRIPTION_SUFFIX;
  }


  public static Set<String> SET_CONTRACT_EXTRACT_STATUSES = new Set<String>{STATUS_OPEN,STATUS_APPROVED};

  public static Set<String> SET_CONTRACT_STATUSES_FOR_RECEIVED_PROJECT = new Set<String>{STATUS_OPEN,STATUS_APPROVED};
}