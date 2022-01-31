public class MassDocGen_apex {
     //public class MissingDDPInfoException extends Exception { }
    public Id templateId {get;set;}
    public Loop__DDP__c loopRec ;

    //templateId=apexpages.currentpage().getParameters().get('templateId');
    
    List<Appointment__c> appointmentIdFromListView{get;set;}
    List<Appointment__c> appointmenttobeupdated= new list<Appointment__c>();    
    list<id> rcid= new list<id>();
    /*
    public MassDocGen_apex(ApexPages.StandardSetController standardController) {
       this.standardController = standardController;
        for(Appointment__c app :(list<Appointment__c>)standardController.getSelected()){
           appointmentIdFromListView.add(app);
            rcid.add(app.id);
       }
       system.debug('appointmentIdFromListView'+appointmentIdFromListView);
        system.debug('rcid++'+rcid);
       //templateId=apexpages.currentpage().getParameters().get('id');
     //  docGenMethod();
}*/
 private ApexPages.StandardSetController standardController;

    public MassDocGen_apex(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public void bumpCases()
    {       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        List<Appointment__c> selectedCases = (List<Appointment__c>) standardController.getSelected();
        system.debug('selectedCases'+selectedCases.size());
    }
  
    /*public NH_MassDocGenerationController(ApexPages.StandardController controller){
       loopRec = (Loop__DDP__c)controller.getRecord();  
      	templateId = loopRec.id;
         system.debug('contructor is called is !:'+templateId);
        //docGenMethod();
    }*/
    
    public PageReference docGenMethod() {
       system.debug('Class is called is !:'+templateId);
        Loop.loopMessage lm = new Loop.loopMessage();
        
        List<Loop__DDP_Integration_Option__c> deliveryOptionList = [Select id, RecordType.Name
                                                                      From Loop__DDP_Integration_Option__c
                                                                     Where Loop__DDP__c =: templateId
                                                                       and RecordType.Name = 'Attach'];
        
        // SESSION ID NEEDED IF IT CANNOT BE DETERMINED FROM UserInfo.getSessionId()
        lm.sessionId = UserInfo.getSessionId();
        System.debug('Session : ' + lm.sessionId);
        // SET DESIRED BATCH NOTIFICATION. IF THIS IS NOT DONE, THE DEFAULT IS 'NONE'
        // THIS IS AVAILABLE IN LOOP 6.7 / 9.56 AND ABOVE
        //lm.batchNotification = Loop.loopMessage.Notification.BEGIN_AND_COMPLETE;
        //lm.batchNotification = Loop.loopMessage.Notification.ON_COMPLETE;
        //lm.batchNotification = Loop.loopMessage.Notification.ON_ERROR;
        
        // LOOP THROUGH WHATEVER COLLECTIONS NECESSARY FOR THE DDP REQUESTS
        for (Appointment__c appRec: appointmentIdFromListView) {

            lm.requests.add(new Loop.loopMessage.loopMessageRequest(
                appRec.Id, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
                appRec.DocGen_Package__c , // DDP ID  a04r00000033KO7AAM
                new Map<string, string>{
                   'deploy' => ((deliveryOptionList.size() > 0) ? deliveryOptionList[0].Id : null),// a02r0000001MQ02AAG
                   'SFLoop__DDP__c' => appRec.DocGen_Package__c 

                }
            ));
			//appRec.Schedule_Generated__c = true;
            appointmenttobeupdated.add(appRec);

        }
        
        //Update template procced date on Appointment
        if(appointmenttobeupdated.size() > 0) {
            // SEND ALL DDP RUN REQUESTS IN A SINGLE CALL OUT
        	lm.sendAllRequests();
            
            //update new Loop__DDP__c(Id=templateId, Last_Mass_Document_Generation_Date__c = date.today());
            update appointmenttobeupdated;
            //return 'Your requests are being processed.';
       		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Files generation process has been intiated.'));
       		return null;
        } else {
            //return 'Your requests are being processed.';
       		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There is no file available for document generation.'));
       		return null;
         }
    }
    
    public PageReference clicktocontinue()
    {    //loopRec.Last_Mass_Document_generation__c = lastMassDocGenDate;
         //update loopRec;
         PageReference pg = new PageReference('/'+templateId);
        pg.setRedirect(true);
        return pg;  
    }
   

}