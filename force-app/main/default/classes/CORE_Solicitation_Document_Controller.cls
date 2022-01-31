/*
* Class Name: CORE_Solicitation_Document_Controller
* Description: Controller class for CORE_Solicitation_Document_Page page
* Author/Date: Ashish Sharma / May 20, 2017
*/
public class CORE_Solicitation_Document_Controller {
    public Id attachmentId{get; set;}

    /*
		* Method Name: CORE_Solicitation_Document_Controller
		* Description: Constructor method
		* @param: none
		* @return: none
	*/
    public CORE_Solicitation_Document_Controller(){
        String documentId = ApexPages.currentPage().getParameters().get('documentId');

        if(!String.isBlank(documentId)){
            for(Attachment attach : [SELECT Id
                                       FROM Attachment
                                      WHERE ParentId =: documentId
                                      ORDER BY CreatedDate DESC LIMIT 1]){

                attachmentId = attach.Id;
            }
        }
    }
}