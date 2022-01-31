public class EEC_NavigationController {
    //variables
    public String currentPage;
    public String recordTypeName ;
    public String highestReachedStep;
    public String provRecordTypeDeveloperName;
    public Boolean IsAssistantUpgradeCertified { get; set; }
    public Boolean initialized { get; set; }
    public String licenseStatus { get; set; }
    public void setcurrentPage(String s) {
        currentPage = s;
        if (!initialized) {
            initializeThatDependsOnReceivedString();
        }
    }
    public String getcurrentPage() {
        return currentPage;
    }
    public void setHighestReachedStep(String s) {
        highestReachedStep = s;
        if (!initialized) {
            initializeThatDependsOnReceivedString();
        }
    }
    public String getHighestReachedStep() {
        return highestReachedStep;
    }
    public void setrecordTypeName(String s) {
        recordTypeName = s;
        if (!initialized) {
            initializeThatDependsOnReceivedString();
        }
    }
    public String getrecordTypeName() {
        return recordTypeName;
    }
    public void setprovRecordTypeDeveloperName(String s) {
        provRecordTypeDeveloperName = s;
        if (!initialized) {
            initializeThatDependsOnReceivedString();
        }
    }
    public String getprovRecordTypeDeveloperName() {
        return provRecordTypeDeveloperName;
    }
    public List<NavigationWrapper> listNavigationWrapper { get; set; }
    public class NavigationWrapper {
        public string pageName { get; set; }
        public boolean selected { get; set; }
        public boolean passed { get; set; }
        public string navigateToStep { get; set; }
    }
    public static map<string, list<string>> recordTypeAvailablePageMap = new map<string, list<String>>{
        'FCC_New_License' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Household Members',
            'License Status and Capacity',
            // 'Assistant Information',
            'Involvement / Professional Experience',
            'Background Information',
            'Training Information',
            'Indoor / Outdoor space information',
            //'Technical Assistance',
            'Attachments',
            'Review & Submission'
        },
        'FCC_License_Upgrade' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Household Members',
                'License Status and Capacity',
                // 'Assistant Information',
                'Background Information',
                'Training Information',
                'Indoor / Outdoor space information',
                'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Change_of_Address' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Household Members',
            'Indoor / Outdoor space information',
            // 'Variance Details',
            'Review & Submission'
        },
        'FCC_Change_Room_Floor_Level' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Indoor / Outdoor space information',
            'Technical Assistance',
            'Review & Submission'
        },
        'FCC_Change_of_Household' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Household Members',
            'Technical Assistance',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Renewal' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Household Members',
            'License Status and Capacity',
            //  'Assistant Information',
            'Background Information',
            'Training Information',
            'Indoor / Outdoor space information',
            //'Technical Assistance',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_License_Upgrade' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            //'EEC Involvement Experience & Professional Exp',
            'Background Information',
            // 'Daily Routine & Activities',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_New_License' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Involvement / Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_Renewal' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            //'Involvement & Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Re_Active' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'FCC_Inactivate' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Re_issuance_of_License_Cert' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Close_Prior_Expiration' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Change_of_Provider_Name' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'FCC_Change_of_Name' => new list<String>{
            'Instructions',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Downgrade_Capacity' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'EEC_FCC_Modification' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            // 'License Status and Capacity',
            'Indoor / Outdoor space information',
            'Review & Submission'
        },
        'Variance_On_Regulation_Request' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Variance Details',
            'Attachments',
            'Review & Submission'
        },
        'Background_Record_Check' => new list<String>{
            'Instructions',
            'Household Members',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> assistantRecordTypeAvailablePageMap = new map<string, list<String>>{
        'FCC_Assistant_License_Upgrade' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            //'EEC Involvement Experience & Professional Exp',
            'Background Information',
            // 'Daily Routine & Activities',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Regular_Assistant_to_Certified_Assistant' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Involvement / Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_New_License' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Involvement / Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_Renewal' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            //'Involvement & Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Re_Active' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'FCC_Inactivate' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Re_issuance_of_License_Cert' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Close_Prior_Expiration' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'FCC_Change_of_Name' => new list<String>{
            'Instructions',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Downgrade_Capacity' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Variance_On_Regulation_Request' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Variance Details',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_Change_of_Address' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            // 'Variance Details',
            'Review & Submission'
        }, 'Background_Record_Check' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> AssistantUpgradeRecordTypeAvailablePageMap = new map<string, list<String>>{
        'FCC_Assistant_New_License' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Involvement / Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_Renewal' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Involvement / Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_License_Upgrade' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Involvement / Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Regular_Assistant_to_Certified_Assistant' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Involvement / Professional Experience',
            'Daily Routine & Activities',
            'Background Information',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },
        'FCC_Assistant_Change_of_Address' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            // 'Variance Details',
            'Review & Submission'
        },'Variance_On_Regulation_Request' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Variance Details',
            'Attachments',
            'Review & Submission'
        }, 'Background_Record_Check' => new list<String>{
            'Instructions',
            'Transaction / Assistant Information',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> GSArecordTypeAvailablePageMap = new map<string, list<String>>{
        'GSA_New_License' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Ownership and Administrator information',
            'Designation of Administrative Responsibility',
            'Capacity Information',
            'Operation details Information',
            'Indoor / Outdoor space information',
            // 'Technical Assistance',
            'Attachments',
            'Review & Submission'
            // 'Payment Information'
        },
        'GSA_Renewal' =>
            new list<String>{
                'Instructions',
                'Transaction / Program Information',
                'Ownership and Administrator information',
                'Designation of Administrative Responsibility',
                'Capacity Information',
                'Operation details Information',
                'Indoor / Outdoor space information',
                // 'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'GSA_License_Change' =>
            new list<String>{
                'Instructions',
                'Transaction / Program Information',
                'Capacity Information',
                // 'Operation details Information',
                'Indoor / Outdoor space information',
                // 'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'GSA_Move' =>
            new list<String>{
                'Instructions',
                'Transaction / Program Information',
                'Ownership and Administrator information',
                'Designation of Administrative Responsibility',
                'Capacity Information',
                'Operation details Information',
                'Indoor / Outdoor space information',
                // 'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'GSA_Temporary_Move' =>
            new list<String>{
                'Instructions',
                'Transaction / Program Information',
                'Ownership and Administrator information',
                'Designation of Administrative Responsibility',
                'Capacity Information',
                'Operation details Information',
                'Indoor / Outdoor space information',
                //  'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'GSA_Change_of_Admin_Authority' =>
            new list<String>{
                'Instructions',
                'Transaction / Program Information',
                'Ownership and Administrator information',
                'Designation of Administrative Responsibility',
                //  'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Re_issuance_of_License_Cert' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'EEC_GSA_Modification' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Capacity Information',
            'Review & Submission'
        },
        'Close_Prior_Expiration' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Change_of_Provider_Name' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Variance_On_Regulation_Request' =>
            new list<String>{
                'Instructions',
                'Transaction / Program Information',
                'Variance Details',
                'Attachments',
                'Review & Submission'
            },
        'Background_Record_Check' => new list<String>{
            'Instructions',
            'Ownership and Administrator information',
            'Review & Submission'
        }, 'Contact_Management' => new list<String>{
                'Instructions',
                'Ownership and Administrator information',
                'Review & Submission'
        }, 'Licensee_BRC_Renewal' => new list<String>{
            'Instructions',
            'Ownership and Administrator information',
            'Review & Submission'
        },'Licensee_Management' => new list<String>{
            'Instructions',
            'Licensee Contact Information',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> RPrecordTypeAvailablePageMap = new map<string, list<String>>{
        'Residential_New_License' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Ownership and Administrator information',
            'Residential Program Details',
            //'Technical Assistance',
            'Attachments',
            'Review & Submission'
        },
        'Residential_License_Renewal' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Ownership and Administrator information',
                'Residential Program Details',
                // 'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Residential_Change_in_License' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Residential Program Details',
                // 'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Residential_Move' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                //  'Ownership and Administrator information',
                //  'Residential Program Details',
                //  'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'R_P_Change_of_Admin_Authority' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Ownership and Administrator information',
                //  'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Placement_New_License' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Ownership and Administrator information',
                'Placement Agency Additional info',
                //  'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Placement_Renewal' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Ownership and Administrator information',
                'Placement Agency Additional info',
                //'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Placement_Change_in_License' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Placement Agency Additional info',
                //'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Placement_Move' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Ownership and Administrator information',
                'Placement Agency Additional info',
                //'Technical Assistance',
                'Attachments',
                'Review & Submission'
            },
        'Re_issuance_of_License_Cert' =>
            new list<String>{
                'Instructions',
                'Review & Submission'
            },
        'Close_Prior_Expiration' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'EEC_RP_Modification' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Residential Program Details',
            'Review & Submission'
        },
        'Change_of_Provider_Name' => new list<String>{
            'Instructions',
            'Review & Submission'
        },
        'Variance_On_Regulation_Request' =>
            new list<String>{
                'Instructions',
                'Transaction / Provider Information',
                'Variance Details',
                'Attachments',
                'Review & Submission'
            },
        'Background_Record_Check' => new list<String>{
            'Instructions',
            'Ownership and Administrator information',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> cbcRecordTypeAvailablePageMap = new map<string, list<String>>{
        'CBC_New_License_Application' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Ownership and Administrator information',
            'Designation of Administrative Responsibility',
            'Capacity Information',
            'Operation details Information',
            'Indoor / Outdoor space information',
            // 'Technical Assistance',
            'Attachments',
            'Review & Submission'
            //   'Payment Information'
        },'Close _Funded_Program' => new List<String>{
                        'Instructions',
                        'Review & Submission'
                }
    };
    public static map<string, list<string>> privateSchoolRecordTypeAvailablePageMap = new map<string, list<String>>{
        'Private_School_New_Funding_Application' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Ownership and Administrator information',
            'Designation of Administrative Responsibility',
            'Capacity Information',
            'Operation details Information',
            'Indoor / Outdoor space information',
            // 'Technical Assistance',
            'Attachments',
            'Review & Submission'
            //   'Payment Information'
        },'Close_Funded_Program' => new List<String>{
            'Instructions',
            'Close Funding Info',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> publicSchoolRecordTypeAvailablePageMap = new map<string, list<String>>{
        'Public_School_New_Funding_Application' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Ownership and Administrator information',
            'Designation of Administrative Responsibility',
            'Capacity Information',
            'Operation details Information',
            'Indoor / Outdoor space information',
            // 'Technical Assistance',
            'Attachments',
            'Review & Submission'
            //   'Payment Information'
        },'Close_Funded_Program' => new List<String>{
            'Instructions',
            'Close Funding Info',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> otherEligibleProvidersRecordTypeAvailablePageMap = new map<string, list<String>>{
        'Other_Eligible_Providers_New_Funding_Application' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Ownership and Administrator information',
            'Designation of Administrative Responsibility',
            'Capacity Information',
            'Operation details Information',
            'Indoor / Outdoor space information',
            // 'Technical Assistance',
            'Attachments',
            'Review & Submission'
            //   'Payment Information'
        },'Close_Funded_Program' => new List<String>{
            'Instructions',
            'Close Funding Info',
            'Review & Submission'
        }
    };
    public static map<string, list<string>> summerCampRecordTypeAvailablePageMap = new map<string, list<String>>{
        'Summer_Camp_New_Application' => new list<String>{
            'Instructions',
            'Transaction / Program Information',
            'Ownership and Administrator information',
            'Designation of Administrative Responsibility',
            'Capacity Information',
            'Operation details Information',
            'Indoor / Outdoor space information',
            // 'Technical Assistance',
            'Attachments',
            'Review & Submission'
            //   'Payment Information'
        }, 'Child_Care_Licensing_Exemption' => new list<string>{
            'Instructions',
            'Transaction / Program Information',
            'Involvement / Professional Experience',
            'Household Members',
            //'Ownership and Administrator information',
            'Attachments',
            'Review & Submission'
        },'Close_Funded_Program' => new List<String>{
                        'Instructions',
                        'Review & Submission'
                } 
    };
    public static map<string, list<string>> informalCareRecordTypeAvailablePageMap = new map<string, list<String>>{
        'Informal_Care_New_Application' => new list<String>{
            'Instructions',
            'Transaction / Provider Information',
            'Involvement / Professional Experience',
            'Training Information',
            'Attachments',
            'Review & Submission'
        },'Close_Funded_Program' => new List<String>{
                        'Instructions',
                        'Review & Submission'
        }
    };
    //Constructor
    public EEC_NavigationController() {
        initialized = false;
    }
    private void initializeThatDependsOnReceivedString() {
        listNavigationWrapper = new List<NavigationWrapper>();
        List<string> listSteps;
        if (IsAssistantUpgradeCertified == null) {
            IsAssistantUpgradeCertified = false;
        }
        if (provRecordTypeDeveloperName != null && recordTypeName != null && currentPage != null) {
            initialized = true;
            if (provRecordTypeDeveloperName == EEC_Constants.PRO_FCC) {
                listSteps = recordTypeAvailablePageMap.get(recordTypeName);
            } else if (provRecordTypeDeveloperName == EEC_Constants.PRO_FCC_ASSISTANT) {
                if (IsAssistantUpgradeCertified) {
                    listSteps = AssistantUpgradeRecordTypeAvailablePageMap.get(recordTypeName);
                } else {
                    listSteps = assistantRecordTypeAvailablePageMap.get(recordTypeName);
                }
            } else if (provRecordTypeDeveloperName == EEC_Constants.PRO_LARGE_GROUP || provRecordTypeDeveloperName == EEC_Constants.PRO_SMALL_GROUP || provRecordTypeDeveloperName == 'Large and Small Group Umbrella') {
                listSteps = GSArecordTypeAvailablePageMap.get(recordTypeName);
            } else if (provRecordTypeDeveloperName == 'R&P Umbrella' || provRecordTypeDeveloperName == EEC_Constants.PRO_TEMPORARY_SHELTER || provRecordTypeDeveloperName == EEC_Constants.PRO_GROUP_CARE
                    || provRecordTypeDeveloperName == EEC_Constants.PRO_FOSTER_CARE_AGENCY || provRecordTypeDeveloperName == EEC_Constants.PRO_ADOPTION_AGENCY) {
                listSteps = RPrecordTypeAvailablePageMap.get(recordTypeName);
            } else if (provRecordTypeDeveloperName == EEC_Constants.PRO_EXEMPT_CBC_CARE) {
                listSteps = cbcRecordTypeAvailablePageMap.get(recordTypeName);
            }else if (provRecordTypeDeveloperName == EEC_Constants.PRO_PRIVATE_SCHOOL) {
                listSteps = privateSchoolRecordTypeAvailablePageMap.get(recordTypeName);
            }else if (provRecordTypeDeveloperName == EEC_Constants.PRO_PUBLIC_SCHOOL) {
                listSteps = publicSchoolRecordTypeAvailablePageMap.get(recordTypeName);
            }else if (provRecordTypeDeveloperName == EEC_Constants.PRO_OTHER_ELIGIBLE_PROVIDER) {
                listSteps = otherEligibleProvidersRecordTypeAvailablePageMap.get(recordTypeName);
            } else if (provRecordTypeDeveloperName == EEC_Constants.PRO_SUMMER_CAMP) {
                listSteps = summerCampRecordTypeAvailablePageMap.get(recordTypeName);
            } else if (provRecordTypeDeveloperName == EEC_Constants.PRO_INFORMAL_CHILD_CARE) {
                listSteps = informalCareRecordTypeAvailablePageMap.get(recordTypeName);
            }
            boolean IsCurrentPassed = false;
            Boolean isHighestPassed = false;
            integer iCurrent = 0;
            if (listSteps != null) {
                for (integer iCount = 0; iCount < listSteps.size(); iCount++) {
                    NavigationWrapper NavigationWrapper = new NavigationWrapper();
                    NavigationWrapper.pageName = listSteps[iCount];
                    if (String.isNotBlank(highestReachedStep)) {
                        if (listSteps[iCount] != highestReachedStep && isHighestPassed == false) {
                            NavigationWrapper.selected = false;
                            NavigationWrapper.passed = true;
                            NavigationWrapper.navigateToStep = listSteps[iCount];
                        } else if (listSteps[iCount] != highestReachedStep && isHighestPassed == true) {
                            NavigationWrapper.selected = false;
                            NavigationWrapper.passed = false;
                            NavigationWrapper.navigateToStep = '';
                        } else if (listSteps[iCount] == highestReachedStep) {
                            NavigationWrapper.selected = false;
                            NavigationWrapper.passed = true;
                            NavigationWrapper.navigateToStep = listSteps[iCount];
                            isHighestPassed = true;
                        }
                    } else {
                        if (listSteps[iCount] != currentPage && IsCurrentPassed == false) {
                            NavigationWrapper.selected = false;
                            NavigationWrapper.passed = true;
                            NavigationWrapper.navigateToStep = listSteps[iCount];
                        } else if (listSteps[iCount] != currentPage && IsCurrentPassed == true) {
                            NavigationWrapper.selected = false;
                            NavigationWrapper.passed = false;
                            NavigationWrapper.navigateToStep = '';
                        } else if (listSteps[iCount] == currentPage) {
                            NavigationWrapper.selected = false;
                            NavigationWrapper.passed = true;
                            NavigationWrapper.navigateToStep = listSteps[iCount];
                            isHighestPassed = true;
                        }
                    }
                    if (listSteps[iCount] == currentPage) {
                        NavigationWrapper.selected = true;
                        NavigationWrapper.passed = false;
                        NavigationWrapper.navigateToStep = '';
                        IsCurrentPassed = true;
                    }
                    if (listSteps[iCount] == currentPage && listSteps[iCount] == highestReachedStep && !string.isBlank(licenseStatus) && licenseStatus != 'Unsubmitted') {
                        NavigationWrapper.selected = true;
                        NavigationWrapper.passed = true;
                        NavigationWrapper.navigateToStep = '';
                        IsCurrentPassed = true;
                    }
                    if (!IsCurrentPassed) {
                        iCurrent++;
                    }
                    listNavigationWrapper.add(NavigationWrapper);
                }
            }
        }
    }
}