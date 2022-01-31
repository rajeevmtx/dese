/*
* 	Class Name: Utility_Trigger_SoftDisable
* 	Description: Utility to "soft disable" triggers via a custom setting
* 	Author/Date: George Acker/Jan 27, 2016
*                        
*/
public class Utility_Trigger_SoftDisable
{
    private Trigger_Soft_Disable__c custSetting;
    
    public Utility_Trigger_SoftDisable(String table)
    {
        Trigger_Soft_Disable__c[] custSettings = Trigger_Soft_Disable__c.getAll().values();

        for(Trigger_Soft_Disable__c t : custSettings){
            if(t.name == table){
                custSetting = t;
                break;
            }
        }
       
    }
    
    public boolean insertDisabled()
    {
        return custSetting != null && custSetting.disable_insert__c;
    }
    
    public boolean updateDisabled()
    {
        return custSetting != null && custSetting.disable_update__c;
    }
    
    public boolean deleteDisabled()
    {
        return custSetting != null && custSetting.disable_delete__c;
    }
    
    public boolean undeleteDisabled()
    {
        return custSetting != null && custSetting.disable_undelete__c;
    }
}