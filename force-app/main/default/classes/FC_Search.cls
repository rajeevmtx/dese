public class FC_Search {
    @AuraEnabled
    public static List<Account> getMatchingRecords(String searchString){

        System.debug('incoming search String: '+searchString);
        SearchStringWrapper wrapper = (SearchStringWrapper) JSON.deserializeStrict(searchString, SearchStringWrapper.class);
        List<Account> resultAccounts = new List<Account>();
        Set<Account> returnAccounts = new Set<Account>();
        String query = 'Select Id, Name, BillingAddress, Marital_Status__c, Employment_Status__c, Homeowner_Status__c, (Select Id, Type__c, Value__c from Parent_Preferences__r) from Account';
        List<String> whereConditionList = new List<String>();
        
        if(wrapper.address != null) {
            String addr = '\'%' + wrapper.address  + '%\'';
            whereConditionList.add('(BillingCity LIKE ' + addr + ' OR BillingPostalCode LIKE ' + addr + ' OR BillingState LIKE '+ addr + ')');
        }
        if(wrapper.maritalStatus != null) {
            whereConditionList.add(' Marital_Status__c = ' + '\''+ wrapper.maritalStatus + '\''); 
        }
        if(wrapper.employmentStatus != null) {
            whereConditionList.add(' Employment_Status__c = ' + '\''+ wrapper.employmentStatus + '\''); 
        }
        if(wrapper.homeownerStatus != null) {
            whereConditionList.add(' Homeowner_Status__c = ' + '\''+  wrapper.homeownerStatus + '\''); 
        }

        if(!whereConditionList.isEmpty()) {
            String whereCondition = ' WHERE ' + String.join(whereConditionList, ' AND ');

            System.debug('whereCondition : '+ whereCondition);
    
            query += whereCondition;
        }

        System.debug('Query: '+ query);
        resultAccounts = Database.query(query);

        if(wrapper.ageRange != null) {
            List<String> ageRange = new List<String>();
            ageRange = wrapper.ageRange.split('-');
            if(!resultAccounts.isEmpty()) {
                Map<Id, Account> accsMap = new Map<Id, Account>();
                Map<Id, List<Preference_and_Condition__c>> accConditionsMap = new Map<Id, List<Preference_and_Condition__c>>();
                for (Account each : resultAccounts) {
                    if(!accConditionsMap.containsKey(each.Id)) {
                        accConditionsMap.put(each.Id, each.Parent_Preferences__r);
                    }
                    if(!accsMap.containsKey(each.Id)) {
                        accsMap.put(each.Id, each);
                    }
                }
                for (Id eachId : accConditionsMap.keySet()) {
                    List<Preference_and_Condition__c> childs = new List<Preference_and_Condition__c>();
                    if(accConditionsMap.get(eachId) != null) {
                        List<Preference_and_Condition__c> each = accConditionsMap.get(eachId);
                        for (Preference_and_Condition__c child : each) {
                            if(child.Type__c == 'Min Age' && Integer.valueOf(ageRange[0]) <= Integer.valueOf(child.Value__c) ) {
                                childs.add(child);
                            } 
                            if(child.Type__c == 'Max Age' && Integer.valueOf(ageRange[1]) >= Integer.valueOf(child.Value__c) ) {
                                childs.add(child);
                            }
                            if (childs.size() > 1) {
                                returnAccounts.add(accsMap.get(eachId));
                            }
                        }
                    }
                }
            }
        } else {
            returnAccounts.addAll(resultAccounts);
        }



        return  new List<Account>(returnAccounts);
    }



    public class SearchStringWrapper {
        public String address;
        public String maritalStatus;
        public String employmentStatus;
        public String homeownerStatus;
        public String ageRange;
    }
}