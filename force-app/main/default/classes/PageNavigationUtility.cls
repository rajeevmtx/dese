/*
*   Class Name: PageNavigationUtility
*   Description: PageNavigationUtility
*
*   Author/Date: Das Nobel/ 02/04/2016
*
*
*/
public with sharing class PageNavigationUtility {

    public static Set<String> allowedTemplateTypeInContractorApplicationSet = new Set<String> { 'Contractor Application',
                                                                                                'Payee Application',
                                                                                                'Change Modification Application'};
    /*
    * Method Name: getTargetPageName
    * Description: get the targeted page name as a string
    * @param: String projectId
    * @param: String currentPageName
    * @param: Boolean isNext
    * @param: String applicationId
    * @return: String
    */
    public static String getTargetPageName(String projectId, String currentPageName, Boolean isNext, String applicationId) {

        String query = 'SELECT ';
        for(String fieldName : getTemplateFieldList()) {
            query += fieldName + ', ';
        }

        // Child Query
        query += ' (Select ';
        for(String fieldName : getTemplatePageFieldList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Wizard_Template_Pages__r )';
        query += ' FROM Wizard_Template__c';

        String caseId = ApexPages.currentPage().getParameters().get('caseId');

        if(caseId != null && caseId != ''){
            query += ' WHERE Case__c = \'' + CORE_Helper.doEscapeSingleQuotes(caseId) + '\' AND Status__c = \'Active\'';
        }else{
            if(projectId != null){

                query += ' WHERE Project__c = \'' + CORE_Helper.doEscapeSingleQuotes(projectId) + '\' AND Status__c = \'Active\'';
            }else if(applicationId != null){

                query += ' WHERE Service_Provider_Application__c = \'' + CORE_Helper.doEscapeSingleQuotes(applicationId) + '\' AND Template_Type__c IN :allowedTemplateTypeInContractorApplicationSet AND Status__c = \'Active\'';
            }
        }

        System.debug('***query**'+query);
        List<Wizard_Template__c> projectTemplateList = Database.query(query);
        if(projectTemplateList.size() == 0) {
            return null;
        }
        system.debug('@@@@@@@@@@@@  projectTemplateList \n\n' + projectTemplateList);
        Wizard_Template__c projectTemplate = projectTemplateList[0];
        String pageName;
        Map<String, Decimal> pageNameToSequenceNumberMap = new Map<String, Decimal>();
        Map<Decimal, String> sequenceNumberToPageNameMap = new Map<Decimal, String>();
        Decimal currentSequenceNumber = 0;
        List<Wizard_Template_Page__c> projTempPageList = new List<Wizard_Template_Page__c>();
        //system.assert(false, projectTemplate.Wizard_Template_Pages__r);

        system.debug('@@@@@@@@@@@@  projectTemplateList \n\n' + projectTemplate.Wizard_Template_Pages__r);

        system.debug('@@@@@@@@@@@@  currentPageName \n\n' + currentPageName);

        for(Wizard_Template_Page__c tempPageRec : projectTemplate.Wizard_Template_Pages__r) {
            pageNameToSequenceNumberMap.put(tempPageRec.Page_Name__c, tempPageRec.Sequence__c);
            sequenceNumberToPageNameMap.put(tempPageRec.Sequence__c, tempPageRec.Page_Name__c);

            if(isNext && tempPageRec.Page_Name__c == currentPageName && tempPageRec.Status__c != 'Complete') {
                Wizard_Template_Page__c projTempPageRec = new Wizard_Template_Page__c(Id = tempPageRec.Id);
                projTempPageRec.Status__c = 'Complete';
                projTempPageList.add(projTempPageRec);
            }
        }

        if(projTempPageList.size() > 0) {
            update projTempPageList;
        }

        currentSequenceNumber = pageNameToSequenceNumberMap.get(currentPageName);
        if(currentSequenceNumber == null) {
            currentSequenceNumber = 0;
        }

        if(isNext) {
            currentSequenceNumber++ ;
        } else if(!isNext){
            currentSequenceNumber-- ;
        }
        pageName = (sequenceNumberToPageNameMap.containsKey(currentSequenceNumber)) ? sequenceNumberToPageNameMap.get(currentSequenceNumber) : currentPageName;

        return pageName;
    }

    /*
    * Method Name: getNextPageURL
    * Description: redirect to the next page
    * @param: String projectId
    * @param: String currentPageName
    * @param: String applicationId
    * @return: Pagereference
    */
    public static Pagereference getNextPageURL(String projectId, String currentPageName, String applicationId) {
        String nextPageName = getTargetPageName(projectId, currentPageName, true, applicationId);
        return getPageReferenceByPageName(nextPageName, projectId, applicationId);
    }


    /*
    * Method Name: getPreviousPageURL
    * Description: redirect to the previous page
    * @param: String projectId
    * @param: String currentPageName
    * @param: String applicationId
    * @return: Pagereference
    */
    public static Pagereference getPreviousPageURL(String projectId, String currentPageName, String applicationId) {
        String previousPageName = getTargetPageName(projectId, currentPageName, false, applicationId);
        return getPageReferenceByPageName(previousPageName, projectId, applicationId);
    }

    /*
    * Method Name: getTargetPageURL
    * Description: redirect to the targeted page
    * @param: String projectId
    * @param: String targetPageName
    * @param: String applicationId
    * @return: Pagereference
    */
    public static Pagereference getTargetPageURL(String projectId, String targetPageName, String applicationId) {
        return getPageReferenceByPageName(targetPageName, projectId, applicationId);
    }

    /*
    * Method Name: getPageReferenceByPageName
    * Description: redirect to the page
    * @param: String pageName
    * @param: String projectId
    * @param: String applicationId
    * @return: Pagereference
    */
    private static Pagereference getPageReferenceByPageName(String pageName, String projectId, String applicationId) {
        String pgRefString;
        String caseId = ApexPages.currentPage().getParameters().get('caseId');
        String securityKey = ApexPages.currentPage().getParameters().get('key');

        if(caseId != null && caseId != ''){

          pgRefString = '/apex/' + pageName + '?caseId=' + caseId + '&ProjectId=' + projectId;
        }else{

          if(projectId != null){
			  if(securityKey != null && securityKey != ''){
                pgRefString = '/apex/' + pageName + '?ProjectId=' + projectId + '&key=' + securityKey;
              } else {
                pgRefString = '/apex/' + pageName + '?ProjectId=' + projectId;
              }
          }else if(applicationId != null){

              pgRefString = '/apex/' + pageName + '?ApplicationId=' + applicationId;
          }
        }

        Pagereference pr = new PageReference(pgRefString);
        pr.setRedirect(true);
        return pr;
    }

    /*
    * Method Name: getTemplateFieldList
    * Description: returns the template fields
    * @param:
    * @return: List<String>
    */
    public static List<String> getTemplateFieldList(){
        List<String> templateFieldList = new List<String>{  'Id',
                                                            'Description__c',
                                                            'Program__c',
                                                            'Project__c',
                                                            'Status__c',
                                                            'Template_Type__c'
                                                };
        return templateFieldList;
    }
    /*
    * Method Name: getTemplatePageFieldList
    * Description: returns the template page fields
    * @param:
    * @return: List<String>
    */
    public static List<String> getTemplatePageFieldList(){
        List<String> templatePageFieldList = new List<String>{  'Id',
                                                                'Name',
                                                                'Page_Name__c',
                                                                'Page_Type__c',
                                                                'Wizard_Template__c',
                                                                'Sequence__c',
                                                                'Status__c'
                                                };
        return templatePageFieldList;
    }
}