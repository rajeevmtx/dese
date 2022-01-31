/*
*   Class Name: WizardTemplate_Helper
*   Description: Utility Class for Wizard Templates
*
*   Author/Date: George Acker/March 20, 2016
*                                                           
*/
public class WizardTemplate_Helper
{
    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_COMPLETE = 'Complete';
    public static final String PAGETYPE_COMPONENTS = 'Project Component';
    public static final String PAGETYPE_REVIEW = 'Project Application Review';
    public static final String PAGETYPE_DOCUMENTS = 'Project Document';
    public static final String PAGETYPE_PROJECT_INFO = 'Project Site Info';
    public static final String PAGETYPE_FINANCIALS = 'Project Financials';
    public static final String PAGETYPE_SUBMIT = 'Submit Application';
    public static final String TEMPLATETYPE_PROPOSAL = 'Proposal Application';
    

    /*
  * Method Name: uncompleteProjectTabs
  * Description: uncomplete tabs in a set of projects based on the page types
  *          used to uncomplete steps 5-7 in NY SUN when blocks change
  * @param: Set<Id> projects
  * @param: Set<String> typs
  * @return: void                                                      
  */
    public static void uncompleteProjectTabs(Set<Id> projects, Set<String> typs)
    {
        if (projects.size() > 0)
        {
            Wizard_Template_Page__c[] pagesToUpdate = [SELECT status__c FROM Wizard_Template_Page__c WHERE
                                                        page_type__c IN :typs
                                                        AND status__c = :WizardTemplate_Helper.STATUS_COMPLETE
                                                        AND wizard_template__r.project__c IN :projects];
            if (pagesToUpdate.size() > 0)
            {
                for (Wizard_Template_Page__c pg :pagesToUpdate)
                {
                    pg.status__c = WizardTemplate_Helper.STATUS_DRAFT;
                }
                update pagesToUpdate;
            }
        }
    }
    
    /*
  * Method Name: getTemplatePages
  * Description: fetch list of template pages based on status
  * @param: Id projectId
  * @param: String status
  * @return: List<Wizard_Template_Page__c>                                                      
  */
    public static List<Wizard_Template_Page__c> getTemplatePages(Id projectId, String status) {
      return [SELECT status__c, Page_Name__c
          FROM Wizard_Template_Page__c 
         WHERE status__c =: status
                   AND wizard_template__r.project__c =: projectId 
             Order by sequence__c ASC];
    } 
}