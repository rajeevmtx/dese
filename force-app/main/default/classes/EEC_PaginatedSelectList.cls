public with sharing class EEC_PaginatedSelectList {
      private List<SelectOption> selectList=new List<SelectOption>();
      private final Integer SUB_LIST_SIZE=1000;
      //Returns total numbers of items.
      public Integer getSize(){
            return selectList.size();
      }
      //Add SelectOption.
      public void add(SelectOption so){
                  selectList.add(so);
      }
      //Gets SelectOption at given index.
      public SelectOption get(Integer index){
            if(index>-1 && index<getSize()){
                  return selectList.get(index);
            }else{
                  return null;
            }    
      }
      //Removes SelectOption at given index
      public void remove(Integer index){
            if(index>-1 && index<getSize()){
                  selectList.remove(index);
            }    
      }

      public void clear(){
            selectList.clear();
      }

      public List<SelectOption> getSelectList(){
            return selectList;
      }

      //Gets Select Options for the given start and end index both are inclusive.
      public List<SelectOption> getSubList(Integer startIndex,Integer endIndex){
            List<SelectOption> subList=new List<SelectOption>();
            if(startIndex>-1 && startIndex<selectList.size()&& endIndex>-1 && endIndex<selectList.size()&&startIndex<=endIndex){
                  for(Integer i=startIndex;i<=endIndex;i++){
                        subList.add(get(i));
                  }
            }
            return subList;
      }
      //Gets Nth sub list by dividing the main list in sublists of SUB_LIST_SIZE(1000 elements).
      public List<SelectOption>getNthSubList(Integer index){
            Integer subListCount=(Integer)(selectList.size()/SUB_LIST_SIZE);
            if(Math.mod(selectList.size(),SUB_LIST_SIZE)>0) subListCount++;
            if(index>=0 && index<=subListCount){
                  Integer startIndex=index*SUB_LIST_SIZE;
                  Integer endIndex=index*SUB_LIST_SIZE+(SUB_LIST_SIZE-1);
                  if(endIndex>=selectList.size())endIndex=selectList.size()-1;
                  return getSubList(startIndex,endIndex);
            }else{
                  return new List<SelectOption>();
            }
      }
      //Gets sublist for given index.

      public List<SelectOption>get0(){
            return getNthSubList(0);
      }
      public List<SelectOption>get1(){
            return getNthSubList(1);
      }
      public List<SelectOption>get2(){
            return getNthSubList(2);
      }
      public List<SelectOption>get3(){
            return getNthSubList(3);
      }
      public List<SelectOption>get4(){
            return getNthSubList(4);
      }
      public List<SelectOption>get5(){
            return getNthSubList(5);
      }
}