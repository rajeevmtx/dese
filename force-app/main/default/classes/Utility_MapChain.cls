/*
* 	Class Name: Utility_MapChain
* 	Description: A self-referencing (recursive) class that stores an n-tier grouping.
*				 This is a generic replacement for creating maps of maps, maps of maps of maps, etc...
*
* 	Author/Date: George Acker/March 15, 2016
*                        
*/
public class Utility_MapChain
{
    public object data;
    public Map<object,Utility_MapChain> grouping;
    
    // Call this constructor to instantiate the first object.  Think of it as the root.  It will never have data != null and contains your first tier of mappings
    public Utility_MapChain()
    {
        grouping = new Map<object,Utility_MapChain>();
    }
    
    // You should never need to call this, hence why it is private.
    private Utility_MapChain(object obj, List<object> fields)
    {
        grouping = new Map<object,Utility_MapChain>();
        if (fields != null)
        {
            insertData(this,fields,obj);
        }
    }
    
    /*
	* Method Name: getData
	* Description: Pass the root chain in, along with a list of fields in the order you want them parsed and get back an object
	* @param: List<object> flds
	* @param: object obj
	* @return: object                                                       
	*/
    public object getData(List<object> flds)
    {
        List<object> fields = new List<object>(flds); //cloning because if get returns null you may want to put the data in with the same list
        Utility_MapChain chain = findChainLink(this,fields);        
        return chain.data;
    }
    
    /*
	* Method Name: putData
	* Description: Pass the root chain in, along with a list of fields in the order you want them parsed and the data to be put into the map chain
	* @param: List<object> flds
	* @param: object obj
	* @return: void                                                       
	*/
    public void putData(List<object> flds, object obj)
    {
        List<object> fields = new List<object>(flds); //cloning to avoid destroying the list that was passed in
        Utility_MapChain chain = findChainLink(this,fields);
        insertData(chain,fields,obj);
    }
     
    /*
	* Method Name: keySet
	* Description: Get back a list of all of the keys (represented as lists, so you get a list of a list of objects).
	*			   Note that it is called keyset because the list is unordered (you can't create a set of a list).
	* @param: none
	* @return: List<List<object>>                                                      
	*/
    public List<List<object>> keySet()
    {
        return keySet(this);
    }
    
    private static List<List<object>> keySet(Utility_MapChain chain)
    {
        List<List<object>> keys = new List<List<object>>();
        for(object o :chain.grouping.keyset())
        {
            List<List<object>> childKeyset = keySet(chain.grouping.get(o));
            for (List<object> childKeys :childkeyset)
            {
                object[] keyList = new object[]{o};
                keyList.addAll(childKeys);
                keys.add(keyList);
            }
            if (childKeyset.size() == 0) //if no child keys, then we need to just return the keys in this chain as a list of a list of size one
            {
                object[] keyList = new object[]{o};
                keys.add(keyList);
            }
        }
        return keys;
    }
    
    private static Utility_MapChain findChainLink(Utility_MapChain chain, List<object> fields)
    {
        while(chain.grouping != null && fields.size() > 0 && chain.grouping.containsKey(fields[0]))
        {
            chain = chain.grouping.get(fields[0]);
            fields.remove(0);
        }
        return chain;
    }
    
    private static void insertData(Utility_MapChain chain, List<object> fields, object obj)
    {
        if (fields.size() == 0)
            chain.data = obj;
        else
        {
            object f = fields.remove(0);
            chain.grouping.put(f,new Utility_MapChain(obj,fields));
        }
    }
}