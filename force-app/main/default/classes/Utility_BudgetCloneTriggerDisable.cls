/*
* 	Class Name: Utility_BudgetCloneTriggerDisable
* 	Description: Utility_BudgetCloneTriggerDisable
*
* 	Author/Date: Gaurav Sinha/ 06/23/2016
*  
*                                                             
*/
public with sharing class Utility_BudgetCloneTriggerDisable {
    
    public  static boolean executeTrigger =false;
    
    public static void setExecuteTrigger(){
        executeTrigger = true;
    }

}