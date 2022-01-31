/*
* Class Name: CORE_Deliverables_Documents_Controller
* Description: S-00354 Controller class designed for handle the functionality of CORE_Deliverables_Documents_Page
* Author/Date:  Gaurav Sinha   07/09/2016
*
* Date         New/Modified      Author             Description
* 05/21/2017   Modified          Ghanshyam          Commenting
*
*/
global with sharing class CORE_Deliverables_Documents_Controller {

    public Project_Milestones__c projMilestone{Get;set;}
    public Map<Id, Attachment> mapOfDeliverableIdAndAttachment {get; set;}
    public Map<Id, Project_Deliverables__c> mapOfIdAndDeliverables{Get;set;}
    public Id selectedDeliverabeldId {get; set;}
    public list<Project_Milestones__c> listOfProjectMilestones{Get;set;}
    public Map<Id, Project_Document__c> mapOfIdAndDocuments{get;set;}
    public string selectedparentdocid{get;set;}
    public Map<Id, List<Project_Document__c>> mapOfChildParent{get;set;}
    public map<id,DeliverablesWrapper> mapSelectedoption{get;set;}
    public List<Id> projectDeliverablesIdList {get; set;}
    public list<task> litask{Get;set;}
    public Map<Id, AttachmentWrapper> attachmentWrapperMap{get;set;}  // #attachmentNameIssue
    public CORE_Deliverables_Documents_Controller (ApexPages.standardController stdCont){
        if(!test.isRunningTest())
            stdCont.addFields(new LIst<string>{'Project__c'});
        projMilestone = (Project_Milestones__c)stdcont.getRecord();
        fetchDeliverables();
    }
    public Map<Id, Boolean> mapOfDeliverableIdAndRequiredStatus {get; set;}
    public boolean contractor{Get{
        return userinfo.getUserType()!=CORE_Deliverables_Helper.USER_TYPE_STANDARD ;
    }
    set;}
     public id projectid {
        get{
            if(projectid==null){
                projectid = apexpages.currentPage().getParameters().get('projectid');
            }
            return projectid;
        }
        private set;
    }

    public boolean profileAccess{
        Get{
            if(profileAccess==null){
                if(userinfo.getUserType()==CORE_Deliverables_Helper.USER_TYPE_STANDARD){
                    contractor = false;
                    integer count = [select count()
                                        from project_role__c
                                        where project__c = :projectid
                                        and   project__R.status__c !=: CORE_Deliverables_Helper.PROJECT_Closed
                                        and  role__c =: CORE_Deliverables_Helper.PROJECT_PM
                                        and User__c =: userinfo.getUserId()];
                    System.debug('==>'+count);
                    if(count !=0){
                        profileAccess = true;
                    }
                    else{
                        profileAccess = false;
                    }
                        System.debug('==>profileAccess'+profileAccess);
                }
/*                else{
                    contractor = true;
                    String contactid = [select id,contactid from user where id=:userinfo.getUserId() limit 1][0].contactid;
                    if(contactid!=null){
                        integer count = [select count()
                                        from project_role__c
                                        where project__c = :projectid
                                        and  project__R.status__c  =: CORE_Deliverables_Helper.PROJECT_Unsubmitted
                                        and role__c =: CORE_Deliverables_Helper.PROJECT_Contractor
                                        and contact__c =: contactid];
                        if(count !=0){
                            profileAccess = true;
                        }
                        else{
                            profileAccess = false;
                        }
                    }else{
                        profileAccess = false;
                    }
                }*/
            }
            return profileAccess;
        }

        private set;

    }

    /*
    * Method Name: fetchDeliverables
    * Description: Method to retrive the deliverables
    * @param
    * @return
    */
    public void fetchDeliverables(){
        mapOfChildParent = new Map<Id, List<Project_Document__c>>();
        mapSelectedoption = new map<id,DeliverablesWrapper>();
        mapOfDeliverableIdAndRequiredStatus = new Map<Id, Boolean>();
        listOfProjectMilestones = new List<Project_Milestones__c>();
        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>();
        mapOfIdAndDocuments = new Map<Id, Project_Document__c>();
        mapOfDeliverableIdAndAttachment = new  Map<Id, Attachment>();
        Set<Id> setOfProjectMilestones = new Set<Id>();
        attachmentWrapperMap = new Map<Id, AttachmentWrapper>();// #attachmentNameIssue



        Boolean isRequiredLocal = false;
        for(Project_Milestones__c milestone : [SELECT Id, Name, Incentive_Amount__c,
                                                      (SELECT Id,Notes__c, Type__c, Sub_Type__c, Name,
                                                              Deliverable_name__c,
                                                              Mandatory_by_Default__c,Project__r.Name,
                                                               Conditionally_Required__c,
                                                              Validation_Logic__c, Status__C
                                                        FROM  Project_Deliverables1__r)
                                               FROM   Project_Milestones__c WHERE ID = :projMilestone.id]){
                  listOfProjectMilestones.add(milestone);
                  for(Project_Deliverables__c deliverable : milestone.Project_Deliverables1__r){
                      if(deliverable.Mandatory_by_Default__c){
                          isRequiredLocal = true;
                      }else if(deliverable.Conditionally_Required__c){
                          isRequiredLocal = FormulaInterpretUtility.checkForRequried(deliverable);
                      }else{
                          isRequiredLocal = false;
                      }
                      mapOfDeliverableIdAndRequiredStatus.put(deliverable.id, isRequiredLocal);
                      mapOfDeliverableIdAndAttachment.put(deliverable.id, new Attachment());
                      attachmentWrapperMap.put(deliverable.id, new AttachmentWrapper()); // #attachmentNameIssue

                }
        }

        mapOfIdAndDeliverables = new Map<Id, Project_Deliverables__c>([SELECT Name, Status__c, CreatedDate,
                                                                           (SELECT Name , Version__c, Notes__c, CreatedDate, Status__c, CreatedBy.Name
                                                                            FROM Project_Documents__r
                                                                            where Parent_Project_Document__c = null
                                                                            ORDER BY CreatedDate desc)
                                                                       FROM Project_Deliverables__c
                                                                       WHERE Id IN :mapOfDeliverableIdAndAttachment.keySet()]);

        litask= new list<task>();
        for(task varloop: [select id,subject,activitydate,createddate, status,type,priority,Description,createdby.name
                            from task
                         //   where Project_Deliverables__c =: mapOfDeliverableIdAndAttachment.keySet()
                            order by activitydate desc]){
            litask.add(varLoop);
        }

        mapOfIdAndDocuments = new Map<Id,Project_Document__c>([SELECT Name, Project_Deliverables__c, Version__c, Status__c, CreatedDate, CreatedBy.Name,
                                                               (SELECT Name, BodyLength FROM Attachments LIMIT 1)
                                                               FROM Project_Document__c
                                                               where    Project_Deliverables__c IN :mapOfDeliverableIdAndAttachment.keySet()
                                                               order by CreatedDate desc]);

        for(Project_Document__c varloop:[SELECT Name, Project_Deliverables__c, Parent_Project_Document__c ,Version__c, Status__c, CreatedDate, CreatedBy.Name
                                                               FROM Project_Document__c
                                                               WHERE Project_Deliverables__c IN :mapOfDeliverableIdAndAttachment.keySet()
                                                               order by CreatedDate desc]){
            if(varloop.Parent_Project_Document__c==null){
                if(mapOfChildParent.get(varloop.id)==null){
                    mapOfChildParent.put(varloop.Id, new List<Project_Document__c>{varloop});
                }else{
                    mapOfChildParent.get(varloop.Id).add(varloop);
                }
            }else{
                if(mapOfChildParent.get(varloop.Parent_Project_Document__c)==null){
                    mapOfChildParent.put(varloop.Parent_Project_Document__c, new List<Project_Document__c>{varloop});
                }else{
                    mapOfChildParent.get(varloop.Parent_Project_Document__c).add(varloop);
                }
            }
        }

        projectDeliverablesIdList = new List<Id>();
        list<Selectoption> listparent = new list<Selectoption>();
        for(Id projDeliverablesRecId : mapOfIdAndDeliverables.keySet()) {
            //if(mapOfDeliverableIdAndRequiredStatus.containsKey(projDeliverablesRecId) && mapOfDeliverableIdAndRequiredStatus.get(projDeliverablesRecId)) {
            projectDeliverablesIdList.add(projDeliverablesRecId);
            DeliverablesWrapper dw = new DeliverablesWrapper();
            for(Project_Document__c var : mapOfIdAndDeliverables.get(projDeliverablesRecId).Project_Documents__r){
                listparent.add(new SelectOption(var.id,mapOfIdAndDocuments.get(mapOfChildParent.get(var.id)[0].id).Attachments[0].name));

            }
            dw.liparent = listparent;
            dw.showValueList = listparent.size() != 0;
            dw.showparentList = listparent.size() > 1;
            dw.selectedParent = listparent.size() == 1 ? listparent[0].getvalue() : null;
            dw.selectedValue = listparent.size()  == 0 ? 'New': '';
            mapSelectedoption.put(projDeliverablesRecId,dw);
            //}
            listparent = new list<Selectoption>();
        }




    }

    /*
    * Method Name: saveDocuments
    * Description: Method to save the documents of deliverables
    * @param
    * @return: PageReference
    */
    public PageReference saveDocuments(){
        List<Project_Document__c> listOfProjectDocumentToInsert = new List<Project_Document__c>();
        List<Attachment> listOfAttachmentToUpsert = new List<Attachment>();
        list<Project_Deliverables__c> listprojectDeliverabels = new list<Project_Deliverables__c>();
        Savepoint sp = Database.setSavepoint();
        Project_Document__c localDoc;
        try{

            boolean isInvoiceSigned = false;

            for(Id dId : mapOfDeliverableIdAndAttachment.keySet()){
                                           if(mapOfDeliverableIdAndAttachment.get(dId) != null){
                                                DeliverablesWrapper tem = mapSelectedoption.get(did);
                                                if(tem==null || String.isBlank(tem.selectedValue))
                                                    continue;


                    if(attachmentWrapperMap.containsKey(dId) && attachmentWrapperMap.get(did).attachmentBody !=null && attachmentWrapperMap.get(did).attachmentName !=null ){ //mapOfDeliverableIdAndAttachment.get(dId).Body != null #attachmentNameIssue
                    localDoc = new Project_Document__c();
                    listprojectDeliverabels.add(new Project_Deliverables__c(id=did,Status__c=CORE_Deliverables_Helper.CONST_SUBMITTED));
                    localDoc.Name = attachmentWrapperMap.get(did).attachmentName.length()>80 ? attachmentWrapperMap.get(did).attachmentName.subString(0,80) : attachmentWrapperMap.get(did).attachmentName ; //mapOfIdAndDeliverables.get(dId).Name; #attachmentNameIssue
                    localDoc.Project__c = projMilestone.Project__c;
                    localDoc.Project_Deliverables__c = dId;
                    localDoc.Status__c= CORE_Deliverables_Helper.CONST_SUBMITTED;
                    if(tem.selectedValue=='Version'){
                    localdoc.Parent_Project_Document__c = tem.selectedParent;
                    localDoc.Version__c = mapOfIdAndDeliverables.get(dId).Project_Documents__r.size() + 1;
                    }else{
                        localDoc.Version__c =1;
                    }
                    listOfProjectDocumentToInsert.add(localDoc);
                }
             }
            }
            if(listOfProjectDocumentToInsert.size()>0)
              Database.insert(listOfProjectDocumentToInsert);
            if(listprojectDeliverabels.size()>0)
              Database.update(listprojectDeliverabels);
            Attachment localAtt;
            system.debug(listprojectDeliverabels);
            for(Project_Document__c doc : listOfProjectDocumentToInsert){
                if(mapOfDeliverableIdAndAttachment.containsKey(doc.Project_Deliverables__c) && attachmentWrapperMap.containsKey(doc.Project_Deliverables__c)
                        &&  attachmentWrapperMap.get(doc.Project_Deliverables__c).attachmentBody!=null){
                    system.debug('Inside If Condition');
                    localAtt = mapOfDeliverableIdAndAttachment.get(doc.Project_Deliverables__c);
                    system.debug(localAtt);
                    localAtt.Name = attachmentWrapperMap.get(doc.Project_Deliverables__c).attachmentName;
                    localAtt.body = attachmentWrapperMap.get(doc.Project_Deliverables__c).attachmentBody;system.debug(mapOfDeliverableIdAndAttachment.get(doc.Project_Deliverables__c).Name.length() > 80);
                    localAtt.ParentId = doc.Id;
                    listOfAttachmentToUpsert.add(localAtt);
                }
            }
            Database.upsert(listOfAttachmentToUpsert);

            Set<Id> deliverableIds = new Set<Id>();

            for(Project_Milestones__c milestone : listOfProjectMilestones){
                if(milestone.Project_Deliverables1__r != null &&
                   milestone.Project_Deliverables1__r.size() > 0){

                    for(Project_Deliverables__c pd : milestone.Project_Deliverables1__r){
                        deliverableIds.add(pd.Id);
                    }
               }
            }

            List<Project_Deliverables__c> toUpdateDeliverables = new List<Project_Deliverables__c>();

            Map<Id, Project_Deliverables__c> oldMap = new Map<Id, Project_Deliverables__c>();

            for(Project_Deliverables__c deliverables : [SELECT Id, Deliverable_name__c, Status__c FROM Project_Deliverables__c WHERE Id IN: deliverableIds]){
                oldMap.put(deliverables.Id, deliverables);
            }

            for(Project_Milestones__c milestone : listOfProjectMilestones){
                if(milestone.Project_Deliverables1__r != null &&
                   milestone.Project_Deliverables1__r.size() > 0){

                    for(Project_Deliverables__c pd : milestone.Project_Deliverables1__r){
                        Project_Deliverables__c tempPd = new Project_Deliverables__c(Id=  pd.Id);
                        if(pd.Status__c == CORE_Deliverables_Helper.CONST_REJECTED &&  oldMap.containsKey(pd.Id) &&
                           oldMap.get(pd.Id).status__c != CORE_Deliverables_Helper.CONST_REJECTED){
                            tempPd.Waiting_for_External_Response__c = true;
                            tempPd.Waiting_for_External_Response_Date__c = system.today();
                        }
                        //if(oldMap.containsKey(pd.Id)) {
                            //tempPd.Status__c = pd.Status__c;
                        //}
                        toUpdateDeliverables.add(tempPd);
                    }
                }
            }

            if(toUpdateDeliverables.size() > 0){
                update toUpdateDeliverables;
            }

            String pageURL = page.CORE_Deliverables_Documents_Page.getURL();
            PageReference p = new PageReference(pageURL+'?projectid='+projMilestone.project__c + '&id=' + projMilestone.Id);
            p.setRedirect(true);
            return p;

        }catch(Exception e){
            SYstem.debug(e.getMessage());
            throw e;
            Database.rollback(sp);
        }

        return null;
    }

    @RemoteAction
    public static boolean updateStatus(String deliverabelId,String status){
        try{
            Project_Deliverables__c pd = [select id, Deliverable_name__c, status__c from Project_Deliverables__c where id =: deliverabelId];
            if(status == CORE_Deliverables_Helper.CONST_REJECTED &&  (  pd.status__c != CORE_Deliverables_Helper.CONST_REJECTED ) ){
                pd.Waiting_for_External_Response__c = true;
                pd.Waiting_for_External_Response_Date__c = system.today();
            }
            pd.status__c = status;
            //Project_Deliverables__c pd = new Project_Deliverables__c(id=deliverabelId,status__c=status);
            update pd;
            return true;
        }catch(Exception e){
            return false;
        }
    }

    @RemoteAction
    public static boolean updateNotes(String deliverabelId,String notes){
        try{
            Project_Deliverables__c pd = new Project_Deliverables__c(id=deliverabelId,notes__c=notes);
            update pd;
          return true;
        }catch(Exception e){
            return false;
        }
    }

    public class DeliverablesWrapper{
        public string selectedValue{get;set;}
        public string selectedParent{Get;set;}
        public list<selectoption> liparent{Get;set;}
        public boolean showValueList{Get;set;}
        public boolean showparentList{Get;set;}
        public list<selectoption> lioption{
            Get{
                if(lioption==null){
                    lioption = new List<selectOption>();
                    lioption.add(new SelectOption('Version','Version'));
                    lioption.add(new SelectOption('New','New'));

                }
                return lioption;
            }
            private set;
        }

        public DeliverablesWrapper(){

        }
    }
     // #attachmentNameIssue
    public class AttachmentWrapper{
        public transient String attachmentName {get;set;}
        public transient Blob attachmentBody{get;set;}
    }

}