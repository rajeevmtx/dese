/*
*   Class Name: ProgramPartnership_Helper
*   Description: Helper class dealing with Program_Partnership__c records.
*
*                                                             
*/
public with sharing class ProgramPartnership_Helper {
  
  public static final String STATUS_PROVISIONAL = 'Provisional';
  
  public static final String STATUS_SUSPENDED = 'Suspended';
  public static final String STATUS_TERMINATED = 'Terminated';
  public static final String STATUS_PROBATION = 'Probation';
  public static final String STATUS_FULL = 'Full';
  
  public static final Set<String> SET_OF_SUSPENDED_STATUSES = new Set<String>{STATUS_SUSPENDED, STATUS_TERMINATED};
  
  
}