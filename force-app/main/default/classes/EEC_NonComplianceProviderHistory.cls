public without sharing class EEC_NonComplianceProviderHistory {
    
    public Map<String,visitWrapper> visitItemMapToShow {get; set;}
    public String currentRecordId {get;set;}
    public String licenseTransactionId {get;set;}
    public Decimal overallCompScore {get; set;}

    public class visitWrapper{
        public Decimal totalNonCompliance {get; set;} 
        public Decimal totalOccurence {get; set;}
        public List<visitItemWrapper> listVisitItems {get; set;}
        public visitWrapper(){            
            this.totalNonCompliance = 0;
            this.totalOccurence = 0;
            this.listVisitItems = new List<visitItemWrapper>();
        }      
    }
    public class visitItemWrapper{
        public String name {get; set;}
        public string listOfRegulations {get; set;} 
        public Decimal noOfNonComp {get; set;}
        public Decimal occurence {get; set;}
        public visitItemWrapper(){
            this.name = '';
            this.listOfRegulations = '';
            this.noOfNonComp = 0;
            this.occurence = 0;
        }      
    }

   
    public EEC_NonComplianceProviderHistory(ApexPages.StandardController controller) {
        overallCompScore = 0;
        visitItemMapToShow = new Map<String,visitWrapper>();
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        Date inspectionDate = date.newinstance(2017, 10, 1);

        visitWrapper v1 = new visitWrapper();
        v1.totalNonCompliance = 5;
        v1.totalOccurence =17;
        List<visitItemWrapper> adminItemList = new List<visitItemWrapper>();

        visitItemWrapper adminItem = new visitItemWrapper();
        adminItem.name = 'Physician Consultation';
        adminItem.listOfRegulations = '18.05(9)(a)M.G.L  c. 71, §§ 53, 53A, and 53B';
        adminItem.noOfNonComp = 3;
        adminItem.occurence =6;
        adminItemList.add(adminItem);

        visitItemWrapper adminItem2 = new visitItemWrapper();
        adminItem2.name = 'Nursing';
        adminItem2.listOfRegulations = '"18.05(9)(b);M.G.L. c. 112 M.G.L. c. 71, §§ 53, 53A, and 53B';
        adminItem2.noOfNonComp = 0;
        adminItem2.occurence =5;
        adminItemList.add(adminItem2);

        visitItemWrapper adminItem3 = new visitItemWrapper();
        adminItem3.name = 'Preventive Health Care';
        adminItem3.listOfRegulations = '18.05(9)(g)(1); 18.05(9)(g)(4)';
        adminItem3.noOfNonComp = 2;
        adminItem3.occurence =6;
        adminItemList.add(adminItem3);

        v1.listVisitItems = adminItemList;
        visitItemMapToShow.put('Area 16: Health and Medical Services', v1);

        //2 
        visitWrapper v2 = new visitWrapper();
        v2.totalNonCompliance = 1;
        v2.totalOccurence =6;
        List<visitItemWrapper> cocItemList = new List<visitItemWrapper>();

        visitItemWrapper cocItem = new visitItemWrapper();
        cocItem.name = 'Attendance Recording and Group Sizes / Ratios';
        cocItem.listOfRegulations = '7.04(04)(a)(01), 7.10(01), 7.10(02), 7.10(03), 7.10(04), 7.10(09)';
        cocItem.noOfNonComp = 1;
        cocItem.occurence =3;
        cocItemList.add(cocItem);

        visitItemWrapper cocItem2 = new visitItemWrapper();
        cocItem2.name = 'Supervision of Children';
        cocItem2.listOfRegulations = '7.10(05)(d), 7.10(05)(f)';
        cocItem2.noOfNonComp = 0;
        cocItem2.occurence =3;
        cocItemList.add(cocItem2);

        v2.listVisitItems = cocItemList;
        visitItemMapToShow.put('Area 18: Student Records', v2);

        //3
        visitWrapper v3 = new visitWrapper();
        v3.totalNonCompliance = 0;
        v3.totalOccurence = 10;
        List<visitItemWrapper> healthItemList = new List<visitItemWrapper>();

        visitItemWrapper healthItem = new visitItemWrapper();
        healthItem.name = 'Diapering and Toileting for children under 2.9';
        healthItem.listOfRegulations = '7.11(12)';
        healthItem.noOfNonComp = 0;
        healthItem.occurence =2;
        healthItemList.add(healthItem);

        visitItemWrapper healthItem2 = new visitItemWrapper();
        healthItem2.name = 'Infection Control / Hand Washing';
        healthItem2.listOfRegulations = '7.11(10)(c), 7.11(10)(d), 7.11(10)(f), 7.11(10)(g), 7.11(10)(l), 7.11(10)(i), 7.11(10)(j), 7.11(10)(m), 7.11(10)(h)';
        healthItem2.noOfNonComp = 0;
        healthItem2.occurence =3;
        healthItemList.add(healthItem2);

        visitItemWrapper healthItem3 = new visitItemWrapper();
        healthItem3.name = 'Sink Spaces';
        healthItem3.listOfRegulations = '7.11(10)(e)';
        healthItem3.noOfNonComp = 0;
        healthItem3.occurence =2;
        healthItemList.add(healthItem3);

        visitItemWrapper healthItem4 = new visitItemWrapper();
        healthItem4.name = 'Toxic Substances';
        healthItem4.listOfRegulations = '7.07(07)(d), 7.07(13)(g)';
        healthItem4.noOfNonComp = 0;
        healthItem4.occurence =3;
        healthItemList.add(healthItem4);

        v3.listVisitItems = healthItemList;
        visitItemMapToShow.put('Area 19: Anti-Hazing', v3);

        //4
        visitWrapper v4 = new visitWrapper();
        v4.totalNonCompliance = 0;
        v4.totalOccurence = 1;
        List<visitItemWrapper> foodItemList = new List<visitItemWrapper>();

        visitItemWrapper foodItem = new visitItemWrapper();
        foodItem.name = 'Food prepared / served in safe / sanitary manner';
        foodItem.listOfRegulations = '7.12(07)(b)';
        foodItem.noOfNonComp = 0;
        foodItem.occurence =1;
        foodItemList.add(foodItem);

        v4.listVisitItems = foodItemList;
        visitItemMapToShow.put('Area 20: Bullying Prevention and Intervention', v4);

        /*5*/
        /*visitWrapper v5 = new visitWrapper();
        v5.totalNonCompliance = 0;
        v5.totalOccurence = 3;
        List<visitItemWrapper> physicalList = new List<visitItemWrapper>();

        visitItemWrapper physicalItem = new visitItemWrapper();
        physicalItem.name = 'Indoor Space';
        physicalItem.listOfRegulations = '7.07(13)(d), 7.07(01), 7.07(02), 7.07(10)';
        physicalItem.noOfNonComp = 0;
        physicalItem.occurence =3;
        physicalList.add(physicalItem);

        v5.listVisitItems = physicalList;
        visitItemMapToShow.put('Physical Facility - Indoors', v5);*/

        /*6*/
        /*visitWrapper v6 = new visitWrapper();
        v6.totalNonCompliance = 0;
        v6.totalOccurence = 3;
        List<visitItemWrapper> physicalOutdoorList = new List<visitItemWrapper>();

        visitItemWrapper physicalOutdoorItem = new visitItemWrapper();
        physicalOutdoorItem.name = 'Outdoor Space';
        physicalOutdoorItem.listOfRegulations = '7.07(07)(e), 7.07(07)(d), 7.07(10), 7.07(13)(d)';
        physicalOutdoorItem.noOfNonComp = 0;
        physicalOutdoorItem.occurence =3;
        physicalOutdoorList.add(physicalOutdoorItem);

        v6.listVisitItems = physicalOutdoorList;
        visitItemMapToShow.put('Physical Facility - Outdoors', v6);*/

        System.debug('visitItemMapToShow'+visitItemMapToShow);
       
        // Licensing_Transaction__c licenseTrans = [SELECT id,Provider__c FROM Licensing_Transaction__c WHERE ID=:licenseTransactionId LIMIT 1];
       // currentRecordId = licenseTrans.Provider__c;

       //visitItemMapToShow- { 'Administration' => visitWrapper :[listVisitItems=(visitItemWrapper:[listOfRegulations=7.11(01)(a)(01), 7.11(01)(a)(02), name=Staff CPR Training, noOfNonComp=0, occurence=2], visitItemWrapper:[listOfRegulations=7.09(17)(d), 7.11(18)(d), name=Staff First Aid Training, noOfNonComp=0, occurence=2], visitItemWrapper:[listOfRegulations=7.11(01), name=EEC Essentials Training completion, noOfNonComp=0, occurence=1]), totalNonCompliance=0, totalOccurence=5], Care of Children=visitWrapper:[listVisitItems=(visitItemWrapper:[listOfRegulations=7.04(04)(a)(01), 7.10(01), 7.10(02), 7.10(03), 7.10(04), 7.10(09), name=Attendance Recording and Group Sizes/Ratios, noOfNonComp=1, occurence=3], visitItemWrapper:[listOfRegulations=7.10(05)(d), 7.10(05)(f), name=Supervision of Children, noOfNonComp=0, occurence=3]), totalNonCompliance=1, totalOccurence=6], Health=visitWrapper:[listVisitItems=(visitItemWrapper:[listOfRegulations=7.11(12), name=Diapering and Toileting for children under 2.9, noOfNonComp=0, occurence=2], visitItemWrapper:[listOfRegulations=7.11(10)(c), 7.11(10)(d), 7.11(10)(f), 7.11(10)(g), 7.11(10)(l), 7.11(10)(i), 7.11(10)(j), 7.11(10)(m), 7.11(10)(h), name=Infection Control/Hand Washing, noOfNonComp=0, occurence=3], visitItemWrapper:[listOfRegulations=7.11(10)(e), name=Sink Spaces, noOfNonComp=0, occurence=2], visitItemWrapper:[listOfRegulations=7.07(07)(d), 7.07(13)(g), name=Toxic Substances, noOfNonComp=0, occurence=3]), totalNonCompliance=0, totalOccurence=10], Mealtime, Food, Food Preparation=visitWrapper:[listVisitItems=(visitItemWrapper:[listOfRegulations=7.12(07)(b), name=Food prepared/served in safe/sanitary manner, noOfNonComp=0, occurence=1]), totalNonCompliance=0, totalOccurence=1], Physical Facility - Indoors=visitWrapper:[listVisitItems=(visitItemWrapper:[listOfRegulations=7.07(13)(d), 7.07(01), 7.07(02), 7.07(10), name=Indoor Space, noOfNonComp=0, occurence=3]), totalNonCompliance=0, totalOccurence=3], Physical Facility - Outdoors=visitWrapper:[listVisitItems=(visitItemWrapper:[listOfRegulations=7.07(07)(e), 7.07(07)(d), 7.07(10), 7.07(13)(d), name=Outdoor Space, noOfNonComp=0, occurence=3]), totalNonCompliance=0, totalOccurence=3]}
        /* Map<Id,Standard_Inspection_Item__c> standardVisitsMap = new Map<Id,Standard_Inspection_Item__c>();
        Map<String,Map<String,visitItemWrapper>> visitItemMap = new Map<String,Map<String,visitItemWrapper>>();
        standardVisitsMap = new Map<Id,Standard_Inspection_Item__c>([SELECT Id, Name, (SELECT Id, Regulation__r.Name FROM Junction_InspRegs__r)
                                                                    FROM Standard_Inspection_Item__c
                                                                    WHERE Include_In_Compliance_Analytics__c = true]);
       
        for(Inspection_Item__c visitItem : [SELECT Id , Name, Legacy_Associated_regulation__c, Category_list__c, Inspection_Item_Name__c, 
                                            Standard_Inspection_Item__c,Inspection_Result__c
                                                FROM Inspection_Item__c
                                                WHERE Standard_Inspection_Item__c IN:standardVisitsMap.keyset()
                                                AND Inspection_No__r.Provider_No__c =: currentRecordId 
                                                AND Inspection_No__r.Status__c = 'Closed' 
                                                AND Inspection_No__r.Type_of_Visit__c != 'Pre-Licensing'
                                                AND Inspection_No__r.Date_of_Visit__c >=: inspectionDate
          
                                                ]){
                      
                                                    
                 if(!visitItemMap.containsKey(visitItem.Category_list__c))
                    visitItemMap.put(visitItem.Category_list__c, new Map<String,visitItemWrapper>());
                 if(!visitItemMap.get(visitItem.Category_list__c).containsKey(visitItem.Inspection_Item_Name__c)){
                    visitItemWrapper vstItemWrap = new visitItemWrapper();
                    vstItemWrap.Name = visitItem.Inspection_Item_Name__c;
                    if(standardVisitsMap.containsKey(visitItem.Standard_Inspection_Item__c)){
                        String lstRegulationNames = '';
                        for(Junction_InspReg__c regulation : standardVisitsMap.get(visitItem.Standard_Inspection_Item__c).Junction_InspRegs__r){
                            if(lstRegulationNames!='')
                                lstRegulationNames+=', ';
                            lstRegulationNames +=regulation.Regulation__r.Name;
                        }
                        vstItemWrap.listOfRegulations = lstRegulationNames;
                    }                    
                    vstItemWrap.noOfNonComp = visitItem.Inspection_Result__c=='Non-Compliant'?1:0;
                    vstItemWrap.occurence = 1;
                    visitItemMap.get(visitItem.Category_list__c).put(visitItem.Inspection_Item_Name__c,vstItemWrap);
                 }else if(visitItemMap.get(visitItem.Category_list__c).containsKey(visitItem.Inspection_Item_Name__c)){
                    visitItemWrapper vstItemWrap = visitItemMap.get(visitItem.Category_list__c).get(visitItem.Inspection_Item_Name__c);
                    if(vstItemWrap.listOfRegulations == ''){
                        if(standardVisitsMap.containsKey(visitItem.Standard_Inspection_Item__c)){
                            String lstRegulationNames = '';
                            for(Junction_InspReg__c regulation : standardVisitsMap.get(visitItem.Standard_Inspection_Item__c).Junction_InspRegs__r){
                                if(lstRegulationNames!='')
                                lstRegulationNames+=', ';
                                lstRegulationNames +=regulation.Regulation__r.Name;
                            }
                            vstItemWrap.listOfRegulations = lstRegulationNames;
                        }      
                    }
                    vstItemWrap.noOfNonComp = visitItem.Inspection_Result__c=='Non-Compliant'?vstItemWrap.noOfNonComp+1:vstItemWrap.noOfNonComp+0;
                    vstItemWrap.occurence = vstItemWrap.occurence+1;
                    visitItemMap.get(visitItem.Category_list__c).put(visitItem.Inspection_Item_Name__c,vstItemWrap);
                 }
        }
        Decimal totalOccurence = 0;
        Decimal totalNonComp = 0;
        for(String domainName : visitItemMap.keyset()){
            visitWrapper vstWrap = new visitWrapper();
            List<visitItemWrapper> visitItemList = new List<visitItemWrapper>();            
            Decimal nonCompTotal = 0;
            Decimal occurenceTotal = 0;
            for(String visitItemName : visitItemMap.get(domainName).keyset()){
                visitItemList.add(visitItemMap.get(domainName).get(visitItemName));
                nonCompTotal += visitItemMap.get(domainName).get(visitItemName).noOfNonComp;
                occurenceTotal += visitItemMap.get(domainName).get(visitItemName).occurence;
            }
            vstWrap.listVisitItems = visitItemList;
            vstWrap.totalNonCompliance = nonCompTotal;
            vstWrap.totalOccurence = occurenceTotal;
            visitItemMapToShow.put(domainName, vstWrap);
            totalNonComp += vstWrap.totalNonCompliance;
            totalOccurence += vstWrap.totalOccurence;
        }        
        if(totalOccurence > 0){

            overallCompScore = (totalNonComp/totalOccurence*100).setScale(2);  
        } */
       
    }
}