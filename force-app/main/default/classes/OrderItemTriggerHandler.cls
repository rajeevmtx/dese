public class OrderItemTriggerHandler {
    public static void rollUpToProduct(List<OrderItem> newList,Map<Id,OrderItem> oldMap){
        System.debug('New List'+newList);
        Set<Id> productIdSet = new Set<Id>();
     	List<Product2> productList = new List<Product2>();
        Map<Id,Double> productIdToQuantityMap = new Map<Id,Double>();
        for(OrderItem item : newList){
            if(item.Product2Id != null && oldMap == null){
               if(!productIdToQuantityMap.containsKey(item.Id)){
                    productIdToQuantityMap.put(item.Product2Id,0);
                }
                productIdToQuantityMap.put(item.Product2Id,productIdToQuantityMap.get(item.Product2Id) + item.Quantity);
                productIdSet.add(item.Product2Id);
            }
            else if(item.Product2Id != null && oldMap != null && oldMap.get(item.Id).Quantity != item.Quantity){
                Double updatedQuantity = item.Quantity - oldMap.get(item.Id).Quantity ;
				if(!productIdToQuantityMap.containsKey(item.Id)){
                    productIdToQuantityMap.put(item.Product2Id,0);
                }
                 productIdToQuantityMap.put(item.Product2Id,productIdToQuantityMap.get(item.Product2Id) + updatedQuantity);
                  productIdSet.add(item.Product2Id);   
            }
        }
        
        
        for(Product2 pdt : [SELECT Id,used_Quantity__c FROM Product2 WHERE Id IN:productIdSet]){
            Product2 pdtObj = new Product2();
            pdtObj.Id = pdt.Id;
            if(productIdToQuantityMap.containsKey(pdt.Id)){
                pdtObj.Used_Quantity__c = productIdToQuantityMap.get(pdt.Id) + pdt.used_Quantity__c;
            }
			productList.add(pdtObj);
        }
        if(!productList.isEmpty()){
            System.debug('Update product List');
            update productList;
        }
    }
    
    public static void rollUpToProductforDelete(List<OrderItem> oldList){
        System.debug('Old List='+oldList);
        List<Product2> productList = new List<Product2>();
        Set<Id> productIdSet = new Set<Id>();
        Map<Id,Double> productIdToQuantityMap = new Map<Id,Double>();
        for(OrderItem item : oldList){
            if(item.Product2Id != null){
                if(!productIdToQuantityMap.containsKey(item.Id)){
                    productIdToQuantityMap.put(item.Product2Id,0);
                }
                productIdToQuantityMap.put(item.Product2Id,productIdToQuantityMap.get(item.Product2Id) + item.Quantity);
                productIdSet.add(item.Product2Id);
            }
        }
        
        for(Product2 pdt : [SELECT Id,used_Quantity__c FROM Product2 WHERE Id IN:productIdSet]){
            Product2 pdtObj = new Product2();
            pdtObj.Id = pdt.Id;
            if(productIdToQuantityMap.containsKey(pdt.Id)){
                pdtObj.Used_Quantity__c = pdt.Used_Quantity__c - productIdToQuantityMap.get(pdt.Id);
            }
			productList.add(pdtObj);
        }
        
        if(!productList.isEmpty()){
            update productList;
        }
    }
}